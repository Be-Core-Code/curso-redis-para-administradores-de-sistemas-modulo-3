# Diapositivas del Curso [NOMBRE DEL CURSO] - Módulo [MODULO]: [TÍTULO DEL MÓDULO]

## Índice


## Visualización

Para ver las diapositivas:

```bash
> docker run --rm -p "8000:8000" becorecode/[SLUG DEL CURSO]-modulo-[MODULO]:latest
```

Una vez levantado el contenedor, accede con un navegador web a `http://localhost:8000`

## Navegación

Las diapositivas están desarrolladas usando [reveal.js](https://revealjs.com/#/):

* Accede a las notas del presentador usando la letra `s`
* Accede a una visión global de todas las diapositivas del módulo usando la tecla `ESC`
* Navega por las diapositivas usando las flechas ⬆➡⬇⬅
* Para imprimirlas:
  * Accede a la URL `http://localhost:8000/?print-pdf`
  * Imprime la página 
  * Si deseas añadir las notas del presentador utiliza la URL  `http://localhost:8000/?print-pdf&showNotes=true`

## Desarrollo

Como se indica un poco más abajo, haz un fork del repositorio y clonalo en tu máquina. 
Asegurate de tener [docker instalado](https://docs.docker.com/install/).

Una vez tengas tu fork clonado, accede a la carpeta con el repsotorio

```bash
> cd /ruta/al/repositorio
```

Estas diapositivas se han desarrollado en una máquina con OSX. Para mejorar el rendimiendo hemos utilizado
volúmenes para cachear los módulos de node. Por ello, antes de poder levantar el contenedor debemos
insertar los módulos de node en el volumen que usaremos como cache. Para ello, ejecutamos el siguiente comando:

```bash
> docker-compose run node npm install
```

Finalmente, levantamos el contenedor:
```bash
> docker-compose up
```

Puedes acceder a las diapositivas en `localhost:[PUERTO]`. Haz los cambios que necesites en las diapositovas situadas en la carpeta
`slides/` y recarga el navegador para ver el resultado.

Si quieres cambiar el puerto, puedes detener los servicios con `docker-compose down`, editar el fichero 
`docker-compose.yml`, cambiar la configuración del servicio `node` y volver a levantar de nuevo los 
servicios con `docker-compose up`

### ¿Cómo enviar las modificaciones para que se incoporen al repositorio?

* Haz un fork del proyecto
* Cloan el proyecto en tu máquina
* Siguiendo alguno de los procedimientos anteriores, modifica las diapositivas
* Crear una rama en git y haz push de esa rama a tu fork
* Envíanos un pull-request desde github


# Credits
