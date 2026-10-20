-- ============================================================
-- Roles y privilegios - Entrega 2
-- ============================================================

SET SQLBLANKLINES ON

-- Borrado previo, para poder ejecutar el script varias veces.
-- La primera vez dan error porque los roles aun no existen.
DROP ROLE rol_admin_torneo;
DROP ROLE rol_analista_deportivo;
DROP ROLE rol_auditor;

-- ------------------------------------------------------------
-- 1. Roles
-- ------------------------------------------------------------

CREATE ROLE rol_admin_torneo;
CREATE ROLE rol_analista_deportivo;
CREATE ROLE rol_auditor;

-- ------------------------------------------------------------
-- 2. ADMINISTRADOR DEL TORNEO: lee y modifica todo el modelo
-- ------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON edicion_mundial TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON sede TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON ciudad TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON estadio TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON fase TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON grupo TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON seleccion TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON partido TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON participacion_partido TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON jugador TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON convocatoria_jugador TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON cuerpo_tecnico TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON arbitro TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON asignacion_arbitral TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON estadistica_jugador_partido TO rol_admin_torneo;
GRANT SELECT, INSERT, UPDATE, DELETE ON incidencia TO rol_admin_torneo;

-- ------------------------------------------------------------
-- 3. ANALISTA DEPORTIVO: consulta los datos deportivos y solo
-- puede cargar y corregir estadisticas. No ve el cuerpo tecnico
-- porque no lo necesita para el analisis de rendimiento.
-- ------------------------------------------------------------

GRANT SELECT ON edicion_mundial TO rol_analista_deportivo;
GRANT SELECT ON sede TO rol_analista_deportivo;
GRANT SELECT ON ciudad TO rol_analista_deportivo;
GRANT SELECT ON estadio TO rol_analista_deportivo;
GRANT SELECT ON fase TO rol_analista_deportivo;
GRANT SELECT ON grupo TO rol_analista_deportivo;
GRANT SELECT ON seleccion TO rol_analista_deportivo;
GRANT SELECT ON partido TO rol_analista_deportivo;
GRANT SELECT ON participacion_partido TO rol_analista_deportivo;
GRANT SELECT ON jugador TO rol_analista_deportivo;
GRANT SELECT ON convocatoria_jugador TO rol_analista_deportivo;
GRANT SELECT ON arbitro TO rol_analista_deportivo;
GRANT SELECT ON asignacion_arbitral TO rol_analista_deportivo;
GRANT SELECT ON incidencia TO rol_analista_deportivo;
GRANT SELECT, INSERT, UPDATE ON estadistica_jugador_partido TO rol_analista_deportivo;

-- ------------------------------------------------------------
-- 4. AUDITOR / CONSULTA: solo lectura de todo el modelo
-- ------------------------------------------------------------

GRANT SELECT ON edicion_mundial TO rol_auditor;
GRANT SELECT ON sede TO rol_auditor;
GRANT SELECT ON ciudad TO rol_auditor;
GRANT SELECT ON estadio TO rol_auditor;
GRANT SELECT ON fase TO rol_auditor;
GRANT SELECT ON grupo TO rol_auditor;
GRANT SELECT ON seleccion TO rol_auditor;
GRANT SELECT ON partido TO rol_auditor;
GRANT SELECT ON participacion_partido TO rol_auditor;
GRANT SELECT ON jugador TO rol_auditor;
GRANT SELECT ON convocatoria_jugador TO rol_auditor;
GRANT SELECT ON cuerpo_tecnico TO rol_auditor;
GRANT SELECT ON arbitro TO rol_auditor;
GRANT SELECT ON asignacion_arbitral TO rol_auditor;
GRANT SELECT ON estadistica_jugador_partido TO rol_auditor;
GRANT SELECT ON incidencia TO rol_auditor;

-- ------------------------------------------------------------
-- 5. Asignacion de roles a cuentas de integrantes para las pruebas.
-- IS101009 (Nicolas) prueba el administrador, IS101013 (Santiago) el
-- analista e IS101016 (Daniel) el auditor. Se ejecutan solo durante
-- las pruebas y se revocan al terminar.
-- ------------------------------------------------------------

-- GRANT rol_admin_torneo TO IS101009;
-- GRANT rol_analista_deportivo TO IS101013;
-- GRANT rol_auditor TO IS101016;

-- REVOKE rol_admin_torneo FROM IS101009;
-- REVOKE rol_analista_deportivo FROM IS101013;
-- REVOKE rol_auditor FROM IS101016;

EXIT;