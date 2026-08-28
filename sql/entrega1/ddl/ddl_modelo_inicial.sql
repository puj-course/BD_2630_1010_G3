-- =============================================================================
--  Proyecto: Sistema de Informacion para la Gestion Integral de la Copa Mundial
--            de la FIFA
--  Entrega 1 - Script DDL del Modelo Generico Inicial (5 entidades)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================
--
--  ALCANCE
--  -------
--  Este script implementa UNICAMENTE el modelo generico inicial descrito en la
--  Seccion 6 del enunciado: EDICION_MUNDIAL, ESTADIO, SELECCION, PARTIDO y
--  PARTICIPACION_PARTIDO. El modelo ampliado (jugadores, arbitros, estadisticas,
--  boleteria, incidencias, auditoria) corresponde a la Entrega 2.
--
--  Se ejecuta sobre el ESQUEMA PROPIO de cada integrante (p. ej. IS101009).
--  NO se ejecuta ni se modifica nada sobre MORENOLUIS, que es de solo lectura.
--
--  AJUSTES MENORES FRENTE AL MODELO DEL ENUNCIADO (justificados)
--  -------------------------------------------------------------
--  1. PARTIDO.ASISTENCIA_REGISTRADA: el enunciado no la lista en la Seccion 6,
--     pero la Consulta 2 exige calcular ocupacion = asistencia/capacidad*100.
--     Sin este atributo la consulta es irrealizable. La tabla de referencia
--     MORENOLUIS.FIFA_PARTIDO tambien la incluye.
--  2. SELECCION.GRUPO: la Consulta 15 pide determinar que seleccion lidera cada
--     grupo. Sin este atributo no hay grupos que liderar. La tabla de referencia
--     MORENOLUIS.FIFA_SELECCION tambien lo incluye.
--  Ambos ajustes estan permitidos por la Seccion 8.1.1 numeral 3 del enunciado
--  ("puede incluir ajustes menores, siempre que se justifiquen").
--
--  NOTA SOBRE ON UPDATE
--  --------------------
--  Oracle Database NO implementa la clausula referencial ON UPDATE. El estandar
--  SQL la contempla, pero Oracle solo soporta ON DELETE CASCADE y
--  ON DELETE SET NULL. La ausencia de ON UPDATE no es una omision del diseno:
--  es una limitacion del motor. La politica equivalente se consigue usando
--  llaves primarias sinteticas e inmutables (los ID nunca se actualizan), que es
--  exactamente la decision de diseno adoptada aqui. De requerirse propagacion de
--  actualizaciones, se implementaria con un trigger (Entrega 3).
--
--  NOTA SOBRE "ON DELETE RESTRICT"
--  -------------------------------
--  Oracle tampoco tiene la sintaxis ON DELETE RESTRICT / NO ACTION. En Oracle,
--  OMITIR la clausula ON DELETE equivale a RESTRICT: el borrado del padre falla
--  con ORA-02292 si existen hijos. Por eso, en este script, toda FK sin clausula
--  ON DELETE es deliberadamente restrictiva y asi esta comentada.
-- =============================================================================


-- =============================================================================
--  SECCION 0 - LIMPIEZA (permite re-ejecutar el script desde cero)
--  El orden es inverso al de creacion para respetar las dependencias.
-- =============================================================================

--  Se usa un bloque PL/SQL en lugar de DROP TABLE directo porque un DROP sobre
--  una tabla inexistente lanza ORA-00942 y abortaria la primera ejecucion del
--  script en una base limpia. Aqui esa excepcion concreta se ignora y cualquier
--  otra se vuelve a lanzar.

