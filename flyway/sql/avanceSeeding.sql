CREATE LOGIN AdministradorGathel WITH PASSWORD = 'contrasenaAdmin';
CREATE LOGIN GerenteGathel WITH PASSWORD = 'contrasenaGerente';

CREATE USER Admin1 FOR LOGIN AdministradorGathel;
CREATE USER Gerente1 FOR LOGIN GerenteGathel;




-- seeding:
-- limpiar para pruebas

/*
TRUNCATE TABLE dbo.transactions;
DELETE FROM dbo.paymentAttempts;

DELETE FROM dbo.predictions;
DELETE FROM dbo.propositionsPerEvent;
DELETE FROM dbo.events;
DELETE FROM dbo.propositions;
DELETE FROM dbo.wallets;
DELETE FROM dbo.users;
*/

USE GATHEL
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roleType)
BEGIN
	INSERT INTO dbo.roleType (code) VALUES ('Admin'), ('Player'), ('Business');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.countries)
BEGIN
-- podemos añadir más si es necesario pero para pruebas por ahora con 2  está bien
    INSERT INTO dbo.countries (name) VALUES ('Costa Rica'), ('Estados Unidos');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.states)
BEGIN
    INSERT INTO dbo.states (countryId, name) VALUES 
    (1, 'Cartago'), (1, 'San José'), (1, 'Alajuela'),
    (2, 'California'), (2, 'Texas')
END;

IF NOT EXISTS (SELECT 1 FROM dbo.currencies)
BEGIN
    INSERT INTO dbo.currencies (name, symbol, enabled, countryId) VALUES 
    ('Colón', '₡', 1, 1),
    ('Dólar', '$', 1, 2);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus)
BEGIN
    INSERT INTO dbo.eventStatus (status) VALUES ('Draft'), ('Active'), ('Completed'), ('Cancelled');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus)
BEGIN
    INSERT INTO dbo.propositionStatus (status) VALUES ('Proposed'), ('Accepted'), ('Rejected'), ('Resolved');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes)
BEGIN
    INSERT INTO dbo.paymentTypes (code, enabled) VALUES ('CARD', 1), ('SINPE', 1), ('WALLET', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes)
BEGIN
    INSERT INTO dbo.operationTypes (code, description, enabled) VALUES ('DEPOSIT', 'Ingreso', 1), ('WITHDRAWAL', 'Retiro', 1), ('BET_PLACE', 'Apuesta', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses)
BEGIN
    INSERT INTO dbo.paymentStatuses (code, description) VALUES ('PENDING', 'Pendiente'), ('APPROVED', 'Aprobado'), ('REJECTED', 'Rechazado');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.settings)
BEGIN
    INSERT INTO dbo.settings (pointsPerEvent, initialPlayerPoints, rejectPenaltyPercentage, unverifiablePenaltyPercentage, proposerEarningsPercentage, platformEarningsPercentage, successfulPredictionPercentage, updatedBy, updatedAt)
    -- lo de successful prediction lo puse así por  mientras pero no estoy seguro
    VALUES (1, 100, 15, 15, 10, 5, 70, NULL, SYSUTCDATETIME());
END;
GO

---------------------------------------------------------------------------------------------------------
------------SEEDING DE USUARIOS
---------------------------------------------------------------------------------------------------------

DECLARE @UserCount INT = 0;
DECLARE @TargetUsers INT = 1000;
DECLARE @PlayerRoleId INT = (SELECT id FROM dbo.roleType WHERE code = 'PLAYER');
DECLARE @DefaultStateId INT = (SELECT TOP 1 id FROM dbo.states);
DECLARE @DefaultCurrencyId INT = (SELECT TOP 1 id FROM dbo.currencies);


