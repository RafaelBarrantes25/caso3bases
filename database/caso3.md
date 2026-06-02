# Preguntas:
# debe tener sinpe o cosas nacionales o con solo paypal?
# propositions debe tener history?
#
# Database engine: SQLServer

Database name: Gathel

Context:Gathel es un juego digital de predicciones basado en acciones y eventos de la vida real de las personas, validados mediante redes sociales e inteligencia artificial.

Al registrarse en la plataforma, los jugadores pueden asociar una o varias cuentas de redes sociales, por ejemplo Instagram o TikTok. Esto permite que Gathel solicite autorización para acceder automáticamente a publicaciones, historias, reels, videos y demás contenido público o autorizado por el usuario.

Cada jugador inicia con un balance inicial de 100 puntos (pts) dentro de la plataforma.

# Tables:

# ==========================
# LOG
# ==========================

## logTypes
- id (PK)
- code varchar(20) (UNIQUE)   -- USER, AI, SYSTEM, SECURITY
- description varchar(100)

## Event
eventTypes
- id (PK)
- code varchar(20) (UNIQUE) 
- description varchar(100)

## SEv
severities
- id (PK)
- code varchar(20) (UNIQUE)
- level varchar(10)

## Sources
sources
- id (PK)
- code (UNIQUE)
- description varchar(100)

## DataObjects
dataObjects
- id (PK)
- code (UNIQUE)
- description varchar(100)

## logs
logs
- id (PK)
- logTypeId (FK -> logTypes.id)
- eventTypeId (FK -> eventTypes.id)
- severityId (FK -> severities.id)
- sourceId (FK -> sources.id)
- dataObjectId (FK -> dataObjects.id)
- description varchar(100)
- objectId1 BIGINT NULL
- objectId2 BIGINT NULL
- referenceId1 BIGINT NULL
- referenceId2 BIGINT NULL
- referenceDescription varchar(100)
- userId (FK -> users.id, NULL)
- computer BYTEA
- checksum BYTEA
- postTime TIMESTAMP


# =========================
# Address Pattern (hasta estados pues es lo que se necesita)
# =========================

## COUNTRIES
countries
- id (PK)
- name varchar(60) --pais mas largo contiene 50 caracteres

## STATES
states
- id (PK)
- countryId (FK -> countries.id) 
- name varchar(100) -- estado mas largo contiene 85 caracteres

# =========================
# CURRENCIES PATTERN
# =========================

# CURRENCIES
currencies
- id (PK) 
- name varchar(20)
- symbol varchar(5)
- enabled BOOLEAN
- postTime TIMESTAMP
- userId (FK -> users.id)
- countryId (FK -> countries.id)

# EXCHANGERATES
exchangeRates
- id (PK)
- fromCurrencyId (FK -> currencies.id)
- toCurrencyId (FK -> currencies.id)
- rate DECIMAL
- date DATE
- createdAt DATE
- postTime TIMESTAMP
- userId (FK -> users.id)
- checkSum BYTEA
- iscurrent BOOLEAN

# EXCHANGEHISTORY
exchangeHistory
- id (PK)
- fromCurrencyId (FK -> currencies.id)
- toCurrencyId (FK -> currencies.id)
- rateToUsd DECIMAL
- startDateTime DATE
- endDateTime DATE
- postTime TIMESTAMP
- checkSum BYTEA
- userId (FK -> users.id)
- exchangeRateId (FK -> exchangeRates.id)
- iscurrent BOOLEAN

# =========================
# IMPUESTOS
# =========================

# Datos historicos de los paises

## taxTypes
- id (PK)
- code varchar(30) (UNIQUE)  -- VAT, IMPORT_DUTY, SALES_TAX

## countryTaxes 
- id (PK)
- countryId (FK -> countries.id)
- percentage DECIMAL NULL 
- flatflee DECIMAL NULL
- validFrom DATE
- validTo DATE
- createdAt DATE
- createdBy (FK -> users.id)
- enabled BOOLEAN
- updatedAt DATE
- updatedBy (FK -> users.id)

