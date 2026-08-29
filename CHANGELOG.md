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

### Cambios principales

- Se creó la estructura de carpetas `docs/`, `sql/` y `tests/` separada por entrega, siguiendo exactamente el `README_CRONOGRAMA.md`.
- Se eliminaron los archivos `blank_file*.md` de la plantilla.
- Se añadió `.gitignore` para evitar versionar credenciales de Oracle.
- Se crearon las 5 tablas del modelo inicial y se probó el script contra el servidor.
- Se cargaron los datos de prueba: 1.687 filas en total.
- Se generó el diagrama entidad-relación a partir de la base de datos.

### Problemas encontrados

- La cuenta Oracle asignada a cada estudiante **no tiene el privilegio `CREATE USER`**, por lo que el punto de "Privilegios Básicos" se resuelve con **roles** (`CREATE ROLE` sí está disponible), alternativa contemplada por el enunciado.
- El `README_GUIA_SERVIDOR.md` lista de forma incompleta las columnas de referencia: `FIFA_PARTIDO` incluye además `ASISTENCIA_REGISTRADA` y `FIFA_SELECCION` incluye además `GRUPO`. Ambas son necesarias para las consultas de ocupación de estadio y de tabla de posiciones.
- La tabla `EDICION_MUNDIAL` queda con 7 filas y no con las 100 que pide el enunciado, porque cada fila es un Mundial completo y solo se han disputado 22 en la historia. Se le consultó a la monitora si aplica la salvedad de "cuando aplique según la naturaleza de la tabla". Las otras cuatro tablas sí superan las 100 filas.

---
