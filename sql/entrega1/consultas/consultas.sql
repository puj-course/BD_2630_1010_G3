-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- ============================================================



-- 6. Partidos con patrones atipicos (marcador alto o sin goles)
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

-- 9. Partido con mayor marcador combinado por estadio
SELECT e.nombre AS estadio, pg.id_partido, pg.fase, pg.goles_totales
FROM (
    SELECT p.id_estadio, p.id_partido, p.fase, SUM(pp.goles_marcados) AS goles_totales
    FROM partido p
    JOIN participacion_partido pp ON p.id_partido = pp.id_partido
    GROUP BY p.id_estadio, p.id_partido, p.fase
) pg
JOIN estadio e ON e.id_estadio = pg.id_estadio
WHERE pg.goles_totales = (
    SELECT MAX(goles_totales)
    FROM (
        SELECT p2.id_partido, SUM(pp2.goles_marcados) AS goles_totales
        FROM partido p2
        JOIN participacion_partido pp2 ON p2.id_partido = pp2.id_partido
        WHERE p2.id_estadio = pg.id_estadio
        GROUP BY p2.id_partido
    )
)
ORDER BY estadio, pg.id_partido;

-- 12. Goles en fase de grupos vs. fase eliminatoria por seleccion
SELECT s.pais,
    SUM(CASE WHEN p.fase = 'Fase de Grupos' THEN pp.goles_marcados ELSE 0 END) AS goles_fase_grupos,
    SUM(CASE WHEN p.fase <> 'Fase de Grupos' THEN pp.goles_marcados ELSE 0 END) AS goles_eliminatoria
FROM seleccion s
JOIN participacion_partido pp ON s.id_seleccion = pp.id_seleccion
JOIN partido p ON pp.id_partido = p.id_partido
GROUP BY s.pais
ORDER BY s.pais;

-- 13. Estadios que hayan albergado partidos en mas de una fase distinta
SELECT e.nombre AS estadio,
    COUNT(DISTINCT p.fase) AS n_fases_distintas
FROM estadio e
JOIN partido p ON e.id_estadio = p.id_estadio
GROUP BY e.nombre
HAVING COUNT(DISTINCT p.fase) > 1
ORDER BY estadio;
