# Diccionario de datos ampliado - Entrega 2

## 1. Propósito y convenciones

Este documento describe las columnas de las 16 tablas del modelo ampliado, con los mismos tipos, valores por defecto y restricciones del DDL.

| Abreviatura | Significado |
|---|---|
| PK | Llave primaria |
| FK | Llave foránea; se indica la tabla y columna a la que apunta |
| UNIQUE | No se puede repetir; si son varias columnas, se nombran todas |
| NOT NULL | Valor obligatorio |
| CHECK | Condición que Oracle valida al insertar o actualizar |
| DEFAULT | Valor que toma la columna si el `INSERT` no la incluye |
| ON DELETE CASCADE | Al borrar la fila padre, se borran también sus filas hijas |
| Nulo permitido | La columna puede quedar vacía |

## 2. Diccionario por tabla

### 2.1. EDICION_MUNDIAL

Representa una edición de la Copa Mundial.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_edicion` | `NUMBER(10)` | PK, NOT NULL | Identificador único de la edición. |
| `anio` | `NUMBER(4)` | NOT NULL, UNIQUE (`uq_edicion_anio`), CHECK 1930–2100 (`ck_edicion_anio`) | Año de realización de la edición. |
| `lema` | `VARCHAR2(200)` | Nulo permitido | Lema asociado al torneo, si está documentado. |
| `fecha_inicio` | `DATE` | NOT NULL | Fecha de inicio de la edición. |
| `fecha_fin` | `DATE` | NOT NULL, CHECK posterior a inicio (`ck_edicion_fechas`), duración mínima de 7 días (`ck_edicion_duracion`) | Fecha de finalización; debe ser posterior al inicio y la diferencia entre fechas debe ser de al menos siete días. |

### 2.2. SEDE

Representa un país anfitrión dentro de una edición.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_sede` | `NUMBER(10)` | PK, NOT NULL | Identificador único del registro de sede. |
| `id_edicion` | `NUMBER(10)` | FK → `EDICION_MUNDIAL.id_edicion`, NOT NULL | Edición a la que pertenece la sede. |
| `pais` | `VARCHAR2(100)` | NOT NULL, UNIQUE compuesto (`id_edicion`, `pais`; `uq_sede_pais`), CHECK texto no vacío (`ck_sede_pais`) | País anfitrión. No se repite para una misma edición. |

### 2.3. CIUDAD

Representa una ciudad anfitriona perteneciente a una sede.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_ciudad` | `NUMBER(10)` | PK, NOT NULL | Identificador único de la ciudad. |
| `id_sede` | `NUMBER(10)` | FK → `SEDE.id_sede`, NOT NULL | Sede a la que pertenece la ciudad. |
| `nombre` | `VARCHAR2(100)` | NOT NULL, UNIQUE compuesto (`id_sede`, `nombre`; `uq_ciudad_nombre`), CHECK texto no vacío (`ck_ciudad_nombre`) | Nombre de la ciudad; no se repite dentro de una misma sede. |

### 2.4. ESTADIO

Representa un estadio ubicado en una ciudad.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_estadio` | `NUMBER(10)` | PK, NOT NULL | Identificador único del estadio. |
| `id_ciudad` | `NUMBER(10)` | FK → `CIUDAD.id_ciudad`, NOT NULL | Ciudad donde se ubica el estadio. |
| `nombre` | `VARCHAR2(150)` | NOT NULL, UNIQUE compuesto (`id_ciudad`, `nombre`; `uq_estadio_nombre`), CHECK texto no vacío (`ck_estadio_nombre`) | Nombre del estadio; no se repite dentro de una misma ciudad. |
| `capacidad` | `NUMBER(10)` | NOT NULL, CHECK entre 20 000 y 150 000 (`ck_estadio_capacidad`) | Aforo máximo definido para el estadio. |

### 2.5. FASE

