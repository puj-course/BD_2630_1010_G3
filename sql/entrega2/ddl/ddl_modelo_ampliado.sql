-- ============================================================
-- Proyecto Base de Datos - Mundial FIFA
-- Entrega 2 - Modelo ampliado (16 tablas)
-- Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
-- Motor: Oracle 19c
-- ============================================================
-- Se ejecuta sobre el esquema propio de cada estudiante.
-- Amplia el modelo de la Entrega 1: separa sede, ciudad y estadio,
-- fase y grupo como entidades, y agrega jugadores, cuerpo tecnico,
-- arbitros, estadisticas e incidencias.
-- ============================================================

-- Evita que SQLcl corte las sentencias al llegar a una linea en blanco.
SET SQLBLANKLINES ON


-- ------------------------------------------------------------
-- Borrado previo, para poder ejecutar el script varias veces.
-- El orden es al reves del de creacion: primero las tablas hijas.
-- La primera vez dan error ORA-00942 porque las tablas aun no existen.
-- ------------------------------------------------------------

-- PURGE evita que las tablas borradas se queden en la papelera de Oracle,
-- que va acumulando basura cada vez que se re-ejecuta el script.
DROP TABLE incidencia PURGE;
DROP TABLE estadistica_jugador_partido PURGE;
DROP TABLE asignacion_arbitral PURGE;
DROP TABLE arbitro PURGE;
DROP TABLE cuerpo_tecnico PURGE;
DROP TABLE convocatoria_jugador PURGE;
DROP TABLE jugador PURGE;
DROP TABLE participacion_partido PURGE;
DROP TABLE partido PURGE;
DROP TABLE seleccion PURGE;
DROP TABLE grupo PURGE;
DROP TABLE fase PURGE;
DROP TABLE estadio PURGE;
DROP TABLE ciudad PURGE;
DROP TABLE sede PURGE;
DROP TABLE edicion_mundial PURGE;


-- ------------------------------------------------------------
-- 1. EDICION_MUNDIAL - cada version del Mundial
-- ------------------------------------------------------------

CREATE TABLE edicion_mundial (
    id_edicion    NUMBER(10)     NOT NULL,
    anio          NUMBER(4)      NOT NULL,
    lema          VARCHAR2(200),
    fecha_inicio  DATE           NOT NULL,
    fecha_fin     DATE           NOT NULL,
    CONSTRAINT pk_edicion PRIMARY KEY (id_edicion),
    -- Solo hay un Mundial por anio
    CONSTRAINT uq_edicion_anio UNIQUE (anio),
    -- El primer Mundial fue en 1930
    CONSTRAINT ck_edicion_anio CHECK (anio BETWEEN 1930 AND 2100),
    -- No puede terminar antes de empezar
    CONSTRAINT ck_edicion_fechas CHECK (fecha_fin > fecha_inicio),
    -- Un Mundial dura semanas, no un dia. Esto atrapa fechas mal digitadas.
    CONSTRAINT ck_edicion_duracion CHECK (fecha_fin - fecha_inicio >= 7)
    -- El pais sede se movio a la tabla SEDE porque hubo mundiales con
    -- dos paises anfitriones (Corea y Japon 2002).
);


-- ------------------------------------------------------------
-- 2. SEDE - un pais anfitrion de una edicion
-- ------------------------------------------------------------
-- Un Mundial se puede jugar en varios paises (Corea-Japon 2002,
-- Estados Unidos-Mexico-Canada 2026), por eso la sede es una tabla.

