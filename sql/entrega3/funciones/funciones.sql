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
