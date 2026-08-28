-- =============================================================================
--  Proyecto: Gestion Integral de la Copa Mundial de la FIFA
--  Entrega 1 - Vistas sobre el modelo inicial
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================
--
--  Se implementan CUATRO vistas. Cada una responde a un criterio distinto de los
--  tres que justifica el enunciado (Seccion 8.1.4): reutilizacion de consultas
--  frecuentes, simplificacion de la logica para otros usuarios, y restriccion
--  del conjunto de columnas visibles.
--
--  La justificacion detallada de cada vista esta en docs/entrega1/vistas.md.
--  El resumen de que consulta reutiliza cada vista es:
--
--    V_RESUMEN_PARTIDO        -> Consultas 6 y 9
--    V_RENDIMIENTO_SELECCION  -> Consultas 1, 3, 7 y 11
--    V_OCUPACION_ESTADIO      -> Consultas 2 y 8
--    V_TABLA_POSICIONES       -> Consulta 15
--
--  Las vistas se disenaron ANTES que las consultas, precisamente para que la
--  reutilizacion sea real y no un maquillaje posterior.
-- =============================================================================


-- =============================================================================
--  VISTA 1 - V_RESUMEN_PARTIDO
-- =============================================================================
--  PROPOSITO: simplificacion de la logica para otros usuarios.
--
--  Reconstruir un marcador a partir del modelo normalizado obliga a pivotar
--  PARTICIPACION_PARTIDO: hay que unir la tabla consigo misma o agregarla con
--  CASE para pasar de dos filas (una por seleccion) a una sola fila con el
--  marcador. Esa maniobra se repetiria en casi todas las consultas del proyecto.
--  Esta vista la resuelve UNA vez y expone el partido como lo entenderia un
--  periodista: local, visitante, marcador, sede y resultado ya derivado.
--
--  Nota de diseno: el resultado NO se almacena en ninguna tabla, se DERIVA aqui.
--  Por construccion es imposible que el resultado contradiga los goles.
-- =============================================================================

CREATE OR REPLACE VIEW v_resumen_partido AS
SELECT
    p.id_partido,
    p.id_edicion,
    ed.anio,
    p.fase,
    p.fecha_hora,
    es.id_estadio,
    es.nombre                          AS estadio,
    es.ciudad,
    es.capacidad,
    p.asistencia_registrada,
    MAX(CASE WHEN pp.condicion = 'LOCAL'     THEN s.pais           END) AS seleccion_local,
    MAX(CASE WHEN pp.condicion = 'LOCAL'     THEN pp.goles_marcados END) AS goles_local,
    MAX(CASE WHEN pp.condicion = 'VISITANTE' THEN s.pais           END) AS seleccion_visitante,
    MAX(CASE WHEN pp.condicion = 'VISITANTE' THEN pp.goles_marcados END) AS goles_visitante,
    SUM(pp.goles_marcados)             AS goles_totales,
    CASE
        WHEN MAX(CASE WHEN pp.condicion = 'LOCAL'     THEN pp.goles_marcados END) >
             MAX(CASE WHEN pp.condicion = 'VISITANTE' THEN pp.goles_marcados END)
            THEN 'GANA LOCAL'
        WHEN MAX(CASE WHEN pp.condicion = 'LOCAL'     THEN pp.goles_marcados END) <
             MAX(CASE WHEN pp.condicion = 'VISITANTE' THEN pp.goles_marcados END)
            THEN 'GANA VISITANTE'
        ELSE 'EMPATE'
    END                                AS resultado
FROM partido p
JOIN edicion_mundial       ed ON ed.id_edicion   = p.id_edicion
JOIN estadio               es ON es.id_estadio   = p.id_estadio
JOIN participacion_partido pp ON pp.id_partido   = p.id_partido
JOIN seleccion             s  ON s.id_seleccion  = pp.id_seleccion
GROUP BY p.id_partido, p.id_edicion, ed.anio, p.fase, p.fecha_hora,
         es.id_estadio, es.nombre, es.ciudad, es.capacidad, p.asistencia_registrada;

COMMENT ON TABLE v_resumen_partido IS 'Vista desnormalizada del partido: local, visitante, marcador, sede y resultado derivado. Evita repetir el pivote de PARTICIPACION_PARTIDO en cada consulta.';