CREATE TABLE sede (
    id_sede     NUMBER(10)     NOT NULL,
    id_edicion  NUMBER(10)     NOT NULL,
    pais        VARCHAR2(100)  NOT NULL,
    CONSTRAINT pk_sede PRIMARY KEY (id_sede),
    -- Sin ON DELETE: no se borra una edicion con sedes registradas.
    CONSTRAINT fk_sede_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- El mismo pais no se repite dos veces como sede de la misma edicion
    CONSTRAINT uq_sede_pais UNIQUE (id_edicion, pais),
    CONSTRAINT ck_sede_pais CHECK (TRIM(pais) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 3. CIUDAD - una ciudad anfitriona, dentro de una sede
-- ------------------------------------------------------------

CREATE TABLE ciudad (
    id_ciudad  NUMBER(10)     NOT NULL,
    id_sede    NUMBER(10)     NOT NULL,
    nombre     VARCHAR2(100)  NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_sede FOREIGN KEY (id_sede)
        REFERENCES sede (id_sede),
    -- El mismo nombre de ciudad no se repite dentro de la misma sede
    CONSTRAINT uq_ciudad_nombre UNIQUE (id_sede, nombre),
    CONSTRAINT ck_ciudad_nombre CHECK (TRIM(nombre) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 4. ESTADIO - el escenario de los partidos
-- ------------------------------------------------------------

CREATE TABLE estadio (
    id_estadio  NUMBER(10)     NOT NULL,
    id_ciudad   NUMBER(10)     NOT NULL,
    nombre      VARCHAR2(150)  NOT NULL,
    capacidad   NUMBER(10)     NOT NULL,
    CONSTRAINT pk_estadio PRIMARY KEY (id_estadio),
    -- Sin ON DELETE: no se borra una ciudad con estadios.
    CONSTRAINT fk_estadio_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad),
    -- Dos estadios de la misma ciudad no pueden llamarse igual
    CONSTRAINT uq_estadio_nombre UNIQUE (id_ciudad, nombre),
    -- Aforo razonable para un estadio de Mundial
    CONSTRAINT ck_estadio_capacidad CHECK (capacidad BETWEEN 20000 AND 150000),
    CONSTRAINT ck_estadio_nombre CHECK (TRIM(nombre) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 5. FASE - una etapa del torneo dentro de una edicion
-- ------------------------------------------------------------

CREATE TABLE fase (
    id_fase      NUMBER(10)     NOT NULL,
    id_edicion   NUMBER(10)     NOT NULL,
    nombre       VARCHAR2(50)   NOT NULL,
    orden_fase   NUMBER(2)      NOT NULL,
    tipo         VARCHAR2(20)   NOT NULL,
    CONSTRAINT pk_fase PRIMARY KEY (id_fase),
    CONSTRAINT fk_fase_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- El orden interesa para saber en que punto del torneo esta la fase
    CONSTRAINT uq_fase_orden UNIQUE (id_edicion, orden_fase),
    -- No puede haber dos fases con el mismo nombre en la misma edicion
    CONSTRAINT uq_fase_nombre UNIQUE (id_edicion, nombre),
    -- El orden empieza en 1 y la fase de grupos manda al resto
    CONSTRAINT ck_fase_orden CHECK (orden_fase >= 1),
    -- Fases que usa el formato real del torneo
    CONSTRAINT ck_fase_nombre CHECK (nombre IN
        ('Fase de Grupos','Dieciseisavos','Octavos','Cuartos',
         'Semifinal','Tercer Puesto','Final')),
    -- La fase de grupos es la unica que no es eliminatoria: tras ella
    -- ningun empate define, siempre tiene que pasar alguien.
    CONSTRAINT ck_fase_tipo CHECK (tipo IN ('GRUPOS','ELIMINATORIA'))
);


-- ------------------------------------------------------------
-- 6. GRUPO - un grupo de la fase de grupos de una edicion
-- ------------------------------------------------------------

CREATE TABLE grupo (
    id_grupo  NUMBER(10)     NOT NULL,
    id_fase   NUMBER(10)     NOT NULL,
    nombre    VARCHAR2(1)    NOT NULL,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_fase FOREIGN KEY (id_fase)
        REFERENCES fase (id_fase),
    -- No puede haber dos grupos con la misma letra en la misma fase
    CONSTRAINT uq_grupo_nombre UNIQUE (id_fase, nombre),
    -- Los grupos van de la A a la L. Se usa una lista y no BETWEEN:
    -- sobre texto, BETWEEN compara alfabeticamente y 'AB' pasa el filtro.
    CONSTRAINT ck_grupo_nombre CHECK (nombre IN
        ('A','B','C','D','E','F','G','H','I','J','K','L'))
);


-- ------------------------------------------------------------
-- 7. SELECCION - los equipos de una edicion
-- ------------------------------------------------------------

CREATE TABLE seleccion (
    id_seleccion   NUMBER(10)     NOT NULL,
    id_edicion     NUMBER(10)     NOT NULL,
    id_grupo       NUMBER(10),
    pais           VARCHAR2(100)  NOT NULL,
    confederacion  VARCHAR2(50)   NOT NULL,
    CONSTRAINT pk_seleccion PRIMARY KEY (id_seleccion),
    CONSTRAINT fk_seleccion_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    -- Una seleccion pertenece a un grupo solo mientras no arrancan
    -- las eliminatorias. Por eso puede ser nulo.
    CONSTRAINT fk_seleccion_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo),
    -- Un pais solo puede estar una vez en la misma edicion
    CONSTRAINT uq_seleccion_pais UNIQUE (id_edicion, pais),
    -- La FIFA tiene seis confederaciones
    CONSTRAINT ck_seleccion_confederacion CHECK
        (confederacion IN ('CONMEBOL','UEFA','CAF','AFC','CONCACAF','OFC')),
    CONSTRAINT ck_seleccion_pais CHECK (TRIM(pais) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 8. PARTIDO - cada encuentro del torneo
-- ------------------------------------------------------------

CREATE TABLE partido (
    id_partido             NUMBER(10)    NOT NULL,
    id_edicion             NUMBER(10)    NOT NULL,
    id_fase                NUMBER(10)    NOT NULL,
    id_estadio             NUMBER(10)    NOT NULL,
    id_partido_siguiente   NUMBER(10),
    fecha_hora             TIMESTAMP     NOT NULL,
    asistencia_registrada  NUMBER(10),
    CONSTRAINT pk_partido PRIMARY KEY (id_partido),
    CONSTRAINT fk_partido_edicion FOREIGN KEY (id_edicion)
        REFERENCES edicion_mundial (id_edicion),
    CONSTRAINT fk_partido_fase FOREIGN KEY (id_fase)
        REFERENCES fase (id_fase),
    -- Sin ON DELETE: no se borra un estadio que ya tiene partidos
    CONSTRAINT fk_partido_estadio FOREIGN KEY (id_estadio)
        REFERENCES estadio (id_estadio),
    -- Que partido viene despues en el cuadro: el ganador de este juega
    -- alli. Solo tiene sentido en eliminatorias, por eso es opcional.
    CONSTRAINT fk_partido_siguiente FOREIGN KEY (id_partido_siguiente)
        REFERENCES partido (id_partido),
    -- Un estadio no puede tener dos partidos a la misma hora
    CONSTRAINT uq_partido_agenda UNIQUE (id_estadio, fecha_hora),
    -- La asistencia no puede ser negativa. Es nula si no se ha jugado.
    CONSTRAINT ck_partido_asistencia CHECK (asistencia_registrada >= 0)
);


-- ------------------------------------------------------------
-- 9. PARTICIPACION_PARTIDO - que seleccion jugo cada partido
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
    -- Sin ON DELETE: no se borra una seleccion que ya jugo.
    CONSTRAINT fk_participacion_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion),
    -- Una seleccion no puede aparecer dos veces en el mismo partido
    CONSTRAINT uq_participacion_seleccion UNIQUE (id_partido, id_seleccion),
    -- Un partido tiene un solo local y un solo visitante
    CONSTRAINT uq_participacion_condicion UNIQUE (id_partido, condicion),
    CONSTRAINT ck_participacion_condicion CHECK (condicion IN ('LOCAL','VISITANTE')),
    -- El tope de 15 sale del reglamento: la mayor goleada de un equipo
    -- en un Mundial fue Hungria 10-1 a El Salvador en 1982.
    CONSTRAINT ck_participacion_goles CHECK (goles_marcados BETWEEN 0 AND 15)
);


-- ------------------------------------------------------------
-- 10. JUGADOR - la ficha basica de un jugador
-- ------------------------------------------------------------
-- El jugador no esta ligado a una seleccion: eso lo decide la
-- convocatoria. Asi, un jugador que paso por varias ediciones (o por
-- distintas selecciones) se registra una sola vez aca.

CREATE TABLE jugador (
    id_jugador  NUMBER(10)     NOT NULL,
    nombre      VARCHAR2(150)  NOT NULL,
    posicion    VARCHAR2(20)   NOT NULL,
    club        VARCHAR2(150),
    CONSTRAINT pk_jugador PRIMARY KEY (id_jugador),
    -- Las posiciones clasicas del futbol
    CONSTRAINT ck_jugador_posicion CHECK (posicion IN
        ('Arquero','Defensa','Volante','Delantero')),
    CONSTRAINT ck_jugador_nombre CHECK (TRIM(nombre) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 11. CONVOCATORIA_JUGADOR - jugador convocado por una seleccion
--     en una edicion, con su numero de camiseta.
-- ------------------------------------------------------------

CREATE TABLE convocatoria_jugador (
    id_convocatoria  NUMBER(10)     NOT NULL,
    id_jugador       NUMBER(10)     NOT NULL,
    id_seleccion     NUMBER(10)     NOT NULL,
    numero_camiseta  NUMBER(3)      NOT NULL,
    es_capitan       NUMBER(1)      DEFAULT 0 NOT NULL,
    CONSTRAINT pk_convocatoria PRIMARY KEY (id_convocatoria),
    CONSTRAINT fk_convocatoria_jugador FOREIGN KEY (id_jugador)
        REFERENCES jugador (id_jugador),
    -- Sin ON DELETE: no se borra una seleccion con historial.
    CONSTRAINT fk_convocatoria_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion),
    -- Un jugador solo va una vez en la misma convocatoria
    CONSTRAINT uq_convocatoria_jugador UNIQUE (id_jugador, id_seleccion),
    -- No puede haber dos jugadores con el mismo numero en el mismo equipo
    CONSTRAINT uq_convocatoria_numero UNIQUE (id_seleccion, numero_camiseta),
    -- La FIFA permite listas de hasta 26 convocados desde el Mundial 2022
    CONSTRAINT ck_convocatoria_numero CHECK (numero_camiseta BETWEEN 1 AND 26),
    CONSTRAINT ck_convocatoria_capitan CHECK (es_capitan IN (0, 1))
);


-- ------------------------------------------------------------
-- 12. CUERPO_TECNICO - la gente que esta detras de cada seleccion
-- ------------------------------------------------------------

CREATE TABLE cuerpo_tecnico (
    id_cuerpo_tecnico  NUMBER(10)     NOT NULL,
    id_seleccion       NUMBER(10)     NOT NULL,
    nombre             VARCHAR2(150)  NOT NULL,
    cargo              VARCHAR2(50)   NOT NULL,
    CONSTRAINT pk_cuerpo_tecnico PRIMARY KEY (id_cuerpo_tecnico),
    -- Sin ON DELETE: no se borra una seleccion con cuerpo tecnico.
    CONSTRAINT fk_cuerpo_tecnico_seleccion FOREIGN KEY (id_seleccion)
        REFERENCES seleccion (id_seleccion),
    -- Los cargos habituales de un banquillo
    CONSTRAINT ck_cuerpo_tecnico_cargo CHECK (cargo IN
        ('Director tecnico','Asistente tecnico','Preparador fisico',
         'Entrenador de porteros','Medico')),
    CONSTRAINT ck_cuerpo_tecnico_nombre CHECK (TRIM(nombre) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 13. ARBITRO - el arbitro del torneo
-- ------------------------------------------------------------

CREATE TABLE arbitro (
    id_arbitro     NUMBER(10)     NOT NULL,
    nombre         VARCHAR2(150)  NOT NULL,
    nacionalidad   VARCHAR2(100)  NOT NULL,
    CONSTRAINT pk_arbitro PRIMARY KEY (id_arbitro),
    CONSTRAINT ck_arbitro_nombre CHECK (TRIM(nombre) IS NOT NULL),
    CONSTRAINT ck_arbitro_nacionalidad CHECK (TRIM(nacionalidad) IS NOT NULL)
);


-- ------------------------------------------------------------
-- 14. ASIGNACION_ARBITRAL - que arbitro hizo que rol en que partido
-- ------------------------------------------------------------

CREATE TABLE asignacion_arbitral (
    id_asignacion  NUMBER(10)     NOT NULL,
    id_partido     NUMBER(10)     NOT NULL,
    id_arbitro     NUMBER(10)     NOT NULL,
    rol            VARCHAR2(30)   NOT NULL,
    CONSTRAINT pk_asignacion PRIMARY KEY (id_asignacion),
    -- CASCADE: si se borra el partido, la asignacion no tiene sentido.
    CONSTRAINT fk_asignacion_partido FOREIGN KEY (id_partido)
        REFERENCES partido (id_partido) ON DELETE CASCADE,
    -- Sin ON DELETE: no se borra un arbitro que ya pito.
    CONSTRAINT fk_asignacion_arbitro FOREIGN KEY (id_arbitro)
        REFERENCES arbitro (id_arbitro),
    -- El mismo arbitro no puede tener dos roles en el mismo partido.
    -- Para conocer los roles reales de la terna se consulta
    -- ARBITRO, y un partido solo tiene un jugador por rol.
    CONSTRAINT uq_asignacion_arbitro UNIQUE (id_partido, id_arbitro),
    -- Los roles del equipo arbitral en un partido
    CONSTRAINT ck_asignacion_rol CHECK (rol IN
        ('Principal','Asistente 1','Asistente 2','Cuarto arbitro',
         'VAR','AVAR'))
);


-- ------------------------------------------------------------
-- 15. ESTADISTICA_JUGADOR_PARTIDO - el rendimiento individual
--     en un partido
-- ------------------------------------------------------------

CREATE TABLE estadistica_jugador_partido (
    id_estadistica       NUMBER(10)    NOT NULL,
    id_partido           NUMBER(10)    NOT NULL,
    id_jugador           NUMBER(10)    NOT NULL,
    titular              NUMBER(1)     NOT NULL,
    minuto_entrada       NUMBER(3),
    minuto_salida        NUMBER(3),
    minutos_jugados      NUMBER(3)     NOT NULL,
    goles                NUMBER(3)     DEFAULT 0 NOT NULL,
    asistencias          NUMBER(3)     DEFAULT 0 NOT NULL,
    tarjetas_amarillas   NUMBER(2)     DEFAULT 0 NOT NULL,
    tarjetas_rojas       NUMBER(2)     DEFAULT 0 NOT NULL,
    CONSTRAINT pk_estadistica PRIMARY KEY (id_estadistica),
    -- CASCADE: las estadisticas del partido se van con el partido.
    CONSTRAINT fk_estadistica_partido FOREIGN KEY (id_partido)
        REFERENCES partido (id_partido) ON DELETE CASCADE,
    -- Sin ON DELETE: no se borra un jugador con historial.
    CONSTRAINT fk_estadistica_jugador FOREIGN KEY (id_jugador)
        REFERENCES jugador (id_jugador),
    -- El mismo jugador no puede tener dos registros del mismo partido
    CONSTRAINT uq_estadistica_jugador UNIQUE (id_partido, id_jugador),
    -- Si inicio el partido no pudo "entrar" despues. El que no inicio
    -- tiene que haber entrado en algun momento del juego.
    CONSTRAINT ck_estadistica_titular CHECK (titular IN (0, 1)),
    CONSTRAINT ck_estadistica_entradas CHECK
        ((titular = 0 AND minuto_entrada IS NOT NULL)
         OR (titular = 1 AND minuto_entrada IS NULL)),
    CONSTRAINT ck_estadistica_entradas_rango CHECK
        ((minuto_entrada IS NULL OR minuto_entrada BETWEEN 0 AND 120)
         AND (minuto_salida IS NULL OR minuto_salida BETWEEN 0 AND 120)),
    -- El minuto 120 toma el caso limite de un partido que se alarga.
    CONSTRAINT ck_estadistica_minutos CHECK (minutos_jugados BETWEEN 0 AND 120),
    CONSTRAINT ck_estadistica_counters CHECK
        (goles >= 0 AND asistencias >= 0
         AND tarjetas_amarillas >= 0 AND tarjetas_rojas >= 0)
);


-- ------------------------------------------------------------
-- 16. INCIDENCIA - eventos durante un partido
-- ------------------------------------------------------------

CREATE TABLE incidencia (
    id_incidencia  NUMBER(10)     NOT NULL,
    id_partido     NUMBER(10)     NOT NULL,
    tipo           VARCHAR2(20)   NOT NULL,
    minuto         NUMBER(3)      NOT NULL,
    descripcion    VARCHAR2(300),
    CONSTRAINT pk_incidencia PRIMARY KEY (id_incidencia),
    -- CASCADE: las incidencias del partido se van con el partido.
    CONSTRAINT fk_incidencia_partido FOREIGN KEY (id_partido)
        REFERENCES partido (id_partido) ON DELETE CASCADE,
    CONSTRAINT ck_incidencia_tipo CHECK (tipo IN
        ('TARJETA','LESION','VAR','INVASION','SUSPENSION','OTRO')),
    CONSTRAINT ck_incidencia_minuto CHECK (minuto BETWEEN 0 AND 120)
);


-- ------------------------------------------------------------
-- Indices
-- ------------------------------------------------------------
-- Oracle crea indices solos para las llaves primarias y las UNIQUE,
-- pero no para las llaves foraneas. Se indexan las columnas de llave
-- foranea que mas se usan en los JOIN de las consultas.
-- ------------------------------------------------------------

CREATE INDEX ix_partido_edicion ON partido (id_edicion);
CREATE INDEX ix_partido_fase ON partido (id_fase);
CREATE INDEX ix_partido_estadio ON partido (id_estadio);
CREATE INDEX ix_partido_siguiente ON partido (id_partido_siguiente);
CREATE INDEX ix_participacion_seleccion ON participacion_partido (id_seleccion);
CREATE INDEX ix_estadistica_jugador ON estadistica_jugador_partido (id_jugador);
CREATE INDEX ix_convocatoria_jugador ON convocatoria_jugador (id_jugador);
CREATE INDEX ix_convocatoria_seleccion ON convocatoria_jugador (id_seleccion);
CREATE INDEX ix_asignacion_arbitro ON asignacion_arbitral (id_arbitro);
CREATE INDEX ix_incidencia_partido ON incidencia (id_partido);


-- ------------------------------------------------------------
-- Reglas que no se pueden poner como CHECK
-- ------------------------------------------------------------
-- Un CHECK solo puede mirar la fila que se esta insertando: no puede
-- consultar otras tablas ni contar filas. Estas reglas del proyecto
-- se verifican con consultas, y se implementaran como triggers en la
-- Entrega 3:
--
--   A. Todo partido debe tener exactamente dos participaciones.
--      Las UNIQUE garantizan que no sean mas de dos, pero no que sean dos.
--   B. La fecha del partido debe estar dentro del rango de su edicion.
--   C. El estadio del partido debe pertenecer a la misma edicion del
--      partido. Ahora se recorre ESTADIO -> CIUDAD -> SEDE -> EDICION_MUNDIAL.
--   D. Las dos selecciones del partido deben ser de esa misma edicion.
--   E. Cada grupo debe tener exactamente 4 selecciones.
--   F. La asistencia de un partido no puede superar el aforo de su
--      estadio, para lo que hay que consultar otra tabla.
--   G. Una seleccion no puede jugar dos partidos a la misma fecha y hora.
--   H. En fase eliminatoria no puede haber empate.
--   I. La fase del partido debe ser una fase de la edicion del partido.
--   J. El partido siguiente (id_partido_siguiente) debe ser de la misma
--      edicion y de una fase posterior a la de este partido. Ademas
--      un FK compuesto por fases podria evitar que un partido de la
--      fase de grupos apunte a un "siguiente", pero la regla real es
--      deportiva: solo en eliminatorias hay un partido siguiente.
--   K. Los partidos de la fase de grupos de una edicion descansan
--      entre fase y fase: no pueden cruzarse dos de la misma fecha.
--   L. La cantidad de convocados por seleccion tiene tope reglamentario
--      (26 desde el Mundial 2022). CUERPO_TECNICO sin limite de filas.
--   M. Un jugador solo puede marcar/registrar estadistica en partidos
--      de la edicion de la seleccion que lo convoco.
--   N. La suma de goles de los jugadores de una seleccion en un partido
--      debe ser igual al goles_marcados de su participacion en ese
--      partido.
--   O. Un arbitro no puede estar asignado a dos partidos que se juegan
--      a la misma hora. ASIGNACION_ARBITRAL no puede comparar fechas.
-- ------------------------------------------------------------

EXIT;