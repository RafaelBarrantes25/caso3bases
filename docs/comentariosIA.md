## Cambios propuestos al diseño de base de datos

Después de revisar el diseño físico actual de la base de datos Gathel, se identificaron varias oportunidades de mejora relacionadas con pagos, billeteras, impuestos, direcciones, eventos, redes sociales e inteligencia artificial. Los cambios propuestos buscan reducir redundancias, corregir cardinalidades, mejorar la trazabilidad del sistema y evitar almacenar información sensible que no es necesaria para el alcance académico del proyecto.

---

# 1. Corrección del módulo de pagos

## Cambio realizado

Se modifica la estructura de pagos para separar correctamente tres conceptos distintos:

1. El método de pago configurado en el sistema.
2. El intento de procesar un pago.
3. La transacción financiera generada cuando el pago fue exitoso.

Actualmente, `paymentAttempts` mezcla información que pertenece a `paymentMethods`, asume que siempre puede existir una tarjeta y también asume que siempre hay una billetera origen o destino. Esto no siempre es correcto, porque un intento de pago puede fallar antes de afectar una billetera, puede provenir de diferentes proveedores externos y no necesariamente debe estar asociado a una tarjeta guardada.

## Tablas que se eliminan

Se eliminan las siguientes tablas:

```text
paymentCards
paymentCardsPerUser
paymentCardType
audits
auditType
```

## Justificación

No se deben guardar tarjetas de crédito o débito dentro del sistema, aunque sea de forma parcial o tokenizada, porque esto introduce problemas de seguridad, cumplimiento normativo y privacidad que están fuera del alcance del proyecto. Gathel solo debe registrar el intento de procesar un pago y la respuesta del proveedor externo, pero no almacenar tarjetas.

Además, la tabla `audits` queda redundante porque su función puede ser cubierta por una tabla más específica de validaciones o bitácora de intentos de pago. En lugar de tener una auditoría genérica separada, las validaciones del intento de pago deben depender directamente de `paymentAttempts`.

## Nueva estructura propuesta

### paymentTypes

```text
paymentTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- CARD, SINPE, PAYPAL, BANK_TRANSFER, INTERNAL_BALANCE
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### paymentProviders

```text
paymentProviders
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- PAYPAL_API, SINPE_API, CARD_PROCESSOR, INTERNAL_ENGINE
- name VARCHAR(80) NOT NULL
- baseUrl VARCHAR(256) NULL
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
```

### paymentMethods

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

### operationTypes

```text
operationTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- POINTS_PURCHASE, MONEY_DEPOSIT, MONEY_WITHDRAWAL, PREDICTION_BET, REWARD_PAYMENT, COMMISSION_PAYMENT, PENALTY
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

### paymentStatuses

```text
paymentStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- PENDING, APPROVED, REJECTED, ERROR, CANCELLED, INSUFFICIENT_FUNDS
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### paymentAttempts

```text
paymentAttempts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- paymentMethodId INT NOT NULL FOREIGN KEY REFERENCES paymentMethods(id)
- operationTypeId INT NOT NULL FOREIGN KEY REFERENCES operationTypes(id)
- paymentStatusId INT NOT NULL FOREIGN KEY REFERENCES paymentStatuses(id)
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- currencyId INT NOT NULL FOREIGN KEY REFERENCES currencies(id)
- amount DECIMAL(18,2) NOT NULL
- referenceObjectType VARCHAR(50) NULL     -- PROPOSITION, PREDICTION, WALLET, WITHDRAWAL, PURCHASE, REWARD
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

### paymentValidationTypes

```text
paymentValidationTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- METHOD_CHECK, COUNTRY_CHECK, FUNDS_CHECK, PROVIDER_RESPONSE, FRAUD_CHECK
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

### paymentValidationStatuses

```text
paymentValidationStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- PENDING, APPROVED, REJECTED, ERROR
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### paymentAttemptValidations

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

## Regla de negocio