## taxes
- id (PK)
- taxTypeId (FK -> taxTypes.id)
- countryTaxId (FK -> countryTaxes.id)
- validFrom DATE
- validTo DATE
- createdAt DATE
- createdBy (FK -> users.id)
- enabled BOOLEAN
- updatedAt DATE
- updatedBy (FK -> users.id)


# =========================
# ESPECÍFICO DEL CASO
# =========================


## Roletype
- id PK
- code varchar(30) UNIQUE

## User
- id PK
- name varchar(20)
- lastName varchar(20)
- username varchar(30)
- email varchar(254) UNIQUE
- password VARBINARY
- enabled boolean
- checksum VARBINARY
- createdAt DATE
- updatedAt DATE
- lastLogin DATE
- roletypeid (FK -> roletype.id)
- createdBy (FK -> user.id)
- updatedBy (FK -> user.id)
- addressId (FK -> addresses.id)

## SocialMediaPerUser
- id PK
- userid (FK -> users.id)
- socialMediaid (FK- socialMedia.id)
- accountUsername varchar(40)
- accountUrl varchar(255) NULL
- accessToken varchar(255) NULL
- enabled BOOLEAN
- authorizedAt TIMESTAMP
- createdAt DATE
- checksum VARBINARY

## SocialMedia
- id PK
- description varchar(20) UNIQUE     -- Instagram, TikTok, etc.

## aiStatus                  -- La respuesta que dio la IA al revisar la evidencia
- id PK
- status varchar(20) UNIQUE

## ProcessType
- id PK
- processType varchar(30) UNIQUE

## AiProcesses                            -- Para ver si la IA acepta evidencia
- id PK
- userId (FK -> user.id)
- url varchar(256)                        -- link a la evidencia que manda el usuario de que completó el reto
- socialMediaId (FK -> socialMedia.id)    -- si viene de tiktok, instagram, etc.
- response varchar(200)                   -- comentario de la IA sobre la evidencia dada
- aiStatusId (FK -> aiStatus.id)          -- para ver si IA acepta, rechaza, inconcluso
- processTypeId (FK -> processType.id)
- requestJson NVARCHAR(MAX)
- responseJson NVARCHAR(MAX)
- createdAt DATE
- checksum VARBINARY

## Settings
- id PK
- pointsPerEvent integer      -- Para configurar los puntos que se pueden apostar
- initialPlayerPoints integer DEFAULT 100
- rejectPenaltyPercentage integer       -- penalización por aceptar el reto y después retractarse
- unverifiablePenaltyPercentage integer -- penalización si no se puede verificar el reto
- proposerEarningsPercentage integer    -- ganancias del que cumple el reto
- platformEarningsPercentage integer    -- ganancias de la plataforma
- enabled BOOLEAN
- updatedBy (FK -> users.id)
- updatedAt DATE
- successfulPredictionPercentage integer -- cuántos puntos obtienen los usuarios ganadores

## auditType
- id (PK)
- code varchar(30) (UNIQUE)              -- PAYMENT_VALIDATION, CARD_VALIDATION, SINPE_VALIDATION, COUNTRY_VALIDATION, FRAUD_CHECK
- description varchar(100)

# Justrificacion: Normalizacion
# Pregunta: Se normaliza validationStep?

## audits
audits
- id (PK)
- paymentAttemptId (FK -> paymentAttempt.id)
- auditTypeId (FK -> auditType.id)             
- validationStep varchar(50)             -- STARTED, METHOD_CHECKED, CARD_CHECKED, COUNTRY_CHECKED, FUNDS_CHECKED, PROVIDER_RESPONSE, COMPLETED
- paymentStatusesId (FK -> paymentStatuses.id)
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- validationMessage varchar(255) NULL
- externalReference varchar(100) NULL
- createdDate DATETIME2
- updateDate DATETIME2 NULL
- createdBy INT (FK -> users.id)
- checksum VARBINARY(32)

# Justificación: Documentacion

# =========================
# PAGOS, AUDITORÍA Y VALIDACIÓN DE TARJETA
# =========================

## PaymentType
paymentTypes
- id (PK)
- code varchar(20) (UNIQUE)              -- CARD, SINPE, PAYPAL, BANK_TRANSFER
- enabled BOOLEAN

