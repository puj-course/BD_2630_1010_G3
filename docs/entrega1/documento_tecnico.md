# Documento Técnico — Entrega 1
## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

**Curso:** Bases de Datos — Pontificia Universidad Javeriana
**Grupo:** G3
**Alcance:** Modelo genérico inicial (5 entidades), según lo definido en la Sección 6 del enunciado del proyecto.

---

## 1. Descripción del problema y alcance del sistema

El presente proyecto tiene como propósito diseñar e implementar, sobre el motor Oracle, la primera fase de una base de datos relacional para la gestión de una edición de la Copa Mundial de la FIFA.

Esta entrega se desarrolla  a partir del modelo genérico inicial propuesto compuesto por cinco entidades: `EDICION_MUNDIAL`, `ESTADIO`, `SELECCION`, `PARTIDO` y `PARTICIPACION_PARTIDO`. El alcance de esta primera entrega cubre:

- El registro de distintas ediciones del torneo (año, país sede, fechas, lema).
- Los estadios asociados a cada edición (nombre, ciudad, capacidad).
- Las selecciones participantes en cada edición (país, confederación, grupo asignado).
- Los partidos programados dentro de una edición (fecha, hora, estadio, fase del torneo).
- La participación de cada selección en cada partido, registrando su condición
  (local/visitante) y los goles marcados.

No se incluyen en esta etapa jugadores, cuerpo técnico, árbitros, estadísticas individuales,
boletería, medios de comunicación ni incidencias operativas. Estos elementos, junto con la
expansión del modelo, se incorporarán en las Entregas 2 y 3 del proyecto, de acuerdo con el
análisis presentado en la Sección 8 (Evaluación Crítica) de este documento.

El sistema busca resolver, sobre este alcance reducido, necesidades reales de un organismo
deportivo: identificar qué selecciones han marcado más goles, calcular la ocupación de los
estadios, construir tablas de posiciones parciales, y garantizar la integridad de la información
de cada partido (por ejemplo, que un partido no quede con más de un local o más de un
visitante).

---

## 2. Supuestos de modelado adoptados por el equipo

1. **Cada partido debe tener exactamente dos participaciones asociadas** (una local, una visitante). Esta regla no puede garantizarse con una restricción `CHECK` simple en Oracle, ya que un `CHECK` solo puede evaluar la fila que se está insertando y no puede contar filas relacionadas en otra tabla. Por esta razón, la regla se controla parcialmente mediante restricciones `UNIQUE` (que impiden más de dos participaciones con la misma condición) y se verificará de forma completa mediante consultas de validación y, en entregas posteriores, mediante un trigger.

2. **Un registro de `ESTADIO` pertenece a una única edición.** Si el mismo estadio físico se usa en dos ediciones distintas del Mundial, se modela como dos registros distintos, uno por edición. Esta es una limitación reconocida del modelo inicial de 5 entidades, discutida en la Sección 8 (Evaluación Crítica).

3. **El atributo `fase` de `PARTIDO` es un valor controlado**, restringido mediante `CHECK` a una lista fija: Fase de Grupos, Dieciseisavos, Octavos, Cuartos, Semifinal, Tercer Puesto, Final.

4. **El atributo `condicion` de `PARTICIPACION_PARTIDO`** solo admite los valores `LOCAL` y `VISITANTE`, controlado mediante `CHECK`.

5. **Los goles marcados (`goles_marcados`) no pueden ser negativos** y se limitan a un rango de 0 a 15. Este tope no es arbitrario: corresponde a la mayor goleada individual registrada por una selección en la fase final de un Mundial (Hungría 10-1 sobre El Salvador, 1982), dejando margen suficiente y a la vez permitiendo detectar errores de digitación en los datos de prueba.

6. **Una selección no puede repetirse dos veces en el mismo partido con la misma condición** (por ejemplo, dos veces como local). Esto se garantiza con una restricción `UNIQUE` compuesta sobre `(id_partido, condicion)`, y de forma independiente se garantiza que una misma selección no aparezca dos veces en el mismo partido mediante `UNIQUE (id_partido, id_seleccion)`.

