/*
    Gathel - V1__create_schema.sql
    Database engine: SQL Server
    Database name: Gathel

    Flyway versioned migration.

    Purpose:
    - Creates the physical schema of the Gathel database.
    - Creates main tables, primary keys, foreign keys, unique constraints and structural relationships.
    - Implements the corrected physical design based on the approved Markdown specification.

    Design notes:
    - SQL Server uses BIT instead of BOOLEAN.
    - SQL Server TIMESTAMP is not used for date/time fields because it represents ROWVERSION.
    - Date/time fields use DATETIME2.
    - JSON fields are stored as NVARCHAR(MAX).
    - Monetary values, points and balances use DECIMAL instead of FLOAT.
    - Points are modeled as a virtual currency inside currencies.
    - Credit card tables are intentionally not included.
    - Audits are replaced by paymentAttemptValidations.
    - Events are intentionally not included because propositions are the central business entity.
*/

/* ==========================
   ADDRESS / GEO PATTERN
   ========================== */

CREATE TABLE countries (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    isoCode CHAR(2) NULL,
    enabled BIT NOT NULL
);

CREATE TABLE states (
    id INT IDENTITY(1,1) PRIMARY KEY,
    countryId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL,
    CONSTRAINT FK_states_countries FOREIGN KEY (countryId) REFERENCES countries(id)
);

CREATE TABLE cities (
    id INT IDENTITY(1,1) PRIMARY KEY,
    stateId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL,
    CONSTRAINT FK_cities_states FOREIGN KEY (stateId) REFERENCES states(id)
);

CREATE TABLE addresses (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    cityId INT NOT NULL,
    addressLine1 VARCHAR(150) NOT NULL,
    addressLine2 VARCHAR(150) NULL,
    postalCode VARCHAR(20) NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_addresses_cities FOREIGN KEY (cityId) REFERENCES cities(id)
);

/* ==========================
   USERS / ROLES
   ========================== */

CREATE TABLE roleTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    lastName VARCHAR(40) NOT NULL,
    username VARCHAR(40) NOT NULL UNIQUE,
    email VARCHAR(254) NOT NULL UNIQUE,
    password VARBINARY(256) NOT NULL,
    enabled BIT NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    lastLogin DATETIME2 NULL,
    roleTypeId INT NOT NULL,
    createdBy INT NULL,
    updatedBy INT NULL,
    addressId BIGINT NULL,
    CONSTRAINT FK_users_roleTypes FOREIGN KEY (roleTypeId) REFERENCES roleTypes(id),
    CONSTRAINT FK_users_createdBy FOREIGN KEY (createdBy) REFERENCES users(id),
    CONSTRAINT FK_users_updatedBy FOREIGN KEY (updatedBy) REFERENCES users(id),
    CONSTRAINT FK_users_addresses FOREIGN KEY (addressId) REFERENCES addresses(id)
);

/* ==========================
   LOG
   ========================== */

