package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryConsultas {

    public List<String> consultarFases(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT nombre FROM fase ");
        sql.append("WHERE id_edicion = ? ");
        sql.append("ORDER BY orden_fase");
        return consultarTextos(sql.toString(), idEdicion);
    }

    public List<String> consultarGrupos(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT g.nombre FROM grupo g ");
        sql.append("JOIN fase f ON f.id_fase = g.id_fase ");
        sql.append("WHERE f.id_edicion = ? ");
        sql.append("ORDER BY g.nombre");
        return consultarTextos(sql.toString(), idEdicion);
    }

    // grupo en null trae todos los grupos de la edicion
    public List<FilaPosicion> consultarPosiciones(int idEdicion, String grupo) throws SQLException {
        StringBuilder sql = new StringBuilder("WITH resultados AS ( ");
        sql.append("SELECT pp.id_seleccion, pp.goles_marcados AS gf, rival.goles_marcados AS gc ");
        sql.append("FROM participacion_partido pp ");
        sql.append("JOIN participacion_partido rival ON rival.id_partido = pp.id_partido ");
        sql.append("AND rival.id_seleccion <> pp.id_seleccion ");
        sql.append("JOIN partido p ON p.id_partido = pp.id_partido ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("WHERE f.tipo = 'GRUPOS') ");
        sql.append("SELECT g.nombre AS grupo, s.pais, COUNT(r.id_seleccion) AS jugados, ");
        sql.append("SUM(CASE WHEN r.gf > r.gc THEN 1 ELSE 0 END) AS ganados, ");
        sql.append("SUM(CASE WHEN r.gf = r.gc THEN 1 ELSE 0 END) AS empatados, ");
        sql.append("SUM(CASE WHEN r.gf < r.gc THEN 1 ELSE 0 END) AS perdidos, ");
        sql.append("NVL(SUM(r.gf), 0) AS goles_favor, NVL(SUM(r.gc), 0) AS goles_contra, ");
        sql.append("NVL(SUM(r.gf - r.gc), 0) AS diferencia, ");
        sql.append("SUM(CASE WHEN r.gf > r.gc THEN 3 WHEN r.gf = r.gc THEN 1 ELSE 0 END) AS puntos ");
        sql.append("FROM seleccion s ");
        sql.append("JOIN grupo g ON g.id_grupo = s.id_grupo ");
        sql.append("LEFT JOIN resultados r ON r.id_seleccion = s.id_seleccion ");
        sql.append("WHERE s.id_edicion = ? ");
        if (grupo != null) {
            sql.append("AND g.nombre = ? ");
        }
        sql.append("GROUP BY g.nombre, s.pais ");
        sql.append("ORDER BY grupo, puntos DESC, diferencia DESC, goles_favor DESC, s.pais");

        List<FilaPosicion> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            if (grupo != null) {
                ps.setString(2, grupo);
            }
            try (ResultSet rs = ps.executeQuery()) {
                String grupoAnterior = null;
                int fila = 0;
                int posicion = 0;
                int[] anterior = null;
                while (rs.next()) {
                    String grupoActual = rs.getString("GRUPO");
                    int puntos = rs.getInt("PUNTOS");
                    int diferencia = rs.getInt("DIFERENCIA");
                    int golesFavor = rs.getInt("GOLES_FAVOR");
                    if (!grupoActual.equals(grupoAnterior)) {
                        grupoAnterior = grupoActual;
                        fila = 0;
                        anterior = null;
                    }
                    fila++;
                    // Si empata en puntos, diferencia y goles con el anterior, comparte puesto
                    int[] actual = {puntos, diferencia, golesFavor};
                    if (anterior == null || actual[0] != anterior[0] || actual[1] != anterior[1] || actual[2] != anterior[2]) {
                        posicion = fila;
                    }
                    anterior = actual;
                    filas.add(new FilaPosicion(
                            grupoActual,
                            posicion,
                            rs.getString("PAIS"),
                            rs.getInt("JUGADOS"),
                            rs.getInt("GANADOS"),
                            rs.getInt("EMPATADOS"),
                            rs.getInt("PERDIDOS"),
                            golesFavor,
                            rs.getInt("GOLES_CONTRA"),
                            diferencia,
                            puntos));
                }
            }
        }
        return filas;
    }

    // fase en null trae todas las fases
    public List<FilaResultado> consultarResultados(int idEdicion, String fase) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT p.fecha_hora, f.nombre AS fase, ");
        sql.append("sl.pais AS local, pl.goles_marcados AS goles_local, ");
        sql.append("pv.goles_marcados AS goles_visitante, sv.pais AS visitante, ");
        sql.append("es.nombre AS estadio, ci.nombre AS ciudad, p.asistencia_registrada ");
        sql.append("FROM partido p ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("JOIN estadio es ON es.id_estadio = p.id_estadio ");
        sql.append("JOIN ciudad ci ON ci.id_ciudad = es.id_ciudad ");
        sql.append("JOIN participacion_partido pl ON pl.id_partido = p.id_partido AND pl.condicion = 'LOCAL' ");
        sql.append("JOIN seleccion sl ON sl.id_seleccion = pl.id_seleccion ");
        sql.append("JOIN participacion_partido pv ON pv.id_partido = p.id_partido AND pv.condicion = 'VISITANTE' ");
        sql.append("JOIN seleccion sv ON sv.id_seleccion = pv.id_seleccion ");
        sql.append("WHERE p.id_edicion = ? ");
        if (fase != null) {
            sql.append("AND f.nombre = ? ");
        }
        sql.append("ORDER BY p.fecha_hora");

        List<FilaResultado> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            if (fase != null) {
                ps.setString(2, fase);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int asistencia = rs.getInt("ASISTENCIA_REGISTRADA");
                    filas.add(new FilaResultado(
                            rs.getTimestamp("FECHA_HORA"),
                            rs.getString("FASE"),
                            rs.getString("LOCAL"),
                            rs.getInt("GOLES_LOCAL"),
                            rs.getInt("GOLES_VISITANTE"),
                            rs.getString("VISITANTE"),
                            rs.getString("ESTADIO"),
                            rs.getString("CIUDAD"),
                            rs.wasNull() ? null : asistencia));
                }
            }
        }
        return filas;
    }

    // fase y tipo en null no filtran
    public List<FilaIncidencia> consultarIncidencias(int idEdicion, String fase, String tipo) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT p.fecha_hora, f.nombre AS fase, ");
        sql.append("sl.pais || ' vs ' || sv.pais AS partido, es.nombre AS estadio, ");
        sql.append("i.minuto, i.tipo, i.descripcion ");
        sql.append("FROM incidencia i ");
        sql.append("JOIN partido p ON p.id_partido = i.id_partido ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("JOIN estadio es ON es.id_estadio = p.id_estadio ");
        sql.append("JOIN participacion_partido pl ON pl.id_partido = p.id_partido AND pl.condicion = 'LOCAL' ");
        sql.append("JOIN seleccion sl ON sl.id_seleccion = pl.id_seleccion ");
        sql.append("JOIN participacion_partido pv ON pv.id_partido = p.id_partido AND pv.condicion = 'VISITANTE' ");
        sql.append("JOIN seleccion sv ON sv.id_seleccion = pv.id_seleccion ");
        sql.append("WHERE p.id_edicion = ? ");
        if (fase != null) {
            sql.append("AND f.nombre = ? ");
        }
        if (tipo != null) {
            sql.append("AND i.tipo = ? ");
        }
        sql.append("ORDER BY p.fecha_hora, i.minuto");

        List<FilaIncidencia> filas = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            int i = 1;
            ps.setInt(i++, idEdicion);
            if (fase != null) {
                ps.setString(i++, fase);
            }
            if (tipo != null) {
                ps.setString(i, tipo);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    filas.add(new FilaIncidencia(
                            rs.getTimestamp("FECHA_HORA"),
                            rs.getString("FASE"),
                            rs.getString("PARTIDO"),
                            rs.getString("ESTADIO"),
                            rs.getInt("MINUTO"),
                            rs.getString("TIPO"),
                            rs.getString("DESCRIPCION")));
                }
            }
        }
        return filas;
    }

    private List<String> consultarTextos(String sql, int idEdicion) throws SQLException {
        List<String> textos = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql)) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    textos.add(rs.getString(1));
                }
            }
        }
        return textos;
    }
}