7. **El nombre de un país en `SELECCION.pais` puede repetirse entre ediciones distintas.** Por ejemplo, "Alemania" en la edición 2022 y "Alemania" en la edición 2026 son dos registros distintos e independientes, coherente con que `SELECCION` representa la participación de un país en una edición específica, no al país como entidad permanente. Por esta razón, la restricción de unicidad sobre `pais` es compuesta: `UNIQUE (id_edicion, pais)`.

8. **El campo `grupo` de `SELECCION` puede ser nulo**, para representar selecciones que aún no han sido asignadas a un grupo (por ejemplo, antes del sorteo) o que participan únicamente en fases eliminatorias. Cuando tiene valor, se restringe mediante una lista explícita de una sola letra (A a L) en lugar de un operador `BETWEEN`, porque `BETWEEN` sobre texto compara alfabéticamente y dejaría pasar valores inválidos como `'AB'` o `'Kansas'` por ubicarse alfabéticamente entre 'A' y 'L'.

9. **El campo `asistencia_registrada` de `PARTIDO` puede ser nulo**, ya que solo se conoce una vez el partido se ha jugado; los partidos aún no disputados no tienen este dato.

10. **Un estadio no puede tener dos partidos programados a la misma fecha y hora**, controlado mediante `UNIQUE (id_estadio, fecha_hora)`. Esto no impide que existan partidos simultáneos en la misma edición, siempre que se jueguen en estadios distintos.

11. **Una edición del Mundial debe durar al menos 7 días.** Un torneo de esta envergadura se disputa a lo largo de varias semanas, nunca en un solo día; esta restricción ayuda a detectar fechas de inicio o fin mal digitadas en los datos de prueba.

12. **Los campos de texto obligatorios no deben quedar en blanco.** Una restricción `NOT NULL` por sí sola no impide que alguien inserte una cadena compuesta solo de espacios (`'   '`), ya que técnicamente no es nula. Por eso se añadieron restricciones `CHECK (TRIM(columna) IS NOT NULL)` sobre los campos de texto más sensibles (`pais_sede`, `nombre` y `ciudad` de estadio, `pais` de selección), para exigir contenido real.

---

## 3. Diagrama Entidad-Relación (ERD)
"Respecto al modelo base el equipo decidió añadir dos atributos: grupo en SELECCION y asistencia_registrada en PARTIDO, esto se justifica porque se consideran necesarios para resolver consultas explícitamente pedidas en el enunciado, sin alterar la estructura de entidades ni relaciones del modelo original."



```mermaid
erDiagram
  EDICION_MUNDIAL ||--o{ ESTADIO : tiene
  EDICION_MUNDIAL ||--o{ SELECCION : convoca
  EDICION_MUNDIAL ||--o{ PARTIDO : programa
  ESTADIO ||--o{ PARTIDO : aloja
  PARTIDO ||--o{ PARTICIPACION_PARTIDO : registra
  SELECCION ||--o{ PARTICIPACION_PARTIDO : participa_en

  EDICION_MUNDIAL {
    NUMBER id_edicion PK
    NUMBER anio UK
    VARCHAR2 pais_sede
    VARCHAR2 lema "nulo permitido"
    DATE fecha_inicio
    DATE fecha_fin
  }
  ESTADIO {
    NUMBER id_estadio PK
    NUMBER id_edicion FK
    VARCHAR2 nombre
    VARCHAR2 ciudad
    NUMBER capacidad
  }
  SELECCION {
    NUMBER id_seleccion PK
    NUMBER id_edicion FK
    VARCHAR2 pais
    VARCHAR2 confederacion
    VARCHAR2 grupo "nulo permitido"
  }
  PARTIDO {
    NUMBER id_partido PK
    NUMBER id_edicion FK
    NUMBER id_estadio FK
    TIMESTAMP fecha_hora
    VARCHAR2 fase
    NUMBER asistencia_registrada "nulo permitido"
  }
  PARTICIPACION_PARTIDO {
    NUMBER id_participacion PK
    NUMBER id_partido FK
    NUMBER id_seleccion FK
    VARCHAR2 condicion
    NUMBER goles_marcados
  }
```

