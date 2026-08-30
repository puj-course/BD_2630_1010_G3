-- ============================================================
-- Proyecto Base de Datos - Mundial FIFA
-- Entrega 1 - Creacion del modelo inicial (5 tablas)
-- Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
-- Motor: Oracle 19c
-- ============================================================
-- Se ejecuta sobre el esquema propio de cada estudiante.
-- No se modifica nada del esquema MORENOLUIS, que es de solo lectura.
-- ============================================================

-- Evita que SQLcl corte las sentencias al llegar a una linea en blanco.
SET SQLBLANKLINES ON


-- ------------------------------------------------------------
-- Borrado previo, para poder ejecutar el script varias veces.
-- El orden es al reves del de creacion: primero las tablas hijas.
-- La primera vez dan error ORA-00942 porque las tablas aun no existen.
-- ------------------------------------------------------------

DROP TABLE participacion_partido;
DROP TABLE partido;
DROP TABLE seleccion;
DROP TABLE estadio;
DROP TABLE edicion_mundial;


-- ------------------------------------------------------------
-- 1. EDICION_MUNDIAL - cada version del Mundial
-- ------------------------------------------------------------

CREATE TABLE edicion_mundial (
    id_edicion    NUMBER(10)     NOT NULL,
    anio          NUMBER(4)      NOT NULL,
    pais_sede     VARCHAR2(100)  NOT NULL,
    lema          VARCHAR2(200),
    fecha_inicio  DATE           NOT NULL,
    fecha_fin     DATE           NOT NULL,
    -- Llave primaria
    CONSTRAINT pk_edicion PRIMARY KEY (id_edicion),
    -- Solo hay un Mundial por anio
    CONSTRAINT uq_edicion_anio UNIQUE (anio),
    -- El primer Mundial fue en 1930
    CONSTRAINT ck_edicion_anio CHECK (anio BETWEEN 1930 AND 2100),
    -- No puede terminar antes de empezar
    CONSTRAINT ck_edicion_fechas CHECK (fecha_fin > fecha_inicio)
);


-- ------------------------------------------------------------
-- 2. ESTADIO - los estadios de una edicion
-- ------------------------------------------------------------

CREATE TABLE estadio (
    id_estadio  NUMBER(10)     NOT NULL,
    id_edicion  NUMBER(10)     NOT NULL,
    nombre      VARCHAR2(150)  NOT NULL,
    ciudad      VARCHAR2(100)  NOT NULL,
    capacidad   NUMBER(10)     NOT NULL,
    CONSTRAINT pk_estadio PRIMARY KEY (id_estadio),
    -- Sin ON DELETE: en Oracle eso significa que no se puede borrar
    -- una edicion que todavia tenga estadios registrados.
    CONSTRAINT fk_estadio_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- Dos estadios de la misma edicion no pueden llamarse igual
    CONSTRAINT uq_estadio_nombre UNIQUE (id_edicion, nombre),
    -- Aforo razonable para un estadio de Mundial
    CONSTRAINT ck_estadio_capacidad CHECK (capacidad BETWEEN 20000 AND 150000)
);


-- ------------------------------------------------------------
-- 3. SELECCION - los equipos de una edicion
-- ------------------------------------------------------------

CREATE TABLE seleccion (
    id_seleccion   NUMBER(10)     NOT NULL,
    id_edicion     NUMBER(10)     NOT NULL,
    pais           VARCHAR2(100)  NOT NULL,
    confederacion  VARCHAR2(50)   NOT NULL,
    grupo          VARCHAR2(1),
    CONSTRAINT pk_seleccion PRIMARY KEY (id_seleccion),
    CONSTRAINT fk_seleccion_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- Un pais solo puede estar una vez en la misma edicion
    CONSTRAINT uq_seleccion_pais UNIQUE (id_edicion, pais),
    -- La FIFA tiene seis confederaciones
    CONSTRAINT ck_seleccion_confederacion CHECK
        (confederacion IN ('CONMEBOL','UEFA','CAF','AFC','CONCACAF','OFC')),
    -- Los grupos van de la A a la L. Puede ser nulo si aun no hay sorteo.
    -- Se usa una lista y no BETWEEN: sobre texto, BETWEEN compara alfabeticamente,
    -- asi que 'AB' o 'Kansas' pasarian el filtro por empezar entre la A y la L.
    CONSTRAINT ck_seleccion_grupo CHECK
        (grupo IS NULL OR grupo IN ('A','B','C','D','E','F','G','H','I','J','K','L'))
);


-- ------------------------------------------------------------
-- 4. PARTIDO - cada encuentro del torneo
-- ------------------------------------------------------------