CREATE TABLE logTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE eventTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(120) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE severities (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    level VARCHAR(10) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE sources (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(120) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE dataObjects (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(120) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE logs (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    logTypeId INT NOT NULL,
    eventTypeId INT NOT NULL,
    severityId INT NOT NULL,
    sourceId INT NOT NULL,
    dataObjectId INT NULL,
    description VARCHAR(255) NOT NULL,
    objectId1 BIGINT NULL,
    objectId2 BIGINT NULL,
    referenceId1 BIGINT NULL,
    referenceId2 BIGINT NULL,
    referenceDescription VARCHAR(150) NULL,
    userId INT NULL,
    computer VARBINARY(32) NULL,
    checksum VARBINARY(32) NOT NULL,
    postTime DATETIME2 NOT NULL,
    CONSTRAINT FK_logs_logTypes FOREIGN KEY (logTypeId) REFERENCES logTypes(id),
    CONSTRAINT FK_logs_eventTypes FOREIGN KEY (eventTypeId) REFERENCES eventTypes(id),
    CONSTRAINT FK_logs_severities FOREIGN KEY (severityId) REFERENCES severities(id),
    CONSTRAINT FK_logs_sources FOREIGN KEY (sourceId) REFERENCES sources(id),
    CONSTRAINT FK_logs_dataObjects FOREIGN KEY (dataObjectId) REFERENCES dataObjects(id),
    CONSTRAINT FK_logs_users FOREIGN KEY (userId) REFERENCES users(id)
);

/* ==========================
   CURRENCIES PATTERN
   ========================== */

CREATE TABLE currencyTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE currencies (
    id INT IDENTITY(1,1) PRIMARY KEY,
    currencyTypeId INT NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(40) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    countryId INT NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_currencies_currencyTypes FOREIGN KEY (currencyTypeId) REFERENCES currencyTypes(id),
    CONSTRAINT FK_currencies_countries FOREIGN KEY (countryId) REFERENCES countries(id)
);

CREATE TABLE exchangeRates (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(18,6) NOT NULL,
    rateDate DATE NOT NULL,
    createdAt DATETIME2 NOT NULL,
    postTime DATETIME2 NOT NULL,
    createdBy INT NULL,
    checksum VARBINARY(32) NOT NULL,
    isCurrent BIT NOT NULL,
    CONSTRAINT FK_exchangeRates_fromCurrency FOREIGN KEY (fromCurrencyId) REFERENCES currencies(id),
    CONSTRAINT FK_exchangeRates_toCurrency FOREIGN KEY (toCurrencyId) REFERENCES currencies(id),
    CONSTRAINT FK_exchangeRates_users FOREIGN KEY (createdBy) REFERENCES users(id),
    CONSTRAINT CK_exchangeRates_different_currency CHECK (fromCurrencyId <> toCurrencyId)
);

CREATE TABLE exchangeHistory (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(18,6) NOT NULL,
    startDateTime DATETIME2 NOT NULL,
    endDateTime DATETIME2 NULL,
    postTime DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    userId INT NULL,
    exchangeRateId INT NOT NULL,
    isCurrent BIT NOT NULL,
    CONSTRAINT FK_exchangeHistory_fromCurrency FOREIGN KEY (fromCurrencyId) REFERENCES currencies(id),
    CONSTRAINT FK_exchangeHistory_toCurrency FOREIGN KEY (toCurrencyId) REFERENCES currencies(id),
    CONSTRAINT FK_exchangeHistory_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_exchangeHistory_exchangeRates FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(id)
);

/* ==========================
   IMPUESTOS
   ========================== */

CREATE TABLE taxTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(150) NULL,
    enabled BIT NOT NULL
);

CREATE TABLE countryTaxes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    countryId INT NOT NULL,
    taxTypeId INT NOT NULL,
    name VARCHAR(80) NOT NULL,
    percentage DECIMAL(9,4) NULL,
    flatFee DECIMAL(18,2) NULL,
    currencyId INT NULL,
    validFrom DATE NOT NULL,
    validTo DATE NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    createdBy INT NULL,
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_countryTaxes_countries FOREIGN KEY (countryId) REFERENCES countries(id),
    CONSTRAINT FK_countryTaxes_taxTypes FOREIGN KEY (taxTypeId) REFERENCES taxTypes(id),
    CONSTRAINT FK_countryTaxes_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT FK_countryTaxes_createdBy FOREIGN KEY (createdBy) REFERENCES users(id),
    CONSTRAINT FK_countryTaxes_updatedBy FOREIGN KEY (updatedBy) REFERENCES users(id),
    CONSTRAINT CK_countryTaxes_value CHECK (percentage IS NOT NULL OR flatFee IS NOT NULL)
);

/* ==========================
   SOCIAL MEDIA
   ========================== */

CREATE TABLE socialMedia (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE socialMediaAccounts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    userId INT NOT NULL,
    socialMediaId INT NOT NULL,
    accountUsername VARCHAR(80) NOT NULL,
    accountUrl VARCHAR(255) NULL,
    externalAccountId VARCHAR(120) NULL,
    accessToken VARBINARY(MAX) NULL,
    refreshToken VARBINARY(MAX) NULL,
    authorizedAt DATETIME2 NULL,
    tokenExpiresAt DATETIME2 NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_socialMediaAccounts_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_socialMediaAccounts_socialMedia FOREIGN KEY (socialMediaId) REFERENCES socialMedia(id),
    CONSTRAINT UQ_socialMediaAccounts_user_media_username UNIQUE (userId, socialMediaId, accountUsername)
);

CREATE TABLE socialMediaPostsTypes (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE socialMediaPosts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    socialMediaAccountId BIGINT NOT NULL,
    externalPostId VARCHAR(120) NULL,
    postUrl VARCHAR(500) NOT NULL,
    postTypeId BIGINT NOT NULL,
    caption NVARCHAR(500) NULL,
    postedAt DATETIME2 NULL,
    capturedAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_socialMediaPosts_accounts FOREIGN KEY (socialMediaAccountId) REFERENCES socialMediaAccounts(id),
    CONSTRAINT FK_socialMediaPosts_types FOREIGN KEY (postTypeId) REFERENCES socialMediaPostsTypes(id)
);

CREATE TABLE propositionSourcePostUse (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

/* ==========================
   AI PROCESS LOGS - base catalogs
   ========================== */

CREATE TABLE aiProviders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE aiModels (
    id INT IDENTITY(1,1) PRIMARY KEY,
    aiProviderId INT NOT NULL,
    modelName VARCHAR(100) NOT NULL,
    version VARCHAR(50) NULL,
    enabled BIT NOT NULL,
    CONSTRAINT FK_aiModels_aiProviders FOREIGN KEY (aiProviderId) REFERENCES aiProviders(id)
);

CREATE TABLE aiProcessTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(60) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE aiResults (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

/* ==========================
   SETTINGS
   ========================== */

CREATE TABLE settingsTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE settings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    settingTypeId INT NOT NULL,
    settingValue VARCHAR(255) NOT NULL,
    valueType VARCHAR(20) NOT NULL,
    description VARCHAR(200) NULL,
    enabled BIT NOT NULL,
    updatedBy INT NULL,
    updatedAt DATETIME2 NOT NULL,
    CONSTRAINT FK_settings_settingsTypes FOREIGN KEY (settingTypeId) REFERENCES settingsTypes(id),
    CONSTRAINT FK_settings_users FOREIGN KEY (updatedBy) REFERENCES users(id)
);

/* ==========================
   PAYMENTS
   ========================== */

CREATE TABLE paymentTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE paymentProviders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    baseUrl VARCHAR(256) NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL
);

CREATE TABLE paymentMethods (
    id INT IDENTITY(1,1) PRIMARY KEY,
    paymentTypeId INT NOT NULL,
    paymentProviderId INT NOT NULL,
    countryId INT NULL,
    name VARCHAR(80) NOT NULL,
    configurationJson NVARCHAR(MAX) NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_paymentMethods_paymentTypes FOREIGN KEY (paymentTypeId) REFERENCES paymentTypes(id),
    CONSTRAINT FK_paymentMethods_paymentProviders FOREIGN KEY (paymentProviderId) REFERENCES paymentProviders(id),
    CONSTRAINT FK_paymentMethods_countries FOREIGN KEY (countryId) REFERENCES countries(id)
);

CREATE TABLE operationTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE paymentStatuses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE paymentAttempts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    paymentMethodId INT NOT NULL,
    operationTypeId INT NOT NULL,
    paymentStatusId INT NOT NULL,
    userId INT NOT NULL,
    currencyId INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    referenceObjectType VARCHAR(50) NULL,
    referenceObjectId BIGINT NULL,
    providerReference VARCHAR(120) NULL,
    transactionReference VARCHAR(120) NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    resultMessage VARCHAR(255) NULL,
    errorCode VARCHAR(60) NULL,
    createdAt DATETIME2 NOT NULL,
    completedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_paymentAttempts_methods FOREIGN KEY (paymentMethodId) REFERENCES paymentMethods(id),
    CONSTRAINT FK_paymentAttempts_operationTypes FOREIGN KEY (operationTypeId) REFERENCES operationTypes(id),
    CONSTRAINT FK_paymentAttempts_statuses FOREIGN KEY (paymentStatusId) REFERENCES paymentStatuses(id),
    CONSTRAINT FK_paymentAttempts_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_paymentAttempts_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT CK_paymentAttempts_amount CHECK (amount > 0)
);

