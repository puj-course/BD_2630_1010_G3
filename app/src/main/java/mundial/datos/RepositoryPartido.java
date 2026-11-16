package mundial.datos;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import mundial.Conexion;

public class RepositoryPartido {

    public List<Partido> consultarPartidos(int idEdicion, Integer idFase) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT p.id_partido, p.id_edicion, p.id_fase, p.id_estadio, p.id_partido_siguiente, ");
        sql.append("p.fecha_hora, p.asistencia_registrada, f.nombre AS nombre_fase, f.tipo AS tipo_fase, ");
        sql.append("es.nombre AS nombre_estadio, es.capacidad AS capacidad_estadio, e.anio AS anio_edicion, ");
        sql.append("loc.id_seleccion AS id_local, s_loc.pais AS pais_local, loc.goles_marcados AS goles_local, ");
        sql.append("vis.id_seleccion AS id_vis, s_vis.pais AS pais_vis, vis.goles_marcados AS goles_vis ");
        sql.append("FROM partido p ");
        sql.append("JOIN fase f ON f.id_fase = p.id_fase ");
        sql.append("JOIN estadio es ON es.id_estadio = p.id_estadio ");
        sql.append("JOIN edicion_mundial e ON e.id_edicion = p.id_edicion ");
        sql.append("LEFT JOIN participacion_partido loc ON loc.id_partido = p.id_partido AND loc.condicion = 'LOCAL' ");
        sql.append("LEFT JOIN seleccion s_loc ON s_loc.id_seleccion = loc.id_seleccion ");
        sql.append("LEFT JOIN participacion_partido vis ON vis.id_partido = p.id_partido AND vis.condicion = 'VISITANTE' ");
        sql.append("LEFT JOIN seleccion s_vis ON s_vis.id_seleccion = vis.id_seleccion ");
        sql.append("WHERE p.id_edicion = ? ");
        if (idFase != null) {
            sql.append("AND p.id_fase = ? ");
        }
        sql.append("ORDER BY p.fecha_hora, p.id_partido");

