-- =============================================================================
--  Entrega 1 - Consultas SQL sobre el modelo inicial
--  Bloque: SUBCONSULTAS  (Consultas 7, 8, 10 y 11 del enunciado)
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Consulta 7: Selecciones invictas.
--
--   Selecciones que no han perdido ningun partido hasta el momento.
--   El enunciado pide expresamente resolverla con NOT EXISTS o equivalente.
--
--   El patron es el de "no existe contraejemplo": en lugar de intentar demostrar
--   que TODOS los partidos fueron no-derrota, se busca UN solo partido perdido;
--   si no lo hay, la seleccion es invicta.
--
--   El primer EXISTS es imprescindible y facil de olvidar: sin el, una seleccion
--   inscrita que aun no ha jugado ningun partido apareceria como invicta, porque
--   trivialmente no ha perdido ninguno. Es el clasico problema del cuantificador
--   universal sobre el conjunto vacio.
--
--   La subconsulta interna localiza, para cada participacion de la seleccion, la
--   del rival en ese mismo partido, y compara los goles.
--
--   Equivalente usando la vista:  SELECT pais FROM v_rendimiento_seleccion
--                                WHERE perdidos = 0;
--   Se prefiere la version con NOT EXISTS porque es la tecnica que el enunciado
--   evalua en esta consulta.
-- -----------------------------------------------------------------------------

SELECT
    s.pais,
    s.confederacion
FROM seleccion s
WHERE EXISTS (                                  -- ha jugado al menos un partido
        SELECT 1
        FROM   participacion_partido pp
        WHERE  pp.id_seleccion = s.id_seleccion
      )
  AND NOT EXISTS (                              -- y no perdio ninguno
        SELECT 1
        FROM   participacion_partido pp
        JOIN   participacion_partido riv
               ON  riv.id_partido    = pp.id_partido
               AND riv.id_seleccion <> pp.id_seleccion
        WHERE  pp.id_seleccion    = s.id_seleccion
          AND  pp.goles_marcados  < riv.goles_marcados
      )
ORDER BY s.pais;


-- -----------------------------------------------------------------------------
-- Consulta 8: Estadios por encima del promedio de ocupacion.
--
--   Subconsulta CORRELACIONADA: el promedio se recalcula para cada fila del
--   exterior, restringido a los estadios de SU MISMA edicion (v2.id_edicion =
--   v.id_edicion). Comparar un estadio de 2026 contra el promedio de todas las
--   ediciones mezclaria torneos con formatos y aforos distintos.
--
--   Reutiliza la vista V_OCUPACION_ESTADIO. Esto no es un detalle menor: el
--   porcentaje individual y el promedio contra el que se compara salen de la
--   MISMA definicion de ocupacion. Si cada uno se calculara por su lado con
--   criterios ligeramente distintos, la comparacion seria invalida y el error
--   pasaria completamente desapercibido.
--
--   El filtro partidos_jugados > 0 excluye a los estadios sin partidos, cuya
--   ocupacion es NULL: sin el, no romperian la consulta (NULL > x es UNKNOWN y
--   se descarta), pero dejarlo explicito documenta la intencion.
-- -----------------------------------------------------------------------------

SELECT
    v.estadio,
    v.ciudad,
    v.anio,
    v.capacidad,
    v.partidos_jugados,
    v.ocupacion_pct
FROM v_ocupacion_estadio v
WHERE v.partidos_jugados > 0
  AND v.ocupacion_pct > (
        SELECT AVG(v2.ocupacion_pct)
        FROM   v_ocupacion_estadio v2
        WHERE  v2.id_edicion       = v.id_edicion   -- correlacion
          AND  v2.partidos_jugados > 0
      )
ORDER BY v.ocupacion_pct DESC, v.estadio;


