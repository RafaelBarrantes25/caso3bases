CREATE TABLE dbo.Empleados (
    EmpleadoID      INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          VARCHAR(100) NOT NULL,
    Puesto          VARCHAR(100) NOT NULL,
    Salario         DECIMAL(10,2) NOT NULL,
    NumeroTarjeta   VARCHAR(20) NOT NULL,
    CorreoElectronico VARCHAR(100) NOT NULL,
    Region          VARCHAR(50) NOT NULL,
    UsuarioBD       SYSNAME NULL  -- para RLS: vincula la fila a un login
);
GO

INSERT INTO dbo.Empleados (Nombre, Puesto, Salario, NumeroTarjeta, CorreoElectronico, Region, UsuarioBD)
VALUES
('Ana Pérez',   'Analista',  850000, '4111111111111111', 'ana.perez@gathel.com',  'Norte', 'usr_norte'),
('Luis Gómez',  'Gerente',  1500000, '4222222222222222', 'luis.gomez@gathel.com', 'Sur',   'usr_sur'),
('María Solano','Analista',  900000, '4333333333333333', 'maria.solano@gathel.com','Norte','usr_norte'),
('Carlos Vargas','Gerente', 1600000, '4444444444444444', 'carlos.vargas@gathel.com','Sur',  'usr_sur');
GO

-- ============================================================
-- 1. CREACIÓN DE USUARIOS DE PRUEBA
-- ============================================================

CREATE LOGIN usr_norte WITH PASSWORD = 'Norte#2026!';
CREATE LOGIN usr_sur   WITH PASSWORD = 'Sur#2026!';
CREATE LOGIN usr_aud   WITH PASSWORD = 'Aud#2026!';   -- usuario solo lectura
CREATE LOGIN usr_app   WITH PASSWORD = 'App#2026!';   -- usuario que solo escribe
GO

-- Usuarios dentro de la base de datos
CREATE USER usr_norte FOR LOGIN usr_norte;
CREATE USER usr_sur   FOR LOGIN usr_sur;
CREATE USER usr_aud   FOR LOGIN usr_aud;
CREATE USER usr_app   FOR LOGIN usr_app;
GO

-- ============================================================
-- 2. CREACIÓN DE ROLES CON PERMISOS ESPECÍFICOS
-- ============================================================
CREATE ROLE rol_lectura;
CREATE ROLE rol_escritura;
CREATE ROLE rol_gerencia;
GO

-- rol_lectura: solo SELECT sobre Empleados
GRANT SELECT ON dbo.Empleados TO rol_lectura;

-- rol_escritura: solo INSERT y UPDATE, sin SELECT
GRANT INSERT, UPDATE ON dbo.Empleados TO rol_escritura;

-- rol_gerencia: acceso completo
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Empleados TO rol_gerencia;
GO

-- ============================================================
-- 3. ASIGNACIÓN DE USUARIOS A ROLES
-- ============================================================
ALTER ROLE rol_lectura  ADD MEMBER usr_aud;     -- usr_aud: solo lectura
ALTER ROLE rol_escritura ADD MEMBER usr_app;    -- usr_app: solo escritura
ALTER ROLE rol_lectura  ADD MEMBER usr_norte;   -- usr_norte: lectura
ALTER ROLE rol_lectura  ADD MEMBER usr_sur;     -- usr_sur: lectura
GO

-- ============================================================
-- 4. PERMISO DIRECTO Y PERMISO HEREDADO EN EL MISMO USUARIO
-- ============================================================
-- usr_norte ya tiene SELECT heredado de rol_lectura.
-- Le damos además un permiso directo adicional: UPDATE solo en columna Salario
GRANT UPDATE ON dbo.Empleados(Salario) TO usr_norte;
GO

-- Verificar permisos efectivos de usr_norte:
EXECUTE AS USER = 'usr_norte';
SELECT * FROM fn_my_permissions(N'dbo.Empleados', 'OBJECT');
REVERT;
GO

-- ============================================================
-- 5. SELECT BLOQUEADO Y ACCESO INDIRECTO POR STORED PROCEDURE
-- ============================================================
-- usr_app no tiene SELECT directo (solo INSERT/UPDATE por rol_escritura)

