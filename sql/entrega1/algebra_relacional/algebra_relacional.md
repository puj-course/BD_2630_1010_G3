# Álgebra Relacional - Entrega 1
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Traducción a notación de álgebra relacional de 4 de las 15 consultas SQL solicitadas en la Sección 8.1.9 del enunciado.

**Notación utilizada:**

| Símbolo | Nombre | Equivalente en SQL |
|---|---|---|
| σ | Selección (filtro de filas) | `WHERE` |
| π | Proyección (elige columnas) | `SELECT` |
| ⋈ | Junta interna | `JOIN` |
| ⟕ | Junta externa izquierda | `LEFT JOIN` |
| ρ | Renombre | Alias / `AS` |
| γ | Agrupación / agregación | `GROUP BY` + función agregada |
| τ | Ordenamiento | `ORDER BY` |

---

## Consulta 1 - Top 5 selecciones con más goles marcados por edición

**SQL actual:**

```sql
SELECT
    id_edicion,
    pais,
    goles_totales
FROM (
    SELECT
        s.id_edicion,
        s.pais,
        SUM(pp.goles_marcados) AS goles_totales,
        ROW_NUMBER() OVER (
            PARTITION BY s.id_edicion
            ORDER BY SUM(pp.goles_marcados) DESC
        ) AS posicion
    FROM seleccion s
    JOIN participacion_partido pp
        ON s.id_seleccion = pp.id_seleccion
    GROUP BY
        s.id_edicion,
        s.pais
)
WHERE posicion <= 5
ORDER BY
    id_edicion,
    posicion;
```

**Álgebra relacional:**

Primero se obtiene el total de goles de cada selección en cada edición:

```text
R1 =
γ_{id_edicion, pais;
   SUM(goles_marcados) → goles_totales}
(
    seleccion
    ⋈_{seleccion.id_seleccion = participacion_partido.id_seleccion}
    participacion_partido
)
```

Después se ordenan las selecciones dentro de cada edición:

```text
R2 =
τ_{id_edicion ASC, goles_totales DESC}(R1)
```

Finalmente se conservan las cinco primeras selecciones de cada edición:

```text
TOP_5_{id_edicion}(R2)
```

**Explicación:**

1. `seleccion ⋈ participacion_partido`: relaciona cada selección con sus participaciones en partidos.
2. `γ`: agrupa por edición y país y suma los goles marcados.
3. `τ`: ordena las selecciones por edición y por goles de mayor a menor.
4. `TOP_5_{id_edicion}` representa la operación de conservar las cinco primeras filas de cada edición.

**Nota:** la operación `TOP_5` por grupo no pertenece al álgebra relacional clásica. Se utiliza aquí como una extensión conceptual para representar el comportamiento de `ROW_NUMBER() OVER (PARTITION BY ...)` combinado con `WHERE posicion <= 5` en Oracle SQL.

---

## Consulta 2 - Porcentaje de ocupación estimado por estadio

**SQL actual:**

```sql
SELECT
    e.id_estadio,
    e.nombre AS estadio,
    e.ciudad,
    e.capacidad,
    ROUND(
        (AVG(p.asistencia_registrada) / e.capacidad) * 100,
        2
    ) AS ocupacion_pct
FROM estadio e
LEFT JOIN partido p
    ON e.id_estadio = p.id_estadio
GROUP BY
    e.id_estadio,
    e.nombre,
    e.ciudad,
    e.capacidad
ORDER BY ocupacion_pct DESC;
```

**Álgebra relacional:**

Primero se realiza una junta externa izquierda:

```text
R1 =
estadio
⟕_{estadio.id_estadio = partido.id_estadio}
partido
```

Se calcula el promedio de asistencia por estadio:

```text
R2 =
γ_{id_estadio, nombre, ciudad, capacidad;
   AVG(asistencia_registrada) → promedio_asistencia}
(R1)
```

Se proyectan las columnas necesarias y se calcula el porcentaje de ocupación:

```text
R3 =
π_{id_estadio,
   nombre,
   ciudad,
   capacidad,
   ROUND(
      (promedio_asistencia / capacidad) × 100,
      2
   ) → ocupacion_pct}
(R2)
```

Finalmente se ordena el resultado:

```text
τ_{ocupacion_pct DESC}(R3)
```

**Explicación:**

