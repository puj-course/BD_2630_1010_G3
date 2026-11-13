package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.sql.SQLException;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.RepositoryEdicion;

public class PanelEdiciones extends JPanel {

    private final RepositoryEdicion repository = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Anio", "Lema", "Inicio", "Fin"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };

    public PanelEdiciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        add(new JLabel("Ediciones del Mundial"), BorderLayout.NORTH);
        add(new JScrollPane(new JTable(modelo)), BorderLayout.CENTER);

        JButton recargar = new JButton("Recargar");
        recargar.addActionListener(e -> cargar());
        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT));
        botones.add(recargar);
        add(botones, BorderLayout.SOUTH);

        cargar();
    }

    private void cargar() {
        modelo.setRowCount(0);
        try {
            for (Edicion e : repository.consultarEdiciones()) {
                modelo.addRow(new Object[] {e.getIdEdicion(), e.getAnio(), e.getLema(), e.getFechaInicio(), e.getFechaFin()});
            }
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
}
