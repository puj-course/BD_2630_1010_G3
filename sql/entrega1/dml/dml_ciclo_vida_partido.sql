-- =============================================================================
--  Entrega 1 - Modificadores de datos (DML)
--  Ciclo de vida de un partido, operaciones invalidas y comportamiento ON DELETE
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================
--
--  REQUISITOS PREVIOS
--  ------------------
--    1. sql/entrega1/ddl/ddl_modelo_inicial.sql   (tablas y restricciones)
--    2. sql/entrega1/dml/carga_datos_prueba.sql   (dataset base)
--
--  COMO EJECUTARLO
--  ---------------
--  Este script provoca errores A PROPOSITO. Para que la ejecucion no se detenga
--  en el primer fallo y se puedan observar los siete escenarios completos, se
--  fija WHENEVER SQLERROR CONTINUE al inicio.
--
--    sql -name "BD Javeriana" @sql/entrega1/dml/dml_ciclo_vida_partido.sql
--
--  El script termina con ROLLBACK: no deja NADA persistido. Puede ejecutarse
--  tantas veces como se quiera sin ensuciar la base ni alterar el dataset.
--  AUTOCOMMIT esta OFF en la conexion del curso, lo que hace posible este
--  patron de "ensayo y reversion".
--
--  La evidencia de cada escenario (sentencia ejecutada y error obtenido) esta
--  transcrita en tests/entrega1/pruebas_dml.md.
-- =============================================================================

WHENEVER SQLERROR CONTINUE;
SET SERVEROUTPUT ON;
SET DEFINE OFF;

-- Identificadores fuera del rango del dataset (que llega a 512 partidos), para
-- que el script sea determinista y no dependa de cuantas filas haya cargadas.
--   Partido de la demostracion .............. 90001
--   Participaciones ......................... 90001, 90002, 90003
--   Partido auxiliar para el ON DELETE ...... 90002


-- #############################################################################
--  PARTE 1 - CICLO DE VIDA COMPLETO DE UN PARTIDO
-- #############################################################################

-- -----------------------------------------------------------------------------
-- 1.1  Alta del partido.
--
--   Se toman una edicion existente y un estadio DE ESA MISMA EDICION. Esto no es
--   opcional: la FK compuesta FK_PARTIDO_ESTADIO_EDICION exige que la pareja
--   (id_estadio, id_edicion) exista en ESTADIO. Tomar un estadio cualquiera
--   fallaria con ORA-02291.
--
--   La fecha se calcula como fecha_inicio + 20 dias, garantizando que cae dentro
--   del rango de la edicion (regla R2 de la Seccion 7 del DDL).
-- -----------------------------------------------------------------------------

INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
SELECT
    90001,
    es.id_edicion,
    es.id_estadio,
    CAST(ed.fecha_inicio + 20 AS TIMESTAMP) + INTERVAL '18' HOUR,
    'Cuartos',
    NULL                              -- todavia no se ha jugado
FROM estadio es
JOIN edicion_mundial ed ON ed.id_edicion = es.id_edicion
WHERE es.id_edicion = 1
  AND ROWNUM = 1;

-- -----------------------------------------------------------------------------
-- 1.2  Registro de las dos participaciones.
--
--   Un partido sin sus dos participaciones esta incompleto: es la regla R1 de la
--   Seccion 7 del DDL, la que Oracle no puede declarar. Se insertan dos
--   selecciones DISTINTAS de la misma edicion del partido, una como LOCAL y otra
--   como VISITANTE. El marcador arranca en 0-0.
-- -----------------------------------------------------------------------------

INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
SELECT 90001, 90001, MIN(s.id_seleccion), 'LOCAL', 0
FROM seleccion s
WHERE s.id_edicion = 1;

INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
SELECT 90002, 90001, MAX(s.id_seleccion), 'VISITANTE', 0
FROM seleccion s
WHERE s.id_edicion = 1;

-- Estado tras el alta: el partido existe, con dos participantes y 0-0.
SELECT 'PASO 1.2 - partido creado' AS momento, id_partido, seleccion_local,
       goles_local, goles_visitante, seleccion_visitante, resultado
FROM   v_resumen_partido
WHERE  id_partido = 90001;

-- -----------------------------------------------------------------------------
-- 1.3  Actualizacion del marcador final y de la asistencia.
--
--   Es el UPDATE que cierra el ciclo de vida: el partido pasa de "programado" a
--   "disputado". Notese que el resultado NO se actualiza en ninguna parte: se
--   deriva en la vista V_RESUMEN_PARTIDO a partir de los goles, de modo que es
--   imposible que quede desincronizado del marcador.
-- -----------------------------------------------------------------------------

UPDATE participacion_partido
SET    goles_marcados = 3
WHERE  id_partido = 90001 AND condicion = 'LOCAL';

