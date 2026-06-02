/*
    Gathel - 03_baseDeInformacion.sql
    Database engine: SQL Server
    Database name: Gathel

    Lo que crea es tras los catalogos informacion base necesaria. Asi que se ejecuta tras el 02_insertarCatalogos.sql.
    Solo crea paises, estados, direcciones, usuario admin, metodos de pago, currencies, settings, wallets y demas. 
*/

USE Gathel;
GO

DECLARE @adminRoleId INT;
DECLARE @playerRoleId INT;
DECLARE @countryCostaRicaId INT;
DECLARE @stateSanJoseId INT;
DECLARE @addressId INT;
DECLARE @adminUserId INT;
DECLARE @playerUserId INT;
DECLARE @crcCurrencyId INT;
DECLARE @usdCurrencyId INT;
DECLARE @paymentTypeCardId INT;
DECLARE @paymentTypeSinpeId INT;
DECLARE @paymentTypeInternalId INT;
DECLARE @sourceCardProcessorId INT;
DECLARE @sourceSinpeId INT;
DECLARE @sourceInternalId INT;

/* =========================================================
   COUNTRIES AND STATES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.countries WHERE name = 'Costa Rica')
    INSERT INTO dbo.countries(name) VALUES ('Costa Rica');

IF NOT EXISTS (SELECT 1 FROM dbo.countries WHERE name = 'United States')
    INSERT INTO dbo.countries(name) VALUES ('United States');

SELECT @countryCostaRicaId = id
FROM dbo.countries
WHERE name = 'Costa Rica';

IF NOT EXISTS (SELECT 1 FROM dbo.states WHERE name = 'San Jose' AND countryId = @countryCostaRicaId)
    INSERT INTO dbo.states(countryId, name) VALUES (@countryCostaRicaId, 'San Jose');

SELECT @stateSanJoseId = id
FROM dbo.states
WHERE name = 'San Jose' AND countryId = @countryCostaRicaId;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.addresses
    WHERE stateId = @stateSanJoseId
      AND addressLine1 = 'Gathel Main Office'
)
BEGIN
    INSERT INTO dbo.addresses(stateId, addressLine1, addressLine2, zipCode, enabled)
    VALUES (@stateSanJoseId, 'Gathel Main Office', 'Initial address', '10101', 1);
END;

SELECT @addressId = id
FROM dbo.addresses
WHERE stateId = @stateSanJoseId
  AND addressLine1 = 'Gathel Main Office';

/* =========================================================
   USERS
   ========================================================= */

SELECT @adminRoleId = id FROM dbo.roleType WHERE code = 'ADMIN';
SELECT @playerRoleId = id FROM dbo.roleType WHERE code = 'PLAYER';

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = 'admin@gathel.local')
BEGIN
    INSERT INTO dbo.users(
        name,
        lastName,
        username,
        email,
        password,
        enabled,
        roleTypeId,
        addressId
    )
    VALUES (
        'Admin',
        'Gathel',
        'admin',
        'admin@gathel.local',
        HASHBYTES('SHA2_256', 'Admin123*'),
        1,
        @adminRoleId,
        @addressId
    );
END;

SELECT @adminUserId = id
FROM dbo.users
WHERE email = 'admin@gathel.local';

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = 'player1@gathel.local')
BEGIN
    INSERT INTO dbo.users(
        name,
        lastName,
        username,
        email,
        password,
        enabled,
        roleTypeId,
        createdBy,
        addressId
    )
    VALUES (
        'Player',
        'One',
        'player1',
        'player1@gathel.local',
        HASHBYTES('SHA2_256', 'Player123*'),
        1,
        @playerRoleId,
        @adminUserId,
        @addressId
    );
END;

SELECT @playerUserId = id
FROM dbo.users
WHERE email = 'player1@gathel.local';

