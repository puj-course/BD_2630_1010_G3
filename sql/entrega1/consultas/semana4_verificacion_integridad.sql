-- ============================================================
-- SEMANA 4 - VERIFICACIÓN DE INTEGRIDAD
-- ============================================================


-- ============================================================
-- CONSULTA 14
-- Identificación de participaciones duplicadas
-- de una selección en un mismo partido
-- ============================================================

SELECT
    id_partido,
    id_seleccion,
    COUNT(*) AS veces_registrada
FROM participacion_partido
GROUP BY
    id_partido,
    id_seleccion
HAVING COUNT(*) > 1
ORDER BY
    id_partido,
    id_seleccion;