-- Stored Procedure con EXECUTE AS OWNER para saltar la restricción
CREATE PROCEDURE dbo.sp_ConsultarEmpleados
WITH EXECUTE AS OWNER
AS
BEGIN
    SELECT EmpleadoID, Nombre, Puesto, Region
    FROM dbo.Empleados;
END;
GO

-- Permitir a usr_app ejecutar el SP (pero no leer la tabla directamente)
GRANT EXECUTE ON dbo.sp_ConsultarEmpleados TO usr_app;
GO

-- PRUEBA: usr_app no puede hacer SELECT directo
EXECUTE AS USER = 'usr_app';
    -- Esto debe fallar (Permiso denegado)
    -- SELECT * FROM dbo.Empleados;

    -- Esto sí debe funcionar (acceso indirecto vía SP)
    EXEC dbo.sp_ConsultarEmpleados;
REVERT;
GO

-- ============================================================
-- 6. LECTURA SIN ESCRITURA Y VICEVERSA
-- ============================================================
-- usr_aud (rol_lectura): puede SELECT, NO puede INSERT/UPDATE/DELETE
EXECUTE AS USER = 'usr_aud';
    SELECT * FROM dbo.Empleados;                  -- Sirve
    -- INSERT INTO dbo.Empleados (Nombre, Puesto, Salario, NumeroTarjeta, CorreoElectronico, Region)
    -- VALUES ('Prueba','Test',1,'0000','x@x.com','Norte');  -- Falla
REVERT;
GO

-- usr_app (rol_escritura): puede INSERT/UPDATE, no puede SELECT directo
EXECUTE AS USER = 'usr_app';
    INSERT INTO dbo.Empleados (Nombre, Puesto, Salario, NumeroTarjeta, CorreoElectronico, Region)
    VALUES ('Nuevo Empleado','Soporte',700000,'4999999999999999','nuevo@gathel.com','Norte'); -- sirve
    -- SELECT * FROM dbo.Empleados;  -- falla
REVERT;
GO

-- ============================================================
-- 7. DATA MASKING SOBRE CAMPOS SENSIBLES
-- ============================================================
ALTER TABLE dbo.Empleados
ALTER COLUMN NumeroTarjeta ADD MASKED WITH (FUNCTION = 'partial(0,"XXXX-XXXX-XXXX-",4)');

ALTER TABLE dbo.Empleados
ALTER COLUMN CorreoElectronico ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE dbo.Empleados
ALTER COLUMN Salario ADD MASKED WITH (FUNCTION = 'random(100000, 999999)');
GO

-- Dar SELECT a usr_sur (sin permiso UNMASK -> verá datos enmascarados)
EXECUTE AS USER = 'usr_sur';
    SELECT EmpleadoID, Nombre, NumeroTarjeta, CorreoElectronico, Salario
    FROM dbo.Empleados;   -- Datos enmascarados
REVERT;
GO

-- Otorgar permiso unmask a un usuario de prueba
GRANT UNMASK TO usr_norte;
GO

EXECUTE AS USER = 'usr_norte';
    SELECT EmpleadoID, Nombre, NumeroTarjeta, CorreoElectronico, Salario
    FROM dbo.Empleados;   -- Datos reales (sin máscara)
REVERT;
GO

-- ============================================================
-- 8. ROW-LEVEL SECURITY (RLS) BASADO EN USUARIO AUTENTICADO
-- ============================================================
CREATE SCHEMA Security;
GO

-- Función de predicado de seguridad, el usuario solo ve filas de su región
CREATE FUNCTION Security.fn_FiltroRegion(@UsuarioBD AS SYSNAME)
-- Devuelve un 1 si hay permiso, null si no
RETURNS TABLE
-- Para no poder alterar la estructura de tablas
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_result
-- USER_NAME() devuelve el nombre del usuario de quien ejecutó el código,
-- si el usuario coincide con @UsuarioBD, o es admin, permite
WHERE @UsuarioBD = USER_NAME()
   OR USER_NAME() = 'dbo'; -- el admin ve todo
GO