BEGIN
    FOR t IN (
        SELECT column_value AS nombre
        FROM TABLE(sys.odcivarchar2list(
            'PARTICIPACION_PARTIDO',
            'PARTIDO',
            'SELECCION',
            'ESTADIO',
            'EDICION_MUNDIAL'))
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.nombre || ' CASCADE CONSTRAINTS PURGE';
            dbms_output.put_line('Eliminada: ' || t.nombre);
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN   -- -942 = la tabla no existe: es correcto
                    RAISE;
                END IF;
        END;
    END LOOP;
END;
/


-- =============================================================================
--  SECCION 1 - EDICION_MUNDIAL
--  Entidad raiz del modelo. Representa una edicion del torneo.
-- =============================================================================

CREATE TABLE edicion_mundial (
    id_edicion    NUMBER(10)     NOT NULL,
    anio          NUMBER(4)      NOT NULL,
    pais_sede     VARCHAR2(100)  NOT NULL,
    lema          VARCHAR2(200),
    fecha_inicio  DATE           NOT NULL,
    fecha_fin     DATE           NOT NULL,

    -- PK sintetica e inmutable: desacopla la identidad de la edicion de su anio,
    -- de modo que corregir el anio nunca obliga a propagar cambios a las FK.
    CONSTRAINT pk_edicion_mundial PRIMARY KEY (id_edicion),

    -- Regla de negocio: la FIFA organiza a lo sumo una Copa Mundial masculina por
    -- anio. Esta UNIQUE impide cargar dos veces la misma edicion.
    CONSTRAINT uq_edicion_anio UNIQUE (anio),

    -- La primera Copa Mundial se disputo en 1930 (Uruguay); cota superior amplia
    -- para permitir cargar ediciones futuras ya adjudicadas.
    CONSTRAINT ck_edicion_anio_rango
        CHECK (anio BETWEEN 1930 AND 2100),

    -- Coherencia temporal basica del periodo del torneo.
    CONSTRAINT ck_edicion_fechas
        CHECK (fecha_fin > fecha_inicio),

    -- Regla derivada del reglamento: una Copa Mundial se disputa en una ventana
    -- de aproximadamente un mes. Historicamente ninguna edicion ha durado menos
    -- de 15 dias (1930: 13 dias es la excepcion previa al formato moderno) ni
    -- mas de 60. Esta cota detecta cargas erroneas de fechas.
    CONSTRAINT ck_edicion_duracion
        CHECK (fecha_fin - fecha_inicio BETWEEN 13 AND 60),

    -- Evita cadenas vacias o solo espacios, que Oracle no considera NULL.
    CONSTRAINT ck_edicion_pais_sede_no_vacio
        CHECK (TRIM(pais_sede) IS NOT NULL)
);

COMMENT ON TABLE  edicion_mundial IS 'Cada version de la Copa Mundial de la FIFA. Entidad raiz de la jerarquia organizacional del torneo.';
COMMENT ON COLUMN edicion_mundial.id_edicion   IS 'Identificador sintetico de la edicion. PK inmutable.';
COMMENT ON COLUMN edicion_mundial.anio         IS 'Anio en que se disputa la edicion. Unico en toda la tabla.';
COMMENT ON COLUMN edicion_mundial.pais_sede    IS 'Pais o paises anfitriones de la edicion.';
COMMENT ON COLUMN edicion_mundial.lema         IS 'Lema oficial de la edicion. Opcional: no todas las ediciones tienen uno registrado.';
COMMENT ON COLUMN edicion_mundial.fecha_inicio IS 'Fecha del partido inaugural.';
COMMENT ON COLUMN edicion_mundial.fecha_fin    IS 'Fecha de la final.';


-- =============================================================================
--  SECCION 2 - ESTADIO
--  Escenario donde se disputan los partidos, perteneciente a una edicion.
-- =============================================================================

CREATE TABLE estadio (
    id_estadio  NUMBER(10)     NOT NULL,
    id_edicion  NUMBER(10)     NOT NULL,
    nombre      VARCHAR2(150)  NOT NULL,
    ciudad      VARCHAR2(100)  NOT NULL,
    capacidad   NUMBER(10)     NOT NULL,

    CONSTRAINT pk_estadio PRIMARY KEY (id_estadio),

    -- FK 1 -- ESTADIO -> EDICION_MUNDIAL
    -- ON DELETE CASCADE: un estadio en este modelo no es un inmueble del mundo
    -- real reutilizable entre ediciones, sino "el estadio tal como fue inscrito
    -- en esta edicion" (por eso lleva id_edicion). Si se elimina la edicion, sus
    -- estadios inscritos pierden todo significado y deben desaparecer con ella.
    -- Esta es una de las DOS relaciones usadas para demostrar el comportamiento
    -- ON DELETE en el script de DML (la contraparte RESTRICT es la FK 6).
    CONSTRAINT fk_estadio_edicion
        FOREIGN KEY (id_edicion) REFERENCES edicion_mundial (id_edicion)
        ON DELETE CASCADE,

    -- Regla de negocio: dentro de una misma edicion no puede haber dos estadios
    -- con el mismo nombre (seria un duplicado de carga). El mismo nombre SI
    -- puede repetirse entre ediciones distintas, porque un estadio real alberga
    -- varios mundiales a lo largo del tiempo.
    CONSTRAINT uq_estadio_edicion_nombre UNIQUE (id_edicion, nombre),

    -- Regla derivada del reglamento FIFA de infraestructura: los estadios de una
    -- Copa Mundial deben superar las 40.000 localidades para fase de grupos,
    -- 60.000 para semifinales y 80.000 para la final. Se usa una cota inferior
    -- mas permisiva (20.000) para no invalidar ediciones historicas antiguas, y
    -- una cota superior de 150.000 (el Estadio Rungrado, el mayor del mundo,
    -- ronda las 114.000). El proposito es atrapar errores de digitacion.
    CONSTRAINT ck_estadio_capacidad
        CHECK (capacidad BETWEEN 20000 AND 150000),

    CONSTRAINT ck_estadio_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL),
    CONSTRAINT ck_estadio_ciudad_no_vacia CHECK (TRIM(ciudad) IS NOT NULL),

    -- Llave candidata compuesta: destino de la FK compuesta de PARTIDO que
    -- garantiza que un partido solo pueda jugarse en un estadio de SU edicion.
    CONSTRAINT uq_estadio_id_edicion UNIQUE (id_estadio, id_edicion)
);