WHILE @UserCount < @TargetUsers
BEGIN
    SET @UserCount = @UserCount + 1;

    -- para que sea User1, User2 y así
    DECLARE @Username VARCHAR(30) = 'player' + CAST(@UserCount AS VARCHAR(10));
    DECLARE @Email VARCHAR(254) = 'player' + CAST(@UserCount AS VARCHAR(10)) + '@gathel.com';
    DECLARE @Name VARCHAR(20) = 'User' + CAST(@UserCount AS VARCHAR(10));
    DECLARE @LastName VARCHAR(20) = 'LastName' + CAST(@UserCount AS VARCHAR(10));


    INSERT INTO dbo.users (name, lastName, username, email, password, enabled, roleTypeId, addressId, createdAt)
    VALUES (
        @Name, 
        @LastName, 
        @Username, 
        @Email, 
        CAST('PasswordHashPlaceholder' AS VARBINARY(MAX)), 
        1, 
        @PlayerRoleId, 
        NULL,
        -- para que aparezcan creados en fechas aleatorias en los últimos 120 días
        -- el newid genera el aleatorio, checksum lo hace int, abs para absoluto
        -- se toma la fecha actual y se le resta el valor random
        DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 120), SYSUTCDATETIME()) 
    );






    DECLARE @NewUserId INT = SCOPE_IDENTITY();

    -- Cada jugador necesita obligatoriamente una Wallet activa
    INSERT INTO dbo.wallets (userId, currencyId, pointsBalance, moneyBalance, enabled, createdAt)
    VALUES (@NewUserId, @DefaultCurrencyId, 1000.00, 50.00, 1, SYSUTCDATETIME());
END;
GO



---------------------------------------------------------------------------------------------------------
------------SEEDING DE EVENTOS
---------------------------------------------------------------------------------------------------------

DECLARE @EventCount INT = 0;
DECLARE @TargetEvents INT = 5000;

---------------------------------------------------IMPORTANTE--------------------------------------------
-- ESTO por mientras está que sea el usuario 1 el creador de los eventos para hacer unas pruebas,
-- hay que modificarlo después
DECLARE @CreatorId INT = (SELECT TOP 1 id FROM dbo.users WHERE username = 'player1');
DECLARE @ActiveStatusId INT = (SELECT id FROM dbo.eventStatus WHERE status = 'Active');

WHILE @EventCount < @TargetEvents
BEGIN
    SET @EventCount = @EventCount + 1;

    -- igual que con usuarios, para que se genere llamandose evento 1 2 3 y así,
    -- y que la fecha de creación sea aleatoria en el último mes
    DECLARE @EventName VARCHAR(50) = 'Evento #' + CAST(@EventCount AS VARCHAR(10));
    DECLARE @CreationDate DATETIME2 = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), SYSUTCDATETIME());

    INSERT INTO dbo.events (
        eventName, 
        creatorUser, 
        eventStatus, 
        description, 
        createdAt
    )
    VALUES (
        @EventName,
        @CreatorId,
        @ActiveStatusId,
        'Descripción',
        @CreationDate
    );
END;

GO




---------------------------------------------------------------------------------------------------------
------------Inserción de eventos
---------------------------------------------------------------------------------------------------------
DECLARE @PropCount INT = 0;
DECLARE @TargetProps INT = 5000;

DECLARE @StatusProposed INT = (SELECT id FROM dbo.propositionStatus WHERE status = 'Proposed');
DECLARE @CurrencyId INT = (SELECT TOP 1 id FROM dbo.currencies);
DECLARE @PaymentTypeId INT = (SELECT id FROM dbo.paymentTypes WHERE code = 'WALLET');
DECLARE @OpTypeId INT = (SELECT id FROM dbo.operationTypes WHERE code = 'BET_PLACE');
DECLARE @StatusApproved INT = (SELECT id FROM dbo.paymentStatuses WHERE code = 'APPROVED');

-- Tabla temporal para mapear IDs de eventos disponibles secuencialmente
SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS RowNum 
INTO #TmpEvents 
FROM dbo.events;

