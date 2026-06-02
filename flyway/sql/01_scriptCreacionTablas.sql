/*
    Gathel - V1__create_schema.sql
    Database engine: SQL Server
    Database name: Gathel

    Generated from the provided Markdown specification.

    Notes:
    - SQL Server BOOLEAN was converted to BIT.
    - SQL Server TIMESTAMP was not used as datetime because it means ROWVERSION.
      Date/time fields were converted to DATETIME2.
    - BYTEA was converted to VARBINARY(32) or VARBINARY(MAX), depending on the field.
    - JSON was stored as NVARCHAR(MAX).
    - Circular dependencies between audits and paymentAttempts are solved by creating
      the audit table first and adding the FK from audits to paymentAttempts at the end.
*/

IF DB_ID(N'Gathel') IS NULL
BEGIN
    CREATE DATABASE Gathel;
END;
GO

USE Gathel;
GO

/* =========================================================
   DROP TABLES IN REVERSE DEPENDENCY ORDER
   Useful for development. Comment this section for production.
   ========================================================= */

IF OBJECT_ID('dbo.predictions', 'U') IS NOT NULL DROP TABLE dbo.predictions;
IF OBJECT_ID('dbo.propositionResult', 'U') IS NOT NULL DROP TABLE dbo.propositionResult;
IF OBJECT_ID('dbo.propositionVotes', 'U') IS NOT NULL DROP TABLE dbo.propositionVotes;
IF OBJECT_ID('dbo.propositionsPerEvent', 'U') IS NOT NULL DROP TABLE dbo.propositionsPerEvent;
IF OBJECT_ID('dbo.propositions', 'U') IS NOT NULL DROP TABLE dbo.propositions;
IF OBJECT_ID('dbo.propositionStatus', 'U') IS NOT NULL DROP TABLE dbo.propositionStatus;
IF OBJECT_ID('dbo.events', 'U') IS NOT NULL DROP TABLE dbo.events;
IF OBJECT_ID('dbo.eventStatus', 'U') IS NOT NULL DROP TABLE dbo.eventStatus;
IF OBJECT_ID('dbo.resultType', 'U') IS NOT NULL DROP TABLE dbo.resultType;
IF OBJECT_ID('dbo.predictionTypes', 'U') IS NOT NULL DROP TABLE dbo.predictionTypes;

IF OBJECT_ID('dbo.productCharacteristicPerProduct', 'U') IS NOT NULL DROP TABLE dbo.productCharacteristicPerProduct;
IF OBJECT_ID('dbo.productRedemption', 'U') IS NOT NULL DROP TABLE dbo.productRedemption;
IF OBJECT_ID('dbo.redemptionStatus', 'U') IS NOT NULL DROP TABLE dbo.redemptionStatus;
IF OBJECT_ID('dbo.redeemableProducts', 'U') IS NOT NULL DROP TABLE dbo.redeemableProducts;
IF OBJECT_ID('dbo.productCharacteristics', 'U') IS NOT NULL DROP TABLE dbo.productCharacteristics;
IF OBJECT_ID('dbo.unitMeasurement', 'U') IS NOT NULL DROP TABLE dbo.unitMeasurement;
IF OBJECT_ID('dbo.quantityType', 'U') IS NOT NULL DROP TABLE dbo.quantityType;
IF OBJECT_ID('dbo.business', 'U') IS NOT NULL DROP TABLE dbo.business;

IF OBJECT_ID('dbo.transactions', 'U') IS NOT NULL DROP TABLE dbo.transactions;
IF OBJECT_ID('dbo.transactionTypes', 'U') IS NOT NULL DROP TABLE dbo.transactionTypes;
IF OBJECT_ID('dbo.paymentValidations', 'U') IS NOT NULL DROP TABLE dbo.paymentValidations;
IF OBJECT_ID('dbo.paymentValidationStatus', 'U') IS NOT NULL DROP TABLE dbo.paymentValidationStatus;
IF OBJECT_ID('dbo.paymentValidationTypes', 'U') IS NOT NULL DROP TABLE dbo.paymentValidationTypes;
IF OBJECT_ID('dbo.paymentAttempts', 'U') IS NOT NULL DROP TABLE dbo.paymentAttempts;
IF OBJECT_ID('dbo.paymentCardsPerUser', 'U') IS NOT NULL DROP TABLE dbo.paymentCardsPerUser;
IF OBJECT_ID('dbo.paymentCards', 'U') IS NOT NULL DROP TABLE dbo.paymentCards;
IF OBJECT_ID('dbo.paymentCardType', 'U') IS NOT NULL DROP TABLE dbo.paymentCardType;
IF OBJECT_ID('dbo.paymentMethods', 'U') IS NOT NULL DROP TABLE dbo.paymentMethods;
IF OBJECT_ID('dbo.paymentSourceAPI', 'U') IS NOT NULL DROP TABLE dbo.paymentSourceAPI;
IF OBJECT_ID('dbo.paymentStatuses', 'U') IS NOT NULL DROP TABLE dbo.paymentStatuses;
IF OBJECT_ID('dbo.operationTypes', 'U') IS NOT NULL DROP TABLE dbo.operationTypes;
IF OBJECT_ID('dbo.paymentTypes', 'U') IS NOT NULL DROP TABLE dbo.paymentTypes;
IF OBJECT_ID('dbo.audits', 'U') IS NOT NULL DROP TABLE dbo.audits;
IF OBJECT_ID('dbo.auditType', 'U') IS NOT NULL DROP TABLE dbo.auditType;
IF OBJECT_ID('dbo.wallets', 'U') IS NOT NULL DROP TABLE dbo.wallets;

IF OBJECT_ID('dbo.settings', 'U') IS NOT NULL DROP TABLE dbo.settings;
IF OBJECT_ID('dbo.aiProcesses', 'U') IS NOT NULL DROP TABLE dbo.aiProcesses;
IF OBJECT_ID('dbo.processType', 'U') IS NOT NULL DROP TABLE dbo.processType;
IF OBJECT_ID('dbo.aiStatus', 'U') IS NOT NULL DROP TABLE dbo.aiStatus;
IF OBJECT_ID('dbo.socialMediaPerUser', 'U') IS NOT NULL DROP TABLE dbo.socialMediaPerUser;
IF OBJECT_ID('dbo.socialMedia', 'U') IS NOT NULL DROP TABLE dbo.socialMedia;

