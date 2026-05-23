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
- email varchar(254)
- enabled boolean
- roletypeid (FK -> roletype.id)

## SocialMedia
- id PK
- description varchar(20) UNIQUE     -- Instagram, TikTok, etc.

## Status
- id PK
- status varchar(20) UNIQUE

## AiProcesses                -- Para ver si la IA acepta evidencia
- id PK
- processtype varchar(30)
- url varchar(256)            -- link a la evidencia que manda el usuario de que completó el reto
- socialMediaId (FK -> socialMedia.id)    -- si viene de tiktok, instagram, etc.
- response varchar(150)       -- comentario de la IA sobre la evidencia dada
- statusId (FK -> statis.id)  -- para ver si IA acepta, rechaza, inconcluso

## Settings
- id PK
- pointsPerEvent integer      -- Para configurar los puntos que se pueden apostar

## Audit
- id PK
- createdDate datetime
- updateDate datetime
- status varchar(50)
- createdBy (FK -> user.id)
- checksum VARBINARY

## PaymentType
- id PK
- code varchar(20) UNIQUE

## OperationType
- id PK
- code varchar(20) UNIQUE -- si es compra, ingreso de dinero, etc.
- enabled BOOLEAN

## PaymentMethod
- id PK
- configuration json
- postTime TIMESTAMP
- userid (FK -> users.id)
- amount NUMERIC()
- currencyId (FK -> currencies.id)

## PaymentAttempt              -- para registrar cuando intenta hacer un pago el usuario
- id PK
- enabled BOOLEAN
- apiUrl varchar(256)
- paymentmethod (FK -> paymentmethod.id)
- auditId (FK -> audit.id)
- source varchar(20)
- paymentTypeId (FK -> paymentType.id)
- checksum VARBINARY
- computer VARBINARY
- createdAt DATE
- postTime TIMESTAMP

# =========================
# TRANSACCIONES FINANCIERAS
# =========================

## TRANSACTION TYPES
- id (PK)
- code varchar(20) (UNIQUE)
- description varchar(60)
- createdAt DATE
- createdBy (FK -> users.id)

## TRANSACTIONS
- id (PK)
- typeId (FK -> transactionTypes.id)
- date DATE
- description varchar(80)
- amount DECIMAL
- currencyId (FK -> currencies.id)
- exchangeRateId (FK -> exchangeRates.id)
- relatedOrderId (FK -> orders.id) allows null
- referenceType varchar(30) allows null
- referenceId BIGINT allows null
- externalReference varchar(80) allows null
- createdBy (FK -> users.id)
- createdAt DATE
- checkSum BYTEA
