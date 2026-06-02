/*
    Gathel - 04_validaciones.sql
    Database engine: SQL Server
    Database name: Gathel

*/

USE Gathel;
GO

/* =========================================================
   VALIDATION VIEW: TABLE COUNTS
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_week1_table_counts
AS
SELECT 'users' AS tableName, COUNT(*) AS totalRows FROM dbo.users
UNION ALL
SELECT 'roleType', COUNT(*) FROM dbo.roleType
UNION ALL
SELECT 'countries', COUNT(*) FROM dbo.countries
UNION ALL
SELECT 'states', COUNT(*) FROM dbo.states
UNION ALL
SELECT 'currencies', COUNT(*) FROM dbo.currencies
UNION ALL
SELECT 'paymentTypes', COUNT(*) FROM dbo.paymentTypes
UNION ALL
SELECT 'operationTypes', COUNT(*) FROM dbo.operationTypes
UNION ALL
SELECT 'paymentStatuses', COUNT(*) FROM dbo.paymentStatuses
UNION ALL
SELECT 'paymentValidationTypes', COUNT(*) FROM dbo.paymentValidationTypes
UNION ALL
SELECT 'paymentValidationStatus', COUNT(*) FROM dbo.paymentValidationStatus
UNION ALL
SELECT 'transactionTypes', COUNT(*) FROM dbo.transactionTypes
UNION ALL
SELECT 'propositionStatus', COUNT(*) FROM dbo.propositionStatus
UNION ALL
SELECT 'predictionTypes', COUNT(*) FROM dbo.predictionTypes
UNION ALL
SELECT 'resultType', COUNT(*) FROM dbo.resultType
UNION ALL
SELECT 'wallets', COUNT(*) FROM dbo.wallets
UNION ALL
SELECT 'paymentMethods', COUNT(*) FROM dbo.paymentMethods
UNION ALL
SELECT 'paymentCards', COUNT(*) FROM dbo.paymentCards
UNION ALL
SELECT 'business', COUNT(*) FROM dbo.business
UNION ALL
SELECT 'redeemableProducts', COUNT(*) FROM dbo.redeemableProducts;
GO

/* =========================================================
   VALIDATION VIEW: WEEK 1 USERS AND WALLETS
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_week1_users_wallets
AS
SELECT
    u.id AS userId,
    u.username,
    u.email,
    rt.code AS roleCode,
    c.name AS currencyName,
    w.pointsBalance,
    w.moneyBalance,
    w.enabled AS walletEnabled
FROM dbo.users u
INNER JOIN dbo.roleType rt
    ON rt.id = u.roleTypeId
INNER JOIN dbo.wallets w
    ON w.userId = u.id
INNER JOIN dbo.currencies c
    ON c.id = w.currencyId;
GO

/* =========================================================
   VALIDATION VIEW: PAYMENT METHODS
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_week1_payment_methods
AS
SELECT
    pm.id AS paymentMethodId,
    pt.code AS paymentType,
    psa.code AS sourceApi,
    pm.source,
    co.name AS countryName,
    pm.enabled
FROM dbo.paymentMethods pm
INNER JOIN dbo.paymentTypes pt
    ON pt.id = pm.paymentTypeId
LEFT JOIN dbo.paymentSourceAPI psa
    ON psa.id = pm.paymentSourceAPIId
LEFT JOIN dbo.countries co
    ON co.id = pm.countryId;
GO

/* =========================================================
   VALIDATION QUERIES
   ========================================================= */

SELECT *
FROM dbo.vw_week1_table_counts
ORDER BY tableName;

SELECT *
FROM dbo.vw_week1_users_wallets
ORDER BY userId;

SELECT *
FROM dbo.vw_week1_payment_methods
ORDER BY paymentMethodId;

SELECT
    name AS createdTable
FROM sys.tables
ORDER BY name;

SELECT
    name AS foreignKeyName
FROM sys.foreign_keys
ORDER BY name;

SELECT
    name AS indexName,
    OBJECT_NAME(object_id) AS tableName
FROM sys.indexes
WHERE name IS NOT NULL
ORDER BY tableName, indexName;
GO