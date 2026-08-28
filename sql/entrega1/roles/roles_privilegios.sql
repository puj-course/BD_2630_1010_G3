-- =============================================================================
--  Entrega 1 - Privilegios basicos: roles, GRANT y REVOKE
--  Grupo G3 - Bases de Datos - Pontificia Universidad Javeriana
--  Motor: Oracle Database 19c
-- =============================================================================
--
--  POR QUE ROLES Y NO USUARIOS
--  ---------------------------
--  El enunciado (Seccion 8.1.6) pide "al menos dos usuarios O ROLES a nivel del
--  motor de base de datos". Se implementa con ROLES, y no por comodidad: las
--  cuentas de estudiante del servidor del curso NO tienen el privilegio
--  CREATE USER. Se puede comprobar con:
--
--      SELECT privilege FROM session_privs ORDER BY 1;
--
--  El resultado incluye CREATE TABLE, CREATE VIEW, CREATE ROLE, CREATE TRIGGER,
--  CREATE PROCEDURE y CREATE SESSION, pero NO CREATE USER. Crear usuarios es
--  por tanto imposible desde nuestra cuenta, y el enunciado contempla
--  explicitamente la alternativa.
--
--  Esto no es una limitacion del diseno. En Oracle, la practica recomendada es
--  precisamente conceder privilegios a ROLES y luego asignar roles a usuarios,
--  en lugar de conceder privilegios directamente a cada cuenta: el rol es la
--  unidad de administracion de permisos.
--
--  LOS DOS PERFILES
--  ----------------
--    ROL_CONSULTA_MUNDIAL   Perfil de solo lectura. Analista o consulta publica.
--                           Solo SELECT. No puede modificar absolutamente nada.
--
--    ROL_OPERATIVO_MUNDIAL  Perfil operativo. Registra el desarrollo del torneo.
--                           SELECT sobre todo el modelo, e INSERT/UPDATE sobre
--                           las tablas TRANSACCIONALES (PARTIDO y
--                           PARTICIPACION_PARTIDO). No recibe DELETE en ninguna
--                           tabla ni escritura sobre las tablas ESTRUCTURALES
--                           (EDICION_MUNDIAL, ESTADIO, SELECCION), que son
--                           catalogo maestro y solo cambian por decision
--                           administrativa.
--
--  La separacion entre datos estructurales y transaccionales la plantea el
--  propio enunciado en su Seccion 5.7.
--
--  COMO EJECUTARLO
--  ---------------
--      sql -name "BD Javeriana" @sql/entrega1/roles/roles_privilegios.sql
--
--  La evidencia de las pruebas de acceso esta en
--  tests/entrega1/pruebas_privilegios.md.
-- =============================================================================

SET SERVEROUTPUT ON;
SET DEFINE OFF;


-- #############################################################################
--  PARTE 0 - COMPROBACION DEL PRIVILEGIO DISPONIBLE
--  Justifica documentalmente por que se usan roles y no usuarios.
-- #############################################################################

SELECT privilege
FROM   session_privs
WHERE  privilege IN ('CREATE USER', 'CREATE ROLE', 'CREATE TABLE',
                     'CREATE VIEW', 'CREATE SESSION')
ORDER BY privilege;


-- #############################################################################
--  PARTE 1 - CREACION DE LOS ROLES
-- #############################################################################

-- Bloque tolerante a la re-ejecucion: si el rol ya existe (ORA-01921) se
-- elimina y se vuelve a crear, de modo que el script sea idempotente.
BEGIN
    FOR r IN (SELECT column_value AS nombre
              FROM TABLE(sys.odcivarchar2list('ROL_CONSULTA_MUNDIAL',
                                              'ROL_OPERATIVO_MUNDIAL'))) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP ROLE ' || r.nombre;
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -1919 THEN  -- -1919 = el rol no existe: correcto
                    RAISE;
                END IF;
        END;
        EXECUTE IMMEDIATE 'CREATE ROLE ' || r.nombre;
        dbms_output.put_line('Rol creado: ' || r.nombre);
    END LOOP;
END;
/


-- #############################################################################
--  PARTE 2 - PERFIL DE SOLO CONSULTA
-- #############################################################################
--  Unicamente SELECT. Se conceden tambien las vistas: un perfil de consulta
--  deberia trabajar preferentemente contra ellas, porque exponen el modelo ya
--  interpretado (marcadores, tabla de posiciones, ocupacion) sin exigirle
--  conocer la estructura normalizada que hay debajo.
-- #############################################################################

