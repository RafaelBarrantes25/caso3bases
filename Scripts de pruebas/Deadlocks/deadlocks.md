# Deadlocks

Se provocan cuando varias transacciones tienen bloqueos y quieren realizar una transacción sobre otro bloqueo.
Por ejemplo, si un SP1 bloquea la tabla1, SP2 bloquea la tabla2, SP1 quiere modificar la tabla 2 y SP2 quiere modidicar la tabla 1, crea una dependencia circular, por lo que ninguna de las dos transacciones puede continuar.

## Manejo por parte de SQL Server

SQL Server detecta automáticamente cuando se produce un deadlock, elige la transacción que haya hecho cambios menores, y la detiene con error 1205.

## Prevención

Se pueden prevenir deadlocks usando niveles de aislamiento adecuados y no haciendo transacciones complejas.
También se puede atrapar el error 1205 y manejarlo.