# Justificación:
# Esta tabla clasifica el tipo general de pago que el usuario intenta realizar. 
# Es necesaria porque Gahel permite operaciones con dinero real, como compras de puntos, apuestas con dinero, retiros o pagos de recompensas. 
# También permite diferenciar si el pago se hizo con tarjeta, SINPE, PayPal u otro medio.

## OperationType
operationTypes
- id (PK)
- code varchar(30) (UNIQUE)              -- POINTS_PURCHASE, MONEY_DEPOSIT, MONEY_WITHDRAWAL, PREDICTION_BET, REWARD_PAYMENT
- description varchar(100)

# Justificación:
# Esta tabla indica el propósito de la operación económica. 
# No es lo mismo pagar para comprar puntos, depositar dinero, retirar ganancias o apostar en una predicción.
# Por eso esta tabla permite clasificar para qué se está usando el pago.


## PaymentStatus
paymentStatuses
- id (PK)
- code varchar(30) (UNIQUE)              -- PENDING, APPROVED, REJECTED, ERROR, INSUFFICIENT_FUNDS, CANCELLED
- description varchar(100)

# Justificación:
# Esta tabla normaliza los posibles estados de un intento de pago.
# Normalizacion.
# También facilita consultas y reportes sobre pagos aprobados, fallidos o pendientes. Y registro si sucede algun fraude o bot.


## paymentSourceAPI
paymentSourceAPI
- id (PK)
- code varchar(30) (UNIQUE)              -- CARD_PROCESSOR, SINPE_API, PAYPAL_API
- description varchar(100)

# Justificación:
# Normalizacion de los posibles APIS para metodos de pago.


## PaymentMethod
paymentMethods
- id (PK)
- paymentTypeId (FK -> paymentTypes.id) 
- source varchar(30)                     
- apiUrl varchar(256)
- configurationJson NVARCHAR(MAX)        -- Configuración del proveedor en JSON
- enabled BOOLEAN
- postTime TIMESTAMP
- userId (FK -> users.id)
- checksum VARBINARY(32)
- countryId (FK -> country.id)

# Justificación:
# Esta tabla define los métodos de pago habilitados en Gathel.
# Por ejemplo, si el pago es con tarjeta, esta tabla puede indicar si se usa VISA, Mastercard o un procesador externo.
# El campo configurationJson permite guardar configuración flexible del proveedor, como llaves públicas, ambiente sandbox, nombre del comercio, moneda por defecto o reglas de validación.
# No se deben guardar datos sensibles completos de la tarjeta aquí.

## paymentCardType
- id (PK)
- code varchar(30) (UNIQUE)              -- VISA, MASTERCARD, AMEX
- description varchar(100)

## PaymentCards
paymentCards
- id (PK)
- userId (FK -> users.id)
- cardHolderName varchar(80)
- paymentCardTypeId (FK -> paymentCardType.id)
- lastFourDigits char(4)
- expirationMonth tinyint
- expirationYear smallint
- tokenizedCard VARBINARY(MAX)           -- Token cifrado o referencia segura del proveedor
- billingCountryId (FK -> countries.id)
- enabled BOOLEAN
- createdAt DATETIME2
- updatedAt DATETIME2
- checksum VARBINARY(32)

# Justificación:
# Esta tabla registra tarjetas asociadas a un usuario, pero sin guardar el número completo de tarjeta ni el CVV.
# Se almacena únicamente información segura como últimos cuatro dígitos, marca, vencimiento y token cifrado.
# Esto permite que Gathel pueda usar tarjetas guardadas para pagos futuros sin almacenar datos sensibles completos.


## PaymentCardsPerUser
paymentCardsPerUser
- id(PK)
- userId (FK -> users.id)
- paymentCardId (FK -> paymentCards.id)

# Justificación:
# Un usuario puede tener multiples tarjetas

