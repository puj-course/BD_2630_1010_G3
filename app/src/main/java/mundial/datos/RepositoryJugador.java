package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryJugador {

    public List<Jugador> consultarJugadores(String filtroTexto) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT id_jugador, nombre, posicion, club ");
        sql.append("FROM jugador ");
        if (filtroTexto != null && !filtroTexto.trim().isEmpty()) {
            sql.append("WHERE UPPER(nombre) LIKE ? OR UPPER(posicion) LIKE ? OR UPPER(club) LIKE ? ");
        }
        sql.append("ORDER BY nombre");

        List<Jugador> jugadores = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            if (filtroTexto != null && !filtroTexto.trim().isEmpty()) {
                String patron = "%" + filtroTexto.trim().toUpperCase() + "%";
                ps.setString(1, patron);
                ps.setString(2, patron);
                ps.setString(3, patron);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    jugadores.add(new Jugador(
                            rs.getInt("ID_JUGADOR"),
                            rs.getString("NOMBRE"),
                            rs.getString("POSICION"),
                            rs.getString("CLUB")));
                }
            }
        }
        return jugadores;
    }

    public int insertarJugador(Jugador jugador) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO jugador (id_jugador, nombre, posicion, club) ");
        sql.append("SELECT NVL(MAX(id_jugador), 0) + 1, ?, ?, ? FROM jugador");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setString(1, jugador.getNombre().trim());
            ps.setString(2, jugador.getPosicion().trim());
            ps.setString(3, jugador.getClub() != null && !jugador.getClub().trim().isEmpty() ? jugador.getClub().trim() : null);
            return ps.executeUpdate();
        }
    }

    public int actualizarJugador(Jugador jugador) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE jugador ");
        sql.append("SET nombre = ?, posicion = ?, club = ? ");
        sql.append("WHERE id_jugador = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setString(1, jugador.getNombre().trim());
            ps.setString(2, jugador.getPosicion().trim());
            ps.setString(3, jugador.getClub() != null && !jugador.getClub().trim().isEmpty() ? jugador.getClub().trim() : null);
            ps.setInt(4, jugador.getIdJugador());
            return ps.executeUpdate();
        }
    }

    public int eliminarJugador(int idJugador) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM jugador WHERE id_jugador = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idJugador);
            return ps.executeUpdate();
        }
    }

    public List<ConvocatoriaJugador> consultarConvocatorias(int idSeleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT c.id_convocatoria, c.id_jugador, c.id_seleccion, ");
        sql.append("c.numero_camiseta, c.es_capitan, j.nombre AS nombre_jugador, j.posicion AS posicion_jugador, s.pais AS pais_seleccion ");
        sql.append("FROM convocatoria_jugador c ");
        sql.append("JOIN jugador j ON j.id_jugador = c.id_jugador ");
        sql.append("JOIN seleccion s ON s.id_seleccion = c.id_seleccion ");
        sql.append("WHERE c.id_seleccion = ? ");
        sql.append("ORDER BY c.numero_camiseta");

        List<ConvocatoriaJugador> convocatorias = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idSeleccion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    convocatorias.add(new ConvocatoriaJugador(
                            rs.getInt("ID_CONVOCATORIA"),
                            rs.getInt("ID_JUGADOR"),
                            rs.getInt("ID_SELECCION"),
                            rs.getInt("NUMERO_CAMISETA"),
                            rs.getInt("ES_CAPITAN"),
                            rs.getString("NOMBRE_JUGADOR"),
                            rs.getString("POSICION_JUGADOR"),
                            rs.getString("PAIS_SELECCION")));
                }
            }
        }
        return convocatorias;
    }

    public List<Jugador> consultarJugadoresDisponibles(int idSeleccion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT j.id_jugador, j.nombre, j.posicion, j.club ");
        sql.append("FROM jugador j ");
        sql.append("WHERE NOT EXISTS ( ");
        sql.append("    SELECT 1 FROM convocatoria_jugador c ");
        sql.append("    WHERE c.id_jugador = j.id_jugador AND c.id_seleccion = ? ");
        sql.append(") ORDER BY j.nombre");

        List<Jugador> jugadores = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idSeleccion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    jugadores.add(new Jugador(
                            rs.getInt("ID_JUGADOR"),
                            rs.getString("NOMBRE"),
                            rs.getString("POSICION"),
                            rs.getString("CLUB")));
                }
            }
        }
        return jugadores;
    }

    public int insertarConvocatoria(ConvocatoriaJugador c) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO convocatoria_jugador (id_convocatoria, id_jugador, id_seleccion, numero_camiseta, es_capitan) ");
        sql.append("SELECT NVL(MAX(id_convocatoria), 0) + 1, ?, ?, ?, ? FROM convocatoria_jugador");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, c.getIdJugador());
            ps.setInt(2, c.getIdSeleccion());
            ps.setInt(3, c.getNumeroCamiseta());
            ps.setInt(4, c.getEsCapitan());
            return ps.executeUpdate();
        }
    }

    public int eliminarConvocatoria(int idConvocatoria) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM convocatoria_jugador WHERE id_convocatoria = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idConvocatoria);
            return ps.executeUpdate();
        }
    }
}