Un registro en `paymentAttempts` representa únicamente el intento de procesar un pago.
Si el intento queda en estado `APPROVED`, entonces se crea uno o varios registros en `transactions`.
Si el intento queda en estado `REJECTED`, `ERROR`, `CANCELLED` o `INSUFFICIENT_FUNDS`, no debe modificar balances, pero sí debe quedar registrado para trazabilidad.

---

# 2. Unificación de puntos y dinero

## Cambio realizado

Se elimina la separación entre `pointsBalance` y `moneyBalance` dentro de `wallets`. Los puntos se modelan como una moneda más dentro de `currencies`.

## Justificación

Separar puntos y dinero en columnas diferentes complica el modelo, porque obliga a duplicar saldos antes y después en las transacciones. Si los puntos son una moneda virtual, entonces deben manejarse con la misma lógica que cualquier otro balance. Esto simplifica apuestas, premios, penalizaciones, compras de puntos y canjes.

## Nueva estructura propuesta

### currencyTypes

```text
currencyTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(20) NOT NULL UNIQUE        -- FIAT, VIRTUAL
- description VARCHAR(100) NOT NULL
```

### currencies

```text
currencies
- id INT IDENTITY(1,1) PRIMARY KEY
- currencyTypeId INT NOT NULL FOREIGN KEY REFERENCES currencyTypes(id)
- code VARCHAR(10) NOT NULL UNIQUE        -- USD, CRC, PTS
- name VARCHAR(40) NOT NULL
- symbol VARCHAR(10) NOT NULL
- countryId INT NULL FOREIGN KEY REFERENCES countries(id)
- enabled BIT NOT NULL
- createdAt DATETIME2 NOT NULL
- updatedAt DATETIME2 NULL
- checksum VARBINARY(32) NOT NULL
```

### wallets

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

### transactions

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

## Regla de negocio

Cada usuario puede tener varias billeteras, una por moneda.
Por ejemplo:

```text
Usuario 1 - PTS - 100
Usuario 1 - USD - 25.00
Usuario 1 - CRC - 5000.00
```

De esta forma, apostar puntos o dinero usa el mismo flujo transaccional.

---

# 3. Corrección de impuestos

## Cambio realizado

Se elimina la separación confusa entre `taxes` y `countryTaxes`. Se deja una sola tabla de impuestos por país, relacionada directamente con el tipo de impuesto.

## Tablas que se eliminan

```text
taxes
countryTaxes
```

## Nueva estructura propuesta

### taxTypes

```text
taxTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- VAT, SALES_TAX, WITHDRAWAL_TAX, SERVICE_FEE
- name VARCHAR(80) NOT NULL
- description VARCHAR(150) NULL
- enabled BIT NOT NULL
```

### countryTaxes

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

## Justificación

La estructura anterior separaba el tipo de impuesto de los datos del impuesto por país, pero la relación terminaba siendo confusa porque el nombre real del impuesto no quedaba claro. Con esta estructura, cada impuesto aplicable a un país tiene su tipo, nombre, porcentaje o monto fijo, moneda y vigencia histórica.

Esto permite modelar, por ejemplo:

```text
Costa Rica - VAT - IVA 13%
Costa Rica - SERVICE_FEE - Comisión de servicio 2%
Estados Unidos - SALES_TAX - Sales Tax 8%
```

---

# 4. Corrección del modelo geográfico y direcciones

## Cambio realizado

Se agrega una estructura completa para direcciones. Actualmente existen países y estados, pero el usuario tiene `addressId` apuntando a una tabla `addresses` que no está definida. Además, falta representar ciudad, detalle de dirección y geolocalización.

## Nueva estructura propuesta

### countries

```text
countries
- id INT IDENTITY(1,1) PRIMARY KEY
- name VARCHAR(60) NOT NULL
- isoCode CHAR(2) NULL
- enabled BIT NOT NULL
```

### states

