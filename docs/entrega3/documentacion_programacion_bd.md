# Documentación de la programación en la base de datos - Entrega 3

## Funciones

Archivo: `sql/entrega3/funciones/funciones.sql`. Al final del script hay consultas de prueba sobre la edición 7.

| Función | Parámetros | Devuelve |
|---|---|---|
| `fn_diferencia_gol` | `p_id_seleccion` | Goles a favor menos goles en contra de la selección en todos sus partidos |
| `fn_goles_jugador` | `p_id_jugador`, `p_id_edicion` | Goles del jugador en esa edición |
| `fn_posicion_goleador` | `p_id_jugador`, `p_id_edicion` | Puesto del jugador en el ranking de goleadores de la edición |
| `fn_cupo_convocatoria` | `p_id_seleccion` | Cupos libres en la convocatoria (26 menos los convocados) |

**`fn_diferencia_gol`.** Une cada participación de la selección con la participación del rival en el mismo partido y suma la resta de los goles. Si la selección no ha jugado, devuelve 0.

**`fn_goles_jugador`.** Suma los goles del jugador en `estadistica_jugador_partido`, solo en los partidos de la edición indicada. Si no tiene estadísticas, devuelve 0.

**`fn_posicion_goleador`.** Cuenta cuántos jugadores de la edición tienen más goles que él y le suma 1. Los jugadores con los mismos goles quedan en el mismo puesto.

**`fn_cupo_convocatoria`.** Cuenta los convocados de la selección y los resta de 26. Si la selección no existe, lanza el error `ORA-20010`.

Ejemplo de uso:

    SELECT pais, fn_diferencia_gol(id_seleccion) AS diferencia_gol
    FROM seleccion
    WHERE id_edicion = 7
    ORDER BY diferencia_gol DESC;

La aplicación usa las tres primeras en el panel de reportes. `fn_cupo_convocatoria` sirve para revisar si una selección todavía puede convocar jugadores, y la puede usar el trigger de consistencia de la convocatoria.

---

## Procedimientos Almacenados

Archivo: `sql/entrega3/procedimientos/procedimientos.sql`.

Responsable: Harold Santiago Pereira Fuentes (`IS101013`).

| Procedimiento | Parámetros | Propósito |
|---|---|---|
| `pr_actualizar_tabla_posiciones` | `p_id_edicion` | Calcula y materializa la tabla de posiciones por grupo de una edición mundialista en la tabla `tabla_posiciones`. |
| `pr_registrar_resultado` | `p_id_partido`, `p_goles_local`, `p_goles_visitante`, `p_asistencia` | Valida y asienta el resultado y asistencia de un partido, actualizando las participaciones y la tabla de posiciones si es fase de grupos. |
| `pr_carga_masiva_resultados` | `p_id_edicion`, `p_procesados OUT`, `p_exitosos OUT`, `p_fallidos OUT` | Procesa en lote de forma controlada resultados pendientes desde `resultado_carga_temporal` con aislamiento por savepoint. |
| `pr_cierre_fase` | `p_id_edicion`, `p_id_fase` | Valida que todos los partidos de la fase hayan concluido y formaliza el avance de los ganadores al partido siguiente en eliminatorias o refresca las posiciones en fase de grupos. |

### 1. `pr_actualizar_tabla_posiciones`

- **Entrada:** `p_id_edicion NUMBER` (identificador de la edición).
- **Comportamiento:**
  1. Verifica que la edición exista en `edicion_mundial`. Si no existe, genera error `ORA-20026`.
  2. Borra los registros anteriores de la edición en `tabla_posiciones`.
  3. Consulta mediante CTE (`resultados` y `acumulado`) todas las selecciones participantes con grupo asignado en la fase `'GRUPOS'` de esa edición, considerando únicamente partidos efectivamente disputados (`p.asistencia_registrada IS NOT NULL`), evitando que partidos programados pendientes con marcador 0–0 por defecto sean contabilizados indebidamente como empates jugados.
  4. Calcula los indicadores reglamentarios: partidos jugados (`jugados`), ganados (`ganados`), empatados (`empatados`), perdidos (`perdidos`), goles a favor (`goles_favor`), goles en contra (`goles_contra`), diferencia de goles (`diferencia_gol = GF - GC`) y puntos (`puntos = 3 * PG + 1 * PE`).
  5. Asigna el orden de posición por grupo aplicando los criterios FIFA (`ROW_NUMBER() OVER (PARTITION BY id_grupo ORDER BY puntos DESC, diferencia DESC, goles_favor DESC, pais ASC)`).
  6. Inserta cada fila resultante en la tabla física `tabla_posiciones`.

