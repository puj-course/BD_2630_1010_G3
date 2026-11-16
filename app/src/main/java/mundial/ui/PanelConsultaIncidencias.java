package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.sql.SQLException;
import java.util.List;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.FilaIncidencia;
import mundial.datos.RepositoryConsultas;

public class PanelConsultaIncidencias extends JPanel {

    // Los mismos valores del CHECK ck_incidencia_tipo
    private static final List<String> TIPOS = List.of("TARJETA", "LESION", "VAR", "INVASION", "SUSPENSION", "OTRO");

    private final RepositoryConsultas repository = new RepositoryConsultas();
    private final JComboBox<Edicion> ediciones = new JComboBox<>();
    private final JComboBox<String> fases = new JComboBox<>();
    private final JComboBox<String> tipos = new JComboBox<>();
    private final JLabel total = new JLabel();
    private final DefaultTableModel modelo = Tablas.modelo(
            "Fecha", "Fase", "Partido", "Estadio", "Minuto", "Tipo", "Descripcion");

    public PanelConsultaIncidencias() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Edicion:"));
        filtros.add(ediciones);
        filtros.add(new JLabel("Fase:"));
        filtros.add(fases);
        filtros.add(new JLabel("Tipo:"));
        filtros.add(tipos);
        JButton consultar = new JButton("Consultar");
        consultar.addActionListener(e -> cargar());
        filtros.add(consultar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(Tablas.titulo("Incidencias de los partidos"), BorderLayout.NORTH);
        norte.add(filtros, BorderLayout.CENTER);
        add(norte, BorderLayout.NORTH);
        add(new JScrollPane(Tablas.crear(modelo, false)), BorderLayout.CENTER);
        add(total, BorderLayout.SOUTH);

        Tablas.llenarOpciones(tipos, TIPOS);
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
            List<FilaIncidencia> filas = repository.consultarIncidencias(
                    edicion.getIdEdicion(), Tablas.filtro(fases), Tablas.filtro(tipos));
            for (FilaIncidencia f : filas) {
                modelo.addRow(new Object[] {Tablas.fecha(f.getFechaHora()), f.getFase(), f.getPartido(),
                    f.getEstadio(), f.getMinuto(), f.getTipo(), f.getDescripcion()});
            }
            total.setText("Total: " + filas.size() + " incidencias");
        } catch (SQLException ex) {
            Tablas.error(this, ex);
        }
    }
}
