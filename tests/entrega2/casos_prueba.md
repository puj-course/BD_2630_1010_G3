# Casos de prueba - Entrega 2
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

El script está en `tests/entrega2/casos_prueba.sql` y se debe ejecutar con el usuario del grupo (`IS101007`). Las pruebas crean sus propios datos con ids desde 9001 y terminan con `ROLLBACK`, así que no cambian los datos de prueba del modelo.

---

## 1. Casos exitosos

| Caso | Qué se prueba | Resultado esperado |
|---|---|---|
| E1 | Crear una edición con su sede, ciudad, estadio, fase y grupo | Filas insertadas |
| E2 | Registrar tres selecciones en el grupo A | Filas insertadas |
| E3 | Crear un partido con una participación local y una visitante | Filas insertadas |
| E4 | Registrar jugadores, convocatoria, árbitro, estadística e incidencia del partido | Filas insertadas |
| E5 | Actualizar el marcador final (2-1) y la asistencia | Filas actualizadas |
| E6 | Borrar el partido y comprobar que se borran sus participaciones, asignaciones, estadísticas e incidencias | Conteo pasa de 2, 1, 1, 1 a 0, 0, 0, 0 |

---

## 2. Casos fallidos

| Caso | Qué se intenta | Error esperado | Restricción |
|---|---|---|---|
| F1 | Poner goles negativos | ORA-02290 | `ck_participacion_goles` |
| F2 | Agregar un segundo local al mismo partido | ORA-00001 | `uq_participacion_condicion` |
| F3 | Repetir un dorsal en la misma selección | ORA-00001 | `uq_convocatoria_numero` |
| F4 | Usar el dorsal 30 | ORA-02290 | `ck_convocatoria_numero` |
| F5 | Dejar un estadio con capacidad de 5000 | ORA-02290 | `ck_estadio_capacidad` |
| F6 | Programar dos partidos en el mismo estadio a la misma hora | ORA-00001 | `uq_partido_agenda` |
| F7 | Crear un partido en un estadio que no existe | ORA-02291 | `fk_partido_estadio` |
| F8 | Darle minuto de entrada a un titular | ORA-02290 | `ck_estadistica_entradas` |
| F9 | Ponerle la letra Z a un grupo | ORA-02290 | `ck_grupo_nombre` |
| F10 | Asignar un rol arbitral que no existe | ORA-02290 | `ck_asignacion_rol` |
| F11 | Borrar una selección que ya jugó un partido | ORA-02292 | `fk_participacion_seleccion` |
| F12 | Borrar un estadio que tiene partidos | ORA-02292 | `fk_partido_estadio` |

---

## 3. Comportamiento al borrar

F11 y F12 muestran que Oracle no deja borrar una fila padre que todavía tiene hijos cuando la llave foránea no tiene `ON DELETE`. E6 muestra lo contrario en las tablas con `ON DELETE CASCADE`: al borrar el partido, sus filas dependientes se borran con él.

---

## 4. Reglas que todavía no se prueban

Las reglas que necesitan consultar otras filas o tablas (por ejemplo, que la asistencia no supere el aforo o que un partido tenga exactamente dos participaciones) no se pueden controlar con `CHECK`. Se probarán en la Entrega 3, cuando estén los triggers.
