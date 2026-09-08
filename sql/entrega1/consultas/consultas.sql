-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- ============================================================

-- 1. Top 5 selecciones con mas goles marcados
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

-- 2. Porcentaje de ocupacion estimado por estadio
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

-- 3. Selecciones con mayor diferencia de gol
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

-- 4. Partidos jugados por fase
SELECT 
    p.fase AS fase,
    COUNT(p.id_partido) AS num_partidos
FROM partido p
GROUP BY p.fase
ORDER BY num_partidos DESC;

-- 5. Estadio(s) con mas partidos por edicion
SELECT 
    p.id_edicion,
    e.nombre AS estadio,
    COUNT(p.id_partido) AS n_partidos
FROM estadio e
JOIN partido p ON e.id_estadio = p.id_estadio
GROUP BY p.id_edicion, e.nombre, e.id_estadio
HAVING COUNT(p.id_partido) = (
    SELECT MAX(COUNT(p2.id_partido))
    FROM partido p2
    WHERE p2.id_edicion = p.id_edicion
    GROUP BY p2.id_estadio
)
ORDER BY p.id_edicion;

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

-- 7. Selecciones invictas (no han perdido ningun partido)
SELECT s.pais
FROM seleccion s
WHERE NOT EXISTS (
    SELECT 1
    FROM participacion_partido p1
    JOIN participacion_partido p2 ON p1.id_partido = p2.id_partido AND p1.id_seleccion <> p2.id_seleccion
    WHERE p1.id_seleccion = s.id_seleccion
    AND p1.goles_marcados < p2.goles_marcados
);

-- 8. Estadios sobre el promedio de ocupacion (subconsulta correlacionada)
SELECT estadio, ciudad, ocupacion_pct
FROM (
    SELECT
        e.id_estadio,
        e.nombre AS estadio,
        e.ciudad AS ciudad,
        ROUND((COUNT(p.id_partido) * 100.0) / e.capacidad, 2) AS ocupacion_pct
    FROM estadio e
    JOIN partido p ON e.id_estadio = p.id_estadio
    GROUP BY e.id_estadio, e.nombre, e.ciudad, e.capacidad
) t
WHERE t.ocupacion_pct > (
    SELECT AVG(ocupacion_pct)
    FROM (
        SELECT (COUNT(p2.id_partido) * 100.0) / e2.capacidad AS ocupacion_pct
        FROM estadio e2
        JOIN partido p2 ON e2.id_estadio = p2.id_estadio
        WHERE e2.id_estadio <> t.id_estadio
        GROUP BY e2.id_estadio, e2.capacidad
    )
)
ORDER BY ocupacion_pct DESC;

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

-- 10. Selecciones con condicion exclusiva (todo local o todo visitante)
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

-- 11. Selecciones con diferencia de gol por encima del promedio general
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

-- 14. Verificacion de participaciones duplicadas de una seleccion en un mismo partido
-- Debe devolver 0 filas: la restriccion UNIQUE uq_participacion_seleccion del DDL
-- impide fisicamente que esto ocurra.
SELECT id_partido, id_seleccion, COUNT(*) AS veces_registrada
FROM participacion_partido
GROUP BY id_partido, id_seleccion
HAVING COUNT(*) > 1;

-- 15. Consulta a partir de una vista: lider de cada grupo (usando vista_tabla_posiciones)
SELECT id_edicion, grupo, pais, goles_a_favor
FROM (
    SELECT 
        id_edicion, grupo, pais, goles_a_favor,
        RANK() OVER (PARTITION BY id_edicion, grupo ORDER BY goles_a_favor DESC) AS pos
    FROM vista_tabla_posiciones
    WHERE grupo IS NOT NULL
)
WHERE pos = 1
ORDER BY id_edicion, grupo;
