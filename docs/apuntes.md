# Resumen
Gathel es un juego de predicciones. Un jugador asocia una o varias cuentas de redes sociales para que Gathel acceda a su contenido y cada jugador empieza con 100 puntos.


**----------------------------------------------------------------------------------------**
**Flujo de uso en Gathel:**
**----------------------------------------------------------------------------------------**
*Recepción de proposiciones*
- P1 publica algo en una red social
- P1, P2, P3 y P4 propone una predicción de algo que le va a pasar a P1
- Un sistema de IA analiza que lo que se haya publicado sea seguro y no rompa las normas
- Otras personas votan por las proposiciones de P[1,4]
- P1 selecciona si borrar alguna de las proposiciones de P[2,4]
- Después de 24 horas, Gathel selecciona la proposición más votada
- P1 elige si aceptar o rechazar la proposición.
Si la rechaza, pierde 1 punto y se cierra la proposición.
Si la acepta, el concurso inicia y P1 define la fecha y hora límite.

*Sistema de predicciones*
- Los jugadores predicen si la proposición se cumplirá o no
- Pueden apostar 1 punto virtual, dinero real a elección o ambos

*Validación del resultado*
- P1 publica evidencia de si se cumplió o no la proposición (fotos, videos, etc.) con hashtags a Gathel
- La IA de Gathel analiza si se cumplió la propuesta o se hizo fraude. Si queda en duda, Gathel puede pedir evidencia adicional

*Recompensas*
- Los que pierden la predicción pierden el punto/dinero
- El monto total se distribuye entre los ganadores, con una comisión para P1 y Gathel

*Flujo alternativo*
- Si no se logra validar el cumplimiento, los jugadores recuperan los puntos/dinero
- P1 pierde 15% de sus puntos

*Economía*
- Se pueden retirar ganancias mediante transferencias bancarias
- Se pueden adquirir puntos mediante compras de dinero real
- Otras empresas pueden aceptar puntos de Gathel como método de pago
- Gathel organiza eventos


**----------------------------------------------------------------------------------------**
**Diseño de la base**
**----------------------------------------------------------------------------------------**
- Hay que tener un agente de IA que revise que todo esté conforme a las especificaciones
- Debe tenerse un README.md dentro de /src
- Hay que usar la herramienta Flyway, documentar instalación configuración, estructura, etc.
- Hacer script seeding integrado de Flyway para que todos los integrantes tengan misma estructura inicial
- El script seeding deeb generar (con loops)
1000 usuarios
5000 proposiciones y sus registros de pago
250 000 eventos
- El proceso de seeding debe contemplar:
- integridad referencial
- consistencia de datos
- generación realista de información
- distribución variada de eventos
- timestamps coherentes
- relaciones válidas entre jugadores, proposiciones, predicciones, pagos y resultados

- Todos los scripts se deben administrar y versionar con github y flyway

**----------------------------------------------------------------------------------------**
**Live coding**
**----------------------------------------------------------------------------------------**
- Se deberán crear scripts de ejemplo pero también dse deben hacer cosas en vivo como:

- SELECT, INSERT, DELETE, UPDATE, JOINS (NATURAL-INNER-LEFT-RIGHT)
- Common table expressions
- Queries y subqueries
- Creación y uso de vistas
- Uso de instrucciones como CASE, EXIST, NOT EXISTS
- Operaciones de conjunto como IN, NOT IN, MERGE, INTERSECT
- Table value parameters en stored procedures y functions
- Selects de JSON con tablas de forma mezclada
- Crear CSV basados en queries
- Diferencia entre un cursor global y uno local
- Uso de triggers
- sp_recompile
- coalesce
- funciones agregadas
- rank, dense_rank, rownumber y partition by
- Union, Distinct
- schema binding y with encryption

- Van a haber preguntas sobre los scripts y su funcionamiento


**----------------------------------------------------------------------------------------**
**Security Lab**
**----------------------------------------------------------------------------------------**
- Deben crearse usuarios de prueba (aparte del admin que ingresa a la base)
- Debe crearse un ejercicio que muestre la creación de roles:
- Crear usuarios con permisos específicos
- Asignar usuarios a distintos roles
- Demostrar que un usuario puede tener permisos de usuario y de rol
- Validar que un usuario no pueda hacer select de una tabla específica pero sí pueda acceder mediante stored procedure o function
- Validar que un usuario tenga permisos solo read o solo write
- Demostrar que se pueda usar Datamasking
- Demostrar que se puede aplicar Row-Level Security
- Demostrar cifrado de contraseñas con master certificate