```text
states
- id INT IDENTITY(1,1) PRIMARY KEY
- countryId INT NOT NULL FOREIGN KEY REFERENCES countries(id)
- name VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### cities

```text
cities
- id INT IDENTITY(1,1) PRIMARY KEY
- stateId INT NOT NULL FOREIGN KEY REFERENCES states(id)
- name VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### addresses

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

## Justificación

Este cambio corrige la ausencia de `addresses` y permite que usuarios, negocios y métodos de pago tengan una ubicación real o aproximada. La latitud y longitud son opcionales porque no todos los registros necesitan geolocalización exacta.

---

# 5. Eliminación de Events y PropositionsPerEvent

## Cambio realizado

Se elimina la tabla `Events`, `EventStatus` y `PropositionsPerEvent`.

## Tablas eliminadas

```text
events
eventStatus
propositionsPerEvent
```

## Justificación

En el diseño actual, `Events` no aporta una función clara dentro del flujo principal. Las proposiciones ya representan el elemento central del juego: alguien propone algo, otros votan, el usuario acepta o rechaza, luego se hacen predicciones y finalmente se valida el resultado. Por eso, mantener una tabla `Events` genera una abstracción adicional que no se usa realmente.

La palabra “evento” puede mantenerse en el sistema de logs o en la generación masiva de actividad, pero no como entidad central de negocio. Si más adelante Gathel desea organizar eventos especiales, torneos o campañas, podría agregarse una tabla específica para eso, pero no debe mezclarse con las proposiciones normales.

---

# 6. Mejora de redes sociales y publicaciones

## Cambio realizado

Se amplía el modelo de redes sociales para guardar las publicaciones o contenidos que originan una proposición. No basta con saber que un usuario tiene Instagram o TikTok; también debe saberse cuál publicación, historia, video o contenido originó la proposición o sirvió como evidencia.

## Nueva estructura propuesta

### socialMedia

```text
socialMedia
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- INSTAGRAM, TIKTOK, X, FACEBOOK
- name VARCHAR(50) NOT NULL
- enabled BIT NOT NULL
```

### socialMediaAccounts

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

### socialMediaPosts

```text
socialMediaPosts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- socialMediaAccountId BIGINT NOT NULL FOREIGN KEY REFERENCES socialMediaAccounts(id)
- externalPostId VARCHAR(120) NULL
- postUrl VARCHAR(500) NOT NULL
- postType VARCHAR(40) NOT NULL           -- POST, STORY, REEL, VIDEO, COMMENT
- caption NVARCHAR(500) NULL
- postedAt DATETIME2 NULL
- capturedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

### propositionSourcePosts

```text
propositionSourcePosts
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- socialMediaPostId BIGINT NOT NULL FOREIGN KEY REFERENCES socialMediaPosts(id)
- sourceUse VARCHAR(40) NOT NULL          -- ORIGIN, EVIDENCE, RESULT_VALIDATION
- createdAt DATETIME2 NOT NULL

UNIQUE(propositionId, socialMediaPostId, sourceUse)
```

## Justificación

Este cambio permite mapear de forma directa qué publicación originó una proposición y qué publicación se usó como evidencia para validar el resultado final. Esto es necesario porque Gathel depende de contenido de redes sociales para crear y validar proposiciones.

---

# 7. Mejora de logs de inteligencia artificial

## Cambio realizado

Se reemplaza la tabla `AiProcesses` por una estructura más completa de proveedores, modelos y ejecuciones de IA.

## Tablas eliminadas o reemplazadas

```text
aiProcesses
aiStatus
processType
```

## Nueva estructura propuesta

### aiProviders

```text
aiProviders
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- OPENAI, GEMINI, CLAUDE, LOCAL_MODEL
- name VARCHAR(80) NOT NULL
- enabled BIT NOT NULL
```

### aiModels

```text
aiModels
- id INT IDENTITY(1,1) PRIMARY KEY
- aiProviderId INT NOT NULL FOREIGN KEY REFERENCES aiProviders(id)
- modelName VARCHAR(100) NOT NULL
- version VARCHAR(50) NULL
- enabled BIT NOT NULL
```

### aiProcessTypes

```text
aiProcessTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(50) NOT NULL UNIQUE        -- PROPOSITION_CREATION_REVIEW, ETHICAL_REVIEW, RESULT_VALIDATION, FRAUD_REVIEW
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