CREATE TABLE paymentValidationTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE paymentValidationStatuses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE paymentAttemptValidations (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    paymentAttemptId BIGINT NOT NULL,
    paymentValidationTypeId INT NOT NULL,
    paymentValidationStatusId INT NOT NULL,
    validationOrder INT NOT NULL,
    validationMessage VARCHAR(255) NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    externalReference VARCHAR(120) NULL,
    createdAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_paymentAttemptValidations_attempts FOREIGN KEY (paymentAttemptId) REFERENCES paymentAttempts(id),
    CONSTRAINT FK_paymentAttemptValidations_types FOREIGN KEY (paymentValidationTypeId) REFERENCES paymentValidationTypes(id),
    CONSTRAINT FK_paymentAttemptValidations_statuses FOREIGN KEY (paymentValidationStatusId) REFERENCES paymentValidationStatuses(id)
);

/* ==========================
   WALLETS AND TRANSACTIONS
   ========================== */

CREATE TABLE wallets (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    userId INT NOT NULL,
    currencyId INT NOT NULL,
    balance DECIMAL(18,2) NOT NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_wallets_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_wallets_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT UQ_wallets_user_currency UNIQUE (userId, currencyId)
);

CREATE TABLE transactionTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    createdAt DATETIME2 NOT NULL,
    createdBy INT NULL,
    enabled BIT NOT NULL,
    CONSTRAINT FK_transactionTypes_users FOREIGN KEY (createdBy) REFERENCES users(id)
);

