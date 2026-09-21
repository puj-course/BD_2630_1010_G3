# CHANGELOG

Registro semanal del progreso del proyecto: objetivos, tareas realizadas,
responsables, ramas utilizadas y problemas encontrados.

Ventana de aporte semanal: **lunes 00:00 — domingo 23:59 (hora Colombia, UTC-5)**.

---

## Equipo del Proyecto

| Nombre | GitHub / Perfil |
|---|---|
| Nicolás Esteban Mamian Palacios | [github.com/Nicolukazzz](https://github.com/Nicolukazzz) |
| Santiago P. | [github.com/hsantiagopf](https://github.com/hsantiagopf) |
| Nick_07 | [github.com/Nivk-Debug](https://github.com/Nivk-Debug) |
| _(completar nombre)_ | [github.com/laulesmes04](https://github.com/laulesmes04) |
| Daniel Rozo | [github.com/daniellrzz](https://github.com/daniellrzz) |
---

# Registro real del proyecto

## Semana 1 — Entrega 1 — (24–30 de agosto de 2026)

### Objetivos de la semana

- Poner en marcha el repositorio con la estructura de carpetas exigida por `README_CRONOGRAMA.md`.
- Documentar en el `README.md` el cronograma del equipo y los datos de conexión al servidor del curso.
- Construir la implementación propia del modelo inicial de 5 entidades en el esquema Oracle de cada integrante.
- Desarrollar los entregables técnicos de la Entrega 1 sobre el modelo inicial.

### Tareas realizadas

| Tarea | Responsable(s) | Rama utilizada | Descripción |
|---|---|---|---|
| Estructura del repositorio, `.gitignore` y `README.md` | Nicolás Mamian | `feature/estructura-inicial` | Árbol de carpetas de las 3 entregas, exclusión de credenciales y documentación de conexión al servidor |
| Script DDL del modelo inicial | Nicolás Mamian | `feature/ddl-modelo-inicial` | Creación de las 5 tablas con sus llaves primarias, foráneas, restricciones CHECK y UNIQUE, y 2 índices |
| Datos de prueba | Nicolás Mamian | `feature/datos-prueba` | 7 ediciones completas: 112 estadios, 224 selecciones, 448 partidos y 896 participaciones |
| Diagrama entidad-relación | Nicolás Mamian | `feature/diagrama-er` | Diagrama del modelo inicial con atributos, llaves y relaciones |
| Corrección de la restricción de grupo | Nicolás Mamian | `fix/restriccion-grupo` | Se cambió BETWEEN por una lista de valores y la columna a un solo carácter |
| Auditoría del DDL | Nicolás Mamian | `fix/auditoria-ddl` | Se cerraron 4 huecos con nuevas restricciones CHECK y se documentaron 3 reglas más que no se pueden declarar |
| Documento técnico, secciones 1 a 3 | Laura Lesmes | `lesmes-dml` | Descripción del problema, supuestos de modelado y diagrama entidad-relación |
| Álgebra relacional | Laura Lesmes | `lesmes-dml` | Traducción de 4 de las 15 consultas a notación de álgebra relacional |
| Vistas, DML y roles | Nicholas Ruiz | `feature/vistas-dml-roles` | Cuatro vistas con su justificación, ciclo de vida del partido y creación de los dos roles |
| Pruebas de privilegios | Nicholas Ruiz | `feature/pruebas-roles-v2` | Matriz de permisos y evidencia de lo que puede hacer cada rol |
| Corrección de roles y rutas | Nicolás Mamian | `fix/roles-y-rutas-nick` | Se ajustaron los GRANT para que coincidieran con la documentación de las pruebas |
| Datos del equipo en el README | Daniel Rozo, Santiago P. | `fix/roles-y-rutas-nick` | Cada integrante completó su nombre y su perfil de GitHub |
| Archivo de consultas | Daniel Rozo | `daniellrzz-patch-1` | Se creó `consultas.sql` como archivo único de trabajo |

### Cambios principales

- Se creó la estructura de carpetas `docs/`, `sql/` y `tests/` separada por entrega, siguiendo exactamente el `README_CRONOGRAMA.md`.
- Se eliminaron los archivos `blank_file*.md` de la plantilla.
- Se añadió `.gitignore` para evitar versionar credenciales de Oracle.
- Se crearon las 5 tablas del modelo inicial y se probó el script contra el servidor.
- Se cargaron los datos de prueba: 1.687 filas en total.
- Se generó el diagrama entidad-relación a partir de la base de datos.
- Se corrigió la restricción del grupo de las selecciones, que dejaba pasar valores inválidos.
- Se auditó el DDL probando datos inválidos contra el servidor. Se cerraron 4 huecos y se documentaron 3 reglas nuevas.

### Problemas encontrados

- La cuenta Oracle asignada a cada estudiante **no tiene el privilegio `CREATE USER`**, por lo que el punto de "Privilegios Básicos" se resuelve con **roles** (`CREATE ROLE` sí está disponible), alternativa contemplada por el enunciado.
- El `README_GUIA_SERVIDOR.md` lista de forma incompleta las columnas de referencia: `FIFA_PARTIDO` incluye además `ASISTENCIA_REGISTRADA` y `FIFA_SELECCION` incluye además `GRUPO`. Ambas son necesarias para las consultas de ocupación de estadio y de tabla de posiciones.
- La tabla `EDICION_MUNDIAL` queda con 7 filas y no con las 100 que pide el enunciado, porque cada fila es un Mundial completo y solo se han disputado 22 en la historia. Se le consultó a la monitora si aplica la salvedad de "cuando aplique según la naturaleza de la tabla". Las otras cuatro tablas sí superan las 100 filas.
- La restricción `grupo BETWEEN 'A' AND 'L'` no servía: sobre texto, `BETWEEN` compara alfabéticamente, así que aceptaba valores como `'AB'` o `'Kansas'` por empezar entre la A y la L. Se reemplazó por una lista explícita de las 12 letras y se bajó la columna a `VARCHAR2(1)`.
- La auditoría encontró que la base aceptaba asistencias mayores que el aforo del estadio, campos de texto con solo espacios en blanco y ediciones de un solo día. Los dos últimos se cerraron con restricciones `CHECK`; el primero no se puede, porque el aforo está en otra tabla y un `CHECK` no puede consultarla.

---

## Semana 2 — Entrega 1 — (31 de agosto al 6 de septiembre de 2026)

### Objetivos de la semana

- Escribir las primeras consultas del listado del enunciado sobre el modelo inicial ya cargado.

### Tareas realizadas

| Tarea | Responsable(s) | Rama utilizada | Descripción |
|---|---|---|---|
| Consultas 1 a 5 | Santiago P. | `daniellrzz-patch-1` | Primeras cinco consultas del listado del enunciado, escritas sobre `consultas.sql` |

### Cambios principales

- Se escribieron las consultas 1 a 5 del listado del enunciado.

### Problemas encontrados

- Semana de poca actividad: solo se registró un aporte. El trabajo de las vistas, el DML y los
  roles que el cronograma ubica en esta semana ya se había adelantado en la semana 1, pero eso
  dejó la ventana de esta semana casi vacía.
- Las consultas se concentraron en un solo archivo, `consultas.sql`, en lugar de los archivos por
  semana que exige el `README_CRONOGRAMA.md`. La división quedó pendiente.

---

## Semana 3 — Entrega 1 — (7 al 13 de septiembre de 2026)

### Objetivos de la semana

- Completar las 15 consultas del listado del enunciado.
- Corregir los documentos que habían quedado con contenido mezclado o desactualizado.

### Tareas realizadas

| Tarea | Responsable(s) | Rama utilizada | Descripción |
|---|---|---|---|
| Consultas 6 a 15 | Daniel Rozo | `daniellrzz-patch-1`, `feature/consultas-joins-semana1-1` | Se completó el listado con las consultas de subconsultas, verificación de integridad y consulta sobre vista |
| Corrección de la consulta 8 | Daniel Rozo | `fix-consulta-8-correlacionada` | Se reescribió la subconsulta correlacionada del promedio de ocupación |
| Corrección de las consultas 2 y 8 | Santiago P. | `consultas2-8_patch` | Se cambió la fórmula de ocupación a asistencia registrada sobre capacidad |
| Comentarios de los datos de prueba | Nicolás Mamian | `daniellrzz-patch-1` | Se corrigieron comentarios que ya no correspondían al contenido del script |
| Limpieza de `vistas.md` | Nicolás Mamian | `fix/vistas-md-y-readme` | Se quitó un fragmento de DML que había quedado pegado tras un merge mal resuelto, y se puso al día la tabla de estado del README |
| Ajuste del `.gitignore` | Daniel Rozo | `daniellrzz-patch-1` | Se quitó una regla que sobraba |

### Cambios principales

- El listado de las 15 consultas del enunciado quedó completo.
- `docs/entrega1/vistas.md` volvió a tener solo las cuatro justificaciones de las vistas.
- La tabla de estado de la Entrega 1 en el `README.md` dejó de marcar como pendiente lo que ya
  estaba mergeado.

### Problemas encontrados

- Las consultas 6 a 15 se escribieron dos veces en paralelo, desde el mismo punto del historial:
  una versión en `main` y otra en la rama `feature/consultas-joins-semana1`. Al momento de cerrar
  la semana, la segunda seguía sin mergear.
- La fórmula de ocupación por estadio de la versión que quedó en `main` dividía el número de
  partidos entre el aforo, lo que no es un porcentaje de ocupación. La corrección existía, pero
  en la rama sin mergear.

---

## Semana 4 — Entrega 1 — (14 al 20 de septiembre de 2026)

### Objetivos de la semana

- Cerrar la Entrega 1: dejar cada entregable en el archivo y la ruta que exige el
  `README_CRONOGRAMA.md` y mergear las ramas que quedaran pendientes.

### Tareas realizadas

| Tarea | Responsable(s) | Rama utilizada | Descripción |
|---|---|---|---|
| Pruebas de DML | Nicolás Mamian | `tests/pruebas-dml` | Se ejecutó el script de ciclo de vida contra el servidor y se documentaron los 4 intentos inválidos y las 2 pruebas de `ON DELETE` con su salida real |
| Merge de la rama de consultas pendiente | Nicolás Mamian | `refactor/consultas-por-semana` | Se integró `feature/consultas-joins-semana1`, conservando la corrección de las consultas 2 y 8 |
| División de las consultas por semana | Nicolás Mamian | `refactor/consultas-por-semana` | `consultas.sql` se partió en los cinco archivos que exige el cronograma |
| Registro de las semanas 2, 3 y 4 | Nicolás Mamian | `refactor/consultas-por-semana` | Se completó el CHANGELOG, que solo tenía la entrada de la semana 1 |

### Cambios principales

- `sql/entrega1/consultas/consultas.sql` desapareció y su contenido quedó repartido en
  `semana1_joins.sql` (consultas 2 y 6), `semana2_agregaciones.sql` (1, 3, 4, 5, 9, 12 y 13),
  `semana3_subconsultas.sql` (7, 8, 10 y 11), `semana3_consulta_vista.sql` (15) y
  `semana4_verificacion_integridad.sql` (14).
- Cada consulta quedó precedida del comentario `-- Consulta N: <descripción>` que pide el
  cronograma.
- Los cinco archivos se ejecutaron contra el servidor: las 15 consultas corren sin error.
- Se creó `tests/entrega1/pruebas_dml.md` con la evidencia de ejecución.

### Problemas encontrados

- El conflicto entre `main` y `feature/consultas-joins-semana1` se resolvió quedándose con la
  versión de la rama, porque traía las 15 consultas completas y además la fórmula de ocupación
  correcta. Se comprobó contra el servidor: la versión de `main` daba 0.01 % de ocupación para
  todos los estadios; la de la rama da valores entre 70,1 % y 90,8 %.
- Las consultas 11 y 15 usan `RANK() OVER (...)`. Es una función de ventana y no aparece en las
  presentaciones del curso.
- La consulta 5 devuelve los 16 estadios de cada edición como empatados en primer lugar. No es un
  error de la consulta: los datos de prueba reparten exactamente 4 partidos por estadio.
- Siguen pendientes al cierre `docs/entrega1/evaluacion_critica_modelo_inicial.md`,
  `docs/entrega1/boceto_modelo_ampliado.png` y `docs/entrega1/diccionario_datos.md`.
- `tests/entrega1/pruebas_privilegios.md` consulta `role_tab_privs`, que devuelve 0 filas desde el
  esquema del estudiante. Los datos que muestra el documento corresponden a
  `user_tab_privs_made`.