-- =============================================================================
--  VISTA 2 - V_RENDIMIENTO_SELECCION
-- =============================================================================
--  PROPOSITO: reutilizacion de una consulta frecuente.
--
--  Goles a favor, goles en contra y diferencia de gol son el insumo de la mitad
--  de las consultas analiticas del enunciado. Calcularlos exige una auto-junta
--  de PARTICIPACION_PARTIDO consigo misma para encontrar, por cada participacion,
--  la del rival en ese mismo partido. Encapsular esa auto-junta aqui evita
--  reescribirla (y equivocarse en ella) cuatro veces.
--
--  Cubre TODAS las fases del torneo, no solo la fase de grupos.
-- =============================================================================

CREATE OR REPLACE VIEW v_rendimiento_seleccion AS
SELECT
    s.id_seleccion,
    s.id_edicion,
    ed.anio,
    s.pais,
    s.confederacion,
    s.grupo,
    COUNT(*)                                                              AS partidos_jugados,
    SUM(CASE WHEN pp.goles_marcados > riv.goles_marcados THEN 1 ELSE 0 END) AS ganados,
    SUM(CASE WHEN pp.goles_marcados = riv.goles_marcados THEN 1 ELSE 0 END) AS empatados,
    SUM(CASE WHEN pp.goles_marcados < riv.goles_marcados THEN 1 ELSE 0 END) AS perdidos,
    SUM(CASE WHEN pp.condicion = 'LOCAL'     THEN 1 ELSE 0 END)           AS partidos_local,
    SUM(CASE WHEN pp.condicion = 'VISITANTE' THEN 1 ELSE 0 END)           AS partidos_visitante,
    SUM(pp.goles_marcados)                                                AS goles_favor,
    SUM(riv.goles_marcados)                                               AS goles_contra,
    SUM(pp.goles_marcados) - SUM(riv.goles_marcados)                      AS diferencia_gol
FROM seleccion s
JOIN edicion_mundial       ed  ON ed.id_edicion  = s.id_edicion
JOIN participacion_partido pp  ON pp.id_seleccion = s.id_seleccion
-- Auto-junta: por cada participacion se localiza la del rival en el mismo
-- partido. Es la unica forma de conocer los goles EN CONTRA en este modelo.
JOIN participacion_partido riv ON riv.id_partido   = pp.id_partido
                              AND riv.id_seleccion <> pp.id_seleccion
GROUP BY s.id_seleccion, s.id_edicion, ed.anio, s.pais, s.confederacion, s.grupo;

COMMENT ON TABLE v_rendimiento_seleccion IS 'Rendimiento acumulado de cada seleccion en su edicion: partidos, ganados/empatados/perdidos, goles a favor y en contra, diferencia de gol.';


-- =============================================================================
--  VISTA 3 - V_OCUPACION_ESTADIO
-- =============================================================================
--  PROPOSITO: reutilizacion de una consulta frecuente + simplificacion.
--
--  Aplica la formula de ocupacion definida en el enunciado (Seccion 8.1.9,
--  consulta 2):   ocupacion = asistencia_registrada / capacidad * 100
--  tomando la asistencia PROMEDIO de los partidos disputados en el estadio,
--  porque la capacidad es una cota por partido, no acumulada.
--
--  Se usa LEFT JOIN a proposito: un estadio inscrito que todavia no ha albergado
--  ningun partido debe aparecer con 0 partidos y ocupacion NULL, no desaparecer
--  del listado. Un INNER JOIN ocultaria silenciosamente esos estadios.
--
--  Encapsular aqui la formula garantiza que las consultas 2 y 8 usen exactamente
--  el mismo criterio de calculo: si se decidiera cambiar de promedio a maximo,
--  se cambia en un solo lugar.
-- =============================================================================

CREATE OR REPLACE VIEW v_ocupacion_estadio AS
SELECT
    es.id_estadio,
    es.id_edicion,
    ed.anio,
    es.nombre    AS estadio,
    es.ciudad,
    es.capacidad,
    COUNT(p.id_partido)                                              AS partidos_jugados,
    SUM(p.asistencia_registrada)                                     AS asistencia_total,
    ROUND(AVG(p.asistencia_registrada), 0)                           AS asistencia_promedio,
    ROUND(AVG(p.asistencia_registrada) / es.capacidad * 100, 2)      AS ocupacion_pct
