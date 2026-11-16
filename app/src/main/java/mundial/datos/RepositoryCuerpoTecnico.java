package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryCuerpoTecnico {

    public List<CuerpoTecnico> consultarCuerpoTecnico(Integer idEdicion, Integer idSeleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ct.id_cuerpo_tecnico, ct.id_seleccion, ct.nombre, ct.cargo, s.pais AS pais_seleccion ");
        sql.append("FROM cuerpo_tecnico ct ");
        sql.append("JOIN seleccion s ON s.id_seleccion = ct.id_seleccion ");
        sql.append("WHERE 1=1 ");
        if (idEdicion != null) {
            sql.append("AND s.id_edicion = ? ");
        }
        if (idSeleccion != null) {
            sql.append("AND ct.id_seleccion = ? ");
        }
        sql.append("ORDER BY s.pais, ct.cargo, ct.nombre");

        List<CuerpoTecnico> lista = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            int idx = 1;
            if (idEdicion != null) {
                ps.setInt(idx++, idEdicion);
            }
            if (idSeleccion != null) {
                ps.setInt(idx++, idSeleccion);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new CuerpoTecnico(
                            rs.getInt("ID_CUERPO_TECNICO"),
                            rs.getInt("ID_SELECCION"),
                            rs.getString("NOMBRE"),
                            rs.getString("CARGO"),
                            rs.getString("PAIS_SELECCION")));
                }
            }
        }
        return lista;
    }

    public int insertarCuerpoTecnico(CuerpoTecnico ct) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO cuerpo_tecnico (id_cuerpo_tecnico, id_seleccion, nombre, cargo) ");
        sql.append("SELECT NVL(MAX(id_cuerpo_tecnico), 0) + 1, ?, ?, ? FROM cuerpo_tecnico");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, ct.getIdSeleccion());
            ps.setString(2, ct.getNombre().trim());
            ps.setString(3, ct.getCargo().trim());
            return ps.executeUpdate();
        }
    }

    public int actualizarCuerpoTecnico(CuerpoTecnico ct) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE cuerpo_tecnico ");
        sql.append("SET id_seleccion = ?, nombre = ?, cargo = ? ");
        sql.append("WHERE id_cuerpo_tecnico = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, ct.getIdSeleccion());
            ps.setString(2, ct.getNombre().trim());
            ps.setString(3, ct.getCargo().trim());
            ps.setInt(4, ct.getIdCuerpoTecnico());
            return ps.executeUpdate();
        }
    }

    public int eliminarCuerpoTecnico(int idCuerpoTecnico) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM cuerpo_tecnico WHERE id_cuerpo_tecnico = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idCuerpoTecnico);
            return ps.executeUpdate();
        }
    }
}