---

## 4. Transformación a modelo lógico relacional

### 4.1 Llaves primarias (PK)

Cada entidad utiliza un identificador artificial (*surrogate key*) de tipo `NUMBER(10)` en lugar de una llave natural (por ejemplo, el nombre del país o del estadio), porque los nombres pueden repetirse entre ediciones distintas (ver Supuesto 7) o pueden estar sujetos a cambios de
escritura. Esto garantiza estabilidad de la llave primaria a lo largo del ciclo de vida de los datos.

- **`EDICION_MUNDIAL.id_edicion`**: identifica cada edición del torneo de forma única.
- **`ESTADIO.id_estadio`**: identifica cada registro de estadio dentro de una edición (ver
  Supuesto 2 sobre la limitación de este enfoque).
- **`SELECCION.id_seleccion`**: identifica la participación de un país en una edición
  específica, no al país como entidad permanente.
- **`PARTIDO.id_partido`**: identifica cada encuentro del torneo.
- **`PARTICIPACION_PARTIDO.id_participacion`**: identifica cada fila de la entidad asociativa
  que resuelve la relación muchos a muchos entre `PARTIDO` y `SELECCION`.

### 4.2 Llaves foráneas (FK) y comportamiento ON DELETE / ON UPDATE

| Llave foránea | Referencia | ON DELETE | Justificación |
|---|---|---|---|
| `ESTADIO.id_edicion` | `EDICION_MUNDIAL(id_edicion)` | RESTRICT (comportamiento por defecto en Oracle) | No se debe poder eliminar una edición si ya tiene estadios registrados; se perdería información estructural del torneo. |
| `SELECCION.id_edicion` | `EDICION_MUNDIAL(id_edicion)` | RESTRICT (por defecto) | Una edición con selecciones ya registradas no debe poder eliminarse sin control explícito. |
| `PARTIDO.id_edicion` | `EDICION_MUNDIAL(id_edicion)` | RESTRICT (por defecto) | Un partido siempre debe pertenecer a una edición existente; no puede quedar huérfano. |
| `PARTIDO.id_estadio` | `ESTADIO(id_estadio)` | RESTRICT (por defecto) | Un estadio que ya tiene partidos programados no debe poder eliminarse, para no perder trazabilidad del calendario. |
| `PARTICIPACION_PARTIDO.id_partido` | `PARTIDO(id_partido)` | **CASCADE** | Una participación no tiene sentido sin su partido asociado: si el partido se elimina, sus dos participaciones (local y visitante) se eliminan automáticamente junto con él. |
| `PARTICIPACION_PARTIDO.id_seleccion` | `SELECCION(id_seleccion)` | RESTRICT (por defecto) | No se debe poder eliminar una selección que ya jugó partidos, porque se perdería el historial deportivo del torneo. Esta es una restricción explícita del enunciado del proyecto (Sección 8.1.2). |

Se utiliza `RESTRICT` (comportamiento por defecto de Oracle al no especificar `ON DELETE`) como
regla general del modelo, reservando `CASCADE` únicamente para la relación
`PARTICIPACION_PARTIDO → PARTIDO`, que es la única donde el registro hijo no tiene ningún
significado independiente de su padre.

### 4.3 Cardinalidades

- **`EDICION_MUNDIAL (1) — (N) ESTADIO`**: una edición tiene muchos estadios asociados; cada
  registro de estadio pertenece a exactamente una edición.
- **`EDICION_MUNDIAL (1) — (N) SELECCION`**: una edición convoca muchas selecciones; cada
  registro de selección pertenece a exactamente una edición.
