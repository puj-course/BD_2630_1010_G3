# Pruebas DML — Mundial FIFA (Entrega 1)

Evidencia de la ejecución de `sql/entrega1/dml/dml_ciclo_vida_partido.sql` contra el
esquema `IS101009` del servidor `orion.javeriana.edu.co` (service name `LAB`).

El script termina en `ROLLBACK`, así que no persiste nada y se puede volver a ejecutar
las veces que haga falta sin ensuciar los datos de prueba.

Fecha de ejecución: 20 de septiembre de 2026.

---

## 1. Flujo normal del ciclo de vida de un partido

| Paso | Operación | Resultado |
|---|---|---|
| 1 | `INSERT` del partido 9999 (edición 1, estadio 1, fase Final, asistencia `NULL`) | `1 row inserted.` |
| 2 | `INSERT` de la participación 99991 (selección 2, LOCAL, 0 goles) | `1 row inserted.` |
| 3 | `INSERT` de la participación 99992 (selección 25, VISITANTE, 0 goles) | `1 row inserted.` |
| 4 | `UPDATE` del marcador de la participación 99991 a 3 goles | `1 row updated.` |
| 5 | `UPDATE` del marcador de la participación 99992 a 0 goles | `1 row updated.` |
| 6 | `UPDATE` de la asistencia del partido 9999 a 80000 | `1 row updated.` |

El partido se crea sin marcador y sin asistencia. Ambos datos se conocen cuando el
partido termina, y por eso entran después con `UPDATE` y no en el `INSERT` inicial.

---

## 2. Intentos de operación inválida

Cada intento ataca una restricción distinta del DDL. Ninguno debe pasar.

### Intento 1 — Dos selecciones locales en el mismo partido

Operación:

```sql
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99993, 9999, 12, 'LOCAL', 1);
```

Resultado:

```
ORA-00001: unique constraint (IS101009.UQ_PARTICIPACION_CONDICION) violated
```

Qué demuestra: la restricción `UNIQUE (id_partido, condicion)` impide que un partido
tenga dos locales o dos visitantes. Un partido solo puede tener dos participaciones,
una por condición.

### Intento 2 — Goles negativos

Operación:

```sql
INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados)
VALUES (99994, 9999, 12, 'VISITANTE', -5);
```

Resultado:

```
ORA-02290: check constraint (IS101009.CK_PARTICIPACION_GOLES) violated
```

Qué demuestra: el `CHECK` sobre `goles_marcados` rechaza valores por debajo de cero.
No existe un marcador negativo.

### Intento 3 — Partido en una edición que no existe

Operación:

```sql
INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
VALUES (8888, 675, 1, TO_TIMESTAMP('1998-06-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Final', 40000);
```

Resultado:

```
ORA-02291: integrity constraint (IS101009.FK_PARTIDO_EDICION) violated - parent key not found
```

Qué demuestra: la llave foránea exige que la edición 675 exista antes de poder
referenciarla. Es integridad referencial: no hay partidos huérfanos.

### Intento 4 — Fase fuera de la lista permitida

Operación:

```sql
INSERT INTO partido (id_partido, id_edicion, id_estadio, fecha_hora, fase, asistencia_registrada)
VALUES (8887, 1, 1, TO_TIMESTAMP('1998-06-15 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Grupos', 40000);
```

Resultado:

```
ORA-02290: check constraint (IS101009.CK_PARTIDO_FASE) violated
```

Qué demuestra: el `CHECK` sobre `fase` acepta solo los valores de la lista del DDL.
`'Grupos'` no está en esa lista; el valor correcto es `'Fase de Grupos'`. La
restricción evita que el mismo concepto se guarde escrito de varias formas.

---

## 3. Comportamiento `ON DELETE` en dos relaciones distintas

### 3.1 `PARTIDO → PARTICIPACION_PARTIDO`: `ON DELETE CASCADE`

Operación y verificación ejecutadas en la misma sesión, con el partido 9999 ya creado
y con sus dos participaciones:

```sql
SELECT COUNT(*) FROM participacion_partido WHERE id_partido = 9999;   -- antes
DELETE FROM partido WHERE id_partido = 9999;
SELECT COUNT(*) FROM participacion_partido WHERE id_partido = 9999;   -- después
```

Resultado:

| Momento | Participaciones del partido 9999 |
|---|---|
| Antes del `DELETE` | 2 |
| Después del `DELETE` | 0 |

El `DELETE` sobre el partido reporta `1 row deleted.` y las dos participaciones
desaparecen solas, sin una sola sentencia que las borre.

Qué demuestra: una participación no tiene existencia propia. Solo significa algo
dentro de un partido, así que cuando el partido se va, ella se va con él. Es la única
relación del modelo con `CASCADE`.

### 3.2 `SELECCION → PARTICIPACION_PARTIDO`: restrictiva

Operación:

```sql
DELETE FROM seleccion WHERE id_seleccion = 1;
```

Resultado:

```
ORA-02292: integrity constraint (IS101009.FK_PARTICIPACION_SELECCION) violated - child record found
```

Qué demuestra: la selección 1 tiene participaciones registradas y Oracle no deja
borrarla. Aquí el `CASCADE` sería un error grave: borraría el historial de partidos de
esa selección. Al omitir la cláusula `ON DELETE`, Oracle aplica el comportamiento
restrictivo, que es el que se quiere. Para borrar la selección habría que borrar antes
sus participaciones, de forma deliberada.

---

## 4. Estado final

El script cierra con `ROLLBACK` y comprueba los conteos:

| Momento | Partidos | Participaciones |
|---|---|---|
| Tras el `ROLLBACK` | 448 | 896 |

Son las mismas cifras que carga `sql/entrega1/dml/carga_datos_prueba.sql`. La base
queda igual que antes de ejecutar las pruebas.