GRANT SELECT ON edicion_mundial        TO rol_consulta_mundial;
GRANT SELECT ON estadio                TO rol_consulta_mundial;
GRANT SELECT ON seleccion              TO rol_consulta_mundial;
GRANT SELECT ON partido                TO rol_consulta_mundial;
GRANT SELECT ON participacion_partido  TO rol_consulta_mundial;

GRANT SELECT ON v_resumen_partido       TO rol_consulta_mundial;
GRANT SELECT ON v_rendimiento_seleccion TO rol_consulta_mundial;
GRANT SELECT ON v_ocupacion_estadio     TO rol_consulta_mundial;
GRANT SELECT ON v_tabla_posiciones      TO rol_consulta_mundial;


-- #############################################################################
--  PARTE 3 - PERFIL OPERATIVO
-- #############################################################################

-- 3.1  Lectura sobre todo el modelo: para registrar un partido hay que poder
--      consultar las ediciones, los estadios y las selecciones disponibles.
GRANT SELECT ON edicion_mundial       TO rol_operativo_mundial;
GRANT SELECT ON estadio               TO rol_operativo_mundial;
GRANT SELECT ON seleccion             TO rol_operativo_mundial;

-- 3.2  Escritura SOLO sobre las tablas transaccionales.
--      Es el nucleo del perfil: programar partidos, registrar sus dos
--      participaciones y actualizar marcadores y asistencias.
GRANT SELECT, INSERT, UPDATE ON partido               TO rol_operativo_mundial;
GRANT SELECT, INSERT, UPDATE ON participacion_partido TO rol_operativo_mundial;

-- 3.3  Se conceden las vistas de consulta, utiles para verificar el trabajo.
GRANT SELECT ON v_resumen_partido  TO rol_operativo_mundial;
GRANT SELECT ON v_tabla_posiciones TO rol_operativo_mundial;

-- NOTA IMPORTANTE SOBRE LO QUE NO SE CONCEDE
--   * Ningun DELETE, en ninguna tabla. Un operador que se equivoca corrige con
--     UPDATE, no borrando historial. El borrado queda reservado al propietario
--     del esquema.
--   * Ninguna escritura sobre EDICION_MUNDIAL, ESTADIO ni SELECCION: son
--     catalogo maestro. Inscribir una seleccion o dar de alta un estadio es una
--     decision administrativa, no una operacion del dia a dia del torneo.
--   * El enunciado menciona ademas que el perfil operativo no debe acceder a la
--     informacion de auditoria "si esta ya existiera". En la Entrega 1 no
--     existe: AUDITORIA_EVENTO pertenece al modelo ampliado de la Entrega 2. Se
--     deja constancia de que, al crearse, NO debera concederse a este rol.


-- #############################################################################
--  PARTE 4 - DEMOSTRACION DE REVOKE
-- #############################################################################
--  Se concede primero un privilegio deliberadamente excesivo y luego se retira,
--  para evidenciar el efecto de REVOKE y no solo el de GRANT.
--
--  El caso elegido no es arbitrario: DELETE sobre PARTICIPACION_PARTIDO permite
--  borrar el marcador de un equipo y dejar el partido con una sola
--  participacion, violando la regla R1 del DDL, que Oracle no puede vigilar de
--  forma declarativa. Es exactamente el tipo de permiso que un perfil operativo
--  no debe tener.
-- #############################################################################

-- 4.1  Concesion excesiva.
GRANT DELETE ON participacion_partido TO rol_operativo_mundial;

-- 4.2  Estado con el privilegio concedido (debe aparecer la fila con DELETE).
SELECT grantee, table_name, privilege
FROM   user_tab_privs_made
WHERE  grantee   = 'ROL_OPERATIVO_MUNDIAL'
  AND  privilege = 'DELETE'
ORDER BY table_name;

-- 4.3  Retiro del privilegio.
REVOKE DELETE ON participacion_partido FROM rol_operativo_mundial;

-- 4.4  Estado tras el REVOKE (no debe devolver ninguna fila).
SELECT grantee, table_name, privilege
FROM   user_tab_privs_made
WHERE  grantee   = 'ROL_OPERATIVO_MUNDIAL'
  AND  privilege = 'DELETE'
ORDER BY table_name;


