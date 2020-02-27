### Comandos utilizados en este módulo

* [`BGREWRITEAOF`](https://redis.io/commands/bgrewriteaof)
* [`BGSAVE`](https://redis.io/commands/bgsave)
* [`CONFIG GET`](https://redis.io/commands/config-get)
* [`CONFIG SET`](https://redis.io/commands/config-set)
* [`INFO`](https://redis.io/commands/info)
* [`SAVE`](https://redis.io/commands/save)

^^^^^^

### Opciones de configuración

* `dir`: Carpeta en la que se persisten los datos
* `dbfilename`: Nombre del fichero RDB
* `logfile`: Ruta completa al fichero de log de Redis
* `appendonly`: activa o desactiva el soporte para la persistencia mediante AOF
* `aof-use-rdb-preamble`: activa el preámbulo del fichero AOF (optimización de rendimiento)

[Sobre `redis.conf`](https://redis.io/topics/config)