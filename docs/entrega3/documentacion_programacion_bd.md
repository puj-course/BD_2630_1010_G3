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

La aplicación usa las tres primeras en el panel de reportes. `fn_cupo_convocatoria` sirve para revisar cuántos jugadores más puede convocar una selección.

---