COMMENT ON TABLE  estadio IS 'Estadio inscrito en una edicion del Mundial. La pertenencia a la edicion forma parte de su identidad.';
COMMENT ON COLUMN estadio.id_estadio IS 'Identificador sintetico del estadio. PK inmutable.';
COMMENT ON COLUMN estadio.id_edicion IS 'Edicion a la que pertenece el estadio. FK con borrado en cascada.';
COMMENT ON COLUMN estadio.nombre     IS 'Nombre del estadio. Unico dentro de su edicion.';
COMMENT ON COLUMN estadio.ciudad     IS 'Ciudad donde se ubica el estadio.';
COMMENT ON COLUMN estadio.capacidad  IS 'Aforo maximo de espectadores. Cota base para el calculo de ocupacion.';


-- =============================================================================
--  SECCION 3 - SELECCION
--  Equipo nacional que participa en una edicion determinada.
-- =============================================================================

CREATE TABLE seleccion (
    id_seleccion   NUMBER(10)     NOT NULL,
    id_edicion     NUMBER(10)     NOT NULL,
    pais           VARCHAR2(100)  NOT NULL,
    confederacion  VARCHAR2(50)   NOT NULL,
    grupo          VARCHAR2(5),

    CONSTRAINT pk_seleccion PRIMARY KEY (id_seleccion),

    -- FK 2 -- SELECCION -> EDICION_MUNDIAL
    -- ON DELETE CASCADE: por el mismo motivo que ESTADIO. Una fila de SELECCION
    -- no representa a la federacion nacional en abstracto, sino su
    -- participacion concreta en UNA edicion. Sin la edicion, no existe.
    CONSTRAINT fk_seleccion_edicion
        FOREIGN KEY (id_edicion) REFERENCES edicion_mundial (id_edicion)
        ON DELETE CASCADE,

    -- Regla de negocio central: un pais clasifica a lo sumo una vez por edicion.
    -- Impide inscribir dos veces a la misma seleccion en el mismo torneo.
    CONSTRAINT uq_seleccion_edicion_pais UNIQUE (id_edicion, pais),

    -- Dominio cerrado: la FIFA reconoce exactamente seis confederaciones.
    -- Modelarlo como CHECK (y no como texto libre) es una decision consciente
    -- para la Entrega 1; en la Evaluacion Critica se propone promoverlo a una
    -- entidad CONFEDERACION propia.
    CONSTRAINT ck_seleccion_confederacion
        CHECK (confederacion IN ('CONMEBOL','UEFA','CAF','AFC','CONCACAF','OFC')),

    -- Los grupos de la fase inicial se identifican con una unica letra mayuscula.
    -- Hasta 2022 fueron 8 grupos (A-H); desde 2026 son 12 (A-L). Se admite el
    -- rango A-L. Es NULL para selecciones aun no sorteadas en un grupo.
    CONSTRAINT ck_seleccion_grupo
        CHECK (grupo IS NULL OR grupo BETWEEN 'A' AND 'L'),

    CONSTRAINT ck_seleccion_pais_no_vacio CHECK (TRIM(pais) IS NOT NULL)
);