- **`EDICION_MUNDIAL (1) — (N) PARTIDO`**: una edición programa muchos partidos.
- **`ESTADIO (1) — (N) PARTIDO`**: un estadio aloja muchos partidos dentro de la misma edición.
- **`PARTIDO (1) — (N) PARTICIPACION_PARTIDO`**: cada partido tiene, por regla de negocio,
  exactamente dos participaciones (ver Supuesto 1).
- **`SELECCION (1) — (N) PARTICIPACION_PARTIDO`**: una selección participa en muchos partidos
  a lo largo del torneo.

La relación real de muchos a muchos entre `PARTIDO` y `SELECCION` (un partido involucra dos
selecciones; una selección juega muchos partidos) se resuelve mediante la entidad asociativa
`PARTICIPACION_PARTIDO`, que además almacena los atributos propios de esa relación (condición y
goles marcados).

---

## 5. Diccionario de datos

### EDICION_MUNDIAL

| Atributo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| id_edicion | NUMBER(10) | PK, NOT NULL | Identificador único de la edición del Mundial. |
| anio | NUMBER(4) | UNIQUE, NOT NULL, CHECK entre 1930 y 2100 | Año de realización; no pueden existir dos ediciones en el mismo año. El rango inicia en 1930, año del primer Mundial disputado. |
| pais_sede | VARCHAR2(100) | NOT NULL, CHECK TRIM no vacío | País o países organizadores de la edición. |
| lema | VARCHAR2(200) | NULL permitido | Lema oficial del torneo; se permite nulo porque no todas las ediciones tienen este dato documentado. |
| fecha_inicio | DATE | NOT NULL | Fecha de inicio del torneo. |
| fecha_fin | DATE | NOT NULL, CHECK fecha_fin > fecha_inicio, CHECK duración ≥ 7 días | Fecha de finalización del torneo; debe ser posterior a la fecha de inicio y la edición debe durar al menos una semana. |

### ESTADIO

| Atributo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| id_estadio | NUMBER(10) | PK, NOT NULL | Identificador único del registro de estadio. |
| id_edicion | NUMBER(10) | FK → EDICION_MUNDIAL, NOT NULL | Edición a la que pertenece este registro de estadio. |
| nombre | VARCHAR2(150) | NOT NULL, UNIQUE compuesto (id_edicion, nombre), CHECK TRIM no vacío | Nombre del estadio; no pueden existir dos estadios con el mismo nombre dentro de la misma edición. |
| ciudad | VARCHAR2(100) | NOT NULL, CHECK TRIM no vacío | Ciudad donde se ubica el estadio. |
| capacidad | NUMBER(10) | NOT NULL, CHECK entre 20.000 y 150.000 | Aforo máximo del estadio; el rango corresponde a capacidades reales de estadios usados en Mundiales. |

### SELECCION

| Atributo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| id_seleccion | NUMBER(10) | PK, NOT NULL | Identificador único de la participación de una selección en una edición. |
| id_edicion | NUMBER(10) | FK → EDICION_MUNDIAL, NOT NULL | Edición en la que participa esta selección. |
| pais | VARCHAR2(100) | NOT NULL, UNIQUE compuesto (id_edicion, pais), CHECK TRIM no vacío | País que representa la selección; un mismo país solo puede aparecer una vez por edición. |
| confederacion | VARCHAR2(50) | NOT NULL, CHECK IN ('CONMEBOL','UEFA','CAF','AFC','CONCACAF','OFC') | Confederación a la que pertenece, limitada a las seis confederaciones oficiales de la FIFA. |
| grupo | VARCHAR2(1) | NULL permitido, CHECK IN ('A','B','C','D','E','F','G','H','I','J','K','L') | Grupo asignado en la fase de grupos; nulo si aún no se ha realizado el sorteo. Se usa una lista explícita de valores (no BETWEEN) porque sobre texto BETWEEN compara alfabéticamente y dejaría pasar valores inválidos. |

### PARTIDO