CREATE TABLE transactions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    transactionTypeId INT NOT NULL,
    walletId BIGINT NOT NULL,
    paymentAttemptId BIGINT NULL,
    currencyId INT NOT NULL,
    exchangeRateId INT NULL,
    amount DECIMAL(18,2) NOT NULL,
    balanceBefore DECIMAL(18,2) NOT NULL,
    balanceAfter DECIMAL(18,2) NOT NULL,
    referenceType VARCHAR(40) NULL,
    referenceId BIGINT NULL,
    externalReference VARCHAR(120) NULL,
    description VARCHAR(150) NULL,
    createdBy INT NULL,
    createdAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_transactions_transactionTypes FOREIGN KEY (transactionTypeId) REFERENCES transactionTypes(id),
    CONSTRAINT FK_transactions_wallets FOREIGN KEY (walletId) REFERENCES wallets(id),
    CONSTRAINT FK_transactions_paymentAttempts FOREIGN KEY (paymentAttemptId) REFERENCES paymentAttempts(id),
    CONSTRAINT FK_transactions_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT FK_transactions_exchangeRates FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(id),
    CONSTRAINT FK_transactions_createdBy FOREIGN KEY (createdBy) REFERENCES users(id)
);

/* ==========================
   BUSINESS AND REDEEMABLE PRODUCTS
   ========================== */

CREATE TABLE businesses (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    businessName VARCHAR(80) NOT NULL,
    countryId INT NOT NULL,
    addressId BIGINT NULL,
    contactEmail VARCHAR(255) NULL,
    contactPhone VARCHAR(20) NULL,
    enabled BIT NOT NULL,
    createdBy INT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_businesses_countries FOREIGN KEY (countryId) REFERENCES countries(id),
    CONSTRAINT FK_businesses_addresses FOREIGN KEY (addressId) REFERENCES addresses(id),
    CONSTRAINT FK_businesses_createdBy FOREIGN KEY (createdBy) REFERENCES users(id),
    CONSTRAINT FK_businesses_updatedBy FOREIGN KEY (updatedBy) REFERENCES users(id)
);

CREATE TABLE quantityTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL
);

CREATE TABLE unitMeasurements (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL
);

CREATE TABLE productCharacteristics (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE redeemableProducts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    businessId BIGINT NOT NULL,
    productName VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    stock INT NOT NULL,
    unitMeasurementId INT NULL,
    quantityTypeId INT NULL,
    currencyId INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    createdAt DATETIME2 NOT NULL,
    createdBy INT NULL,
    enabled BIT NOT NULL,
    updatedAt DATETIME2 NULL,
    updatedBy INT NULL,
    CONSTRAINT FK_redeemableProducts_businesses FOREIGN KEY (businessId) REFERENCES businesses(id),
    CONSTRAINT FK_redeemableProducts_unitMeasurements FOREIGN KEY (unitMeasurementId) REFERENCES unitMeasurements(id),
    CONSTRAINT FK_redeemableProducts_quantityTypes FOREIGN KEY (quantityTypeId) REFERENCES quantityTypes(id),
    CONSTRAINT FK_redeemableProducts_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT FK_redeemableProducts_createdBy FOREIGN KEY (createdBy) REFERENCES users(id),
    CONSTRAINT FK_redeemableProducts_updatedBy FOREIGN KEY (updatedBy) REFERENCES users(id),
    CONSTRAINT CK_redeemableProducts_stock CHECK (stock >= 0),
    CONSTRAINT CK_redeemableProducts_amount CHECK (amount >= 0)
);

CREATE TABLE redemptionStatuses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    status VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NULL,
    enabled BIT NOT NULL
);