UPDATE participacion_partido
SET    goles_marcados = 1
WHERE  id_partido = 90001 AND condicion = 'VISITANTE';

UPDATE partido
SET    asistencia_registrada = (SELECT ROUND(es.capacidad * 0.93)
                                FROM   estadio es
                                WHERE  es.id_estadio = partido.id_estadio)
WHERE  id_partido = 90001;

-- Estado final: 3-1, con el resultado derivado automaticamente.
SELECT 'PASO 1.3 - partido disputado' AS momento, id_partido, seleccion_local,
       goles_local, goles_visitante, seleccion_visitante, resultado,
       asistencia_registrada, capacidad
FROM   v_resumen_partido
WHERE  id_partido = 90001;


-- #############################################################################
--  PARTE 2 - INTENTOS DE OPERACION INVALIDA
--  Los cuatro deben FALLAR. El error esperado se indica en cada bloque y la
--  transcripcion literal esta en tests/entrega1/pruebas_dml.md.
-- #############################################################################

-- -----------------------------------------------------------------------------
-- INTENTO 1 - Tercer participante en un partido.
--   Restriccion vulnerada : UQ_PARTICIPACION_PARTIDO_CONDICION (id_partido, condicion)
--   Error esperado        : ORA-00001 unique constraint violated
--   Por que               : el partido 90001 ya tiene un VISITANTE. Un partido
--                           enfrenta exactamente a dos selecciones, asi que no
--                           puede haber un tercer participante.
--   Es la verificacion practica de lo que la Consulta 14 comprueba por consulta.
-- -----------------------------------------------------------------------------

INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
SELECT 90003, 90001, MIN(s.id_seleccion), 'VISITANTE', 0
FROM   seleccion s
WHERE  s.id_edicion = 1
  AND  s.id_seleccion NOT IN (SELECT id_seleccion FROM participacion_partido WHERE id_partido = 90001);

-- -----------------------------------------------------------------------------
-- INTENTO 2 - Seleccion duplicada en el mismo partido.
--   Restriccion vulnerada : UQ_PARTICIPACION_PARTIDO_SELECCION (id_partido, id_seleccion)
--   Error esperado        : ORA-00001 unique constraint violated
--   Por que               : la misma seleccion no puede aparecer dos veces en un
--                           partido. Esta restriccion cubre ademas, como efecto
--                           colateral, la regla de que una seleccion no puede
--                           enfrentarse a si misma.
-- -----------------------------------------------------------------------------

INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
SELECT 90004, 90001, pp.id_seleccion, 'LOCAL', 2
FROM   participacion_partido pp
WHERE  pp.id_partido = 90001 AND pp.condicion = 'VISITANTE';

-- -----------------------------------------------------------------------------
-- INTENTO 3 - Gol negativo.
--   Restriccion vulnerada : CK_PARTICIPACION_GOLES (goles_marcados BETWEEN 0 AND 30)
--   Error esperado        : ORA-02290 check constraint violated
--   Por que               : el enunciado lo pide expresamente en la Seccion 8.1.2.
--                           Un marcador negativo no tiene interpretacion posible.
-- -----------------------------------------------------------------------------

UPDATE participacion_partido
SET    goles_marcados = -2
WHERE  id_partido = 90001 AND condicion = 'LOCAL';

-- -----------------------------------------------------------------------------
-- INTENTO 4 - Partido en un estadio de OTRA edicion.
--   Restriccion vulnerada : FK_PARTIDO_ESTADIO_EDICION (FK compuesta)
--   Error esperado        : ORA-02291 integrity constraint - parent key not found
--   Por que               : es la restriccion mas interesante del modelo. Una FK
--                           simple hacia id_estadio dejaria pasar este INSERT sin
--                           protestar, porque el estadio EXISTE; lo que no existe
--                           es la pareja (estadio, edicion). Al referenciar la
--                           clave candidata compuesta, el motor lo rechaza de
--                           forma declarativa, sin necesidad de trigger.
-- -----------------------------------------------------------------------------

INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
SELECT 90003, 1, es.id_estadio,
       TIMESTAMP '1994-06-20 15:00:00', 'Octavos', 40000
FROM   estadio es
WHERE  es.id_edicion = 2          -- estadio de la edicion 2, partido de la 1
  AND  ROWNUM = 1;


-- #############################################################################
--  PARTE 3 - COMPORTAMIENTO ON DELETE EN DOS RELACIONES DISTINTAS
--  El enunciado exige ilustrar CASCADE frente a RESTRICT sobre dos relaciones
--  diferentes, verificando que lo observado coincide con lo definido en el DDL.
-- #############################################################################

