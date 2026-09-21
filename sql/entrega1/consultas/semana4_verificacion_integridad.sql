-- ============================================================
-- Consultas SQL - Mundial FIFA (Entrega 1)
-- Semana 4: verificacion de integridad
-- ============================================================

-- Consulta 14: Verificacion de participaciones duplicadas de una seleccion en un mismo partido
-- Debe devolver 0 filas: la restriccion UNIQUE uq_participacion_seleccion del DDL
-- impide fisicamente que esto ocurra.
SELECT id_partido, id_seleccion, COUNT(*) AS veces_registrada
FROM participacion_partido
GROUP BY id_partido, id_seleccion
HAVING COUNT(*) > 1;
