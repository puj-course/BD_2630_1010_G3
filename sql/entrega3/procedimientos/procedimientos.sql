-- ============================================================
-- Procedimientos Almacenados - Entrega 3
-- ============================================================
-- Responsable: Harold Santiago Pereira Fuentes (IS101013)
--
-- Contenido:
--   1. Tabla TABLA_POSICIONES y tabla RESULTADO_CARGA_TEMPORAL
--   2. Procedimiento PR_ACTUALIZAR_TABLA_POSICIONES
--   3. Procedimiento PR_REGISTRAR_RESULTADO
--   4. Procedimiento PR_CARGA_MASIVA_RESULTADOS
--   5. Procedimiento PR_CIERRE_FASE
--   6. Bloque de pruebas y validaciones
-- ============================================================

SET SQLBLANKLINES ON
SET SERVEROUTPUT ON

-- ------------------------------------------------------------
-- 1. Tabla TABLA_POSICIONES
-- ------------------------------------------------------------
-- Almacena la tabla de posiciones calculada automaticamente
-- para cada grupo de una edicion mundialista.
-- ------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE tabla_posiciones (
            id_posicion       NUMBER(10) NOT NULL,
            id_edicion        NUMBER(10) NOT NULL,
            id_grupo          NUMBER(10) NOT NULL,
            id_seleccion      NUMBER(10) NOT NULL,
            partidos_jugados  NUMBER(3)  DEFAULT 0 NOT NULL,
            ganados           NUMBER(3)  DEFAULT 0 NOT NULL,
            empatados         NUMBER(3)  DEFAULT 0 NOT NULL,
            perdidos          NUMBER(3)  DEFAULT 0 NOT NULL,
            goles_favor       NUMBER(3)  DEFAULT 0 NOT NULL,
            goles_contra      NUMBER(3)  DEFAULT 0 NOT NULL,
            diferencia_gol    NUMBER(4)  DEFAULT 0 NOT NULL,
            puntos            NUMBER(3)  DEFAULT 0 NOT NULL,
            posicion          NUMBER(2)  DEFAULT 0 NOT NULL,
            CONSTRAINT pk_tabla_posiciones PRIMARY KEY (id_posicion),
            CONSTRAINT fk_pos_edicion FOREIGN KEY (id_edicion)
                REFERENCES edicion_mundial (id_edicion),
            CONSTRAINT fk_pos_grupo FOREIGN KEY (id_grupo)
                REFERENCES grupo (id_grupo),
            CONSTRAINT fk_pos_seleccion FOREIGN KEY (id_seleccion)
                REFERENCES seleccion (id_seleccion),
            CONSTRAINT uq_pos_edicion_sel UNIQUE (id_edicion, id_seleccion)
        )';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN
            RAISE;
        END IF;
END;
/

-- ------------------------------------------------------------
-- Tabla de soporte: RESULTADO_CARGA_TEMPORAL
-- Para la carga masiva controlada de resultados
-- ------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE resultado_carga_temporal (
            id_carga          NUMBER(10) NOT NULL,
            id_partido        NUMBER(10) NOT NULL,
            goles_local       NUMBER(3)  NOT NULL,
            goles_visitante   NUMBER(3)  NOT NULL,
            asistencia        NUMBER(10),
            estado            VARCHAR2(20) DEFAULT ''PENDIENTE'' NOT NULL,
            mensaje_error     VARCHAR2(300),
            CONSTRAINT pk_resultado_carga PRIMARY KEY (id_carga)
        )';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN
            RAISE;
        END IF;
END;
/


