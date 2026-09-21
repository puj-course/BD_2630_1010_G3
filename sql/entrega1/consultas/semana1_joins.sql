-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- Semana 1: consultas resueltas con juntas
-- ============================================================

-- Consulta 2: Porcentaje de ocupacion estimado por estadio
SELECT
    e.nombre AS estadio,
    e.ciudad AS ciudad,
    e.capacidad AS capacidad,
    COUNT(p.id_partido) AS partidos_jugados,
    ROUND(AVG(p.asistencia_registrada) / e.capacidad * 100, 2) AS ocupacion_pct
FROM estadio e
LEFT JOIN partido p ON e.id_estadio = p.id_estadio
GROUP BY e.nombre, e.ciudad, e.capacidad
ORDER BY ocupacion_pct DESC;

-- Consulta 6: Partidos con patrones atipicos (marcador alto o sin goles)
SELECT 
    p.id_partido,
    p.id_edicion,
    p.fase,
    SUM(pp.goles_marcados) AS goles_totales,
    CASE 
        WHEN SUM(pp.goles_marcados) >= 5 THEN 'MARCADOR ALTO'
        WHEN SUM(pp.goles_marcados) = 0 THEN 'SIN GOLES'
    END AS patron
FROM partido p
JOIN participacion_partido pp ON p.id_partido = pp.id_partido
GROUP BY p.id_partido, p.id_edicion, p.fase
HAVING SUM(pp.goles_marcados) >= 5 OR SUM(pp.goles_marcados) = 0
ORDER BY p.id_partido;
