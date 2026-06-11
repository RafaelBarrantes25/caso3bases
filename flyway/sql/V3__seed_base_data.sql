/*
    Gathel - V3__seed_base_data.sql
    Database engine: SQL Server
    Database name: Gathel

    Flyway versioned migration.

    Purpose:
    - Inserts base operational data required to test Gathel after the catalog data exists.
    - Creates initial countries, states, cities, addresses, users, wallets, payment methods,
      social media accounts, posts, propositions, AI logs, payment attempts, transactions and predictions.

    Important notes:
    - This is base seed data for week 1 validation.
    - The massive seed required by the case should be added later in another migration.
*/

DECLARE @now DATETIME2 = SYSDATETIME();
DECLARE @checksum VARBINARY(32) = CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', 'GATHEL_BASE_SEED'));
DECLARE @adminId INT;
DECLARE @crcId INT;
DECLARE @usdId INT;
DECLARE @ptsId INT;

/* GEOGRAPHY */
INSERT INTO countries (name, isoCode, enabled) VALUES
('Costa Rica', 'CR', 1),
('United States', 'US', 1),
('Mexico', 'MX', 1),
('Colombia', 'CO', 1),
('Spain', 'ES', 1);

INSERT INTO states (countryId, name, enabled) VALUES
((SELECT id FROM countries WHERE isoCode = 'CR'), 'San Jose', 1),
((SELECT id FROM countries WHERE isoCode = 'CR'), 'Heredia', 1),
((SELECT id FROM countries WHERE isoCode = 'US'), 'Florida', 1),
((SELECT id FROM countries WHERE isoCode = 'MX'), 'Ciudad de Mexico', 1),
((SELECT id FROM countries WHERE isoCode = 'CO'), 'Bogota D.C.', 1),
((SELECT id FROM countries WHERE isoCode = 'ES'), 'Madrid', 1);

INSERT INTO cities (stateId, name, enabled) VALUES
((SELECT id FROM states WHERE name = 'San Jose'), 'San Jose', 1),
((SELECT id FROM states WHERE name = 'Heredia'), 'Heredia', 1),
((SELECT id FROM states WHERE name = 'Florida'), 'Miami', 1),
((SELECT id FROM states WHERE name = 'Ciudad de Mexico'), 'Mexico City', 1),
((SELECT id FROM states WHERE name = 'Bogota D.C.'), 'Bogota', 1),
((SELECT id FROM states WHERE name = 'Madrid'), 'Madrid', 1);

INSERT INTO addresses (cityId, addressLine1, addressLine2, postalCode, latitude, longitude, createdAt, updatedAt, checksum) VALUES
((SELECT id FROM cities WHERE name = 'San Jose'), 'Gathel Headquarters', 'Central Avenue', '10101', 9.928100, -84.090700, @now, NULL, @checksum),
((SELECT id FROM cities WHERE name = 'Heredia'), 'Player Address 1', NULL, '40101', 9.998100, -84.119800, @now, NULL, @checksum),
((SELECT id FROM cities WHERE name = 'Miami'), 'Sample US Address', NULL, '33101', 25.761700, -80.191800, @now, NULL, @checksum),
((SELECT id FROM cities WHERE name = 'Mexico City'), 'Sample MX Address', NULL, '06000', 19.432600, -99.133200, @now, NULL, @checksum),
((SELECT id FROM cities WHERE name = 'Bogota'), 'Sample CO Address', NULL, '110111', 4.711000, -74.072100, @now, NULL, @checksum),
((SELECT id FROM cities WHERE name = 'Madrid'), 'Sample ES Address', NULL, '28001', 40.416800, -3.703800, @now, NULL, @checksum);

/* Link CRC currency to Costa Rica after country creation */
UPDATE currencies
SET countryId = (SELECT id FROM countries WHERE isoCode = 'CR')
WHERE code = 'CRC';

SET @crcId = (SELECT id FROM currencies WHERE code = 'CRC');
SET @usdId = (SELECT id FROM currencies WHERE code = 'USD');
SET @ptsId = (SELECT id FROM currencies WHERE code = 'PTS');

/* EXCHANGE RATES */
INSERT INTO exchangeRates (fromCurrencyId, toCurrencyId, rate, rateDate, createdAt, postTime, createdBy, checksum, isCurrent) VALUES
(@crcId, @usdId, 0.00195, CAST(@now AS DATE), @now, @now, NULL, @checksum, 1),
(@usdId, @crcId, 512.000000, CAST(@now AS DATE), @now, @now, NULL, @checksum, 1),
(@ptsId, @usdId, 0.010000, CAST(@now AS DATE), @now, @now, NULL, @checksum, 1),
(@usdId, @ptsId, 100.000000, CAST(@now AS DATE), @now, @now, NULL, @checksum, 1);

