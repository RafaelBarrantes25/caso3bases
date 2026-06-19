# SecurityLab
Se crea una tabla empleados y los usuarios usr_norte, usr_sur (empleados normales), usr_aud (auditoría) y usr_app (de aplicación).
Se le da permiso de lectura a todos menos usr_app, que tiene permisos de escritura.

- Caso 4: Se hacen varias pruebas, por ejemplo se le da permiso de lectura a usr_norte mediante rol y luego se le da permiso directo de update en la fila empleados de la tabla salario, entonces al revisar sus permisos se ve que tiene tanto permisos de rol como permisos directos.

- Caso 5: Se le da permiso a usr_app de ejecutar el stored procedure, pero no ded hacer select, entonces si hace select, da error, pero si ejecuta el stored procedure sí puede traer datos de la tabla.

- Caso 6: Se le da al usr_aud rol de lectura, et¿ntonces si hace select sí sirve pero si hace insert da error.
- rol escritura puede hacer insert pero no select.

- Caso 7: Data masking: Se hace un masking de los campos email, tarjeta y salario, entonces si alguien no tiene permiso de unmasking, ve datos basura.

Caso 8: Se crea una función para que cada usuario soo pueda ver campos de su rol.

Caso 9: Se cifran y descifran datos con master certificate.


Evidencias:

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
