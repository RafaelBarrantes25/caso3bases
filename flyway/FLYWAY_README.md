# Flyway - Gathel

Este documento contiene la información básica sobre el uso de **Flyway** dentro del proyecto **Gathel**.
Flyway se utiliza para administrar, versionar y ejecutar los scripts SQL de la base de datos de forma ordenada y repetible.

---

## ¿Qué es Flyway?

Flyway es una herramienta de **migraciones de base de datos**.
Una migración es un archivo SQL que contiene un cambio en la base de datos, por ejemplo:

* creación de tablas,
* creación de llaves primarias y foráneas,
* inserción de catálogos,
* creación de índices,
* creación de vistas,
* creación de stored procedures,
* scripts de seeding,
* scripts de seguridad,
* scripts de validación.

Flyway permite que todos los integrantes del equipo puedan construir la misma base de datos ejecutando los mismos archivos SQL en el mismo orden.

En lugar de ejecutar scripts manualmente sin control, Flyway revisa qué scripts ya fueron aplicados y cuáles están pendientes.

---

## ¿Para qué se usa Flyway en Gathel?

En el proyecto Gathel, Flyway se utiliza para administrar los scripts SQL de la base de datos **Gathel** en SQL Server.

Su uso permite:

* Crear la estructura física de la base de datos.
* Crear tablas, relaciones y restricciones.
* Insertar catálogos iniciales.
* Insertar datos base para pruebas.
* Validar que la estructura fue creada correctamente.
* Mantener el orden correcto de ejecución de los scripts.
* Evitar que cada integrante tenga una versión diferente de la base de datos.
* Llevar control de qué migraciones ya fueron ejecutadas.
* Versionar los cambios de base de datos junto con GitHub.

Dentro del caso Gathel, Flyway es importante porque el proyecto requiere que todos los scripts SQL sean administrados y versionados correctamente. Esto incluye los scripts de diseño, seeding, validaciones, seguridad, stored procedures, transacciones y concurrencia.

---

## ¿Cómo funciona Flyway?

Flyway trabaja leyendo los archivos SQL ubicados en una carpeta de migraciones.
En este proyecto, la carpeta es:

```text
flyway/sql/
```

Cada archivo tiene un nombre con una convención específica.
Por ejemplo:

```text
V1__create_schema.sql
V2__insert_catalogs.sql
V3__seed_base_data.sql
V4__week1_validation_queries.sql
```

La letra `V` significa que es una migración versionada.
Estas migraciones se ejecutan una sola vez y en orden.

Por ejemplo:

1. Primero se ejecuta `V1`.
2. Luego se ejecuta `V2`.
3. Luego se ejecuta `V3`.
4. Finalmente se ejecuta `V4`.

Flyway crea automáticamente una tabla llamada:

```text
flyway_schema_history
```

En esa tabla, Flyway guarda el historial de las migraciones ejecutadas.
Gracias a esta tabla, Flyway sabe cuáles scripts ya se aplicaron y cuáles faltan.

---

## Estructura usada en el proyecto

La estructura utilizada para Flyway dentro del repositorio es la siguiente:

```text
Gathel/
│
├── database/
│   └── manual/
│       └── 00__create_database.sql
│
└── flyway/
    ├── README.md
    ├── conf/
    │   └── flyway.conf
    └── sql/
        ├── V1__create_schema.sql
        ├── V2__insert_catalogs.sql
        ├── V3__seed_base_data.sql
        └── V4__week1_validation_queries.sql
```

---

## Carpeta `database/manual`

La carpeta `database/manual` contiene scripts que se ejecutan manualmente antes de usar Flyway.

El archivo principal es:

```text
database/manual/00__create_database.sql
```

Este script crea la base de datos `Gathel` si todavía no existe.

Este archivo no se ejecuta con Flyway porque Flyway trabaja sobre una base de datos ya existente.
Por eso, primero se crea manualmente la base de datos y después Flyway se encarga de crear las tablas, catálogos y datos iniciales.

---

## Carpeta `flyway/conf`

