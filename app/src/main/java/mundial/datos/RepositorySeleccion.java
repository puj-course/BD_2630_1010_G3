package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositorySeleccion {

    // Un grupo para llenar la lista desplegable: "Grupo A (2022)".
    public static class OpcionGrupo {
        private int idGrupo;
        private int idEdicion;
        private String texto;

        public OpcionGrupo(int idGrupo, int idEdicion, String texto) {
            this.idGrupo = idGrupo;
            this.idEdicion = idEdicion;
            this.texto = texto;
        }

        public int getIdGrupo() { return idGrupo; }
        public int getIdEdicion() { return idEdicion; }

        @Override
        public String toString() {
            return texto;
        }
    }

    public List<Seleccion> consultarSelecciones() throws SQLException {
        // El grupo puede ser nulo, por eso se une con LEFT JOIN.
        StringBuilder sql = new StringBuilder("SELECT s.id_seleccion, s.id_edicion, s.id_grupo, ");
        sql.append("s.pais, s.confederacion, e.anio, g.nombre AS grupo ");
        sql.append("FROM seleccion s ");
        sql.append("JOIN edicion_mundial e ON s.id_edicion = e.id_edicion ");
        sql.append("LEFT JOIN grupo g ON s.id_grupo = g.id_grupo ");
        sql.append("ORDER BY e.anio, g.nombre, s.pais");

        List<Seleccion> selecciones = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                // getInt devuelve 0 cuando el valor es NULL.
                selecciones.add(new Seleccion(
                        rs.getInt("ID_SELECCION"),
                        rs.getInt("ID_EDICION"),
                        rs.getInt("ID_GRUPO"),
                        rs.getString("PAIS"),
                        rs.getString("CONFEDERACION"),
                        rs.getInt("ANIO"),
                        rs.getString("GRUPO")));
            }
        }
        return selecciones;
    }

    public List<OpcionGrupo> consultarGrupos() throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT g.id_grupo, f.id_edicion, g.nombre, e.anio ");
        sql.append("FROM grupo g ");
        sql.append("JOIN fase f ON g.id_fase = f.id_fase ");
        sql.append("JOIN edicion_mundial e ON f.id_edicion = e.id_edicion ");
        sql.append("ORDER BY e.anio, g.nombre");

        List<OpcionGrupo> grupos = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                grupos.add(new OpcionGrupo(
                        rs.getInt("ID_GRUPO"),
                        rs.getInt("ID_EDICION"),
                        "Grupo " + rs.getString("NOMBRE") + " (" + rs.getInt("ANIO") + ")"));
            }
        }
        return grupos;
    }

    public int insertarSeleccion(Seleccion seleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO seleccion ");
        sql.append("(id_seleccion, id_edicion, id_grupo, pais, confederacion) ");
        sql.append("SELECT NVL(MAX(id_seleccion), 0) + 1, ?, ?, ?, ? FROM seleccion");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, seleccion.getIdEdicion());
            asignarGrupo(ps, 2, seleccion.getIdGrupo());
            ps.setString(3, seleccion.getPais().trim());
            ps.setString(4, seleccion.getConfederacion());
            return ps.executeUpdate();
        }
    }

    public int actualizarSeleccion(Seleccion seleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE seleccion ");
        sql.append("SET id_edicion = ?, id_grupo = ?, pais = ?, confederacion = ? ");
        sql.append("WHERE id_seleccion = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, seleccion.getIdEdicion());
            asignarGrupo(ps, 2, seleccion.getIdGrupo());
            ps.setString(3, seleccion.getPais().trim());
            ps.setString(4, seleccion.getConfederacion());
            ps.setInt(5, seleccion.getIdSeleccion());
            return ps.executeUpdate();
        }
    }

    public int eliminarSeleccion(int idSeleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM seleccion ");
        sql.append("WHERE id_seleccion = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idSeleccion);
            return ps.executeUpdate();
        }
    }

    // Si no hay grupo se guarda NULL en lugar de 0.
    private void asignarGrupo(PreparedStatement ps, int posicion, int idGrupo) throws SQLException {
        if (idGrupo == 0) {
            ps.setNull(posicion, Types.NUMERIC);
        } else {
            ps.setInt(posicion, idGrupo);
        }
    }
}
