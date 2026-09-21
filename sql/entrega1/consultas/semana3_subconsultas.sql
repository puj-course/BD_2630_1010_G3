-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- Semana 3: consultas resueltas con subconsultas
-- ============================================================

-- Consulta 7: Selecciones invictas (no han perdido ningun partido)
SELECT s.pais
FROM seleccion s
WHERE NOT EXISTS (
    SELECT 1
    FROM participacion_partido p1
    JOIN participacion_partido p2 ON p1.id_partido = p2.id_partido AND p1.id_seleccion <> p2.id_seleccion
    WHERE p1.id_seleccion = s.id_seleccion
    AND p1.goles_marcados < p2.goles_marcados
);

-- Consulta 8: Estadios sobre el promedio de ocupacion (subconsulta correlacionada)
WITH ocupacion_estadio AS (
    SELECT
        e.id_estadio,
        e.nombre AS estadio,
        e.ciudad,
        ROUND(AVG(p.asistencia_registrada) / e.capacidad * 100, 2) AS ocupacion_pct
    FROM estadio e
    JOIN partido p ON e.id_estadio = p.id_estadio
    GROUP BY e.id_estadio, e.nombre, e.ciudad, e.capacidad
)
SELECT t.estadio, t.ciudad, t.ocupacion_pct
FROM ocupacion_estadio t
WHERE t.ocupacion_pct > (
    SELECT AVG(o2.ocupacion_pct)
    FROM ocupacion_estadio o2
    WHERE o2.id_estadio <> t.id_estadio
)
ORDER BY t.ocupacion_pct DESC;

-- Consulta 10: Selecciones con condicion exclusiva (todo local o todo visitante)
SELECT 
    s.pais,
    SUM(CASE WHEN pp.condicion = 'LOCAL' THEN 1 ELSE 0 END) AS partidos_local,
    SUM(CASE WHEN pp.condicion = 'VISITANTE' THEN 1 ELSE 0 END) AS partidos_visitante,
    COUNT(*) AS total_partidos
FROM seleccion s
JOIN participacion_partido pp ON s.id_seleccion = pp.id_seleccion
GROUP BY s.pais
HAVING SUM(CASE WHEN pp.condicion = 'LOCAL' THEN 1 ELSE 0 END) = 0
    OR SUM(CASE WHEN pp.condicion = 'VISITANTE' THEN 1 ELSE 0 END) = 0
ORDER BY s.pais;

-- Consulta 11: Selecciones con diferencia de gol por encima del promedio general
SELECT pais, diferencia_gol,
    RANK() OVER (ORDER BY diferencia_gol DESC) AS ranking
FROM (
    SELECT 
        s.pais AS pais,
        SUM(p1.goles_marcados) - SUM(p2.goles_marcados) AS diferencia_gol
    FROM seleccion s
    JOIN participacion_partido p1 ON s.id_seleccion = p1.id_seleccion
    JOIN participacion_partido p2 ON p1.id_partido = p2.id_partido AND p1.id_seleccion <> p2.id_seleccion
    GROUP BY s.pais
)
WHERE diferencia_gol > (
    SELECT AVG(dif) FROM (
        SELECT SUM(p1.goles_marcados) - SUM(p2.goles_marcados) AS dif
        FROM participacion_partido p1
        JOIN participacion_partido p2 ON p1.id_partido = p2.id_partido AND p1.id_seleccion <> p2.id_seleccion
        GROUP BY p1.id_seleccion
    )
)
ORDER BY diferencia_gol DESC;