-- #############################################################################
--  PARTE 5 - EVIDENCIA: MATRIZ DE PRIVILEGIOS RESULTANTE
-- #############################################################################

SELECT
    grantee                                     AS rol,
    table_name                                  AS objeto,
    LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege) AS privilegios
FROM   user_tab_privs_made
WHERE  grantee IN ('ROL_CONSULTA_MUNDIAL', 'ROL_OPERATIVO_MUNDIAL')
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

-- Contraste resumido: el rol de consulta no debe tener NINGUN privilegio de
-- escritura; el operativo debe tenerlo unicamente sobre las dos tablas
-- transaccionales.
SELECT
    grantee AS rol,
    COUNT(CASE WHEN privilege = 'SELECT' THEN 1 END) AS objetos_lectura,
    COUNT(CASE WHEN privilege IN ('INSERT','UPDATE','DELETE') THEN 1 END) AS privilegios_escritura
FROM   user_tab_privs_made
WHERE  grantee IN ('ROL_CONSULTA_MUNDIAL', 'ROL_OPERATIVO_MUNDIAL')
GROUP BY grantee
ORDER BY grantee;


-- #############################################################################
--  PARTE 6 - ASIGNACION A UNA CUENTA REAL Y PRUEBA DE AISLAMIENTO
-- #############################################################################
--  Un rol sin titular no demuestra nada: la rubrica pide "evidencia de que cada
--  usuario solo puede ejecutar las operaciones para las que fue autorizado".
--
--  Como no podemos crear usuarios, se concede el rol a la cuenta Oracle de otro
--  integrante del grupo. El compañero se conecta con SU cuenta y ejecuta las
--  pruebas de la Parte 7; lo que obtenga es la evidencia real de aislamiento, y
--  ademas queda como aporte verificable suyo en el repositorio.
--
--  Sustituir IS1010XX por el usuario Oracle del integrante correspondiente.
-- #############################################################################

-- GRANT rol_consulta_mundial  TO IS1010XX;
-- GRANT rol_operativo_mundial TO IS1010YY;

-- Verificacion de a quien se le concedio cada rol:
-- SELECT grantee, granted_role FROM user_role_privs ORDER BY 1, 2;   -- desde la cuenta receptora


-- #############################################################################
--  PARTE 7 - GUION DE PRUEBAS PARA LA CUENTA RECEPTORA
-- #############################################################################
--  El integrante que recibio ROL_CONSULTA_MUNDIAL ejecuta esto desde SU sesion.
--  Debe anteponer el nombre del esquema propietario a cada objeto.
--
--    -- Los roles no estan activos por defecto en una sesion nueva:
--    SET ROLE rol_consulta_mundial;
--
--    -- (a) DEBE FUNCIONAR: lectura autorizada.
--    SELECT COUNT(*) FROM IS101009.partido;
--    SELECT * FROM IS101009.v_tabla_posiciones WHERE posicion_grupo = 1;
--
--    -- (b) DEBE FALLAR con ORA-01031: insufficient privileges.
--    INSERT INTO IS101009.partido (id_partido, id_edicion, id_estadio, fecha_hora, fase)
--    VALUES (99999, 1, 1, SYSTIMESTAMP, 'Final');
--
--    -- (c) DEBE FALLAR con ORA-01031: insufficient privileges.
--    UPDATE IS101009.participacion_partido SET goles_marcados = 99;
--
--    -- (d) DEBE FALLAR con ORA-01031: insufficient privileges.
--    DELETE FROM IS101009.seleccion;
--
--  Y quien recibio ROL_OPERATIVO_MUNDIAL:
--
--    SET ROLE rol_operativo_mundial;
--
--    -- (e) DEBE FUNCIONAR: escritura sobre tabla transaccional.
--    UPDATE IS101009.participacion_partido SET goles_marcados = 2
--    WHERE id_participacion = 1;
--    ROLLBACK;
--
--    -- (f) DEBE FALLAR: DELETE fue retirado con REVOKE en la Parte 4.
--    DELETE FROM IS101009.participacion_partido WHERE id_participacion = 1;
--
--    -- (g) DEBE FALLAR: sin escritura sobre catalogo maestro.
--    INSERT INTO IS101009.seleccion (id_seleccion, id_edicion, pais, confederacion)
--    VALUES (99999, 1, 'Atlantida', 'UEFA');
--
--  La transcripcion literal de cada resultado va en
--  tests/entrega1/pruebas_privilegios.md.
-- #############################################################################