IF OBJECT_ID('dbo.logs', 'U') IS NOT NULL DROP TABLE dbo.logs;
IF OBJECT_ID('dbo.dataObjects', 'U') IS NOT NULL DROP TABLE dbo.dataObjects;
IF OBJECT_ID('dbo.sources', 'U') IS NOT NULL DROP TABLE dbo.sources;
IF OBJECT_ID('dbo.severities', 'U') IS NOT NULL DROP TABLE dbo.severities;
IF OBJECT_ID('dbo.eventTypes', 'U') IS NOT NULL DROP TABLE dbo.eventTypes;
IF OBJECT_ID('dbo.logTypes', 'U') IS NOT NULL DROP TABLE dbo.logTypes;

IF OBJECT_ID('dbo.taxes', 'U') IS NOT NULL DROP TABLE dbo.taxes;
IF OBJECT_ID('dbo.countryTaxes', 'U') IS NOT NULL DROP TABLE dbo.countryTaxes;
IF OBJECT_ID('dbo.taxTypes', 'U') IS NOT NULL DROP TABLE dbo.taxTypes;
IF OBJECT_ID('dbo.exchangeHistory', 'U') IS NOT NULL DROP TABLE dbo.exchangeHistory;
IF OBJECT_ID('dbo.exchangeRates', 'U') IS NOT NULL DROP TABLE dbo.exchangeRates;
IF OBJECT_ID('dbo.currencies', 'U') IS NOT NULL DROP TABLE dbo.currencies;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
IF OBJECT_ID('dbo.roleType', 'U') IS NOT NULL DROP TABLE dbo.roleType;
IF OBJECT_ID('dbo.addresses', 'U') IS NOT NULL DROP TABLE dbo.addresses;
IF OBJECT_ID('dbo.states', 'U') IS NOT NULL DROP TABLE dbo.states;
IF OBJECT_ID('dbo.countries', 'U') IS NOT NULL DROP TABLE dbo.countries;
GO

/* =========================================================
   ADDRESS PATTERN
   ========================================================= */

CREATE TABLE dbo.countries (
    id INT IDENTITY(1,1) NOT NULL,
    name VARCHAR(60) NOT NULL,
    CONSTRAINT PK_countries PRIMARY KEY (id)
);
GO

CREATE TABLE dbo.states (
    id INT IDENTITY(1,1) NOT NULL,
    countryId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT PK_states PRIMARY KEY (id),
    CONSTRAINT FK_states_countries FOREIGN KEY (countryId) REFERENCES dbo.countries(id)
);
GO

CREATE TABLE dbo.addresses (
    id INT IDENTITY(1,1) NOT NULL,
    stateId INT NOT NULL,
    addressLine1 VARCHAR(120) NOT NULL,
    addressLine2 VARCHAR(120) NULL,
    zipCode VARCHAR(20) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_addresses_enabled DEFAULT (1),
    CONSTRAINT PK_addresses PRIMARY KEY (id),
    CONSTRAINT FK_addresses_states FOREIGN KEY (stateId) REFERENCES dbo.states(id)
);
GO

/* =========================================================
   USERS AND SECURITY
   ========================================================= */

CREATE TABLE dbo.roleType (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    CONSTRAINT PK_roleType PRIMARY KEY (id),
    CONSTRAINT UQ_roleType_code UNIQUE (code)
);
GO

