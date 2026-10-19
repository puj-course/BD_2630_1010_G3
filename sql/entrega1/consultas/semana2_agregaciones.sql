-- ============================================================
-- SEMANA 2 - AGREGACIONES
-- ============================================================


-- ============================================================
-- CONSULTA 1
-- Top 5 selecciones con más goles en cada edición
-- ============================================================

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


-- ============================================================
-- CONSULTA 3
-- Selecciones con mayor diferencia de gol
-- ============================================================

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


-- ============================================================
-- CONSULTA 4
-- Partidos jugados por fase
-- ============================================================

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


-- ============================================================
-- CONSULTA 5
-- Estadios que albergaron la mayor cantidad de partidos
-- dentro de cada edición
-- ============================================================

SELECT
    p.id_edicion,
    e.id_estadio,
    e.nombre AS estadio,
    COUNT(p.id_partido) AS n_partidos
FROM estadio e
JOIN partido p
    ON e.id_estadio = p.id_estadio
GROUP BY
    p.id_edicion,
    e.id_estadio,
    e.nombre
HAVING COUNT(p.id_partido) = (
    SELECT MAX(COUNT(p2.id_partido))
    FROM partido p2
    WHERE p2.id_edicion = p.id_edicion
    GROUP BY p2.id_estadio
)
ORDER BY
    p.id_edicion,
    e.id_estadio;


-- ============================================================
-- CONSULTA 9
-- Partido con mayor cantidad de goles por estadio
-- ============================================================

SELECT
    p.id_edicion,
    e.id_estadio,
    e.nombre AS estadio,
    p.id_partido,
    p.fase,
    SUM(pp.goles_marcados) AS goles_totales
FROM estadio e
JOIN partido p
    ON e.id_estadio = p.id_estadio
JOIN participacion_partido pp
    ON p.id_partido = pp.id_partido
GROUP BY
    p.id_edicion,
    e.id_estadio,
    e.nombre,
    p.id_partido,
    p.fase
HAVING SUM(pp.goles_marcados) = (
    SELECT MAX(total_goles)
    FROM (
        SELECT
            p2.id_partido,
            SUM(pp2.goles_marcados) AS total_goles
        FROM partido p2
        JOIN participacion_partido pp2
            ON p2.id_partido = pp2.id_partido
        WHERE p2.id_estadio = e.id_estadio
          AND p2.id_edicion = p.id_edicion
        GROUP BY p2.id_partido
    )
)
ORDER BY
    p.id_edicion,
    e.id_estadio,
    p.id_partido;


-- ============================================================
-- CONSULTA 12
-- Comparación de goles en fase de grupos vs. eliminación
-- ============================================================

SELECT
    s.id_edicion,
    s.pais,
    SUM(
        CASE
            WHEN p.fase = 'Fase de Grupos'
            THEN pp.goles_marcados
            ELSE 0
        END
    ) AS goles_fase_grupos,
    SUM(
        CASE
            WHEN p.fase <> 'Fase de Grupos'
            THEN pp.goles_marcados
            ELSE 0
        END
    ) AS goles_eliminatoria
FROM seleccion s
JOIN participacion_partido pp
    ON s.id_seleccion = pp.id_seleccion
JOIN partido p
    ON pp.id_partido = p.id_partido
GROUP BY
    s.id_edicion,
    s.pais
ORDER BY
    s.id_edicion,
    s.pais;


-- ============================================================
-- CONSULTA 13
-- Estadios que albergaron partidos en más de una fase
-- ============================================================

SELECT
    p.id_edicion,
    e.id_estadio,
    e.nombre AS estadio,
    COUNT(DISTINCT p.fase) AS n_fases_distintas
FROM estadio e
JOIN partido p
    ON e.id_estadio = p.id_estadio
GROUP BY
    p.id_edicion,
    e.id_estadio,
    e.nombre
HAVING COUNT(DISTINCT p.fase) > 1
ORDER BY
    p.id_edicion,
    e.id_estadio;