Representa una etapa de una edición del torneo.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_fase` | `NUMBER(10)` | PK, NOT NULL | Identificador único de la fase. |
| `id_edicion` | `NUMBER(10)` | FK → `EDICION_MUNDIAL.id_edicion`, NOT NULL | Edición a la que pertenece la fase. |
| `nombre` | `VARCHAR2(50)` | NOT NULL, UNIQUE compuesto (`id_edicion`, `nombre`; `uq_fase_nombre`), CHECK lista de fases (`ck_fase_nombre`) | Fase: Fase de Grupos, Dieciseisavos, Octavos, Cuartos, Semifinal, Tercer Puesto o Final. |
| `orden_fase` | `NUMBER(2)` | NOT NULL, UNIQUE compuesto (`id_edicion`, `orden_fase`; `uq_fase_orden`), CHECK ≥ 1 (`ck_fase_orden`) | Orden cronológico/deportivo de la fase dentro de la edición. |
| `tipo` | `VARCHAR2(20)` | NOT NULL, CHECK en `GRUPOS`/`ELIMINATORIA` (`ck_fase_tipo`) | Clasificación de la fase como grupos o eliminatoria. |

### 2.6. GRUPO

Representa un grupo asociado a una fase.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_grupo` | `NUMBER(10)` | PK, NOT NULL | Identificador único del grupo. |
| `id_fase` | `NUMBER(10)` | FK → `FASE.id_fase`, NOT NULL | Fase a la que pertenece el grupo. |
| `nombre` | `VARCHAR2(1)` | NOT NULL, UNIQUE compuesto (`id_fase`, `nombre`; `uq_grupo_nombre`), CHECK A–L (`ck_grupo_nombre`) | Letra identificadora del grupo, única dentro de la fase. |

### 2.7. SELECCION

Representa una selección nacional participante en una edición.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_seleccion` | `NUMBER(10)` | PK, NOT NULL | Identificador de la selección. |
| `id_edicion` | `NUMBER(10)` | FK → `EDICION_MUNDIAL.id_edicion`, NOT NULL | Edición en la que participa la selección. |
| `id_grupo` | `NUMBER(10)` | FK → `GRUPO.id_grupo`, nulo permitido | Grupo asociado a la selección; puede quedar sin asignación. |
| `pais` | `VARCHAR2(100)` | NOT NULL, UNIQUE compuesto (`id_edicion`, `pais`; `uq_seleccion_pais`), CHECK texto no vacío (`ck_seleccion_pais`) | País representado; no se repite dentro de la misma edición. |
| `confederacion` | `VARCHAR2(50)` | NOT NULL, CHECK en `CONMEBOL`, `UEFA`, `CAF`, `AFC`, `CONCACAF`, `OFC` (`ck_seleccion_confederacion`) | Confederación a la que pertenece la selección. |

### 2.8. PARTIDO

Representa un encuentro de una edición.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_partido` | `NUMBER(10)` | PK, NOT NULL | Identificador único del partido. |
| `id_edicion` | `NUMBER(10)` | FK → `EDICION_MUNDIAL.id_edicion`, NOT NULL | Edición a la que pertenece el partido. |
| `id_fase` | `NUMBER(10)` | FK → `FASE.id_fase`, NOT NULL | Fase en que se disputa. |
| `id_estadio` | `NUMBER(10)` | FK → `ESTADIO.id_estadio`, NOT NULL | Estadio donde se disputa. |
| `id_partido_siguiente` | `NUMBER(10)` | FK autorreferenciada → `PARTIDO.id_partido`, nulo permitido | Partido posterior al que puede avanzar el ganador en el cuadro eliminatorio. |
| `fecha_hora` | `TIMESTAMP` | NOT NULL, UNIQUE compuesto (`id_estadio`, `fecha_hora`; `uq_partido_agenda`) | Fecha y hora programada; un estadio no puede tener dos partidos con la misma fecha y hora. |
| `asistencia_registrada` | `NUMBER(10)` | Nulo permitido, CHECK ≥ 0 (`ck_partido_asistencia`) | Número de espectadores; puede ser nulo antes del partido y no admite valores negativos. |

### 2.9. PARTICIPACION_PARTIDO

Relaciona una selección con un partido y registra su condición y goles.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_participacion` | `NUMBER(10)` | PK, NOT NULL | Identificador de la participación. |
| `id_partido` | `NUMBER(10)` | FK → `PARTIDO.id_partido`, NOT NULL, ON DELETE CASCADE (`fk_participacion_partido`) | Partido al que corresponde la participación; se elimina con el partido. |
| `id_seleccion` | `NUMBER(10)` | FK → `SELECCION.id_seleccion`, NOT NULL | Selección que participa. |
| `condicion` | `VARCHAR2(20)` | NOT NULL, CHECK `LOCAL`/`VISITANTE` (`ck_participacion_condicion`), UNIQUE compuesto (`id_partido`, `condicion`; `uq_participacion_condicion`) | Condición de la selección; solo puede existir una participación local y una visitante por partido. |
| `goles_marcados` | `NUMBER(3)` | NOT NULL, DEFAULT 0, CHECK 0–15 (`ck_participacion_goles`) | Cantidad de goles marcados por la selección en el partido. |

**Restricción adicional de tabla:** `uq_participacion_seleccion` establece UNIQUE sobre (`id_partido`, `id_seleccion`), por lo que una selección no puede registrarse dos veces en el mismo partido.

### 2.10. JUGADOR

Contiene la ficha básica de un jugador.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_jugador` | `NUMBER(10)` | PK, NOT NULL | Identificador único del jugador. |
| `nombre` | `VARCHAR2(150)` | NOT NULL, CHECK texto no vacío (`ck_jugador_nombre`) | Nombre registrado del jugador. |
| `posicion` | `VARCHAR2(20)` | NOT NULL, CHECK `Arquero`/`Defensa`/`Volante`/`Delantero` (`ck_jugador_posicion`) | Posición principal. |
| `club` | `VARCHAR2(150)` | Nulo permitido | Club al que pertenece o pertenecía, si se conoce. |

