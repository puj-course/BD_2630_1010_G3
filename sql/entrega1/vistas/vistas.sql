-- ============================================================
-- Vistas - Mundial FIFA (Entrega 1)
-- ============================================================

-- 1. Tabla de Posiciones por Seleccion
CREATE OR REPLACE VIEW vista_tabla_posiciones AS
SELECT 
    s.id_edicion,
    s.pais,
    s.grupo,
    COUNT(pp.id_participacion) AS partidos_jugados,
    SUM(pp.goles_marcados) AS goles_a_favor
FROM seleccion s
LEFT JOIN participacion_partido pp ON s.id_seleccion = pp.id_seleccion
GROUP BY s.id_edicion, s.pais, s.grupo;

-- 2. Goleadores (Total de goles por seleccion y edicion)
CREATE OR REPLACE VIEW vista_goleadores AS
SELECT 
    em.anio,
    em.pais_sede,
    s.pais,
    SUM(pp.goles_marcados) AS total_goles
FROM participacion_partido pp
JOIN seleccion s ON pp.id_seleccion = s.id_seleccion
JOIN edicion_mundial em ON s.id_edicion = em.id_edicion
GROUP BY em.anio, em.pais_sede, s.pais;

-- 3. Ocupacion y Promedio de Asistencia en Estadios
CREATE OR REPLACE VIEW vista_ocupacion_estadios AS
SELECT 
    e.id_estadio,
    e.nombre AS estadio,
    e.ciudad,
    e.capacidad,
    COUNT(p.id_partido) AS partidos_Jugados,
    AVG(p.asistencia_registrada) AS promedio_asistencia,
    ROUND((AVG(p.asistencia_registrada) / e.capacidad) * 100, 2) AS porcentaje_promedio_ocupacion
FROM estadio e
LEFT JOIN partido p ON e.id_estadio = p.id_estadio
GROUP BY e.id_estadio, e.nombre, e.ciudad, e.capacidad;

-- 4. Resumen General de Ediciones del Mundial
CREATE OR REPLACE VIEW vista_resumen_ediciones AS
SELECT 
    em.id_edicion,
    em.anio,
    em.pais_sede,
    COUNT(DISTINCT e.id_estadio) AS total_estadios,
    COUNT(DISTINCT s.id_seleccion) AS total_selecciones,
    COUNT(DISTINCT p.id_partido) AS total_partidos
FROM edicion_mundial em
LEFT JOIN estadio e ON em.id_edicion = e.id_edicion
LEFT JOIN seleccion s ON em.id_edicion = s.id_edicion
LEFT JOIN partido p ON em.id_edicion = p.id_edicion
GROUP BY em.id_edicion, em.anio, em.pais_sede;