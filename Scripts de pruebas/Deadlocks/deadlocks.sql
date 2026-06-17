
CREATE TABLE dbo.Cuentas (
    CuentaID INT PRIMARY KEY,
    Titular VARCHAR(50),
    Saldo DECIMAL(10,2)
);

INSERT INTO dbo.Cuentas VALUES (1,'Ana',1000), (2,'Luis',1000), (3,'María',1000);



CREATE PROCEDURE dbo.sp_Deadlock_A
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Cuentas SET Saldo = Saldo - 50 WHERE CuentaID = 1;
        
        -- Modifica y bloquea saldo campo 1
        WAITFOR DELAY '00:00:07'; 
        -- Está bloqueado por el deadlock B
        UPDATE dbo.Cuentas SET Saldo = Saldo + 50 WHERE CuentaID = 2;
    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.sp_Deadlock_B
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 2;
        
        -- modifica y bloquea el saldo campo 2
        WAITFOR DELAY '00:00:07'; 
        -- está bloqueado por el deadblock A
        UPDATE dbo.Cuentas SET Saldo = Saldo - 20 WHERE CuentaID = 1;
    COMMIT TRANSACTION;
END;
GO

-- ejecutar ambos en ventanas separadas
EXEC dbo.sp_Deadlock_A;

EXEC dbo.sp_Deadlock_B;




---------------------------------------------------------------------------------------------
-- Deadlock de 3 transacciones
---------------------------------------------------------------------------------------------


CREATE PROCEDURE dbo.sp_T1
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 1;  
        -- bloquea fila 1
        WAITFOR DELAY '00:00:06';
  		-- espera fila 2 de t2
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 2;
    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.sp_T2
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 2;  
        -- bloquea fila 2
        WAITFOR DELAY '00:00:06';
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 3;  
        -- espera fila 3 de t3
    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.sp_T3
AS
BEGIN
    BEGIN TRANSACTION;
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 3;  
        -- bloquea fila 3
        WAITFOR DELAY '00:00:06';
        UPDATE dbo.Cuentas SET Saldo = Saldo - 10 WHERE CuentaID = 1;  
        -- espera fila 1 de t1
    COMMIT TRANSACTION;
END;
GO


-- ejecutar en ventanas separadas
EXEC dbo.sp_T1;
EXEC dbo.sp_T2;
EXEC dbo.sp_T3;