CREATE TABLE dbo.users (
    id INT IDENTITY(1,1) NOT NULL,
    name VARCHAR(20) NOT NULL,
    lastName VARCHAR(20) NOT NULL,
    username VARCHAR(30) NOT NULL,
    email VARCHAR(254) NOT NULL,
    password VARBINARY(MAX) NOT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_users_enabled DEFAULT (1),
    checksum VARBINARY(32) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_users_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2 NULL,
    lastLogin DATETIME2 NULL,
    roleTypeId INT NOT NULL,
    createdBy INT NULL,
    updatedBy INT NULL,
    addressId INT NULL,
    CONSTRAINT PK_users PRIMARY KEY (id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT FK_users_roleType FOREIGN KEY (roleTypeId) REFERENCES dbo.roleType(id),
    CONSTRAINT FK_users_createdBy FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_users_updatedBy FOREIGN KEY (updatedBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_users_addresses FOREIGN KEY (addressId) REFERENCES dbo.addresses(id)
);
GO

/* =========================================================
   LOGS
   ========================================================= */

CREATE TABLE dbo.logTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_logTypes PRIMARY KEY (id),
    CONSTRAINT UQ_logTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.eventTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_eventTypes PRIMARY KEY (id),
    CONSTRAINT UQ_eventTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.severities (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    level VARCHAR(10) NOT NULL,
    CONSTRAINT PK_severities PRIMARY KEY (id),
    CONSTRAINT UQ_severities_code UNIQUE (code)
);
GO

CREATE TABLE dbo.sources (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_sources PRIMARY KEY (id),
    CONSTRAINT UQ_sources_code UNIQUE (code)
);
GO

CREATE TABLE dbo.dataObjects (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_dataObjects PRIMARY KEY (id),
    CONSTRAINT UQ_dataObjects_code UNIQUE (code)
);
GO

CREATE TABLE dbo.logs (
    id BIGINT IDENTITY(1,1) NOT NULL,
    logTypeId INT NOT NULL,
    eventTypeId INT NOT NULL,
    severityId INT NOT NULL,
    sourceId INT NOT NULL,
    dataObjectId INT NOT NULL,
    description VARCHAR(100) NOT NULL,
    objectId1 BIGINT NULL,
    objectId2 BIGINT NULL,
    referenceId1 BIGINT NULL,
    referenceId2 BIGINT NULL,
    referenceDescription VARCHAR(100) NULL,
    userId INT NULL,
    computer VARBINARY(32) NULL,
    checksum VARBINARY(32) NULL,
    postTime DATETIME2 NOT NULL CONSTRAINT DF_logs_postTime DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_logs PRIMARY KEY (id),
    CONSTRAINT FK_logs_logTypes FOREIGN KEY (logTypeId) REFERENCES dbo.logTypes(id),
    CONSTRAINT FK_logs_eventTypes FOREIGN KEY (eventTypeId) REFERENCES dbo.eventTypes(id),
    CONSTRAINT FK_logs_severities FOREIGN KEY (severityId) REFERENCES dbo.severities(id),
    CONSTRAINT FK_logs_sources FOREIGN KEY (sourceId) REFERENCES dbo.sources(id),
    CONSTRAINT FK_logs_dataObjects FOREIGN KEY (dataObjectId) REFERENCES dbo.dataObjects(id),
    CONSTRAINT FK_logs_users FOREIGN KEY (userId) REFERENCES dbo.users(id)
);
GO

/* =========================================================
   CURRENCIES PATTERN
   ========================================================= */

CREATE TABLE dbo.currencies (
    id INT IDENTITY(1,1) NOT NULL,
    name VARCHAR(20) NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_currencies_enabled DEFAULT (1),
    postTime DATETIME2 NOT NULL CONSTRAINT DF_currencies_postTime DEFAULT (SYSUTCDATETIME()),
    userId INT NULL,
    countryId INT NOT NULL,
    CONSTRAINT PK_currencies PRIMARY KEY (id),
    CONSTRAINT FK_currencies_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_currencies_countries FOREIGN KEY (countryId) REFERENCES dbo.countries(id)
);
GO

CREATE TABLE dbo.exchangeRates (
    id INT IDENTITY(1,1) NOT NULL,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(20,8) NOT NULL,
    date DATE NOT NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_exchangeRates_createdAt DEFAULT (SYSUTCDATETIME()),
    postTime DATETIME2 NOT NULL CONSTRAINT DF_exchangeRates_postTime DEFAULT (SYSUTCDATETIME()),
    userId INT NULL,
    checksum VARBINARY(32) NULL,
    isCurrent BIT NOT NULL CONSTRAINT DF_exchangeRates_isCurrent DEFAULT (1),
    CONSTRAINT PK_exchangeRates PRIMARY KEY (id),
    CONSTRAINT FK_exchangeRates_fromCurrency FOREIGN KEY (fromCurrencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_exchangeRates_toCurrency FOREIGN KEY (toCurrencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_exchangeRates_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT CK_exchangeRates_rate_positive CHECK (rate > 0),
    CONSTRAINT CK_exchangeRates_different_currency CHECK (fromCurrencyId <> toCurrencyId)
);
GO

CREATE TABLE dbo.exchangeHistory (
    id BIGINT IDENTITY(1,1) NOT NULL,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rateToUsd DECIMAL(20,8) NOT NULL,
    startDateTime DATETIME2 NOT NULL,
    endDateTime DATETIME2 NULL,
    postTime DATETIME2 NOT NULL CONSTRAINT DF_exchangeHistory_postTime DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    userId INT NULL,
    exchangeRateId INT NOT NULL,
    isCurrent BIT NOT NULL CONSTRAINT DF_exchangeHistory_isCurrent DEFAULT (1),
    CONSTRAINT PK_exchangeHistory PRIMARY KEY (id),
    CONSTRAINT FK_exchangeHistory_fromCurrency FOREIGN KEY (fromCurrencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_exchangeHistory_toCurrency FOREIGN KEY (toCurrencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_exchangeHistory_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_exchangeHistory_exchangeRates FOREIGN KEY (exchangeRateId) REFERENCES dbo.exchangeRates(id),
    CONSTRAINT CK_exchangeHistory_rate_positive CHECK (rateToUsd > 0),
    CONSTRAINT CK_exchangeHistory_dates CHECK (endDateTime IS NULL OR startDateTime < endDateTime),
    CONSTRAINT CK_exchangeHistory_different_currency CHECK (fromCurrencyId <> toCurrencyId)
);
GO

/* =========================================================
   TAXES
   ========================================================= */

CREATE TABLE dbo.taxTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    CONSTRAINT PK_taxTypes PRIMARY KEY (id),
    CONSTRAINT UQ_taxTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.countryTaxes (
    id INT IDENTITY(1,1) NOT NULL,
    countryId INT NOT NULL,
    percentage DECIMAL(9,4) NULL,
    flatFee DECIMAL(18,2) NULL,
    validFrom DATE NOT NULL,
    validTo DATE NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_countryTaxes_createdAt DEFAULT (SYSUTCDATETIME()),
    createdBy INT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_countryTaxes_enabled DEFAULT (1),
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    CONSTRAINT PK_countryTaxes PRIMARY KEY (id),
    CONSTRAINT FK_countryTaxes_countries FOREIGN KEY (countryId) REFERENCES dbo.countries(id),
    CONSTRAINT FK_countryTaxes_createdBy FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_countryTaxes_updatedBy FOREIGN KEY (updatedBy) REFERENCES dbo.users(id),
    CONSTRAINT CK_countryTaxes_value CHECK (percentage IS NOT NULL OR flatFee IS NOT NULL),
    CONSTRAINT CK_countryTaxes_dates CHECK (validTo IS NULL OR validFrom < validTo)
);
GO

CREATE TABLE dbo.taxes (
    id INT IDENTITY(1,1) NOT NULL,
    taxTypeId INT NOT NULL,
    countryTaxId INT NOT NULL,
    validFrom DATE NOT NULL,
    validTo DATE NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_taxes_createdAt DEFAULT (SYSUTCDATETIME()),
    createdBy INT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_taxes_enabled DEFAULT (1),
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    CONSTRAINT PK_taxes PRIMARY KEY (id),
    CONSTRAINT FK_taxes_taxTypes FOREIGN KEY (taxTypeId) REFERENCES dbo.taxTypes(id),
    CONSTRAINT FK_taxes_countryTaxes FOREIGN KEY (countryTaxId) REFERENCES dbo.countryTaxes(id),
    CONSTRAINT FK_taxes_createdBy FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_taxes_updatedBy FOREIGN KEY (updatedBy) REFERENCES dbo.users(id),
    CONSTRAINT CK_taxes_dates CHECK (validTo IS NULL OR validFrom < validTo)
);
GO

/* =========================================================
   SOCIAL MEDIA AND AI
   ========================================================= */

CREATE TABLE dbo.socialMedia (
    id INT IDENTITY(1,1) NOT NULL,
    description VARCHAR(20) NOT NULL,
    CONSTRAINT PK_socialMedia PRIMARY KEY (id),
    CONSTRAINT UQ_socialMedia_description UNIQUE (description)
);
GO

CREATE TABLE dbo.socialMediaPerUser (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    socialMediaId INT NOT NULL,
    accountUsername VARCHAR(40) NOT NULL,
    accountUrl VARCHAR(255) NULL,
    accessToken VARBINARY(MAX) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_socialMediaPerUser_enabled DEFAULT (1),
    authorizedAt DATETIME2 NOT NULL CONSTRAINT DF_socialMediaPerUser_authorizedAt DEFAULT (SYSUTCDATETIME()),
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_socialMediaPerUser_createdAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_socialMediaPerUser PRIMARY KEY (id),
    CONSTRAINT FK_socialMediaPerUser_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_socialMediaPerUser_socialMedia FOREIGN KEY (socialMediaId) REFERENCES dbo.socialMedia(id),
    CONSTRAINT UQ_socialMediaPerUser_account UNIQUE (socialMediaId, accountUsername)
);
GO

CREATE TABLE dbo.aiStatus (
    id INT IDENTITY(1,1) NOT NULL,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_aiStatus PRIMARY KEY (id),
    CONSTRAINT UQ_aiStatus_status UNIQUE (status)
);
GO

CREATE TABLE dbo.processType (
    id INT IDENTITY(1,1) NOT NULL,
    processType VARCHAR(30) NOT NULL,
    CONSTRAINT PK_processType PRIMARY KEY (id),
    CONSTRAINT UQ_processType_processType UNIQUE (processType)
);
GO

CREATE TABLE dbo.aiProcesses (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NULL,
    url VARCHAR(256) NULL,
    socialMediaId INT NULL,
    response VARCHAR(200) NULL,
    aiStatusId INT NOT NULL,
    processTypeId INT NOT NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_aiProcesses_createdAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_aiProcesses PRIMARY KEY (id),
    CONSTRAINT FK_aiProcesses_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_aiProcesses_socialMedia FOREIGN KEY (socialMediaId) REFERENCES dbo.socialMedia(id),
    CONSTRAINT FK_aiProcesses_aiStatus FOREIGN KEY (aiStatusId) REFERENCES dbo.aiStatus(id),
    CONSTRAINT FK_aiProcesses_processType FOREIGN KEY (processTypeId) REFERENCES dbo.processType(id)
);
GO

CREATE TABLE dbo.settings (
    id INT IDENTITY(1,1) NOT NULL,
    pointsPerEvent INT NOT NULL,
    initialPlayerPoints INT NOT NULL CONSTRAINT DF_settings_initialPlayerPoints DEFAULT (100),
    rejectPenaltyPercentage INT NOT NULL,
    unverifiablePenaltyPercentage INT NOT NULL,
    proposerEarningsPercentage INT NOT NULL,
    platformEarningsPercentage INT NOT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_settings_enabled DEFAULT (1),
    updatedBy INT NULL,
    updatedAt DATETIME2 NOT NULL CONSTRAINT DF_settings_updatedAt DEFAULT (SYSUTCDATETIME()),
    successfulPredictionPercentage INT NOT NULL,
    CONSTRAINT PK_settings PRIMARY KEY (id),
    CONSTRAINT FK_settings_users FOREIGN KEY (updatedBy) REFERENCES dbo.users(id),
    CONSTRAINT CK_settings_pointsPerEvent CHECK (pointsPerEvent > 0),
    CONSTRAINT CK_settings_initialPlayerPoints CHECK (initialPlayerPoints >= 0),
    CONSTRAINT CK_settings_percentages CHECK (
        rejectPenaltyPercentage BETWEEN 0 AND 100 AND
        unverifiablePenaltyPercentage BETWEEN 0 AND 100 AND
        proposerEarningsPercentage BETWEEN 0 AND 100 AND
        platformEarningsPercentage BETWEEN 0 AND 100 AND
        successfulPredictionPercentage BETWEEN 0 AND 100
    )
);
GO

/* =========================================================
   PAYMENTS, AUDITS, WALLETS
   ========================================================= */

CREATE TABLE dbo.auditType (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_auditType PRIMARY KEY (id),
    CONSTRAINT UQ_auditType_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_paymentTypes_enabled DEFAULT (1),
    CONSTRAINT PK_paymentTypes PRIMARY KEY (id),
    CONSTRAINT UQ_paymentTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.operationTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_operationTypes_enabled DEFAULT (1),
    CONSTRAINT PK_operationTypes PRIMARY KEY (id),
    CONSTRAINT UQ_operationTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentStatuses (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_paymentStatuses PRIMARY KEY (id),
    CONSTRAINT UQ_paymentStatuses_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentSourceAPI (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_paymentSourceAPI PRIMARY KEY (id),
    CONSTRAINT UQ_paymentSourceAPI_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentMethods (
    id INT IDENTITY(1,1) NOT NULL,
    paymentTypeId INT NOT NULL,
    paymentSourceAPIId INT NULL,
    source VARCHAR(30) NULL,
    apiUrl VARCHAR(256) NULL,
    configurationJson NVARCHAR(MAX) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_paymentMethods_enabled DEFAULT (1),
    postTime DATETIME2 NOT NULL CONSTRAINT DF_paymentMethods_postTime DEFAULT (SYSUTCDATETIME()),
    userId INT NULL,
    checksum VARBINARY(32) NULL,
    countryId INT NULL,
    CONSTRAINT PK_paymentMethods PRIMARY KEY (id),
    CONSTRAINT FK_paymentMethods_paymentTypes FOREIGN KEY (paymentTypeId) REFERENCES dbo.paymentTypes(id),
    CONSTRAINT FK_paymentMethods_paymentSourceAPI FOREIGN KEY (paymentSourceAPIId) REFERENCES dbo.paymentSourceAPI(id),
    CONSTRAINT FK_paymentMethods_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_paymentMethods_countries FOREIGN KEY (countryId) REFERENCES dbo.countries(id)
);
GO

CREATE TABLE dbo.paymentCardType (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    CONSTRAINT PK_paymentCardType PRIMARY KEY (id),
    CONSTRAINT UQ_paymentCardType_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentCards (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    cardHolderName VARCHAR(80) NOT NULL,
    paymentCardTypeId INT NOT NULL,
    lastFourDigits CHAR(4) NOT NULL,
    expirationMonth TINYINT NOT NULL,
    expirationYear SMALLINT NOT NULL,
    tokenizedCard VARBINARY(MAX) NOT NULL,
    billingCountryId INT NOT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_paymentCards_enabled DEFAULT (1),
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_paymentCards_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_paymentCards PRIMARY KEY (id),
    CONSTRAINT FK_paymentCards_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_paymentCards_paymentCardType FOREIGN KEY (paymentCardTypeId) REFERENCES dbo.paymentCardType(id),
    CONSTRAINT FK_paymentCards_billingCountry FOREIGN KEY (billingCountryId) REFERENCES dbo.countries(id),
    CONSTRAINT CK_paymentCards_expirationMonth CHECK (expirationMonth BETWEEN 1 AND 12),
    CONSTRAINT CK_paymentCards_lastFourDigits CHECK (LEN(lastFourDigits) = 4)
);
GO

CREATE TABLE dbo.paymentCardsPerUser (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    paymentCardId BIGINT NOT NULL,
    CONSTRAINT PK_paymentCardsPerUser PRIMARY KEY (id),
    CONSTRAINT FK_paymentCardsPerUser_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_paymentCardsPerUser_paymentCards FOREIGN KEY (paymentCardId) REFERENCES dbo.paymentCards(id),
    CONSTRAINT UQ_paymentCardsPerUser_user_card UNIQUE (userId, paymentCardId)
);
GO

CREATE TABLE dbo.wallets (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    currencyId INT NOT NULL,
    pointsBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_wallets_pointsBalance DEFAULT (100),
    moneyBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_wallets_moneyBalance DEFAULT (0),
    enabled BIT NOT NULL CONSTRAINT DF_wallets_enabled DEFAULT (1),
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_wallets_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_wallets PRIMARY KEY (id),
    CONSTRAINT FK_wallets_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_wallets_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT CK_wallets_pointsBalance CHECK (pointsBalance >= 0),
    CONSTRAINT CK_wallets_moneyBalance CHECK (moneyBalance >= 0)
);
GO

CREATE TABLE dbo.audits (
    id BIGINT IDENTITY(1,1) NOT NULL,
    paymentAttemptId BIGINT NULL,
    auditTypeId INT NOT NULL,
    validationStep VARCHAR(50) NOT NULL,
    paymentStatusId INT NOT NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    validationMessage VARCHAR(255) NULL,
    externalReference VARCHAR(100) NULL,
    createdDate DATETIME2 NOT NULL CONSTRAINT DF_audits_createdDate DEFAULT (SYSUTCDATETIME()),
    updateDate DATETIME2 NULL,
    createdBy INT NULL,
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_audits PRIMARY KEY (id),
    CONSTRAINT FK_audits_auditType FOREIGN KEY (auditTypeId) REFERENCES dbo.auditType(id),
    CONSTRAINT FK_audits_paymentStatuses FOREIGN KEY (paymentStatusId) REFERENCES dbo.paymentStatuses(id),
    CONSTRAINT FK_audits_users FOREIGN KEY (createdBy) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.paymentAttempts (
    id BIGINT IDENTITY(1,1) NOT NULL,
    paymentMethodId INT NOT NULL,
    paymentCardId BIGINT NULL,
    auditId BIGINT NOT NULL,
    paymentTypeId INT NOT NULL,
    operationTypeId INT NOT NULL,
    paymentStatusId INT NOT NULL,
    userId INT NOT NULL,
    sourceWalletId BIGINT NULL,
    destinationWalletId BIGINT NULL,
    sourceCountryId INT NULL,
    destinationCountryId INT NULL,
    currencyId INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    apiUrl VARCHAR(256) NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    transactionReference VARCHAR(100) NULL,
    referenceObjectType VARCHAR(50) NULL,
    referenceObjectId BIGINT NULL,
    sourceObjectId BIGINT NULL,
    checksum VARBINARY(32) NULL,
    computer VARBINARY(32) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_paymentAttempts_createdAt DEFAULT (SYSUTCDATETIME()),
    postTime DATETIME2 NOT NULL CONSTRAINT DF_paymentAttempts_postTime DEFAULT (SYSUTCDATETIME()),
    internal BIT NOT NULL CONSTRAINT DF_paymentAttempts_internal DEFAULT (0),
    CONSTRAINT PK_paymentAttempts PRIMARY KEY (id),
    CONSTRAINT FK_paymentAttempts_paymentMethods FOREIGN KEY (paymentMethodId) REFERENCES dbo.paymentMethods(id),
    CONSTRAINT FK_paymentAttempts_paymentCards FOREIGN KEY (paymentCardId) REFERENCES dbo.paymentCards(id),
    CONSTRAINT FK_paymentAttempts_audits FOREIGN KEY (auditId) REFERENCES dbo.audits(id),
    CONSTRAINT FK_paymentAttempts_paymentTypes FOREIGN KEY (paymentTypeId) REFERENCES dbo.paymentTypes(id),
    CONSTRAINT FK_paymentAttempts_operationTypes FOREIGN KEY (operationTypeId) REFERENCES dbo.operationTypes(id),
    CONSTRAINT FK_paymentAttempts_paymentStatuses FOREIGN KEY (paymentStatusId) REFERENCES dbo.paymentStatuses(id),
    CONSTRAINT FK_paymentAttempts_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_paymentAttempts_sourceWallet FOREIGN KEY (sourceWalletId) REFERENCES dbo.wallets(id),
    CONSTRAINT FK_paymentAttempts_destinationWallet FOREIGN KEY (destinationWalletId) REFERENCES dbo.wallets(id),
    CONSTRAINT FK_paymentAttempts_sourceCountry FOREIGN KEY (sourceCountryId) REFERENCES dbo.countries(id),
    CONSTRAINT FK_paymentAttempts_destinationCountry FOREIGN KEY (destinationCountryId) REFERENCES dbo.countries(id),
    CONSTRAINT FK_paymentAttempts_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT CK_paymentAttempts_amount_positive CHECK (amount > 0),
    CONSTRAINT CK_paymentAttempts_same_country_or_internal CHECK (
        internal = 1 OR
        sourceCountryId IS NULL OR
        destinationCountryId IS NULL OR
        sourceCountryId = destinationCountryId
    )
);
GO

ALTER TABLE dbo.audits
ADD CONSTRAINT FK_audits_paymentAttempts
FOREIGN KEY (paymentAttemptId) REFERENCES dbo.paymentAttempts(id);
GO

CREATE TABLE dbo.paymentValidationTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_paymentValidationTypes_enabled DEFAULT (1),
    CONSTRAINT PK_paymentValidationTypes PRIMARY KEY (id),
    CONSTRAINT UQ_paymentValidationTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentValidationStatus (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_paymentValidationStatus_enabled DEFAULT (1),
    CONSTRAINT PK_paymentValidationStatus PRIMARY KEY (id),
    CONSTRAINT UQ_paymentValidationStatus_code UNIQUE (code)
);
GO

CREATE TABLE dbo.paymentValidations (
    id BIGINT IDENTITY(1,1) NOT NULL,
    paymentAttemptId BIGINT NOT NULL,
    paymentValidationTypeId INT NOT NULL,
    paymentValidationStatusId INT NOT NULL,
    validationMessage VARCHAR(255) NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_paymentValidations_createdAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_paymentValidations PRIMARY KEY (id),
    CONSTRAINT FK_paymentValidations_paymentAttempts FOREIGN KEY (paymentAttemptId) REFERENCES dbo.paymentAttempts(id),
    CONSTRAINT FK_paymentValidations_paymentValidationTypes FOREIGN KEY (paymentValidationTypeId) REFERENCES dbo.paymentValidationTypes(id),
    CONSTRAINT FK_paymentValidations_paymentValidationStatus FOREIGN KEY (paymentValidationStatusId) REFERENCES dbo.paymentValidationStatus(id)
);
GO

/* =========================================================
   TRANSACTIONS
   ========================================================= */

CREATE TABLE dbo.transactionTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_transactionTypes_createdAt DEFAULT (SYSUTCDATETIME()),
    createdBy INT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_transactionTypes_enabled DEFAULT (1),
    CONSTRAINT PK_transactionTypes PRIMARY KEY (id),
    CONSTRAINT UQ_transactionTypes_code UNIQUE (code),
    CONSTRAINT FK_transactionTypes_users FOREIGN KEY (createdBy) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.transactions (
    id BIGINT IDENTITY(1,1) NOT NULL,
    typeId INT NOT NULL,
    walletId BIGINT NOT NULL,
    paymentAttemptId BIGINT NULL,
    date DATETIME2 NOT NULL CONSTRAINT DF_transactions_date DEFAULT (SYSUTCDATETIME()),
    description VARCHAR(100) NULL,
    amount DECIMAL(18,2) NOT NULL,
    currencyId INT NOT NULL,
    exchangeRateId INT NULL,
    referenceType VARCHAR(30) NULL,
    referenceId BIGINT NULL,
    externalReference VARCHAR(100) NULL,
    balanceAfterPoints DECIMAL(18,2) NOT NULL,
    balanceAfterMoney DECIMAL(18,2) NOT NULL,
    balanceBeforePoints DECIMAL(18,2) NOT NULL,
    balanceBeforeMoney DECIMAL(18,2) NOT NULL,
    createdBy INT NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_transactions_createdAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_transactions PRIMARY KEY (id),
    CONSTRAINT FK_transactions_transactionTypes FOREIGN KEY (typeId) REFERENCES dbo.transactionTypes(id),
    CONSTRAINT FK_transactions_wallets FOREIGN KEY (walletId) REFERENCES dbo.wallets(id),
    CONSTRAINT FK_transactions_paymentAttempts FOREIGN KEY (paymentAttemptId) REFERENCES dbo.paymentAttempts(id),
    CONSTRAINT FK_transactions_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_transactions_exchangeRates FOREIGN KEY (exchangeRateId) REFERENCES dbo.exchangeRates(id),
    CONSTRAINT FK_transactions_users FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT CK_transactions_amount_positive CHECK (amount > 0),
    CONSTRAINT CK_transactions_balances CHECK (
        balanceAfterPoints >= 0 AND
        balanceAfterMoney >= 0 AND
        balanceBeforePoints >= 0 AND
        balanceBeforeMoney >= 0
    )
);
GO

/* =========================================================
   BUSINESS AND REDEEMABLE PRODUCTS
   ========================================================= */

CREATE TABLE dbo.business (
    id INT IDENTITY(1,1) NOT NULL,
    businessName VARCHAR(40) NOT NULL,
    countryId INT NOT NULL,
    contactEmail VARCHAR(255) NULL,
    contactPhone VARCHAR(20) NULL,
    enabled BIT NOT NULL CONSTRAINT DF_business_enabled DEFAULT (1),
    createdBy INT NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_business_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_business PRIMARY KEY (id),
    CONSTRAINT FK_business_countries FOREIGN KEY (countryId) REFERENCES dbo.countries(id),
    CONSTRAINT FK_business_createdBy FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_business_updatedBy FOREIGN KEY (updatedBy) REFERENCES dbo.users(id)
);
GO

CREATE TABLE dbo.quantityType (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    CONSTRAINT PK_quantityType PRIMARY KEY (id),
    CONSTRAINT UQ_quantityType_code UNIQUE (code)
);
GO

CREATE TABLE dbo.unitMeasurement (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(20) NOT NULL,
    CONSTRAINT PK_unitMeasurement PRIMARY KEY (id),
    CONSTRAINT UQ_unitMeasurement_code UNIQUE (code)
);
GO

CREATE TABLE dbo.productCharacteristics (
    id INT IDENTITY(1,1) NOT NULL,
    name VARCHAR(60) NOT NULL,
    CONSTRAINT PK_productCharacteristics PRIMARY KEY (id),
    CONSTRAINT UQ_productCharacteristics_name UNIQUE (name)
);
GO

CREATE TABLE dbo.redeemableProducts (
    id INT IDENTITY(1,1) NOT NULL,
    businessId INT NOT NULL,
    productName VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    stock INT NOT NULL,
    unitMeasurementId INT NOT NULL,
    quantityTypeId INT NOT NULL,
    checksum VARBINARY(32) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_redeemableProducts_createdAt DEFAULT (SYSUTCDATETIME()),
    createdBy INT NULL,
    enabled BIT NOT NULL CONSTRAINT DF_redeemableProducts_enabled DEFAULT (1),
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    currencyId INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_redeemableProducts PRIMARY KEY (id),
    CONSTRAINT FK_redeemableProducts_business FOREIGN KEY (businessId) REFERENCES dbo.business(id),
    CONSTRAINT FK_redeemableProducts_unitMeasurement FOREIGN KEY (unitMeasurementId) REFERENCES dbo.unitMeasurement(id),
    CONSTRAINT FK_redeemableProducts_quantityType FOREIGN KEY (quantityTypeId) REFERENCES dbo.quantityType(id),
    CONSTRAINT FK_redeemableProducts_createdBy FOREIGN KEY (createdBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_redeemableProducts_updatedBy FOREIGN KEY (updatedBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_redeemableProducts_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT CK_redeemableProducts_stock CHECK (stock >= 0),
    CONSTRAINT CK_redeemableProducts_amount CHECK (amount > 0)
);
GO

CREATE TABLE dbo.redemptionStatus (
    id INT IDENTITY(1,1) NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT PK_redemptionStatus PRIMARY KEY (id),
    CONSTRAINT UQ_redemptionStatus_status UNIQUE (status)
);
GO

CREATE TABLE dbo.productRedemption (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    redeemableProductsId INT NOT NULL,
    currencyId INT NOT NULL,
    amountSpent DECIMAL(18,2) NOT NULL,
    redeemedAt DATETIME2 NOT NULL CONSTRAINT DF_productRedemption_redeemedAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    transactionId BIGINT NULL,
    redemptionStatusId INT NOT NULL,
    CONSTRAINT PK_productRedemption PRIMARY KEY (id),
    CONSTRAINT FK_productRedemption_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_productRedemption_redeemableProducts FOREIGN KEY (redeemableProductsId) REFERENCES dbo.redeemableProducts(id),
    CONSTRAINT FK_productRedemption_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT FK_productRedemption_transactions FOREIGN KEY (transactionId) REFERENCES dbo.transactions(id),
    CONSTRAINT FK_productRedemption_redemptionStatus FOREIGN KEY (redemptionStatusId) REFERENCES dbo.redemptionStatus(id),
    CONSTRAINT CK_productRedemption_amountSpent CHECK (amountSpent > 0)
);
GO

CREATE TABLE dbo.productCharacteristicPerProduct (
    id BIGINT IDENTITY(1,1) NOT NULL,
    redeemableProductId INT NOT NULL,
    productCharacteristicId INT NOT NULL,
    value VARCHAR(100) NOT NULL,
    CONSTRAINT PK_productCharacteristicPerProduct PRIMARY KEY (id),
    CONSTRAINT FK_productCharacteristicPerProduct_redeemableProducts FOREIGN KEY (redeemableProductId) REFERENCES dbo.redeemableProducts(id),
    CONSTRAINT FK_productCharacteristicPerProduct_productCharacteristics FOREIGN KEY (productCharacteristicId) REFERENCES dbo.productCharacteristics(id),
    CONSTRAINT UQ_productCharacteristicPerProduct UNIQUE (redeemableProductId, productCharacteristicId)
);
GO

/* =========================================================
   PROPOSITIONS, PREDICTIONS, EVENTS
   ========================================================= */

CREATE TABLE dbo.eventStatus (
    id INT IDENTITY(1,1) NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT PK_eventStatus PRIMARY KEY (id),
    CONSTRAINT UQ_eventStatus_status UNIQUE (status)
);
GO

CREATE TABLE dbo.events (
    id BIGINT IDENTITY(1,1) NOT NULL,
    eventName VARCHAR(50) NOT NULL,
    creatorUser INT NOT NULL,
    eventStatus INT NOT NULL,
    description VARCHAR(200) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_events_createdAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_events PRIMARY KEY (id),
    CONSTRAINT FK_events_creatorUser FOREIGN KEY (creatorUser) REFERENCES dbo.users(id),
    CONSTRAINT FK_events_eventStatus FOREIGN KEY (eventStatus) REFERENCES dbo.eventStatus(id)
);
GO

CREATE TABLE dbo.propositionStatus (
    id INT IDENTITY(1,1) NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT PK_propositionStatus PRIMARY KEY (id),
    CONSTRAINT UQ_propositionStatus_status UNIQUE (status)
);
GO

CREATE TABLE dbo.propositions (
    id BIGINT IDENTITY(1,1) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(200) NOT NULL,
    numberOfVotes INT NOT NULL CONSTRAINT DF_propositions_numberOfVotes DEFAULT (0),
    proposedBy INT NOT NULL,
    proposedTo INT NOT NULL,
    propositionStatusId INT NOT NULL,
    currencyId INT NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_propositions_createdAt DEFAULT (SYSUTCDATETIME()),
    votingStarts DATETIME2 NULL,
    votingClosesAt DATETIME2 NULL,
    acceptedAt DATETIME2 NULL,
    rejectedAt DATETIME2 NULL,
    enabled BIT NOT NULL CONSTRAINT DF_propositions_enabled DEFAULT (1),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_propositions PRIMARY KEY (id),
    CONSTRAINT FK_propositions_proposedBy FOREIGN KEY (proposedBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_propositions_proposedTo FOREIGN KEY (proposedTo) REFERENCES dbo.users(id),
    CONSTRAINT FK_propositions_propositionStatus FOREIGN KEY (propositionStatusId) REFERENCES dbo.propositionStatus(id),
    CONSTRAINT FK_propositions_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT CK_propositions_votes CHECK (numberOfVotes >= 0),
    CONSTRAINT CK_propositions_voting_dates CHECK (votingClosesAt IS NULL OR votingStarts IS NULL OR votingStarts < votingClosesAt)
);
GO

CREATE TABLE dbo.propositionsPerEvent (
    id BIGINT IDENTITY(1,1) NOT NULL,
    eventId BIGINT NOT NULL,
    propositionId BIGINT NOT NULL,
    CONSTRAINT PK_propositionsPerEvent PRIMARY KEY (id),
    CONSTRAINT FK_propositionsPerEvent_events FOREIGN KEY (eventId) REFERENCES dbo.events(id),
    CONSTRAINT FK_propositionsPerEvent_propositions FOREIGN KEY (propositionId) REFERENCES dbo.propositions(id),
    CONSTRAINT UQ_propositionsPerEvent UNIQUE (eventId, propositionId)
);
GO

CREATE TABLE dbo.propositionVotes (
    id BIGINT IDENTITY(1,1) NOT NULL,
    userId INT NOT NULL,
    propositionsId BIGINT NOT NULL,
    checksum VARBINARY(32) NULL,
    votedAt DATETIME2 NOT NULL CONSTRAINT DF_propositionVotes_votedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_propositionVotes PRIMARY KEY (id),
    CONSTRAINT FK_propositionVotes_users FOREIGN KEY (userId) REFERENCES dbo.users(id),
    CONSTRAINT FK_propositionVotes_propositions FOREIGN KEY (propositionsId) REFERENCES dbo.propositions(id),
    CONSTRAINT UQ_propositionVotes_user_proposition UNIQUE (userId, propositionsId)
);
GO

CREATE TABLE dbo.resultType (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    CONSTRAINT PK_resultType PRIMARY KEY (id),
    CONSTRAINT UQ_resultType_code UNIQUE (code)
);
GO

CREATE TABLE dbo.propositionResult (
    id BIGINT IDENTITY(1,1) NOT NULL,
    resultTypeId INT NOT NULL,
    aiProcessId BIGINT NULL,
    propositionId BIGINT NOT NULL,
    resultAt DATETIME2 NOT NULL CONSTRAINT DF_propositionResult_resultAt DEFAULT (SYSUTCDATETIME()),
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_propositionResult PRIMARY KEY (id),
    CONSTRAINT FK_propositionResult_resultType FOREIGN KEY (resultTypeId) REFERENCES dbo.resultType(id),
    CONSTRAINT FK_propositionResult_aiProcesses FOREIGN KEY (aiProcessId) REFERENCES dbo.aiProcesses(id),
    CONSTRAINT FK_propositionResult_propositions FOREIGN KEY (propositionId) REFERENCES dbo.propositions(id),
    CONSTRAINT UQ_propositionResult_proposition UNIQUE (propositionId)
);
GO

CREATE TABLE dbo.predictionTypes (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(40) NOT NULL,
    CONSTRAINT PK_predictionTypes PRIMARY KEY (id),
    CONSTRAINT UQ_predictionTypes_code UNIQUE (code)
);
GO

CREATE TABLE dbo.predictions (
    id BIGINT IDENTITY(1,1) NOT NULL,
    predictionTypesId INT NOT NULL,
    predictedBy INT NOT NULL,
    propositionId BIGINT NOT NULL,
    currencyId INT NULL,
    amount DECIMAL(18,2) NOT NULL,
    winnerAmount DECIMAL(18,2) NULL,
    createdAt DATETIME2 NOT NULL CONSTRAINT DF_predictions_createdAt DEFAULT (SYSUTCDATETIME()),
    enabled BIT NOT NULL CONSTRAINT DF_predictions_enabled DEFAULT (1),
    winner BIT NULL,
    checksum VARBINARY(32) NULL,
    CONSTRAINT PK_predictions PRIMARY KEY (id),
    CONSTRAINT FK_predictions_predictionTypes FOREIGN KEY (predictionTypesId) REFERENCES dbo.predictionTypes(id),
    CONSTRAINT FK_predictions_users FOREIGN KEY (predictedBy) REFERENCES dbo.users(id),
    CONSTRAINT FK_predictions_propositions FOREIGN KEY (propositionId) REFERENCES dbo.propositions(id),
    CONSTRAINT FK_predictions_currencies FOREIGN KEY (currencyId) REFERENCES dbo.currencies(id),
    CONSTRAINT CK_predictions_amount CHECK (amount >= 0),
    CONSTRAINT CK_predictions_winnerAmount CHECK (winnerAmount IS NULL OR winnerAmount >= 0),
    CONSTRAINT UQ_predictions_user_proposition UNIQUE (predictedBy, propositionId)
);
GO

/* =========================================================
   INDEXES
   ========================================================= */

CREATE INDEX IX_states_countryId ON dbo.states(countryId);
CREATE INDEX IX_addresses_stateId ON dbo.addresses(stateId);
CREATE INDEX IX_users_roleTypeId ON dbo.users(roleTypeId);
CREATE INDEX IX_users_addressId ON dbo.users(addressId);
CREATE INDEX IX_logs_postTime ON dbo.logs(postTime);
CREATE INDEX IX_logs_userId ON dbo.logs(userId);
CREATE INDEX IX_logs_dataObject_object ON dbo.logs(dataObjectId, objectId1);
CREATE INDEX IX_currencies_countryId ON dbo.currencies(countryId);
CREATE INDEX IX_exchangeRates_pair ON dbo.exchangeRates(fromCurrencyId, toCurrencyId);
CREATE INDEX IX_exchangeRates_current ON dbo.exchangeRates(isCurrent);
CREATE INDEX IX_exchangeHistory_pair ON dbo.exchangeHistory(fromCurrencyId, toCurrencyId);
CREATE INDEX IX_countryTaxes_countryId ON dbo.countryTaxes(countryId);
CREATE INDEX IX_socialMediaPerUser_userId ON dbo.socialMediaPerUser(userId);
CREATE INDEX IX_aiProcesses_userId ON dbo.aiProcesses(userId);
CREATE INDEX IX_aiProcesses_status ON dbo.aiProcesses(aiStatusId);
CREATE INDEX IX_paymentMethods_type ON dbo.paymentMethods(paymentTypeId);
CREATE INDEX IX_paymentMethods_country ON dbo.paymentMethods(countryId);
CREATE INDEX IX_paymentCards_userId ON dbo.paymentCards(userId);
CREATE INDEX IX_paymentAttempts_userId ON dbo.paymentAttempts(userId);
CREATE INDEX IX_paymentAttempts_status ON dbo.paymentAttempts(paymentStatusId);
CREATE INDEX IX_paymentAttempts_postTime ON dbo.paymentAttempts(postTime);
CREATE INDEX IX_paymentAttempts_source_destination_country ON dbo.paymentAttempts(sourceCountryId, destinationCountryId);
CREATE INDEX IX_audits_paymentAttemptId ON dbo.audits(paymentAttemptId);
CREATE INDEX IX_paymentValidations_attempt ON dbo.paymentValidations(paymentAttemptId);
CREATE INDEX IX_wallets_userId ON dbo.wallets(userId);
CREATE INDEX IX_transactions_walletId ON dbo.transactions(walletId);
CREATE INDEX IX_transactions_paymentAttemptId ON dbo.transactions(paymentAttemptId);
CREATE INDEX IX_transactions_date ON dbo.transactions(date);
CREATE INDEX IX_transactions_reference ON dbo.transactions(referenceType, referenceId);
CREATE INDEX IX_business_countryId ON dbo.business(countryId);
CREATE INDEX IX_redeemableProducts_businessId ON dbo.redeemableProducts(businessId);
CREATE INDEX IX_productRedemption_userId ON dbo.productRedemption(userId);
CREATE INDEX IX_events_creatorUser ON dbo.events(creatorUser);
CREATE INDEX IX_propositions_proposedBy ON dbo.propositions(proposedBy);
CREATE INDEX IX_propositions_proposedTo ON dbo.propositions(proposedTo);
CREATE INDEX IX_propositions_status ON dbo.propositions(propositionStatusId);
CREATE INDEX IX_propositionVotes_proposition ON dbo.propositionVotes(propositionsId);
CREATE INDEX IX_predictions_proposition ON dbo.predictions(propositionId);
CREATE INDEX IX_predictions_predictedBy ON dbo.predictions(predictedBy);
GO

/* =========================================================
   ADDITIONAL BUSINESS NOTES
   =========================================================

   Rules that require joins should be enforced through stored procedures,
   triggers, or service logic, not only CHECK constraints. Examples:

   1. If payment type is CARD:
      - paymentCardId must not be NULL.
      - A CARD_VALIDATION record must exist.
      - CVV and full card number must never be stored.

   2. If payment type is SINPE:
      - paymentCardId must be NULL.
      - sourceCountryId and destinationCountryId must not be NULL.
      - sourceCountryId must equal destinationCountryId, unless internal = 1.
      - A SINPE_VALIDATION or COUNTRY_VALIDATION record must exist.

   3. A transaction should only exist when the related paymentAttempt is APPROVED.

   4. wallets stores current balance; transactions stores historical movement.
*/
GO
