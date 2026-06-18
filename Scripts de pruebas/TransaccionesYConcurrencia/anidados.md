# SP Anidados

Cuando un SP llama a otro, que a su vez llama a otro, que llama a otro...

En SP anidados, si un SP de adentro falla y no se tiene un manejo de errores adecuado, lo que haya modificado se almacena de todas formas, lo que podría causar problemas al intentar corregir errores que este haya provocado.

Usando try y catch, se puede hacer un rollback, que devuelva todo a como estaba antes del error, así se deshace y se asegura qu eno hayan errores.