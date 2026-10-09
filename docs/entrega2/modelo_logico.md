# Modelo Lógico Ampliado - Entrega 2

## Sistema de Información para la Gestión Integral de la Copa Mundial de la FIFA

## 1. Objetivo

El modelo lógico ampliado extiende el modelo inicial desarrollado en la Entrega 1
para representar de manera más completa la organización, competencia deportiva,
participación de selecciones y jugadores, arbitraje, estadísticas e incidencias
de una edición de la Copa Mundial.

El modelo busca mantener una estructura relacional normalizada hasta Tercera
Forma Normal (3FN), evitando la duplicación de información y permitiendo
consultas analíticas por jugador, partido, selección, grupo, fase y edición.

La propuesta está compuesta por 16 tablas.

---

# 2. Tablas del modelo

## 2.1. EDICION_MUNDIAL

Representa una edición particular de la Copa Mundial.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_edicion | Identificador único de la edición | PK |
| anio | Año de realización del torneo | UNIQUE |
| lema | Lema asociado a la edición | |
| fecha_inicio | Fecha de inicio del torneo | |
| fecha_fin | Fecha de finalización del torneo | |

### Relaciones

- Una edición puede tener una o varias sedes.
- Una edición puede tener múltiples fases.
- Una edición puede tener múltiples selecciones.
- Una edición puede tener múltiples partidos.

---

## 2.2. SEDE

Representa un país anfitrión dentro de una edición del Mundial.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_sede | Identificador único de la sede | PK |
| id_edicion | Edición a la que pertenece | FK |
| pais | País anfitrión | |

### Restricciones

- Una misma edición no debe registrar dos veces el mismo país como sede.

### Relación

- Una edición puede tener múltiples sedes.
- Una sede pertenece a una única edición.

---

## 2.3. CIUDAD

Representa una ciudad perteneciente a una sede de una edición.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_ciudad | Identificador único de la ciudad | PK |
| id_sede | Sede a la que pertenece | FK |
| nombre | Nombre de la ciudad | |

### Relación

- Una sede puede contener múltiples ciudades.
- Una ciudad pertenece a una única sede.

---

## 2.4. ESTADIO

Representa un estadio utilizado durante el torneo.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_estadio | Identificador único del estadio | PK |
| id_ciudad | Ciudad donde se encuentra | FK |
| nombre | Nombre del estadio | |
| capacidad | Capacidad máxima del estadio | |

### Restricciones

- La capacidad debe ser mayor que cero.
- Un estadio pertenece a una única ciudad.

### Relación

- Una ciudad puede tener uno o varios estadios.
- Un estadio puede alojar múltiples partidos.

---

# 3. Competencia deportiva

## 3.1. FASE

Representa una etapa del torneo.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_fase | Identificador de la fase | PK |
| id_edicion | Edición a la que pertenece | FK |
| nombre | Nombre de la fase | |
| orden_fase | Orden cronológico/deportivo de la fase | |
| tipo | Tipo de fase | |

### Ejemplos de fases

- Fase de grupos
- Dieciseisavos
- Octavos
- Cuartos
- Semifinal
- Tercer puesto
- Final

### Restricciones

- `orden_fase` debe ser positivo.
- Una fase pertenece a una única edición.

### Relación

- Una edición contiene múltiples fases.
- Una fase contiene múltiples partidos.
- Una fase de grupos puede contener múltiples grupos.

---

## 3.2. GRUPO

Representa un grupo de la fase correspondiente.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_grupo | Identificador único del grupo | PK |
| id_fase | Fase a la que pertenece | FK |
| nombre | Identificador del grupo, por ejemplo A, B o C | |

### Restricciones

- Un grupo pertenece a una única fase.
- El nombre del grupo debe ser único dentro de la fase.

### Relación

- Una fase puede tener múltiples grupos.
- Un grupo puede estar asociado a múltiples selecciones.

---

## 3.3. SELECCION

Representa una selección nacional participante en una edición.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_seleccion | Identificador único de la participación de la selección | PK |
| id_edicion | Edición en la que participa | FK |
| id_grupo | Grupo al que pertenece durante la fase de grupos | FK |
| pais | País representado | |
| confederacion | Confederación a la que pertenece | |

### Restricciones

- Una selección debe pertenecer a una edición.
- Una selección no debe aparecer dos veces en la misma edición.
- `id_grupo` puede ser nulo para selecciones cuando ya se encuentran
  exclusivamente en fases eliminatorias.

