package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryReportes {

    // Usa fn_goles_jugador y fn_posicion_goleador de funciones.sql
    public List<FilaGoleador> consultarGoleadores(int idEdicion, int top) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM ( ");
        sql.append("SELECT j.nombre, s.pais, ");
        sql.append("fn_goles_jugador(j.id_jugador, s.id_edicion) AS goles, ");
        sql.append("fn_posicion_goleador(j.id_jugador, s.id_edicion) AS posicion ");
        sql.append("FROM jugador j ");
        sql.append("JOIN convocatoria_jugador c ON c.id_jugador = j.id_jugador ");
        sql.append("JOIN seleccion s ON s.id_seleccion = c.id_seleccion ");
        sql.append("WHERE s.id_edicion = ? ");
        // Solo los que marcaron, para no llamar las funciones con todos los convocados
        sql.append("AND EXISTS (SELECT 1 FROM estadistica_jugador_partido e ");
        sql.append("JOIN partido p ON p.id_partido = e.id_partido ");
        sql.append("WHERE e.id_jugador = j.id_jugador AND p.id_edicion = s.id_edicion AND e.goles > 0)) ");
        sql.append("WHERE posicion <= ? ");
        sql.append("ORDER BY posicion, nombre");

        List<FilaGoleador> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            ps.setInt(2, top);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    filas.add(new FilaGoleador(
                            rs.getInt("POSICION"),
                            rs.getString("NOMBRE"),
                            rs.getString("PAIS"),
                            rs.getInt("GOLES")));
                }
            }
        }
        return filas;
    }

    // Usa fn_diferencia_gol de funciones.sql
    public List<FilaSeleccion> consultarSelecciones(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("WITH resultados AS ( ");
        sql.append("SELECT pp.id_seleccion, pp.goles_marcados AS gf, rival.goles_marcados AS gc ");
        sql.append("FROM participacion_partido pp ");
        sql.append("JOIN participacion_partido rival ON rival.id_partido = pp.id_partido ");
        sql.append("AND rival.id_seleccion <> pp.id_seleccion) ");
        sql.append("SELECT s.pais, g.nombre AS grupo, COUNT(r.id_seleccion) AS jugados, ");
        sql.append("SUM(CASE WHEN r.gf > r.gc THEN 1 ELSE 0 END) AS ganados, ");
        sql.append("SUM(CASE WHEN r.gf = r.gc THEN 1 ELSE 0 END) AS empatados, ");
        sql.append("SUM(CASE WHEN r.gf < r.gc THEN 1 ELSE 0 END) AS perdidos, ");
        sql.append("NVL(SUM(r.gf), 0) AS goles_favor, NVL(SUM(r.gc), 0) AS goles_contra, ");
        sql.append("fn_diferencia_gol(s.id_seleccion) AS diferencia ");
        sql.append("FROM seleccion s ");
        sql.append("LEFT JOIN grupo g ON g.id_grupo = s.id_grupo ");
        sql.append("LEFT JOIN resultados r ON r.id_seleccion = s.id_seleccion ");
        sql.append("WHERE s.id_edicion = ? ");
        sql.append("GROUP BY s.id_seleccion, s.pais, g.nombre ");
        sql.append("ORDER BY diferencia DESC, goles_favor DESC, s.pais");

        List<FilaSeleccion> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    filas.add(new FilaSeleccion(
                            rs.getString("PAIS"),
                            rs.getString("GRUPO"),
                            rs.getInt("JUGADOS"),
                            rs.getInt("GANADOS"),
                            rs.getInt("EMPATADOS"),
                            rs.getInt("PERDIDOS"),
                            rs.getInt("GOLES_FAVOR"),
                            rs.getInt("GOLES_CONTRA"),
                            rs.getInt("DIFERENCIA")));
                }
            }
        }
        return filas;
    }

    public List<FilaFase> consultarFases(int idEdicion) throws SQLException {
        // Primero se suman los goles de cada partido para no contar dos veces la asistencia
        StringBuilder sql = new StringBuilder("SELECT f.nombre AS fase, COUNT(*) AS partidos, ");
        sql.append("SUM(t.goles) AS goles, ROUND(AVG(t.goles), 2) AS promedio, ");
        sql.append("NVL(SUM(t.asistencia), 0) AS asistencia ");
        sql.append("FROM (SELECT p.id_partido, p.id_fase, p.asistencia_registrada AS asistencia, ");
        sql.append("NVL(SUM(pp.goles_marcados), 0) AS goles ");
        sql.append("FROM partido p ");
        sql.append("LEFT JOIN participacion_partido pp ON pp.id_partido = p.id_partido ");
        sql.append("WHERE p.id_edicion = ? ");
        sql.append("GROUP BY p.id_partido, p.id_fase, p.asistencia_registrada) t ");
        sql.append("JOIN fase f ON f.id_fase = t.id_fase ");
        sql.append("GROUP BY f.orden_fase, f.nombre ");
        sql.append("ORDER BY f.orden_fase");

        List<FilaFase> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    filas.add(new FilaFase(
                            rs.getString("FASE"),
                            rs.getInt("PARTIDOS"),
                            rs.getInt("GOLES"),
                            rs.getDouble("PROMEDIO"),
                            rs.getLong("ASISTENCIA")));
                }
            }
        }
        return filas;
    }

    public List<FilaIncidenciasEstadio> consultarIncidenciasPorEstadio(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT f.nombre AS fase, es.nombre AS estadio, ");
        sql.append("COUNT(*) AS incidencias ");
        sql.append("FROM incidencia i ");
        sql.append("JOIN partido p ON p.id_partido = i.id_partido ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("JOIN estadio es ON es.id_estadio = p.id_estadio ");
        sql.append("WHERE p.id_edicion = ? ");
        sql.append("GROUP BY f.orden_fase, f.nombre, es.nombre ");
        sql.append("ORDER BY incidencias DESC, f.orden_fase, es.nombre");

        List<FilaIncidenciasEstadio> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    filas.add(new FilaIncidenciasEstadio(
                            rs.getString("FASE"),
                            rs.getString("ESTADIO"),
                            rs.getInt("INCIDENCIAS")));
                }
            }
        }
        return filas;
    }
}
