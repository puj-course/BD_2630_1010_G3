# Pruebas de Procedimientos Almacenados - Entrega 3
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

Responsable: Harold Santiago Pereira Fuentes (`IS101013`).

El script de pruebas se ubica en `tests/entrega3/pruebas_procedimientos.sql`. Evalúa de manera exhaustiva las reglas de negocio implementadas en los procedimientos almacenados desarrollados para la base de datos Oracle 19c.

---

## 1. Casos Exitosos

| Caso | Procedimiento | Operación Evaluada | Resultado Esperado |
|---|---|---|---|
| **P1** | `pr_actualizar_tabla_posiciones` | Recalcular y materializar la tabla de posiciones por grupo de la edición 7 (Catar 2022). | Se puebla la tabla `tabla_posiciones` con 32 selecciones ordenadas del puesto 1 al 4 en cada uno de los 8 grupos (A–H) con puntos, diferencia y goles reglamentarios. |
| **R1** | `pr_registrar_resultado` | Registrar marcador 2-0 y asistencia de 60.000 en el partido 385 (Fase de Grupos). | Se actualizan las participaciones del local y visitante con sus goles, la asistencia del partido y se recalcula la tabla de posiciones del grupo. |
| **M1** | `pr_carga_masiva_resultados` | Procesar un lote en `resultado_carga_temporal` con un registro válido. | La fila válida pasa a estado `'PROCESADO'` con `mensaje_error IS NULL` y se actualizan los datos en el modelo relacional. |
| **C1** | `pr_cierre_fase` | Cerrar formalmente la fase de grupos (fase 37) en la edición 7. | Todos los partidos cuentan con asistencia y participaciones completas; el procedimiento confirma el cierre y consolida las posiciones finales. |

---

## 2. Casos Fallidos (Validación de Reglas de Negocio)

| Caso | Procedimiento | Condición Inválida Evaluada | Error Oracle Obtenido | Regla Protegida |
|---|---|---|---|---|
| **P2** | `pr_actualizar_tabla_posiciones` | Edición que no existe (`id_edicion = 999999`). | `ORA-20026: La edicion 999999 no existe` | Integridad referencial de la edición. |
| **R2** | `pr_registrar_resultado` | Marcador con goles fuera de rango (`goles_local = 16`). | `ORA-20023: Goles del local fuera de rango (0-15): 16` | Límite máximo de goles por partido (`ck_participacion_goles`). |
| **R3** | `pr_registrar_resultado` | Asistencia de 80.000 en estadio 97 con aforo de 60.000. | `ORA-20024: La asistencia (80000) supera la capacidad del estadio (60000)` | Control de aforo máximo de estadios en partidos. |
| **R4** | `pr_registrar_resultado` | Registro de empate (2-2) en un partido de fase eliminatoria (partido 448, Final). | `ORA-20025: Un partido de fase eliminatoria no puede terminar en empate` | Desempate reglamentario obligatorio en llaves eliminatorias. |
| **R5** | `pr_registrar_resultado` | Partido inexistente (`id_partido = 999999`). | `ORA-20021: El partido 999999 no existe` | Integridad referencial del partido. |
| **M2** | `pr_carga_masiva_resultados` | Lote con resultado con goles negativos (`goles = -1`). | Fila marcada en estado `'ERROR'` con el mensaje de excepción sin interrumpir el procesamiento del resto del lote. | Aislamiento y tolerancia a fallos por `SAVEPOINT`. |
| **M3** | `pr_carga_masiva_resultados` | Lote con partido inexistente (`id_partido = 999999`). | Fila no omitida silenciosamente: capturada, procesada y marcada como `'ERROR'` con mensaje `ORA-20021`. | Integridad en procesamiento masivo de datos externos. |
| **C2** | `pr_cierre_fase` | Fase que no pertenece a la edición (`id_fase = 99999`). | `ORA-20026: La fase 99999 no existe en la edicion 7` | Coherencia de fases y torneos. |

---

## 3. Verificación de Integración con la Aplicación

Los procedimientos se integran con la interfaz gráfica en Java Swing a través de `RepositoryPartido`:
1. `RepositoryPartido.registrarResultado` invoca mediante JDBC `CallableStatement` el procedimiento `pr_registrar_resultado`.
2. `RepositoryPartido.cerrarFase` invoca mediante JDBC `CallableStatement` el procedimiento `pr_cierre_fase`.
3. Cuando Oracle rechaza una operación inválida, los errores `ORA-20021` a `ORA-20027` son capturados por el bloque try-catch y presentados al usuario a través del componente `Mensajes.error`.
