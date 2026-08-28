-- =============================================================================
--  Entrega 1 - Consultas SQL sobre el modelo inicial
--  Bloque: CONSULTA SOBRE VISTA  (Consulta 15 del enunciado)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
--
--  Requiere que se haya ejecutado antes sql/entrega1/vistas/vistas.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Consulta 15: Que seleccion lidera cada grupo.
--
--   Es la consulta que el enunciado pide construir a partir de una de las vistas
--   creadas (Seccion 8.1.9, numeral 15), tomando como ejemplo la vista de tabla
--   de posiciones parcial.
--
--   Aqui se ve el valor real de haber disenado las vistas antes que las
--   consultas. V_TABLA_POSICIONES ya resuelve, de una sola vez:
--
--     * la auto-junta que permite conocer los goles en contra,
--     * el sistema de puntuacion oficial de la FIFA (3 / 1 / 0),
--     * los desempates del reglamento en orden: puntos, diferencia de gol y
--       goles a favor, mediante RANK(),
--     * y la restriccion a fase de grupos, que es la unica donde una tabla de
--       posiciones tiene sentido.
--
--   Con todo eso encapsulado, "quien lidera cada grupo" se reduce a filtrar la
--   primera posicion. Sin la vista, esta misma consulta necesitaria una funcion
--   de ventana sobre una agregacion sobre una auto-junta.
--
--   Se usa RANK() y no ROW_NUMBER() de forma deliberada: si dos selecciones
--   empatan en puntos, diferencia de gol y goles a favor, estan genuinamente
--   empatadas en el liderato y ambas deben aparecer. ROW_NUMBER() elegiria una
--   de las dos de forma arbitraria y ocultaria el empate.
-- -----------------------------------------------------------------------------

SELECT
    anio,
    grupo,
    pais                AS lider_del_grupo,
    confederacion,
    partidos_jugados,
    ganados,
    empatados,
    perdidos,
    goles_favor,
    goles_contra,
    diferencia_gol,
    puntos
FROM v_tabla_posiciones
WHERE posicion_grupo = 1
ORDER BY anio, grupo, pais;


-- -----------------------------------------------------------------------------
-- Consulta complementaria (no exigida): la tabla de posiciones completa de un
-- grupo, tal como la publicaria la FIFA. Se incluye para evidenciar que la
-- vista no sirve solo para la consulta anterior.
-- -----------------------------------------------------------------------------

SELECT
    anio,
    grupo,
    posicion_grupo AS pos,
    pais,
    partidos_jugados AS pj,
    ganados          AS g,
    empatados        AS e,
    perdidos         AS p,
    goles_favor      AS gf,
    goles_contra     AS gc,
    diferencia_gol   AS dg,
    puntos           AS pts
FROM v_tabla_posiciones
ORDER BY anio, grupo, posicion_grupo, pais;
