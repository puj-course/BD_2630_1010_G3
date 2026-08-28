-- =============================================================================
--  Entrega 1 - Consultas SQL sobre el modelo inicial
--  Bloque: VERIFICACION DE INTEGRIDAD  (Consulta 14 del enunciado)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================
--
--  Todas las consultas de este archivo son de CONTROL: su resultado correcto es
--  CERO FILAS. Cualquier fila devuelta es un defecto de integridad en los datos.
--
--  Se dividen en dos grupos, y la diferencia entre ambos es conceptualmente
--  importante:
--
--    * La Consulta 14 verifica una regla que el DDL YA GARANTIZA de forma
--      declarativa. Aqui no puede fallar nunca: sirve para DEMOSTRAR que la
--      restriccion funciona.
--
--    * Las verificaciones V1 a V4 comprueban las reglas que Oracle NO permite
--      expresar de forma declarativa (documentadas en la Seccion 7 del script
--      DDL). Estas SI podrian devolver filas, y son la unica red de seguridad
--      hasta que se implementen como triggers en la Entrega 3.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Consulta 14: Participaciones duplicadas de una seleccion en un mismo partido.
--
--   El enunciado pide una consulta que INTENTE identificar este caso, para
--   validar que la restriccion anti-duplicidad del DDL efectivamente lo impide.
--
--   La restriccion responsable es:
--       CONSTRAINT uq_participacion_partido_seleccion
--           UNIQUE (id_partido, id_seleccion)
--
--   Esa UNIQUE hace estructuralmente imposible que esta consulta devuelva algo:
--   el motor rechaza el segundo INSERT con ORA-00001 antes de que la fila
--   duplicada llegue a existir. La demostracion practica de ese rechazo esta en
--   sql/entrega1/dml/dml_ciclo_vida_partido.sql (intento invalido 1) y su
--   evidencia en tests/entrega1/pruebas_dml.md.
--
--   La misma UNIQUE cubre, como efecto colateral, la regla de que una seleccion
--   no puede enfrentarse a si misma: eso exigiria dos filas con el mismo
--   id_partido y el mismo id_seleccion, que es justo lo que la restriccion
--   prohibe.
-- -----------------------------------------------------------------------------

SELECT
    pp.id_partido,
    pp.id_seleccion,
    COUNT(*) AS n_participaciones
FROM participacion_partido pp
GROUP BY pp.id_partido, pp.id_seleccion
HAVING COUNT(*) > 1
ORDER BY pp.id_partido, pp.id_seleccion;


-- -----------------------------------------------------------------------------
-- V1: Partidos que no tienen EXACTAMENTE dos participaciones.
--
--   Regla R1 de la Seccion 7 del DDL. Las restricciones UNIQUE garantizan el
--   limite SUPERIOR de dos participaciones, pero el limite INFERIOR requiere
--   contar filas relacionadas, y un CHECK en Oracle no admite subconsultas ni
--   funciones de agregacion. Por eso esta verificacion es necesaria.
-- -----------------------------------------------------------------------------

SELECT
    p.id_partido,
    p.id_edicion,
    p.fase,
    COUNT(pp.id_participacion) AS n_participaciones
FROM partido p
LEFT JOIN participacion_partido pp ON pp.id_partido = p.id_partido
GROUP BY p.id_partido, p.id_edicion, p.fase
HAVING COUNT(pp.id_participacion) <> 2
ORDER BY p.id_partido;


-- -----------------------------------------------------------------------------
-- V2: Partidos fuera del rango de fechas de su edicion.
--
--   Regla R2 de la Seccion 7 del DDL. Un CHECK sobre PARTIDO no puede leer
--   EDICION_MUNDIAL, asi que la regla no es declarable.
--
--   La comparacion usa TRUNC sobre fecha_hora porque PARTIDO.FECHA_HORA es un
--   TIMESTAMP y las fechas de la edicion son DATE a medianoche: sin truncar, un
--   partido jugado el mismo dia de la final a las 20:00 quedaria marcado como
--   fuera de rango.
-- -----------------------------------------------------------------------------

SELECT
    p.id_partido,
    p.id_edicion,
    TO_CHAR(p.fecha_hora, 'YYYY-MM-DD HH24:MI') AS fecha_partido,
    TO_CHAR(ed.fecha_inicio, 'YYYY-MM-DD')      AS inicio_edicion,
    TO_CHAR(ed.fecha_fin,    'YYYY-MM-DD')      AS fin_edicion
FROM partido p
JOIN edicion_mundial ed ON ed.id_edicion = p.id_edicion
WHERE TRUNC(CAST(p.fecha_hora AS DATE)) NOT BETWEEN ed.fecha_inicio AND ed.fecha_fin
ORDER BY p.id_partido;


-- -----------------------------------------------------------------------------
-- V3: Participaciones cuya seleccion no pertenece a la edicion del partido.
--
--   Regla R3 de la Seccion 7 del DDL. Para ESTADIO esta regla SI se resolvio de
--   forma declarativa, con la FK compuesta FK_PARTIDO_ESTADIO_EDICION. Para
--   SELECCION haria falta denormalizar id_edicion dentro de
--   PARTICIPACION_PARTIDO, lo que introduciria una dependencia transitiva y
--   romperia la 3FN. Se prefirio conservar la normalizacion y verificar por
--   consulta.
-- -----------------------------------------------------------------------------

SELECT
    pp.id_participacion,
    pp.id_partido,
    p.id_edicion   AS edicion_del_partido,
    pp.id_seleccion,
    s.pais,
    s.id_edicion   AS edicion_de_la_seleccion
FROM participacion_partido pp
JOIN partido   p ON p.id_partido   = pp.id_partido
JOIN seleccion s ON s.id_seleccion = pp.id_seleccion
WHERE s.id_edicion <> p.id_edicion
ORDER BY pp.id_partido;


-- -----------------------------------------------------------------------------
-- V4: Estadios con dos partidos programados a la misma fecha y hora.
--
--   Esta regla SI esta garantizada por el DDL, mediante
--       CONSTRAINT uq_partido_estadio_fecha UNIQUE (id_estadio, fecha_hora)
--   La consulta se incluye como contraparte demostrativa de la Consulta 14: al
--   igual que aquella, su resultado correcto es cero filas por construccion.
-- -----------------------------------------------------------------------------

SELECT
    p.id_estadio,
    es.nombre AS estadio,
    TO_CHAR(p.fecha_hora, 'YYYY-MM-DD HH24:MI') AS fecha_hora,
    COUNT(*) AS n_partidos
FROM partido p
JOIN estadio es ON es.id_estadio = p.id_estadio
GROUP BY p.id_estadio, es.nombre, p.fecha_hora
HAVING COUNT(*) > 1
ORDER BY p.id_estadio;