-- ------------------------------------------------------------
-- 2. Procedimiento PR_ACTUALIZAR_TABLA_POSICIONES
-- ------------------------------------------------------------
-- Recalcula de forma automatica y consolida la tabla de
-- posiciones por grupo para una edicion determinada.
-- Aplica los criterios oficiales:
--   1. Puntos (3 por victoria, 1 por empate, 0 por derrota)
--   2. Diferencia de gol (GF - GC)
--   3. Goles a favor (GF)
--   4. Nombre del pais (desempate alfabetico)
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE pr_actualizar_tabla_posiciones (
    p_id_edicion IN NUMBER
)
IS
    v_existe_edicion NUMBER;
    v_id_posicion    NUMBER := 0;

    CURSOR c_posiciones IS
        WITH resultados AS (
            SELECT pp.id_seleccion,
                   pp.goles_marcados AS gf,
                   rival.goles_marcados AS gc
            FROM participacion_partido pp
            JOIN participacion_partido rival ON rival.id_partido = pp.id_partido
                                            AND rival.id_seleccion <> pp.id_seleccion
            JOIN partido p ON p.id_partido = pp.id_partido
            JOIN fase f ON f.id_fase = p.id_fase
            WHERE f.tipo = 'GRUPOS'
              AND p.id_edicion = p_id_edicion
              AND p.asistencia_registrada IS NOT NULL
        ),
        acumulado AS (
            SELECT s.id_grupo,
                   s.id_seleccion,
                   s.pais,
                   COUNT(r.id_seleccion) AS jugados,
                   NVL(SUM(CASE WHEN r.gf > r.gc THEN 1 ELSE 0 END), 0) AS ganados,
                   NVL(SUM(CASE WHEN r.gf = r.gc THEN 1 ELSE 0 END), 0) AS empatados,
                   NVL(SUM(CASE WHEN r.gf < r.gc THEN 1 ELSE 0 END), 0) AS perdidos,
                   NVL(SUM(r.gf), 0) AS goles_favor,
                   NVL(SUM(r.gc), 0) AS goles_contra,
                   NVL(SUM(r.gf - r.gc), 0) AS diferencia,
                   NVL(SUM(CASE WHEN r.gf > r.gc THEN 3 WHEN r.gf = r.gc THEN 1 ELSE 0 END), 0) AS puntos
            FROM seleccion s
            JOIN grupo g ON g.id_grupo = s.id_grupo
            JOIN fase f ON f.id_fase = g.id_fase
            LEFT JOIN resultados r ON r.id_seleccion = s.id_seleccion
            WHERE s.id_edicion = p_id_edicion
              AND f.id_edicion = p_id_edicion
              AND f.tipo = 'GRUPOS'
            GROUP BY s.id_grupo, s.id_seleccion, s.pais
        )
        SELECT id_grupo,
               id_seleccion,
               jugados,
               ganados,
               empatados,
               perdidos,
               goles_favor,
               goles_contra,
               diferencia,
               puntos,
               ROW_NUMBER() OVER (
                   PARTITION BY id_grupo
                   ORDER BY puntos DESC, diferencia DESC, goles_favor DESC, pais ASC
               ) AS posicion
        FROM acumulado
        ORDER BY id_grupo, posicion;
BEGIN
    SELECT COUNT(*) INTO v_existe_edicion
    FROM edicion_mundial
    WHERE id_edicion = p_id_edicion;

    IF v_existe_edicion = 0 THEN
        RAISE_APPLICATION_ERROR(-20026, 'La edicion ' || p_id_edicion || ' no existe');
    END IF;

    -- Borra posiciones previas de esta edicion para refrescar la clasificacion
    DELETE FROM tabla_posiciones WHERE id_edicion = p_id_edicion;

    SELECT NVL(MAX(id_posicion), 0) INTO v_id_posicion FROM tabla_posiciones;

    FOR r IN c_posiciones LOOP
        v_id_posicion := v_id_posicion + 1;
        INSERT INTO tabla_posiciones (
            id_posicion, id_edicion, id_grupo, id_seleccion,
            partidos_jugados, ganados, empatados, perdidos,
            goles_favor, goles_contra, diferencia_gol, puntos, posicion
        ) VALUES (
            v_id_posicion, p_id_edicion, r.id_grupo, r.id_seleccion,
            r.jugados, r.ganados, r.empatados, r.perdidos,
            r.goles_favor, r.goles_contra, r.diferencia, r.puntos, r.posicion
        );
    END LOOP;
END pr_actualizar_tabla_posiciones;
/


-- ------------------------------------------------------------
-- 3. Procedimiento PR_REGISTRAR_RESULTADO
-- ------------------------------------------------------------
-- Registra de forma controlada el marcador final y la asistencia
-- de un partido, validando:
--   - Existencia del partido y de sus 2 participaciones (local/visitante)
--   - Rango valido de goles (0 a 15)
--   - Asistencia valida (no negativa y no superior a capacidad de estadio)
--   - Prohibicion de empate en fases eliminatorias
-- Si el partido es de fase de grupos, actualiza automaticamente
-- la tabla de posiciones de la edicion correspondiente.
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE pr_registrar_resultado (
    p_id_partido      IN NUMBER,
    p_goles_local     IN NUMBER,
    p_goles_visitante IN NUMBER,
    p_asistencia      IN NUMBER
)
IS
    v_id_edicion      NUMBER;
    v_tipo_fase       VARCHAR2(20);
    v_capacidad       NUMBER;
    v_id_part_local   NUMBER;
    v_id_part_vis     NUMBER;
    v_count_part      NUMBER;