**Ejemplo de uso:**

```sql
EXEC pr_actualizar_tabla_posiciones(7);

SELECT g.nombre AS grupo, tp.posicion, s.pais, tp.puntos, tp.diferencia_gol
FROM tabla_posiciones tp
JOIN grupo g ON g.id_grupo = tp.id_grupo
JOIN seleccion s ON s.id_seleccion = tp.id_seleccion
WHERE tp.id_edicion = 7 AND tp.posicion <= 2
ORDER BY g.nombre, tp.posicion;
```

### 2. `pr_registrar_resultado`

- **Entradas:**
  - `p_id_partido NUMBER`: identificador del partido.
  - `p_goles_local NUMBER`: goles marcados por la selección local (0 a 15, no nulo).
  - `p_goles_visitante NUMBER`: goles marcados por la selección visitante (0 a 15, no nulo).
  - `p_asistencia NUMBER`: cantidad de espectadores presentes en el estadio (opcional, no negativo; si es nulo se asienta 0 para formalizar que el partido fue disputado).
- **Validaciones aplicadas:**
  - `ORA-20021`: Si el partido no existe en la base de datos.
  - `ORA-20023`: Si los goles del local o visitante son nulos o están fuera del rango válido (0 a 15, alineado con `ck_participacion_goles`).
  - `ORA-20024`: Si la asistencia es negativa o supera la capacidad máxima del estadio donde se disputa el partido.
  - `ORA-20025`: Si el partido corresponde a una fase eliminatoria y se intenta registrar un empate (`p_goles_local = p_goles_visitante`).
  - `ORA-20022`: Si el partido no tiene asociadas exactamente dos participaciones (`LOCAL` y `VISITANTE`).
- **Comportamiento:**
  1. Actualiza `goles_marcados` en las dos filas de `participacion_partido`.
  2. Actualiza `asistencia_registrada` en `partido` asentando `NVL(p_asistencia, 0)`.
  3. Si la fase del partido es de tipo `'GRUPOS'`, invoca automáticamente `pr_actualizar_tabla_posiciones(v_id_edicion)` para mantener los puntajes al día.

**Ejemplo de uso:**

```sql
-- Partido 385 (Catar vs Ecuador en Fase de Grupos)
EXEC pr_registrar_resultado(385, 0, 2, 60000);
```

### 3. `pr_carga_masiva_resultados`

- **Entradas y salidas:**
  - `p_id_edicion IN NUMBER`: edición cuyos resultados pendientes se desean cargar.
  - `p_procesados OUT NUMBER`: total de registros examinados en el lote.
  - `p_exitosos OUT NUMBER`: cantidad de resultados procesados y asentados correctamente.
  - `p_fallidos OUT NUMBER`: cantidad de registros rechazados por inconsistencias de validación.
- **Comportamiento:**
  1. Lee las filas en estado `'PENDIENTE'` de `resultado_carga_temporal` mediante `LEFT JOIN` con `partido`, garantizando que registros con identificadores de partido inexistentes o inválidos no sean omitidos silenciosamente, sino procesados, capturados y marcados con estado `'ERROR'` y código `ORA-20021`.
  2. Para cada registro establece un `SAVEPOINT sp_resultado` e intenta registrar el marcador con `pr_registrar_resultado`.
  3. Si es exitoso, marca la fila como `'PROCESADO'`. Si falla alguna regla de negocio, realiza un rollback específico al savepoint, actualiza el registro con estado `'ERROR'` y guarda el mensaje descriptivo en `mensaje_error`.
  4. Al concluir el recorrido del cursor, refresca la tabla de posiciones con `pr_actualizar_tabla_posiciones`.

