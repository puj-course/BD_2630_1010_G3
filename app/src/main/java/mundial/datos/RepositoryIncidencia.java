package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryIncidencia {

    public List<Incidencia> consultarIncidencias(int idPartido) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT i.id_incidencia, i.id_partido, i.tipo, i.minuto, i.descripcion, ");
        sql.append("'Partido #' || p.id_partido || ' (' || f.nombre || ')' AS partido_info ");
        sql.append("FROM incidencia i ");
        sql.append("JOIN partido p ON p.id_partido = i.id_partido ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("WHERE i.id_partido = ? ");
        sql.append("ORDER BY i.minuto, i.id_incidencia");

        List<Incidencia> lista = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idPartido);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Incidencia(
                            rs.getInt("ID_INCIDENCIA"),
                            rs.getInt("ID_PARTIDO"),
                            rs.getString("TIPO"),
                            rs.getInt("MINUTO"),
                            rs.getString("DESCRIPCION"),
                            rs.getString("PARTIDO_INFO")));
                }
            }
        }
        return lista;
    }

    public int insertarIncidencia(Incidencia inc) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO incidencia (id_incidencia, id_partido, tipo, minuto, descripcion) ");
        sql.append("SELECT NVL(MAX(id_incidencia), 0) + 1, ?, ?, ?, ? FROM incidencia");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, inc.getIdPartido());
            ps.setString(2, inc.getTipo().trim());
            ps.setInt(3, inc.getMinuto());
            ps.setString(4, inc.getDescripcion() != null && !inc.getDescripcion().trim().isEmpty() ? inc.getDescripcion().trim() : null);
            return ps.executeUpdate();
        }
    }

    public int actualizarIncidencia(Incidencia inc) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE incidencia ");
        sql.append("SET tipo = ?, minuto = ?, descripcion = ? ");
        sql.append("WHERE id_incidencia = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setString(1, inc.getTipo().trim());
            ps.setInt(2, inc.getMinuto());
            ps.setString(3, inc.getDescripcion() != null && !inc.getDescripcion().trim().isEmpty() ? inc.getDescripcion().trim() : null);
            ps.setInt(4, inc.getIdIncidencia());
            return ps.executeUpdate();
        }
    }

    public int eliminarIncidencia(int idIncidencia) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM incidencia WHERE id_incidencia = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idIncidencia);
            return ps.executeUpdate();
        }
    }
}