FROM estadio es
JOIN edicion_mundial ed ON ed.id_edicion = es.id_edicion
LEFT JOIN partido    p  ON p.id_estadio  = es.id_estadio
GROUP BY es.id_estadio, es.id_edicion, ed.anio, es.nombre, es.ciudad, es.capacidad;

COMMENT ON TABLE v_ocupacion_estadio IS 'Ocupacion estimada por estadio segun la formula del enunciado. Incluye estadios sin partidos gracias al LEFT JOIN.';


-- =============================================================================
--  VISTA 4 - V_TABLA_POSICIONES
-- =============================================================================
--  PROPOSITO: simplificacion de la logica + restriccion del conjunto de columnas.
--
--  Es la vista de mayor valor de negocio: la tabla de posiciones por grupo, con
--  el sistema de puntuacion oficial de la FIFA (3 puntos por victoria, 1 por
--  empate, 0 por derrota). Un usuario final puede consultarla sin saber que
--  existen PARTICIPACION_PARTIDO ni las auto-juntas que hay detras.
--
--  Se limita deliberadamente a la FASE DE GRUPOS: las fases eliminatorias no
--  producen tabla de posiciones sino llaves, asi que incluirlas produciria una
--  clasificacion sin sentido. Este filtro es tambien un ejemplo de restriccion
--  del subconjunto de datos visibles.
--
--  El orden de desempate replica el del reglamento FIFA: puntos, diferencia de
--  gol y goles a favor.
--
--  Es la vista que reutiliza la Consulta 15.
-- =============================================================================

CREATE OR REPLACE VIEW v_tabla_posiciones AS
SELECT
    sel.id_edicion,
    ed.anio,
    sel.grupo,
    sel.id_seleccion,
    sel.pais,
    sel.confederacion,
    COUNT(*)                                                                AS partidos_jugados,
    SUM(CASE WHEN pp.goles_marcados > riv.goles_marcados THEN 1 ELSE 0 END) AS ganados,
    SUM(CASE WHEN pp.goles_marcados = riv.goles_marcados THEN 1 ELSE 0 END) AS empatados,
    SUM(CASE WHEN pp.goles_marcados < riv.goles_marcados THEN 1 ELSE 0 END) AS perdidos,
    SUM(pp.goles_marcados)                                                  AS goles_favor,
    SUM(riv.goles_marcados)                                                 AS goles_contra,
    SUM(pp.goles_marcados) - SUM(riv.goles_marcados)                        AS diferencia_gol,
    -- Sistema de puntuacion oficial FIFA.
    SUM(CASE WHEN pp.goles_marcados > riv.goles_marcados THEN 3
             WHEN pp.goles_marcados = riv.goles_marcados THEN 1
             ELSE 0 END)                                                    AS puntos,
    -- Posicion dentro del grupo, aplicando los desempates del reglamento.
    RANK() OVER (
        PARTITION BY sel.id_edicion, sel.grupo
        ORDER BY SUM(CASE WHEN pp.goles_marcados > riv.goles_marcados THEN 3
                          WHEN pp.goles_marcados = riv.goles_marcados THEN 1
                          ELSE 0 END)                            DESC,
                 SUM(pp.goles_marcados) - SUM(riv.goles_marcados) DESC,
                 SUM(pp.goles_marcados)                           DESC
    )                                                                       AS posicion_grupo
FROM seleccion sel
JOIN edicion_mundial       ed  ON ed.id_edicion   = sel.id_edicion
JOIN participacion_partido pp  ON pp.id_seleccion = sel.id_seleccion
JOIN partido               p   ON p.id_partido    = pp.id_partido
JOIN participacion_partido riv ON riv.id_partido   = pp.id_partido
                              AND riv.id_seleccion <> pp.id_seleccion
WHERE p.fase = 'Fase de Grupos'
  AND sel.grupo IS NOT NULL
GROUP BY sel.id_edicion, ed.anio, sel.grupo, sel.id_seleccion, sel.pais, sel.confederacion;

COMMENT ON TABLE v_tabla_posiciones IS 'Tabla de posiciones parcial por edicion y grupo, con puntuacion y desempates del reglamento FIFA. Solo fase de grupos.';


-- =============================================================================
--  FIN DEL SCRIPT
-- =============================================================================
