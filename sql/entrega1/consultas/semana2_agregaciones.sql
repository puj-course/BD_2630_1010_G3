-- =============================================================================
--  Entrega 1 - Consultas SQL sobre el modelo inicial
--  Bloque: AGREGACIONES  (Consultas 1, 3, 4, 5, 9, 12 y 13 del enunciado)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Consulta 1: Top 5 selecciones con mas goles marcados.
--
--   Se agrupa por PAIS y no por ID_SELECCION de forma deliberada. En este modelo
--   una fila de SELECCION representa la participacion de un pais en UNA edicion
--   concreta, asi que Brasil 2018 y Brasil 2022 son dos filas distintas. La
--   pregunta "que selecciones han marcado mas goles" se refiere al pais a lo
--   largo de todo el historico, por lo que agrupar por pais es lo correcto.
--
--   FETCH FIRST ... ROWS ONLY es la sintaxis estandar disponible desde Oracle
--   12c; se prefiere a ROWNUM porque se aplica DESPUES del ORDER BY, mientras
--   que ROWNUM se asigna antes de ordenar y produciria un top 5 arbitrario.
--
--   Reutiliza la vista V_RENDIMIENTO_SELECCION.
-- -----------------------------------------------------------------------------

SELECT
    pais,
    SUM(goles_favor) AS goles_totales
FROM v_rendimiento_seleccion
GROUP BY pais
ORDER BY goles_totales DESC, pais
FETCH FIRST 5 ROWS ONLY;

-- Variante acotada a una unica edicion, por si se quiere el top 5 "de la
-- edicion modelada" en lugar del historico:
--
--   SELECT pais, SUM(goles_favor) AS goles_totales
--   FROM   v_rendimiento_seleccion
--   WHERE  id_edicion = (SELECT MAX(id_edicion) FROM edicion_mundial)
--   GROUP BY pais
--   ORDER BY goles_totales DESC, pais
--   FETCH FIRST 5 ROWS ONLY;


-- -----------------------------------------------------------------------------
-- Consulta 3: Selecciones con mayor diferencia de gol.
--
--   diferencia_gol = goles a favor - goles en contra, a lo largo de todos sus
--   partidos y de todas las fases.
--
--   Los goles EN CONTRA no estan almacenados en ninguna columna del modelo: son
--   los goles del rival, que viven en OTRA fila de PARTICIPACION_PARTIDO. La
--   vista V_RENDIMIENTO_SELECCION ya resuelve esa auto-junta, de modo que aqui
--   basta con agregar.
-- -----------------------------------------------------------------------------

SELECT
    pais,
    SUM(goles_favor)                        AS goles_favor,
    SUM(goles_contra)                       AS goles_contra,
    SUM(goles_favor) - SUM(goles_contra)    AS diferencia_gol
FROM v_rendimiento_seleccion
GROUP BY pais
ORDER BY diferencia_gol DESC, pais;


-- -----------------------------------------------------------------------------
-- Consulta 4: Partidos jugados por fase.
--
--   Cuenta cuantos partidos corresponden a cada fase del torneo.
--
--   El ORDER BY usa un CASE para imponer el orden CRONOLOGICO del torneo en
--   lugar del alfabetico. Ordenar por el nombre de la fase pondria 'Cuartos'
--   antes que 'Fase de Grupos' y la 'Final' en medio del listado, lo que no
--   refleja como avanza la competencia. Este es exactamente el problema que la
--   Evaluacion Critica propone resolver promoviendo FASE a una entidad propia
--   con un atributo de orden.
-- -----------------------------------------------------------------------------

SELECT
    p.fase,
    COUNT(*) AS num_partidos
FROM partido p
GROUP BY p.fase
ORDER BY CASE p.fase
             WHEN 'Fase de Grupos' THEN 1
             WHEN 'Dieciseisavos'  THEN 2
             WHEN 'Octavos'        THEN 3
             WHEN 'Cuartos'        THEN 4
             WHEN 'Semifinal'      THEN 5
             WHEN 'Tercer Puesto'  THEN 6
             WHEN 'Final'          THEN 7
         END;


-- -----------------------------------------------------------------------------
-- Consulta 5: Para cada edicion, el o los estadios que albergaron mas partidos.
--
--   El enunciado dice "cual o CUALES", asi que la consulta debe contemplar
--   EMPATES: si dos estadios de la misma edicion albergaron 6 partidos cada uno,
--   ambos deben aparecer. Por eso no sirve un simple ORDER BY ... FETCH FIRST 1.
--
--   Se resuelve comparando el conteo de cada estadio contra el maximo DE SU
--   PROPIA EDICION, mediante una subconsulta CORRELACIONADA: la subconsulta
--   interna se re-evalua para cada fila candidata, filtrando por c.id_edicion.
-- -----------------------------------------------------------------------------

