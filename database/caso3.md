# Preguntas pendientes

# ¿Debe tener SINPE o cosas nacionales o con solo PayPal?

Se recomienda mantener soporte para varios métodos de pago, pero sin almacenar información sensible de tarjetas.
El sistema puede soportar SINPE, PayPal, tarjeta mediante procesador externo y balance interno, pero Gathel solo registra el intento de pago y la respuesta del proveedor.

# ¿Propositions debe tener history?

Sí. Se recomienda agregar una tabla `propositionStatusHistory` para registrar los cambios de estado de cada proposición.
Esto permite demostrar cómo una proposición pasó por revisión de IA, votación, aceptación, ejecución, validación o cancelación.

# Database engine: SQLServer

# Database name: Gathel

# Contexto

Gathel es un juego digital de predicciones basado en acciones y eventos de la vida real de las personas, validados mediante redes sociales e inteligencia artificial.

Al registrarse en la plataforma, los jugadores pueden asociar una o varias cuentas de redes sociales, por ejemplo Instagram, TikTok u otras plataformas. Esto permite que Gathel solicite autorización para acceder automáticamente a publicaciones, historias, reels, videos y demás contenido público o autorizado por el usuario.

Cada jugador inicia con un balance inicial de 100 puntos dentro de la plataforma.

Los puntos no se manejan como una columna separada, sino como una moneda virtual dentro de la tabla `currencies`. De esta forma, los puntos y el dinero real se administran mediante el mismo modelo de billeteras y transacciones.

Cuando un usuario intenta hacer un pago, primero se registra el intento en `paymentAttempts`. Si el pago es aprobado, se genera una transacción en `transactions`. Si el pago falla, queda registrado el intento, pero no se modifica el balance del usuario.

La inteligencia artificial se usa para revisar proposiciones, validar contenido ético, analizar evidencia de redes sociales y determinar si una proposición se cumplió o no. Por eso, el modelo guarda proveedor, modelo, request, response, resultado y objeto sobre el cual se aplicó el análisis.

---

# Tables

# ==========================

# LOG

# ==========================

## logTypes

```text
logTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- USER, AI, SYSTEM, SECURITY, PAYMENT
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:
# Esta tabla clasifica el origen general del log.
# Permite separar eventos generados por usuarios, procesos de IA, sistema, seguridad o pagos.

---

## eventTypes

```text
eventTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- LOGIN, LOGOUT, INSERT, UPDATE, DELETE, PAYMENT_ATTEMPT, AI_REVIEW, TRANSACTION_CREATED
- description VARCHAR(120) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:
# Esta tabla normaliza los tipos de eventos que pueden quedar registrados en la bitácora.
# No se debe confundir con la tabla Events anterior, porque aquí "event" significa evento de log, no evento de negocio.

---

## severities

```text
severities
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- INFO, WARNING, ERROR, CRITICAL
- level VARCHAR(10) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:
# Permite clasificar la gravedad de cada registro de log.

---

## sources

```text
sources
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- FRONTEND, BACKEND, DATABASE, AI_PROVIDER, PAYMENT_PROVIDER, SOCIAL_MEDIA
- description VARCHAR(120) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:
# Permite saber desde dónde se generó un evento.
# Ejemplo: frontend, backend, base de datos, proveedor de IA, proveedor de pago o red social.

---

## dataObjects

```text
dataObjects
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- USERS, PROPOSITIONS, PREDICTIONS, PAYMENT_ATTEMPTS, TRANSACTIONS, AI_PROCESS_LOGS
- description VARCHAR(120) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:
# Permite saber sobre qué objeto del sistema se generó el log.

---

## logs

```text
logs
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- logTypeId INT NOT NULL FOREIGN KEY REFERENCES logTypes(id)
- eventTypeId INT NOT NULL FOREIGN KEY REFERENCES eventTypes(id)
- severityId INT NOT NULL FOREIGN KEY REFERENCES severities(id)
- sourceId INT NOT NULL FOREIGN KEY REFERENCES sources(id)
- dataObjectId INT NULL FOREIGN KEY REFERENCES dataObjects(id)
- description VARCHAR(255) NOT NULL
- objectId1 BIGINT NULL
- objectId2 BIGINT NULL
- referenceId1 BIGINT NULL
- referenceId2 BIGINT NULL
- referenceDescription VARCHAR(150) NULL
- userId INT NULL FOREIGN KEY REFERENCES users(id)
- computer VARBINARY(32) NULL
- checksum VARBINARY(32) NOT NULL
- postTime DATETIME2 NOT NULL
```

# Justificación:

# Tabla central de bitácora.
# Permite registrar operaciones relevantes del sistema sin crear una tabla de log distinta para cada módulo.
# Se puede usar para auditoría de usuarios, pagos, IA, seguridad y operaciones de base de datos.

---

# ==========================
# ADDRESS / GEO PATTERN
# ==========================

## countries

```text
countries
- id INT IDENTITY(1,1) PRIMARY KEY
- name VARCHAR(60) NOT NULL
- isoCode CHAR(2) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Tabla de países.
# El campo `isoCode` permite usar códigos como CR, US, MX, etc.

