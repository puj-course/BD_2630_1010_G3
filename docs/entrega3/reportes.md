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

