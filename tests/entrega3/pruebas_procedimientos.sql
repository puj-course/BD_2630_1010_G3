-- ============================================================
-- Casos de Prueba: Procedimientos Almacenados - Entrega 3
-- ============================================================
-- Responsable: Harold Santiago Pereira Fuentes (IS101013)
--
-- Se prueban:
--   1. PR_ACTUALIZAR_TABLA_POSICIONES
--   2. PR_REGISTRAR_RESULTADO (casos validos e invalidos)
--   3. PR_CARGA_MASIVA_RESULTADOS
--   4. PR_CIERRE_FASE
-- ============================================================

SET SQLBLANKLINES ON
SET SERVEROUTPUT ON

-- ------------------------------------------------------------
-- 1. PR_ACTUALIZAR_TABLA_POSICIONES
-- ------------------------------------------------------------
-- Caso P1: Actualizar tabla de posiciones de la edicion 7 (Catar 2022)
EXEC pr_actualizar_tabla_posiciones(7);

SELECT g.nombre AS grupo, tp.posicion, s.pais, tp.partidos_jugados AS pj,
       tp.ganados AS pg, tp.empatados AS pe, tp.perdidos AS pp,
       tp.goles_favor AS gf, tp.goles_contra AS gc, tp.diferencia_gol AS dg, tp.puntos AS pts
FROM tabla_posiciones tp
JOIN grupo g ON g.id_grupo = tp.id_grupo
JOIN seleccion s ON s.id_seleccion = tp.id_seleccion
WHERE tp.id_edicion = 7
ORDER BY g.nombre, tp.posicion;

-- Caso P2 (Fallido): Intentar actualizar edicion inexistente (debe lanzar ORA-20026)
BEGIN
    pr_actualizar_tabla_posiciones(999999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('P2 esperado: ' || SQLERRM);
END;
/


-- ------------------------------------------------------------
-- 2. PR_REGISTRAR_RESULTADO
-- ------------------------------------------------------------
-- Caso R1 (Exitoso): Registrar marcador 2-0 y asistencia 60.000 en partido 385 (Fase de Grupos)
EXEC pr_registrar_resultado(385, 2, 0, 60000);

-- Verificar que se actualizaron participaciones y partido
SELECT p.id_partido, loc.goles_marcados AS g_loc, vis.goles_marcados AS g_vis, p.asistencia_registrada
FROM partido p
JOIN participacion_partido loc ON loc.id_partido = p.id_partido AND loc.condicion = 'LOCAL'
JOIN participacion_partido vis ON vis.id_partido = p.id_partido AND vis.condicion = 'VISITANTE'
WHERE p.id_partido = 385;

-- Caso R2 (Fallido): Goles fuera de rango (16 goles, debe lanzar ORA-20023)
BEGIN
    pr_registrar_resultado(385, 16, 0, 50000);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('R2 esperado: ' || SQLERRM);
END;
/

-- Caso R3 (Fallido): Asistencia superior al aforo del estadio (aforo estadio 97 es 60.000, asistencia 80.000)
BEGIN
    pr_registrar_resultado(385, 1, 0, 80000);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('R3 esperado: ' || SQLERRM);
END;
/

-- Caso R4 (Fallido): Empate en fase eliminatoria (partido 448 es la Final, debe lanzar ORA-20025)
BEGIN
    pr_registrar_resultado(448, 2, 2, 85000);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('R4 esperado: ' || SQLERRM);
END;
/


-- ------------------------------------------------------------
-- 3. PR_CARGA_MASIVA_RESULTADOS
-- ------------------------------------------------------------
-- Limpiar y preparar filas de prueba en RESULTADO_CARGA_TEMPORAL
DELETE FROM resultado_carga_temporal WHERE id_carga >= 9001;

-- Fila 1 valida (partido 386: Inglaterra vs Iran)
INSERT INTO resultado_carga_temporal (id_carga, id_partido, goles_local, goles_visitante, asistencia, estado)
VALUES (9001, 386, 6, 2, 45000, 'PENDIENTE');

-- Fila 2 invalida (goles negativos)
INSERT INTO resultado_carga_temporal (id_carga, id_partido, goles_local, goles_visitante, asistencia, estado)
VALUES (9002, 386, -1, 2, 45000, 'PENDIENTE');

DECLARE
    v_proc NUMBER;
    v_exit NUMBER;
    v_fall NUMBER;
BEGIN
    pr_carga_masiva_resultados(7, v_proc, v_exit, v_fall);
    DBMS_OUTPUT.PUT_LINE('Carga masiva ejecutada: Procesados=' || v_proc || ', Exitosos=' || v_exit || ', Fallidos=' || v_fall);
END;
/

-- Revisar el estado registrado en la tabla temporal
SELECT id_carga, id_partido, estado, mensaje_error
FROM resultado_carga_temporal
WHERE id_carga IN (9001, 9002);

DELETE FROM resultado_carga_temporal WHERE id_carga >= 9001;


-- ------------------------------------------------------------
-- 4. PR_CIERRE_FASE
-- ------------------------------------------------------------
-- Caso C1 (Exitoso): Cierre de la fase de grupos (fase 37) en la edicion 7
EXEC pr_cierre_fase(7, 37);

-- Caso C2 (Fallido): Intentar cerrar una fase inexistente (debe lanzar ORA-20026)
BEGIN
    pr_cierre_fase(7, 99999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('C2 esperado: ' || SQLERRM);
END;
/

ROLLBACK;

EXIT;
