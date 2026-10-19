-- ============================================================
-- SEMANA 3 - SUBCONSULTAS
-- ============================================================


-- ============================================================
-- CONSULTA 7
-- Selecciones invictas
-- ============================================================

SELECT
    s.id_edicion,
    s.pais
FROM seleccion s
WHERE EXISTS (
    SELECT 1
    FROM participacion_partido pp
    WHERE pp.id_seleccion = s.id_seleccion
)
AND NOT EXISTS (
    SELECT 1
    FROM participacion_partido pp1
    JOIN participacion_partido pp2
        ON pp1.id_partido = pp2.id_partido
       AND pp1.id_seleccion <> pp2.id_seleccion
    WHERE pp1.id_seleccion = s.id_seleccion
      AND pp1.goles_marcados < pp2.goles_marcados
)
ORDER BY
    s.id_edicion,
    s.pais;


-- ============================================================
-- CONSULTA 8
-- Estadios con ocupación superior al promedio general
-- ============================================================

SELECT
    e.id_estadio,
    e.nombre AS estadio,
    e.ciudad,
    ROUND(
        (
            SELECT AVG(p.asistencia_registrada)
            FROM partido p
            WHERE p.id_estadio = e.id_estadio
        ) / e.capacidad * 100,
        2
    ) AS ocupacion_pct
FROM estadio e
WHERE
    (
        SELECT AVG(p.asistencia_registrada)
        FROM partido p
        WHERE p.id_estadio = e.id_estadio
    ) / e.capacidad * 100
    >
    (
        SELECT AVG(t.ocupacion_pct)
        FROM (
            SELECT
                e2.id_estadio,
                AVG(p2.asistencia_registrada)
                    / e2.capacidad * 100 AS ocupacion_pct
            FROM estadio e2
            JOIN partido p2
                ON e2.id_estadio = p2.id_estadio
            GROUP BY
                e2.id_estadio,
                e2.capacidad
        ) t
    )
ORDER BY
    ocupacion_pct DESC;


-- ============================================================
-- CONSULTA 10
-- Selecciones cuya condición es exclusivamente LOCAL
-- o exclusivamente VISITANTE
-- ============================================================

SELECT
    s.id_edicion,
    s.pais,
    SUM(
        CASE
            WHEN pp.condicion = 'LOCAL' THEN 1
            ELSE 0
        END
    ) AS partidos_local,
    SUM(
        CASE
            WHEN pp.condicion = 'VISITANTE' THEN 1
            ELSE 0
        END
    ) AS partidos_visitante,
    COUNT(*) AS total_partidos
FROM seleccion s
JOIN participacion_partido pp
    ON s.id_seleccion = pp.id_seleccion
GROUP BY
    s.id_edicion,
    s.pais
HAVING
       SUM(
           CASE
               WHEN pp.condicion = 'LOCAL' THEN 1
               ELSE 0
           END
       ) = 0
    OR SUM(
           CASE
               WHEN pp.condicion = 'LOCAL' THEN 1
               ELSE 0
           END
       ) = COUNT(*)
ORDER BY
    s.id_edicion,
    s.pais;


-- ============================================================
-- CONSULTA 11
-- Selecciones cuya diferencia de gol está estrictamente
-- por encima del promedio general
-- ============================================================

SELECT
    id_edicion,
    pais,
    diferencia_gol
FROM (
    SELECT
        s.id_edicion,
        s.id_seleccion,
        s.pais,
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
        s.id_seleccion,
        s.pais
)
WHERE diferencia_gol > (
    SELECT AVG(diferencia_gol)
    FROM (
        SELECT
            s2.id_seleccion,
            SUM(pp2.goles_marcados)
                - SUM(rival2.goles_marcados) AS diferencia_gol
        FROM seleccion s2
        JOIN participacion_partido pp2
            ON s2.id_seleccion = pp2.id_seleccion
        JOIN participacion_partido rival2
            ON pp2.id_partido = rival2.id_partido
           AND pp2.id_seleccion <> rival2.id_seleccion
        GROUP BY
            s2.id_seleccion
    )
)
ORDER BY
    id_edicion,
    diferencia_gol DESC;