INSERT INTO exchangeHistory (fromCurrencyId, toCurrencyId, rate, startDateTime, endDateTime, postTime, checksum, userId, exchangeRateId, isCurrent)
SELECT fromCurrencyId, toCurrencyId, rate, @now, NULL, @now, @checksum, NULL, id, 1
FROM exchangeRates;

/* TAXES */
INSERT INTO countryTaxes (countryId, taxTypeId, name, percentage, flatFee, currencyId, validFrom, validTo, enabled, createdAt, createdBy, updatedAt, updatedBy, checksum) VALUES
((SELECT id FROM countries WHERE isoCode = 'CR'), (SELECT id FROM taxTypes WHERE code = 'VAT'), 'Costa Rica IVA', 13.0000, NULL, @crcId, CAST(@now AS DATE), NULL, 1, @now, NULL, NULL, NULL, @checksum),
((SELECT id FROM countries WHERE isoCode = 'CR'), (SELECT id FROM taxTypes WHERE code = 'SERVICE_FEE'), 'Gathel service fee Costa Rica', 2.0000, NULL, @crcId, CAST(@now AS DATE), NULL, 1, @now, NULL, NULL, NULL, @checksum);

/* USERS */
INSERT INTO users (name, lastName, username, email, password, enabled, checksum, createdAt, updatedAt, lastLogin, roleTypeId, createdBy, updatedBy, addressId)
VALUES (
    'System',
    'Admin',
    'admin',
    'admin@gathel.local',
    CONVERT(VARBINARY(256), HASHBYTES('SHA2_256', 'Admin123!')),
    1,
    @checksum,
    @now,
    NULL,
    NULL,
    (SELECT id FROM roleTypes WHERE code = 'ADMIN'),
    NULL,
    NULL,
    (SELECT MIN(id) FROM addresses)
);

SET @adminId = SCOPE_IDENTITY();

DECLARE @i INT = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO users (name, lastName, username, email, password, enabled, checksum, createdAt, updatedAt, lastLogin, roleTypeId, createdBy, updatedBy, addressId)
    VALUES (
        CONCAT('Player', @i),
        CONCAT('LastName', @i),
        CONCAT('player', @i),
        CONCAT('player', @i, '@gathel.local'),
        CONVERT(VARBINARY(256), HASHBYTES('SHA2_256', CONCAT('Player', @i, '123!'))),
        1,
        @checksum,
        DATEADD(DAY, -@i, @now),
        NULL,
        NULL,
        (SELECT id FROM roleTypes WHERE code = 'PLAYER'),
        @adminId,
        NULL,
        ((@i % 6) + 1)
    );

    SET @i += 1;
END;

/* PAYMENT METHODS */
INSERT INTO paymentMethods (paymentTypeId, paymentProviderId, countryId, name, configurationJson, enabled, createdAt, updatedAt, checksum) VALUES
((SELECT id FROM paymentTypes WHERE code = 'PAYPAL'), (SELECT id FROM paymentProviders WHERE code = 'PAYPAL_API'), NULL, 'PayPal Sandbox', '{"environment":"sandbox"}', 1, @now, NULL, @checksum),
((SELECT id FROM paymentTypes WHERE code = 'SINPE'), (SELECT id FROM paymentProviders WHERE code = 'SINPE_API'), (SELECT id FROM countries WHERE isoCode = 'CR'), 'SINPE Costa Rica Sandbox', '{"environment":"sandbox","country":"CR"}', 1, @now, NULL, @checksum),
((SELECT id FROM paymentTypes WHERE code = 'CARD'), (SELECT id FROM paymentProviders WHERE code = 'CARD_PROCESSOR'), NULL, 'External Card Processor Sandbox', '{"environment":"sandbox","storeCards":false}', 1, @now, NULL, @checksum),
((SELECT id FROM paymentTypes WHERE code = 'INTERNAL_BALANCE'), (SELECT id FROM paymentProviders WHERE code = 'INTERNAL_ENGINE'), NULL, 'Gathel Internal Balance', '{"internal":true}', 1, @now, NULL, @checksum);

/* WALLETS: each user receives PTS, USD and CRC wallets */
INSERT INTO wallets (userId, currencyId, balance, enabled, createdAt, updatedAt, checksum)
SELECT u.id, c.id,
       CASE WHEN c.code = 'PTS' THEN 100.00 ELSE 25.00 END AS balance,
       1, @now, NULL, @checksum
FROM users u
CROSS JOIN currencies c
WHERE c.code IN ('PTS', 'USD', 'CRC');