---

## states

```text
states
- id INT IDENTITY(1,1) PRIMARY KEY
- countryId INT NOT NULL FOREIGN KEY REFERENCES countries(id)
- name VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Representa provincias, estados o regiones dentro de un país.

---

## cities

```text
cities
- id INT IDENTITY(1,1) PRIMARY KEY
- stateId INT NOT NULL FOREIGN KEY REFERENCES states(id)
- name VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Se agrega porque el diseño anterior tenía países y estados, pero faltaba el nivel de ciudad.

---

## addresses

```text
addresses
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- cityId INT NOT NULL FOREIGN KEY REFERENCES cities(id)
- addressLine1 VARCHAR(150) NOT NULL
- addressLine2 VARCHAR(150) NULL
- postalCode VARCHAR(20) NULL
- latitude DECIMAL(9,6) NULL
- longitude DECIMAL(9,6) NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Se agrega la tabla `addresses` porque el diseño anterior tenía referencias a `addressId`, pero no estaba definida.
# También se agregan latitud y longitud de forma opcional para soportar geolocalización sin obligar a todos los registros a tener coordenadas exactas.

---

# ==========================
# CURRENCIES PATTERN
# ==========================

## currencyTypes

```text
currencyTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- FIAT, VIRTUAL
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Permite diferenciar monedas reales de monedas virtuales.
# Los puntos de Gathel se modelan como una moneda virtual.

---

## currencies

```text
currencies
- id INT IDENTITY(1,1) PRIMARY KEY
- currencyTypeId INT NOT NULL FOREIGN KEY REFERENCES currencyTypes(id)
- code VARCHAR(10) NOT NULL UNIQUE        -- USD, CRC, EUR, PTS
- name VARCHAR(40) NOT NULL
- symbol VARCHAR(10) NOT NULL
- countryId INT NULL FOREIGN KEY REFERENCES countries(id)
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Los puntos se unifican con el dinero mediante esta tabla.

# En lugar de tener `pointsBalance` y `moneyBalance`, cada usuario tiene una billetera por moneda.

# Ejemplo:

# - CRC para colones

# - USD para dólares

# - PTS para puntos de Gathel

---

## exchangeRates

```text
exchangeRates
- id INT IDENTITY(1,1) PRIMARY KEY
- fromCurrencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- toCurrencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- rate DECIMAL(18,6) NOT NULL
- rateDate DATE NOT NULL
- createdAt DATETIME2 NOT NULL
- postTime DATETIME2 NOT NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- checksum VARBINARY(32) NOT NULL
- isCurrent BIT NOT NULL
```

# Justificación:

# Registra el tipo de cambio entre monedas.

# Se usa cuando una transacción necesita conversión entre monedas.

---

## exchangeHistory

```text
exchangeHistory
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- fromCurrencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- toCurrencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- rate DECIMAL(18,6) NOT NULL
- startDateTime DATETIME2 NOT NULL
- endDateTime DATETIME2 NULL
- postTime DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
- userId INT NULL FOREIGN KEY REFERENCES users(id)
- exchangeRateId INT NOT NULL FOREIGN KEY REFERENCES exchangeRates(id)
- isCurrent BIT NOT NULL
```

# Justificación:

# Guarda el historial de cambios en tasas de cambio.

# Permite saber qué tasa estaba vigente en un momento determinado.

---

# ==========================

# IMPUESTOS

# ==========================

## taxTypes

```text
taxTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- VAT, SALES_TAX, WITHDRAWAL_TAX, SERVICE_FEE
- name VARCHAR(80) NOT NULL
- description VARCHAR(150) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza los tipos de impuestos o cargos.