COMMENT ON TABLE  seleccion IS 'Equipo nacional inscrito en una edicion concreta del Mundial.';
COMMENT ON COLUMN seleccion.id_seleccion  IS 'Identificador sintetico de la seleccion. PK inmutable.';
COMMENT ON COLUMN seleccion.id_edicion    IS 'Edicion en la que participa. FK con borrado en cascada.';
COMMENT ON COLUMN seleccion.pais          IS 'Pais representado. Unico dentro de su edicion.';
COMMENT ON COLUMN seleccion.confederacion IS 'Confederacion FIFA a la que pertenece: CONMEBOL, UEFA, CAF, AFC, CONCACAF u OFC.';
COMMENT ON COLUMN seleccion.grupo         IS 'Letra del grupo de la fase inicial (A-L). NULL si aun no ha sido sorteada.';


-- =============================================================================
--  SECCION 4 - PARTIDO
--  Encuentro programado dentro de una edicion, en un estadio y una fase.
-- =============================================================================

CREATE TABLE partido (
    id_partido             NUMBER(10)  NOT NULL,
    id_edicion             NUMBER(10)  NOT NULL,
    id_estadio             NUMBER(10)  NOT NULL,
    fecha_hora             TIMESTAMP   NOT NULL,
    fase                   VARCHAR2(50) NOT NULL,
    asistencia_registrada  NUMBER(10),

    CONSTRAINT pk_partido PRIMARY KEY (id_partido),

    -- FK 3 -- PARTIDO -> EDICION_MUNDIAL
    -- SIN clausula ON DELETE, es decir, RESTRICT.
    --
    -- Esta eleccion NO es arbitraria: es lo que hace determinista el borrado de
    -- una edicion. Si esta FK fuera CASCADE, borrar una edicion desencadenaria
    -- DOS caminos de cascada simultaneos (hacia ESTADIO y hacia PARTIDO) que
    -- convergen en la FK 4, que es restrictiva. Oracle no garantiza el orden en
    -- que resuelve cascadas por caminos multiples, asi que el mismo DELETE
    -- podria tener exito o fallar con ORA-02292 de forma no reproducible.
    -- Declarandola restrictiva, la semantica queda univoca y verificable:
    --
    --    * Edicion SIN partidos registrados -> se elimina y arrastra en cascada
    --      sus estadios y sus selecciones (FK 1 y FK 2).
    --    * Edicion CON partidos registrados -> el borrado falla siempre.
    --      Es ademas el comportamiento deseable: una edicion ya disputada es
    --      historia del torneo y debe archivarse, no eliminarse. El enunciado
    --      contempla explicitamente esta alternativa en la Seccion 8.1.2.
    --
    -- La FK se declara aunque la integridad de id_edicion ya quedaria
    -- garantizada de forma transitiva por la FK 4 (PARTIDO -> ESTADIO ->
    -- EDICION_MUNDIAL), porque reproduce fielmente la relacion Edicion-Partido
    -- del modelo del enunciado y la hace explicita en el diccionario de datos.
    CONSTRAINT fk_partido_edicion
        FOREIGN KEY (id_edicion) REFERENCES edicion_mundial (id_edicion),

    -- FK 4 -- PARTIDO -> ESTADIO, COMPUESTA por (id_estadio, id_edicion).
    --
    -- Esta es la decision de diseno mas importante del script. Una FK simple
    -- (id_estadio -> estadio.id_estadio) permitiria programar un partido de la
    -- edicion 2026 en un estadio inscrito en la edicion 2018: seria
    -- referencialmente valido y semanticamente absurdo.
    -- Al referenciar la llave candidata UQ_ESTADIO_ID_EDICION con la pareja
    -- (id_estadio, id_edicion), el motor garantiza DE FORMA DECLARATIVA que el
    -- estadio pertenece a la misma edicion del partido. No hace falta trigger.
    --
    -- Se OMITE la clausula ON DELETE de forma deliberada: en Oracle eso equivale
    -- a RESTRICT. Borrar un estadio que ya alberga partidos programados debe
    -- fallar (ORA-02292), porque implicaria perder el historial del torneo. Es
    -- la contraparte RESTRICT que el script de DML contrasta contra el CASCADE
    -- de la FK 1.
    CONSTRAINT fk_partido_estadio_edicion
        FOREIGN KEY (id_estadio, id_edicion)
        REFERENCES estadio (id_estadio, id_edicion),

    -- Dominio cerrado de fases. Cubre el formato clasico (32 equipos, desde
    -- octavos) y el formato 2026 (48 equipos, que agrega los dieciseisavos).
    CONSTRAINT ck_partido_fase
        CHECK (fase IN ('Fase de Grupos','Dieciseisavos','Octavos','Cuartos',
                        'Semifinal','Tercer Puesto','Final')),

    -- Un estadio no puede albergar dos partidos a la misma fecha y hora.
    -- Evita el cruce de agenda exigido por la Seccion 8.1.2 del enunciado.
    CONSTRAINT uq_partido_estadio_fecha UNIQUE (id_estadio, fecha_hora),

    -- La asistencia no puede ser negativa. Es NULL mientras el partido no se ha
    -- jugado o no se ha reportado la cifra oficial.
    CONSTRAINT ck_partido_asistencia
        CHECK (asistencia_registrada IS NULL OR asistencia_registrada >= 0)
);

