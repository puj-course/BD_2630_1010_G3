-- ============================================================
-- SEMANA 3 - CONSULTA SOBRE VISTA
-- ============================================================


-- ============================================================
-- CONSULTA 15
-- Selección que lidera cada grupo según la tabla parcial
-- ============================================================

SELECT
    id_edicion,
    grupo,
    pais,
    goles_a_favor
FROM (
    SELECT
        id_edicion,
        grupo,
        pais,
        goles_a_favor,
        RANK() OVER (
            PARTITION BY id_edicion, grupo
            ORDER BY goles_a_favor DESC
        ) AS posicion
    FROM vista_tabla_posiciones
    WHERE grupo IS NOT NULL
)
WHERE posicion = 1
ORDER BY
    id_edicion,
    grupo,
    pais;