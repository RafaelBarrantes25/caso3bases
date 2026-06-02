/*
    Gathel - 02_insertarCatalogos.sql
    Database engine: SQL Server
    Database name: Gathel

    Use tras 01_script_creacionTablas.sql para crear las tablas necesarias antes de ejecutar este script.
    Este script inserta todos los catalogos o "tablas tipo" con los valores iniciales necesarios para el funcionamiento de Gathel.
    Si se sufre algun cambio en la base de datos este tambien debe cambiarse.
*/

USE Gathel;
GO

/* =========================================================
   ROLE TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.roleType WHERE code = 'ADMIN')
    INSERT INTO dbo.roleType(code) VALUES ('ADMIN');

IF NOT EXISTS (SELECT 1 FROM dbo.roleType WHERE code = 'PLAYER')
    INSERT INTO dbo.roleType(code) VALUES ('PLAYER');

IF NOT EXISTS (SELECT 1 FROM dbo.roleType WHERE code = 'AUDITOR')
    INSERT INTO dbo.roleType(code) VALUES ('AUDITOR');

IF NOT EXISTS (SELECT 1 FROM dbo.roleType WHERE code = 'READ_ONLY')
    INSERT INTO dbo.roleType(code) VALUES ('READ_ONLY');

IF NOT EXISTS (SELECT 1 FROM dbo.roleType WHERE code = 'WRITE_ONLY')
    INSERT INTO dbo.roleType(code) VALUES ('WRITE_ONLY');
GO

/* =========================================================
   LOG TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.logTypes WHERE code = 'USER')
    INSERT INTO dbo.logTypes(code, description) VALUES ('USER', 'User related event');

IF NOT EXISTS (SELECT 1 FROM dbo.logTypes WHERE code = 'AI')
    INSERT INTO dbo.logTypes(code, description) VALUES ('AI', 'Artificial intelligence process event');

IF NOT EXISTS (SELECT 1 FROM dbo.logTypes WHERE code = 'SYSTEM')
    INSERT INTO dbo.logTypes(code, description) VALUES ('SYSTEM', 'System internal event');

IF NOT EXISTS (SELECT 1 FROM dbo.logTypes WHERE code = 'SECURITY')
    INSERT INTO dbo.logTypes(code, description) VALUES ('SECURITY', 'Security related event');

IF NOT EXISTS (SELECT 1 FROM dbo.logTypes WHERE code = 'PAYMENT')
    INSERT INTO dbo.logTypes(code, description) VALUES ('PAYMENT', 'Payment related event');
GO

/* =========================================================
   EVENT TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'CREATED')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('CREATED', 'Record created');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'UPDATED')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('UPDATED', 'Record updated');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'DELETED')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('DELETED', 'Record deleted');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'LOGIN')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('LOGIN', 'User login');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'PAYMENT_ATTEMPT')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('PAYMENT_ATTEMPT', 'Payment attempt registered');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'AI_REVIEW')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('AI_REVIEW', 'AI review executed');

IF NOT EXISTS (SELECT 1 FROM dbo.eventTypes WHERE code = 'TRANSACTION_CREATED')
    INSERT INTO dbo.eventTypes(code, description) VALUES ('TRANSACTION_CREATED', 'Transaction created');
GO

/* =========================================================
   SEVERITIES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.severities WHERE code = 'INFO')
    INSERT INTO dbo.severities(code, level) VALUES ('INFO', 'LOW');

IF NOT EXISTS (SELECT 1 FROM dbo.severities WHERE code = 'WARNING')
    INSERT INTO dbo.severities(code, level) VALUES ('WARNING', 'MEDIUM');

IF NOT EXISTS (SELECT 1 FROM dbo.severities WHERE code = 'ERROR')
    INSERT INTO dbo.severities(code, level) VALUES ('ERROR', 'HIGH');

IF NOT EXISTS (SELECT 1 FROM dbo.severities WHERE code = 'CRITICAL')
    INSERT INTO dbo.severities(code, level) VALUES ('CRITICAL', 'CRITICAL');
GO

/* =========================================================
   SOURCES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.sources WHERE code = 'WEB')
    INSERT INTO dbo.sources(code, description) VALUES ('WEB', 'Web frontend');

IF NOT EXISTS (SELECT 1 FROM dbo.sources WHERE code = 'API')
    INSERT INTO dbo.sources(code, description) VALUES ('API', 'Backend REST API');

IF NOT EXISTS (SELECT 1 FROM dbo.sources WHERE code = 'SQL_JOB')
    INSERT INTO dbo.sources(code, description) VALUES ('SQL_JOB', 'SQL Server job or script');

IF NOT EXISTS (SELECT 1 FROM dbo.sources WHERE code = 'AI_AGENT')
    INSERT INTO dbo.sources(code, description) VALUES ('AI_AGENT', 'AI agent process');

IF NOT EXISTS (SELECT 1 FROM dbo.sources WHERE code = 'PAYMENT_PROVIDER')
    INSERT INTO dbo.sources(code, description) VALUES ('PAYMENT_PROVIDER', 'External payment provider');
GO

/* =========================================================
   DATA OBJECTS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'USER')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('USER', 'User object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'PROPOSITION')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('PROPOSITION', 'Proposition object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'PREDICTION')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('PREDICTION', 'Prediction object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'PAYMENT')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('PAYMENT', 'Payment object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'TRANSACTION')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('TRANSACTION', 'Transaction object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'AI_PROCESS')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('AI_PROCESS', 'AI process object');

IF NOT EXISTS (SELECT 1 FROM dbo.dataObjects WHERE code = 'WALLET')
    INSERT INTO dbo.dataObjects(code, description) VALUES ('WALLET', 'Wallet object');
GO

/* =========================================================
   TAX TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.taxTypes WHERE code = 'VAT')
    INSERT INTO dbo.taxTypes(code) VALUES ('VAT');

IF NOT EXISTS (SELECT 1 FROM dbo.taxTypes WHERE code = 'IMPORT_DUTY')
    INSERT INTO dbo.taxTypes(code) VALUES ('IMPORT_DUTY');

IF NOT EXISTS (SELECT 1 FROM dbo.taxTypes WHERE code = 'SALES_TAX')
    INSERT INTO dbo.taxTypes(code) VALUES ('SALES_TAX');

IF NOT EXISTS (SELECT 1 FROM dbo.taxTypes WHERE code = 'SERVICE_FEE')
    INSERT INTO dbo.taxTypes(code) VALUES ('SERVICE_FEE');
GO

/* =========================================================
   SOCIAL MEDIA
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.socialMedia WHERE description = 'Instagram')
    INSERT INTO dbo.socialMedia(description) VALUES ('Instagram');

IF NOT EXISTS (SELECT 1 FROM dbo.socialMedia WHERE description = 'TikTok')
    INSERT INTO dbo.socialMedia(description) VALUES ('TikTok');

IF NOT EXISTS (SELECT 1 FROM dbo.socialMedia WHERE description = 'Facebook')
    INSERT INTO dbo.socialMedia(description) VALUES ('Facebook');

IF NOT EXISTS (SELECT 1 FROM dbo.socialMedia WHERE description = 'X')
    INSERT INTO dbo.socialMedia(description) VALUES ('X');
GO

/* =========================================================
   AI STATUS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.aiStatus WHERE status = 'PENDING')
    INSERT INTO dbo.aiStatus(status) VALUES ('PENDING');

IF NOT EXISTS (SELECT 1 FROM dbo.aiStatus WHERE status = 'APPROVED')
    INSERT INTO dbo.aiStatus(status) VALUES ('APPROVED');

IF NOT EXISTS (SELECT 1 FROM dbo.aiStatus WHERE status = 'REJECTED')
    INSERT INTO dbo.aiStatus(status) VALUES ('REJECTED');

IF NOT EXISTS (SELECT 1 FROM dbo.aiStatus WHERE status = 'INCONCLUSIVE')
    INSERT INTO dbo.aiStatus(status) VALUES ('INCONCLUSIVE');

IF NOT EXISTS (SELECT 1 FROM dbo.aiStatus WHERE status = 'FAILED')
    INSERT INTO dbo.aiStatus(status) VALUES ('FAILED');
GO

/* =========================================================
   PROCESS TYPE
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.processType WHERE processType = 'PROPOSITION_REVIEW')
    INSERT INTO dbo.processType(processType) VALUES ('PROPOSITION_REVIEW');

IF NOT EXISTS (SELECT 1 FROM dbo.processType WHERE processType = 'RESULT_VALIDATION')
    INSERT INTO dbo.processType(processType) VALUES ('RESULT_VALIDATION');

IF NOT EXISTS (SELECT 1 FROM dbo.processType WHERE processType = 'FRAUD_CHECK')
    INSERT INTO dbo.processType(processType) VALUES ('FRAUD_CHECK');

IF NOT EXISTS (SELECT 1 FROM dbo.processType WHERE processType = 'PAYMENT_RISK_REVIEW')
    INSERT INTO dbo.processType(processType) VALUES ('PAYMENT_RISK_REVIEW');
GO

/* =========================================================
   AUDIT TYPE
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.auditType WHERE code = 'PAYMENT_VALIDATION')
    INSERT INTO dbo.auditType(code, description) VALUES ('PAYMENT_VALIDATION', 'General payment validation');

IF NOT EXISTS (SELECT 1 FROM dbo.auditType WHERE code = 'CARD_VALIDATION')
    INSERT INTO dbo.auditType(code, description) VALUES ('CARD_VALIDATION', 'Card payment validation');

IF NOT EXISTS (SELECT 1 FROM dbo.auditType WHERE code = 'SINPE_VALIDATION')
    INSERT INTO dbo.auditType(code, description) VALUES ('SINPE_VALIDATION', 'SINPE payment validation');

IF NOT EXISTS (SELECT 1 FROM dbo.auditType WHERE code = 'COUNTRY_VALIDATION')
    INSERT INTO dbo.auditType(code, description) VALUES ('COUNTRY_VALIDATION', 'Country validation for local transfers');

IF NOT EXISTS (SELECT 1 FROM dbo.auditType WHERE code = 'FRAUD_CHECK')
    INSERT INTO dbo.auditType(code, description) VALUES ('FRAUD_CHECK', 'Fraud risk validation');
GO

/* =========================================================
   PAYMENT TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes WHERE code = 'CARD')
    INSERT INTO dbo.paymentTypes(code, enabled) VALUES ('CARD', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes WHERE code = 'SINPE')
    INSERT INTO dbo.paymentTypes(code, enabled) VALUES ('SINPE', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes WHERE code = 'PAYPAL')
    INSERT INTO dbo.paymentTypes(code, enabled) VALUES ('PAYPAL', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes WHERE code = 'BANK_TRANSFER')
    INSERT INTO dbo.paymentTypes(code, enabled) VALUES ('BANK_TRANSFER', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentTypes WHERE code = 'INTERNAL')
    INSERT INTO dbo.paymentTypes(code, enabled) VALUES ('INTERNAL', 1);
GO

/* =========================================================
   OPERATION TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'POINTS_PURCHASE')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('POINTS_PURCHASE', 'Purchase points with real money');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'MONEY_DEPOSIT')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('MONEY_DEPOSIT', 'Deposit real money');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'MONEY_WITHDRAWAL')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('MONEY_WITHDRAWAL', 'Withdraw real money');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'PREDICTION_BET')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('PREDICTION_BET', 'Place a prediction bet');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'REWARD_PAYMENT')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('REWARD_PAYMENT', 'Pay reward to winner');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'PRODUCT_REDEMPTION')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('PRODUCT_REDEMPTION', 'Redeem product with points');

IF NOT EXISTS (SELECT 1 FROM dbo.operationTypes WHERE code = 'PENALTY')
    INSERT INTO dbo.operationTypes(code, description) VALUES ('PENALTY', 'Apply penalty');
GO

/* =========================================================
   PAYMENT STATUSES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'PENDING')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('PENDING', 'Payment is pending');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'APPROVED')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('APPROVED', 'Payment approved');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'REJECTED')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('REJECTED', 'Payment rejected');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'ERROR')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('ERROR', 'Payment error');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'INSUFFICIENT_FUNDS')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('INSUFFICIENT_FUNDS', 'Insufficient funds');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentStatuses WHERE code = 'CANCELLED')
    INSERT INTO dbo.paymentStatuses(code, description) VALUES ('CANCELLED', 'Payment cancelled');
GO

/* =========================================================
   PAYMENT SOURCE API
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentSourceAPI WHERE code = 'CARD_PROCESSOR')
    INSERT INTO dbo.paymentSourceAPI(code, description) VALUES ('CARD_PROCESSOR', 'Card processor API');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentSourceAPI WHERE code = 'SINPE_API')
    INSERT INTO dbo.paymentSourceAPI(code, description) VALUES ('SINPE_API', 'SINPE API');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentSourceAPI WHERE code = 'PAYPAL_API')
    INSERT INTO dbo.paymentSourceAPI(code, description) VALUES ('PAYPAL_API', 'PayPal API');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentSourceAPI WHERE code = 'INTERNAL')
    INSERT INTO dbo.paymentSourceAPI(code, description) VALUES ('INTERNAL', 'Internal Gathel process');
GO

/* =========================================================
   PAYMENT CARD TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentCardType WHERE code = 'VISA')
    INSERT INTO dbo.paymentCardType(code, description) VALUES ('VISA', 'Visa card');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentCardType WHERE code = 'MASTERCARD')
    INSERT INTO dbo.paymentCardType(code, description) VALUES ('MASTERCARD', 'Mastercard card');

IF NOT EXISTS (SELECT 1 FROM dbo.paymentCardType WHERE code = 'AMEX')
    INSERT INTO dbo.paymentCardType(code, description) VALUES ('AMEX', 'American Express card');
GO

/* =========================================================
   PAYMENT VALIDATION TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationTypes WHERE code = 'CARD_VALIDATION')
    INSERT INTO dbo.paymentValidationTypes(code, description, enabled) VALUES ('CARD_VALIDATION', 'Card validation', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationTypes WHERE code = 'SINPE_VALIDATION')
    INSERT INTO dbo.paymentValidationTypes(code, description, enabled) VALUES ('SINPE_VALIDATION', 'SINPE validation', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationTypes WHERE code = 'COUNTRY_VALIDATION')
    INSERT INTO dbo.paymentValidationTypes(code, description, enabled) VALUES ('COUNTRY_VALIDATION', 'Country validation', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationTypes WHERE code = 'FUNDS_VALIDATION')
    INSERT INTO dbo.paymentValidationTypes(code, description, enabled) VALUES ('FUNDS_VALIDATION', 'Funds validation', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationTypes WHERE code = 'PROVIDER_VALIDATION')
    INSERT INTO dbo.paymentValidationTypes(code, description, enabled) VALUES ('PROVIDER_VALIDATION', 'External provider validation', 1);
GO

/* =========================================================
   PAYMENT VALIDATION STATUS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationStatus WHERE code = 'PENDING')
    INSERT INTO dbo.paymentValidationStatus(code, description, enabled) VALUES ('PENDING', 'Validation pending', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationStatus WHERE code = 'APPROVED')
    INSERT INTO dbo.paymentValidationStatus(code, description, enabled) VALUES ('APPROVED', 'Validation approved', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationStatus WHERE code = 'REJECTED')
    INSERT INTO dbo.paymentValidationStatus(code, description, enabled) VALUES ('REJECTED', 'Validation rejected', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.paymentValidationStatus WHERE code = 'ERROR')
    INSERT INTO dbo.paymentValidationStatus(code, description, enabled) VALUES ('ERROR', 'Validation error', 1);
GO

/* =========================================================
   TRANSACTION TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'POINTS_IN')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('POINTS_IN', 'Points added to wallet', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'POINTS_OUT')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('POINTS_OUT', 'Points removed from wallet', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'MONEY_IN')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('MONEY_IN', 'Money added to wallet', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'MONEY_OUT')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('MONEY_OUT', 'Money removed from wallet', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'BET')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('BET', 'Prediction bet movement', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'REWARD')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('REWARD', 'Reward movement', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'COMMISSION')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('COMMISSION', 'Commission movement', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'PENALTY')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('PENALTY', 'Penalty movement', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.transactionTypes WHERE code = 'PRODUCT_REDEMPTION')
    INSERT INTO dbo.transactionTypes(code, description, enabled) VALUES ('PRODUCT_REDEMPTION', 'Product redemption with points', 1);
GO

/* =========================================================
   PROPOSITION STATUS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'CREATED')
    INSERT INTO dbo.propositionStatus(status) VALUES ('CREATED');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'AI_REVIEW')
    INSERT INTO dbo.propositionStatus(status) VALUES ('AI_REVIEW');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'REJECTED_BY_AI')
    INSERT INTO dbo.propositionStatus(status) VALUES ('REJECTED_BY_AI');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'VOTING')
    INSERT INTO dbo.propositionStatus(status) VALUES ('VOTING');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'SELECTED')
    INSERT INTO dbo.propositionStatus(status) VALUES ('SELECTED');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'REJECTED_BY_TARGET')
    INSERT INTO dbo.propositionStatus(status) VALUES ('REJECTED_BY_TARGET');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'ACTIVE')
    INSERT INTO dbo.propositionStatus(status) VALUES ('ACTIVE');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'CLOSED')
    INSERT INTO dbo.propositionStatus(status) VALUES ('CLOSED');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'FINISHED')
    INSERT INTO dbo.propositionStatus(status) VALUES ('FINISHED');

IF NOT EXISTS (SELECT 1 FROM dbo.propositionStatus WHERE status = 'CANCELLED')
    INSERT INTO dbo.propositionStatus(status) VALUES ('CANCELLED');
GO

/* =========================================================
   EVENT STATUS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'DRAFT')
    INSERT INTO dbo.eventStatus(status) VALUES ('DRAFT');

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'VOTING')
    INSERT INTO dbo.eventStatus(status) VALUES ('VOTING');

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'ACTIVE')
    INSERT INTO dbo.eventStatus(status) VALUES ('ACTIVE');

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'CLOSED')
    INSERT INTO dbo.eventStatus(status) VALUES ('CLOSED');

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'FINISHED')
    INSERT INTO dbo.eventStatus(status) VALUES ('FINISHED');

IF NOT EXISTS (SELECT 1 FROM dbo.eventStatus WHERE status = 'CANCELLED')
    INSERT INTO dbo.eventStatus(status) VALUES ('CANCELLED');
GO

/* =========================================================
   RESULT TYPE
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.resultType WHERE code = 'FULFILLED')
    INSERT INTO dbo.resultType(code) VALUES ('FULFILLED');

IF NOT EXISTS (SELECT 1 FROM dbo.resultType WHERE code = 'NOT_FULFILLED')
    INSERT INTO dbo.resultType(code) VALUES ('NOT_FULFILLED');

IF NOT EXISTS (SELECT 1 FROM dbo.resultType WHERE code = 'UNVERIFIABLE')
    INSERT INTO dbo.resultType(code) VALUES ('UNVERIFIABLE');

IF NOT EXISTS (SELECT 1 FROM dbo.resultType WHERE code = 'CANCELLED')
    INSERT INTO dbo.resultType(code) VALUES ('CANCELLED');
GO

/* =========================================================
   PREDICTION TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.predictionTypes WHERE code = 'WILL_HAPPEN')
    INSERT INTO dbo.predictionTypes(code) VALUES ('WILL_HAPPEN');

IF NOT EXISTS (SELECT 1 FROM dbo.predictionTypes WHERE code = 'WILL_NOT_HAPPEN')
    INSERT INTO dbo.predictionTypes(code) VALUES ('WILL_NOT_HAPPEN');
GO

/* =========================================================
   REDEMPTION STATUS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.redemptionStatus WHERE status = 'REQUESTED')
    INSERT INTO dbo.redemptionStatus(status) VALUES ('REQUESTED');

IF NOT EXISTS (SELECT 1 FROM dbo.redemptionStatus WHERE status = 'APPROVED')
    INSERT INTO dbo.redemptionStatus(status) VALUES ('APPROVED');

IF NOT EXISTS (SELECT 1 FROM dbo.redemptionStatus WHERE status = 'DELIVERED')
    INSERT INTO dbo.redemptionStatus(status) VALUES ('DELIVERED');

IF NOT EXISTS (SELECT 1 FROM dbo.redemptionStatus WHERE status = 'CANCELLED')
    INSERT INTO dbo.redemptionStatus(status) VALUES ('CANCELLED');
GO

/* =========================================================
   QUANTITY TYPES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.quantityType WHERE code = 'UNIT')
    INSERT INTO dbo.quantityType(code) VALUES ('UNIT');

IF NOT EXISTS (SELECT 1 FROM dbo.quantityType WHERE code = 'PAIR')
    INSERT INTO dbo.quantityType(code) VALUES ('PAIR');

IF NOT EXISTS (SELECT 1 FROM dbo.quantityType WHERE code = 'BOX')
    INSERT INTO dbo.quantityType(code) VALUES ('BOX');

IF NOT EXISTS (SELECT 1 FROM dbo.quantityType WHERE code = 'BOTTLE')
    INSERT INTO dbo.quantityType(code) VALUES ('BOTTLE');
GO

/* =========================================================
   UNIT MEASUREMENT
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.unitMeasurement WHERE code = 'UNIT')
    INSERT INTO dbo.unitMeasurement(code) VALUES ('UNIT');

IF NOT EXISTS (SELECT 1 FROM dbo.unitMeasurement WHERE code = 'CM')
    INSERT INTO dbo.unitMeasurement(code) VALUES ('CM');

IF NOT EXISTS (SELECT 1 FROM dbo.unitMeasurement WHERE code = 'ML')
    INSERT INTO dbo.unitMeasurement(code) VALUES ('ML');

IF NOT EXISTS (SELECT 1 FROM dbo.unitMeasurement WHERE code = 'KG')
    INSERT INTO dbo.unitMeasurement(code) VALUES ('KG');
GO

/* =========================================================
   PRODUCT CHARACTERISTICS
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.productCharacteristics WHERE name = 'Color')
    INSERT INTO dbo.productCharacteristics(name) VALUES ('Color');

IF NOT EXISTS (SELECT 1 FROM dbo.productCharacteristics WHERE name = 'Size')
    INSERT INTO dbo.productCharacteristics(name) VALUES ('Size');

IF NOT EXISTS (SELECT 1 FROM dbo.productCharacteristics WHERE name = 'Material')
    INSERT INTO dbo.productCharacteristics(name) VALUES ('Material');

IF NOT EXISTS (SELECT 1 FROM dbo.productCharacteristics WHERE name = 'Capacity')
    INSERT INTO dbo.productCharacteristics(name) VALUES ('Capacity');
GO