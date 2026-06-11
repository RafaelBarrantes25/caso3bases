/*
    Gathel - V4__week1_validation_queries.sql
    Database engine: SQL Server
    Database name: Gathel

    Flyway versioned migration.

    Purpose:
    - Provides validation queries for the first project delivery.
    - Confirms schema, catalogs, seed data and Flyway execution.

    Important note:
    - This migration creates a validation view instead of printing many result sets.
      The queries at the bottom can also be copied and executed manually in SSMS for evidence screenshots.
*/

CREATE VIEW vw_week1_database_summary
AS
SELECT 'users' AS objectName, COUNT_BIG(*) AS totalRows FROM users
UNION ALL SELECT 'wallets', COUNT_BIG(*) FROM wallets
UNION ALL SELECT 'currencies', COUNT_BIG(*) FROM currencies
UNION ALL SELECT 'paymentMethods', COUNT_BIG(*) FROM paymentMethods
UNION ALL SELECT 'paymentAttempts', COUNT_BIG(*) FROM paymentAttempts
UNION ALL SELECT 'paymentAttemptValidations', COUNT_BIG(*) FROM paymentAttemptValidations
UNION ALL SELECT 'transactions', COUNT_BIG(*) FROM transactions
UNION ALL SELECT 'socialMediaAccounts', COUNT_BIG(*) FROM socialMediaAccounts
UNION ALL SELECT 'socialMediaPosts', COUNT_BIG(*) FROM socialMediaPosts
UNION ALL SELECT 'propositions', COUNT_BIG(*) FROM propositions
UNION ALL SELECT 'propositionSourcePosts', COUNT_BIG(*) FROM propositionSourcePosts
UNION ALL SELECT 'aiProcessLogs', COUNT_BIG(*) FROM aiProcessLogs
UNION ALL SELECT 'predictions', COUNT_BIG(*) FROM predictions
UNION ALL SELECT 'logs', COUNT_BIG(*) FROM logs;
GO

/*
Manual validation queries for SSMS evidence:

SELECT DB_NAME() AS CurrentDatabase;

SELECT *
FROM flyway_schema_history
ORDER BY installed_rank;

SELECT *
FROM vw_week1_database_summary
ORDER BY objectName;

SELECT u.username, c.code AS currencyCode, w.balance
FROM wallets w
INNER JOIN users u ON u.id = w.userId
INNER JOIN currencies c ON c.id = w.currencyId
ORDER BY u.username, c.code;

SELECT p.id, p.title, ps.code AS statusCode, proposer.username AS proposedBy, targetUser.username AS proposedTo
FROM propositions p
INNER JOIN propositionStatuses ps ON ps.id = p.propositionStatusId
INNER JOIN users proposer ON proposer.id = p.proposedBy
INNER JOIN users targetUser ON targetUser.id = p.proposedTo;

SELECT p.title, smp.postUrl, psu.code AS sourceUse
FROM propositionSourcePosts psp
INNER JOIN propositions p ON p.id = psp.propositionId
INNER JOIN socialMediaPosts smp ON smp.id = psp.socialMediaPostId
INNER JOIN propositionSourcePostUse psu ON psu.id = psp.sourceUseId;

SELECT p.title, aip.code AS processType, ar.code AS aiResult, apl.responseSummary
FROM aiProcessLogs apl
INNER JOIN propositions p ON p.id = apl.propositionId
INNER JOIN aiProcessTypes aip ON aip.id = apl.aiProcessTypeId
INNER JOIN aiResults ar ON ar.id = apl.aiResultId;

SELECT pa.id, u.username, ot.code AS operationType, ps.code AS paymentStatus, c.code AS currencyCode, pa.amount
FROM paymentAttempts pa
INNER JOIN users u ON u.id = pa.userId
INNER JOIN operationTypes ot ON ot.id = pa.operationTypeId
INNER JOIN paymentStatuses ps ON ps.id = pa.paymentStatusId
INNER JOIN currencies c ON c.id = pa.currencyId;

SELECT t.id, u.username, c.code AS currencyCode, tt.code AS transactionType, t.amount, t.balanceBefore, t.balanceAfter
FROM transactions t
INNER JOIN wallets w ON w.id = t.walletId
INNER JOIN users u ON u.id = w.userId
INNER JOIN currencies c ON c.id = t.currencyId
INNER JOIN transactionTypes tt ON tt.id = t.transactionTypeId;
*/
