-- ============================================================
-- Consultas avanzadas - Entrega 2 (semana 3)
-- ============================================================

SET SQLBLANKLINES ON


-- 1. Top 5 goleadores de cada edicion
WITH goles_jugador AS (
    SELECT p.id_edicion, j.id_jugador, j.nombre, s.pais, SUM(e.goles) AS goles
    FROM estadistica_jugador_partido e
    JOIN partido p ON p.id_partido = e.id_partido
    JOIN jugador j ON j.id_jugador = e.id_jugador
    JOIN convocatoria_jugador c ON c.id_jugador = j.id_jugador
    JOIN participacion_partido pp ON pp.id_partido = p.id_partido
                                 AND pp.id_seleccion = c.id_seleccion
    JOIN seleccion s ON s.id_seleccion = c.id_seleccion
    GROUP BY p.id_edicion, j.id_jugador, j.nombre, s.pais
),
ranking AS (
    SELECT g.*, RANK() OVER (PARTITION BY g.id_edicion ORDER BY g.goles DESC) AS posicion
    FROM goles_jugador g
    WHERE g.goles > 0
)
SELECT m.anio, r.posicion, r.nombre AS jugador, r.pais, r.goles
FROM ranking r
JOIN edicion_mundial m ON m.id_edicion = r.id_edicion
WHERE r.posicion <= 5
ORDER BY m.anio, r.posicion, r.nombre;


-- 2. Tarjetas por seleccion en cada edicion
SELECT m.anio, s.pais,
       SUM(e.tarjetas_amarillas) AS amarillas,
       SUM(e.tarjetas_rojas) AS rojas
FROM estadistica_jugador_partido e
JOIN partido p ON p.id_partido = e.id_partido
JOIN edicion_mundial m ON m.id_edicion = p.id_edicion
JOIN convocatoria_jugador c ON c.id_jugador = e.id_jugador
JOIN participacion_partido pp ON pp.id_partido = p.id_partido
                             AND pp.id_seleccion = c.id_seleccion
JOIN seleccion s ON s.id_seleccion = c.id_seleccion
GROUP BY m.anio, s.pais
HAVING SUM(e.tarjetas_amarillas) + SUM(e.tarjetas_rojas) > 0
ORDER BY m.anio, rojas DESC, amarillas DESC;


-- 3. Ficha de cada partido: equipos, marcador, sede, fase y equipo arbitral
SELECT m.anio,
       f.nombre AS fase,
       p.fecha_hora,
       sl.pais AS local,
       pl.goles_marcados || ' - ' || pv.goles_marcados AS marcador,
       sv.pais AS visitante,
       es.nombre AS estadio,
       ci.nombre AS ciudad,
       sd.pais AS pais_sede,
       (SELECT LISTAGG(a.rol || ': ' || ar.nombre, ', ') WITHIN GROUP (ORDER BY a.rol)
        FROM asignacion_arbitral a
        JOIN arbitro ar ON ar.id_arbitro = a.id_arbitro
        WHERE a.id_partido = p.id_partido) AS equipo_arbitral
FROM partido p
JOIN edicion_mundial m ON m.id_edicion = p.id_edicion
JOIN fase f ON f.id_fase = p.id_fase
JOIN estadio es ON es.id_estadio = p.id_estadio
JOIN ciudad ci ON ci.id_ciudad = es.id_ciudad
JOIN sede sd ON sd.id_sede = ci.id_sede
JOIN participacion_partido pl ON pl.id_partido = p.id_partido AND pl.condicion = 'LOCAL'
JOIN seleccion sl ON sl.id_seleccion = pl.id_seleccion
JOIN participacion_partido pv ON pv.id_partido = p.id_partido AND pv.condicion = 'VISITANTE'
JOIN seleccion sv ON sv.id_seleccion = pv.id_seleccion
ORDER BY m.anio, p.fecha_hora;


-- 4. Partidos donde el marcador oficial no coincide con la suma de goles de los jugadores
WITH goles_jugadores AS (
    SELECT e.id_partido, c.id_seleccion, SUM(e.goles) AS goles
    FROM estadistica_jugador_partido e
    JOIN convocatoria_jugador c ON c.id_jugador = e.id_jugador
    JOIN participacion_partido pp ON pp.id_partido = e.id_partido
                                 AND pp.id_seleccion = c.id_seleccion
    GROUP BY e.id_partido, c.id_seleccion
)
SELECT pp.id_partido, s.pais,
       pp.goles_marcados AS marcador_oficial,
       NVL(g.goles, 0) AS suma_jugadores
FROM participacion_partido pp
JOIN seleccion s ON s.id_seleccion = pp.id_seleccion
LEFT JOIN goles_jugadores g ON g.id_partido = pp.id_partido
                           AND g.id_seleccion = pp.id_seleccion
WHERE pp.goles_marcados <> NVL(g.goles, 0)
ORDER BY pp.id_partido, s.pais;


-- 5. Tabla de posiciones por grupo
WITH resultados AS (
    SELECT pp.id_seleccion,
           pp.goles_marcados AS gf,
           rival.goles_marcados AS gc
    FROM participacion_partido pp
    JOIN participacion_partido rival ON rival.id_partido = pp.id_partido
                                    AND rival.id_seleccion <> pp.id_seleccion
    JOIN partido p ON p.id_partido = pp.id_partido
    JOIN fase f ON f.id_fase = p.id_fase
    WHERE f.tipo = 'GRUPOS'
),
tabla AS (
    SELECT s.id_edicion, g.nombre AS grupo, s.pais,
           COUNT(r.id_seleccion) AS jugados,
           SUM(CASE WHEN r.gf > r.gc THEN 1 ELSE 0 END) AS ganados,
           SUM(CASE WHEN r.gf = r.gc THEN 1 ELSE 0 END) AS empatados,
           SUM(CASE WHEN r.gf < r.gc THEN 1 ELSE 0 END) AS perdidos,
           NVL(SUM(r.gf), 0) AS goles_favor,
           NVL(SUM(r.gc), 0) AS goles_contra,
           NVL(SUM(r.gf - r.gc), 0) AS diferencia,
           SUM(CASE WHEN r.gf > r.gc THEN 3 WHEN r.gf = r.gc THEN 1 ELSE 0 END) AS puntos
    FROM seleccion s
    JOIN grupo g ON g.id_grupo = s.id_grupo
    LEFT JOIN resultados r ON r.id_seleccion = s.id_seleccion
    GROUP BY s.id_edicion, g.nombre, s.pais
)
SELECT m.anio, t.grupo,
       RANK() OVER (PARTITION BY t.id_edicion, t.grupo
                    ORDER BY t.puntos DESC, t.diferencia DESC, t.goles_favor DESC) AS posicion,
       t.pais, t.jugados, t.ganados, t.empatados, t.perdidos,
       t.goles_favor, t.goles_contra, t.diferencia, t.puntos
FROM tabla t
JOIN edicion_mundial m ON m.id_edicion = t.id_edicion
ORDER BY m.anio, t.grupo, posicion;


EXIT;