## paymentAttempts
paymentAttempts
- id (pk)
- paymentMethodId INT (FK -> paymentMethods.id)
- paymentCardId BIGINT (FK -> paymentCards.id, NULL)
- auditId BIGINT (FK -> audits.id)
- paymentTypeId INT (FK -> paymentTypes.id)
- operationTypeId INT (FK -> operationTypes.id)
- paymentStatusId INT (FK -> paymentStatuses.id)
- userId INT (FK -> users.id)
- sourceWalletId BIGINT (FK -> wallets.id, NULL)
- destinationWalletId BIGINT (FK -> wallets.id, NULL)
- sourceCountryId INT (FK -> countries.id, NULL)
- destinationCountryId INT (FK -> countries.id, NULL)
- currencyId INT (FK -> currencies.id)
- amount DECIMAL(18,2)
- apiUrl varchar(256) NULL
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- transactionReference varchar(100) NULL
- referenceObjectType varchar(50) NULL    -- PROPOSITION, PREDICTION, WALLET, WITHDRAWAL, PURCHASE
- referenceObjectId BIGINT NULL
- sourceObjectId BIGINT NULL
- checksum VARBINARY(32)
- computer VARBINARY(32) NULL
- createdAt DATETIME2
- postTime DATETIME2
- internal BOOLEAN

# Justificacion: Validacion que si es interna del pais o no, etc

# =========================
# Wallet
# =========================

## wallets
wallets
- id BIGINT IDENTITY(1,1) (PK)
- userId INT (FK -> users.id)
- currencyId INT (FK -> currencies.id)
- pointsBalance DECIMAL(18,2)
- moneyBalance DECIMAL(18,2)
- enabled BOOLEAN
- createdAt DATETIME2
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32)

# =========================
# VALIDACIONES DE PAGOS
# =========================

## PaymentValidationTypes
paymentValidationTypes
- id (PK)
- code varchar(30) (UNIQUE)       -- CARD_VALIDATION, SINPE_VALIDATION, COUNTRY_VALIDATION, FUNDS_VALIDATION
- description varchar(100)
- enabled BOOLEAN

# Justificación:
# Esta tabla clasifica los tipos de validación que se realizan sobre un intento de pago.
# Es necesaria porque no todos los métodos de pago se validan igual.
# Una tarjeta requiere validar token, fondos y respuesta del proveedor.
# SINPE requiere vBusinealidar que sea una operación interna o del mismo país.

## paymentValidationStatus
paymentValidationStatus
- id (PK)
- code varchar(30) (UNIQUE)       -- APPROVED, REJECTED, ERROR, PENDING
- description varchar(100)
- enabled BOOLEAN

## PaymentValidations
paymentValidations
- id (PK)
- paymentAttemptId (FK -> paymentAttempts.id)
- paymentValidationTypeId (FK -> paymentValidationTypes.id)
- paymentValidationStatusId (FK -> paymentValidationStatusId)              
- validationMessage varchar(255)
- requestJson NVARCHAR(MAX)
- responseJson NVARCHAR(MAX)
- createdAt DATE
- checksum VARBINARY(32)

# Justificación:
# Esta tabla guarda cada validación realizada sobre un intento de pago.
# Permite demostrar paso por paso por qué un pago fue aceptado o rechazado.
# Por ejemplo, en SINPE puede guardar la validación de país, moneda, usuario origen, usuario destino y resultado.

## transactionTypes
transactionTypes
- id  (PK)
- code varchar(30) (UNIQUE)              -- POINTS_IN, POINTS_OUT, MONEY_IN, MONEY_OUT, BET, REWARD, COMMISSION, PENALTY
- description varchar(100)
- createdAt DATETIME2
- createdBy INT (FK -> users.id)
- enabled BOOLEAN

# Por normalizacion

## transactions
transactions
- id (PK)
- typeId INT (FK -> transactionTypes.id)
- walletId BIGINT (FK -> wallets.id)
- paymentAttemptId BIGINT (FK -> paymentAttempts.id, NULL)
- date DATETIME2
- description varchar(100)
- amount DECIMAL(18,2)
- currencyId INT (FK -> currencies.id)
- exchangeRateId INT (FK -> exchangeRates.id, NULL)
- referenceType varchar(30) NULL          -- PREDICTION, PROPOSITION, PAYMENT, REWARD, PENALTY
- referenceId BIGINT NULL
- externalReference varchar(100) NULL
- balanceAfterPoints DECIMAL(18,2)
- balanceAfterMoney DECIMAL(18,2)
- balanceBeforePoints DECIMAL(18,2)
- balanceBeforeMoney DECIMAL(18,2)
- createdBy (FK -> users.id)
- createdAt DATETIME
- checksum VARBINARY(32)

