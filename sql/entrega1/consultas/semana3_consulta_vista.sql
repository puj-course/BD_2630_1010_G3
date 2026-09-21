-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- Semana 3: consulta construida sobre una vista
-- Requiere haber ejecutado antes sql/entrega1/vistas/vistas.sql
-- ============================================================

-- Consulta 15: Consulta a partir de una vista: lider de cada grupo (usando vista_tabla_posiciones)
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
