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