# Ejemplo: IVA, impuesto de ventas, cargo por retiro o comisión de servicio.

---

## countryTaxes

```text
countryTaxes
- id INT IDENTITY(1,1) PRIMARY KEY
- countryId INT NOT NULL FOREIGN KEY REFERENCES countries(id)
- taxTypeId INT NOT NULL FOREIGN KEY REFERENCES taxTypes(id)
- name VARCHAR(80) NOT NULL
- percentage DECIMAL(9,4) NULL
- flatFee DECIMAL(18,2) NULL
- currencyId INT NULL FOREIGN KEY REFERENCES currencies(id)
- validFrom DATE NOT NULL
- validTo DATE NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- updatedAt DATETIME2 NULL
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Se elimina la estructura anterior separada entre `taxes` y `countryTaxes`, porque generaba una cardinalidad confusa.

# Ahora cada impuesto por país tiene tipo, nombre, porcentaje o monto fijo, moneda y vigencia.

# Esto permite saber claramente el nombre del impuesto y dónde aplica.

---

# ==========================

# USERS / ROLES

# ==========================

## roleTypes

```text
roleTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- ADMIN, PLAYER, BUSINESS, SUPPORT, READONLY
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Define los tipos principales de usuario dentro de Gathel.

---

## users

```text
users
- id INT IDENTITY(1,1) PRIMARY KEY
- name VARCHAR(40) NOT NULL
- lastName VARCHAR(40) NOT NULL
- username VARCHAR(40) NOT NULL UNIQUE
- email VARCHAR(254) NOT NULL UNIQUE
- password VARBINARY(256) NOT NULL
- enabled BIT NOT NULL
- checksum VARBINARY(32) NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- lastLogin DATETIME2 NULL
- roleTypeId INT NOT NULL FOREIGN KEY REFERENCES roleTypes(id)
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
- addressId BIGINT NULL FOREIGN KEY REFERENCES addresses(id)
```

# Justificación:

# Tabla principal de usuarios.

# La contraseña se almacena como dato binario cifrado o hasheado, no como texto plano.

# `addressId` es opcional porque no todos los usuarios necesitan registrar dirección.

---

# ==========================

# SOCIAL MEDIA

# ==========================

## socialMedia

```text
socialMedia
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- INSTAGRAM, TIKTOK, X, FACEBOOK, YOUTUBE
- name VARCHAR(50) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Catálogo de redes sociales soportadas por Gathel.

---

## socialMediaAccounts

```text
socialMediaAccounts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- socialMediaId INT NOT NULL FOREIGN KEY REFERENCES socialMedia(id)
- accountUsername VARCHAR(80) NOT NULL
- accountUrl VARCHAR(255) NULL
- externalAccountId VARCHAR(120) NULL
- accessToken VARBINARY(MAX) NULL
- refreshToken VARBINARY(MAX) NULL
- authorizedAt DATETIME2 NULL
- tokenExpiresAt DATETIME2 NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Representa las cuentas de redes sociales asociadas por un usuario.

# Los tokens se guardan como binarios cifrados o referencias seguras, no como texto plano.

# Esta tabla reemplaza y mejora `SocialMediaPerUser`.

---
## socialMediaPostsTypes

```text
socialMediaPostsTypes
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- POST, STORY, REEL, VIDEO, COMMENT
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificacion
# Normalizacion

---

## socialMediaPosts

```text
socialMediaPosts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- socialMediaAccountId BIGINT NOT NULL FOREIGN KEY REFERENCES socialMediaAccounts(id)
- externalPostId VARCHAR(120) NULL
- postUrl VARCHAR(500) NOT NULL
- postTypeId BIGINT NOT NULL FOREIGN KEY REFERENCES socialMediaPostsTypes(id)
- caption NVARCHAR(500) NULL
- postedAt DATETIME2 NULL
- capturedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Guarda las publicaciones, historias, reels, videos o comentarios que originan proposiciones o sirven como evidencia.

# Esto permite mapear exactamente cuál publicación de red social está relacionada con una proposición.

---
## propositionSourcePostsUse

