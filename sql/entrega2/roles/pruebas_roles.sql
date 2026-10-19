-- Auditor (usuario_auditor)
SELECT * FROM IS101007.partido;
DELETE FROM IS101007.partido WHERE 1 = 0;

-- Analista (usuario_analista)
SELECT * FROM IS101007.estadistica_jugador_partido;
UPDATE IS101007.estadistica_jugador_partido SET goles = goles WHERE 1 = 0;
SELECT * FROM IS101007.cuerpo_tecnico;
UPDATE IS101007.partido SET fecha_hora = fecha_hora WHERE 1 = 0;

-- Administrador (usuario_admin_torneo)
SELECT * FROM IS101007.incidencia;
DELETE FROM IS101007.incidencia WHERE 1 = 0;

-- REVOKE y GRANT (dueño de las tablas: IS101007)
REVOKE INSERT, UPDATE ON estadistica_jugador_partido FROM rol_analista_deportivo;
-- Con usuario_analista: debe fallar
-- UPDATE IS101007.estadistica_jugador_partido SET goles = goles WHERE 1 = 0;
GRANT INSERT, UPDATE ON estadistica_jugador_partido TO rol_analista_deportivo;
-- Con usuario_analista: debe funcionar
-- UPDATE IS101007.estadistica_jugador_partido SET goles = goles WHERE 1 = 0;