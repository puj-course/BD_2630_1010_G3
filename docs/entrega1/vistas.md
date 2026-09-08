# Vistas del Modelo Inicial — Justificación

**Entrega 1 — Grupo G3**
Implementación: [`sql/entrega1/vistas/vistas.sql`](../../sql/entrega1/vistas/vistas.sql)

Cada vista guarda una consulta que se repite en varios puntos del proyecto,
para no reescribir los mismos JOIN y GROUP BY cada vez y para que el resto
del equipo trabaje contra un resultado ya interpretado.

## 1. `vista_tabla_posiciones`

Da una fila por selección con sus partidos jugados y sus goles a favor,
agrupada por edición, país y grupo. Usa `LEFT JOIN` para que las selecciones
sin partidos también aparezcan (con conteo en cero).

Sirve como base de la tabla de posiciones por grupo: en vez de repetir el
`LEFT JOIN` a `participacion_partido` y el `GROUP BY` en cada consulta que
necesite posiciones, se consulta la vista. **Se reutiliza en la Consulta 15**
(líder de cada grupo).

## 2. `vista_goleadores`

Total de goles marcados por cada selección en cada edición, ya cruzado con el
año y el país sede del torneo.

Concentra el doble JOIN `participacion_partido → seleccion → edicion_mundial`
que necesita cualquier consulta de goleadores por edición, para que esa lógica
quede en un solo lugar.

## 3. `vista_ocupacion_estadios`

Una fila por estadio con los partidos jugados, el promedio de asistencia y el
porcentaje de ocupación (`AVG(asistencia_registrada) / capacidad * 100`).

Deja precalculada la ocupación, que si no habría que volver a escribir en cada
consulta que la use, y aplica el redondeo una sola vez. El `LEFT JOIN` mantiene
en el resultado los estadios que todavía no tienen partidos.

## 4. `vista_resumen_ediciones`

Una fila por edición con el total de estadios, selecciones y partidos de ese
Mundial (`COUNT(DISTINCT ...)` sobre tres `LEFT JOIN`).

Pensada para un panel de resumen: entrega los tres totales por edición sin que
quien consulta tenga que armar los tres conteos con junta externa cada vez.
