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
import mundial.datos.Edicion;
import mundial.datos.RepositoryEdicion;
import mundial.datos.RepositorySede;
import mundial.datos.Sede;

public class PanelSedes extends JPanel {

    private final RepositorySede repository = new RepositorySede();
    private final RepositoryEdicion repositoryEdicion = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Edicion", "Pais"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    // Las filas de la tabla van en el mismo orden que esta lista.
    private List<Sede> sedes = new ArrayList<>();

    public PanelSedes() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        tabla.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        add(new JLabel("Paises sede de cada edicion"), BorderLayout.NORTH);
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
            sedes = repository.consultarSedes();
            for (Sede s : sedes) {
                modelo.addRow(new Object[] {s.getIdSede(), s.getAnioEdicion(), s.getPais()});
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void nueva() {
        Sede sede = pedirDatos("Nueva sede", new Sede(0, 0, null, 0));
        if (sede == null) {
            return;
        }
        try {
            repository.insertarSede(sede);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void editar() {
        Sede actual = seleccionada();
        if (actual == null) {
            return;
        }
        Sede sede = pedirDatos("Editar sede " + actual, actual);
        if (sede == null) {
            return;
        }
        try {
            repository.actualizarSede(sede);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void eliminar() {
        Sede actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "Eliminar la sede " + actual + "?", "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarSede(actual.getIdSede());
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private Sede seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            JOptionPane.showMessageDialog(this, "Seleccione una sede de la tabla.");
            return null;
        }
        return sedes.get(fila);
    }

    // Muestra el formulario. Devuelve null si el usuario cancela o deja el pais vacio.
    private Sede pedirDatos(String titulo, Sede base) {
        JComboBox<Edicion> edicion = new JComboBox<>();
        try {
            for (Edicion e : repositoryEdicion.consultarEdiciones()) {
                edicion.addItem(e);
                if (e.getIdEdicion() == base.getIdEdicion()) {
                    edicion.setSelectedItem(e);
                }
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
            return null;
        }
        JTextField pais = new JTextField(base.getPais() == null ? "" : base.getPais());

        JPanel formulario = new JPanel(new GridLayout(0, 2, 5, 5));
        formulario.add(new JLabel("Edicion"));
        formulario.add(edicion);
        formulario.add(new JLabel("Pais"));
        formulario.add(pais);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, titulo, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        Edicion elegida = (Edicion) edicion.getSelectedItem();
        if (elegida == null || pais.getText().isBlank()) {
            mostrarError("Escoja una edicion y escriba el pais.");
            return null;
        }
        return new Sede(base.getIdSede(), elegida.getIdEdicion(), pais.getText(), elegida.getAnio());
    }

    private void mostrarError(String mensaje) {
        JOptionPane.showMessageDialog(this, mensaje, "Error", JOptionPane.ERROR_MESSAGE);
    }
}