        List<Partido> partidos = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            if (idFase != null) {
                ps.setInt(2, idFase);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int idSiguiente = rs.getInt("ID_PARTIDO_SIGUIENTE");
                    Integer idPartSig = rs.wasNull() ? null : idSiguiente;

                    int asis = rs.getInt("ASISTENCIA_REGISTRADA");
                    Integer asistencia = rs.wasNull() ? null : asis;

                    int idLoc = rs.getInt("ID_LOCAL");
                    Integer idLocal = rs.wasNull() ? null : idLoc;

                    int gLoc = rs.getInt("GOLES_LOCAL");
                    Integer golesLocal = rs.wasNull() ? null : gLoc;

                    int idVis = rs.getInt("ID_VIS");
                    Integer idVisitante = rs.wasNull() ? null : idVis;

                    int gVis = rs.getInt("GOLES_VIS");
                    Integer golesVisitante = rs.wasNull() ? null : gVis;

                    partidos.add(new Partido(
                            rs.getInt("ID_PARTIDO"),
                            rs.getInt("ID_EDICION"),
                            rs.getInt("ID_FASE"),
                            rs.getInt("ID_ESTADIO"),
                            idPartSig,
                            rs.getTimestamp("FECHA_HORA"),
                            asistencia,
                            rs.getString("NOMBRE_FASE"),
                            rs.getString("TIPO_FASE"),
                            rs.getString("NOMBRE_ESTADIO"),
                            rs.getInt("CAPACIDAD_ESTADIO"),
                            rs.getInt("ANIO_EDICION"),
                            idLocal,
                            rs.getString("PAIS_LOCAL"),
                            golesLocal,
                            idVisitante,
                            rs.getString("PAIS_VIS"),
                            golesVisitante));
                }
            }
        }
        return partidos;
    }

    public int insertarPartido(int idEdicion, int idFase, int idEstadio, Timestamp fechaHora,
                               int idLocal, int idVisitante) throws SQLException {
        String sqlPartId = "SELECT NVL(MAX(id_partido), 0) + 1 AS nuevo_id FROM partido";
        String sqlInsertPartido = "INSERT INTO partido (id_partido, id_edicion, id_fase, id_estadio, fecha_hora) VALUES (?, ?, ?, ?, ?)";
        String sqlParticId = "SELECT NVL(MAX(id_participacion), 0) FROM participacion_partido";
        String sqlInsertPartic = "INSERT INTO participacion_partido (id_participacion, id_partido, id_seleccion, condicion, goles_marcados) VALUES (?, ?, ?, ?, 0)";

        try (Connection conex = Conexion.abrir()) {
            conex.setAutoCommit(false);
            try {
                int nuevoIdPartido = 1;
                try (PreparedStatement psId = conex.prepareStatement(sqlPartId);
                     ResultSet rsId = psId.executeQuery()) {
                    if (rsId.next()) {
                        nuevoIdPartido = rsId.getInt("nuevo_id");
                    }
                }

                try (PreparedStatement psPart = conex.prepareStatement(sqlInsertPartido)) {
                    psPart.setInt(1, nuevoIdPartido);
                    psPart.setInt(2, idEdicion);
                    psPart.setInt(3, idFase);
                    psPart.setInt(4, idEstadio);
                    psPart.setTimestamp(5, fechaHora);
                    psPart.executeUpdate();
                }

                int baseIdPartic = 0;
                try (PreparedStatement psPId = conex.prepareStatement(sqlParticId);
                     ResultSet rsPId = psPId.executeQuery()) {
                    if (rsPId.next()) {
                        baseIdPartic = rsPId.getInt(1);
                    }
                }

                // Insertar Local
                try (PreparedStatement psLocal = conex.prepareStatement(sqlInsertPartic)) {
                    psLocal.setInt(1, baseIdPartic + 1);
                    psLocal.setInt(2, nuevoIdPartido);
                    psLocal.setInt(3, idLocal);
                    psLocal.setString(4, "LOCAL");
                    psLocal.executeUpdate();
                }

                // Insertar Visitante
                try (PreparedStatement psVis = conex.prepareStatement(sqlInsertPartic)) {
                    psVis.setInt(1, baseIdPartic + 2);
                    psVis.setInt(2, nuevoIdPartido);
                    psVis.setInt(3, idVisitante);
                    psVis.setString(4, "VISITANTE");
                    psVis.executeUpdate();
                }

                conex.commit();
                return nuevoIdPartido;
            } catch (SQLException ex) {
                conex.rollback();
                throw ex;
            } finally {
                conex.setAutoCommit(true);
            }
        }
    }

    public void registrarResultado(int idPartido, int golesLocal, int golesVisitante, Integer asistencia) throws SQLException {
        // Invoca el procedimiento almacenado pr_registrar_resultado
        String call = "{CALL pr_registrar_resultado(?, ?, ?, ?)}";
        try (Connection conex = Conexion.abrir();
             CallableStatement cs = conex.prepareCall(call)) {
            cs.setInt(1, idPartido);
            cs.setInt(2, golesLocal);
            cs.setInt(3, golesVisitante);
            if (asistencia != null) {
                cs.setInt(4, asistencia);
            } else {
                cs.setNull(4, java.sql.Types.NUMERIC);
            }
            cs.execute();
        }
    }

    public void cerrarFase(int idEdicion, int idFase) throws SQLException {
        String call = "{CALL pr_cierre_fase(?, ?)}";
        try (Connection conex = Conexion.abrir();
             CallableStatement cs = conex.prepareCall(call)) {
            cs.setInt(1, idEdicion);
            cs.setInt(2, idFase);
            cs.execute();
        }
    }

    public int eliminarPartido(int idPartido) throws SQLException {
        StringBuilder sql = new StringBuilder("DELETE FROM partido WHERE id_partido = ?");
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idPartido);
            return ps.executeUpdate();
        }
    }

    public List<Fase> consultarFases(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT id_fase, id_edicion, nombre, orden_fase, tipo ");
        sql.append("FROM fase WHERE id_edicion = ? ORDER BY orden_fase");

        List<Fase> fases = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    fases.add(new Fase(
                            rs.getInt("ID_FASE"),
                            rs.getInt("ID_EDICION"),
                            rs.getString("NOMBRE"),
                            rs.getInt("ORDEN_FASE"),
                            rs.getString("TIPO")));
                }
            }
        }
        return fases;
    }

    public List<Estadio> consultarEstadiosPorEdicion(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT es.id_estadio, es.id_ciudad, es.nombre, es.capacidad, c.nombre AS ciudad ");
        sql.append("FROM estadio es ");
        sql.append("JOIN ciudad c ON c.id_ciudad = es.id_ciudad ");
        sql.append("JOIN sede s ON s.id_sede = c.id_sede ");
        sql.append("WHERE s.id_edicion = ? ");
        sql.append("ORDER BY es.nombre");

        List<Estadio> estadios = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    estadios.add(new Estadio(
                            rs.getInt("ID_ESTADIO"),
                            rs.getInt("ID_CIUDAD"),
                            rs.getString("NOMBRE"),
                            rs.getInt("CAPACIDAD"),
                            rs.getString("CIUDAD")));
                }
            }
        }
        return estadios;
    }

    public static class OpcionSeleccion {
        private final int idSeleccion;
        private final String pais;

        public OpcionSeleccion(int idSeleccion, String pais) {
            this.idSeleccion = idSeleccion;
            this.pais = pais;
        }

        public int getIdSeleccion() { return idSeleccion; }
        public String getPais() { return pais; }

        @Override
        public String toString() { return pais; }
    }

    public List<OpcionSeleccion> consultarSeleccionesPorEdicion(int idEdicion) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT id_seleccion, pais FROM seleccion ");
        sql.append("WHERE id_edicion = ? ORDER BY pais");

        List<OpcionSeleccion> selecciones = new ArrayList<>();
        try (Connection conex = Conexion.abrir();
             PreparedStatement ps = conex.prepareStatement(sql.toString())) {
            ps.setInt(1, idEdicion);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    selecciones.add(new OpcionSeleccion(rs.getInt("ID_SELECCION"), rs.getString("PAIS")));
                }
            }
        }
        return selecciones;
    }
}