BEGIN
    -- 1. Validar existencia del partido, su fase y estadio
    BEGIN
        SELECT p.id_edicion, f.tipo, e.capacidad
        INTO v_id_edicion, v_tipo_fase, v_capacidad
        FROM partido p
        JOIN fase f ON f.id_fase = p.id_fase
        JOIN estadio e ON e.id_estadio = p.id_estadio
        WHERE p.id_partido = p_id_partido;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20021, 'El partido ' || p_id_partido || ' no existe');
    END;

    -- 2. Validar rango de goles
    IF p_goles_local IS NULL OR p_goles_local < 0 OR p_goles_local > 15 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Goles del local fuera de rango (0-15): ' || NVL(TO_CHAR(p_goles_local), 'NULL'));
    END IF;
    IF p_goles_visitante IS NULL OR p_goles_visitante < 0 OR p_goles_visitante > 15 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Goles del visitante fuera de rango (0-15): ' || NVL(TO_CHAR(p_goles_visitante), 'NULL'));
    END IF;

    -- 3. Validar asistencia
    IF p_asistencia IS NOT NULL THEN
        IF p_asistencia < 0 THEN
            RAISE_APPLICATION_ERROR(-20024, 'La asistencia no puede ser negativa');
        END IF;
        IF p_asistencia > v_capacidad THEN
            RAISE_APPLICATION_ERROR(-20024, 'La asistencia (' || p_asistencia ||
                ') supera la capacidad del estadio (' || v_capacidad || ')');
        END IF;
    END IF;

    -- 4. Validar empate en fase eliminatoria
    IF UPPER(TRIM(v_tipo_fase)) = 'ELIMINATORIA' AND p_goles_local = p_goles_visitante THEN
        RAISE_APPLICATION_ERROR(-20025, 'Un partido de fase eliminatoria no puede terminar en empate');
    END IF;

    -- 5. Validar que existan las 2 participaciones reglamentarias
    SELECT COUNT(*) INTO v_count_part
    FROM participacion_partido
    WHERE id_partido = p_id_partido;

    IF v_count_part <> 2 THEN
        RAISE_APPLICATION_ERROR(-20022, 'El partido debe tener exactamente dos selecciones participantes');
    END IF;

    BEGIN
        SELECT id_participacion INTO v_id_part_local
        FROM participacion_partido
        WHERE id_partido = p_id_partido AND condicion = 'LOCAL';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20022, 'El partido no tiene seleccion local asignada');
    END;

    BEGIN
        SELECT id_participacion INTO v_id_part_vis
        FROM participacion_partido
        WHERE id_partido = p_id_partido AND condicion = 'VISITANTE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20022, 'El partido no tiene seleccion visitante asignada');
    END;

    -- 6. Actualizar goles
    UPDATE participacion_partido
    SET goles_marcados = p_goles_local
    WHERE id_participacion = v_id_part_local;

    UPDATE participacion_partido
    SET goles_marcados = p_goles_visitante
    WHERE id_participacion = v_id_part_vis;

    -- 7. Actualizar asistencia (si es nula se registra 0 para formalizar que el partido fue disputado)
    UPDATE partido
    SET asistencia_registrada = NVL(p_asistencia, 0)
    WHERE id_partido = p_id_partido;

    -- 8. Actualizar automaticamente tabla de posiciones si es fase de grupos
    IF v_tipo_fase = 'GRUPOS' THEN
        pr_actualizar_tabla_posiciones(v_id_edicion);
    END IF;
END pr_registrar_resultado;
/


-- ------------------------------------------------------------
-- 4. Procedimiento PR_CARGA_MASIVA_RESULTADOS
-- ------------------------------------------------------------
-- Procesa de forma controlada un lote de resultados pendientes
-- desde RESULTADO_CARGA_TEMPORAL para una edicion.
-- Cada resultado se valida con savepoints individuales:
-- si una fila tiene error, se registra el motivo y se continua
-- con las demas filas del lote.
-- Al finalizar actualiza la tabla de posiciones.
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE pr_carga_masiva_resultados (
    p_id_edicion IN  NUMBER,
    p_procesados OUT NUMBER,
    p_exitosos   OUT NUMBER,
    p_fallidos   OUT NUMBER
)
IS
    v_existe_edicion NUMBER;
    v_mensaje        VARCHAR2(300);
    CURSOR c_cargas IS
        SELECT rct.id_carga, rct.id_partido, rct.goles_local, rct.goles_visitante, rct.asistencia
        FROM resultado_carga_temporal rct
        LEFT JOIN partido p ON p.id_partido = rct.id_partido
        WHERE rct.estado = 'PENDIENTE'
          AND (p.id_edicion = p_id_edicion OR p.id_partido IS NULL)
        ORDER BY rct.id_carga;