CREATE SECURITY POLICY Security.PoliticaRegion
-- Usa la función de arriba, entonces cuando alguien hace
-- una operación como select, update o delete,
-- se inserta el código de arriba, que hace que
-- se inserte un WHERE UsuarioBD = usuario, así cada usuario solo
-- puede consultar información que le pertenece
ADD FILTER PREDICATE Security.fn_FiltroRegion(UsuarioBD)
ON dbo.Empleados,
-- Si un usuario intenta hacer algo con un campo que no le
-- pertenece, lo bloquea
ADD BLOCK PREDICATE Security.fn_FiltroRegion(UsuarioBD)
ON dbo.Empleados AFTER INSERT
WITH (STATE = ON);
GO

-- Otorgar permiso SELECT y EXECUTE necesario para evaluar la política
GRANT SELECT ON dbo.Empleados TO usr_norte, usr_sur;
GRANT EXECUTE ON Security.fn_FiltroRegion TO usr_norte, usr_sur;
GO

-- PRUEBA: usr_norte solo ve filas con UsuarioBD = 'usr_norte'
EXECUTE AS USER = 'usr_norte';
    SELECT * FROM dbo.Empleados;
REVERT;
GO

-- PRUEBA: usr_sur solo ve filas con UsuarioBD = 'usr_sur'
EXECUTE AS USER = 'usr_sur';
    SELECT * FROM dbo.Empleados;
REVERT;
GO

-- ============================================================
-- 9: CIFRADO DE CONTRASEÑAS CON MASTER CERTIFICATE
-- ============================================================

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M@sterKey#2026!Secure';
GO

-- Crear certificado protegido por la Master Key
CREATE CERTIFICATE CertContraseñas
WITH SUBJECT = 'Certificado para cifrado de contraseñas - SecurityLabDB';
GO

-- Crear clave simétrica protegida por el certificado
CREATE SYMMETRIC KEY ClaveContraseñas
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertContraseñas;
GO

-- Tabla para almacenar contraseñas cifradas
CREATE TABLE dbo.Credenciales (
    CredencialID    INT IDENTITY(1,1) PRIMARY KEY,
    Usuario         VARCHAR(50) NOT NULL,
    ContraseñaEnc   VARBINARY(256) NOT NULL
);
GO

-- Insertar registro con contraseña cifrada
OPEN SYMMETRIC KEY ClaveContraseñas
DECRYPTION BY CERTIFICATE CertContraseñas;

INSERT INTO dbo.Credenciales (Usuario, ContraseñaEnc)
VALUES (
    'ana.perez',
    EncryptByKey(Key_GUID('ClaveContraseñas'), 'MiContraseñaSegura123')
);

CLOSE SYMMETRIC KEY ClaveContraseñas;
GO

-- Desencriptar para verificar
OPEN SYMMETRIC KEY ClaveContraseñas
DECRYPTION BY CERTIFICATE CertContraseñas;

SELECT
    Usuario,
    ContraseñaEnc AS ContraseñaCifrada,
    CONVERT(VARCHAR(100), DecryptByKey(ContraseñaEnc)) AS ContraseñaDescifrada
FROM dbo.Credenciales;

CLOSE SYMMETRIC KEY ClaveContraseñas;
GO


-- ============================================================
-- CONSULTAS DE VERIFICACIÓN / EVIDENCIA PARA DOCUMENTAR
-- ============================================================

-- Listar usuarios de la base de datos
SELECT name, type_desc, create_date FROM sys.database_principals WHERE type IN ('S','U');

-- Listar roles y sus miembros
SELECT
    r.name AS Rol,
    m.name AS Miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id;

-- Permisos directos vs heredados (ejecutar como cada usuario)

EXECUTE AS USER = 'usr_norte';
SELECT * FROM fn_my_permissions(N'dbo.Empleados', 'OBJECT');
REVERT;
GO

-- Verificar columnas enmascaradas
SELECT name, is_masked, masking_function FROM sys.masked_columns;

-- Verificar políticas de seguridad RLS
SELECT name, is_enabled FROM sys.security_policies;

-- Verificar certificados y claves simétricas
SELECT name, pvt_key_encryption_type_desc FROM sys.certificates;
SELECT name, algorithm_desc FROM sys.symmetric_keys;