**Ejemplo de uso:**

```sql
DECLARE
    v_proc NUMBER;
    v_exit NUMBER;
    v_fall NUMBER;
BEGIN
    pr_carga_masiva_resultados(7, v_proc, v_exit, v_fall);
    DBMS_OUTPUT.PUT_LINE('Procesados: ' || v_proc || ' | Exitosos: ' || v_exit || ' | Fallidos: ' || v_fall);
END;
/
```

### 4. `pr_cierre_fase`

- **Entradas:**
  - `p_id_edicion NUMBER`: edición del torneo.
  - `p_id_fase NUMBER`: fase que se desea cerrar formalmente.
- **Validaciones aplicadas:**
  - `ORA-20026`: Si la fase no pertenece a la edición indicada.
  - `ORA-20027`: Si la fase no tiene partidos programados o si existen partidos sin asistencia/marcador registrado o sin sus 2 participaciones.
  - `ORA-20025`: Si existen empates no resueltos en partidos de eliminación directa.
- **Comportamiento:**
  - En fase eliminatoria: examina cada partido que posea un `id_partido_siguiente` configurado en el cuadro del torneo, determina la selección ganadora y genera su registro de participación en el partido siguiente (`LOCAL` si el cupo está libre, o `VISITANTE` en caso contrario).
  - En fase de grupos: ejecuta `pr_actualizar_tabla_posiciones` para dejar firme la tabla de posiciones definitiva de los grupos.

**Ejemplo de uso:**

```sql
-- Cierre de la fase de grupos (fase 37) en la edicion 7
EXEC pr_cierre_fase(7, 37);
```


## Triggers

Archivo: `sql/entrega3/triggers/triggers.sql`. Las pruebas de cada uno están en `tests/entrega3/pruebas_triggers.md`, con su captura.

Responsable: Laura Lesmes (`IS101007`).

Son los cuatro triggers obligatorios del enunciado.

| Trigger | Tabla | Momento | Nivel | Error que lanza |
|---|---|---|---|---|
| `trg_rangos_estadistica` | `estadistica_jugador_partido` | BEFORE INSERT o UPDATE | Fila | ORA-20001, ORA-20002 |
| `trg_antiduplicidad_participacion` | `participacion_partido` | BEFORE INSERT | Fila | ORA-20003 |
| `trg_auditoria_partido` y `trg_auditoria_estadistica` | `partido` y `estadistica_jugador_partido` | AFTER INSERT, UPDATE o DELETE | Fila | No lanza errores, escribe en `auditoria_evento` |
| `trg_consistencia_marcador` | `estadistica_jugador_partido` | AFTER INSERT o UPDATE de `goles` | Sentencia | ORA-20004 |

**Cómo ejecutar el archivo.** Se corre completo con "Ejecutar script". Las tablas se deben haber creado antes (DDL ampliado). Ojo: al inicio de la parte de auditoría el script hace `DROP TABLE auditoria_evento`, así que cada vez que se vuelve a correr, el historial de auditoría se reinicia. Si se vuelve a ejecutar el DDL de las 16 tablas, los triggers se borran junto con ellas y hay que volver a correr `triggers.sql`.

### 1. Validación de rangos — `trg_rangos_estadistica`

**Propósito.** Que un jugador no pueda tener goles ni asistencias negativos.

**Cuándo se dispara.** Antes de insertar o actualizar una fila de `estadistica_jugador_partido`.

**Entradas.** Los valores nuevos de `goles` y `asistencias` (`:NEW.goles`, `:NEW.asistencias`).

**Comportamiento.** Si `goles` es menor que cero cancela la operación con `ORA-20001: Los goles no pueden ser negativos`. Si `asistencias` es menor que cero, con `ORA-20002: Las asistencias no pueden ser negativas`. Si los valores son correctos, no hace nada y la fila se guarda.

**Ejemplo de uso:**