COMMENT ON TABLE  partido IS 'Encuentro programado en una edicion, en un estadio y una fase determinadas.';
COMMENT ON COLUMN partido.id_partido            IS 'Identificador sintetico del partido. PK inmutable.';
COMMENT ON COLUMN partido.id_edicion            IS 'Edicion a la que pertenece el partido. Parte de la FK compuesta hacia ESTADIO.';
COMMENT ON COLUMN partido.id_estadio            IS 'Estadio donde se disputa. Restringido por FK compuesta a estadios de la misma edicion.';
COMMENT ON COLUMN partido.fecha_hora            IS 'Fecha y hora de inicio programada. Unica por estadio.';
COMMENT ON COLUMN partido.fase                  IS 'Etapa del torneo: Fase de Grupos, Dieciseisavos, Octavos, Cuartos, Semifinal, Tercer Puesto o Final.';
COMMENT ON COLUMN partido.asistencia_registrada IS 'Espectadores reportados. NULL si el partido no se ha jugado. Numerador del calculo de ocupacion.';


-- =============================================================================
--  SECCION 5 - PARTICIPACION_PARTIDO
--  Entidad asociativa que resuelve la relacion N:M entre PARTIDO y SELECCION.
-- =============================================================================

CREATE TABLE participacion_partido (
    id_participacion  NUMBER(10)   NOT NULL,
    id_partido        NUMBER(10)   NOT NULL,
    id_seleccion      NUMBER(10)   NOT NULL,
    condicion         VARCHAR2(20) NOT NULL,
    goles_marcados    NUMBER(3)    DEFAULT 0 NOT NULL,

    CONSTRAINT pk_participacion_partido PRIMARY KEY (id_participacion),

    -- FK 5 -- PARTICIPACION_PARTIDO -> PARTIDO
    -- ON DELETE CASCADE: una participacion no tiene existencia propia fuera de
    -- su partido; es una entidad debil por dependencia de existencia. Si el
    -- partido se elimina, sus dos participaciones deben irse con el, o el modelo
    -- queda con filas huerfanas sin significado.
    CONSTRAINT fk_participacion_partido
        FOREIGN KEY (id_partido) REFERENCES partido (id_partido)
        ON DELETE CASCADE,

    -- FK 6 -- PARTICIPACION_PARTIDO -> SELECCION
    -- SIN clausula ON DELETE, es decir, RESTRICT.
    -- Asimetria deliberada frente a la FK 5: borrar una seleccion que ya jugo
    -- partidos falsearia el historial del torneo (los marcadores de sus rivales
    -- quedarian sin contraparte). El enunciado (Seccion 8.1.2) pide justamente
    -- "no permitir eliminar una seleccion que ya tiene partidos registrados".
    -- El intento fallara con ORA-02292 y asi queda demostrado en pruebas_dml.md.
    CONSTRAINT fk_participacion_seleccion
        FOREIGN KEY (id_seleccion) REFERENCES seleccion (id_seleccion),

    -- Dominio cerrado de la condicion del equipo en el encuentro.
    CONSTRAINT ck_participacion_condicion
        CHECK (condicion IN ('LOCAL','VISITANTE')),

    -- ANTI-DUPLICIDAD: una seleccion no puede aparecer dos veces en el mismo
    -- partido. Es la restriccion que verifica la Consulta 14.
    CONSTRAINT uq_participacion_partido_seleccion
        UNIQUE (id_partido, id_seleccion),

    -- Un partido tiene a lo sumo UN local y UN visitante. Junto con la anterior,
    -- acota el partido a un maximo de dos participaciones y garantiza que no se
    -- registren dos equipos con la misma condicion (exigido por el enunciado).
    CONSTRAINT uq_participacion_partido_condicion
        UNIQUE (id_partido, condicion),

    -- No se permiten goles negativos. Cota superior de 30 como deteccion de
    -- errores de digitacion: la mayor goleada en la historia de la Copa Mundial
    -- es Hungria 10 - El Salvador 1 (1982).
    CONSTRAINT ck_participacion_goles
        CHECK (goles_marcados BETWEEN 0 AND 30)
);

