# Pruebas de Triggers - Entrega 3
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Responsable: Laura Lesmes (`IS101007`).

Los triggers se ubican en `sql/entrega3/triggers/triggers.sql`. Cada prueba se ejecutó en Oracle 19c (SQL Developer, conexión `proyecto3`) y tiene su captura en `docs/entrega3/`. Las pruebas que modifican datos se deshacen con `ROLLBACK` para no alterar la carga de prueba.

---

## 1. Casos Exitosos

| Caso | Trigger | Operación Evaluada | Resultado Obtenido | Captura |
|---|---|---|---|---|
| **T4** | `trg_auditoria_partido` | `UPDATE partido SET asistencia_registrada = 12345` en el partido 274. | `SELECT` sobre `auditoria_evento`: 1 fila (`PARTIDO`, `UPDATE`, id 274, anterior `81216`, nuevo `12345`, usuario `IS101007`). | `../../docs/entrega3/trigger_auditoria.png` |
| **T6** | Los cuatro (caso válido) | `UPDATE estadistica_jugador_partido SET goles = 0` sobre la primera estadística. | `1 fila actualizada`, sin error: los triggers dejan pasar los datos correctos. | `../../docs/entrega3/caso_valido_estadistica.png` |

---

## 2. Casos Fallidos (Validación de Reglas de Negocio)

| Caso | Trigger | Condición Inválida Evaluada | Error Oracle Obtenido | Regla Protegida | Captura |
|---|---|---|---|---|---|
| **T1** | `trg_rangos_estadistica` | `INSERT` en `estadistica_jugador_partido` con `goles = -1`. | `ORA-20001: Los goles no pueden ser negativos` | Rango de goles. | `../../docs/entrega3/trigger_rangos_goles.png` |
| **T5** | `trg_rangos_estadistica` | `UPDATE estadistica_jugador_partido SET asistencias = -3` sobre la primera estadística. | `ORA-20002: Las asistencias no pueden ser negativas` | Rango de asistencias. | `../../docs/entrega3/trigger_rangos_asistencias.png` |
| **T2** | `trg_antiduplicidad_participacion` | `INSERT` en `participacion_partido` de la selección 153 en el partido 274, donde ya participa. | `ORA-20003: La seleccion ya participa en este partido` | Una selección no aparece dos veces en el mismo partido. | `../../docs/entrega3/trigger_antiduplicidad.png` |
| **T3** | `trg_consistencia_marcador` | `UPDATE estadistica_jugador_partido SET goles = 20` sobre la primera estadística. | `ORA-20004: Los goles de los jugadores superan el marcador oficial` | Los goles individuales no superan el marcador oficial. | `../../docs/entrega3/trigger_consistencia.png` |

---

## 3. Notas de la Ejecución

1. En todos los casos fallidos Oracle muestra también `ORA-06512` y `ORA-04088`: indican en qué trigger y línea se lanzó el error. El mensaje propio de cada regla es el `ORA-2000X`.
2. La auditoría no escribe nada cuando la operación falla, porque el trigger es `AFTER` y Oracle deshace la sentencia completa.
3. Las pruebas se repiten ejecutando `triggers.sql` completo y luego cada sentencia de esta tabla, una por una, con `ROLLBACK` al final.