```sql
-- Goles negativos: debe fallar con ORA-20001
INSERT INTO estadistica_jugador_partido
  (id_estadistica, id_partido, id_jugador, titular, minutos_jugados, goles, asistencias, tarjetas_amarillas, tarjetas_rojas)
VALUES (99002, 5, 20, 1, 90, -1, 0, 0, 0);
ROLLBACK;
```

**Problemas previstos y cómo se previenen.**
- *La tabla ya tiene un CHECK para esto (`ck_estadistica_counters`).* Se dejó el trigger porque el enunciado lo pide y porque, al ejecutarse antes que el CHECK, da un mensaje propio y más claro. El CHECK queda como respaldo: si alguien deshabilita el trigger con `ALTER TRIGGER ... DISABLE`, los negativos se siguen rechazando. Además el CHECK cubre las tarjetas, que el trigger no revisa.
- *Valores nulos.* `goles` y `asistencias` son `NOT NULL` con valor por defecto 0, así que la comparación nunca recibe un nulo.

### 2. Anti-duplicidad — `trg_antiduplicidad_participacion`

**Propósito.** Evitar que una selección quede registrada dos veces en el mismo partido.

**Cuándo se dispara.** Antes de insertar una fila en `participacion_partido`.

**Entradas.** `:NEW.id_partido` y `:NEW.id_seleccion`.

**Comportamiento.** Cuenta cuántas participaciones existen ya con ese partido y esa selección. Si hay alguna, cancela con `ORA-20003: La seleccion ya participa en este partido`. Si no hay ninguna, deja pasar la fila.

**Ejemplo de uso:**

```sql
-- La seleccion 153 ya participa en el partido 274: debe fallar con ORA-20003
INSERT INTO participacion_partido
  (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99010, 274, 153, 'VISITANTE', 0);
ROLLBACK;
```

**Problemas previstos y cómo se previenen.**
- *Dos sesiones insertando al mismo tiempo.* Las dos podrían contar cero antes de que cualquiera guarde. La garantía final no es el trigger sino la restricción `uq_participacion_seleccion` (UNIQUE sobre `id_partido, id_seleccion`), que Oracle valida de forma segura entre sesiones y respondería con ORA-00001.
- *Tabla mutante (ORA-04091).* Un trigger por fila que consulta su propia tabla puede fallar cuando el INSERT afecta varias filas a la vez (visto en clase). En la prueba, con un INSERT de una sola fila, funcionó sin ese error. No se probó con inserciones de varias filas; en una carga masiva, la restricción UNIQUE sigue protegiendo aunque el trigger se deshabilite.
- *UPDATE.* El trigger solo vigila los INSERT. Si alguien cambia `id_seleccion` de una fila existente a una selección repetida, lo detiene la misma restricción UNIQUE.

### 3. Auditoría — `trg_auditoria_partido` y `trg_auditoria_estadistica`

**Propósito.** Dejar un registro de quién modificó partidos y estadísticas, cuándo y cómo cambió el dato.

**Tabla de apoyo: `auditoria_evento`.** Una fila por cada cambio.

| Columna | Qué guarda |
|---|---|
| `id_auditoria` | Número que Oracle asigna solo (llave primaria) |
| `tabla` | Tabla modificada (`PARTIDO` o `ESTADISTICA_JUGADOR_PARTIDO`) |
| `operacion` | `INSERT`, `UPDATE` o `DELETE` |
| `id_registro` | Llave de la fila afectada |
| `valor_anterior` y `valor_nuevo` | Valor antes y después (en `partido`, `asistencia_registrada`; en estadística, `goles`) |
| `usuario` | Usuario de Oracle que hizo el cambio (`USER`) |
| `fecha` | Fecha y hora del cambio (por defecto `SYSDATE`) |

**Cuándo se dispara.** Después de insertar, actualizar o borrar una fila en `partido` o en `estadistica_jugador_partido`.

**Entradas.** Los valores `:OLD` y `:NEW` de la fila y la función `USER`.

**Comportamiento.** Con `IF INSERTING / UPDATING / DELETING` decide qué anotar: en un INSERT no hay valor anterior, en un DELETE no hay valor nuevo. Nadie escribe en `auditoria_evento` a mano: la llenan los triggers.