### Relación

- Una edición tiene múltiples selecciones.
- Una selección puede pertenecer a un grupo.
- Una selección participa en múltiples partidos.
- Una selección puede tener múltiples jugadores convocados.
- Una selección puede tener múltiples integrantes de cuerpo técnico.

---

## 3.4. PARTIDO

Representa un partido disputado durante una edición.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_partido | Identificador único del partido | PK |
| id_edicion | Edición del partido | FK |
| id_fase | Fase en la que se disputa | FK |
| id_estadio | Estadio donde se disputa | FK |
| id_partido_siguiente | Partido al que puede alimentar en la fase eliminatoria | FK, autorreferencia |
| fecha_hora | Fecha y hora programada | |
| asistencia_registrada | Número de espectadores registrados | |

### Restricciones

- El partido debe pertenecer a la misma edición que su fase y estadio.
- La asistencia no puede ser negativa.
- La asistencia no debe superar la capacidad del estadio.
- `id_partido_siguiente` es opcional y se utiliza para representar
  la progresión del cuadro eliminatorio.

### Relación

- Una fase contiene múltiples partidos.
- Un estadio puede alojar múltiples partidos.
- Un partido tiene dos participaciones de selección en condiciones normales.
- Un partido puede generar estadísticas, asignaciones arbitrales e incidencias.
- Un partido puede alimentar a otro partido durante una fase eliminatoria.

---

## 3.5. PARTICIPACION_PARTIDO

Representa la participación de una selección dentro de un partido.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_participacion | Identificador de la participación | PK |
| id_partido | Partido correspondiente | FK |
| id_seleccion | Selección participante | FK |
| condicion | Condición dentro del partido | |
| goles_marcados | Goles registrados por la selección | |

### Restricciones

- Una selección no puede participar dos veces en el mismo partido.
- Un partido no puede tener dos participaciones con la misma condición.
- `condicion` puede tomar valores como `LOCAL` o `VISITANTE`.
- Los goles registrados deben ser mayores o iguales a cero.

### Relación

- Un partido tiene participaciones de selecciones.
- Una selección puede participar en múltiples partidos.

> La validación de que un partido tenga exactamente dos participaciones
> se considera una regla de negocio que puede requerir mecanismos adicionales
> de integridad en una etapa posterior.

---

# 4. Jugadores y personal técnico

## 4.1. JUGADOR

Representa a un jugador del sistema.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_jugador | Identificador único del jugador | PK |
| nombre | Nombre del jugador | |
| posicion | Posición principal | |
| club | Club al que pertenece | |

### Relación

- Un jugador puede formar parte de convocatorias de diferentes ediciones.
- Un jugador puede registrar estadísticas en múltiples partidos.

---

## 4.2. CONVOCATORIA_JUGADOR

Relaciona un jugador con la selección para la que fue convocado en
una determinada edición.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_convocatoria | Identificador de la convocatoria | PK |
| id_jugador | Jugador convocado | FK |
| id_seleccion | Selección que convoca al jugador | FK |
| numero_camiseta | Número utilizado por el jugador | |
| es_capitan | Indica si el jugador es capitán | |

### Restricciones

- Un jugador no debe aparecer dos veces en la misma selección.
- El número de camiseta debe ser válido dentro de la convocatoria.
- Una selección debe pertenecer a una edición.
- Las reglas de cantidad máxima de jugadores convocados se validarán
  mediante mecanismos adicionales cuando corresponda.

### Relación

- Una selección puede convocar múltiples jugadores.
- Un jugador puede aparecer en múltiples convocatorias.

---

## 4.3. CUERPO_TECNICO

Representa integrantes del cuerpo técnico de una selección.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_cuerpo_tecnico | Identificador del integrante | PK |
| id_seleccion | Selección a la que pertenece | FK |
| nombre | Nombre del integrante | |
| cargo | Cargo dentro del cuerpo técnico | |

### Ejemplos de cargo

- Director técnico
- Asistente técnico
- Preparador físico
- Entrenador de porteros

### Relación

- Una selección puede tener múltiples integrantes del cuerpo técnico.
- Cada integrante registrado pertenece a una selección dentro del modelo.

---

# 5. Arbitraje

## 5.1. ARBITRO

Representa un árbitro participante en el torneo.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_arbitro | Identificador único del árbitro | PK |
| nombre | Nombre del árbitro | |
| nacionalidad | Nacionalidad del árbitro | |

