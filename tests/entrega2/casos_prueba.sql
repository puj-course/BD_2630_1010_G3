-- ============================================================
-- Casos de prueba - Entrega 2
-- ============================================================
-- Se usan ids desde 9001 para no chocar con los datos de prueba.
-- Al final se hace ROLLBACK, asi que no queda nada guardado.

SET SQLBLANKLINES ON


-- ------------------------------------------------------------
-- CASOS EXITOSOS
-- ------------------------------------------------------------

-- E1. Organizacion del torneo
INSERT INTO edicion_mundial (id_edicion, anio, lema, fecha_inicio, fecha_fin)
VALUES (9001, 2099, 'Edicion de prueba', DATE '2099-06-10', DATE '2099-07-10');
INSERT INTO sede (id_sede, id_edicion, pais) VALUES (9001, 9001, 'Colombia');
INSERT INTO ciudad (id_ciudad, id_sede, nombre) VALUES (9001, 9001, 'Bogota');
INSERT INTO estadio (id_estadio, id_ciudad, nombre, capacidad)
VALUES (9001, 9001, 'Estadio de Prueba', 40000);
INSERT INTO fase (id_fase, id_edicion, nombre, orden_fase, tipo)
VALUES (9001, 9001, 'Fase de Grupos', 1, 'GRUPOS');
INSERT INTO grupo (id_grupo, id_fase, nombre) VALUES (9001, 9001, 'A');

-- E2. Selecciones del grupo
INSERT INTO seleccion (id_seleccion, id_edicion, id_grupo, pais, confederacion)
VALUES (9001, 9001, 9001, 'Colombia', 'CONMEBOL');
INSERT INTO seleccion (id_seleccion, id_edicion, id_grupo, pais, confederacion)
VALUES (9002, 9001, 9001, 'Japon', 'AFC');
INSERT INTO seleccion (id_seleccion, id_edicion, id_grupo, pais, confederacion)
VALUES (9003, 9001, 9001, 'Ghana', 'CAF');

-- E3. Partido con sus dos participaciones
INSERT INTO partido (id_partido, id_edicion, id_fase, id_estadio,
    id_partido_siguiente, fecha_hora, asistencia_registrada)
VALUES (9001, 9001, 9001, 9001, NULL, TIMESTAMP '2099-06-15 16:00:00', NULL);
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (9001, 9001, 9001, 'LOCAL', 0);
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (9002, 9001, 9002, 'VISITANTE', 0);

-- E4. Jugadores, convocatoria, arbitraje, estadistica e incidencia
INSERT INTO jugador (id_jugador, nombre, posicion, club)
VALUES (9001, 'Jugador Prueba Uno', 'Delantero', 'Club Prueba');
INSERT INTO jugador (id_jugador, nombre, posicion, club)
VALUES (9002, 'Jugador Prueba Dos', 'Volante', NULL);
INSERT INTO convocatoria_jugador (id_convocatoria, id_jugador, id_seleccion, numero_camiseta, es_capitan)
VALUES (9001, 9001, 9001, 10, 1);
INSERT INTO arbitro (id_arbitro, nombre, nacionalidad)
VALUES (9001, 'Arbitro Prueba', 'Chile');
INSERT INTO asignacion_arbitral (id_asignacion, id_partido, id_arbitro, rol)
VALUES (9001, 9001, 9001, 'Principal');
INSERT INTO estadistica_jugador_partido (id_estadistica, id_partido, id_jugador, titular,
    minuto_entrada, minuto_salida, minutos_jugados, goles, asistencias,
    tarjetas_amarillas, tarjetas_rojas)
VALUES (9001, 9001, 9001, 1, NULL, NULL, 90, 2, 0, 0, 0);
INSERT INTO incidencia (id_incidencia, id_partido, tipo, minuto, descripcion)
VALUES (9001, 9001, 'VAR', 55, 'Revision de posible penal');

-- E5. Marcador final y asistencia
UPDATE participacion_partido SET goles_marcados = 2 WHERE id_participacion = 9001;
UPDATE participacion_partido SET goles_marcados = 1 WHERE id_participacion = 9002;
UPDATE partido SET asistencia_registrada = 35000 WHERE id_partido = 9001;


-- ------------------------------------------------------------
-- CASOS FALLIDOS (cada uno debe dar error)
-- ------------------------------------------------------------

-- F1. Goles negativos
UPDATE participacion_partido SET goles_marcados = -1 WHERE id_participacion = 9001;

-- F2. Segundo local en el mismo partido
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (9003, 9001, 9003, 'LOCAL', 0);

-- F3. Dorsal repetido en la misma seleccion
INSERT INTO convocatoria_jugador (id_convocatoria, id_jugador, id_seleccion, numero_camiseta, es_capitan)
VALUES (9002, 9002, 9001, 10, 0);

-- F4. Dorsal fuera de rango
UPDATE convocatoria_jugador SET numero_camiseta = 30 WHERE id_convocatoria = 9001;

-- F5. Capacidad de estadio fuera de rango
UPDATE estadio SET capacidad = 5000 WHERE id_estadio = 9001;

-- F6. Dos partidos en el mismo estadio a la misma hora
INSERT INTO partido (id_partido, id_edicion, id_fase, id_estadio,
    id_partido_siguiente, fecha_hora, asistencia_registrada)
VALUES (9002, 9001, 9001, 9001, NULL, TIMESTAMP '2099-06-15 16:00:00', NULL);

-- F7. Partido en un estadio que no existe
INSERT INTO partido (id_partido, id_edicion, id_fase, id_estadio,
    id_partido_siguiente, fecha_hora, asistencia_registrada)
VALUES (9003, 9001, 9001, 99999, NULL, TIMESTAMP '2099-06-16 16:00:00', NULL);

-- F8. Titular con minuto de entrada
UPDATE estadistica_jugador_partido SET minuto_entrada = 30 WHERE id_estadistica = 9001;

-- F9. Grupo con letra fuera de A-L
UPDATE grupo SET nombre = 'Z' WHERE id_grupo = 9001;

-- F10. Rol arbitral que no existe
UPDATE asignacion_arbitral SET rol = 'Juez de linea' WHERE id_asignacion = 9001;

-- F11. Borrar una seleccion que ya jugo
DELETE FROM seleccion WHERE id_seleccion = 9002;

-- F12. Borrar un estadio con partidos
DELETE FROM estadio WHERE id_estadio = 9001;


-- ------------------------------------------------------------
-- E6. ON DELETE CASCADE: al borrar el partido se borran sus hijos
-- ------------------------------------------------------------

SELECT (SELECT COUNT(*) FROM participacion_partido WHERE id_partido = 9001) AS participaciones,
       (SELECT COUNT(*) FROM asignacion_arbitral WHERE id_partido = 9001) AS asignaciones,
       (SELECT COUNT(*) FROM estadistica_jugador_partido WHERE id_partido = 9001) AS estadisticas,
       (SELECT COUNT(*) FROM incidencia WHERE id_partido = 9001) AS incidencias
FROM dual;

DELETE FROM partido WHERE id_partido = 9001;

SELECT (SELECT COUNT(*) FROM participacion_partido WHERE id_partido = 9001) AS participaciones,
       (SELECT COUNT(*) FROM asignacion_arbitral WHERE id_partido = 9001) AS asignaciones,
       (SELECT COUNT(*) FROM estadistica_jugador_partido WHERE id_partido = 9001) AS estadisticas,
       (SELECT COUNT(*) FROM incidencia WHERE id_partido = 9001) AS incidencias
FROM dual;


ROLLBACK;

EXIT;
