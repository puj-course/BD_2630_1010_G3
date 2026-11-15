package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Ciudad;
import mundial.datos.RepositoryCiudad;
import mundial.datos.RepositorySede;
import mundial.datos.Sede;

public class PanelCiudades extends JPanel {

    private final RepositoryCiudad repository = new RepositoryCiudad();
    private final RepositorySede repositorySede = new RepositorySede();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Ciudad", "Sede"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    private List<Ciudad> ciudades = new ArrayList<>();

    public PanelCiudades() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        tabla.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        add(new JLabel("Ciudades de cada sede"), BorderLayout.NORTH);
        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton nuevo = new JButton("Nueva");
        JButton editar = new JButton("Editar");
        JButton eliminar = new JButton("Eliminar");
        JButton recargar = new JButton("Recargar");
        nuevo.addActionListener(e -> nueva());
        editar.addActionListener(e -> editar());
        eliminar.addActionListener(e -> eliminar());
        recargar.addActionListener(e -> cargar());

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT));
        botones.add(nuevo);
        botones.add(editar);
        botones.add(eliminar);
        botones.add(recargar);
        add(botones, BorderLayout.SOUTH);

        cargar();
    }

    private void cargar() {
        modelo.setRowCount(0);
        try {
            ciudades = repository.consultarCiudades();
            for (Ciudad c : ciudades) {
                modelo.addRow(new Object[] {c.getIdCiudad(), c.getNombre(), c.getSede()});
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void nueva() {
        Ciudad ciudad = pedirDatos("Nueva ciudad", new Ciudad(0, 0, null, null));
        if (ciudad == null) {
            return;
        }
        try {
            repository.insertarCiudad(ciudad);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void editar() {
        Ciudad actual = seleccionada();
        if (actual == null) {
            return;
        }
        Ciudad ciudad = pedirDatos("Editar ciudad " + actual.getNombre(), actual);
        if (ciudad == null) {
            return;
        }
        try {
            repository.actualizarCiudad(ciudad);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void eliminar() {
        Ciudad actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "Eliminar la ciudad " + actual + "?", "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarCiudad(actual.getIdCiudad());
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private Ciudad seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            JOptionPane.showMessageDialog(this, "Seleccione una ciudad de la tabla.");
            return null;
        }
        return ciudades.get(fila);
    }

    private Ciudad pedirDatos(String titulo, Ciudad base) {
        JComboBox<Sede> sede = new JComboBox<>();
        try {
            for (Sede s : repositorySede.consultarSedes()) {
                sede.addItem(s);
                if (s.getIdSede() == base.getIdSede()) {
                    sede.setSelectedItem(s);
                }
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
            return null;
        }
        JTextField nombre = new JTextField(base.getNombre() == null ? "" : base.getNombre());

        JPanel formulario = new JPanel(new GridLayout(0, 2, 5, 5));
        formulario.add(new JLabel("Sede"));
        formulario.add(sede);
        formulario.add(new JLabel("Nombre"));
        formulario.add(nombre);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, titulo, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        Sede elegida = (Sede) sede.getSelectedItem();
        if (elegida == null || nombre.getText().isBlank()) {
            mostrarError("Escoja una sede y escriba el nombre de la ciudad.");
            return null;
        }
        return new Ciudad(base.getIdCiudad(), elegida.getIdSede(), nombre.getText(), elegida.toString());
    }

    private void mostrarError(String mensaje) {
        JOptionPane.showMessageDialog(this, mensaje, "Error", JOptionPane.ERROR_MESSAGE);
    }
}