COMMENT ON TABLE  participacion_partido IS 'Entidad asociativa que resuelve la relacion N:M entre PARTIDO y SELECCION. Cada partido tiene exactamente dos filas aqui.';
COMMENT ON COLUMN participacion_partido.id_participacion IS 'Identificador sintetico de la participacion. PK inmutable.';
COMMENT ON COLUMN participacion_partido.id_partido       IS 'Partido en el que se participa. FK con borrado en cascada.';
COMMENT ON COLUMN participacion_partido.id_seleccion     IS 'Seleccion participante. FK restrictiva: no se borra una seleccion con historial.';
COMMENT ON COLUMN participacion_partido.condicion        IS 'Rol en el encuentro: LOCAL o VISITANTE. Unico por partido.';
COMMENT ON COLUMN participacion_partido.goles_marcados   IS 'Goles anotados por la seleccion en ese partido. Cero por defecto.';


-- =============================================================================
--  SECCION 6 - INDICES ESTRATEGICOS
-- =============================================================================
--  Criterio general: Oracle crea automaticamente un indice unico al declarar
--  PRIMARY KEY o UNIQUE, pero NO indexa las llaves foraneas. Una FK sin indice
--  provoca dos problemas: (a) bloqueos de tabla completa en la tabla hija al
--  hacer DML sobre el padre, y (b) full scans en los JOIN. Por eso se indexa
--  toda columna FK que no quede ya cubierta como columna LIDER de un indice
--  unico preexistente.
--
--  Cobertura ya existente (no se duplica indice):
--    - ESTADIO(id_edicion)               <- lider de UQ_ESTADIO_EDICION_NOMBRE
--    - SELECCION(id_edicion)             <- lider de UQ_SELECCION_EDICION_PAIS
--    - PARTIDO(id_estadio)               <- lider de UQ_PARTIDO_ESTADIO_FECHA
--    - PARTICIPACION_PARTIDO(id_partido) <- lider de UQ_PARTICIPACION_PARTIDO_SELECCION
-- =============================================================================

-- FK de PARTIDO hacia la edicion (FK 3): no es columna lider de ningun indice
-- unico, y una FK sin indice bloquea la tabla hija al borrar en el padre.
-- Acelera las Consultas 4, 5 y 12, que agrupan partidos por edicion.
CREATE INDEX ix_partido_edicion ON partido (id_edicion);

