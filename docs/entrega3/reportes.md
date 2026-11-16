# Módulo de reportes y consultas - Entrega 3

Las pantallas de este módulo solo leen datos: no insertan, no modifican y no borran nada. Todas tienen un filtro de edición, que por defecto muestra la edición más reciente. Los datos de jugadores, estadísticas, árbitros e incidencias solo están cargados para la edición 7 (Catar 2022); en las demás ediciones esas tablas salen vacías.

| Pantalla | Menú | Clase de la interfaz | Clase de datos |
|---|---|---|---|
| Tabla de posiciones | Consultas → Tabla de posiciones | `PanelPosiciones` | `RepositoryConsultas` |
| Resultados | Consultas → Resultados | `PanelResultados` | `RepositoryConsultas` |
| Incidencias | Consultas → Incidencias | `PanelConsultaIncidencias` | `RepositoryConsultas` |
| Panel de reportes | Reportes → Panel de reportes | `PanelReportes` | `RepositoryReportes` |

---

## 1. Consultas

### Tabla de posiciones

Filtros: edición y grupo (o todos los grupos).

Muestra por cada selección los partidos jugados, ganados, empatados y perdidos, los goles a favor y en contra, la diferencia de gol y los puntos (3 por victoria y 1 por empate). Solo cuenta los partidos de la fase de grupos. Dentro de cada grupo se ordena por puntos, luego por diferencia de gol y luego por goles a favor. Si dos selecciones empatan en los tres, comparten el puesto.

### Resultados

Filtros: edición y fase.

Muestra cada partido con su fecha, fase, local, marcador, visitante, estadio, ciudad y asistencia, ordenados por fecha.

### Incidencias

Filtros: edición, fase y tipo de incidencia (`TARJETA`, `LESION`, `VAR`, `INVASION`, `SUSPENSION` u `OTRO`).

Muestra cada incidencia con el partido en que ocurrió, el estadio, el minuto y la descripción. Abajo indica el total de incidencias encontradas.

---

## 2. Panel de reportes

Filtros: edición y cantidad de goleadores (top 5, 10 o 20). El panel tiene cuatro pestañas.

| Pestaña | Qué muestra | Función que usa |
|---|---|---|
| Goleadores | Puesto, jugador, selección y goles | `fn_goles_jugador`, `fn_posicion_goleador` |
| Por selección | Partidos jugados, ganados, empatados, perdidos, goles a favor, goles en contra y diferencia de gol de cada selección | `fn_diferencia_gol` |
| Por fase | Partidos, goles, promedio de goles por partido y asistencia total de cada fase | — |
| Incidencias por fase y estadio | Cantidad de incidencias en cada combinación de fase y estadio, de mayor a menor | — |

En la pestaña de goleadores, los jugadores con los mismos goles comparten puesto, así que el top 10 puede mostrar más de 10 filas.

Antes de abrir el panel de reportes hay que ejecutar `sql/entrega3/funciones/funciones.sql`. Si las funciones no existen, Oracle devuelve un error y la aplicación lo muestra con `Mensajes`.

---

## 3. Clases

Las clases `Fila*` del paquete `mundial.datos` no representan tablas: cada una guarda una fila del resultado de una consulta (por ejemplo, `FilaPosicion` es una fila de la tabla de posiciones). Por eso solo tienen getters.

La clase `Tablas` reúne lo que comparten los cuatro paneles: el combo de ediciones, la opción "Todos" de los filtros, el formato de las fechas y la creación de las tablas con el estilo de `Estilo`.
