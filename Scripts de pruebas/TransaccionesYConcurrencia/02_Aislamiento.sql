
CREATE TABLE dbo.Cuentas (
    CuentaID INT PRIMARY KEY,
    Titular VARCHAR(50),
    Saldo DECIMAL(10,2)
);

INSERT INTO dbo.Cuentas VALUES (1,'Ana',1000), (2,'Luis',1000), (3,'María',1000);


--------------------------------
--Dirty read
--------------------------------

-- Cambia el saldo del usuario 1 a 99 999 pero no hace commit
BEGIN TRANSACTION;
UPDATE dbo.Cuentas SET Saldo = 99999 WHERE CuentaID = 1;
WAITFOR DELAY '00:00:10';
ROLLBACK TRANSACTION; -- se revierte



-- ejecutar en pestaña aparte
-- Hace un dirty read porque lee los cambios que no han sido committed
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT Saldo FROM dbo.Cuentas WHERE CuentaID = 1;



---------------------------------
-- Non repeatable read
---------------------------------

-- valor inicial
UPDATE dbo.Cuentas SET Saldo = 1000 WHERE CuentaID = 1;



SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
	-- lee el valor inicial, 1000 en este caso
    SELECT Saldo FROM dbo.Cuentas WHERE CuentaID = 1;
    WAITFOR DELAY '00:00:08';
	-- se hace el update de abajo antes de que pasen 8 segundos
	-- este select lee el valor actualizado, 500
    SELECT Saldo FROM dbo.Cuentas WHERE CuentaID = 1;
COMMIT TRANSACTION;

-- se ejecuta en pestaña aparte
UPDATE dbo.Cuentas SET Saldo = 500 WHERE CuentaID = 1;


---------------------------------
-- Phantom read
---------------------------------


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
	-- Lee la tabla y muestra las que cumplan
    SELECT * FROM dbo.Cuentas WHERE Saldo < 2000;
    WAITFOR DELAY '00:00:08';
	-- se ejecuta el insert de abajo, esto hace que
	-- haya una nueva fila que cumpla la condición,
	-- entonces el segundo select muestra
	-- más valores
    SELECT * FROM dbo.Cuentas WHERE Saldo < 2000;
COMMIT TRANSACTION;

-- ejecutar en pestaña aparte
INSERT INTO dbo.Cuentas VALUES (4, 'Pedro', 100);


---------------------------------
-- Serializable protege de todo
---------------------------------


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    SELECT * FROM dbo.Cuentas WHERE Saldo < 2000;
	-- el insert de abajo no se ejecuta hasta que se ejecute este
    WAITFOR DELAY '00:00:08';
    SELECT * FROM dbo.Cuentas WHERE Saldo < 2000;
COMMIT TRANSACTION;


-- Ejecutar en pestaña aparte
INSERT INTO dbo.Cuentas VALUES (5, 'Sofía', 300);