La carpeta `flyway/conf` contiene el archivo de configuración de Flyway:

```text
flyway/conf/flyway.conf
```

Este archivo define la conexión hacia SQL Server.
Ahí se configuran datos como:

```text
url de conexión
usuario
contraseña
ubicación de los scripts SQL
```

Ejemplo general:

```properties
flyway.url=jdbc:sqlserver://localhost:1433;databaseName=Gathel;encrypt=true;trustServerCertificate=true
flyway.user=usuario_sql
flyway.password=contraseña_sql
flyway.locations=filesystem:sql
```

Antes de ejecutar Flyway, cada integrante debe revisar este archivo y cambiar las credenciales según su ambiente local.

---

## Carpeta `flyway/sql`

La carpeta `flyway/sql` contiene las migraciones SQL versionadas del proyecto.

Cada archivo representa una parte del proceso de creación o validación de la base de datos.

---

## Archivos de migración

### `V1__create_schema.sql`

Este archivo crea la estructura física de la base de datos.

Incluye:

* tablas,
* llaves primarias,
* llaves foráneas,
* restricciones,
* relaciones principales.

En este proyecto, este archivo crea módulos como:

* logs,
* geografía y direcciones,
* usuarios y roles,
* monedas,
* billeteras,
* transacciones,
* pagos,
* redes sociales,
* procesos de IA,
* proposiciones,
* predicciones,
* resultados,
* productos canjeables.

---

### `V2__insert_catalogs.sql`

Este archivo inserta los catálogos iniciales necesarios para que la base funcione.

Por ejemplo:

* tipos de usuario,
* tipos de moneda,
* monedas,
* tipos de logs,
* severidades,
* redes sociales,
* proveedores de IA,
* modelos de IA,
* tipos de pago,
* estados de pago,
* tipos de transacción,
* estados de proposiciones,
* tipos de predicción,
* tipos de resultado,
* configuraciones iniciales.

Este archivo debe ejecutarse después de crear las tablas, porque depende de que el esquema ya exista.

---

### `V3__seed_base_data.sql`

Este archivo inserta datos base para pruebas iniciales.

Puede incluir:

* países,
* estados,
* ciudades,
* direcciones,
* usuario administrador,
* jugadores de prueba,
* billeteras iniciales,
* métodos de pago habilitados,
* cuentas de redes sociales de prueba,
* publicaciones de redes sociales,
* proposiciones de ejemplo,
* predicciones,
* intentos de pago,
* transacciones.

Este archivo sirve para que la base tenga información inicial y se pueda validar el flujo básico del sistema.

---

### `V4__week1_validation_queries.sql`

Este archivo contiene consultas de validación para la primera entrega.

Sirve para comprobar que:

* las tablas fueron creadas,
* los catálogos fueron insertados,
* los datos base existen,
* las relaciones principales funcionan,
* Flyway registró correctamente las migraciones ejecutadas.

También sirve para generar evidencia mediante capturas de pantalla.

Por ejemplo:

```sql
SELECT * FROM flyway_schema_history;
```

Esa consulta permite ver qué migraciones fueron ejecutadas por Flyway.

---

## Orden de ejecución

El orden correcto de uso es el siguiente:

1. Ejecutar manualmente en SQL Server Management Studio:

```text
database/manual/00__create_database.sql
```

2. Revisar el archivo de configuración:

```text
flyway/conf/flyway.conf
```

3. Actualizar usuario y contraseña de SQL Server según el ambiente local.

4. Entrar a la carpeta `flyway`.

5. Ejecutar:

```bash
flyway -configFiles=conf/flyway.conf info
flyway -configFiles=conf/flyway.conf migrate
flyway -configFiles=conf/flyway.conf info
```

---

## Comandos utilizados

### `flyway info`

Muestra el estado de las migraciones.

Permite ver:

* migraciones ejecutadas,
* migraciones pendientes,
* migraciones fallidas,
* orden de ejecución,
* estado actual de la base.

Comando:

```bash
flyway -configFiles=conf/flyway.conf info
```

---

### `flyway migrate`

Ejecuta las migraciones pendientes.

Si la base de datos está vacía, ejecuta desde `V1` en adelante.
Si ya se ejecutaron algunas migraciones, solamente ejecuta las que falten.

Comando:

```bash
flyway -configFiles=conf/flyway.conf migrate
```

---

### `flyway validate`

Valida que las migraciones aplicadas coincidan con los archivos actuales.

Esto es útil porque Flyway detecta si alguien modificó un archivo SQL que ya había sido ejecutado.

Comando:

```bash
flyway -configFiles=conf/flyway.conf validate
```

---

### `flyway repair`

Repara la tabla de historial de Flyway cuando hay errores controlados.

Debe usarse con cuidado, porque modifica el historial de migraciones.

Comando:

```bash
flyway -configFiles=conf/flyway.conf repair
```

---

## Tabla `flyway_schema_history`

Flyway crea una tabla llamada:

```text
flyway_schema_history
```

Esta tabla guarda información sobre cada migración ejecutada.

Contiene datos como:

* versión,
* descripción,
* nombre del script,
* fecha de ejecución,
* usuario que ejecutó la migración,
* checksum,
* estado de éxito o fallo.

Esto permite saber exactamente qué scripts fueron aplicados a la base de datos.

Ejemplo de consulta:

```sql
SELECT *
FROM flyway_schema_history
ORDER BY installed_rank;
```

---

## Importancia del checksum

Flyway calcula un checksum para cada migración.

El checksum sirve para detectar si un archivo SQL fue modificado después de haber sido ejecutado.

Por ejemplo, si ya se ejecutó:

```text
V1__create_schema.sql
```

y luego alguien cambia ese archivo, Flyway puede detectar que el contenido ya no coincide con el historial registrado.

Por esta razón, una regla importante del proyecto es:

```text
No modificar migraciones versionadas que ya fueron ejecutadas.
```

Si se necesita corregir algo, se debe crear una nueva migración.

Ejemplo:

```text
V5__fix_users_table.sql
V6__add_missing_indexes.sql
```

---

## Regla de trabajo con Flyway

La regla principal es:

```text
Cada cambio nuevo en la base de datos debe hacerse mediante una nueva migración.
```

No se deben hacer cambios manuales directamente en SQL Server sin dejar el script correspondiente en Flyway.

Esto permite que todos los integrantes puedan reconstruir la base de datos desde cero.

---

## Rollback en Flyway

En este proyecto, el rollback se manejará mediante migraciones correctivas hacia adelante.

Esto significa que, si una migración tiene un error o se necesita modificar algo, no se debe editar el archivo anterior si ya fue ejecutado.

En su lugar, se crea una nueva migración que corrija el problema.

Ejemplo:

```text
V5__fix_payment_attempts_constraint.sql
V6__add_missing_social_media_indexes.sql
```

Esta estrategia mantiene el historial claro y evita inconsistencias entre los integrantes del equipo.

---

## Evidencia de ejecución

Para la primera semana, se recomienda guardar capturas de pantalla en:

```text
evidence/week1/
```

Evidencias recomendadas:

```text
flyway_info.png
flyway_migrate.png
flyway_schema_history.png
```

Estas capturas demuestran que Flyway fue configurado, ejecutado y validado correctamente.

---

## Resumen

Flyway se utiliza en Gathel para controlar la evolución de la base de datos.

Permite ejecutar los scripts SQL en orden, registrar cuáles ya fueron aplicados y garantizar que todos los integrantes del grupo tengan la misma estructura y datos iniciales.

En este proyecto, Flyway administra:

* creación del esquema físico,
* inserción de catálogos,
* datos base,
* validaciones,
* futuras vistas,
* funciones,
* stored procedures,
* scripts de seguridad,
* scripts de transacciones,
* pruebas de concurrencia,
* y seeding masivo.

Gracias a Flyway, la base de datos de Gathel puede reconstruirse de forma ordenada, repetible y documentada.