```text
propositionSourcePostUse
- id BIGINT IDENTITY(1,1) PRIMARY KEY   -- ORIGIN, EVIDENCE, RESULT_VALIDATION
- code VARCHAR(30) NOT NULL UNIQUE        
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

---
## propositionSourcePosts

```text
propositionSourcePosts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- socialMediaPostId BIGINT NOT NULL FOREIGN KEY REFERENCES socialMediaPosts(id)
- sourceUseId BIGINT NOT NULL FOREIGN KEY REFERENCES propositionSourcePostUse(id)
- createdAt DATETIME2 NOT NULL

UNIQUE(propositionId, socialMediaPostId, sourceUse)
```

# Justificación:

# Relaciona una proposición con las publicaciones que la originaron o que sirvieron como evidencia.

# Es necesaria porque Gathel depende de contenido de redes sociales para crear y validar proposiciones.

---

# ==========================

# AI PROCESS LOGS

# ==========================

## aiProviders

```text
aiProviders
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- OPENAI, GEMINI, CLAUDE, LOCAL_MODEL
- name VARCHAR(80) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Catálogo de proveedores de inteligencia artificial.

---

## aiModels

```text
aiModels
- id INT IDENTITY(1,1) PRIMARY KEY
- aiProviderId INT NOT NULL FOREIGN KEY REFERENCES aiProviders(id)
- modelName VARCHAR(100) NOT NULL
- version VARCHAR(50) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Permite registrar qué modelo específico se usó para una revisión.

# Ejemplo: proveedor OpenAI, Gemini o Claude, con su respectivo modelo.

---

## aiProcessTypes

```text
aiProcessTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(60) NOT NULL UNIQUE        -- PROPOSITION_CREATION_REVIEW, ETHICAL_REVIEW, RESULT_VALIDATION, FRAUD_REVIEW
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Define para qué se usó la IA.

# Puede ser para crear proposiciones, revisar contenido antiético, validar resultados o detectar fraude.

---

## aiResults

```text
aiResults
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- APPROVED, REJECTED, INCONCLUSIVE, NEEDS_MORE_EVIDENCE, ERROR
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza los posibles resultados de una revisión de IA.

---

## aiProcessLogs

```text
aiProcessLogs
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- aiModelId INT NOT NULL FOREIGN KEY REFERENCES aiModels(id)
- aiProcessTypeId INT NOT NULL FOREIGN KEY REFERENCES aiProcessTypes(id)
- aiResultId INT NOT NULL FOREIGN KEY REFERENCES aiResults(id)
- userId INT NULL FOREIGN KEY REFERENCES users(id)
- propositionId BIGINT NULL FOREIGN KEY REFERENCES propositions(id)
- socialMediaPostId BIGINT NULL FOREIGN KEY REFERENCES socialMediaPosts(id)
- appliedObjectType VARCHAR(50) NOT NULL  -- PROPOSITION, SOCIAL_POST, RESULT, PAYMENT_ATTEMPT
- appliedObjectId BIGINT NOT NULL
- prompt NVARCHAR(MAX) NULL
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- responseSummary VARCHAR(500) NULL
- confidence DECIMAL(5,4) NULL
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Tabla central para registrar ejecuciones de IA.

# Guarda proveedor, modelo, tipo de proceso, request, response, resultado y objeto donde se aplicó.

# Esto permite auditar decisiones de IA y explicar qué modelo aprobó, rechazó o dejó inconclusa una proposición o evidencia.

---

# ==========================

# SETTINGS

# ==========================

## settingsTypes
```text
settingsTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- INITIAL_PLAYER_POINTS, REJECT_PENALTY_PERCENTAGE, PLATFORM_EARNINGS_PERCENTAGE
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificacion
# Normalizacion

---

## settings

```text
settings
- id INT IDENTITY(1,1) PRIMARY KEY
- settingKey INT NOT NULL FOREIGN KET REFERENCES settingsTypes(Id)
- settingValue VARCHAR(255) NOT NULL
- valueType VARCHAR(20) NOT NULL          -- INT, DECIMAL, STRING, BOOLEAN
- description VARCHAR(200) NULL
- enabled BIT NOT NULL
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
- updatedAt DATETIME2 NOT NULL
```

# Justificación:

# Se usa una tabla flexible de configuración en vez de columnas fijas.

# Esto permite agregar nuevas reglas del juego sin modificar la estructura física de la tabla.

# Ejemplo:

# - INITIAL_PLAYER_POINTS = 100

# - UNVERIFIABLE_PENALTY_PERCENTAGE = 15

# - PLATFORM_EARNINGS_PERCENTAGE = 5

---

# ==========================

# PAYMENT METHODS, ATTEMPTS AND VALIDATIONS

# ==========================

## paymentTypes

```text
paymentTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- CARD, SINPE, PAYPAL, BANK_TRANSFER, INTERNAL_BALANCE
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Clasifica el tipo general de pago.

