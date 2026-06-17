CREATE TABLE dbo.Cuentas (
    CuentaID INT PRIMARY KEY,
    Titular VARCHAR(50),
    Saldo DECIMAL(10,2)
);

INSERT INTO dbo.Cuentas VALUES (1,'Ana',1000), (2,'Luis',1000), (3,'María',1000);

CREATE TABLE dbo.LogTransacciones (
    LogID INT IDENTITY PRIMARY KEY,
    Mensaje VARCHAR(200),
    Fecha DATETIME DEFAULT GETDATE()
);
GO







-- SP 3, si este falla, todo se revierte, SP 1, 2 y 3.
CREATE PROCEDURE dbo.sp_Nivel3 @CuentaID INT, @Monto DECIMAL(10,2), @ForzarError BIT = 0
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION SP3;
		
		-- si no falla, pasa 100 de saldo de Ana a Luis
        UPDATE dbo.Cuentas SET Saldo = Saldo - @Monto WHERE CuentaID = @CuentaID;
        INSERT INTO dbo.LogTransacciones (Mensaje) VALUES ('SP3: débito aplicado');
		-- si falla, deshace todo, demostrado porque deja los logs vacíos, si no falla,
		-- quedan datos en logs
        IF @ForzarError = 1
            THROW 50000, 'Error forzado en SP3', 1;

        COMMIT TRANSACTION SP3;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION SP3;
        THROW;  -- manda el error a SP 2 que lo llamó
    END CATCH
END;
GO

-- SP 2 crea el log para demostrar, y llama a SP 3
CREATE PROCEDURE dbo.sp_Nivel2 @CuentaID INT, @Monto DECIMAL(10,2), @ForzarError BIT = 0
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION SP2;

        INSERT INTO dbo.LogTransacciones (Mensaje) VALUES ('SP2: operación pendiente registrada');

        EXEC dbo.sp_Nivel3 @CuentaID = @CuentaID, @Monto = @Monto, @ForzarError = @ForzarError;

        COMMIT TRANSACTION SP2;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION SP2;
        THROW;
    END CATCH
END;
GO

-- SP 1, inserta el log y llama a SP 2
CREATE PROCEDURE dbo.sp_Nivel1 @CuentaOrigen INT, @CuentaDestino INT, @Monto DECIMAL(10,2), @ForzarError BIT = 0
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION SP1;

        UPDATE dbo.Cuentas SET Saldo = Saldo + @Monto WHERE CuentaID = @CuentaDestino;
        INSERT INTO dbo.LogTransacciones (Mensaje) VALUES ('SP1: crédito a destino pendiente');

        EXEC dbo.sp_Nivel2 @CuentaID = @CuentaOrigen, @Monto = @Monto, @ForzarError = @ForzarError;

        COMMIT TRANSACTION SP1;
        PRINT 'TRANSACCIÓN COMPLETA: éxito';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION SP1;
        PRINT 'TRANSACCIÓN REVERTIDA: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-- Exitoso
SELECT * FROM dbo.Cuentas;
EXEC dbo.sp_Nivel1 @CuentaOrigen = 1, @CuentaDestino = 2, @Monto = 100, @ForzarError = 0;
SELECT * FROM dbo.Cuentas;          -- Los cambios persisten
SELECT * FROM dbo.LogTransacciones; -- 3 logs, de SP 1, 2 y 3
GO

-- Error
DELETE FROM dbo.LogTransacciones;
EXEC dbo.sp_Nivel1 @CuentaOrigen = 1, @CuentaDestino = 2, @Monto = 100, @ForzarError = 1;
SELECT * FROM dbo.Cuentas;          -- No hay cambios
SELECT * FROM dbo.LogTransacciones; -- 0 logs
GO