BEGIN
    p_procesados := 0;
    p_exitosos := 0;
    p_fallidos := 0;

    SELECT COUNT(*) INTO v_existe_edicion
    FROM edicion_mundial
    WHERE id_edicion = p_id_edicion;

    IF v_existe_edicion = 0 THEN
        RAISE_APPLICATION_ERROR(-20026, 'La edicion ' || p_id_edicion || ' no existe');
    END IF;

    FOR r IN c_cargas LOOP
        p_procesados := p_procesados + 1;
        BEGIN
            SAVEPOINT sp_resultado;
            pr_registrar_resultado(
                p_id_partido      => r.id_partido,
                p_goles_local     => r.goles_local,
                p_goles_visitante => r.goles_visitante,
                p_asistencia      => r.asistencia
            );
            UPDATE resultado_carga_temporal
            SET estado = 'PROCESADO', mensaje_error = NULL
            WHERE id_carga = r.id_carga;
            p_exitosos := p_exitosos + 1;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO sp_resultado;
                -- SQLERRM no se puede usar dentro de un UPDATE, se guarda antes en una variable
                v_mensaje := SUBSTR(SQLERRM, 1, 300);
                UPDATE resultado_carga_temporal
                SET estado = 'ERROR', mensaje_error = v_mensaje
                WHERE id_carga = r.id_carga;
                p_fallidos := p_fallidos + 1;
        END;
    END LOOP;

    pr_actualizar_tabla_posiciones(p_id_edicion);
END pr_carga_masiva_resultados;
/


-- ------------------------------------------------------------
-- 5. Procedimiento PR_CIERRE_FASE
-- ------------------------------------------------------------
-- Realiza el cierre formal de una fase del torneo:
--   - Valida que todos los partidos de la fase esten jugados
--     (con asistencia registrada y participaciones completas).
--   - En fases eliminatorias valida que ningun encuentro termine en empate.
--   - Si es fase de grupos: genera la tabla de posiciones definitiva.
--   - Si es eliminatoria: identifica los ganadores de cada llave y los
--     avanza automaticamente al partido siguiente (id_partido_siguiente).
-- ------------------------------------------------------------

CREATE OR REPLACE PROCEDURE pr_cierre_fase (
    p_id_edicion IN NUMBER,
    p_id_fase    IN NUMBER
)
IS
    v_nombre_fase       VARCHAR2(50);
    v_tipo_fase         VARCHAR2(20);
    v_orden_fase        NUMBER;
    v_partidos_totales  NUMBER;
    v_partidos_sin_res  NUMBER;
    v_empates           NUMBER;
    v_ganador           NUMBER;
    v_part_sig_local    NUMBER;
    v_id_part_nuevo     NUMBER;

    CURSOR c_partidos_elim IS
        SELECT p.id_partido,
               p.id_partido_siguiente,
               loc.id_seleccion AS sel_local,
               loc.goles_marcados AS goles_local,
               vis.id_seleccion AS sel_vis,
               vis.goles_marcados AS goles_vis
        FROM partido p
        JOIN participacion_partido loc ON loc.id_partido = p.id_partido AND loc.condicion = 'LOCAL'
        JOIN participacion_partido vis ON vis.id_partido = p.id_partido AND vis.condicion = 'VISITANTE'
        WHERE p.id_fase = p_id_fase
          AND p.id_edicion = p_id_edicion;
