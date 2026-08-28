# Vistas del Modelo Inicial — Justificación

**Entrega 1 — Grupo G3 — Bases de Datos, Pontificia Universidad Javeriana**
Implementación: [`sql/entrega1/vistas/vistas.sql`](../../sql/entrega1/vistas/vistas.sql)

El enunciado (Sección 8.1.4) pide entre 4 y 5 vistas, justificando para qué sirve cada una
según tres criterios posibles: **reutilización de consultas frecuentes**, **simplificación de
la lógica para otros usuarios** de la base de datos, o **restricción del conjunto de columnas
visibles**. Se implementaron cuatro vistas, cubriendo los tres criterios.

Las vistas se diseñaron **antes** que las consultas SQL, no después. Esa decisión es
deliberada: si las vistas se escriben al final, la "reutilización" acaba siendo cosmética —
una vista creada para cumplir el requisito y una consulta que la ignora. Aquí ocurre al
revés: las consultas 1, 2, 3, 6, 7, 8, 9, 11 y 15 se apoyan en estas vistas porque sin ellas
tendrían que repetir la misma lógica compleja.

---

## Resumen

| Vista | Criterio que justifica su existencia | Consultas que la reutilizan |
|---|---|---|
| `V_RESUMEN_PARTIDO` | Simplificación de la lógica | 6, 9 |
| `V_RENDIMIENTO_SELECCION` | Reutilización de consulta frecuente | 1, 3, 7, 11 |
| `V_OCUPACION_ESTADIO` | Reutilización + centralización de una fórmula | 2, 8 |
| `V_TABLA_POSICIONES` | Simplificación + restricción del subconjunto visible | 15 |

---

## 1. `V_RESUMEN_PARTIDO`

**Criterio: simplificación de la lógica para otros usuarios.**

El modelo guarda el marcador de un partido en **dos filas** de `PARTICIPACION_PARTIDO`, una
por selección. Esa normalización es correcta, pero significa que reconstruir algo tan básico
como *"Brasil 2 – 1 Croacia en el Maracaná"* obliga a pivotar dos filas en una, con `MAX(CASE
WHEN condicion = 'LOCAL' ...)` o con una auto-junta. Nadie ajeno al diseño de la base
esperaría esa maniobra para leer un marcador.

La vista la resuelve una sola vez y expone el partido como lo entendería un periodista o un
hincha: local, visitante, marcador, sede, fase y resultado.

**Decisión de diseño relevante:** el campo `resultado` (`GANA LOCAL` / `GANA VISITANTE` /
`EMPATE`) **no se almacena en ninguna tabla, se deriva aquí**. El enunciado (Sección 8.1.2)
pide como restricción que "el resultado registrado sea consistente con el marcador". Al
derivarlo en la vista en lugar de almacenarlo, esa inconsistencia es imposible por
construcción: no hay nada que pueda desincronizarse. Es preferible a almacenar un campo
redundante y luego custodiarlo con un trigger.

---

## 2. `V_RENDIMIENTO_SELECCION`

**Criterio: reutilización de una consulta frecuente.**

Goles a favor, goles en contra y diferencia de gol son el insumo de buena parte de las
consultas analíticas del enunciado. El problema es que **los goles en contra no están
almacenados en ninguna parte**: son los goles del rival, que viven en *otra fila* de
`PARTICIPACION_PARTIDO`. Obtenerlos exige unir la tabla consigo misma buscando, para cada
participación, la del rival en ese mismo partido:

```sql
JOIN participacion_partido riv ON riv.id_partido    = pp.id_partido
                              AND riv.id_seleccion <> pp.id_seleccion
```

Esa auto-junta es exactamente el tipo de lógica que no conviene repetir: aparecería en cuatro
consultas distintas y basta equivocarse en la condición `<>` una vez para que una selección
compute como su propio rival y todos los números salgan en cero. Encapsularla aquí la escribe
—y la depura— una sola vez.

La vista cubre **todas las fases** del torneo, no solo la fase de grupos, porque las consultas
que la usan analizan el rendimiento global de cada selección.

---

## 3. `V_OCUPACION_ESTADIO`

**Criterio: reutilización + centralización de una fórmula de negocio.**

Aplica la fórmula que el propio enunciado define en la consulta 2:

```
ocupacion = asistencia_registrada / capacidad * 100
```

Se toma la **asistencia promedio** de los partidos disputados en el estadio, no la suma,
porque la capacidad es una cota *por partido*: sumar la asistencia de seis partidos y
dividirla entre el aforo daría porcentajes de varios cientos, sin significado.

Centralizar la fórmula tiene una consecuencia práctica: las consultas 2 y 8 usan
necesariamente el mismo criterio de cálculo. La consulta 8 compara cada estadio contra el
promedio general de ocupación, así que si las dos consultas calcularan la ocupación de forma
ligeramente distinta, la comparación sería inválida y el error pasaría desapercibido.

**Decisión de diseño relevante:** se usa `LEFT JOIN` hacia `PARTIDO` a propósito. Un estadio
inscrito en la edición que todavía no ha albergado ningún partido debe aparecer con cero
partidos y ocupación nula, no desaparecer del listado. Un `INNER JOIN` lo ocultaría en
silencio, que es justo el tipo de omisión que hace que un informe de ocupación mienta por
ausencia.

---

## 4. `V_TABLA_POSICIONES`

**Criterio: simplificación de la lógica + restricción del subconjunto de datos visibles.**

Es la vista con mayor valor de negocio del proyecto: la tabla de posiciones por grupo, con el
sistema de puntuación oficial de la FIFA (3 puntos por victoria, 1 por empate, 0 por derrota)
y los desempates del reglamento aplicados en orden — puntos, luego diferencia de gol, luego
goles a favor — mediante una función de ventana `RANK()`.

Un usuario final puede consultar la clasificación de un grupo sin saber que existe
`PARTICIPACION_PARTIDO`, ni que hay auto-juntas detrás, ni cómo se puntúa un empate.

**Restricción deliberada del subconjunto visible:** la vista filtra `fase = 'Fase de Grupos'`.
Las fases eliminatorias no producen una tabla de posiciones sino llaves de eliminación
directa; incluirlas generaría una clasificación que mezcla dos formatos de competencia
distintos y no significa nada. Filtrar también `grupo IS NOT NULL` excluye a las selecciones
que aún no han sido sorteadas en un grupo.

Es la vista que reutiliza la **consulta 15** del enunciado, que pide determinar qué selección
lidera cada grupo: sobre esta vista, eso se reduce a filtrar `posicion_grupo = 1`.
