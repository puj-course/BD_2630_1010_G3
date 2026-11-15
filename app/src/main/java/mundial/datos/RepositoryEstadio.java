package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryEstadio {

    public List<Estadio> consultarEstadios() throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT es.id_estadio, es.id_ciudad, es.nombre, es.capacidad, ");
        sql.append("c.nombre || ' - ' || s.pais || ' (' || e.anio || ')' AS ciudad ");
        sql.append("FROM estadio es ");
        sql.append("JOIN ciudad c ON es.id_ciudad = c.id_ciudad ");
        sql.append("JOIN sede s ON c.id_sede = s.id_sede ");
        sql.append("JOIN edicion_mundial e ON s.id_edicion = e.id_edicion ");
        sql.append("ORDER BY e.anio, s.pais, c.nombre, es.nombre");

        List<Estadio> estadios = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                estadios.add(new Estadio(
                        rs.getInt("ID_ESTADIO"),
                        rs.getInt("ID_CIUDAD"),
                        rs.getString("NOMBRE"),
                        rs.getInt("CAPACIDAD"),
                        rs.getString("CIUDAD")));
            }
        }
        return estadios;
    }

    public int insertarEstadio(Estadio estadio) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO estadio (id_estadio, id_ciudad, nombre, capacidad) ");
        sql.append("SELECT NVL(MAX(id_estadio), 0) + 1, ?, ?, ? FROM estadio");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, estadio.getIdCiudad());
            ps.setString(2, estadio.getNombre().trim());
            ps.setInt(3, estadio.getCapacidad());
            return ps.executeUpdate();
        }
    }

    public int actualizarEstadio(Estadio estadio) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE estadio ");
        sql.append("SET id_ciudad = ?, nombre = ?, capacidad = ? ");
        sql.append("WHERE id_estadio = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, estadio.getIdCiudad());
            ps.setString(2, estadio.getNombre().trim());
            ps.setInt(3, estadio.getCapacidad());
            ps.setInt(4, estadio.getIdEstadio());
            return ps.executeUpdate();
        }
    }

    public int eliminarEstadio(int idEstadio) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM estadio ");
        sql.append("WHERE id_estadio = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEstadio);
            return ps.executeUpdate();
        }
    }
}
