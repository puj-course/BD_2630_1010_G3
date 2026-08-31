# Pruebas de Roles y Privilegios - Mundial FIFA (Entrega 1)


## 1. Matriz de Permisos Configurada

| Objeto / Tabla | Rol Lectura (ROL_LECTURA_MUNDIAL) | Rol Escritura (ROL_ESCRITURA_MUNDIAL) |
| :--- | :--- | :--- |
| Catálogos (EDICION_MUNDIAL, ESTADIO, SELECCION) | SELECT | SELECT |
| Transaccionales (PARTIDO, PARTICIPACION_PARTIDO) | SELECT | SELECT, INSERT, UPDATE |
| Vistas | SELECT |     |

---

## 2. Resultados de la Verificacion en Diccionario de Datos

### Prueba 1: Permisos del Rol de Lectura

Consulta ejecutada:
SELECT table_name, privilege FROM role_tab_privs WHERE role = 'ROL_LECTURA_MUNDIAL' ORDER BY table_name;

Salida del Diccionario de Datos (9 filas devueltas):

| TABLE_NAME | PRIVILEGE |
| :--- | :--- |
| EDICION_MUNDIAL | SELECT |
| ESTADIO | SELECT |
| PARTICIPACION_PARTIDO | SELECT |
| PARTIDO | SELECT |
| SELECCION | SELECT |
| VISTA_GOLEADORES | SELECT |
| VISTA_OCUPACION_ESTADIOS | SELECT |
| VISTA_RESUMEN_EDICIONES | SELECT |
| VISTA_TABLA_POSICIONES | SELECT |



---

### Prueba 2: Verificacion de Privilegios Iniciales vs Efecto del REVOKE (Rol Escritura)

Consulta ejecutada:
SELECT table_name, privilege FROM role_tab_privs WHERE role = 'ROL_ESCRITURA_MUNDIAL' ORDER BY table_name, privilege;

**Estado Inicial (11 filas devueltas - Antes de aplicar REVOKE):**

| TABLE_NAME | PRIVILEGE |
| :--- | :--- |
| EDICION_MUNDIAL | SELECT |
| ESTADIO | SELECT |
| PARTICIPACION_PARTIDO | DELETE |
| PARTICIPACION_PARTIDO | INSERT |
| PARTICIPACION_PARTIDO | SELECT |
| PARTICIPACION_PARTIDO | UPDATE |
| PARTIDO | DELETE |
| PARTIDO | INSERT |
| PARTIDO | SELECT |
| PARTIDO | UPDATE |
| SELECCION | SELECT |

---

**Estado Final Verificado (9 filas devueltas - Tras aplicar REVOKE):**

| TABLE_NAME | PRIVILEGE | Estado del Permiso |
| :--- | :--- | :--- |
| EDICION_MUNDIAL | SELECT |  (Solo lectura) |
| ESTADIO | SELECT |  (Solo lectura) |
| PARTICIPACION_PARTIDO | INSERT | Habilitado |
| PARTICIPACION_PARTIDO | SELECT | Habilitado |
| PARTICIPACION_PARTIDO | UPDATE | Habilitado (DELETE Revocado) |
| PARTIDO | INSERT | Habilitado |
| PARTIDO | SELECT | Habilitado |
| PARTIDO | UPDATE | Habilitado (DELETE Revocado) |
| SELECCION | SELECT |  (Solo lectura) |

> Evaluacion:
> 1. la eliminacion de los permisos DELETE en las tablas  (PARTIDO y PARTICIPACION_PARTIDO) aplicando el comando REVOKE.