## Business
- id PK
- businessName varchar(40)
- countryId (FK -> countries.id)
- contactEmail varchar(255)
- contactPhone varchar(20)
- enabled BOOLEAN
- createdBy (FK -> users.id)
- createdAt DATETIME
- updatedAt DATETIME
- updatedBy (FK -> users.id)
- checksum VARBINARY(32)


## quantityType
- id (PK)
- code varchar(20) (UNIQUE) -- bottles, pair

## unitMeasurement
- id (PK)
- code varchar(20) (UNIQUE) -- cm, dl, om

# Catalogo de caracteristicas variables que puede tener un producto.
# Ejemplo: color, material, tamaño, capacidad, RAM, CPU

## productCharacteristics
- id (PK)
- name varchar(60)


## RedeemableProducts
- id PK
- businessId (FK -> business.id)
- productName varchar(100)
- description varchar(255)
- stock integer
- unitMeasurementId (FK -> unitMeasurement.id)
- quantityTypeId (FK -> quanityType.id)
- checksum VARBINARY
- createdAt DATE
- createdBy (FK -> users.id)
- enabled BOOLEAN
- updatedAt DATE
- updatedBy (FK -> users.id)
- currencyId (FK -> currencies.id)
- amount float

## RedemptionStatus
- id PK
- status varchar(30) UNIQUE

## ProductRedemption
- id PK
- userId (FK -> users.id)
- redeemableProductsId (FK -> redeemableProducts.id)
- currencyId (FK -> currrencies.id)
- amountSpent NUMERIC
- redeemedAt DATETIME
- checksum VARBINARY
- transactionId (FK -> transactions.id)
- redemptionStatusId (FK -> redemptionStatus.id)

# Relacion entre el producto y sus caracteristicas variables.
# Ejemplo: Laptop -> RAM = 16GB

## productCharacteristicPerProduct
- id (PK)
- redeemableProductId (FK -> redeemableProduct.id)
- productCharacteristicId (FK -> productCharacteristics.id)
- value varchar(100)

# =========================
# Proposiciones, predicciones y eventos
# =========================

## EventStatus                        -- Si está en revisión, ejecutándose, en votación...
- id PK
- status varchar(30) UNIQUE

## Events
- id PK
- eventName varchar(50)
- creatorUser (FK -> users.id)
- eventStatus (FK -> eventStatus.id)
- description varchar(200)
- createdAt DATE

## PropositionStatus
- id PK
- status varchar(30) UNIQUE

## Propositions
- id PK
- title varchar(100)
- description varchar(200)
- numberOfVotes integer
- proposedBy (FK -> user.id)
- proposedTo (FK -> user.id)
- propositionStatusid (FK -> propositionStatus.id)
- currencyId (FK -> currency.id)
- createdAt DATE
- votingStarts TIMESTAMP
- votingClosesAt TIMESTAMP
- acceptedAt DATE
- rejectedAt DATE
- enabled BOOLEAN
- checksum VARBINARY

## PropositionsPerEvent
- id PK
- eventId (FK -> events.id)
- propositionId (FK -> propositions.id)

## PropositionVotes
- id PK
- userId (FK -> users.id)
- propositionsId (FK -> propositions.id)
- checksum VARBINARY
- votedAt TIMESTAMP

## ResultType
- id PK
- code varchar(30) UNIQUE

## PropositionResult
- id PK
- resultTypeId (FK -> resultType.id)
- aiProcessId (FK -> aiProcess.id)
- propositionId (FK -> propositions.id)
- resultAt DATE
- checksum VARBINARY

## PredictionType
- id PK
- code varchar(40) UNIQUE

## Predictions                     -- no hay predictionsPerUser porque cada usuario solo tiene una predicción por proposición
- id PK
- predictionTypesId (FK -> predictionTypes.id)
- predictedBy (FK -> users.id)
- propositionId (FK -> proposition.id)
- currencyId (FK -> currencies.id)
- amount float
- winnerAmount float                     -- cuánto ganó el que hizo al predicción
- createdAt DATE
- enabled BOOLEAN
- winner BOOLEAN
- checksum VARBINARY