/* =========================================================
   CURRENCIES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.currencies WHERE name = 'Colon')
BEGIN
    INSERT INTO dbo.currencies(name, symbol, enabled, userId, countryId)
    VALUES ('Colon', 'CRC', 1, @adminUserId, @countryCostaRicaId);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.currencies WHERE name = 'Dollar')
BEGIN
    INSERT INTO dbo.currencies(name, symbol, enabled, userId, countryId)
    VALUES ('Dollar', 'USD', 1, @adminUserId, @countryCostaRicaId);
END;

SELECT @crcCurrencyId = id FROM dbo.currencies WHERE name = 'Colon';
SELECT @usdCurrencyId = id FROM dbo.currencies WHERE name = 'Dollar';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.exchangeRates
    WHERE fromCurrencyId = @usdCurrencyId
      AND toCurrencyId = @crcCurrencyId
      AND isCurrent = 1
)
BEGIN
    INSERT INTO dbo.exchangeRates(
        fromCurrencyId,
        toCurrencyId,
        rate,
        date,
        userId,
        isCurrent
    )
    VALUES (
        @usdCurrencyId,
        @crcCurrencyId,
        520.00000000,
        CAST(GETDATE() AS DATE),
        @adminUserId,
        1
    );
END;

/* =========================================================
   WALLETS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.wallets WHERE userId = @adminUserId AND currencyId = @crcCurrencyId)
BEGIN
    INSERT INTO dbo.wallets(userId, currencyId, pointsBalance, moneyBalance, enabled)
    VALUES (@adminUserId, @crcCurrencyId, 100, 0, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.wallets WHERE userId = @playerUserId AND currencyId = @crcCurrencyId)
BEGIN
    INSERT INTO dbo.wallets(userId, currencyId, pointsBalance, moneyBalance, enabled)
    VALUES (@playerUserId, @crcCurrencyId, 100, 0, 1);
END;

/* =========================================================
   SETTINGS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.settings WHERE enabled = 1)
BEGIN
    INSERT INTO dbo.settings(
        pointsPerEvent,
        initialPlayerPoints,
        rejectPenaltyPercentage,
        unverifiablePenaltyPercentage,
        proposerEarningsPercentage,
        platformEarningsPercentage,
        enabled,
        updatedBy,
        successfulPredictionPercentage
    )
    VALUES (
        1,
        100,
        1,
        15,
        5,
        5,
        1,
        @adminUserId,
        80
    );
END;

/* =========================================================
   PAYMENT METHODS
   ========================================================= */

SELECT @paymentTypeCardId = id FROM dbo.paymentTypes WHERE code = 'CARD';
SELECT @paymentTypeSinpeId = id FROM dbo.paymentTypes WHERE code = 'SINPE';
SELECT @paymentTypeInternalId = id FROM dbo.paymentTypes WHERE code = 'INTERNAL';

SELECT @sourceCardProcessorId = id FROM dbo.paymentSourceAPI WHERE code = 'CARD_PROCESSOR';
SELECT @sourceSinpeId = id FROM dbo.paymentSourceAPI WHERE code = 'SINPE_API';
SELECT @sourceInternalId = id FROM dbo.paymentSourceAPI WHERE code = 'INTERNAL';

IF NOT EXISTS (SELECT 1 FROM dbo.paymentMethods WHERE source = 'CARD_PROCESSOR')
BEGIN
    INSERT INTO dbo.paymentMethods(
        paymentTypeId,
        paymentSourceAPIId,
        source,
        apiUrl,
        configurationJson,
        enabled,
        userId,
        countryId
    )
    VALUES (
        @paymentTypeCardId,
        @sourceCardProcessorId,
        'CARD_PROCESSOR',
        'https://sandbox.card-processor.local/api/payments',
        N'{"environment":"sandbox","provider":"CARD_PROCESSOR"}',
        1,
        @adminUserId,
        NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.paymentMethods WHERE source = 'SINPE_API')