-- -----------------------------------------------------------------------------
-- Consulta 10: Selecciones con condicion exclusiva.
--
--   Selecciones que jugaron TODOS sus partidos como local, o NINGUNO como local.
--   El enunciado lo plantea como ejercicio analogo al operador de DIVISION del
--   algebra relacional.
--
--   La division relacional no tiene un operador propio en SQL. El equivalente
--   canonico es la doble negacion: "todos los partidos fueron como local" se
--   reescribe como "no existe ningun partido suyo que NO fuera como local".
--   Eso es exactamente lo que hace cada NOT EXISTS de abajo.
--
--   De nuevo, el EXISTS inicial descarta a las selecciones que no han jugado,
--   que de otro modo satisfarian las dos condiciones a la vez de forma trivial.
--
--   Las tres subconsultas escalares del SELECT son correlacionadas: se evaluan
--   una vez por cada seleccion que supera el filtro.
-- -----------------------------------------------------------------------------

SELECT
    s.pais,
    (SELECT COUNT(*)
     FROM   participacion_partido pp
     WHERE  pp.id_seleccion = s.id_seleccion
       AND  pp.condicion    = 'LOCAL')      AS partidos_local,
    (SELECT COUNT(*)
     FROM   participacion_partido pp
     WHERE  pp.id_seleccion = s.id_seleccion
       AND  pp.condicion    = 'VISITANTE')  AS partidos_visitante,
    (SELECT COUNT(*)
     FROM   participacion_partido pp
     WHERE  pp.id_seleccion = s.id_seleccion) AS total_partidos
FROM seleccion s
WHERE EXISTS (
        SELECT 1
        FROM   participacion_partido pp
        WHERE  pp.id_seleccion = s.id_seleccion
      )
  AND (
        -- Jugo TODOS sus partidos como local:
        -- no existe ninguno suyo que no lo fuera.
        NOT EXISTS (
            SELECT 1
            FROM   participacion_partido pp
            WHERE  pp.id_seleccion = s.id_seleccion
              AND  pp.condicion   <> 'LOCAL'
        )
        OR
        -- No jugo NINGUNO como local.
        NOT EXISTS (
            SELECT 1
            FROM   participacion_partido pp
            WHERE  pp.id_seleccion = s.id_seleccion
              AND  pp.condicion    = 'LOCAL'
        )
      )
ORDER BY s.pais;


-- -----------------------------------------------------------------------------
-- Consulta 11: Selecciones con diferencia de gol sobre el promedio general.
--
--   Muestra unicamente las selecciones cuya diferencia de gol esta ESTRICTAMENTE
--   por encima del promedio de diferencia de gol de todas las selecciones.
--
--   Subconsulta NO CORRELACIONADA: el promedio es un unico escalar, igual para
--   todas las filas, asi que el motor lo evalua UNA sola vez. Es el contraste
--   directo con la correlacionada de la Consulta 8.
--
--   Detalle facil de errar: el promedio debe calcularse sobre la diferencia de
--   gol YA AGREGADA POR PAIS, no sobre las filas por edicion. Promediar antes de
--   agrupar daria un valor distinto para los paises que participaron en varias
--   ediciones. Por eso la subconsulta repite el mismo GROUP BY pais del exterior.
--
--   RANK() se calcula despues del filtro, de modo que numera solo a las
--   selecciones que quedan por encima del promedio.
-- -----------------------------------------------------------------------------

SELECT
    pais,
    diferencia_gol,
    RANK() OVER (ORDER BY diferencia_gol DESC) AS ranking
FROM (
        SELECT
            pais,
            SUM(goles_favor) - SUM(goles_contra) AS diferencia_gol
        FROM v_rendimiento_seleccion
        GROUP BY pais
     )
WHERE diferencia_gol > (
        SELECT AVG(dg)
        FROM (
                SELECT SUM(goles_favor) - SUM(goles_contra) AS dg
                FROM   v_rendimiento_seleccion
                GROUP BY pais
             )
      )
ORDER BY diferencia_gol DESC, pais;
