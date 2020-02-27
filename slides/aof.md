### AOF

Genera un log con cada operación de escritura que recibe el servidor.

Estas instrucciones se guardan en un fichero y se reaplican cuando el servidor se inicia, reconstruyendo los datos en memoria

^^^^^^

#### AOF

Los comandos se guardan en el mismo formato que el protocolo de Redis

Cuando el log se hace muy grande, redis es capaz de reescribirlo para optimizarlo


^^^^^^

#### AOF: Pros

* Durabilidad
* __append_only__
* Compactable 
* Legible

notes:

* Durabilidad: Dado que las operaciones de escritura se guardan en el log, incluso
  en el caso de que haya una caída del servicio, las últimas operaciones quedarán guardadas en el log
  (esto depende del tipo de sincronización). En el peor de los casos, podemos perder
  el último segundo de operaciones de escritura
* __append only__: en caso de que falle el servidor justo cuando se está 
  está escribiendo una línea del log (nos quedamos sin espacio en disco por ejemplo)
  Redis es capaz de leer el resto del fichero ignorando la línea que no está correctamente
  almacenada. En las últimas versiones, el propio Redis es capaz de procesar estos ficheros con errores. En
  versionea más antiguas, se debía utilizar la herramienta `redis-check-aof`
* Compactable: Cuando el fichero se hace demasiado grande, Redis es capaz de reescribirlo en segundo plano.
  Esta escritura es totalmente segura ya que mientras se comprime el fichero, Redis genera un nuevo fichero y guarda 
  las nuevas operaciones de escritura en el fichero viejo. Cuando termina de crearlo, lo sustituye y comienza a 
  añadir las instrucciones al nuevo fichero
* Legible: Al guardarse en el mismo formato que el protocolo de Redis, podemos editarlo con un editor
  de texto tradicional. Por ejemplo, podríamos encontrarnos en la siguiente situación: imagínate que borramos
  sin darnos cuenta todas las claves utilizando FLUSHALL. Si todavía no se ha reescrito el log
  podríamos guardar el fichero AOF, parar el servidor, editar el fichero AOF, borrar la línea que 
  ejecuta el FLUSHALL y levantar el servidor. 
       
^^^^^^

#### AOF: Contras

* Los ficheros AOF son habitualmente más grandes que los ficheros RDB
* Puede ser más lento que RDB, dependiendo de la política que se escoja para sincronizar
* En el pasado ha habido problemas con bugs en algunos comandos relacionados con AOF

notes:

Como se [indica en la documentación](https://redis.io/topics/persistence#aof-disadvantages)
se han reportado bugs en los que AOF no produce exactamente los mismos datos cuando se 
recarga el fichero. Estos errores son muy poco frecuentes y, como se indica en el enlace,
el algoritmo se ha pensado para reducir al máximo el riesgo de error.

^^^^^^

#### AOF: Configuración

Para activarlo podemos:

```redis-cli
redis-cli > CONFIG SET appendonly yes

```

```bash
# /etc/redis.conf
appendonly yes
```

notes:

Podemos activarlo usando el comando [`CONFIG SET`](https://redis.io/commands/config-set) o
a través de la opción `appendonly` del fichero de configuración`/etc/redis.conf`

^^^^^^

#### AOF: Configuración

Podemos saber si nuestra instancia de Redis tiene esta opción activada de varias maneras:

* Con el comando [`CONFIG GET`](https://redis.io/commands/config-get)

```redis-cli
redis-cli > CONFIG GET appendonly
1) "appendonly"
2) "no"
```

* Con el comando [`INFO`](https://redis.io/commands/info)

```redis-cli
redis-cli > INFO Persistence
loading:0
...
aof_enabled:0
...
```

^^^^^^

#### AOF: Configuración

Opciones de configuración más importantes:

* `appendfilename`: Ruta al fichero AOF

^^^^^^

#### AOF: Configuración

Opciones de configuración más importantes:

* `appendfsync`: forma en la que se persisten a disco los cambios del fichero AOF (llamando a
  la función `fsync()`)

^^^^^^

#### appendfsync: always 

Se llama a `fsync()` por cada operación de escritura.

**Es la más segura pero la más lenta**

notes:

Debes tener en cuenta que la llamada a `fsync()` es síncrona, de forma que el rendimineto de Redis
estará estrechamente vinculado a la velocidad del disco.

En servidores Redis con una alta carga de operaciones de escritura esta opción suele afectar
negativamente al rendimiento de forma significativa. 

^^^^^^
#### appendfsync: everysec

Se llama a `fsync()` una vez por segundo.

**En caso de desastre, perdemos como máximo las operaciones de escritura realizadas en el último segundo.**

Opción recomendada por su equilibrio entre durabilidad y rendimiento.

^^^^^^
#### appendfsync: no

Redis nunca llama a `fsync()`.

**La llamada se delega al sistema operativo, que en Linux se realiza típcamente cada 30 segundos.**



^^^^^^

### 💻️ Práctica

* Activar el soporte para AOF si no está activo:

```redis-cli
redis-cli > CONFIG SET appendonly yes 
```

^^^^^^

#### 💻️ Práctica

* Ejecutar la siguiente secuencia de comandos de Redis:

```redis-cli
redis-cli > SET clave1 valor1
OK 
redis-cli > INCR contador
(integer) 1
redis-cli > INCR contador
(integer) 2
redis-cli > SET clave2 valor2
OK 
redis-cli > DEL clave1
(integer) 1
redis-cli > DEL clave3
(integer) 0
redis-cli > HSET mykey f1 v1 f2 v2
(integer) 2 
```

^^^^^^

#### 💻️ Práctica

* Si abrimos el fichero `appendonly.aof` veremos:

```
# /var/lib/redis/appendonly.aof
*2\r\n$6\r\nSELECT\r\n$1\r\n0\r\n
*3\r\n$3\r\nSET\r\n$6\r\nclave1\r\n$6valor1\r\n
*2\r\n$4\r\nINCR\r\n$8\r\ncontador\r\n
*2\r\n$4\r\nINCR\r\n$8\r\ncontador\r\n
...
```

^^^^^^

#### 💻️ Práctica

* Ejecutar el comando [`BGREWRITEAOF`](https://redis.io/commands/bgrewriteaof)

```redis-cli
redis-cli > BGREWRITEAOF
Background append only file rewriting started 
```

^^^^^^

#### 💻️ Práctica

* Si abrimos de nuevo el fichero `appendonly.aof` veremos únicamente el `aof-preamble`
* Veremos el `aof-preamble` en más detalle en la siguiente sección

note:

Según la documentación de la opción `aof-use-rdb-preamble`:

```bash
# When rewriting the AOF file, Redis is able to use an RDB preamble in the
# AOF file for faster rewrites and recoveries. When this option is turned
# on the rewritten AOF file is composed of two different stanzas:
#
#   [RDB file][AOF tail]
#
# When loading Redis recognizes that the AOF file starts with the "REDIS"
# string and loads the prefixed RDB file, and continues loading the AOF
# tail.
aof-use-rdb-preamble yes
```

Si abrimos el ficher en este punto, veremos únicamente el preámbulo:

```bash
REDIS0009.      redis-ver^E5.0.7.
redis-bits.@.^Ectime.v.V^.^Hused-mem.^?,        ^@.^Laof-preamble.^A.^@.^C^@^M^E...
```

Si ejecutamos ahora un comando como por ejemplo `SET clave3 valor3`, el fichero contendrá
el preámbulo y los nuevos comandos:

```bash
REDIS0009.      redis-ver^E5.0.7.
redis-bits.@.^Ectime.v.V^.^Hused-mem.^?,        ^@.^Laof-preamble.^A.^@.^C^@^M^E...
*2\r\n$6\r\nSELECT\r\n$1\r\n0\r\n
*3\r\n$3\r\nset\r\n$6\r\nclave3\r\n$6\r\nvalor3\r\n
```
 