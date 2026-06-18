# Tipos de aislamiento

## Dirty read
Al hacer READ UNCOMMITED, se leen datos que aún no han sido commited, por lo que si se hace un rollback, los datos que se leyeron con el READ UNCOMMITED no fueron los datos finales, y pueden ser erróneos.

## Non repeatable read
Puede pasar con READ UNCOMMITED y READ COMMITTED.
Se lee un registro, otra transacción lo modifica y la transacción original lo vuelve a leer, entonces el dato que lee es distinto.

## Phantom read
Puede pasar con REPEATABLE READ
Se lee un rango de filas por condición, otra transacción inserta una fila que cumple la misma condición, entonces la primera, si vuelve a leer, ve una fila que antes no estaba.

## Lost update
Dos transacciones leen un valor y lo modifican con base en el valor inicial, una lo modifica primero y la otra después. La última en modificarlo gana y no toma en cuenta el valor de la otra.

# Soluciones

Usar el tipo de aislamiento que proteja según lo que se necesite, o serializable que protege de todo (pero no permite la concurrencia).