**Ejemplo de uso:**

```sql
-- Cambiar la asistencia del partido 274 deja una fila en auditoria_evento
UPDATE partido SET asistencia_registrada = 12345 WHERE id_partido = 274;
SELECT tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario, fecha
FROM auditoria_evento;
ROLLBACK;
```

**Problemas previstos y cómo se previenen.**
- *Un cambio que se revierte no deja rastro.* El trigger es AFTER, así que solo registra lo que realmente se aplicó. Si una sentencia falla (por ejemplo, por el trigger de consistencia), Oracle la deshace junto con su registro. Es el comportamiento buscado, pero significa que los intentos fallidos no se auditan.
- *Crecimiento de la tabla y cargas masivas.* Cada fila modificada genera un registro. En una carga masiva conviene deshabilitar los triggers de auditoría y habilitarlos al terminar (`ALTER TRIGGER trg_auditoria_partido DISABLE`), o aceptar que la carga llene la tabla.
- *Borrado en cascada.* Al borrar un partido, Oracle borra sus estadísticas por `ON DELETE CASCADE`, y cada una de esas filas también queda registrada como `DELETE`.
- *Usuario de la aplicación.* `USER` devuelve el usuario de Oracle, y la aplicación se conecta siempre con la misma cuenta, así que todos los cambios hechos desde ella aparecerían con el mismo usuario. Una mejora posible es que la aplicación informe quién está usando el sistema.
- *Alcance.* Solo se audita una columna por tabla (`asistencia_registrada` y `goles`). Se puede ampliar agregando columnas a `auditoria_evento`.

### 4. Consistencia — `trg_consistencia_marcador`

**Propósito.** Que los goles individuales de los jugadores no contradigan el marcador oficial del partido.

**Cuándo se dispara.** Después de insertar una estadística o actualizar la columna `goles` de `estadistica_jugador_partido`. Es un trigger de sentencia (sin `FOR EACH ROW`).

**Entradas.** No usa `:NEW`: consulta las tablas `estadistica_jugador_partido`, `convocatoria_jugador` y `participacion_partido`.

**Comportamiento.** Suma los goles de los jugadores de cada selección en cada partido (uniendo la convocatoria para saber a qué selección pertenece el jugador) y los compara con `goles_marcados`. Si en algún partido la suma supera el marcador oficial, cancela con `ORA-20004: Los goles de los jugadores superan el marcador oficial`.

**Ejemplo de uso:**

```sql
-- 20 goles superan el marcador oficial: debe fallar con ORA-20004
UPDATE estadistica_jugador_partido SET goles = 20
WHERE id_estadistica = (SELECT MIN(id_estadistica) FROM estadistica_jugador_partido);
ROLLBACK;
```

**Decisiones y problemas previstos.**
- *Por qué de sentencia y no de fila.* Un trigger por fila no puede consultar la tabla que lo disparó (tabla mutante, ORA-04091). Al ser de sentencia, puede leer la tabla completa sin ese error.
- *"No supera" y no "es igual".* Mientras se cargan las estadísticas jugador por jugador, la suma está incompleta. Exigir igualdad bloquearía la carga. La igualdad exacta se verifica con la consulta avanzada 4 y puede revisarse en el procedimiento de cierre de fase.
- *Autogoles.* Se asume que `goles` cuenta solo los goles a favor del propio equipo. Un autogol suma al marcador del rival y no a los goles individuales del jugador; si se registrara como gol del jugador, el trigger podría dar un falso error.
- *Rendimiento.* La consulta revisa todos los partidos y no solo los afectados. Con los datos actuales (2048 estadísticas) es inmediata; con muchos más datos habría que limitarla a los partidos tocados por la sentencia, por ejemplo con un trigger compuesto.
- *Cambios en el marcador.* Si alguien baja `goles_marcados` en `participacion_partido` después de cargar estadísticas, este trigger no lo detecta (solo vigila cambios en estadísticas). Se podría cubrir con un trigger equivalente sobre `participacion_partido`.