/* SOCIAL MEDIA ACCOUNTS AND POSTS */
INSERT INTO socialMediaAccounts (userId, socialMediaId, accountUsername, accountUrl, externalAccountId, accessToken, refreshToken, authorizedAt, tokenExpiresAt, enabled, createdAt, checksum)
SELECT TOP 5
    u.id,
    (SELECT id FROM socialMedia WHERE code = 'INSTAGRAM'),
    CONCAT(u.username, '_ig'),
    CONCAT('https://instagram.example/', u.username),
    CONCAT('ig_', u.id),
    CONVERT(VARBINARY(MAX), HASHBYTES('SHA2_256', CONCAT('access_', u.id))),
    CONVERT(VARBINARY(MAX), HASHBYTES('SHA2_256', CONCAT('refresh_', u.id))),
    @now,
    DATEADD(DAY, 30, @now),
    1,
    @now,
    @checksum
FROM users u
WHERE u.username LIKE 'player%'
ORDER BY u.id;

INSERT INTO socialMediaPosts (socialMediaAccountId, externalPostId, postUrl, postTypeId, caption, postedAt, capturedAt, checksum)
SELECT
    a.id,
    CONCAT('post_', a.id),
    CONCAT(a.accountUrl, '/posts/post_', a.id),
    (SELECT id FROM socialMediaPostsTypes WHERE code = 'POST'),
    'Training update for a public challenge.',
    DATEADD(HOUR, -a.id, @now),
    @now,
    @checksum
FROM socialMediaAccounts a;

/* PROPOSITIONS */
DECLARE @statusProposed INT = (SELECT id FROM propositionStatuses WHERE code = 'PROPOSED');
DECLARE @statusActive INT = (SELECT id FROM propositionStatuses WHERE code = 'ACTIVE');
DECLARE @player1 INT = (SELECT id FROM users WHERE username = 'player1');
DECLARE @player2 INT = (SELECT id FROM users WHERE username = 'player2');
DECLARE @player3 INT = (SELECT id FROM users WHERE username = 'player3');

INSERT INTO propositions (title, description, proposedBy, proposedTo, propositionStatusId, selectedVoteId, votingStartsAt, votingClosesAt, acceptedAt, rejectedAt, challengeStartsAt, challengeEndsAt, enabled, createdAt, updatedAt, checksum) VALUES
('Player 1 will complete a 5 km run', 'Prediction challenge based on a social media training post.', @player2, @player1, @statusActive, NULL, DATEADD(HOUR, -24, @now), DATEADD(HOUR, -1, @now), DATEADD(MINUTE, -50, @now), NULL, @now, DATEADD(DAY, 7, @now), 1, DATEADD(DAY, -1, @now), NULL, @checksum),
('Player 3 will publish a training update', 'Simple proposition for week 1 validation.', @player1, @player3, @statusProposed, NULL, @now, DATEADD(HOUR, 24, @now), NULL, NULL, NULL, NULL, 1, @now, NULL, @checksum);

INSERT INTO propositionStatusHistory (propositionId, oldStatusId, newStatusId, changedBy, changeReason, changedAt, checksum)
SELECT id, NULL, propositionStatusId, proposedBy, 'Initial status from seed data', createdAt, @checksum
FROM propositions;

INSERT INTO propositionSourcePosts (propositionId, socialMediaPostId, sourceUseId, createdAt)
SELECT TOP 1
    (SELECT id FROM propositions WHERE title = 'Player 1 will complete a 5 km run'),
    p.id,
    (SELECT id FROM propositionSourcePostUse WHERE code = 'ORIGIN'),
    @now
FROM socialMediaPosts p
ORDER BY p.id;

/* AI LOG FOR PROPOSITION REVIEW */
INSERT INTO aiProcessLogs (aiModelId, aiProcessTypeId, aiResultId, userId, propositionId, socialMediaPostId, appliedObjectType, appliedObjectId, prompt, requestJson, responseJson, responseSummary, confidence, createdAt, checksum)
SELECT TOP 1
    (SELECT TOP 1 id FROM aiModels ORDER BY id),
    (SELECT id FROM aiProcessTypes WHERE code = 'PROPOSITION_CREATION_REVIEW'),
    (SELECT id FROM aiResults WHERE code = 'APPROVED'),
    @player2,
    pr.id,
    sp.id,
    'PROPOSITION',
    pr.id,
    'Review the proposition according to Gathel safety rules.',
    '{"input":"Player 1 will complete a 5 km run"}',
    '{"result":"APPROVED","reason":"Safe proposition"}',
    'The proposition was approved by the seed AI review.',
    0.9500,
    @now,
    @checksum
FROM propositions pr
LEFT JOIN propositionSourcePosts psp ON psp.propositionId = pr.id
LEFT JOIN socialMediaPosts sp ON sp.id = psp.socialMediaPostId
WHERE pr.title = 'Player 1 will complete a 5 km run';