CREATE TABLE productRedemptions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    userId INT NOT NULL,
    redeemableProductId BIGINT NOT NULL,
    currencyId INT NOT NULL,
    amountSpent DECIMAL(18,2) NOT NULL,
    redeemedAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    transactionId BIGINT NULL,
    redemptionStatusId INT NOT NULL,
    CONSTRAINT FK_productRedemptions_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_productRedemptions_products FOREIGN KEY (redeemableProductId) REFERENCES redeemableProducts(id),
    CONSTRAINT FK_productRedemptions_currencies FOREIGN KEY (currencyId) REFERENCES currencies(id),
    CONSTRAINT FK_productRedemptions_transactions FOREIGN KEY (transactionId) REFERENCES transactions(id),
    CONSTRAINT FK_productRedemptions_statuses FOREIGN KEY (redemptionStatusId) REFERENCES redemptionStatuses(id)
);

CREATE TABLE productCharacteristicPerProduct (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    redeemableProductId BIGINT NOT NULL,
    productCharacteristicId INT NOT NULL,
    value VARCHAR(100) NOT NULL,
    CONSTRAINT FK_productCharacteristicPerProduct_products FOREIGN KEY (redeemableProductId) REFERENCES redeemableProducts(id),
    CONSTRAINT FK_productCharacteristicPerProduct_characteristics FOREIGN KEY (productCharacteristicId) REFERENCES productCharacteristics(id),
    CONSTRAINT UQ_productCharacteristicPerProduct UNIQUE (redeemableProductId, productCharacteristicId)
);

/* ==========================
   PROPOSITIONS, PREDICTIONS AND RESULTS
   ========================== */

CREATE TABLE propositionStatuses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE propositions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(120) NOT NULL,
    description VARCHAR(500) NOT NULL,
    proposedBy INT NOT NULL,
    proposedTo INT NOT NULL,
    propositionStatusId INT NOT NULL,
    selectedVoteId BIGINT NULL,
    votingStartsAt DATETIME2 NULL,
    votingClosesAt DATETIME2 NULL,
    acceptedAt DATETIME2 NULL,
    rejectedAt DATETIME2 NULL,
    challengeStartsAt DATETIME2 NULL,
    challengeEndsAt DATETIME2 NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    updatedAt DATETIME2 NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_propositions_proposedBy FOREIGN KEY (proposedBy) REFERENCES users(id),
    CONSTRAINT FK_propositions_proposedTo FOREIGN KEY (proposedTo) REFERENCES users(id),
    CONSTRAINT FK_propositions_statuses FOREIGN KEY (propositionStatusId) REFERENCES propositionStatuses(id)
);

CREATE TABLE propositionStatusHistory (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT NOT NULL,
    oldStatusId INT NULL,
    newStatusId INT NOT NULL,
    changedBy INT NULL,
    changeReason VARCHAR(255) NULL,
    changedAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_propositionStatusHistory_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT FK_propositionStatusHistory_oldStatus FOREIGN KEY (oldStatusId) REFERENCES propositionStatuses(id),
    CONSTRAINT FK_propositionStatusHistory_newStatus FOREIGN KEY (newStatusId) REFERENCES propositionStatuses(id),
    CONSTRAINT FK_propositionStatusHistory_users FOREIGN KEY (changedBy) REFERENCES users(id)
);

CREATE TABLE propositionVotes (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    userId INT NOT NULL,
    propositionId BIGINT NOT NULL,
    votedAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_propositionVotes_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_propositionVotes_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT UQ_propositionVotes_user_proposition UNIQUE (userId, propositionId)
);

ALTER TABLE propositions
ADD CONSTRAINT FK_propositions_selectedVote FOREIGN KEY (selectedVoteId) REFERENCES propositionVotes(id);

CREATE TABLE propositionSourcePosts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT NOT NULL,
    socialMediaPostId BIGINT NOT NULL,
    sourceUseId BIGINT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    CONSTRAINT FK_propositionSourcePosts_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT FK_propositionSourcePosts_socialPosts FOREIGN KEY (socialMediaPostId) REFERENCES socialMediaPosts(id),
    CONSTRAINT FK_propositionSourcePosts_sourceUse FOREIGN KEY (sourceUseId) REFERENCES propositionSourcePostUse(id),
    CONSTRAINT UQ_propositionSourcePosts UNIQUE (propositionId, socialMediaPostId, sourceUseId)
);

