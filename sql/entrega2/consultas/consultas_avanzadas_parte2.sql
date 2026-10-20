-- ============================================================
-- Consultas avanzadas - Entrega 2 (parte 2)
-- ============================================================

SET SQLBLANKLINES ON


-- 6. Hasta que fase llego cada seleccion que paso la fase de grupos
SELECT m.anio, s.pais, g.nombre AS grupo, f.nombre AS fase_alcanzada
FROM seleccion s
JOIN edicion_mundial m ON m.id_edicion = s.id_edicion
LEFT JOIN grupo g ON g.id_grupo = s.id_grupo
JOIN fase f ON f.id_edicion = s.id_edicion
WHERE f.orden_fase = (SELECT MAX(f2.orden_fase)
                      FROM participacion_partido pp
                      JOIN partido p ON p.id_partido = pp.id_partido
                      JOIN fase f2 ON f2.id_fase = p.id_fase
                      WHERE pp.id_seleccion = s.id_seleccion)
  AND EXISTS (SELECT 1
              FROM participacion_partido pp
              JOIN partido p ON p.id_partido = pp.id_partido
              JOIN fase f3 ON f3.id_fase = p.id_fase
              WHERE pp.id_seleccion = s.id_seleccion
                AND f3.tipo = 'ELIMINATORIA')
ORDER BY m.anio, f.orden_fase DESC, s.pais;


-- 7. Rendimiento de cada seleccion en fase de grupos frente a eliminatorias
WITH resultados AS (
    SELECT pp.id_seleccion, f.tipo,
           pp.goles_marcados AS gf,
           rival.goles_marcados AS gc
    FROM participacion_partido pp
    JOIN participacion_partido rival ON rival.id_partido = pp.id_partido
                                    AND rival.id_seleccion <> pp.id_seleccion
    JOIN partido p ON p.id_partido = pp.id_partido
    JOIN fase f ON f.id_fase = p.id_fase
)
SELECT m.anio, s.pais,
       SUM(CASE WHEN r.tipo = 'GRUPOS' THEN 1 ELSE 0 END) AS partidos_grupos,
       SUM(CASE WHEN r.tipo = 'GRUPOS' THEN r.gf ELSE 0 END) AS gf_grupos,
       SUM(CASE WHEN r.tipo = 'GRUPOS' THEN r.gc ELSE 0 END) AS gc_grupos,
       SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN 1 ELSE 0 END) AS partidos_elim,
       SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN r.gf ELSE 0 END) AS gf_elim,
       SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN r.gc ELSE 0 END) AS gc_elim,
       ROUND(SUM(CASE WHEN r.tipo = 'GRUPOS' THEN r.gf ELSE 0 END)
             / NULLIF(SUM(CASE WHEN r.tipo = 'GRUPOS' THEN 1 ELSE 0 END), 0), 2) AS prom_gf_grupos,
       ROUND(SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN r.gf ELSE 0 END)
             / NULLIF(SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN 1 ELSE 0 END), 0), 2) AS prom_gf_elim
FROM resultados r
JOIN seleccion s ON s.id_seleccion = r.id_seleccion
JOIN edicion_mundial m ON m.id_edicion = s.id_edicion
GROUP BY m.anio, s.pais
HAVING SUM(CASE WHEN r.tipo = 'ELIMINATORIA' THEN 1 ELSE 0 END) > 0
ORDER BY m.anio, s.pais;


-- 8. Fases y estadios con mas incidencias que el promedio
SELECT m.anio, f.nombre AS fase, es.nombre AS estadio,
       COUNT(*) AS incidencias,
       COUNT(DISTINCT i.id_partido) AS partidos_afectados
FROM incidencia i
JOIN partido p ON p.id_partido = i.id_partido
JOIN fase f ON f.id_fase = p.id_fase
JOIN estadio es ON es.id_estadio = p.id_estadio
JOIN edicion_mundial m ON m.id_edicion = p.id_edicion
GROUP BY m.anio, f.orden_fase, f.nombre, es.nombre
HAVING COUNT(*) > (SELECT AVG(COUNT(*))
                   FROM incidencia i2
                   JOIN partido p2 ON p2.id_partido = i2.id_partido
                   GROUP BY p2.id_fase, p2.id_estadio)
ORDER BY incidencias DESC, m.anio, f.orden_fase;


-- 9. Asistencia y ocupacion por edicion, pais sede y ciudad, con subtotales
SELECT CASE WHEN GROUPING(m.anio) = 1 THEN 'TOTAL' ELSE TO_CHAR(m.anio) END AS edicion,
       CASE WHEN GROUPING(sd.pais) = 1 THEN '(todos)' ELSE sd.pais END AS pais_sede,
       CASE WHEN GROUPING(ci.nombre) = 1 THEN '(todas)' ELSE ci.nombre END AS ciudad,
       COUNT(p.id_partido) AS partidos,
       SUM(p.asistencia_registrada) AS asistencia_total,
       ROUND(SUM(p.asistencia_registrada) * 100 / SUM(es.capacidad), 2) AS ocupacion_pct
FROM partido p
JOIN edicion_mundial m ON m.id_edicion = p.id_edicion
JOIN estadio es ON es.id_estadio = p.id_estadio
JOIN ciudad ci ON ci.id_ciudad = es.id_ciudad
JOIN sede sd ON sd.id_sede = ci.id_sede
WHERE p.asistencia_registrada IS NOT NULL
GROUP BY ROLLUP (m.anio, sd.pais, ci.nombre)
ORDER BY m.anio, sd.pais, ci.nombre;

-- 10. Historial de cada arbitro y partidos que se le cruzan de horario
SELECT ar.nombre AS arbitro, ar.nacionalidad,
       COUNT(*) AS partidos,
       SUM(CASE WHEN a.rol = 'Principal' THEN 1 ELSE 0 END) AS como_principal,
       SUM(CASE WHEN a.rol IN ('VAR', 'AVAR') THEN 1 ELSE 0 END) AS como_var,
       COUNT(DISTINCT p.id_edicion) AS ediciones,
       (SELECT COUNT(*)
        FROM asignacion_arbitral a1
        JOIN partido p1 ON p1.id_partido = a1.id_partido
        JOIN asignacion_arbitral a2 ON a2.id_arbitro = a1.id_arbitro
                                   AND a2.id_partido > a1.id_partido
        JOIN partido p2 ON p2.id_partido = a2.id_partido
        WHERE a1.id_arbitro = ar.id_arbitro
          AND p1.fecha_hora = p2.fecha_hora) AS cruces_horario
FROM arbitro ar
JOIN asignacion_arbitral a ON a.id_arbitro = ar.id_arbitro
JOIN partido p ON p.id_partido = a.id_partido
GROUP BY ar.id_arbitro, ar.nombre, ar.nacionalidad
ORDER BY partidos DESC, ar.nombre;


EXIT;


