-- ============================================================
-- Roles y Privilegios - Mundial FIFA
-- Nota: CREATE ROLE
-- ============================================================

-- 1. Crear el Rol de Solo Lectura
CREATE ROLE rol_lectura_mundial;

-- Asignar permisos de SELECT sobre todas las tablas del esquema
GRANT SELECT ON edicion_mundial TO rol_lectura_mundial;
GRANT SELECT ON estadio TO rol_lectura_mundial;
GRANT SELECT ON seleccion TO rol_lectura_mundial;
GRANT SELECT ON partido TO rol_lectura_mundial;
GRANT SELECT ON participacion_partido TO rol_lectura_mundial;

-- Asignar permisos sobre las Vistas creadas
GRANT SELECT ON vista_tabla_posiciones TO rol_lectura_mundial;
GRANT SELECT ON vista_goleadores TO rol_lectura_mundial;
GRANT SELECT ON vista_ocupacion_estadios TO rol_lectura_mundial;
GRANT SELECT ON vista_resumen_ediciones TO rol_lectura_mundial;


-- 2. Crear el Rol de Escritura 
CREATE ROLE rol_escritura_mundial;

-- Asignar permisos 
GRANT SELECT, INSERT, UPDATE, DELETE ON edicion_mundial TO rol_escritura_mundial;
GRANT SELECT, INSERT, UPDATE, DELETE ON estadio TO rol_escritura_mundial;
GRANT SELECT, INSERT, UPDATE, DELETE ON seleccion TO rol_escritura_mundial;
GRANT SELECT, INSERT, UPDATE, DELETE ON partido TO rol_escritura_mundial;
GRANT SELECT, INSERT, UPDATE, DELETE ON participacion_partido TO rol_escritura_mundial;