DECLARE @MaxEvents INT = (SELECT COUNT(*) FROM #TmpEvents);

WHILE @PropCount < @TargetProps
BEGIN
    SET @PropCount = @PropCount + 1;

    -- Seleccionar dos jugadores distintos aleatoriamente
    DECLARE @PlayerA INT, @PlayerB INT;
    
    SELECT TOP 1 @PlayerA = id FROM dbo.users ORDER BY NEWID();
    SELECT TOP 1 @PlayerB = id FROM dbo.users WHERE id <> @PlayerA ORDER BY NEWID();

    DECLARE @WalletA BIGINT = (SELECT id FROM dbo.wallets WHERE userId = @PlayerA);
    DECLARE @WalletB BIGINT = (SELECT id FROM dbo.wallets WHERE userId = @PlayerB);

    DECLARE @Amount DECIMAL(18,2) = CAST((ABS(CHECKSUM(NEWID())) % 45 + 5) AS DECIMAL(18,2)); -- Montos entre 5 y 50
    DECLARE @CreationDate DATETIME2 = DATEADD(MINUTE, -ABS(CHECKSUM(NEWID()) % 1440), SYSUTCDATETIME());

    /* A. INSERTAR PROPOSICIÓN */
    INSERT INTO dbo.propositions (
        title, description, numberOfVotes, proposedBy, proposedTo, 
        propositionStatusId, currencyId, createdAt, enabled
    )
    VALUES (
        'Proposición #' + CAST(@PropCount AS VARCHAR(10)),
        'Descripción',
        0, @PlayerA, @PlayerB, @StatusProposed, @CurrencyId, @CreationDate, 1
    );

    DECLARE @NewPropId BIGINT = SCOPE_IDENTITY();


    -- Se toma la ID, que va subiendo de 1 en 1 y se multiplica por 5,
    -- Max events - 60 es para que el número siempre quede en el rango de eventos
    -- existentes
    INSERT INTO dbo.propositionsPerEvent (eventId, propositionId)
    SELECT id, @NewPropId
    FROM #TmpEvents
    WHERE RowNum BETWEEN ((@PropCount * 5) % (@MaxEvents - 60)) AND (((@PropCount * 5) % (@MaxEvents - 60)) + 49);


    
 

    VALUES (
        NULL, 1, 'INITIAL_CHECK', @StatusApproved, 'Fondos de Wallet validados correctamente.', @CreationDate, @PlayerA
    );

    INSERT INTO dbo.paymentAttempts (
        paymentMethodId, paymentCardId, paymentTypeId, operationTypeId, 
        paymentStatusId, userId, sourceWalletId, destinationWalletId, currencyId, 
        amount, referenceObjectType, referenceObjectId, createdAt, postTime, internal
    )
    VALUES (
        1, NULL, @PaymentTypeId, @OpTypeId, @StatusApproved, 
        @PlayerA, @WalletA, @WalletB, @CurrencyId, @Amount, 
        'PROPOSITION', @NewPropId, @CreationDate, @CreationDate, 1
    );

    DECLARE @NewPaymentAttemptId BIGINT = SCOPE_IDENTITY();


    -- Balance simulado pre y post
    DECLARE @BalBefore DECIMAL(18,2) = 100.00; 
    
    INSERT INTO dbo.transactions (
        typeId, walletId, paymentAttemptId, date, description, amount, 
        currencyId, referenceType, referenceId, balanceAfterPoints, 
        balanceAfterMoney, balanceBeforePoints, balanceBeforeMoney, createdAt
    )
    VALUES (
        1, @WalletA, @NewPaymentAttemptId, @CreationDate, 
        'Débito automático por creación de Proposición #' + CAST(@NewPropId AS VARCHAR(10)), 
        @Amount, @CurrencyId, 'PROPOSITION', @NewPropId, 
        @BalBefore - @Amount, 0, @BalBefore, 0, @CreationDate
    );

END;

DROP TABLE #TmpEvents;
GO