### 2.11. CONVOCATORIA_JUGADOR

Asocia un jugador con una selección convocante.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_convocatoria` | `NUMBER(10)` | PK, NOT NULL | Identificador de la convocatoria individual. |
| `id_jugador` | `NUMBER(10)` | FK → `JUGADOR.id_jugador`, NOT NULL | Jugador convocado. |
| `id_seleccion` | `NUMBER(10)` | FK → `SELECCION.id_seleccion`, NOT NULL | Selección que convoca al jugador. |
| `numero_camiseta` | `NUMBER(3)` | NOT NULL, CHECK 1–26 (`ck_convocatoria_numero`) | Número de camiseta dentro de la selección. |
| `es_capitan` | `NUMBER(1)` | NOT NULL, DEFAULT 0, CHECK 0/1 (`ck_convocatoria_capitan`) | Indicador numérico de capitanía: 1 sí, 0 no. |

**Restricciones adicionales de tabla:** `uq_convocatoria_jugador` impide repetir el mismo jugador en la misma selección (UNIQUE sobre `id_jugador`, `id_seleccion`). `uq_convocatoria_numero` impide repetir un número de camiseta dentro de la selección (UNIQUE sobre `id_seleccion`, `numero_camiseta`).

### 2.12. CUERPO_TECNICO

Registra integrantes del cuerpo técnico de una selección.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_cuerpo_tecnico` | `NUMBER(10)` | PK, NOT NULL | Identificador del integrante. |
| `id_seleccion` | `NUMBER(10)` | FK → `SELECCION.id_seleccion`, NOT NULL | Selección a la que pertenece. |
| `nombre` | `VARCHAR2(150)` | NOT NULL, CHECK texto no vacío (`ck_cuerpo_tecnico_nombre`) | Nombre del integrante. |
| `cargo` | `VARCHAR2(50)` | NOT NULL, CHECK lista de cargos (`ck_cuerpo_tecnico_cargo`) | Cargo: Director tecnico, Asistente tecnico, Preparador fisico, Entrenador de porteros o Medico. |

### 2.13. ARBITRO

Contiene información básica de un árbitro.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_arbitro` | `NUMBER(10)` | PK, NOT NULL | Identificador único del árbitro. |
| `nombre` | `VARCHAR2(150)` | NOT NULL, CHECK texto no vacío (`ck_arbitro_nombre`) | Nombre registrado del árbitro. |
| `nacionalidad` | `VARCHAR2(100)` | NOT NULL, CHECK texto no vacío (`ck_arbitro_nacionalidad`) | Nacionalidad del árbitro. |

### 2.14. ASIGNACION_ARBITRAL

Relaciona un árbitro con un partido y define el rol arbitral.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_asignacion` | `NUMBER(10)` | PK, NOT NULL | Identificador de la asignación. |
| `id_partido` | `NUMBER(10)` | FK → `PARTIDO.id_partido`, NOT NULL, ON DELETE CASCADE (`fk_asignacion_partido`) | Partido asignado; la asignación se elimina con el partido. |
| `id_arbitro` | `NUMBER(10)` | FK → `ARBITRO.id_arbitro`, NOT NULL | Árbitro asignado. |
| `rol` | `VARCHAR2(30)` | NOT NULL, CHECK lista de roles (`ck_asignacion_rol`) | Función: Principal, Asistente 1, Asistente 2, Cuarto arbitro, VAR o AVAR. |

**Restricción adicional de tabla:** `uq_asignacion_arbitro` establece UNIQUE sobre (`id_partido`, `id_arbitro`), de modo que el mismo árbitro no puede tener dos asignaciones en un partido. 

### 2.15. ESTADISTICA_JUGADOR_PARTIDO

