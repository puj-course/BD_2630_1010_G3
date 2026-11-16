package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.sql.SQLException;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.FilaFase;
import mundial.datos.FilaGoleador;
import mundial.datos.FilaIncidenciasEstadio;
import mundial.datos.FilaSeleccion;
import mundial.datos.RepositoryReportes;

public class PanelReportes extends JPanel {

    private final RepositoryReportes repository = new RepositoryReportes();
    private final JComboBox<Edicion> ediciones = new JComboBox<>();
    private final JComboBox<Integer> top = new JComboBox<>(new Integer[] {5, 10, 20});
    private final DefaultTableModel goleadores = Tablas.modelo("Pos", "Jugador", "Seleccion", "Goles");
    private final DefaultTableModel selecciones = Tablas.modelo(
            "Seleccion", "Grupo", "PJ", "G", "E", "P", "GF", "GC", "DG");
    private final DefaultTableModel fases = Tablas.modelo(
            "Fase", "Partidos", "Goles", "Goles por partido", "Asistencia total");
    private final DefaultTableModel incidencias = Tablas.modelo("Fase", "Estadio", "Incidencias");

    public PanelReportes() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Edicion:"));
        filtros.add(ediciones);
        filtros.add(new JLabel("Top goleadores:"));
        top.setSelectedItem(10);
        Tablas.ancho(top, 70);
        filtros.add(top);
        JButton generar = new JButton("Generar");
        generar.addActionListener(e -> cargar());
        filtros.add(generar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(Tablas.titulo("Panel de reportes"), BorderLayout.NORTH);
        norte.add(filtros, BorderLayout.CENTER);
        add(norte, BorderLayout.NORTH);

        JTabbedPane pestanas = new JTabbedPane();
        pestanas.addTab("Goleadores", new JScrollPane(Tablas.crear(goleadores, true)));
        pestanas.addTab("Por seleccion", new JScrollPane(Tablas.crear(selecciones, false)));
        pestanas.addTab("Por fase", new JScrollPane(Tablas.crear(fases, false)));
        pestanas.addTab("Incidencias por fase y estadio", new JScrollPane(Tablas.crear(incidencias, false)));
        add(pestanas, BorderLayout.CENTER);

        Tablas.cargarEdiciones(this, ediciones);
        cargar();
    }

    private void cargar() {
        goleadores.setRowCount(0);
        selecciones.setRowCount(0);
        fases.setRowCount(0);
        incidencias.setRowCount(0);
        Edicion edicion = (Edicion) ediciones.getSelectedItem();
        if (edicion == null) {
            return;
        }
        int id = edicion.getIdEdicion();
        try {
            for (FilaGoleador f : repository.consultarGoleadores(id, (Integer) top.getSelectedItem())) {
                goleadores.addRow(new Object[] {f.getPosicion(), f.getNombre(), f.getPais(), f.getGoles()});
            }
            for (FilaSeleccion f : repository.consultarSelecciones(id)) {
                selecciones.addRow(new Object[] {f.getPais(), f.getGrupo() == null ? "" : f.getGrupo(),
                    f.getJugados(), f.getGanados(), f.getEmpatados(), f.getPerdidos(),
                    f.getGolesFavor(), f.getGolesContra(), f.getDiferencia()});
            }
            for (FilaFase f : repository.consultarFases(id)) {
                fases.addRow(new Object[] {f.getFase(), f.getPartidos(), f.getGoles(),
                    f.getPromedioGoles(), f.getAsistencia()});
            }
            for (FilaIncidenciasEstadio f : repository.consultarIncidenciasPorEstadio(id)) {
                incidencias.addRow(new Object[] {f.getFase(), f.getEstadio(), f.getIncidencias()});
            }
        } catch (SQLException ex) {
            Tablas.error(this, ex);
        }
    }
}