BEGIN
    INSERT INTO dbo.paymentMethods(
        paymentTypeId,
        paymentSourceAPIId,
        source,
        apiUrl,
        configurationJson,
        enabled,
        userId,
        countryId
    )
    VALUES (
        @paymentTypeSinpeId,
        @sourceSinpeId,
        'SINPE_API',
        'https://sandbox.sinpe.local/api/payments',
        N'{"environment":"sandbox","country":"Costa Rica"}',
        1,
        @adminUserId,
        @countryCostaRicaId
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.paymentMethods WHERE source = 'INTERNAL')
BEGIN
    INSERT INTO dbo.paymentMethods(
        paymentTypeId,
        paymentSourceAPIId,
        source,
        apiUrl,
        configurationJson,
        enabled,
        userId,
        countryId
    )
    VALUES (
        @paymentTypeInternalId,
        @sourceInternalId,
        'INTERNAL',
        NULL,
        N'{"environment":"internal"}',
        1,
        @adminUserId,
        @countryCostaRicaId
    );
END;

/* =========================================================
   PAYMENT CARD SAMPLE
   ========================================================= */

DECLARE @visaTypeId INT;

SELECT @visaTypeId = id
FROM dbo.paymentCardType
WHERE code = 'VISA';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.paymentCards
    WHERE userId = @playerUserId
      AND lastFourDigits = '1234'
)
BEGIN
    INSERT INTO dbo.paymentCards(
        userId,
        cardHolderName,
        paymentCardTypeId,
        lastFourDigits,
        expirationMonth,
        expirationYear,
        tokenizedCard,
        billingCountryId,
        enabled
    )
    VALUES (
        @playerUserId,
        'Player One',
        @visaTypeId,
        '1234',
        12,
        2030,
        HASHBYTES('SHA2_256', 'tokenized-card-player-one-1234'),
        @countryCostaRicaId,
        1
    );
END;

/* =========================================================
   BUSINESS AND REDEEMABLE PRODUCT SAMPLE
   ========================================================= */

DECLARE @businessId INT;
DECLARE @unitMeasurementId INT;
DECLARE @quantityTypeId INT;
DECLARE @productId INT;

SELECT @unitMeasurementId = id FROM dbo.unitMeasurement WHERE code = 'UNIT';
SELECT @quantityTypeId = id FROM dbo.quantityType WHERE code = 'UNIT';

IF NOT EXISTS (SELECT 1 FROM dbo.business WHERE businessName = 'Gathel Store')
BEGIN
    INSERT INTO dbo.business(
        businessName,
        countryId,
        contactEmail,
        contactPhone,
        enabled,
        createdBy
    )
    VALUES (
        'Gathel Store',
        @countryCostaRicaId,
        'store@gathel.local',
        '8888-8888',
        1,
        @adminUserId
    );
END;

SELECT @businessId = id
FROM dbo.business
WHERE businessName = 'Gathel Store';

IF NOT EXISTS (SELECT 1 FROM dbo.redeemableProducts WHERE productName = 'Gathel Gift Card')
BEGIN
    INSERT INTO dbo.redeemableProducts(
        businessId,
        productName,
        description,
        stock,
        unitMeasurementId,
        quantityTypeId,
        createdBy,
        enabled,
        currencyId,
        amount
    )
    VALUES (
        @businessId,
        'Gathel Gift Card',
        'Producto inicial canjeable por puntos',
        100,
        @unitMeasurementId,
        @quantityTypeId,
        @adminUserId,
        1,
        @crcCurrencyId,
        2500
    );
END;

SELECT @productId = id
FROM dbo.redeemableProducts
WHERE productName = 'Gathel Gift Card';

DECLARE @colorCharacteristicId INT;

SELECT @colorCharacteristicId = id
FROM dbo.productCharacteristics
WHERE name = 'Color';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.productCharacteristicPerProduct
    WHERE redeemableProductId = @productId
      AND productCharacteristicId = @colorCharacteristicId
)
BEGIN
    INSERT INTO dbo.productCharacteristicPerProduct(
        redeemableProductId,
        productCharacteristicId,
        value
    )
    VALUES (
        @productId,
        @colorCharacteristicId,
        'Digital'
    );
END;
GO