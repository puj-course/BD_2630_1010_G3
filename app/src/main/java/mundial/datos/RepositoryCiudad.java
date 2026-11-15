package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryCiudad {

    public List<Ciudad> consultarCiudades() throws SQLException {
        // La sede se muestra como "pais (anio)", por eso se une tambien con la edicion.
        StringBuilder sql = new StringBuilder("SELECT c.id_ciudad, c.id_sede, c.nombre, ");
        sql.append("s.pais || ' (' || e.anio || ')' AS sede ");
        sql.append("FROM ciudad c ");
        sql.append("JOIN sede s ON c.id_sede = s.id_sede ");
        sql.append("JOIN edicion_mundial e ON s.id_edicion = e.id_edicion ");
        sql.append("ORDER BY e.anio, s.pais, c.nombre");

        List<Ciudad> ciudades = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ciudades.add(new Ciudad(
                        rs.getInt("ID_CIUDAD"),
                        rs.getInt("ID_SEDE"),
                        rs.getString("NOMBRE"),
                        rs.getString("SEDE")));
            }
        }
        return ciudades;
    }

    public int insertarCiudad(Ciudad ciudad) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO ciudad (id_ciudad, id_sede, nombre) ");
        sql.append("SELECT NVL(MAX(id_ciudad), 0) + 1, ?, ? FROM ciudad");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, ciudad.getIdSede());
            ps.setString(2, ciudad.getNombre().trim());
            return ps.executeUpdate();
        }
    }

    public int actualizarCiudad(Ciudad ciudad) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE ciudad ");
        sql.append("SET id_sede = ?, nombre = ? ");
        sql.append("WHERE id_ciudad = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, ciudad.getIdSede());
            ps.setString(2, ciudad.getNombre().trim());
            ps.setInt(3, ciudad.getIdCiudad());
            return ps.executeUpdate();
        }
    }

    public int eliminarCiudad(int idCiudad) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM ciudad ");
        sql.append("WHERE id_ciudad = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idCiudad);
            return ps.executeUpdate();
        }
    }
}