### aiResults

```text
aiResults
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(30) NOT NULL UNIQUE        -- APPROVED, REJECTED, INCONCLUSIVE, NEEDS_MORE_EVIDENCE, ERROR
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

### aiProcessLogs

```text
aiProcessLogs
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- aiModelId INT NOT NULL FOREIGN KEY REFERENCES aiModels(id)
- aiProcessTypeId INT NOT NULL FOREIGN KEY REFERENCES aiProcessTypes(id)
- aiResultId INT NOT NULL FOREIGN KEY REFERENCES aiResults(id)
- userId INT NULL FOREIGN KEY REFERENCES users(id)
- propositionId BIGINT NULL FOREIGN KEY REFERENCES propositions(id)
- socialMediaPostId BIGINT NULL FOREIGN KEY REFERENCES socialMediaPosts(id)
- appliedObjectType VARCHAR(50) NOT NULL   -- PROPOSITION, SOCIAL_POST, RESULT, PAYMENT_ATTEMPT
- appliedObjectId BIGINT NOT NULL
- prompt NVARCHAR(MAX) NULL
- requestJson NVARCHAR(MAX) NULL
- responseJson NVARCHAR(MAX) NULL
- responseSummary VARCHAR(500) NULL
- confidence DECIMAL(5,4) NULL
- createdAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL
```

## Justificación

La IA se usa en varios momentos del flujo: para revisar si una publicación o proposición es segura, para validar que no se haga algo antiético, para analizar evidencia y para determinar si el resultado final se cumplió o no. Por eso, el log de IA debe guardar proveedor, modelo, tipo de proceso, request, response, resultado y objeto donde se aplicó.

Esto permite responder preguntas como:

```text
¿Qué modelo revisó esta proposición?
¿Qué respuesta dio la IA?
¿La IA aprobó o rechazó la evidencia?
¿Sobre qué publicación se aplicó la revisión?
¿Qué request y response se enviaron?
```

---

# 8. Ajuste de Propositions

## Cambio realizado

Se actualiza `propositions` para que sea la entidad central del sistema, sin depender de `events`.

## Nueva estructura propuesta

### propositionStatuses

```text
propositionStatuses
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- PROPOSED, UNDER_AI_REVIEW, VOTING, SELECTED, ACCEPTED, REJECTED, ACTIVE, COMPLETED, CANCELLED, UNVERIFIABLE
- description VARCHAR(150) NOT NULL
- enabled BIT NOT NULL
```

### propositions

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

### propositionVotes

```text
propositionVotes
- id BIGINT IDENTITY(1,1) PRIMARY KEY
- userId INT NOT NULL FOREIGN KEY REFERENCES users(id)
- propositionId BIGINT NOT NULL FOREIGN KEY REFERENCES propositions(id)
- votedAt DATETIME2 NOT NULL
- checksum VARBINARY(32) NOT NULL