### Relación

- Un árbitro puede ser asignado a múltiples partidos.

---

## 5.2. ASIGNACION_ARBITRAL

Relaciona árbitros con partidos y registra la función desempeñada.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_asignacion | Identificador de la asignación | PK |
| id_partido | Partido asignado | FK |
| id_arbitro | Árbitro asignado | FK |
| rol | Función arbitral desempeñada | |

### Ejemplos de rol

- Principal
- Asistente 1
- Asistente 2
- Cuarto árbitro
- VAR
- AVAR

### Restricciones

- Un mismo árbitro no debe tener dos asignaciones para el mismo partido.
- Las reglas de no simultaneidad entre partidos se consideran reglas de
  negocio que pueden requerir validaciones adicionales.

---

# 6. Estadísticas de juego

## 6.1. ESTADISTICA_JUGADOR_PARTIDO

Registra el rendimiento individual de un jugador durante un partido.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_estadistica | Identificador de la estadística | PK |
| id_partido | Partido correspondiente | FK |
| id_jugador | Jugador correspondiente | FK |
| titular | Indica si inició el partido | |
| minuto_entrada | Minuto en el que ingresó al partido | |
| minuto_salida | Minuto en el que salió del partido | |
| minutos_jugados | Total de minutos jugados | |
| goles | Goles anotados | |
| asistencias | Asistencias registradas | |
| tarjetas_amarillas | Tarjetas amarillas recibidas | |
| tarjetas_rojas | Tarjetas rojas recibidas | |

### Restricciones

- Un jugador no debe tener dos registros estadísticos para el mismo partido.
- Goles, asistencias, tarjetas y minutos no pueden ser negativos.
- El jugador debe estar asociado a una selección participante del partido.
- Los goles individuales deberán ser consistentes con el marcador oficial
  registrado para la selección.

### Relación

- Un partido tiene estadísticas de múltiples jugadores.
- Un jugador puede tener estadísticas en múltiples partidos.

---

# 7. Incidencias

## 7.1. INCIDENCIA

Registra eventos relevantes ocurridos durante un partido.

### Atributos

| Atributo | Descripción | Clave |
|---|---|---|
| id_incidencia | Identificador de la incidencia | PK |
| id_partido | Partido donde ocurrió | FK |
| tipo | Tipo de incidencia | |
| minuto | Minuto aproximado de ocurrencia | |
| descripcion | Descripción de la incidencia | |

### Ejemplos de tipo

- TARJETA
- LESION
- VAR
- INVASION
- SUSPENSION
- OTRO

### Relación

- Un partido puede registrar múltiples incidencias.
- Cada incidencia pertenece a un único partido.

---

# 8. Resumen de relaciones

| Entidad origen | Cardinalidad | Entidad destino |
|---|---|---|
| EDICION_MUNDIAL | 1:N | SEDE |
| SEDE | 1:N | CIUDAD |
| CIUDAD | 1:N | ESTADIO |
| EDICION_MUNDIAL | 1:N | FASE |
| FASE | 1:N | GRUPO |
| EDICION_MUNDIAL | 1:N | SELECCION |
| GRUPO | 1:N | SELECCION |
| EDICION_MUNDIAL | 1:N | PARTIDO |
| FASE | 1:N | PARTIDO |
| ESTADIO | 1:N | PARTIDO |
| PARTIDO | 1:N | PARTICIPACION_PARTIDO |
| SELECCION | 1:N | PARTICIPACION_PARTIDO |
| JUGADOR | 1:N | CONVOCATORIA_JUGADOR |
| SELECCION | 1:N | CONVOCATORIA_JUGADOR |
| SELECCION | 1:N | CUERPO_TECNICO |
| ARBITRO | 1:N | ASIGNACION_ARBITRAL |
| PARTIDO | 1:N | ASIGNACION_ARBITRAL |
| JUGADOR | 1:N | ESTADISTICA_JUGADOR_PARTIDO |
| PARTIDO | 1:N | ESTADISTICA_JUGADOR_PARTIDO |
| PARTIDO | 1:N | INCIDENCIA |
| PARTIDO | 1:N | PARTIDO (progresión) |

---

# 9. Reglas de negocio principales

El modelo lógico ampliado contempla las siguientes reglas:

1. Cada edición del Mundial se identifica de manera única.
2. Una edición puede tener múltiples países sede.
3. Cada sede pertenece a una edición.
4. Cada sede puede contener múltiples ciudades.
5. Cada ciudad puede contener múltiples estadios.
6. Un estadio pertenece a una ciudad.
7. Una edición contiene múltiples fases.
8. Una fase puede contener múltiples grupos cuando corresponde a una fase
   de grupos.
9. Una selección participa en una edición determinada.
10. Una selección puede pertenecer a un grupo durante la fase correspondiente.
11. Un partido pertenece a una única edición, fase y estadio.
12. Un partido enfrenta a las selecciones registradas mediante
    `PARTICIPACION_PARTIDO`.
13. Una selección no puede participar dos veces en el mismo partido.
14. Las participaciones distinguen la condición de las selecciones,
    por ejemplo LOCAL y VISITANTE.
15. Un jugador puede participar en diferentes ediciones mediante
    convocatorias.
16. Un jugador puede registrar estadísticas en múltiples partidos.
17. Un árbitro puede participar en múltiples partidos mediante asignaciones.
18. Una asignación arbitral define el rol desempeñado por el árbitro.
19. Un partido puede registrar múltiples incidencias.
20. La asistencia registrada de un partido no debe superar la capacidad
    del estadio.
21. Las estadísticas individuales deben ser consistentes con los resultados
    oficiales del partido.
22. Los partidos de fases eliminatorias pueden relacionarse con el partido
    posterior al que alimentan mediante `id_partido_siguiente`.

---

# 10. Decisiones de modelado

### Separación de sede, ciudad y estadio

El modelo inicial almacenaba información geográfica directamente en
`EDICION_MUNDIAL` y `ESTADIO`. El modelo ampliado separa estos conceptos para
representar correctamente la jerarquía:

`EDICION_MUNDIAL → SEDE → CIUDAD → ESTADIO`

Esto permite realizar agregaciones por país, ciudad y estadio sin duplicar
información.

### Separación de fase y grupo

La fase del torneo deja de ser un atributo textual de `PARTIDO` y pasa a ser
una entidad independiente. Los grupos también se modelan como entidades,
permitiendo asociar las selecciones participantes y realizar análisis
específicos por grupo y fase.

### Separación de jugador y convocatoria

La información básica del jugador se almacena en `JUGADOR`, mientras que su
participación con una selección se registra mediante `CONVOCATORIA_JUGADOR`.
Esto evita duplicar la información del jugador entre diferentes ediciones.

### Estadísticas por jugador y partido

Las estadísticas se almacenan en una relación independiente entre jugador y
partido. Esto permite analizar goles, asistencias, tarjetas y minutos
jugados por diferentes niveles del torneo.

### Arbitraje

La relación entre árbitros y partidos se implementa mediante
`ASIGNACION_ARBITRAL`, permitiendo que un árbitro desempeñe diferentes roles
en diferentes partidos.

### Progresión de fases eliminatorias

`PARTIDO.id_partido_siguiente` permite representar que un partido puede
alimentar un partido posterior dentro del cuadro eliminatorio.

### Incidencias

Las incidencias se mantienen asociadas al partido para permitir consultas
operativas sobre eventos ocurridos durante el desarrollo del encuentro.

---

# 11. Normalización

El modelo se diseña siguiendo los principios de normalización hasta Tercera
Forma Normal (3FN):

- Los atributos de cada tabla representan una única propiedad.
- Los atributos no clave dependen de la clave primaria correspondiente.
- Se separan entidades independientes para evitar dependencias transitivas.
- Las relaciones N:M se representan mediante tablas asociativas.
- La información de jugadores, selecciones, partidos, árbitros y estadísticas
  se mantiene separada para evitar redundancia.

La demostración formal de 1FN, 2FN y 3FN se desarrolla en el documento:

`docs/entrega2/normalizacion.md`

---

# 12. Proyección hacia consultas avanzadas

La estructura permite realizar consultas que recorran diferentes niveles
del torneo, por ejemplo:

`JUGADOR → ESTADISTICA_JUGADOR_PARTIDO → PARTIDO → SELECCION → GRUPO → FASE → EDICION_MUNDIAL`

Esto permite obtener indicadores como:

- goleadores por edición;
- asistencias por selección;
- rendimiento de jugadores por fase;
- estadísticas por grupo;
- resultados por selección;
- incidencias por fase;
- desempeño arbitral;
- asistencia acumulada por sede;
- estadísticas agregadas por edición.

Estas estructuras servirán como base para las consultas avanzadas de la
Entrega 2.