1. `estadio ⟕ partido`: se utiliza junta externa izquierda porque el SQL emplea `LEFT JOIN`. Esto permite conservar los estadios aunque no tengan partidos asociados.
2. `γ`: se agrupa por estadio y se calcula el promedio de `asistencia_registrada`.
3. `π`: se proyectan los atributos del estadio y se calcula el porcentaje de ocupación.
4. `τ`: se ordena el resultado de mayor a menor ocupación.

El cálculo corresponde a:

```text
ocupacion_pct =
(AVG(asistencia_registrada) / capacidad) × 100
```

---

## Consulta 3 - Selecciones con mayor diferencia de gol

**SQL actual:**

```sql
SELECT
    s.id_edicion,
    s.pais,
    SUM(pp.goles_marcados) AS goles_favor,
    SUM(rival.goles_marcados) AS goles_contra,
    SUM(pp.goles_marcados)
        - SUM(rival.goles_marcados) AS diferencia_gol
FROM seleccion s
JOIN participacion_partido pp
    ON s.id_seleccion = pp.id_seleccion
JOIN participacion_partido rival
    ON pp.id_partido = rival.id_partido
   AND pp.id_seleccion <> rival.id_seleccion
GROUP BY
    s.id_edicion,
    s.pais
ORDER BY
    s.id_edicion,
    diferencia_gol DESC;
```

Como `PARTICIPACION_PARTIDO` participa dos veces, se renombran sus dos instancias:

```text
ρ_{pp}(participacion_partido)
ρ_{rival}(participacion_partido)
```

Luego se realiza la junta:

```text
R1 =
seleccion
⋈_{seleccion.id_seleccion = pp.id_seleccion}
ρ_{pp}(participacion_partido)
⋈_{pp.id_partido = rival.id_partido
   ∧ pp.id_seleccion ≠ rival.id_seleccion}
ρ_{rival}(participacion_partido)
```

Se agrupa por edición y selección:

```text
R2 =
γ_{id_edicion, pais;
   SUM(pp.goles_marcados) → goles_favor,
   SUM(rival.goles_marcados) → goles_contra}
(R1)
```

Se calcula la diferencia de gol:

```text
R3 =
π_{id_edicion,
   pais,
   goles_favor,
   goles_contra,
   (goles_favor - goles_contra) → diferencia_gol}
(R2)
```

Finalmente se ordena:

```text
τ_{id_edicion ASC, diferencia_gol DESC}(R3)
```

**Explicación:**

1. `ρ` permite utilizar dos instancias de `participacion_partido`.
2. `pp` representa la participación de la selección analizada.
3. `rival` representa la otra selección del mismo partido.
4. `γ` calcula los goles a favor y en contra por selección y edición.
5. La diferencia de gol se obtiene como:

```text
diferencia_gol = goles_favor - goles_contra
```

---

## Consulta 4 - Partidos jugados por fase

**SQL actual:**

```sql
SELECT
    p.id_edicion,
    p.fase,
    COUNT(p.id_partido) AS num_partidos
FROM partido p
GROUP BY
    p.id_edicion,
    p.fase
ORDER BY
    p.id_edicion,
    num_partidos DESC;
```

Se agrupa la relación `partido` por edición y fase:

```text
R1 =
γ_{id_edicion, fase;
   COUNT(id_partido) → num_partidos}
(partido)
```

Después se proyectan las columnas finales:

```text
R2 =
π_{id_edicion, fase, num_partidos}(R1)
```

Y finalmente se ordena:

```text
τ_{id_edicion ASC, num_partidos DESC}(R2)
```

**Explicación:**

1. `γ_{id_edicion, fase; COUNT(...)}` agrupa los partidos por edición y fase.
2. `COUNT(id_partido)` determina cuántos partidos corresponden a cada fase.
3. `π` conserva las columnas solicitadas.
4. `τ` ordena primero por edición y dentro de cada edición de mayor a menor cantidad de partidos.

---

## Correspondencia con las consultas SQL

Las cuatro consultas traducidas mantienen la misma lógica de las consultas SQL actualmente implementadas en el proyecto:

| Consulta | Operaciones principales |
|---|---|
| Consulta 1 | `⋈`, `γ`, `τ` y extensión `TOP-N` |
| Consulta 2 | `⟕`, `γ`, `π`, `τ` |
| Consulta 3 | `ρ`, `⋈`, `γ`, `π`, `τ` |
| Consulta 4 | `γ`, `π`, `τ` |

Las cuatro traducciones corresponden a las versiones actuales de las consultas SQL almacenadas en:

```text
sql/entrega1/consultas/
```

De esta manera, la representación en álgebra relacional permanece consistente con la implementación SQL final de la Entrega 1.