**----------------------------------------------------------------------------------------**
**Transacciones y concurrencia**
**----------------------------------------------------------------------------------------**
- Todo se deberá hacer con scripts sql
- Demostrar el comportamiento de un flujo exitoso, y uno fallido, cuando existen 3 Stored Procedures transaccionales ejecutándose de forma anidada y ocurre un fallo en el último SP de la cadena, mientras aún existen operaciones pendientes en los niveles superiores.
- Simular un deadlock usando 2 stored procedures con escritura concurrentes
No se permite usar instrucciones de locking pero sí WAITFOR DELAY para facilitar la sincronización
Demostrar que puede ocurrir un deadlock por un select también
Demostrar un deadlock T1->T2->T3->T4
- Demostrar problemas con READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ y SERIALIZABLE
- Comprender y documentar los problemas en cada nivel, cómo identificarlos
- Crear Stored Procedures transaccionales para el MVP
- Todo en Flyway


**----------------------------------------------------------------------------------------**
**MVP**
**----------------------------------------------------------------------------------------**
- Hacer interfaz gráfica con aplicación web o Android
- Debe tener login y logout
- Pantalla principal con balance de puntos y dinero, y actividad básica del jugador
- Crear proposición para otro jugador o para sí mismo
- Visualizar proposiciones activas
- Realizar predicciones con puntos o dinero
- Comunicación entre frontend y backend REST API.
**Backend**
- Endpoints para el frontend
- Lectura con ORM
- Escritura con stored procedures
- Esquema _fixed-size connection pooling_ para base de datos

**----------------------------------------------------------------------------------------**
**Extra**
**----------------------------------------------------------------------------------------**
- Documentar todo, usuarios, scripts, configuraciones, todo
Apuntes sobre el caso 3

- No diseñar la demostración de que la persona ejecutó la acción (no poner para video, imágenes y todo eso), solo diseñar la bitácora que diga si se confirmó, si falló o si se anula

- Hacer 1 sola tabla de bitácora de análisis de procesos para saber si la IA acepta o no la evidencia de si completó el reto (processid, processtype, url, sourcetype, response, result)
[para ver de dónde proviene la prueba, no hacer una tabla Instagram o una tiktok sino usar este source]

- No diseñar lo de banear gente ni lo de temas dudosos moralmente, solo documentarlo

- Todas las tablas de transactions, lo de plata y lo que nos sirva lo copiamos del caso 2

- tener tablas de configuración para poder cambiar valores como los puntos que cuesta apostar y cosas así

- hacer tabla de pagos que registre el intento de pagar
Tener una tabla paymentmethod que tenga:
json de configuración, enabled, audit, url api, source (sinpe, tarjeta, paypal)

También debe haber una tabla paymentattempts. Esta registra que un usuario trató de procesar un pago
Debe tener:
Paymentmethodid (para la tabla anterior), posttime, userid, amount, currencyid, operationtypeid, referenceobjectid (número de pago, carrito, etc), sourceobject id, result, request (lo que se le manda), response (si se pudo procesar el pago, si no hay plata, si no se pudo pagar), transaction reference varchar

- si el pago se hizo exitosamente, se va a transactions (modelo que vimos en clase)



- hacer agentes que revisen el diseño de la base y cumpla las reglas en el github (hacer ctrl f en el githubcaso3 donde dice "analizar aspectos como:" ahí aparecen las reglas)


- *DEBE MANDARSE EL MODELO EN DISEÑO FÍSICO, NO DISEÑO LÓGICO* (físico muestra exactamente cómo está estructurado, osea debe salir los campos, los nombres, los tamaños de los campos, si acepta null y todo eso, no solo que diga los nombres y ya)


- en el management studio, hay una sección de security, y el profe nos va a pedir ver qué usuarios se conectaron y sus permisos


- la parte MVP la podemos hacer con IA porque no es un curso de frontend. NO va a tener conexión a la base de datos sino que va a tener una API al backend
- Lo que sí tenemos que hacer nosotros son los últimos 3 puntos de donde dice backend del mvp osea
Debemos hacer operaciones de lectura orm y saber explicarlo, las escrituras deben realizarse con stored procedures y saber cómo funciona la conexión a la base de datos y saber qué es un driver nativo y todo eso

y lo de un fixed size connection pooling

- debe tenerse forma de crear usuarios O ya tener usuarios registrados 
- si anita votó donde perdió, debe reflejarse que perdió los puntos
- si juancito ganó, debe tener más plata


- el profe nos va a revisar bastante los agentes de IA

- podemos hacer la revisión antes de la fecha (pero mejor no hagamos eso para no morir)