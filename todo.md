# Colección de cambios pendientes (sobre la versión master)

  - [ ] Arreglar los problemas de tamaño de la ventana gráfica global.
  - [ ] Descargar por defecto una carpeta de ejemplos y no añadirlas al compilado. Permitir que se puedan refrescar los ejemplos descargando un zip independiente 
  (a nivel de Github, hacerlo sencillo).
  - [ ] Cambiar el comportamiento de movimiento de la cámara (invertir).
  - [ ] Eliminar toda la parte de configuración de los ficheros de modelos (inicial y final), y dejar únicamente lo que sea imprescindible. Lo que se hace es cargar un modelo de configuración estándar común a todos los modelos. Un usuario avanzado puede copiar ese fichero de configuración a la carpeta del modelo y adaptarlo a sus necesidades. En ese caso, se leerá el fichero local en vez del global.
  - [ ] Eliminar las opciones ticks, xsize, ysize de la configuración. No tienen sentido ni para el modelo ni para el motor gráfico.
