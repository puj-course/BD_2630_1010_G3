package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryEdicion {

    public List<Edicion> consultarEdiciones() throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT id_edicion, anio, lema, fecha_inicio, fecha_fin ");
        sql.append("FROM edicion_mundial ");
        sql.append("ORDER BY anio");

        List<Edicion> ediciones = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ediciones.add(new Edicion(
                        rs.getInt("ID_EDICION"),
                        rs.getInt("ANIO"),
                        rs.getString("LEMA"),
                        rs.getDate("FECHA_INICIO"),
                        rs.getDate("FECHA_FIN")));
            }
        }
        return ediciones;
    }

    public int insertarEdicion(Edicion edicion) throws SQLException {
        // El id es el mayor que exista mas uno. Si dos personas guardan al mismo
        // tiempo, la PK rechaza la segunda con ORA-00001.
        StringBuilder sql = new StringBuilder("INSERT INTO edicion_mundial ");
        sql.append("(id_edicion, anio, lema, fecha_inicio, fecha_fin) ");
        sql.append("SELECT NVL(MAX(id_edicion), 0) + 1, ?, ?, ?, ? FROM edicion_mundial");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, edicion.getAnio());
            asignarLema(ps, 2, edicion.getLema());
            ps.setDate(3, edicion.getFechaInicio());
            ps.setDate(4, edicion.getFechaFin());
            return ps.executeUpdate();
        }
    }

    public int actualizarEdicion(Edicion edicion) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE edicion_mundial ");
        sql.append("SET anio = ?, lema = ?, fecha_inicio = ?, fecha_fin = ? ");
        sql.append("WHERE id_edicion = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, edicion.getAnio());
            asignarLema(ps, 2, edicion.getLema());
            ps.setDate(3, edicion.getFechaInicio());
            ps.setDate(4, edicion.getFechaFin());
            ps.setInt(5, edicion.getIdEdicion());
            return ps.executeUpdate();
        }
    }

    public int eliminarEdicion(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM edicion_mundial ");
        sql.append("WHERE id_edicion = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            return ps.executeUpdate();
        }
    }

    private void asignarLema(PreparedStatement ps, int posicion, String lema) throws SQLException {
        if (lema == null || lema.isBlank()) {
            ps.setNull(posicion, Types.VARCHAR);
        } else {
            ps.setString(posicion, lema.trim());
        }
    }
}
