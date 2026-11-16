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
  3. Consulta mediante CTE (`resultados` y `acumulado`) todas las selecciones participantes con grupo asignado en la fase `'GRUPOS'` de esa edición.
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
  - `p_goles_local NUMBER`: goles marcados por la selección local (0 a 15).
  - `p_goles_visitante NUMBER`: goles marcados por la selección visitante (0 a 15).
  - `p_asistencia NUMBER`: cantidad de espectadores presentes en el estadio (opcional, no negativo).
- **Validaciones aplicadas:**
  - `ORA-20021`: Si el partido no existe en la base de datos.
  - `ORA-20023`: Si los goles del local o visitante están fuera del rango válido (0 a 15, alineado con `ck_participacion_goles`).
  - `ORA-20024`: Si la asistencia es negativa o supera la capacidad máxima del estadio donde se disputa el partido.
  - `ORA-20025`: Si el partido corresponde a una fase eliminatoria y se intenta registrar un empate (`p_goles_local = p_goles_visitante`).
  - `ORA-20022`: Si el partido no tiene asociadas exactamente dos participaciones (`LOCAL` y `VISITANTE`).
- **Comportamiento:**
  1. Actualiza `goles_marcados` en las dos filas de `participacion_partido`.
  2. Actualiza `asistencia_registrada` en `partido`.
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
  1. Lee las filas en estado `'PENDIENTE'` de `resultado_carga_temporal` correspondientes a la edición.
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

