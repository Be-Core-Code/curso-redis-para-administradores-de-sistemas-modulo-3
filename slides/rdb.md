### RDB

RDB realiza `point-in-time snapshots` de los datos en memoria a intervalos regulares
y configurables.

^^^^^^

#### RDB: Pros

* Representación en formato binario y compacto de los datos
* Especialmente indicado para hacer backups
* Ofrece el máximo rendimiento ya que el backup se hace dentro de un proceso hijo (fork del 
  master de Redis)
* Hace que el reinicio de un servidor Redis sea más rápido para bases de datos grandes que la alternativa AOF   

notes:

El formato compacto de RDB lo hace el candidato ideal para guardar copias de seguridad de nuestra
base de datos Redis. Podemos almacenar ficheros RDB cada 24 horas durante 30 días para disponer de un histórico de los
datos de redis, por ejemplo.

Es, además, el formato más cómodo para recuperación ante desastres ante AOF por su menor tamaño.

^^^^^^

#### RDB: Contras

* ⚠️ No nos garantiza que, ante una caída, se persistan todos los datos

notes: 

Por ejemplo, si configuramos la realización de un snapshot cada 15 minutos, y el servidor
se apaga entre la realización de ambos snapshots, perderemos todos los datos en memoria manipulados
después de la creación del snapshot.

^^^^^^

#### RDB: Contras

* RDB se ejecuta en `fork()` para persitir los datos en un proceso hijo. Si el volumen
  de datos es alto, Redis puede no responder durante la llamada a `fork()` 
  

^^^^^^

#### RDB: Comandos

* [`SAVE`](https://redis.io/commands/save)
* [`BGSAVE`](https://redis.io/commands/bgsave)

notes:

* [`SAVE`](https://redis.io/commands/save) Crea un snapshot de manera síncrona
* [`BGSAVE`](https://redis.io/commands/bgsave) Crea un snapshot de manera asíncrona

^^^^^^

#### RDB: Comandos

[`SAVE`](https://redis.io/commands/save) bloquea el hilo principal de redis **por lo que no
es recomendable usarlo en producción**.

^^^^^^

#### RDB: Comandos

[`BGSAVE`](https://redis.io/commands/bgsave) no bloquea el hilo principal de redis ya que 
utiliza `fork()` para lanzar un proceso hijo que hace el snapshot.

^^^^^^

#### RDB: Configuración

```
SAVE x1 y1 x2 y2 x3 y3 ...
```

que significa que haga un snapshot cada `x` segundos si han cambiado al menos `y` claves y no hay
otro snapshot en progreso.
 
  
^^^^^^

#### RDB: Configuración

```
# /etc/redis.conf

save 900 1 300 10 60 10000
```

notes:

Haz un snapshot cada 900 segundos si al menos una clave ha cambiado. Haz uno cada 300 segundos si
al menos 10 claves han cambiado y otro cada 60 segundos si han cambiado 10.000 claves.


^^^^^^

#### RDB: Configuración

Para desactivar los snapshots:

* Eliminar las líneas `save` del fichero `/etc/redis.conf`
* Ejecutar comando `SAVE ""`


^^^^^^

#### 💻️ Práctica 1

* Utilizando la aplicación [redis-random-data-generator](https://github.com/SaminOz/redis-random-data-generator)
  crear un set de prueba en Redis:
  
```bash
for i in `seq 2` 
do  
node generator.js hash 1000000 session  
done
```  

notes:

Este comando genera dos millones de entradas en redis de tipo hash.

^^^^^^

#### 💻️ Práctica 1

* Utilizando el comando [INFO](https://redis.io/commands/info) podemos ver un resumen de
  las claves que hemos creado
  
```redis-cli
redis-cli > INFO keyspace

# Keyspace
db0:keys=2000000,expires=0,avg_ttl=0
``` 

^^^^^^

#### 💻️ Práctica 1

* Utilizando el comando [`SAVE`](https://redis.io/commands/save), realizar una snapshot de los datos

```redis-cli 
redis-cli > INFO SAVE
OK
(90.99s)
```

notes:

Este comando es síncrono y bloquea el hilo principal de redis. Si nos intentamos conectar desde otra
consola para ejecutar otro comando, no podremos hacerlo hasta que este comando termine su ejecución.

^^^^^^

#### 💻️ Práctica 1

* Una vez el comando termine, podemos ver el fichero en la carpeta `/var/lib/redis`

```bash 
> ls -s /var/lib/redis/
total 259200
259200 dump.rdb
```

notes:

¿Porqué están en /var/lib/redis? Porque así se ha configurado en `/etc/redis.conf`

```bash 
> grep dir /etc/redis.conf

dir /var/lib/redis

```

También podemos verlo usando el comando [CONFIG GET](https://redis.io/commands/config-get)

```redis-cli
redis-cli > CONFIG GET dir
1) "dir"
2) "/var/lib/redis"
```

^^^^^^

#### 💻️ Práctica 1

* Llevaremos a cabo ahora la misma operación usando [`BGSAVE`](https://redis.io/commands/bgsave)

```redis-cli
redis-cli > BGSAVE
Background saving started
```
 Como este proceso lleva varios segundos, vamos a ver qué está pasando...
 
^^^^^^

#### 💻️ Práctica 1

* El comando [`INFO`](https://redis.io/commands/info) nos muestra que un proceso está en marcha en segundo plano:

```redis-cli
> INFO Persistence
# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:1
...
```

^^^^^^

#### 💻️ Práctica 1

* Además, veremos que tenemos dos procesos de redis en marcha en nuestra máquina:

```bash
> ps uxaf |grep redis
 4893 redis     1:33 /usr/bin/redis-server /etc/redis.conf --daemonize no
 5030 redis     0:08 /usr/bin/redis-server /etc/redis.conf --daemonize no
```

^^^^^^

#### 💻️ Práctica 1

* Veremos que el proceso 5030 crea un fichero temporal en la carpeta `/var/lib/redis`
  en el que hace el volcado:
  
```bash 
> ls /var/lib/redis
dump.rdb       temp-5003.rdb
```  


^^^^^^

#### 💻️ Práctica 1

* Cuando el proceso termina, el fichero `dump.rdb` es sustituido por `temp-5030.rdb` 

^^^^^^

* Si miramos el fichero de log `/var/log/redis/redis.log`:

```
4893:M 26 Feb 2020 13:10:38.027 * Background saving started by pid 5030
5030:C 26 Feb 2020 13:12:00.600 * DB saved on disk
5030:C 26 Feb 2020 13:12:00.611 * RDB: 0 MB of memory used by copy-on-write
4893:M 26 Feb 2020 13:12:00.688 * Background saving terminated with success
```

^^^^^^

#### 💻️ Práctica 1

* Una vez el programa termina, el comando [`INFO`](https://redis.io/commands/info)
  nos da información adicional sobre si el proceso terminó correctamente y cuándo terminó:
  
```redis-cli 
redis-cli > INFO Persistence
# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1582719120 <----
rdb_last_bgsave_status:ok     <----
```

^^^^^^

### RDB: configuración

* `stop-writes-on-bgsave-error yes` Si el proceso lanzado por [`BGSAVE`](https://redis.io/commands/bgsave) falla,
  el servidor deja de aceptar operaciones de escritura
* `rdbcompression yes` comprime el fichero para ahorrar espacio a costa de un coste aproximado de un 10% extra de CPU
* `rdbchecksum yes` Crea un CRC64 checksum al final del snapshot