/* PAYMENT ATTEMPT AND VALIDATIONS */
DECLARE @paymentAttemptId BIGINT;
INSERT INTO paymentAttempts (paymentMethodId, operationTypeId, paymentStatusId, userId, currencyId, amount, referenceObjectType, referenceObjectId, providerReference, transactionReference, requestJson, responseJson, resultMessage, errorCode, createdAt, completedAt, checksum)
VALUES (
    (SELECT id FROM paymentMethods WHERE name = 'Gathel Internal Balance'),
    (SELECT id FROM operationTypes WHERE code = 'PREDICTION_BET'),
    (SELECT id FROM paymentStatuses WHERE code = 'APPROVED'),
    @player3,
    @ptsId,
    1.00,
    'PROPOSITION',
    (SELECT id FROM propositions WHERE title = 'Player 1 will complete a 5 km run'),
    'internal_seed_001',
    'tx_seed_001',
    '{"amount":1,"currency":"PTS"}',
    '{"approved":true}',
    'Approved internal points bet',
    NULL,
    @now,
    @now,
    @checksum
);
SET @paymentAttemptId = SCOPE_IDENTITY();

INSERT INTO paymentAttemptValidations (paymentAttemptId, paymentValidationTypeId, paymentValidationStatusId, validationOrder, validationMessage, requestJson, responseJson, externalReference, createdAt, checksum) VALUES
(@paymentAttemptId, (SELECT id FROM paymentValidationTypes WHERE code = 'METHOD_CHECK'), (SELECT id FROM paymentValidationStatuses WHERE code = 'APPROVED'), 1, 'Internal balance method enabled', NULL, '{"enabled":true}', 'validation_seed_001', @now, @checksum),
(@paymentAttemptId, (SELECT id FROM paymentValidationTypes WHERE code = 'FUNDS_CHECK'), (SELECT id FROM paymentValidationStatuses WHERE code = 'APPROVED'), 2, 'Player has enough points', NULL, '{"enoughFunds":true}', 'validation_seed_002', @now, @checksum);

/* TRANSACTION AND PREDICTION */
DECLARE @walletId BIGINT = (SELECT id FROM wallets WHERE userId = @player3 AND currencyId = @ptsId);
DECLARE @balanceBefore DECIMAL(18,2) = (SELECT balance FROM wallets WHERE id = @walletId);
DECLARE @transactionId BIGINT;

UPDATE wallets
SET balance = balance - 1.00,
    updatedAt = @now
WHERE id = @walletId;

INSERT INTO transactions (transactionTypeId, walletId, paymentAttemptId, currencyId, exchangeRateId, amount, balanceBefore, balanceAfter, referenceType, referenceId, externalReference, description, createdBy, createdAt, checksum)
VALUES (
    (SELECT id FROM transactionTypes WHERE code = 'BET'),
    @walletId,
    @paymentAttemptId,
    @ptsId,
    NULL,
    -1.00,
    @balanceBefore,
    @balanceBefore - 1.00,
    'PROPOSITION',
    (SELECT id FROM propositions WHERE title = 'Player 1 will complete a 5 km run'),
    'tx_seed_001',
    'Initial seed prediction bet using Gathel points',
    @player3,
    @now,
    @checksum
);
SET @transactionId = SCOPE_IDENTITY();

INSERT INTO predictions (predictionTypeId, predictedBy, propositionId, walletId, betTransactionId, rewardTransactionId, amount, winnerAmount, winner, enabled, createdAt, checksum)
VALUES (
    (SELECT id FROM predictionTypes WHERE code = 'WILL_HAPPEN'),
    @player3,
    (SELECT id FROM propositions WHERE title = 'Player 1 will complete a 5 km run'),
    @walletId,
    @transactionId,
    NULL,
    1.00,
    NULL,
    NULL,
    1,
    @now,
    @checksum
);

/* SAMPLE LOG */
INSERT INTO logs (logTypeId, eventTypeId, severityId, sourceId, dataObjectId, description, objectId1, objectId2, referenceId1, referenceId2, referenceDescription, userId, computer, checksum, postTime)
VALUES (
    (SELECT id FROM logTypes WHERE code = 'SYSTEM'),
    (SELECT id FROM eventTypes WHERE code = 'INSERT'),
    (SELECT id FROM severities WHERE code = 'INFO'),
    (SELECT id FROM sources WHERE code = 'FLYWAY'),
    (SELECT id FROM dataObjects WHERE code = 'USERS'),
    'Base seed data was inserted successfully.',
    NULL,
    NULL,
    NULL,
    NULL,
    'V3 seed base data',
    @adminId,
    NULL,
    @checksum,
    @now
);
