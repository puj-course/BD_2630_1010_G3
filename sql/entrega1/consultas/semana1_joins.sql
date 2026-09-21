-- ============================================================
-- SEMANA 1 - JOINS
-- ============================================================


-- ============================================================
-- CONSULTA 2
-- Porcentaje de ocupación estimado por estadio
-- ============================================================

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


-- ============================================================
-- CONSULTA 6
-- Identificación de patrones atípicos
-- ============================================================

-- Regla definida por el equipo:
-- 1. 5 o más goles totales = marcador inusualmente alto.
-- 2. 0 goles totales = partido sin goles (0-0).

SELECT
    p.id_edicion,
    p.id_partido,
    p.fase,
    SUM(pp.goles_marcados) AS goles_totales,
    CASE
        WHEN SUM(pp.goles_marcados) >= 5
            THEN 'MARCADOR ALTO'
        WHEN SUM(pp.goles_marcados) = 0
            THEN 'SIN GOLES'
    END AS patron
FROM partido p
JOIN participacion_partido pp
    ON p.id_partido = pp.id_partido
GROUP BY
    p.id_edicion,
    p.id_partido,
    p.fase
HAVING
       SUM(pp.goles_marcados) >= 5
    OR SUM(pp.goles_marcados) = 0
ORDER BY
    p.id_edicion,
    p.id_partido;