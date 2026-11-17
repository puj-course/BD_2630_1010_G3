# Pruebas de Triggers - Entrega 3
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Responsable: Laura Lesmes (`IS101007`).

Los triggers están en `sql/entrega3/triggers/triggers.sql`. Cada prueba se ejecutó en Oracle 19c (SQL Developer, conexión `proyecto3`) y tiene su captura en `docs/entrega3/`. Las pruebas que modifican datos se deshacen con `ROLLBACK` para no alterar la carga de prueba.

---

## 1. Casos fallidos (el trigger rechaza la operación)

| Caso | Trigger | Operación evaluada | Resultado obtenido | Captura |
|---|---|---|---|---|
| **T1** | `trg_rangos_estadistica` | `INSERT` en `estadistica_jugador_partido` con `goles = -1`. | `ORA-20001: Los goles no pueden ser negativos` | `../../docs/entrega3/trigger_rangos_goles.png` |
| **T2** | `trg_antiduplicidad_participacion` | `INSERT` en `participacion_partido` de la selección 153 en el partido 274, donde ya participa. | `ORA-20003: La seleccion ya participa en este partido` | `../../docs/entrega3/trigger_antiduplicidad.png` |
| **T3** | `trg_consistencia_marcador` | `UPDATE estadistica_jugador_partido SET goles = 20` sobre la primera estadística. | `ORA-20004: Los goles de los jugadores superan el marcador oficial` | `../../docs/entrega3/trigger_consistencia.png` |

## 2. Caso de auditoría (el trigger registra el cambio)

| Caso | Trigger | Operación evaluada | Resultado obtenido | Captura |
|---|---|---|---|---|
| **T4** | `trg_auditoria_partido` | `UPDATE partido SET asistencia_registrada = 12345` en el partido 274. | `SELECT` sobre `auditoria_evento`: 1 fila (`PARTIDO`, `UPDATE`, id 274, anterior `81216`, nuevo `12345`, usuario `IS101007`). | `../../docs/entrega3/trigger_auditoria.png` |

## 3. Pruebas pendientes de ejecutar y capturar

Estas dos faltan; no se registra resultado hasta tener la captura.

| Caso | Trigger | Operación | Resultado esperado | Captura |
|---|---|---|---|---|
| **T5** | `trg_rangos_estadistica` | `UPDATE estadistica_jugador_partido SET asistencias = -3` sobre una fila existente. | `ORA-20002: Las asistencias no pueden ser negativas` | `trigger_rangos_asistencias.png` |
| **T6** | Los cuatro | Caso válido: `UPDATE estadistica_jugador_partido SET goles = 0` sobre una fila existente. | `1 fila actualizada`, sin error. | `caso_valido_estadistica.png` |

---

## 4. Regla protegida por cada trigger

- Rangos: no hay goles ni asistencias negativos.
- Anti-duplicidad: una selección no aparece dos veces en el mismo partido.
- Auditoría: queda quién, cuándo y qué cambió en partidos y estadísticas.
- Consistencia: los goles de los jugadores no superan el marcador oficial.
