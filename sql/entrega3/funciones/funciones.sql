-- ============================================================
-- Funciones - Entrega 3
-- ============================================================

SET SQLBLANKLINES ON


-- ------------------------------------------------------------
-- 1. Diferencia de gol de una seleccion en todos sus partidos
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_diferencia_gol (
    p_id_seleccion IN NUMBER
) RETURN NUMBER
IS
    v_diferencia NUMBER;
BEGIN
    -- Se une la participacion con la del rival del mismo partido
    SELECT NVL(SUM(pp.goles_marcados - rival.goles_marcados), 0)
    INTO v_diferencia
    FROM participacion_partido pp
    JOIN participacion_partido rival ON rival.id_partido = pp.id_partido
                                    AND rival.id_seleccion <> pp.id_seleccion
    WHERE pp.id_seleccion = p_id_seleccion;

    RETURN v_diferencia;
END fn_diferencia_gol;
/

-- ------------------------------------------------------------
-- 2. Goles de un jugador en una edicion
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_goles_jugador (
    p_id_jugador IN NUMBER,
    p_id_edicion IN NUMBER
) RETURN NUMBER
IS
    v_goles NUMBER;
BEGIN
    SELECT NVL(SUM(e.goles), 0)
    INTO v_goles
    FROM estadistica_jugador_partido e
    JOIN partido p ON p.id_partido = e.id_partido
    WHERE e.id_jugador = p_id_jugador
      AND p.id_edicion = p_id_edicion;

    RETURN v_goles;
END fn_goles_jugador;
/