| Atributo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| id_partido | NUMBER(10) | PK, NOT NULL | Identificador único del partido. |
| id_edicion | NUMBER(10) | FK → EDICION_MUNDIAL, NOT NULL | Edición a la que pertenece el partido. |
| id_estadio | NUMBER(10) | FK → ESTADIO, NOT NULL | Estadio donde se juega el partido. |
| fecha_hora | TIMESTAMP | NOT NULL, UNIQUE compuesto (id_estadio, fecha_hora) | Fecha y hora del partido; un mismo estadio no puede tener dos partidos a la misma hora (no impide partidos simultáneos en estadios distintos). |
| fase | VARCHAR2(50) | NOT NULL, CHECK IN lista de fases | Fase del torneo a la que corresponde el partido (Fase de Grupos, Dieciseisavos, Octavos, Cuartos, Semifinal, Tercer Puesto, Final). |
| asistencia_registrada | NUMBER(10) | NULL permitido, CHECK ≥ 0 | Número de espectadores registrados; nulo hasta que el partido se dispute. |

### PARTICIPACION_PARTIDO

| Atributo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| id_participacion | NUMBER(10) | PK, NOT NULL | Identificador único de la participación. |
| id_partido | NUMBER(10) | FK → PARTIDO, ON DELETE CASCADE, NOT NULL | Partido al que corresponde esta participación. |
| id_seleccion | NUMBER(10) | FK → SELECCION, NOT NULL | Selección que participa en el partido. |
| condicion | VARCHAR2(20) | NOT NULL, CHECK IN ('LOCAL','VISITANTE') | Rol de la selección en el partido. |
| goles_marcados | NUMBER(3) | NOT NULL, DEFAULT 0, CHECK entre 0 y 15 | Goles anotados por esta selección en este partido. El tope de 15 se basa en la mayor goleada real registrada en un Mundial (Hungría 10-1 El Salvador, 1982). |

**Restricciones de unicidad compuesta adicionales**:

- `UNIQUE (id_partido, id_seleccion)`: una selección no puede aparecer dos veces en el mismo
  partido.
- `UNIQUE (id_partido, condicion)`: un partido no puede tener dos locales ni dos visitantes.

**Índices adicionales:** se crearon índices sobre `PARTIDO.id_edicion` y
`PARTICIPACION_PARTIDO.id_seleccion`, ya que Oracle no genera automáticamente un índice para las llaves foráneas (solo para PK y restricciones UNIQUE), y estas dos columnas se usan frecuentemente en las condiciones `JOIN` de las consultas del proyecto.

**Reglas de negocio no implementables mediante CHECK:** dado que una restricción `CHECK` en Oracle solo puede evaluar los valores de la fila que se está insertando (no puede consultar otras tablas ni contar filas relacionadas), las siguientes reglas quedan documentadas para verificarse mediante consultas de validación y, en la Entrega 3, mediante triggers:

1. Todo partido debe tener exactamente dos participaciones asociadas (las restricciones
   `UNIQUE` garantizan que no haya más de dos, pero no obligan a que existan exactamente dos).
2. La fecha y hora de un partido debe estar dentro del rango `fecha_inicio`–`fecha_fin` de su
   edición correspondiente.
3. El estadio asignado a un partido debe pertenecer a la misma edición del partido.
4. Las dos selecciones que participan en un partido deben pertenecer a la misma edición del
   partido.
5. Cada grupo de la fase inicial debe tener exactamente 4 selecciones asignadas (exige contar
   filas relacionadas, algo que un CHECK no puede hacer).
6. La asistencia registrada de un partido no puede superar la capacidad de su estadio (el
   aforo está en otra tabla, y un CHECK no puede consultarla).
7. Una misma selección no puede tener dos partidos programados a la misma fecha y hora (exige
   comparar filas entre sí).
8. En fase eliminatoria no puede haber empate: el resultado siempre debe definir un ganador
   (exige comparar las dos participaciones de un mismo partido entre sí).