CREATE TABLE partido (
    id_partido             NUMBER(10)    NOT NULL,
    id_edicion             NUMBER(10)    NOT NULL,
    id_estadio             NUMBER(10)    NOT NULL,
    fecha_hora             TIMESTAMP     NOT NULL,
    fase                   VARCHAR2(50)  NOT NULL,
    asistencia_registrada  NUMBER(10),
    CONSTRAINT pk_partido PRIMARY KEY (id_partido),
    CONSTRAINT fk_partido_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- Sin ON DELETE: no se puede borrar un estadio que ya tiene partidos
    CONSTRAINT fk_partido_estadio FOREIGN KEY (id_estadio)
        REFERENCES estadio (id_estadio),
    -- Un estadio no puede tener dos partidos a la misma hora
    CONSTRAINT uq_partido_agenda UNIQUE (id_estadio, fecha_hora),
    -- Fases posibles del torneo
    CONSTRAINT ck_partido_fase CHECK (fase IN
        ('Fase de Grupos','Dieciseisavos','Octavos','Cuartos',
         'Semifinal','Tercer Puesto','Final')),
    -- La asistencia no puede ser negativa. Es nula si no se ha jugado.
    CONSTRAINT ck_partido_asistencia CHECK (asistencia_registrada >= 0)
);


-- ------------------------------------------------------------
-- 5. PARTICIPACION_PARTIDO - que seleccion jugo cada partido
--    y cuantos goles marco. Resuelve la relacion muchos a muchos
--    entre PARTIDO y SELECCION.
-- ------------------------------------------------------------

CREATE TABLE participacion_partido (
    id_participacion  NUMBER(10)    NOT NULL,
    id_partido        NUMBER(10)    NOT NULL,
    id_seleccion      NUMBER(10)    NOT NULL,
    condicion         VARCHAR2(20)  NOT NULL,
    goles_marcados    NUMBER(3)     DEFAULT 0 NOT NULL,
    CONSTRAINT pk_participacion PRIMARY KEY (id_participacion),
    -- CASCADE: si se borra el partido, sus dos participaciones no
    -- tienen sentido por separado, asi que se borran con el.
    CONSTRAINT fk_participacion_partido FOREIGN KEY (id_partido)
        REFERENCES partido (id_partido) ON DELETE CASCADE,
    -- Sin ON DELETE: no se puede borrar una seleccion que ya jugo
    -- partidos, porque se perderia el historial del torneo.
    CONSTRAINT fk_participacion_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion),
    -- Una seleccion no puede aparecer dos veces en el mismo partido
    CONSTRAINT uq_participacion_seleccion UNIQUE (id_partido, id_seleccion),
    -- Un partido tiene un solo local y un solo visitante
    CONSTRAINT uq_participacion_condicion UNIQUE (id_partido, condicion),
    CONSTRAINT ck_participacion_condicion CHECK (condicion IN ('LOCAL','VISITANTE')),
    -- No hay goles negativos. El tope de 15 sale del reglamento: la mayor
    -- goleada de un equipo en un Mundial fue Hungria 10-1 a El Salvador en
    -- 1982, asi que 15 deja margen y a la vez detecta errores de digitacion.
    CONSTRAINT ck_participacion_goles CHECK (goles_marcados BETWEEN 0 AND 15)
);


-- ------------------------------------------------------------
-- Indices
-- ------------------------------------------------------------
-- Oracle crea indices solos para las llaves primarias y las UNIQUE,
-- pero no para las llaves foraneas. Creamos indice en las dos columnas
-- de llave foranea que no quedan cubiertas por ningun otro indice y que
-- mas se usan en los JOIN de las consultas.
-- ------------------------------------------------------------

CREATE INDEX ix_partido_edicion ON partido (id_edicion);
CREATE INDEX ix_participacion_seleccion ON participacion_partido (id_seleccion);


-- ------------------------------------------------------------
-- Reglas que no se pueden poner como CHECK
-- ------------------------------------------------------------
-- Un CHECK solo puede mirar la fila que se esta insertando: no puede
-- consultar otras tablas ni contar filas. Por eso estas cuatro reglas
-- del proyecto se verifican con consultas, y se implementaran como
-- triggers en la Entrega 3:
--
--   1. Todo partido debe tener exactamente dos participaciones.
--      Las UNIQUE garantizan que no sean mas de dos, pero no que sean dos.
--   2. La fecha del partido debe estar dentro del rango de su edicion.
--   3. El estadio del partido debe ser de la misma edicion del partido.
--   4. Las dos selecciones del partido deben ser de esa misma edicion.
--   5. Cada grupo debe tener exactamente 4 selecciones.
--      Tambien exige contar filas, asi que tampoco se puede poner como CHECK.
-- ------------------------------------------------------------

EXIT;
