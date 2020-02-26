### Persistencia

Redis almacena **todos los datos en memoria**.

^^^^^^

#### Persistencia

Si el servidor se reinicia o se cae por algún motivo, los datos se pierden.


^^^^^^

#### Persistencia

¿De qué herramientas disponemos para defendernos de esta característica de Redis?

* Replicación
* Mecanismos de persistencia facilitados por redis

^^^^^^

#### Persistencia

La replicación la veremos en el siguiente módulo.
 

^^^^^^

#### Persistencia

Redis nos da dos mecanismos para persistir los datos que tiene en memoria:

* RDB: es un point-in-time snapshot de los datos
* AOF: log de las operaciones de escritura que se pueden volver a aplicar cuando el servidor se reinicia

^^^^^^

#### Persistencia

[https://redis.io/topics/persistence](https://redis.io/topics/persistence)