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
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.FilaResultado;
import mundial.datos.RepositoryConsultas;

public class PanelResultados extends JPanel {

    private final RepositoryConsultas repository = new RepositoryConsultas();
    private final JComboBox<Edicion> ediciones = new JComboBox<>();
    private final JComboBox<String> fases = new JComboBox<>();
    private final DefaultTableModel modelo = Tablas.modelo(
            "Fecha", "Fase", "Local", "Marcador", "Visitante", "Estadio", "Ciudad", "Asistencia");

    public PanelResultados() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Edicion:"));
        filtros.add(ediciones);
        filtros.add(new JLabel("Fase:"));
        filtros.add(fases);
        JButton consultar = new JButton("Consultar");
        consultar.addActionListener(e -> cargar());
        filtros.add(consultar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(new JLabel("Resultados de los partidos"), BorderLayout.NORTH);
        norte.add(filtros, BorderLayout.CENTER);
        add(norte, BorderLayout.NORTH);
        add(new JScrollPane(new JTable(modelo)), BorderLayout.CENTER);

        Tablas.cargarEdiciones(this, ediciones);
        cargarFases();
        ediciones.addActionListener(e -> cargarFases());
        cargar();
    }

    private void cargarFases() {
        Edicion edicion = (Edicion) ediciones.getSelectedItem();
        if (edicion == null) {
            return;
        }
        try {
            Tablas.llenarOpciones(fases, repository.consultarFases(edicion.getIdEdicion()));
        } catch (SQLException ex) {
            Tablas.error(this, ex);
        }
    }

    private void cargar() {
        modelo.setRowCount(0);
        Edicion edicion = (Edicion) ediciones.getSelectedItem();
        if (edicion == null) {
            return;
        }
        try {
            for (FilaResultado f : repository.consultarResultados(edicion.getIdEdicion(), Tablas.filtro(fases))) {
                modelo.addRow(new Object[] {Tablas.fecha(f.getFechaHora()), f.getFase(), f.getLocal(),
                    f.getMarcador(), f.getVisitante(), f.getEstadio(), f.getCiudad(),
                    f.getAsistencia() == null ? "" : f.getAsistencia()});
            }
        } catch (SQLException ex) {
            Tablas.error(this, ex);
        }
    }
}
