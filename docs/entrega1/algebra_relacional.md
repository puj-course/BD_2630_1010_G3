# Álgebra Relacional — Entrega 1
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Traducción a notación de álgebra relacional de 4 de las 15 consultas SQL solicitadas en la Sección 8.1.9 del enunciado.

**Notación utilizada:**

| Símbolo | Nombre | Equivalente en SQL |
|---|---|---|
| σ | Selección (filtro de filas) | `WHERE` |
| π | Proyección (elige columnas) | `SELECT` |
| ⋈ | Junta interna | `JOIN` |
| ⟕ | Junta externa izquierda | `LEFT JOIN` |
| ρ | Renombre | `AS` |
| γ | Agrupación / agregación | `GROUP BY` + función agregada |
| τ | Ordenamiento | `ORDER BY` |

---

## Consulta 1 — Top 5 selecciones con más goles marcados

**SQL original:**
```sql
SELECT pais, goles_totales
FROM (
    SELECT
        s.pais AS pais,
        SUM(pp.goles_marcados) AS goles_totales
    FROM seleccion s
    JOIN participacion_partido pp ON s.id_seleccion = pp.id_seleccion
    GROUP BY s.pais
    ORDER BY SUM(pp.goles_marcados) DESC
)
WHERE ROWNUM <= 5;
```

**Álgebra relacional:**
```
τ_{goles_totales DESC} (
  π_{pais, goles_totales} (
    _{pais} γ_{SUM(goles_marcados) → goles_totales} (
      seleccion ⋈_{seleccion.id_seleccion = participacion_partido.id_seleccion} participacion_partido
    )
  )
)
```

**Explicación:**
1. `seleccion ⋈ participacion_partido`: se juntan las dos tablas por la llave foránea `id_seleccion`.
2. `γ_pais SUM(goles_marcados)`: se agrupa por país y se suma el total de goles marcados (equivalente al `GROUP BY` con función agregada).
3. `π pais, goles_totales`: se proyectan únicamente las columnas necesarias para el resultado.
4. `τ goles_totales DESC`: se ordena de mayor a menor.

**Limitación de la notación:** el álgebra relacional clásica no cuenta con un operador estándar para "tomar únicamente las primeras N filas" (el `WHERE ROWNUM <= 5` de Oracle). Esta es una operación de tipo *top-N*, propia de las extensiones prácticas de SQL sobre los motores
relacionales, y no forma parte de las operaciones fundamentales del álgebra relacional (σ, π, ⋈, ρ, ∪, ∩, −). Por esta razón no se incluye un operador para ese paso final.

---

## Consulta 2 — Porcentaje de ocupación estimado por estadio

**SQL original:**
```sql
SELECT
    e.nombre AS estadio,
    e.ciudad AS ciudad,
    e.capacidad AS capacidad,
    COUNT(p.id_partido) AS partidos_jugados,
    ROUND((COUNT(p.id_partido) * 100.0) / e.capacidad, 2) AS ocupacion_pct
FROM estadio e
LEFT JOIN partido p ON e.id_estadio = p.id_estadio
GROUP BY e.nombre, e.ciudad, e.capacidad
ORDER BY ocupacion_pct DESC;
```

**Álgebra relacional:**
```
τ_{ocupacion_pct DESC} (
  π_{nombre, ciudad, capacidad, partidos_jugados, ocupacion_pct} (
    _{nombre, ciudad, capacidad} γ_{COUNT(id_partido) → partidos_jugados} (
      estadio ⟕_{estadio.id_estadio = partido.id_estadio} partido
    )
  )
)
```

**Explicación:**
1. `estadio ⟕ partido`: se usa junta externa izquierda (⟕), no una junta interna (⋈), porque el SQL original usa `LEFT JOIN`. Esto es necesario para que un estadio que aún no tiene ningún partido jugado siga apareciendo en el resultado (con conteo en cero), en vez de desaparecer como ocurriría con una junta interna.
2. `γ_{nombre,ciudad,capacidad} COUNT(id_partido)`: se agrupa por estadio y se cuenta cuántos partidos tiene asociados.
3. `π`: se proyectan las columnas finales, incluyendo el cálculo de ocupación.
4. `τ ocupacion_pct DESC`: se ordena de mayor a menor ocupación.

---

## Consulta 3 — Selecciones con mayor diferencia de gol

**SQL original:**
```sql
SELECT
    s.pais AS pais,
    SUM(p1.goles_marcados) AS goles_favor,
    SUM(p2.goles_marcados) AS goles_contra,
    (SUM(p1.goles_marcados) - SUM(p2.goles_marcados)) AS diferencia_gol
FROM seleccion s
JOIN participacion_partido p1 ON s.id_seleccion = p1.id_seleccion
JOIN participacion_partido p2 ON p1.id_partido = p2.id_partido AND p1.id_seleccion <> p2.id_seleccion
GROUP BY s.pais
ORDER BY diferencia_gol DESC;
```

**Álgebra relacional:**
```
ρ_{p1}(participacion_partido)
ρ_{p2}(participacion_partido)

τ_{diferencia_gol DESC} (
  π_{pais, goles_favor, goles_contra, diferencia_gol} (
    _{pais} γ_{SUM(p1.goles_marcados) → goles_favor, SUM(p2.goles_marcados) → goles_contra} (
      σ_{p1.id_seleccion ≠ p2.id_seleccion} (
        seleccion ⋈_{seleccion.id_seleccion = p1.id_seleccion} p1
                  ⋈_{p1.id_partido = p2.id_partido} p2
      )
    )
  )
)
```

**Explicación:**
1. `ρ_{p1}` y `ρ_{p2}`: la tabla `participacion_partido` se necesita comparar consigo misma (autojunta), ya que hay que enfrentar la participación de "mi selección" contra la del rival dentro del mismo partido. El renombre (ρ) crea dos alias distintos de la misma tabla, para que el motor pueda distinguir cuál instancia es cuál.
2. `seleccion ⋈ p1 ⋈ p2`: se junta primero `seleccion` con `p1` (mi participación), y luego con `p2` (la participación rival) usando el mismo `id_partido`.
3. `σ p1.id_seleccion ≠ p2.id_seleccion`: filtro que garantiza que `p2` corresponda a la *otra* selección del partido, no a la misma fila comparada consigo misma.
4. `γ_pais SUM(...)`: se agrupan los resultados por país, sumando goles a favor y en contra.
5. `π` y `τ`: se proyectan las columnas finales y se ordena por diferencia de gol descendente.

---

## Consulta 4 — Partidos jugados por fase

**SQL original:**
```sql
SELECT
    p.fase AS fase,
    COUNT(p.id_partido) AS num_partidos
FROM partido p
GROUP BY p.fase
ORDER BY num_partidos DESC;
```

**Álgebra relacional:**
```
τ_{num_partidos DESC} (
  π_{fase, num_partidos} (
    _{fase} γ_{COUNT(id_partido) → num_partidos} ( partido )
  )
)
```

**Explicación:**
1. `γ_fase COUNT(id_partido)`: se agrupa la tabla `partido` por su columna `fase` y se cuenta cuántos partidos hay en cada una.
2. `π fase, num_partidos`: se proyectan las columnas finales.
3. `τ num_partidos DESC`: se ordena de la fase con más partidos a la que tiene menos.


