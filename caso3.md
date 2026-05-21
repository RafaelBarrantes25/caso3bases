# Database engine: SQLServer

Database name: Gathel

Context:Gathel es un juego digital de predicciones basado en acciones y eventos de la vida real de las personas, validados mediante redes sociales e inteligencia artificial.

Al registrarse en la plataforma, los jugadores pueden asociar una o varias cuentas de redes sociales, por ejemplo Instagram o TikTok. Esto permite que Gathel solicite autorización para acceder automáticamente a publicaciones, historias, reels, videos y demás contenido público o autorizado por el usuario.

Cada jugador inicia con un balance inicial de 100 puntos (pts) dentro de la plataforma.

# Tables:
## Users:
- userID PK
- name varchar(20)
- lastName varchar(20)
- email varchar(254)
- enabled boolean

## Countries:
- countryID PK
- countryCommonName varchar(25)			-- Ej: 'Costa Rica', 'Estados Unidos', 'Japón'
- countryOfficialName varchar(30)			-- Ej: 'República de Costa Rica', 'Estados Unidos de América', 'Japón'
- isoCode char(3)			-- Ej: 'CRC', 'USA', 'JAP'
- taxRate decimal(5,4)
- enabled boolean

## States:
- stateID PK
- countryID FK
- stateName varchar(20)			-- Ej: 'Alajuela', 'Buenos Aires', 'Ciudad de Guatemala'
- isoCode varchar(10)			-- Ej: 'CR-A', 'AR-C', 'GT-GU'
- enabled boolean

## Cities:
- cityID PK
- stateID FK
- cityName varchar(30)			-- Ej: 'San Ramón', 'Medellín (Centro)', 'Santiago (Centro)'
- enabled boolean

## Addresses:
- addressID PK
- cityID FK
- address1 varchar(30)
- address2 varchar(30)
- zipCode varchar(20)			-- Ej: '20201', '050001', '8320000'
- geoPosition point
- enabled boolean

## Currencies:
- currencyID PK
- currencySymbol char(1)
- currencyName varchar(10)
- countryID FK
- userID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## ExchangeRates:
- exchangeRateID PK
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangeRate decimal(20,4)			-- Factor multiplicativo
- postTime TIMESTAMP
- userID FK
- post timestamp
- checksum bytea
- enabled boolean

## ExchangeHistories:
- exchangeHistoryID PK
- startDate TIME
- endDate TIME
- exchangeRateID FK			-- tasa De Cambio Actual
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangerate decimal(20,4)			-- Factor multiplicativo
- userID FK
- post timestamp
- checksum bytea

## Logs:
- logID PK
- eventTypeID FK
- description varchar(255)
- sourceID FK
- severityID FK
- postTime Timestamp
- userID FK
- checksum BYTEA
- dataObjectID1 FK
- dataObjectID2 FK

## EventTypes:
- EventTypeID PK
- LogType varchar(30)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

