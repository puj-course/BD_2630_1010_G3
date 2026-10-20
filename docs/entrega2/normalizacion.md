# Normalización - Entrega 2
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

## 1. Criterios

| Forma normal | Condición |
|---|---|
| 1FN | Atributos atómicos, sin grupos repetitivos y con llave primaria |
| 2FN | Cumple 1FN y ningún atributo depende de solo una parte de una llave compuesta |
| 3FN | Cumple 2FN y ningún atributo no clave depende de otro atributo no clave (sin dependencias transitivas) |


## 2. Primera forma normal (1FN)

Las 16 tablas cumplen 1FN:

- Todas tienen llave primaria.
- Cada columna guarda un solo valor. Por ejemplo, un jugador tiene una sola posición y una selección un solo país.
- No hay columnas repetitivas (como `jugador1`, `jugador2`). Lo que se repite se modela en tablas propias: `CONVOCATORIA_JUGADOR`, `ESTADISTICA_JUGADOR_PARTIDO`, `ASIGNACION_ARBITRAL` e `INCIDENCIA`.


## 3. Segunda forma normal (2FN)

Las 16 tablas usan una llave primaria de una sola columna (`id_*`), así que con respecto a ella no puede haber dependencias parciales.

Algunas tablas también tienen llaves candidatas compuestas, declaradas como `UNIQUE`. En todas, los demás atributos dependen de la combinación completa y no de una sola parte. Por ejemplo, en `PARTICIPACION_PARTIDO` los goles dependen de `(id_partido, id_seleccion)` juntos: con solo el partido o solo la selección no se sabe cuántos goles hubo. Lo mismo pasa con el dorsal en `CONVOCATORIA_JUGADOR`, el rol en `ASIGNACION_ARBITRAL` y los datos de `ESTADISTICA_JUGADOR_PARTIDO`.



## 4. Tercera forma normal (3FN) por tabla

| Tabla | Dependencias funcionales | 3FN |
|---|---|---|
| EDICION_MUNDIAL | `id_edicion` → anio, lema, fecha_inicio, fecha_fin | Sí |
| SEDE | `id_sede` → id_edicion, pais | Sí |
| CIUDAD | `id_ciudad` → id_sede, nombre | Sí |
| ESTADIO | `id_estadio` → id_ciudad, nombre, capacidad | Sí |
| FASE | `id_fase` → id_edicion, nombre, orden_fase, tipo | Ver observación 3 |
| GRUPO | `id_grupo` → id_fase, nombre | Sí |
| SELECCION | `id_seleccion` → id_edicion, id_grupo, pais, confederacion | Ver observación 1 |
| PARTIDO | `id_partido` → id_edicion, id_fase, id_estadio, id_partido_siguiente, fecha_hora, asistencia_registrada | Ver observación 2 |
| PARTICIPACION_PARTIDO | `id_participacion` → id_partido, id_seleccion, condicion, goles_marcados | Sí |
| JUGADOR | `id_jugador` → nombre, posicion, club | Sí |
| CONVOCATORIA_JUGADOR | `id_convocatoria` → id_jugador, id_seleccion, numero_camiseta, es_capitan | Sí |
| CUERPO_TECNICO | `id_cuerpo_tecnico` → id_seleccion, nombre, cargo | Sí |
| ARBITRO | `id_arbitro` → nombre, nacionalidad | Sí |
| ASIGNACION_ARBITRAL | `id_asignacion` → id_partido, id_arbitro, rol | Sí |
| ESTADISTICA_JUGADOR_PARTIDO | `id_estadistica` → id_partido, id_jugador, titular, minutos, goles, asistencias, tarjetas | Ver observación 4 |
| INCIDENCIA | `id_incidencia` → id_partido, tipo, minuto, descripcion | Sí |

En las tablas marcadas "Sí" ningún atributo no clave determina a otro atributo no clave.

Las ubicaciones se normalizaron separando la jerarquía `EDICION_MUNDIAL → SEDE → CIUDAD → ESTADIO`. La edición de un estadio no se guarda en `ESTADIO`: se obtiene recorriendo esa cadena, lo que evita una dependencia transitiva.


## 5. Observaciones

Cuatro tablas tienen una dependencia entre atributos no clave:

1. **SELECCION:** `pais` → `confederacion`. Un país pertenece a una sola confederación, pero el dato se repite en cada edición. Para 3FN estricta se crearía una tabla de países o federaciones nacionales con su confederación. El enunciado (sección 7.3) menciona federación nacional y confederación; queda como mejora.
2. **PARTIDO:** `id_fase` → `id_edicion`. La edición del partido también se obtiene por su fase. Se conserva `id_edicion` en `PARTIDO` como redundancia controlada: permite filtrar por edición sin uniones y facilita validar que la fase, el estadio y la fecha del partido sean de la misma edición.
3. **FASE:** `nombre` → `tipo`. Solo "Fase de Grupos" es de tipo `GRUPOS`; las demás son `ELIMINATORIA`. Los valores se restringen con `CHECK`. Para 3FN estricta se crearía un catálogo de tipos de fase.
4. **ESTADISTICA_JUGADOR_PARTIDO:** `minutos_jugados` se puede derivar de `titular`, `minuto_entrada` y `minuto_salida`. Se almacena para facilitar las agregaciones por jugador, partido y edición.


## 6. Mejoras frente al modelo inicial

| Modelo inicial | Modelo ampliado | Problema que resuelve |
|---|---|---|
| `ESTADIO.ciudad` como texto | Tablas `SEDE` y `CIUDAD` | Evita repetir el nombre de la ciudad y permite varios países sede |
| `PARTIDO.fase` como texto | Tabla `FASE` | Evita texto repetido y permite ordenar las fases |
| `SELECCION.grupo` como texto | Tabla `GRUPO` | El grupo se asocia a una fase |
| Sin jugadores | `JUGADOR` y `CONVOCATORIA_JUGADOR` | El jugador se registra una sola vez aunque juegue varias ediciones |



## 7. Conclusión

Las 16 tablas cumplen 1FN y 2FN. Doce cumplen 3FN sin observaciones y cuatro tienen una dependencia documentada en la sección 5, con su justificación y la mejora que llevaría a 3FN estricta.