Registra estadísticas individuales de un jugador en un partido.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_estadistica` | `NUMBER(10)` | PK, NOT NULL | Identificador del registro estadístico. |
| `id_partido` | `NUMBER(10)` | FK → `PARTIDO.id_partido`, NOT NULL, ON DELETE CASCADE (`fk_estadistica_partido`) | Partido asociado; el registro se elimina con el partido. |
| `id_jugador` | `NUMBER(10)` | FK → `JUGADOR.id_jugador`, NOT NULL | Jugador asociado. |
| `titular` | `NUMBER(1)` | NOT NULL, CHECK 0/1 (`ck_estadistica_titular`) | Indica si inició el partido: 1 sí, 0 no. |
| `minuto_entrada` | `NUMBER(3)` | Nulo permitido, CHECK 0–120 cuando se informa (`ck_estadistica_entradas_rango`), coherencia con titular (`ck_estadistica_entradas`) | Minuto de ingreso; obligatorio para quien no fue titular y nulo para quien inició el partido. |
| `minuto_salida` | `NUMBER(3)` | Nulo permitido, CHECK 0–120 cuando se informa (`ck_estadistica_entradas_rango`) | Minuto en que salió del partido, si aplica. |
| `minutos_jugados` | `NUMBER(3)` | NOT NULL, CHECK 0–120 (`ck_estadistica_minutos`) | Total de minutos jugados registrados. |
| `goles` | `NUMBER(3)` | NOT NULL, DEFAULT 0, CHECK ≥ 0 (`ck_estadistica_counters`) | Goles anotados por el jugador. |
| `asistencias` | `NUMBER(3)` | NOT NULL, DEFAULT 0, CHECK ≥ 0 (`ck_estadistica_counters`) | Asistencias registradas. |
| `tarjetas_amarillas` | `NUMBER(2)` | NOT NULL, DEFAULT 0, CHECK ≥ 0 (`ck_estadistica_counters`) | Tarjetas amarillas recibidas. |
| `tarjetas_rojas` | `NUMBER(2)` | NOT NULL, DEFAULT 0, CHECK ≥ 0 (`ck_estadistica_counters`) | Tarjetas rojas recibidas. |

**Restricción adicional de tabla:** `uq_estadistica_jugador` impide dos registros estadísticos para el mismo jugador en un partido (UNIQUE sobre `id_partido`, `id_jugador`).

### 2.16. INCIDENCIA

Registra un evento relevante ocurrido durante un partido.

| Atributo | Tipo Oracle | Restricciones | Descripción |
|---|---|---|---|
| `id_incidencia` | `NUMBER(10)` | PK, NOT NULL | Identificador único de la incidencia. |
| `id_partido` | `NUMBER(10)` | FK → `PARTIDO.id_partido`, NOT NULL, ON DELETE CASCADE (`fk_incidencia_partido`) | Partido donde ocurrió el evento; la incidencia se elimina con el partido. |
| `tipo` | `VARCHAR2(20)` | NOT NULL, CHECK en TARJETA/LESION/VAR/INVASION/SUSPENSION/OTRO (`ck_incidencia_tipo`) | Categoría de la incidencia. |
| `minuto` | `NUMBER(3)` | NOT NULL, CHECK 0–120 (`ck_incidencia_minuto`) | Minuto aproximado del evento. |
| `descripcion` | `VARCHAR2(300)` | Nulo permitido | Descripción complementaria del evento. |

## 3. Reglas que no se pueden poner como CHECK

El DDL documenta reglas que requieren validaciones adicionales, por ejemplo mediante triggers, procedimientos o casos de prueba:

1. La asistencia del partido no debe superar la capacidad del estadio.
2. La fecha del partido debe pertenecer al rango de fechas de la edición asociada.
3. El estadio, la fase y las selecciones asociadas a un partido deben corresponder a la misma edición.
4. Cada partido debe tener exactamente dos participaciones: una local y una visitante. Las restricciones `UNIQUE` limitan los duplicados, pero no obligan a que existan dos filas.
5. Cada grupo debe tener exactamente cuatro selecciones.
6. Una selección y un árbitro no deben tener partidos simultáneos.
7. Las estadísticas de un jugador deben corresponder a una convocatoria y a una selección participante del partido.
8. La suma de goles individuales debe coincidir con los goles de la selección en `PARTICIPACION_PARTIDO`.
9. El partido siguiente debe corresponder a la misma edición y una fase posterior cuando se use la progresión eliminatoria.
10. Una selección no puede tener más de 26 jugadores convocados.
11. En fase eliminatoria un partido no puede terminar empatado.

## 4. Observaciones 

El diccionario usa los nombres del DDL. El diseño conceptual de cada tabla está en `docs/entrega2/modelo_logico.md`.
