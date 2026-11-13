package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
}