CREATE TABLE aiProcessLogs (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    aiModelId INT NOT NULL,
    aiProcessTypeId INT NOT NULL,
    aiResultId INT NOT NULL,
    userId INT NULL,
    propositionId BIGINT NULL,
    socialMediaPostId BIGINT NULL,
    appliedObjectType VARCHAR(50) NOT NULL,
    appliedObjectId BIGINT NOT NULL,
    prompt NVARCHAR(MAX) NULL,
    requestJson NVARCHAR(MAX) NULL,
    responseJson NVARCHAR(MAX) NULL,
    responseSummary VARCHAR(500) NULL,
    confidence DECIMAL(5,4) NULL,
    createdAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_aiProcessLogs_aiModels FOREIGN KEY (aiModelId) REFERENCES aiModels(id),
    CONSTRAINT FK_aiProcessLogs_aiProcessTypes FOREIGN KEY (aiProcessTypeId) REFERENCES aiProcessTypes(id),
    CONSTRAINT FK_aiProcessLogs_aiResults FOREIGN KEY (aiResultId) REFERENCES aiResults(id),
    CONSTRAINT FK_aiProcessLogs_users FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT FK_aiProcessLogs_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT FK_aiProcessLogs_socialPosts FOREIGN KEY (socialMediaPostId) REFERENCES socialMediaPosts(id)
);

CREATE TABLE resultTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE propositionResults (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT NOT NULL,
    resultTypeId INT NOT NULL,
    aiProcessLogId BIGINT NULL,
    resultAt DATETIME2 NOT NULL,
    resultDescription VARCHAR(255) NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_propositionResults_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT FK_propositionResults_resultTypes FOREIGN KEY (resultTypeId) REFERENCES resultTypes(id),
    CONSTRAINT FK_propositionResults_aiProcessLogs FOREIGN KEY (aiProcessLogId) REFERENCES aiProcessLogs(id)
);

CREATE TABLE predictionTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    enabled BIT NOT NULL
);

CREATE TABLE predictions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    predictionTypeId INT NOT NULL,
    predictedBy INT NOT NULL,
    propositionId BIGINT NOT NULL,
    walletId BIGINT NOT NULL,
    betTransactionId BIGINT NULL,
    rewardTransactionId BIGINT NULL,
    amount DECIMAL(18,2) NOT NULL,
    winnerAmount DECIMAL(18,2) NULL,
    winner BIT NULL,
    enabled BIT NOT NULL,
    createdAt DATETIME2 NOT NULL,
    checksum VARBINARY(32) NOT NULL,
    CONSTRAINT FK_predictions_predictionTypes FOREIGN KEY (predictionTypeId) REFERENCES predictionTypes(id),
    CONSTRAINT FK_predictions_users FOREIGN KEY (predictedBy) REFERENCES users(id),
    CONSTRAINT FK_predictions_propositions FOREIGN KEY (propositionId) REFERENCES propositions(id),
    CONSTRAINT FK_predictions_wallets FOREIGN KEY (walletId) REFERENCES wallets(id),
    CONSTRAINT FK_predictions_betTransactions FOREIGN KEY (betTransactionId) REFERENCES transactions(id),
    CONSTRAINT FK_predictions_rewardTransactions FOREIGN KEY (rewardTransactionId) REFERENCES transactions(id),
    CONSTRAINT UQ_predictions_user_proposition UNIQUE (predictedBy, propositionId),
    CONSTRAINT CK_predictions_amount CHECK (amount > 0)
);

/* ==========================
   INDEXES
   ========================== */

CREATE INDEX IX_users_username ON users(username);
CREATE INDEX IX_users_email ON users(email);
CREATE INDEX IX_wallets_user_currency ON wallets(userId, currencyId);
CREATE INDEX IX_transactions_wallet_createdAt ON transactions(walletId, createdAt);
CREATE INDEX IX_paymentAttempts_user_status ON paymentAttempts(userId, paymentStatusId);
CREATE INDEX IX_propositions_status_createdAt ON propositions(propositionStatusId, createdAt);
CREATE INDEX IX_predictions_proposition ON predictions(propositionId);
CREATE INDEX IX_socialMediaPosts_account ON socialMediaPosts(socialMediaAccountId);
CREATE INDEX IX_aiProcessLogs_proposition ON aiProcessLogs(propositionId);
CREATE INDEX IX_logs_postTime ON logs(postTime);