-- -----------------------------------------------------------------------------
-- 3.1  RELACION A: PARTIDO -> PARTICIPACION_PARTIDO  =>  ON DELETE CASCADE
--
--   Definicion en el DDL:
--       CONSTRAINT fk_participacion_partido
--           FOREIGN KEY (id_partido) REFERENCES partido (id_partido)
--           ON DELETE CASCADE
--
--   Justificacion: una participacion es una entidad con dependencia de
--   existencia; fuera de su partido no significa nada. Borrar el partido debe
--   arrastrarla.
--
--   Comportamiento esperado: el DELETE tiene EXITO y el contador de
--   participaciones del partido 90001 pasa de 2 a 0 SIN haberlas borrado
--   explicitamente.
-- -----------------------------------------------------------------------------

SELECT 'ANTES  del DELETE (CASCADE)' AS momento, COUNT(*) AS participaciones_90001
FROM   participacion_partido WHERE id_partido = 90001;

DELETE FROM partido WHERE id_partido = 90001;

SELECT 'DESPUES del DELETE (CASCADE)' AS momento, COUNT(*) AS participaciones_90001
FROM   participacion_partido WHERE id_partido = 90001;

-- -----------------------------------------------------------------------------
-- 3.2  RELACION B: SELECCION -> PARTICIPACION_PARTIDO  =>  RESTRICT
--
--   Definicion en el DDL (sin clausula ON DELETE, que en Oracle equivale a
--   RESTRICT; el motor no implementa la sintaxis ON DELETE RESTRICT):
--       CONSTRAINT fk_participacion_seleccion
--           FOREIGN KEY (id_seleccion) REFERENCES seleccion (id_seleccion)
--
--   Justificacion: el enunciado pide expresamente "no permitir eliminar una
--   seleccion que ya tiene partidos registrados". Borrarla falsearia el
--   historial: los marcadores de sus rivales quedarian sin contraparte.
--
--   Comportamiento esperado: el DELETE FALLA con ORA-02292, y el contador
--   posterior demuestra que la seleccion sigue existiendo.
--
--   La asimetria frente a 3.1 es deliberada: las dos FK apuntan a la MISMA tabla
--   hija, PARTICIPACION_PARTIDO, y aun asi se comportan al reves. Es la prueba
--   de que el comportamiento lo decide el diseno de cada relacion, no la tabla.
-- -----------------------------------------------------------------------------

SELECT 'ANTES del DELETE (RESTRICT)' AS momento, COUNT(*) AS partidos_de_la_seleccion
FROM   participacion_partido
WHERE  id_seleccion = (SELECT MIN(id_seleccion) FROM seleccion WHERE id_edicion = 1);

DELETE FROM seleccion
WHERE  id_seleccion = (SELECT MIN(id_seleccion) FROM seleccion WHERE id_edicion = 1);

SELECT 'DESPUES del DELETE (RESTRICT)' AS momento, COUNT(*) AS la_seleccion_sigue_existiendo
FROM   seleccion
WHERE  id_seleccion = (SELECT MIN(id_seleccion) FROM seleccion WHERE id_edicion = 1);

-- -----------------------------------------------------------------------------
-- 3.3  CONTRASTE: borrado de una EDICION con partidos registrados.
--
--   Definicion en el DDL: FK_PARTIDO_EDICION, tambien restrictiva.
--   Comportamiento esperado: FALLA con ORA-02292.
--
--   Este caso justifica una decision de diseno que documenta el DDL: si esta FK
--   fuera CASCADE, borrar una edicion dispararia DOS caminos de cascada (hacia
--   ESTADIO y hacia PARTIDO) que convergen en la FK compuesta, que es
--   restrictiva. Oracle no garantiza el orden de resolucion de cascadas por
--   caminos multiples, asi que el mismo DELETE podria tener exito o fallar de
--   forma no reproducible. Declarandola restrictiva, la semantica queda univoca.
-- -----------------------------------------------------------------------------

DELETE FROM edicion_mundial WHERE id_edicion = 1;


-- #############################################################################
--  PARTE 4 - REVERSION
-- #############################################################################
--  Se deshace TODO lo anterior: las altas de la Parte 1, el borrado en cascada
--  de la Parte 3.1 y cualquier efecto residual. La base queda exactamente como
--  estaba antes de ejecutar el script.
-- #############################################################################

ROLLBACK;

-- Comprobacion de que la reversion fue completa: las dos consultas deben
-- devolver los valores originales del dataset.
SELECT 'TRAS EL ROLLBACK' AS momento,
       (SELECT COUNT(*) FROM partido)               AS partidos,
       (SELECT COUNT(*) FROM participacion_partido) AS participaciones,
       (SELECT COUNT(*) FROM seleccion)             AS selecciones,
       (SELECT COUNT(*) FROM edicion_mundial)       AS ediciones
FROM dual;

WHENEVER SQLERROR EXIT FAILURE;