# No significa que Gathel guarde tarjetas, solo que puede procesar pagos mediante proveedores externos.

---

## paymentProviders

```text
paymentProviders
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- PAYPAL_API, SINPE_API, CARD_PROCESSOR, INTERNAL_ENGINE
- name VARCHAR(80) NOT NULL
- baseUrl VARCHAR(256) NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
```

# Justificación:

# Define el proveedor externo o interno que procesa el pago.

# Permite diferenciar entre PayPal, SINPE, procesador de tarjeta o motor interno.

---

## paymentMethods

```text
paymentMethods
- id INT IDENTITY(1,1) PRIMARY KEY
- paymentTypeId INT NOT NULL FOREIGN KEY REFERENCES paymentTypes(id)
- paymentProviderId INT NOT NULL FOREIGN KEY REFERENCES paymentProviders(id)
- countryId INT NULL FOREIGN KEY REFERENCES countries(id)
- name VARCHAR(80) NOT NULL
- configurationJson NVARCHAR(MAX) NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Define los métodos de pago habilitados en Gathel.

# Aquí se guarda configuración general del método, no información de tarjetas ni datos sensibles del usuario.

# Ejemplo: PayPal Costa Rica, SINPE Costa Rica, procesador de tarjetas sandbox.

---

## operationTypes

```text
operationTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- POINTS_PURCHASE, MONEY_DEPOSIT, MONEY_WITHDRAWAL, PREDICTION_BET, REWARD_PAYMENT, COMMISSION_PAYMENT, PENALTY
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Indica el propósito económico de la operación.

# No es lo mismo comprar puntos, retirar dinero, apostar, pagar recompensa o aplicar una penalización.

---

## paymentStatuses

```text
paymentStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- PENDING, APPROVED, REJECTED, ERROR, CANCELLED, INSUFFICIENT_FUNDS
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza los posibles estados de un intento de pago.

---

## paymentAttempts

```text
paymentAttempts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- paymentMethodId INT NOT NULL FOREIGN KEY REFERENCES paymentMethods(id)
- operationTypeId INT NOT NULL FOREIGN KEY REFERENCES operationTypes(id)
- paymentStatusId INT NOT NULL FOREIGN KEY REFERENCES paymentStatuses(id)
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- amount DECIMAL(18,2) NOT NULL
- referenceObjectType VARCHAR(50) NULL    -- PROPOSITION, PREDICTION, WALLET, WITHDRAWAL, PURCHASE, REWARD
- referenceObjectId BIGINT NULL
- providerReference VARCHAR(120) NULL
- transactionReference VARCHAR(120) NULL
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- resultMessage VARCHAR(255) NULL
- errorCode VARCHAR(60) NULL
- createdAt DATETIME2 NOT NULL
- completedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Esta tabla representa únicamente el intento de procesar un pago.

# No debe mezclar datos propios de `paymentMethods`.

# No debe asumir que siempre hay tarjeta.

# No debe asumir que siempre hay billetera origen o destino.

# Si el pago es aprobado, entonces se crea una o varias transacciones.

# Si el pago falla, el intento queda registrado, pero no modifica balances.

---

## paymentValidationTypes

```text
paymentValidationTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- METHOD_CHECK, COUNTRY_CHECK, FUNDS_CHECK, PROVIDER_RESPONSE, FRAUD_CHECK
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Clasifica los pasos de validación realizados sobre un intento de pago.

---

## paymentValidationStatuses

```text
paymentValidationStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- PENDING, APPROVED, REJECTED, ERROR
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza los estados de cada validación individual de pago.

---

## paymentAttemptValidations

