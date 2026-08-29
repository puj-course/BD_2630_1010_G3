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
-- 2. ESTADIO  (112 filas -- 16 por edicion)
-- ============================================================
-- Las ciudades corresponden al pais anfitrion de cada edicion, para
-- que el dato sea coherente. Los nombres de estadio son inventados.
--
-- Restricciones que deben cumplirse:
--   - id_edicion tiene que existir en EDICION_MUNDIAL (1 a 7)
--   - no se repite el nombre dentro de una misma edicion
--   - capacidad entre 20000 y 150000
-- ------------------------------------------------------------

-- Edicion 1 - Francia
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (1, 1, 'Estadio Paris', 'Paris', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (2, 1, 'Estadio Marsella', 'Marsella', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (3, 1, 'Estadio Lyon', 'Lyon', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (4, 1, 'Estadio Burdeos', 'Burdeos', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (5, 1, 'Estadio Lens', 'Lens', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (6, 1, 'Estadio Montpellier', 'Montpellier', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (7, 1, 'Estadio Nantes', 'Nantes', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (8, 1, 'Estadio Saint-Etienne', 'Saint-Etienne', 48000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (9, 1, 'Estadio Toulouse', 'Toulouse', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (10, 1, 'Estadio Niza', 'Niza', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (11, 1, 'Estadio Estrasburgo', 'Estrasburgo', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (12, 1, 'Estadio Lille', 'Lille', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (13, 1, 'Estadio Rennes', 'Rennes', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (14, 1, 'Estadio Le Havre', 'Le Havre', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (15, 1, 'Estadio Grenoble', 'Grenoble', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (16, 1, 'Estadio Dijon', 'Dijon', 90000);

-- Edicion 2 - Corea del Sur y Japon
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (17, 2, 'Estadio Seul', 'Seul', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (18, 2, 'Estadio Busan', 'Busan', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (19, 2, 'Estadio Incheon', 'Incheon', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (20, 2, 'Estadio Daegu', 'Daegu', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (21, 2, 'Estadio Gwangju', 'Gwangju', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (22, 2, 'Estadio Daejeon', 'Daejeon', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (23, 2, 'Estadio Ulsan', 'Ulsan', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (24, 2, 'Estadio Suwon', 'Suwon', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (25, 2, 'Estadio Tokio', 'Tokio', 48000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (26, 2, 'Estadio Yokohama', 'Yokohama', 38000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (27, 2, 'Estadio Osaka', 'Osaka', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (28, 2, 'Estadio Sapporo', 'Sapporo', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (29, 2, 'Estadio Kobe', 'Kobe', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (30, 2, 'Estadio Niigata', 'Niigata', 52000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (31, 2, 'Estadio Sendai', 'Sendai', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (32, 2, 'Estadio Oita', 'Oita', 41000);

-- Edicion 3 - Alemania
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (33, 3, 'Estadio Berlin', 'Berlin', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (34, 3, 'Estadio Munich', 'Munich', 38000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (35, 3, 'Estadio Dortmund', 'Dortmund', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (36, 3, 'Estadio Stuttgart', 'Stuttgart', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (37, 3, 'Estadio Hamburgo', 'Hamburgo', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (38, 3, 'Estadio Colonia', 'Colonia', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (39, 3, 'Estadio Frankfurt', 'Frankfurt', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (40, 3, 'Estadio Gelsenkirchen', 'Gelsenkirchen', 48000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (41, 3, 'Estadio Hannover', 'Hannover', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (42, 3, 'Estadio Leipzig', 'Leipzig', 52000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (43, 3, 'Estadio Nuremberg', 'Nuremberg', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (44, 3, 'Estadio Kaiserslautern', 'Kaiserslautern', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (45, 3, 'Estadio Bremen', 'Bremen', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (46, 3, 'Estadio Dusseldorf', 'Dusseldorf', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (47, 3, 'Estadio Dresde', 'Dresde', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (48, 3, 'Estadio Bochum', 'Bochum', 68000);

-- Edicion 4 - Sudafrica
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (49, 4, 'Estadio Johannesburgo', 'Johannesburgo', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (50, 4, 'Estadio Ciudad del Cabo', 'Ciudad del Cabo', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (51, 4, 'Estadio Durban', 'Durban', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (52, 4, 'Estadio Pretoria', 'Pretoria', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (53, 4, 'Estadio Puerto Elizabeth', 'Puerto Elizabeth', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (54, 4, 'Estadio Bloemfontein', 'Bloemfontein', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (55, 4, 'Estadio Polokwane', 'Polokwane', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (56, 4, 'Estadio Nelspruit', 'Nelspruit', 52000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (57, 4, 'Estadio Rustenburgo', 'Rustenburgo', 52000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (58, 4, 'Estadio Kimberley', 'Kimberley', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (59, 4, 'Estadio East London', 'East London', 45000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (60, 4, 'Estadio Pietermaritzburgo', 'Pietermaritzburgo', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (61, 4, 'Estadio Soweto', 'Soweto', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (62, 4, 'Estadio Vereeniging', 'Vereeniging', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (63, 4, 'Estadio George', 'George', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (64, 4, 'Estadio Upington', 'Upington', 52000);

-- Edicion 5 - Brasil
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (65, 5, 'Estadio Rio de Janeiro', 'Rio de Janeiro', 38000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (66, 5, 'Estadio Sao Paulo', 'Sao Paulo', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (67, 5, 'Estadio Brasilia', 'Brasilia', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (68, 5, 'Estadio Salvador', 'Salvador', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (69, 5, 'Estadio Fortaleza', 'Fortaleza', 56000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (70, 5, 'Estadio Belo Horizonte', 'Belo Horizonte', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (71, 5, 'Estadio Porto Alegre', 'Porto Alegre', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (72, 5, 'Estadio Recife', 'Recife', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (73, 5, 'Estadio Curitiba', 'Curitiba', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (74, 5, 'Estadio Manaos', 'Manaos', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (75, 5, 'Estadio Natal', 'Natal', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (76, 5, 'Estadio Cuiaba', 'Cuiaba', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (77, 5, 'Estadio Campinas', 'Campinas', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (78, 5, 'Estadio Goiania', 'Goiania', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (79, 5, 'Estadio Belem', 'Belem', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (80, 5, 'Estadio Florianopolis', 'Florianopolis', 68000);

-- Edicion 6 - Rusia
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (81, 6, 'Estadio Moscu', 'Moscu', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (82, 6, 'Estadio San Petersburgo', 'San Petersburgo', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (83, 6, 'Estadio Kazan', 'Kazan', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (84, 6, 'Estadio Sochi', 'Sochi', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (85, 6, 'Estadio Samara', 'Samara', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (86, 6, 'Estadio Rostov del Don', 'Rostov del Don', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (87, 6, 'Estadio Nizhni Novgorod', 'Nizhni Novgorod', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (88, 6, 'Estadio Ekaterimburgo', 'Ekaterimburgo', 52000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (89, 6, 'Estadio Kaliningrado', 'Kaliningrado', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (90, 6, 'Estadio Volgogrado', 'Volgogrado', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (91, 6, 'Estadio Saransk', 'Saransk', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (92, 6, 'Estadio Krasnodar', 'Krasnodar', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (93, 6, 'Estadio Ufa', 'Ufa', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (94, 6, 'Estadio Perm', 'Perm', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (95, 6, 'Estadio Voronezh', 'Voronezh', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (96, 6, 'Estadio Novosibirsk', 'Novosibirsk', 38000);

-- Edicion 7 - Catar
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (97, 7, 'Estadio Doha', 'Doha', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (98, 7, 'Estadio Lusail', 'Lusail', 48000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (99, 7, 'Estadio Al Rayyan', 'Al Rayyan', 85000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (100, 7, 'Estadio Al Wakrah', 'Al Wakrah', 45000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (101, 7, 'Estadio Al Khor', 'Al Khor', 90000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (102, 7, 'Estadio Umm Salal', 'Umm Salal', 38000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (103, 7, 'Estadio Al Daayen', 'Al Daayen', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (104, 7, 'Estadio Al Shamal', 'Al Shamal', 68000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (105, 7, 'Estadio Dukhan', 'Dukhan', 76000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (106, 7, 'Estadio Mesaieed', 'Mesaieed', 41000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (107, 7, 'Estadio Al Shahaniya', 'Al Shahaniya', 80000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (108, 7, 'Estadio Madinat Khalifa', 'Madinat Khalifa', 72000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (109, 7, 'Estadio Al Gharrafa', 'Al Gharrafa', 60000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (110, 7, 'Estadio Al Sadd', 'Al Sadd', 64000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (111, 7, 'Estadio Al Thumama', 'Al Thumama', 45000);
INSERT INTO estadio (id_estadio, id_edicion, nombre, ciudad, capacidad) VALUES (112, 7, 'Estadio Ras Laffan', 'Ras Laffan', 64000);


-- ============================================================
-- 3. SELECCION  (224 filas -- 32 por edicion)
-- ============================================================
-- 32 selecciones por edicion, repartidas en 8 grupos de 4 (A a H),
-- que es el formato que uso el Mundial hasta 2022.
--
-- Restricciones que deben cumplirse:
--   - id_edicion tiene que existir en EDICION_MUNDIAL
--   - un pais no se puede repetir dentro de la misma edicion
--   - confederacion solo puede ser una de las seis de la FIFA
--   - grupo es una letra entre A y L
-- ------------------------------------------------------------

-- Edicion 1
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (1, 1, 'Fiyi', 'OFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (2, 1, 'Inglaterra', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (3, 1, 'Jamaica', 'CONCACAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (4, 1, 'Paraguay', 'CONMEBOL', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (5, 1, 'Japon', 'AFC', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (6, 1, 'Arabia Saudita', 'AFC', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (7, 1, 'Ucrania', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (8, 1, 'Australia', 'AFC', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (9, 1, 'Marruecos', 'CAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (10, 1, 'Catar', 'AFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (11, 1, 'Camerun', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (12, 1, 'Paises Bajos', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (13, 1, 'Ghana', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (14, 1, 'Escocia', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (15, 1, 'Iran', 'AFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (16, 1, 'Suiza', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (17, 1, 'Costa Rica', 'CONCACAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (18, 1, 'Nigeria', 'CAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (19, 1, 'Mexico', 'CONCACAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (20, 1, 'Estados Unidos', 'CONCACAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (21, 1, 'Chequia', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (22, 1, 'Espana', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (23, 1, 'Croacia', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (24, 1, 'Belgica', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (25, 1, 'Brasil', 'CONMEBOL', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (26, 1, 'Uruguay', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (27, 1, 'Chile', 'CONMEBOL', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (28, 1, 'Dinamarca', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (29, 1, 'Gales', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (30, 1, 'Corea del Sur', 'AFC', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (31, 1, 'Nueva Zelanda', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (32, 1, 'Argelia', 'CAF', 'F');

-- Edicion 2
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (33, 2, 'Egipto', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (34, 2, 'Senegal', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (35, 2, 'Serbia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (36, 2, 'Espana', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (37, 2, 'Paises Bajos', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (38, 2, 'Arabia Saudita', 'AFC', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (39, 2, 'Nueva Zelanda', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (40, 2, 'Ucrania', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (41, 2, 'Nigeria', 'CAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (42, 2, 'Canada', 'CONCACAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (43, 2, 'Chequia', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (44, 2, 'Ghana', 'CAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (45, 2, 'Iran', 'AFC', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (46, 2, 'Uruguay', 'CONMEBOL', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (47, 2, 'Croacia', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (48, 2, 'Dinamarca', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (49, 2, 'Estados Unidos', 'CONCACAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (50, 2, 'Ecuador', 'CONMEBOL', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (51, 2, 'Gales', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (52, 2, 'Mexico', 'CONCACAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (53, 2, 'Panama', 'CONCACAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (54, 2, 'Costa de Marfil', 'CAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (55, 2, 'Francia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (56, 2, 'Irak', 'AFC', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (57, 2, 'Marruecos', 'CAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (58, 2, 'Chile', 'CONMEBOL', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (59, 2, 'Corea del Sur', 'AFC', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (60, 2, 'Bolivia', 'CONMEBOL', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (61, 2, 'Catar', 'AFC', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (62, 2, 'Portugal', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (63, 2, 'Camerun', 'CAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (64, 2, 'Colombia', 'CONMEBOL', 'C');

-- Edicion 3
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (65, 3, 'Espana', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (66, 3, 'Uzbekistan', 'AFC', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (67, 3, 'Jamaica', 'CONCACAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (68, 3, 'Noruega', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (69, 3, 'Venezuela', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (70, 3, 'Gales', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (71, 3, 'Brasil', 'CONMEBOL', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (72, 3, 'Peru', 'CONMEBOL', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (73, 3, 'Canada', 'CONCACAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (74, 3, 'Costa Rica', 'CONCACAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (75, 3, 'Argelia', 'CAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (76, 3, 'Camerun', 'CAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (77, 3, 'Estados Unidos', 'CONCACAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (78, 3, 'Mali', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (79, 3, 'Fiyi', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (80, 3, 'Portugal', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (81, 3, 'Paraguay', 'CONMEBOL', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (82, 3, 'Australia', 'AFC', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (83, 3, 'Uruguay', 'CONMEBOL', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (84, 3, 'Catar', 'AFC', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (85, 3, 'Belgica', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (86, 3, 'Suecia', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (87, 3, 'Panama', 'CONCACAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (88, 3, 'Mexico', 'CONCACAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (89, 3, 'Dinamarca', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (90, 3, 'Senegal', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (91, 3, 'Ghana', 'CAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (92, 3, 'Serbia', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (93, 3, 'Chile', 'CONMEBOL', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (94, 3, 'Tunez', 'CAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (95, 3, 'Japon', 'AFC', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (96, 3, 'Corea del Sur', 'AFC', 'G');

-- Edicion 4
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (97, 4, 'Argelia', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (98, 4, 'Bolivia', 'CONMEBOL', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (99, 4, 'Costa de Marfil', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (100, 4, 'Arabia Saudita', 'AFC', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (101, 4, 'Nigeria', 'CAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (102, 4, 'Croacia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (103, 4, 'Peru', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (104, 4, 'Noruega', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (105, 4, 'Iran', 'AFC', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (106, 4, 'Alemania', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (107, 4, 'Nueva Zelanda', 'OFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (108, 4, 'Fiyi', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (109, 4, 'Suiza', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (110, 4, 'Panama', 'CONCACAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (111, 4, 'Estados Unidos', 'CONCACAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (112, 4, 'Austria', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (113, 4, 'Venezuela', 'CONMEBOL', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (114, 4, 'Egipto', 'CAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (115, 4, 'Espana', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (116, 4, 'Corea del Sur', 'AFC', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (117, 4, 'Brasil', 'CONMEBOL', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (118, 4, 'Ecuador', 'CONMEBOL', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (119, 4, 'Catar', 'AFC', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (120, 4, 'Chile', 'CONMEBOL', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (121, 4, 'Colombia', 'CONMEBOL', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (122, 4, 'Suecia', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (123, 4, 'Dinamarca', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (124, 4, 'Francia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (125, 4, 'Camerun', 'CAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (126, 4, 'Tunez', 'CAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (127, 4, 'Chequia', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (128, 4, 'Paises Bajos', 'UEFA', 'C');

-- Edicion 5
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (129, 5, 'Marruecos', 'CAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (130, 5, 'Dinamarca', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (131, 5, 'Australia', 'AFC', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (132, 5, 'Suiza', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (133, 5, 'Gales', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (134, 5, 'Nueva Zelanda', 'OFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (135, 5, 'Paraguay', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (136, 5, 'Senegal', 'CAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (137, 5, 'Ucrania', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (138, 5, 'Tunez', 'CAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (139, 5, 'Mali', 'CAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (140, 5, 'Alemania', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (141, 5, 'Venezuela', 'CONMEBOL', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (142, 5, 'Argelia', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (143, 5, 'Egipto', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (144, 5, 'Italia', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (145, 5, 'Chequia', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (146, 5, 'Irak', 'AFC', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (147, 5, 'Polonia', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (148, 5, 'Mexico', 'CONCACAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (149, 5, 'Inglaterra', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (150, 5, 'Chile', 'CONMEBOL', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (151, 5, 'Escocia', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (152, 5, 'Uruguay', 'CONMEBOL', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (153, 5, 'Espana', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (154, 5, 'Francia', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (155, 5, 'Argentina', 'CONMEBOL', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (156, 5, 'Costa Rica', 'CONCACAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (157, 5, 'Belgica', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (158, 5, 'Noruega', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (159, 5, 'Fiyi', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (160, 5, 'Uzbekistan', 'AFC', 'D');

-- Edicion 6
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (161, 6, 'Nueva Zelanda', 'OFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (162, 6, 'Mexico', 'CONCACAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (163, 6, 'Corea del Sur', 'AFC', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (164, 6, 'Espana', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (165, 6, 'Marruecos', 'CAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (166, 6, 'Catar', 'AFC', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (167, 6, 'Australia', 'AFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (168, 6, 'Argentina', 'CONMEBOL', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (169, 6, 'Bolivia', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (170, 6, 'Jamaica', 'CONCACAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (171, 6, 'Egipto', 'CAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (172, 6, 'Italia', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (173, 6, 'Irak', 'AFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (174, 6, 'Fiyi', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (175, 6, 'Alemania', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (176, 6, 'Francia', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (177, 6, 'Austria', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (178, 6, 'Belgica', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (179, 6, 'Chequia', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (180, 6, 'Camerun', 'CAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (181, 6, 'Noruega', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (182, 6, 'Peru', 'CONMEBOL', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (183, 6, 'Japon', 'AFC', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (184, 6, 'Suiza', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (185, 6, 'Uzbekistan', 'AFC', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (186, 6, 'Suecia', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (187, 6, 'Ghana', 'CAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (188, 6, 'Canada', 'CONCACAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (189, 6, 'Inglaterra', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (190, 6, 'Portugal', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (191, 6, 'Argelia', 'CAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (192, 6, 'Costa Rica', 'CONCACAF', 'C');

-- Edicion 7
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (193, 7, 'Croacia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (194, 7, 'Ucrania', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (195, 7, 'Francia', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (196, 7, 'Dinamarca', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (197, 7, 'Egipto', 'CAF', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (198, 7, 'Marruecos', 'CAF', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (199, 7, 'Gales', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (200, 7, 'Paraguay', 'CONMEBOL', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (201, 7, 'Panama', 'CONCACAF', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (202, 7, 'Mexico', 'CONCACAF', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (203, 7, 'Belgica', 'UEFA', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (204, 7, 'Ecuador', 'CONMEBOL', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (205, 7, 'Italia', 'UEFA', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (206, 7, 'Inglaterra', 'UEFA', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (207, 7, 'Brasil', 'CONMEBOL', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (208, 7, 'Peru', 'CONMEBOL', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (209, 7, 'Nueva Zelanda', 'OFC', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (210, 7, 'Polonia', 'UEFA', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (211, 7, 'Noruega', 'UEFA', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (212, 7, 'Camerun', 'CAF', 'H');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (213, 7, 'Jamaica', 'CONCACAF', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (214, 7, 'Argentina', 'CONMEBOL', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (215, 7, 'Suecia', 'UEFA', 'C');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (216, 7, 'Alemania', 'UEFA', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (217, 7, 'Argelia', 'CAF', 'A');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (218, 7, 'Arabia Saudita', 'AFC', 'F');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (219, 7, 'Colombia', 'CONMEBOL', 'D');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (220, 7, 'Suiza', 'UEFA', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (221, 7, 'Nigeria', 'CAF', 'B');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (222, 7, 'Bolivia', 'CONMEBOL', 'E');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (223, 7, 'Irak', 'AFC', 'G');
INSERT INTO seleccion (id_seleccion, id_edicion, pais, confederacion, grupo) VALUES (224, 7, 'Austria', 'UEFA', 'F');

-- ============================================================
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
