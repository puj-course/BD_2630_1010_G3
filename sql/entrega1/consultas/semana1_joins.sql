-- =============================================================================
--  Entrega 1 - Consultas SQL sobre el modelo inicial
--  Bloque: JOINS  (Consultas 2 y 6 del enunciado)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Consulta 2: Porcentaje de ocupacion estimado por estadio.
--
--   Formula definida por el enunciado (Seccion 8.1.9):
--       ocupacion = asistencia_registrada / capacidad * 100
--
--   Se toma la asistencia PROMEDIO de los partidos disputados en el estadio, no
--   la suma: la capacidad es una cota POR PARTIDO, de modo que sumar la
--   asistencia de seis encuentros y dividirla entre el aforo daria porcentajes
--   de varios cientos, sin significado.
--
--   Se usa LEFT JOIN de forma deliberada. Un estadio inscrito en la edicion que
--   todavia no ha albergado ningun partido debe aparecer con 0 partidos y
--   ocupacion nula, no desaparecer del informe: un INNER JOIN lo ocultaria en
--   silencio, que es justo el tipo de omision que hace que un reporte de
--   ocupacion mienta por ausencia.
--
--   Existe la vista V_OCUPACION_ESTADIO que encapsula exactamente este calculo
--   (y que reutiliza la Consulta 8). Aqui se escribe la junta de forma explicita
--   porque este archivo esta destinado a demostrar la tecnica de JOIN, y usar la
--   vista ocultaria precisamente lo que se quiere evidenciar.
-- -----------------------------------------------------------------------------

SELECT
    es.nombre                                                   AS estadio,
    es.ciudad,
    es.capacidad,
    COUNT(p.id_partido)                                         AS partidos_jugados,
    ROUND(AVG(p.asistencia_registrada), 0)                      AS asistencia_promedio,
    ROUND(AVG(p.asistencia_registrada) / es.capacidad * 100, 2) AS ocupacion_pct
FROM estadio es
LEFT JOIN partido p
       ON p.id_estadio = es.id_estadio
GROUP BY es.id_estadio, es.nombre, es.ciudad, es.capacidad
ORDER BY ocupacion_pct DESC NULLS LAST, estadio;


-- -----------------------------------------------------------------------------
-- Consulta 6: Identificacion de partidos con patrones atipicos.
--
--   El enunciado pide detectar marcadores inusualmente altos y partidos sin
--   goles, y deja explicitamente que el equipo defina y justifique sus propias
--   reglas. Las tres reglas adoptadas son:
--
--     * SIN GOLES      -> goles totales = 0.
--       Un 0-0 es estadisticamente atipico en un Mundial: alrededor del 8 % de
--       los partidos, y suele coincidir con encuentros de tramite en la ultima
--       jornada de grupos, donde ambos equipos ya estan clasificados.
--
--     * MARCADOR ALTO  -> goles totales >= 6.
--       El promedio historico de la Copa Mundial ronda los 2,7 goles por
--       partido. Seis o mas duplica con creces esa media.
--
--     * GOLEADA        -> diferencia absoluta >= 4.
--       Detecta un desequilibrio de nivel entre las dos selecciones, que es un
--       patron distinto al de "muchos goles": un 5-1 y un 3-3 tienen ambos seis
--       goles, pero solo el primero es una goleada.
--
--   El orden del CASE importa: un partido puede cumplir dos reglas a la vez
--   (por ejemplo 6-0, que es marcador alto Y goleada), y el CASE devuelve la
--   primera que coincide.
--
--   Se reutiliza la vista V_RESUMEN_PARTIDO, que ya resuelve el pivote de las
--   dos filas de PARTICIPACION_PARTIDO en un unico marcador, y se une con
--   EDICION_MUNDIAL para situar cada partido en su edicion.
-- -----------------------------------------------------------------------------

SELECT
    v.id_partido,
    v.id_edicion,
    ed.anio,
    v.fase,
    v.seleccion_local,
    v.goles_local,
    v.seleccion_visitante,
    v.goles_visitante,
    v.goles_totales,
    CASE
        WHEN v.goles_totales = 0                                THEN 'SIN GOLES'
        WHEN v.goles_totales >= 6                               THEN 'MARCADOR ALTO'
        WHEN ABS(v.goles_local - v.goles_visitante) >= 4         THEN 'GOLEADA'
    END                                                          AS patron
FROM v_resumen_partido v
JOIN edicion_mundial ed
      ON ed.id_edicion = v.id_edicion
WHERE v.goles_totales = 0
   OR v.goles_totales >= 6
   OR ABS(v.goles_local - v.goles_visitante) >= 4
ORDER BY v.id_edicion, v.goles_totales DESC, v.id_partido;
