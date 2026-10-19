-- ============================================================
-- Roles y privilegios - Entrega 2
-- Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana


SET SQLBLANKLINES ON

DROP USER usuario_admin_torneo CASCADE;
DROP USER usuario_analista CASCADE;
DROP USER usuario_auditor CASCADE;
DROP ROLE rol_admin_torneo;
DROP ROLE rol_analista_deportivo;
DROP ROLE rol_auditor;


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
-- 3. ANALISTA DEPORTIVO: consulta lo deportivo y solo carga
-- estadisticas y no ve el cuerpo tecnico.
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
-- 5. Usuarios de prueba, uno por rol.
-- ------------------------------------------------------------

CREATE USER usuario_admin_torneo IDENTIFIED BY "ClavePrueba_1";
CREATE USER usuario_analista IDENTIFIED BY "ClavePrueba_2";
CREATE USER usuario_auditor IDENTIFIED BY "ClavePrueba_3";

GRANT CREATE SESSION TO usuario_admin_torneo;
GRANT CREATE SESSION TO usuario_analista;
GRANT CREATE SESSION TO usuario_auditor;

GRANT rol_admin_torneo TO usuario_admin_torneo;
GRANT rol_analista_deportivo TO usuario_analista;
GRANT rol_auditor TO usuario_auditor;






EXIT;