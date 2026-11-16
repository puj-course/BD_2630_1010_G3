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
import mundial.datos.FilaPosicion;
import mundial.datos.RepositoryConsultas;

public class PanelPosiciones extends JPanel {

    private final RepositoryConsultas repository = new RepositoryConsultas();
    private final JComboBox<Edicion> ediciones = new JComboBox<>();
    private final JComboBox<String> grupos = new JComboBox<>();
    private final DefaultTableModel modelo = Tablas.modelo(
            "Grupo", "Pos", "Seleccion", "PJ", "G", "E", "P", "GF", "GC", "DG", "Pts");

    public PanelPosiciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT));
        filtros.add(new JLabel("Edicion:"));
        filtros.add(ediciones);
        filtros.add(new JLabel("Grupo:"));
        filtros.add(grupos);
        JButton consultar = new JButton("Consultar");
        consultar.addActionListener(e -> cargar());
        filtros.add(consultar);

        JPanel norte = new JPanel(new BorderLayout());
        norte.add(new JLabel("Tabla de posiciones por grupo"), BorderLayout.NORTH);
        norte.add(filtros, BorderLayout.CENTER);
        add(norte, BorderLayout.NORTH);
        add(new JScrollPane(new JTable(modelo)), BorderLayout.CENTER);

        Tablas.cargarEdiciones(this, ediciones);
        cargarGrupos();
        ediciones.addActionListener(e -> cargarGrupos());
        cargar();
    }

    private void cargarGrupos() {
        Edicion edicion = (Edicion) ediciones.getSelectedItem();
        if (edicion == null) {
            return;
        }
        try {
            Tablas.llenarOpciones(grupos, repository.consultarGrupos(edicion.getIdEdicion()));
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
            for (FilaPosicion f : repository.consultarPosiciones(edicion.getIdEdicion(), Tablas.filtro(grupos))) {
                modelo.addRow(new Object[] {f.getGrupo(), f.getPosicion(), f.getPais(), f.getJugados(),
                    f.getGanados(), f.getEmpatados(), f.getPerdidos(), f.getGolesFavor(),
                    f.getGolesContra(), f.getDiferencia(), f.getPuntos()});
            }
        } catch (SQLException ex) {
            Tablas.error(this, ex);
        }
    }
}
