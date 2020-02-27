### Combinando RDB y AOF

^^^^^^

### 💻️ Práctica

* Limpiar los datos usando el comando [`FLUSHALL`](https://redis.io/commands/flushall)
* Activar RDB
* Activar EOF

^^^^^^

#### 💻️ Práctica

* Crear 10.000 claves con el comando DEBUG POPULATE

```redis-cli
redis-cli > DEBUG POPULATE 10000
OK 
```

^^^^^^^

#### 💻️ Práctica

* Crear 10.000 claves con el comando DEBUG POPULATE

```redis-cli
redis-cli > DEBUG POPULATE 10000
OK 
```

^^^^^^

#### 💻️ Práctica

* Persistir los datos

```redis-cli
redis-cli > SAVE
OK 
redis-cli > BGREWRITEAOF
Background append only file rewriting started
```

^^^^^^

#### 💻️ Práctica

* Listar ambos ficheros en la consola:

```bash 
> ls -l /var/lib/redis
-rw-r--r--    1 redis    redis       207878 Feb 27 10:01 appendonly.aof
-rw-r--r--    1 redis    redis       207878 Feb 27 10:01 dump.rdb
```

¡Ambos ficheros ocupan lo mismo!


^^^^^^

#### 💻️ Práctica

* Esto es porque está activa la opción `aof-use-rdb-preamble`
* Desactivar la opción

```redis-cli
redis-cli > CONFIG SET aof-use-rdb-preamble no
OK
```

^^^^^^

#### 💻️ Práctica

* Volver a persistir los datos

```redis-cli
redis-cli > SAVE
OK 
redis-cli > BGREWRITEAOF
Background append only file rewriting started
```

^^^^^^

#### 💻️ Práctica

* Listar ambos ficheros en la consola:

```bash 
> ls -l /var/lib/redis
-rw-r--r--    1 redis    redis       436803 Feb 27 10:16 appendonly.aof
-rw-r--r--    1 redis    redis       207878 Feb 27 10:16 dump.rdb
```

¡el fichero AOF ocupa el doble!


^^^^^^
#### Combinando RDB y AOF

El uso de la opción `aof-use-rdb-preamble` permite:

* Reducir el tamaño del fichero AOF
* Aumentar la velocidad de la carga de datos (mejora el tiempo de reinicio del servicio)
* Mantiene todas las ventajas de la persistencia que nos da AOF (durabilidad, etc...)
