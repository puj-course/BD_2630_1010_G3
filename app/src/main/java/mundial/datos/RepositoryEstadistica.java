package mundial.datos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryEstadistica {

    public List<EstadisticaJugador> consultarEstadisticas(int idPartido) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT e.id_estadistica, e.id_partido, e.id_jugador, e.titular, ");
        sql.append("e.minuto_entrada, e.minuto_salida, e.minutos_jugados, e.goles, e.asistencias, ");
        sql.append("e.tarjetas_amarillas, e.tarjetas_rojas, j.nombre AS nombre_jugador, j.posicion AS posicion_jugador, ");
        sql.append("s.pais AS pais_seleccion, 'Partido #' || p.id_partido AS partido_info ");
        sql.append("FROM estadistica_jugador_partido e ");
        sql.append("JOIN jugador j ON j.id_jugador = e.id_jugador ");
        sql.append("JOIN partido p ON p.id_partido = e.id_partido ");
        sql.append("LEFT JOIN convocatoria_jugador c ON c.id_jugador = e.id_jugador ");
        sql.append("LEFT JOIN participacion_partido pp ON pp.id_partido = p.id_partido AND pp.id_seleccion = c.id_seleccion ");
        sql.append("LEFT JOIN seleccion s ON s.id_seleccion = pp.id_seleccion ");
        sql.append("WHERE e.id_partido = ? ");
        sql.append("ORDER BY e.titular DESC, e.minutos_jugados DESC, j.nombre");

        List<EstadisticaJugador> lista = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idPartido);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int mEnt = rs.getInt("MINUTO_ENTRADA");
                    Integer minEnt = rs.wasNull() ? null : mEnt;

                    int mSal = rs.getInt("MINUTO_SALIDA");
                    Integer minSal = rs.wasNull() ? null : mSal;

                    lista.add(new EstadisticaJugador(
                            rs.getInt("ID_ESTADISTICA"),
                            rs.getInt("ID_PARTIDO"),
                            rs.getInt("ID_JUGADOR"),
                            rs.getInt("TITULAR"),
                            minEnt,
                            minSal,
                            rs.getInt("MINUTOS_JUGADOS"),
                            rs.getInt("GOLES"),
                            rs.getInt("ASISTENCIAS"),
                            rs.getInt("TARJETAS_AMARILLAS"),
                            rs.getInt("TARJETAS_ROJAS"),
                            rs.getString("NOMBRE_JUGADOR"),
                            rs.getString("POSICION_JUGADOR"),
                            rs.getString("PAIS_SELECCION"),
                            rs.getString("PARTIDO_INFO")));
                }
            }
        }
        return lista;
    }

    public static class OpcionJugadorPartido {
        private final int idJugador;
        private final String nombre;
        private final String pais;
        private final String posicion;

        public OpcionJugadorPartido(int idJugador, String nombre, String pais, String posicion) {
            this.idJugador = idJugador;
            this.nombre = nombre;
            this.pais = pais;
            this.posicion = posicion;
        }

        public int getIdJugador() { return idJugador; }
        public String getNombre() { return nombre; }
        public String getPais() { return pais; }
        public String getPosicion() { return posicion; }

        @Override
        public String toString() {
            return nombre + " (" + pais + " - " + posicion + ")";
        }
    }

    public List<OpcionJugadorPartido> consultarJugadoresPartido(int idPartido) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT j.id_jugador, j.nombre, s.pais, j.posicion ");
        sql.append("FROM participacion_partido pp ");
        sql.append("JOIN seleccion s ON s.id_seleccion = pp.id_seleccion ");
        sql.append("JOIN convocatoria_jugador c ON c.id_seleccion = s.id_seleccion ");
        sql.append("JOIN jugador j ON j.id_jugador = c.id_jugador ");
        sql.append("WHERE pp.id_partido = ? ");
        sql.append("ORDER BY s.pais, c.numero_camiseta");

        List<OpcionJugadorPartido> jugadores = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idPartido);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    jugadores.add(new OpcionJugadorPartido(
                            rs.getInt("ID_JUGADOR"),
                            rs.getString("NOMBRE"),
                            rs.getString("PAIS"),
                            rs.getString("POSICION")));
                }
            }
        }
        return jugadores;
    }

    public int insertarEstadistica(EstadisticaJugador e) throws SQLException {
        StringBuilder sql = new StringBuilder("INSERT INTO estadistica_jugador_partido ");
        sql.append("(id_estadistica, id_partido, id_jugador, titular, minuto_entrada, minuto_salida, ");
        sql.append("minutos_jugados, goles, asistencias, tarjetas_amarillas, tarjetas_rojas) ");
        sql.append("SELECT NVL(MAX(id_estadistica), 0) + 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? FROM estadistica_jugador_partido");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, e.getIdPartido());
            ps.setInt(2, e.getIdJugador());
            ps.setInt(3, e.getTitular());
            if (e.getMinutoEntrada() != null) {
                ps.setInt(4, e.getMinutoEntrada());
            } else {
                ps.setNull(4, java.sql.Types.NUMERIC);
            }
            if (e.getMinutoSalida() != null) {
                ps.setInt(5, e.getMinutoSalida());
            } else {
                ps.setNull(5, java.sql.Types.NUMERIC);
            }
            ps.setInt(6, e.getMinutosJugados());
            ps.setInt(7, e.getGoles());
            ps.setInt(8, e.getAsistencias());
            ps.setInt(9, e.getTarjetasAmarillas());
            ps.setInt(10, e.getTarjetasRojas());
            return ps.executeUpdate();
        }
    }

    public int actualizarEstadistica(EstadisticaJugador e) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE estadistica_jugador_partido SET ");
        sql.append("titular = ?, minuto_entrada = ?, minuto_salida = ?, minutos_jugados = ?, ");
        sql.append("goles = ?, asistencias = ?, tarjetas_amarillas = ?, tarjetas_rojas = ? ");
        sql.append("WHERE id_estadistica = ?");

        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, e.getTitular());
            if (e.getMinutoEntrada() != null) {
                ps.setInt(2, e.getMinutoEntrada());
            } else {
                ps.setNull(2, java.sql.Types.NUMERIC);
            }
            if (e.getMinutoSalida() != null) {
                ps.setInt(3, e.getMinutoSalida());
            } else {
                ps.setNull(3, java.sql.Types.NUMERIC);
            }
            ps.setInt(4, e.getMinutosJugados());
            ps.setInt(5, e.getGoles());
            ps.setInt(6, e.getAsistencias());
            ps.setInt(7, e.getTarjetasAmarillas());
            ps.setInt(8, e.getTarjetasRojas());
            ps.setInt(9, e.getIdEstadistica());
            return ps.executeUpdate();
        }
    }

    public int eliminarEstadistica(int idEstadistica) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM estadistica_jugador_partido WHERE id_estadistica = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEstadistica);
            return ps.executeUpdate();
        }
    }
}
