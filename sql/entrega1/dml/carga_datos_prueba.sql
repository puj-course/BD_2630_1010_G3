-- ============================================================
-- Proyecto Base de Datos - Mundial FIFA
-- Entrega 1 - Carga de datos de prueba
-- Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
-- Motor: Oracle 19c
-- ============================================================
--
-- COMO USARLO
-- Cada integrante ejecuta este script en SU PROPIO esquema, despues
-- de haber creado las tablas con sql/entrega1/ddl/ddl_modelo_inicial.sql
--
--     sql -name "BD Javeriana" @sql/entrega1/dml/carga_datos_prueba.sql
--
-- SOBRE LOS DATOS
-- Los anios, paises sede y fechas de las ediciones son informacion
-- publica del futbol mundial. Los lemas son inventados. Los estadios,
-- selecciones, partidos y marcadores tambien seran inventados, tal como
-- pide la seccion 4 del enunciado: no se presentan resultados reales
-- como si los hubiera generado el sistema.
--
-- Estos datos son propios y distintos de los del esquema MORENOLUIS,
-- como exige la seccion 7 del README_GUIA_SERVIDOR.
--
-- VOLUMEN PREVISTO (7 ediciones completas)
--     EDICION_MUNDIAL          7 filas
--     ESTADIO                112 filas   (16 por edicion)
--     SELECCION              224 filas   (32 por edicion)
--     PARTIDO                448 filas   (64 por edicion)
--     PARTICIPACION_PARTIDO  896 filas   (2 por partido)
--
-- EDICION_MUNDIAL es la unica tabla que no llega a 100 filas, por la
-- naturaleza de la tabla: solo se han disputado 22 Mundiales en toda la
-- historia. El enunciado contempla esa salvedad en la seccion 8.1.3.
-- ============================================================

SET SQLBLANKLINES ON
SET DEFINE OFF


-- ------------------------------------------------------------
-- Limpieza previa, para poder ejecutar el script varias veces.
-- El orden es de la tabla hija a la tabla padre, porque las llaves
-- foraneas no dejan borrar un padre que todavia tiene hijos.
-- ------------------------------------------------------------

DELETE FROM participacion_partido;
DELETE FROM partido;
DELETE FROM seleccion;
DELETE FROM estadio;
DELETE FROM edicion_mundial;


-- ============================================================
-- 1. EDICION_MUNDIAL  (7 filas)
-- ============================================================
-- Siete ediciones completas del Mundial. Se cargan primero porque
-- ESTADIO, SELECCION y PARTIDO apuntan a esta tabla con llave foranea.
--
-- Restricciones que deben cumplirse:
--   - anio entre 1930 y 2100, y sin repetirse
--   - fecha_fin posterior a fecha_inicio
-- ------------------------------------------------------------

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (1, 1998, 'Francia', 'El futbol nos une', DATE '1998-06-10', DATE '1998-07-12');

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (2, 2002, 'Corea del Sur y Japon', 'Dos naciones, un torneo', DATE '2002-05-31', DATE '2002-06-30');

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (3, 2006, 'Alemania', 'El mundo entre amigos', DATE '2006-06-09', DATE '2006-07-09');

-- lema queda en NULL: no toda edicion tiene un lema registrado, y la
-- columna admite nulos precisamente por eso.
INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (4, 2010, 'Sudafrica', NULL, DATE '2010-06-11', DATE '2010-07-11');

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (5, 2014, 'Brasil', 'Todos en un mismo ritmo', DATE '2014-06-12', DATE '2014-07-13');

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (6, 2018, 'Rusia', 'De este a oeste', DATE '2018-06-14', DATE '2018-07-15');

INSERT INTO edicion_mundial (id_edicion, anio, pais_sede, lema, fecha_inicio, fecha_fin)
VALUES (7, 2022, 'Catar', 'Ahora es el momento', DATE '2022-11-20', DATE '2022-12-18');


-- ============================================================
-- 2. ESTADIO   (pendiente - 112 filas)
-- 3. SELECCION (pendiente - 224 filas)
-- 4. PARTIDO   (pendiente - 448 filas)
-- 5. PARTICIPACION_PARTIDO (pendiente - 896 filas)
-- ============================================================


COMMIT;


-- ------------------------------------------------------------
-- Verificacion: cuantas filas quedaron en cada tabla
-- ------------------------------------------------------------

SELECT 'EDICION_MUNDIAL'       AS tabla, COUNT(*) AS filas FROM edicion_mundial
UNION ALL SELECT 'ESTADIO',               COUNT(*) FROM estadio
UNION ALL SELECT 'SELECCION',             COUNT(*) FROM seleccion
UNION ALL SELECT 'PARTIDO',               COUNT(*) FROM partido
UNION ALL SELECT 'PARTICIPACION_PARTIDO', COUNT(*) FROM participacion_partido;

EXIT;