WITH conteo_por_estadio AS (
    SELECT
        p.id_edicion,
        es.id_estadio,
        es.nombre AS estadio,
        COUNT(*)  AS n_partidos
    FROM partido p
    JOIN estadio es ON es.id_estadio = p.id_estadio
    GROUP BY p.id_edicion, es.id_estadio, es.nombre
)
SELECT
    c.id_edicion,
    c.estadio,
    c.n_partidos
FROM conteo_por_estadio c
WHERE c.n_partidos = (
        SELECT MAX(c2.n_partidos)
        FROM   conteo_por_estadio c2
        WHERE  c2.id_edicion = c.id_edicion   -- correlacion con la fila externa
      )
ORDER BY c.id_edicion, c.estadio;


-- -----------------------------------------------------------------------------
-- Consulta 9: Para cada estadio, el partido con mayor marcador combinado.
--
--   Igual que en la Consulta 5, hay que contemplar empates: si dos partidos
--   jugados en el mismo estadio comparten el marcador combinado mas alto, los
--   dos deben aparecer.
--
--   Aqui se resuelve con una subconsulta NO CORRELACIONADA en la clausula FROM:
--   se calcula de una sola pasada el maximo por estadio (GROUP BY) y luego se
--   une contra el detalle. Frente a la correlacionada de la Consulta 5, esta
--   variante evalua la agregacion UNA vez en lugar de una por fila, y se incluye
--   deliberadamente para contrastar ambas tecnicas.
--
--   Reutiliza la vista V_RESUMEN_PARTIDO.
-- -----------------------------------------------------------------------------

SELECT
    v.estadio,
    v.id_partido,
    v.fase,
    v.goles_totales
FROM v_resumen_partido v
JOIN (
        SELECT id_estadio, MAX(goles_totales) AS max_goles
        FROM   v_resumen_partido
        GROUP BY id_estadio
     ) m
     ON  m.id_estadio = v.id_estadio
     AND m.max_goles  = v.goles_totales
ORDER BY v.estadio, v.id_partido;


-- -----------------------------------------------------------------------------
-- Consulta 12: Goles en fase de grupos frente a fase eliminatoria, por seleccion.
--
--   Uso de CASE combinado con GROUP BY: el CASE actua como un filtro dentro de
--   la agregacion, permitiendo calcular dos totales distintos sobre el mismo
--   conjunto de filas y en una sola pasada. Resolverlo con dos consultas unidas
--   por UNION o con dos subconsultas escalares recorreria la tabla dos veces.
--
--   "Fase eliminatoria" se define como toda fase distinta de 'Fase de Grupos'.
-- -----------------------------------------------------------------------------

SELECT
    s.pais,
    SUM(CASE WHEN p.fase =  'Fase de Grupos' THEN pp.goles_marcados ELSE 0 END) AS goles_fase_grupos,
    SUM(CASE WHEN p.fase <> 'Fase de Grupos' THEN pp.goles_marcados ELSE 0 END) AS goles_eliminatoria
FROM participacion_partido pp
JOIN partido   p ON p.id_partido   = pp.id_partido
JOIN seleccion s ON s.id_seleccion = pp.id_seleccion
GROUP BY s.pais
ORDER BY s.pais;


-- -----------------------------------------------------------------------------
-- Consulta 13: Estadios que albergaron partidos en mas de una fase distinta.
--
--   GROUP BY + HAVING COUNT(DISTINCT fase) > 1.
--
--   El filtro va en HAVING y no en WHERE porque se aplica sobre el resultado de
--   una funcion de agregacion: WHERE se evalua fila a fila, antes de agrupar, y
--   en ese momento el conteo de fases distintas todavia no existe.
--
--   LISTAGG(DISTINCT ...) concatena las fases en una sola celda para que el
--   resultado sea legible sin tener que lanzar una segunda consulta. La variante
--   con DISTINCT esta disponible desde Oracle 19c.
-- -----------------------------------------------------------------------------

SELECT
    es.nombre                                                        AS estadio,
    COUNT(DISTINCT p.fase)                                           AS n_fases_distintas,
    LISTAGG(DISTINCT p.fase, ', ') WITHIN GROUP (ORDER BY p.fase)    AS fases
FROM estadio es
JOIN partido p ON p.id_estadio = es.id_estadio
GROUP BY es.id_estadio, es.nombre
HAVING COUNT(DISTINCT p.fase) > 1
ORDER BY n_fases_distintas DESC, estadio;
