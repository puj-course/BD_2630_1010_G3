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
