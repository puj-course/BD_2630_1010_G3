-- ============================================================
-- Roles y Privilegios - Mundial FIFA (Entrega 1)
-- Grupo G3
-- ============================================================
-- Se usan ROLES y no usuarios porque la cuenta del curso no tiene el
-- privilegio CREATE USER. Se puede comprobar con:
--     SELECT privilege FROM session_privs ORDER BY 1;
-- El enunciado permite la alternativa ("al menos dos usuarios o roles").
--
-- IMPORTANTE: en Oracle los roles NO pertenecen a un esquema, son globales
-- de toda la base de datos. Si dos integrantes ejecutan este script, el
-- segundo recibe ORA-01921 porque el rol ya existe. Eso no es un error del
-- script: los GRANT posteriores si se aplican, y cada uno concede permisos
-- sobre SUS PROPIAS tablas. Por eso la verificacion usa USER_TAB_PRIVS_MADE,
-- que muestra lo que cada quien concedio sobre sus objetos, y no
-- ROLE_TAB_PRIVS, que solo deja ver los roles que uno mismo tiene.
-- ============================================================


-- ------------------------------------------------------------
-- Borrado previo, para poder ejecutar el script varias veces.
-- Sin esto, la segunda ejecucion falla con ORA-01921 (role already exists).
-- ------------------------------------------------------------

SET SERVEROUTPUT ON

BEGIN
    FOR r IN (SELECT 'ROL_LECTURA_MUNDIAL' n FROM dual
              UNION ALL SELECT 'ROL_ESCRITURA_MUNDIAL' FROM dual) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP ROLE ' || r.n;
            dbms_output.put_line('Rol eliminado: ' || r.n);
        EXCEPTION WHEN OTHERS THEN
            dbms_output.put_line('No se elimino ' || r.n || ' (lo creo otro integrante o no existia)');
        END;
    END LOOP;
END;
/


-- ------------------------------------------------------------
-- 1. Rol de solo lectura
-- ------------------------------------------------------------
-- Perfil de analista o consulta publica. Solo puede leer, nunca modificar.

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE rol_lectura_mundial';
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('ROL_LECTURA_MUNDIAL ya existia, se reutiliza');
END;
/

GRANT SELECT ON edicion_mundial       TO rol_lectura_mundial;
GRANT SELECT ON estadio               TO rol_lectura_mundial;
GRANT SELECT ON seleccion             TO rol_lectura_mundial;
GRANT SELECT ON partido               TO rol_lectura_mundial;
GRANT SELECT ON participacion_partido TO rol_lectura_mundial;

-- Tambien las vistas: un perfil de consulta deberia trabajar contra ellas,
-- que exponen el modelo ya interpretado.
GRANT SELECT ON vista_tabla_posiciones   TO rol_lectura_mundial;
GRANT SELECT ON vista_goleadores         TO rol_lectura_mundial;
GRANT SELECT ON vista_ocupacion_estadios TO rol_lectura_mundial;
GRANT SELECT ON vista_resumen_ediciones  TO rol_lectura_mundial;


-- ------------------------------------------------------------
-- 2. Rol de escritura
-- ------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE rol_escritura_mundial';
EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('ROL_ESCRITURA_MUNDIAL ya existia, se reutiliza');
END;
/

-- Los catalogos solo se leen. Dar de alta un estadio o inscribir una
-- seleccion es una decision administrativa, no una operacion del dia a dia
-- del torneo.
GRANT SELECT ON edicion_mundial TO rol_escritura_mundial;
GRANT SELECT ON estadio         TO rol_escritura_mundial;
GRANT SELECT ON seleccion       TO rol_escritura_mundial;

-- Sobre las tablas transaccionales si puede escribir: programar partidos,
-- registrar sus participaciones y actualizar marcadores.
GRANT SELECT, INSERT, UPDATE, DELETE ON partido               TO rol_escritura_mundial;
GRANT SELECT, INSERT, UPDATE, DELETE ON participacion_partido TO rol_escritura_mundial;


-- ------------------------------------------------------------
-- 3. REVOKE: se retira el DELETE
-- ------------------------------------------------------------
-- Se concede primero y se retira despues para dejar evidencia del efecto
-- del REVOKE, no solo del GRANT.
--
-- El caso no es arbitrario: con DELETE sobre PARTICIPACION_PARTIDO se podria
-- borrar el marcador de un equipo y dejar el partido con una sola
-- participacion, violando una regla que Oracle no puede vigilar con un CHECK.
-- Un operador que se equivoca corrige con UPDATE, no borrando historial.

-- Estado antes del REVOKE: 11 filas
SELECT table_name, privilege FROM user_tab_privs_made
WHERE grantee = 'ROL_ESCRITURA_MUNDIAL' ORDER BY table_name, privilege;

REVOKE DELETE ON partido               FROM rol_escritura_mundial;
REVOKE DELETE ON participacion_partido FROM rol_escritura_mundial;

-- Estado despues del REVOKE: 9 filas
SELECT table_name, privilege FROM user_tab_privs_made
WHERE grantee = 'ROL_ESCRITURA_MUNDIAL' ORDER BY table_name, privilege;


-- ------------------------------------------------------------
-- 4. Verificacion final
-- ------------------------------------------------------------

SELECT grantee AS rol, table_name AS objeto,
       LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege) AS privilegios
FROM   user_tab_privs_made
WHERE  grantee IN ('ROL_LECTURA_MUNDIAL', 'ROL_ESCRITURA_MUNDIAL')
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

EXIT;
