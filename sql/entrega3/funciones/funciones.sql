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

-- ------------------------------------------------------------
-- 3. Puesto de un jugador en el ranking de goleadores de una edicion
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_posicion_goleador (
    p_id_jugador IN NUMBER,
    p_id_edicion IN NUMBER
) RETURN NUMBER
IS
    v_goles   NUMBER;
    v_encima  NUMBER;
BEGIN
    v_goles := fn_goles_jugador(p_id_jugador, p_id_edicion);

    -- Cuantos jugadores de la edicion tienen mas goles; los empatados comparten puesto
    SELECT COUNT(*)
    INTO v_encima
    FROM (SELECT e.id_jugador, SUM(e.goles) AS goles
          FROM estadistica_jugador_partido e
          JOIN partido p ON p.id_partido = e.id_partido
          WHERE p.id_edicion = p_id_edicion
          GROUP BY e.id_jugador)
    WHERE goles > v_goles;

    RETURN v_encima + 1;
END fn_posicion_goleador;
/

-- ------------------------------------------------------------
-- 4. Cupos libres en la convocatoria de una seleccion (maximo 26)
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_cupo_convocatoria (
    p_id_seleccion IN NUMBER
) RETURN NUMBER
IS
    c_maximo      CONSTANT NUMBER := 26;
    v_existe      NUMBER;
    v_convocados  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe
    FROM seleccion
    WHERE id_seleccion = p_id_seleccion;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'La seleccion ' || p_id_seleccion || ' no existe');
    END IF;

    SELECT COUNT(*) INTO v_convocados
    FROM convocatoria_jugador
    WHERE id_seleccion = p_id_seleccion;

    RETURN c_maximo - v_convocados;
END fn_cupo_convocatoria;
/

-- ------------------------------------------------------------
-- Pruebas rapidas
-- ------------------------------------------------------------

-- Diferencia de gol de las selecciones de la edicion 7
SELECT pais, fn_diferencia_gol(id_seleccion) AS diferencia_gol
FROM seleccion
WHERE id_edicion = 7
ORDER BY diferencia_gol DESC;

-- Top 5 goleadores de la edicion 7
SELECT *
FROM (SELECT j.nombre,
             fn_goles_jugador(j.id_jugador, 7) AS goles,
             fn_posicion_goleador(j.id_jugador, 7) AS posicion
      FROM jugador j
      WHERE EXISTS (SELECT 1
                    FROM estadistica_jugador_partido e
                    JOIN partido p ON p.id_partido = e.id_partido
                    WHERE e.id_jugador = j.id_jugador
                      AND p.id_edicion = 7))
WHERE goles > 0 AND posicion <= 5
ORDER BY posicion, nombre;

-- Cupos libres por seleccion de la edicion 7 (con 26 convocados deben dar 0)
SELECT pais, fn_cupo_convocatoria(id_seleccion) AS cupos_libres
FROM seleccion
WHERE id_edicion = 7
ORDER BY pais;

-- Seleccion que no existe: debe dar ORA-20010
SELECT fn_cupo_convocatoria(999999) FROM dual;


EXIT;
