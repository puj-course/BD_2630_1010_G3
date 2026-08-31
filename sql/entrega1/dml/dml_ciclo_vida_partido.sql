-- ============================================================
-- DML Ciclo de Vida del Partido - Mundial FIFA
-- ============================================================

-- ------------------------------------------------------------
-- PARTE 1: Flujo Normal (Crear partido, participaciones y actualizar)
-- ------------------------------------------------------------
-- Insertar un partido 
INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
VALUES (9999, 1, 1, TO_TIMESTAMP('1998-07-12 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Final', NULL);

-- Meter sus 2 participaciones (Local y Visitante)
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99991, 9999, 2, 'LOCAL', 0);

INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99992, 9999, 25, 'VISITANTE', 0);

-- Actualizar el marcador y la asistencia registrada al finalizar
UPDATE participacion_partido SET goles_marcados = 3 WHERE id_participacion = 99991;
UPDATE participacion_partido SET goles_marcados = 0 WHERE id_participacion = 99992;
UPDATE partido SET asistencia_registrada = 80000 WHERE id_partido = 9999;


-- ------------------------------------------------------------
-- PARTE 2: Intentos Fallidos a Proposito (Anotar el ORA- resultante)
-- ------------------------------------------------------------

-- Intento Fallido 1: Insertar un tercer equipo en el mismo partido con la misma condicion (Falla por Unique Key / Restriccion)
-- Error : ORA-00001: unique constraint (IS101009.UQ_PARTICIPACION_CONDICION) violated
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99993, 9999, 12, 'LOCAL', 1);

-- Intento Fallido 2: Goles negativos
-- Error : ORA-02290: check constraint (IS101009.CK_PARTICIPACION_GOLES) violated
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99994, 9999, 12, 'VISITANTE', -5);

-- Intento Fallido 3: Partido apuntando a una Edicion que no existe
-- Error : ORA-02291: integrity constraint (IS101009.FK_PARTIDO_EDICION) violated
INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
VALUES (8888, 675, 1, TO_TIMESTAMP('1998-06-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Final', 40000);

-- Intento Fallido 4: Fase que no esta en la lista permitida
-- Error : ORA-02290: check constraint (IS101009.CK_PARTIDO_FASE) violated
INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
VALUES (8887, 1, 1, TO_TIMESTAMP('1998-06-15 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Grupos', 40000);


-- ------------------------------------------------------------
-- PARTE 3: Demostracion de ON DELETE
-- ------------------------------------------------------------

-- Demostrar CASCADE: Borrar un partido elimina sus participaciones asociadas sin error.
DELETE FROM partido WHERE id_partido = 9999;
--  SELECT * FROM participacion_partido WHERE id_partido = 9999; devuelve 0 filas

-- Demostrar Restriccion Foreign Key (Falla al borrar un padre con hijos):
-- Intenta borrar la seleccion 1 que tiene partidos/participaciones asociadas.
-- Error: ORA-02292: integrity constraint (SCHEMA.FK_NAME) violated - child record found
DELETE FROM seleccion WHERE id_seleccion = 1;


-- ------------------------------------------------------------
-- PARTE 4: Reversion
-- ------------------------------------------------------------
-- Se deshace todo. El script no persiste nada y se puede volver a ejecutar
-- cuantas veces se quiera sin ensuciar los datos de prueba.

ROLLBACK;

SELECT 'TRAS EL ROLLBACK' AS momento,
       (SELECT COUNT(*) FROM partido)               AS partidos,
       (SELECT COUNT(*) FROM participacion_partido) AS participaciones
FROM dual;

EXIT;