BEGIN
    -- 1. Validar fase y edicion
    BEGIN
        SELECT nombre, tipo, orden_fase
        INTO v_nombre_fase, v_tipo_fase, v_orden_fase
        FROM fase
        WHERE id_fase = p_id_fase AND id_edicion = p_id_edicion;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20026, 'La fase ' || p_id_fase || ' no existe en la edicion ' || p_id_edicion);
    END;

    -- 2. Validar que la fase tenga partidos programados
    SELECT COUNT(*) INTO v_partidos_totales
    FROM partido
    WHERE id_fase = p_id_fase AND id_edicion = p_id_edicion;

    IF v_partidos_totales = 0 THEN
        RAISE_APPLICATION_ERROR(-20027, 'No se puede cerrar la fase: no tiene partidos programados');
    END IF;

    -- 3. Validar que todos los partidos tengan asistencia registrada y dos participaciones
    SELECT COUNT(*) INTO v_partidos_sin_res
    FROM partido p
    WHERE p.id_fase = p_id_fase
      AND p.id_edicion = p_id_edicion
      AND (p.asistencia_registrada IS NULL
           OR (SELECT COUNT(*) FROM participacion_partido pp WHERE pp.id_partido = p.id_partido) <> 2);

    IF v_partidos_sin_res > 0 THEN
        RAISE_APPLICATION_ERROR(-20027, 'No se puede cerrar la fase: hay ' || v_partidos_sin_res ||
            ' partido(s) pendientes por registrar resultado o con participaciones incompletas');
    END IF;

    -- 4. Tratamiento segun tipo de fase
    IF v_tipo_fase = 'ELIMINATORIA' THEN
        -- Verificar que no haya empates
        SELECT COUNT(*) INTO v_empates
        FROM partido p
        JOIN participacion_partido loc ON loc.id_partido = p.id_partido AND loc.condicion = 'LOCAL'
        JOIN participacion_partido vis ON vis.id_partido = p.id_partido AND vis.condicion = 'VISITANTE'
        WHERE p.id_fase = p_id_fase
          AND p.id_edicion = p_id_edicion
          AND loc.goles_marcados = vis.goles_marcados;

        IF v_empates > 0 THEN
            RAISE_APPLICATION_ERROR(-20025, 'No se puede cerrar la fase: existen ' || v_empates ||
                ' partido(s) empatados en fase eliminatoria');
        END IF;

        -- Avanzar ganadores al partido siguiente si esta definido
        FOR m IN c_partidos_elim LOOP
            IF m.id_partido_siguiente IS NOT NULL THEN
                IF m.goles_local > m.goles_vis THEN
                    v_ganador := m.sel_local;
                ELSE
                    v_ganador := m.sel_vis;
                END IF;

                -- Revisar si el ganador ya esta en el partido siguiente
                SELECT COUNT(*) INTO v_part_sig_local
                FROM participacion_partido
                WHERE id_partido = m.id_partido_siguiente AND id_seleccion = v_ganador;

                IF v_part_sig_local = 0 THEN
                    -- Intentar cupo LOCAL
                    SELECT COUNT(*) INTO v_part_sig_local
                    FROM participacion_partido
                    WHERE id_partido = m.id_partido_siguiente AND condicion = 'LOCAL';

                    SELECT NVL(MAX(id_participacion), 0) + 1 INTO v_id_part_nuevo
                    FROM participacion_partido;

                    IF v_part_sig_local = 0 THEN
                        INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
                        VALUES (v_id_part_nuevo, m.id_partido_siguiente, v_ganador, 'LOCAL', 0);
                    ELSE
                        -- Intentar cupo VISITANTE
                        SELECT COUNT(*) INTO v_part_sig_local
                        FROM participacion_partido
                        WHERE id_partido = m.id_partido_siguiente AND condicion = 'VISITANTE';

                        IF v_part_sig_local = 0 THEN
                            INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
                            VALUES (v_id_part_nuevo, m.id_partido_siguiente, v_ganador, 'VISITANTE', 0);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    ELSE
        -- Fase de grupos: refrescar tabla de posiciones final
        pr_actualizar_tabla_posiciones(p_id_edicion);
    END IF;
END pr_cierre_fase;
/


-- ------------------------------------------------------------
-- 6. Bloque de pruebas rapidas
-- ------------------------------------------------------------

-- A. Probar actualizacion de la tabla de posiciones en la edicion 7 (Catar 2022)
EXEC pr_actualizar_tabla_posiciones(7);

-- Consultar primeros lugares por grupo
SELECT g.nombre AS grupo, tp.posicion, s.pais, tp.puntos, tp.diferencia_gol, tp.goles_favor
FROM tabla_posiciones tp
JOIN grupo g ON g.id_grupo = tp.id_grupo
JOIN seleccion s ON s.id_seleccion = tp.id_seleccion
WHERE tp.id_edicion = 7 AND tp.posicion <= 2
ORDER BY g.nombre, tp.posicion;

-- B. Probar registro de resultado valido sobre partido de fase de grupos
-- (partido 385: Catar vs Ecuador, estadio 97 con aforo 60000)
EXEC pr_registrar_resultado(385, 0, 2, 60000);

-- C. Probar cierre de fase de grupos en la edicion 7
EXEC pr_cierre_fase(7, 37);

-- Se deshacen las pruebas para no cambiar los datos de carga
ROLLBACK;

EXIT;
