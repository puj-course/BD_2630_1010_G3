package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositorySede {

    public List<Sede> consultarSedes() throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT s.id_sede, s.id_edicion, s.pais, e.anio ");
        sql.append("FROM sede s JOIN edicion_mundial e ON s.id_edicion = e.id_edicion ");
        sql.append("ORDER BY e.anio, s.pais");

        List<Sede> sedes = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                sedes.add(new Sede(
                        rs.getInt("ID_SEDE"),
                        rs.getInt("ID_EDICION"),
                        rs.getString("PAIS"),
                        rs.getInt("ANIO")));
            }
        }
        return sedes;
    }

    public int insertarSede(Sede sede) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO sede (id_sede, id_edicion, pais) ");
        sql.append("SELECT NVL(MAX(id_sede), 0) + 1, ?, ? FROM sede");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, sede.getIdEdicion());
            ps.setString(2, sede.getPais().trim());
            return ps.executeUpdate();
        }
    }

    public int actualizarSede(Sede sede) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE sede ");
        sql.append("SET id_edicion = ?, pais = ? ");
        sql.append("WHERE id_sede = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, sede.getIdEdicion());
            ps.setString(2, sede.getPais().trim());
            ps.setInt(3, sede.getIdSede());
            return ps.executeUpdate();
        }
    }

    public int eliminarSede(int idSede) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM sede ");
        sql.append("WHERE id_sede = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idSede);
            return ps.executeUpdate();
        }
    }
}