```text
paymentAttemptValidations
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- paymentAttemptId BIGINT NOT NULL FOREIGN KEY REFERENCES paymentAttempts(id)
- paymentValidationTypeId INT NOT NULL FOREIGN KEY REFERENCES paymentValidationTypes(id)
- paymentValidationStatusId INT NOT NULL FOREIGN KEY REFERENCES paymentValidationStatuses(id)
- validationOrder INT NOT NULL
- validationMessage VARCHAR(255) NULL
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- externalReference VARCHAR(120) NULL
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Reemplaza la tabla `audits`.

# Esta tabla es más específica porque registra las validaciones realizadas sobre un intento de pago.

# Permite demostrar paso a paso por qué un pago fue aprobado, rechazado o falló.

---

# ==========================

# WALLETS AND TRANSACTIONS

# ==========================

## wallets

```text
wallets
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- balance DECIMAL(18,2) NOT NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL

UNIQUE(userId, currencyId)
```

# Justificación:

# Un usuario puede tener una billetera por moneda.

# Los puntos son una moneda virtual, por lo que no se necesita separar `pointsBalance` y `moneyBalance`.

# Ejemplo:

# - Usuario 1, PTS, balance 100

# - Usuario 1, USD, balance 25

# - Usuario 1, CRC, balance 5000

---

## transactionTypes

```text
transactionTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- BALANCE_IN, BALANCE_OUT, BET, REWARD, COMMISSION, PENALTY, REDEMPTION
- description VARCHAR(150) NOT NULL
- createdAt DATETIME2 NOT NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- enabled BIT NOT NULL
```

# Justificación:

# Clasifica los movimientos de saldo.

# Se usa tanto para puntos como para dinero real.

---

## transactions

```text
transactions
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- transactionTypeId INT NOT NULL FOREIGN KEY REFERENCES transactionTypes(id)
- walletId BIGINT NOT NULL FOREIGN KEY REFERENCES wallets(id)
- paymentAttemptId BIGINT NULL FOREIGN KEY REFERENCES paymentAttempts(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- exchangeRateId INT NULL FOREIGN KEY REFERENCES exchangeRates(id)
- amount DECIMAL(18,2) NOT NULL
- balanceBefore DECIMAL(18,2) NOT NULL
- balanceAfter DECIMAL(18,2) NOT NULL
- referenceType VARCHAR(40) NULL          -- PREDICTION, PROPOSITION, PAYMENT, REWARD, PENALTY, REDEMPTION
- referenceId BIGINT NULL
- externalReference VARCHAR(120) NULL
- description VARCHAR(150) NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Registra movimientos reales sobre una billetera.

# Solo debe generarse cuando hay un cambio de balance.

# Si proviene de un pago externo exitoso, se relaciona con `paymentAttempts`.

---

# ==========================

# BUSINESS AND REDEEMABLE PRODUCTS

# ==========================

## businesses

```text
businesses
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- businessName VARCHAR(80) NOT NULL
- countryId INT NOT NULL FOREIGN KEY REFERENCES countries(id)
- addressId BIGINT NULL FOREIGN KEY REFERENCES addresses(id)
- contactEmail VARCHAR(255) NULL
- contactPhone VARCHAR(20) NULL
- enabled BIT NOT NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Representa empresas externas que pueden aceptar puntos de Gathel o participar en canjes.

---

## quantityTypes

```text
quantityTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- UNIT, BOTTLE, PAIR, PACKAGE
- description VARCHAR(100) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza el tipo de cantidad de un producto canjeable.

---

## unitMeasurements

```text
unitMeasurements
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- CM, ML, KG, UNIT
- description VARCHAR(100) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza unidades de medida.

---

## productCharacteristics

```text
productCharacteristics
- id INT IDENTITY(1,1) PRIMARY KEY
- name VARCHAR(60) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Catálogo de características variables que puede tener un producto.

# Ejemplo: color, material, tamaño, capacidad, RAM, CPU.

---

## redeemableProducts

```text
redeemableProducts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- businessId BIGINT NOT NULL FOREIGN KEY REFERENCES businesses(id)
- productName VARCHAR(100) NOT NULL
- description VARCHAR(255) NULL
- stock INT NOT NULL
- unitMeasurementId INT NULL FOREIGN KEY REFERENCES unitMeasurements(id)
- quantityTypeId INT NULL FOREIGN KEY REFERENCES quantityTypes(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- amount DECIMAL(18,2) NOT NULL
- checksum VARBINARY(32) NOT NULL
- createdAt DATETIME2 NOT NULL
- createdBy INT NULL FOREIGN KEY REFERENCES users(id)
- enabled BIT NOT NULL
- updatedAt DATETIME2 NULL
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
```

# Justificación:

# Productos que pueden ser canjeados con dinero o puntos de Gathel.

# El precio se maneja con `currencyId`, por lo que puede cobrarse en PTS, USD, CRC, etc.

---

## redemptionStatuses

```text
redemptionStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- status VARCHAR(30) NOT NULL UNIQUE      -- PENDING, APPROVED, REJECTED, DELIVERED, CANCELLED
- description VARCHAR(100) NULL
- enabled BIT NOT NULL
```

# Justificación:

# Estados posibles de un canje.

---

## productRedemptions

```text
productRedemptions
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- redeemableProductId BIGINT NOT NULL FOREIGN KEY REFERENCES redeemableProducts(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- amountSpent DECIMAL(18,2) NOT NULL
- redeemedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
- transactionId BIGINT NULL FOREIGN KEY REFERENCES transactions(id)
- redemptionStatusId INT NOT NULL FOREIGN KEY REFERENCES redemptionStatuses(id)
```

# Justificación:

# Registra el canje de productos por parte de los usuarios.

# Si el canje afecta balance, debe relacionarse con una transacción.

---

## productCharacteristicPerProduct

```text
productCharacteristicPerProduct
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- redeemableProductId BIGINT NOT NULL FOREIGN KEY REFERENCES redeemableProducts(id)
- productCharacteristicId INT NOT NULL FOREIGN KEY REFERENCES productCharacteristics(id)
- value VARCHAR(100) NOT NULL

UNIQUE(redeemableProductId, productCharacteristicId)
```

# Justificación:

# Relaciona productos canjeables con características variables.

# Ejemplo:

# Laptop -> RAM = 16GB

# Botella -> Capacidad = 500ml

---

# ==========================

# PROPOSITIONS, PREDICTIONS AND RESULTS

# ==========================

## propositionStatuses

```text
propositionStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- PROPOSED, UNDER_AI_REVIEW, VOTING, SELECTED, ACCEPTED, REJECTED, ACTIVE, COMPLETED, CANCELLED, UNVERIFIABLE
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza el ciclo de vida de una proposición.

# La proposición es la entidad central del flujo de Gathel.

---

## propositions

```text
propositions
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- title VARCHAR(120) NOT NULL
- description VARCHAR(500) NOT NULL
- proposedBy INT NOT NULL FOREIGN KEY REFERENCES users(id)
- proposedTo INT NOT NULL FOREIGN KEY REFERENCES users(id)
- propositionStatusId INT NOT NULL FOREIGN KEY REFERENCES propositionStatuses(id)
- selectedVoteId BIGINT NULL
- votingStartsAt DATETIME2 NULL
- votingClosesAt DATETIME2 NULL
- acceptedAt DATETIME2 NULL
- rejectedAt DATETIME2 NULL
- challengeStartsAt DATETIME2 NULL
- challengeEndsAt DATETIME2 NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Representa una proposición hecha por un usuario hacia sí mismo o hacia otro jugador.

# Se elimina la dependencia con `Events`, porque la proposición ya contiene el flujo de votación, aceptación, ejecución y validación.

---

## propositionStatusHistory

```text
propositionStatusHistory
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- oldStatusId INT NULL FOREIGN KEY REFERENCES propositionStatuses(id)
- newStatusId INT NOT NULL FOREIGN KEY REFERENCES propositionStatuses(id)
- changedBy INT NULL FOREIGN KEY REFERENCES users(id)
- changeReason VARCHAR(255) NULL
- changedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Registra el historial de cambios de estado de una proposición.

# Permite explicar cómo una proposición pasó por revisión de IA, votación, aceptación, ejecución, cierre o anulación.

---

## propositionVotes

```text
propositionVotes
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- votedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL

UNIQUE(userId, propositionId)
```

# Justificación:

# Registra los votos de los usuarios sobre proposiciones.

# La restricción UNIQUE evita que un usuario vote más de una vez por la misma proposición.

---

## resultTypes

```text
resultTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- COMPLETED, NOT_COMPLETED, UNVERIFIABLE, CANCELLED
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Normaliza los posibles resultados finales de una proposición.

---

## propositionResults

```text
propositionResults
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- resultTypeId INT NOT NULL FOREIGN KEY REFERENCES resultTypes(id)
- aiProcessLogId BIGINT NULL FOREIGN KEY REFERENCES aiProcessLogs(id)
- resultAt DATETIME2 NOT NULL
- resultDescription VARCHAR(255) NULL
- checksum VARBINARY(32) NOT NULL
```

# Justificación:

# Registra el resultado final de una proposición.

# Puede vincularse al análisis de IA que validó si la proposición se cumplió o no.

---

## predictionTypes

```text
predictionTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- WILL_HAPPEN, WILL_NOT_HAPPEN
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

# Justificación:

# Define los tipos de predicción posibles.

---

## predictions

```text
predictions
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- predictionTypeId INT NOT NULL FOREIGN KEY REFERENCES predictionTypes(id)
- predictedBy INT NOT NULL FOREIGN KEY REFERENCES users(id)
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- walletId BIGINT NOT NULL FOREIGN KEY REFERENCES wallets(id)
- betTransactionId BIGINT NULL FOREIGN KEY REFERENCES transactions(id)
- rewardTransactionId BIGINT NULL FOREIGN KEY REFERENCES transactions(id)
- amount DECIMAL(18,2) NOT NULL
- winnerAmount DECIMAL(18,2) NULL
- winner BIT NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL

UNIQUE(predictedBy, propositionId)
```

# Justificación:

# Cada usuario solo puede hacer una predicción por proposición.

# La predicción se asocia a una billetera porque puede hacerse con puntos o dinero.

# Si la predicción genera apuesta o recompensa, se relaciona con transacciones.

---

# ==========================

# TABLAS ELIMINADAS DEL DISEÑO ANTERIOR

# ==========================

## Tablas eliminadas

```text
events
eventStatus
propositionsPerEvent
paymentCards
paymentCardsPerUser
paymentCardType
audits
auditType
taxes
```

# Justificación general:

# `events`, `eventStatus` y `propositionsPerEvent` se eliminan porque no aportaban al flujo principal.

# La proposición ya representa la unidad central del juego.

#

# `paymentCards`, `paymentCardsPerUser` y `paymentCardType` se eliminan porque Gathel no debe guardar tarjetas.

# Guardar tarjetas implica riesgos de seguridad y estándares que están fuera del alcance del proyecto.

#

# `audits` y `auditType` se reemplazan por `paymentAttemptValidations`, que es más específico y depende directamente del intento de pago.

#

# `taxes` se elimina porque generaba confusión con `countryTaxes`.

# Ahora `countryTaxes` contiene el país, tipo de impuesto, nombre, porcentaje o monto fijo y vigencia.

---

# ==========================

# REGLAS GENERALES DEL DISEÑO

# ==========================

# 1. Puntos y dinero

# Los puntos de Gathel son una moneda virtual llamada PTS.

# Por eso no se usa `pointsBalance` y `moneyBalance`.

# Todo saldo se guarda en `wallets.balance`.

# 2. Pagos

# Un pago primero se registra en `paymentAttempts`.

# Si el intento es aprobado, se genera una transacción.

# Si el intento falla, no se modifica ningún balance.

# 3. Tarjetas

# Gathel no almacena tarjetas.

# Solo registra el proveedor, el intento de pago, request, response y resultado.

# 4. IA

# Toda revisión de IA debe quedar registrada en `aiProcessLogs`.

# Debe saberse proveedor, modelo, tipo de proceso, request, response, resultado y objeto donde se aplicó.

# 5. Redes sociales

# No basta con saber que un usuario tiene Instagram o TikTok.

# También se debe guardar qué publicación originó la proposición o cuál sirvió como evidencia.

# 6. Proposiciones

# La proposición es la entidad principal del juego.

# No se necesita una tabla `Events` para el flujo base.

# 7. Fechas

# Se usa `DATETIME2` cuando interesa guardar fecha y hora.

# Se evita usar solo `DATE` en procesos como votaciones, pagos, predicciones, publicaciones y logs.

# 8. Montos

# Se usa `DECIMAL` para dinero, puntos y balances.

# No se usa `FLOAT` para montos financieros porque puede generar errores de precisión.

# 9. Seguridad

# Passwords, tokens y checksums se guardan en campos binarios.

# No se guardan contraseñas, tarjetas ni tokens sensibles en texto plano.