-- FK de PARTICIPACION_PARTIDO hacia la seleccion: no es lider de ningun indice.
-- Es la columna de JOIN mas usada de todo el modelo: la recorren las Consultas
-- 1, 3, 7, 10, 11 y 12 para agregar goles por seleccion.
CREATE INDEX ix_participacion_seleccion ON participacion_partido (id_seleccion);

-- Indice compuesto orientado a consulta (no a FK). Las Consultas 4, 12 y 13
-- filtran o agrupan partidos por edicion y fase simultaneamente; este indice
-- resuelve ambas columnas sin tocar la tabla.
CREATE INDEX ix_partido_edicion_fase ON partido (id_edicion, fase);

-- La Consulta 15 y la vista de tabla de posiciones recorren las selecciones
-- agrupando por edicion y grupo. Este indice evita ordenar en memoria.
CREATE INDEX ix_seleccion_edicion_grupo ON seleccion (id_edicion, grupo);

-- Las Consultas 2 y 8 calculan ocupacion agrupando por estadio y sumando
-- asistencia. Indice de cobertura: resuelve la agregacion sin acceder a la tabla.
CREATE INDEX ix_partido_estadio_asistencia ON partido (id_estadio, asistencia_registrada);


-- =============================================================================
--  SECCION 7 - REGLAS DE NEGOCIO NO EXPRESABLES DE FORMA DECLARATIVA
-- =============================================================================
--  Las siguientes reglas hacen parte del dominio pero NO pueden implementarse
--  con CHECK ni con FK en Oracle, porque una restriccion CHECK solo puede
--  referirse a columnas de su propia fila: no admite subconsultas ni funciones
--  de agregacion. Se documentan aqui de forma explicita, se verifican mediante
--  consultas de control (ver sql/entrega1/consultas/semana4_verificacion_integridad.sql
--  y la seccion de verificacion de tests/entrega1/pruebas_dml.md), y su
--  implementacion definitiva como TRIGGER corresponde a la Entrega 3, donde el
--  enunciado los exige explicitamente (Seccion 8.3.1).
--
--  R1. Todo partido debe tener EXACTAMENTE dos participaciones.
--      Las restricciones UQ_PARTICIPACION_PARTIDO_SELECCION y
--      UQ_PARTICIPACION_PARTIDO_CONDICION ya garantizan el limite SUPERIOR de
--      dos. El limite INFERIOR (que no haya partidos con cero o una) requiere
--      contar filas relacionadas -> trigger o consulta de verificacion.
--
--  R2. La fecha y hora de un partido debe caer dentro del rango
--      fecha_inicio-fecha_fin de su edicion.
--      Requiere leer EDICION_MUNDIAL desde un CHECK de PARTIDO -> imposible.
--
--  R3. Las dos selecciones de un partido deben pertenecer a la edicion del
--      partido.
--      Para ESTADIO esto SI se resolvio de forma declarativa, con la FK
--      compuesta FK_PARTIDO_ESTADIO_EDICION. Para SELECCION haria falta
--      denormalizar id_edicion dentro de PARTICIPACION_PARTIDO, lo que
--      introduciria una dependencia transitiva y romperia la 3FN. Se prefiere
--      conservar la normalizacion y verificar la regla por consulta.
--
--  R4. Una seleccion no puede enfrentarse a si misma.
--      Es un caso particular de R1/R3 y queda cubierto por
--      UQ_PARTICIPACION_PARTIDO_SELECCION solo si ambas filas comparten
--      id_partido, que es justamente el caso: dos filas con la misma seleccion
--      y el mismo partido violan la UNIQUE. Esta regla SI queda garantizada.
--
--  R5. El resultado (gano/perdio/empato) debe ser consistente con
--      goles_marcados de ambas participaciones.
--      En este modelo el resultado no se almacena: se DERIVA por consulta a
--      partir de goles_marcados, por lo que la inconsistencia es imposible por
--      construccion. Es una decision de diseno deliberada frente a almacenar un
--      campo redundante.
-- =============================================================================


-- =============================================================================
--  FIN DEL SCRIPT
-- =============================================================================