UNIQUE(userId, propositionId)
```

### propositionResults

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

## Justificación

La proposición debe contener su propio ciclo de vida: propuesta, revisión por IA, votación, aceptación, ejecución, validación y cierre. De esta forma, el modelo queda alineado con el flujo real del juego.

---

# 9. Ajuste de Predictions

## Cambio realizado

Se mantiene `predictions`, pero se recomienda asociar la predicción con una transacción cuando implique apuesta de puntos o dinero.

## Nueva estructura propuesta

### predictionTypes

```text
predictionTypes
- id INT IDENTITY(1,1) PRIMARY KEY
- code VARCHAR(40) NOT NULL UNIQUE        -- WILL_HAPPEN, WILL_NOT_HAPPEN
- description VARCHAR(100) NOT NULL
- enabled BIT NOT NULL
```

### predictions

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

## Justificación

Cada usuario solo debe poder realizar una predicción por proposición. Además, si la predicción implica apostar puntos o dinero, debe existir una transacción asociada. Esto permite demostrar claramente cuándo un usuario perdió puntos, ganó dinero o recibió una recompensa.

---

# 10. Ajuste de Settings

## Cambio realizado

Se recomienda transformar `settings` en una tabla de configuración flexible, en lugar de tener una columna por cada parámetro.

## Nueva estructura propuesta

### settings

```text
settings
- id INT IDENTITY(1,1) PRIMARY KEY
- settingKey VARCHAR(80) NOT NULL UNIQUE  -- INITIAL_PLAYER_POINTS, REJECT_PENALTY_PERCENTAGE, PLATFORM_EARNINGS_PERCENTAGE
- settingValue VARCHAR(255) NOT NULL
- valueType VARCHAR(20) NOT NULL          -- INT, DECIMAL, STRING, BOOLEAN
- description VARCHAR(200) NULL
- enabled BIT NOT NULL
- updatedBy INT NULL FOREIGN KEY REFERENCES users(id)
- updatedAt DATETIME2 NOT NULL
```

## Justificación

El diseño anterior obliga a modificar la estructura de la tabla cada vez que se agregue una nueva configuración. Con una tabla clave-valor, Gathel puede agregar nuevas reglas sin cambiar el diseño físico.

---

# 11. Cambios adicionales recomendados

## 11.1 Corrección de nombres

Se recomienda usar nombres consistentes en plural o singular, pero no mezclados. Por ejemplo:

```text
users
roles
socialMedia
socialMediaAccounts
paymentMethods
paymentAttempts
transactions
propositions
predictions
```

También se deben corregir inconsistencias como:

```text
user.id -> users.id
currency.id -> currencies.id
currrencies -> currencies
quanityType -> quantityType
paymentStatusId -> paymentStatusId
predictionTypesId -> predictionTypeId
propositionStatusid -> propositionStatusId
```

## 11.2 Uso de DATETIME2 en lugar de DATE cuando interesa hora

Se recomienda usar `DATETIME2` en campos donde la hora importa, por ejemplo:

```text
createdAt
updatedAt
votingStartsAt
votingClosesAt
acceptedAt
rejectedAt
challengeStartsAt
challengeEndsAt
postedAt
capturedAt
completedAt
```

## 11.3 Uso de DECIMAL en lugar de FLOAT para dinero

Se recomienda reemplazar `float` por `DECIMAL(18,2)` o `DECIMAL(18,4)` en montos económicos. El tipo `FLOAT` puede generar diferencias de precisión y no es adecuado para dinero.

## 11.4 Historial de proposiciones

Se recomienda agregar una tabla de historial para cambios de estado de una proposición.

### propositionStatusHistory

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

## Justificación

Esto permite explicar cómo una proposición pasó de propuesta a revisión, votación, aceptación, ejecución, completada o rechazada.

---

# Resumen de cambios principales

| Área           | Cambio                                                                       |
| -------------- | ---------------------------------------------------------------------------- |
| Pagos          | `paymentAttempts` queda solo como intento de pago                            |
| Tarjetas       | Se eliminan tablas de tarjetas                                               |
| Auditoría      | Se elimina `audits`; se reemplaza por validaciones de intentos de pago       |
| Wallets        | Se unifican puntos y dinero usando `currencies`                              |
| Transacciones  | Se simplifican balances antes/después                                        |
| Impuestos      | Se corrige cardinalidad con una sola tabla `countryTaxes`                    |
| Direcciones    | Se agregan `cities` y `addresses`                                            |
| Events         | Se elimina porque no aporta al flujo principal                               |
| Redes sociales | Se agregan publicaciones que originan proposiciones                          |
| IA             | Se agregan proveedor, modelo, request, response, resultado y objeto aplicado |
| Propositions   | Se vuelve la entidad central del flujo                                       |
| Predictions    | Se vinculan con wallet y transacciones                                       |
| Settings       | Se vuelve una tabla flexible de configuración                                |
