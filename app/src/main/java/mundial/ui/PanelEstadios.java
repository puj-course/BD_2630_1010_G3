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
import mundial.datos.Estadio;
import mundial.datos.RepositoryCiudad;
import mundial.datos.RepositoryEstadio;

public class PanelEstadios extends JPanel {

    private final RepositoryEstadio repository = new RepositoryEstadio();
    private final RepositoryCiudad repositoryCiudad = new RepositoryCiudad();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Estadio", "Capacidad", "Ciudad"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    private List<Estadio> estadios = new ArrayList<>();

    public PanelEstadios() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        tabla.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        add(new JLabel("Estadios"), BorderLayout.NORTH);
        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton nuevo = new JButton("Nuevo");
        JButton editar = new JButton("Editar");
        JButton eliminar = new JButton("Eliminar");
        JButton recargar = new JButton("Recargar");
        nuevo.addActionListener(e -> nuevo());
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
            estadios = repository.consultarEstadios();
            for (Estadio e : estadios) {
                modelo.addRow(new Object[] {e.getIdEstadio(), e.getNombre(), e.getCapacidad(), e.getCiudad()});
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void nuevo() {
        Estadio estadio = pedirDatos("Nuevo estadio", new Estadio(0, 0, null, 0, null));
        if (estadio == null) {
            return;
        }
        try {
            repository.insertarEstadio(estadio);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void editar() {
        Estadio actual = seleccionado();
        if (actual == null) {
            return;
        }
        Estadio estadio = pedirDatos("Editar estadio " + actual.getNombre(), actual);
        if (estadio == null) {
            return;
        }
        try {
            repository.actualizarEstadio(estadio);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void eliminar() {
        Estadio actual = seleccionado();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "Eliminar el estadio " + actual.getNombre() + "?", "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarEstadio(actual.getIdEstadio());
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private Estadio seleccionado() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            JOptionPane.showMessageDialog(this, "Seleccione un estadio de la tabla.");
            return null;
        }
        return estadios.get(fila);
    }

    private Estadio pedirDatos(String titulo, Estadio base) {
        JComboBox<Ciudad> ciudad = new JComboBox<>();
        try {
            for (Ciudad c : repositoryCiudad.consultarCiudades()) {
                ciudad.addItem(c);
                if (c.getIdCiudad() == base.getIdCiudad()) {
                    ciudad.setSelectedItem(c);
                }
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
            return null;
        }
        JTextField nombre = new JTextField(base.getNombre() == null ? "" : base.getNombre());
        JTextField capacidad = new JTextField(base.getCapacidad() == 0 ? "" : String.valueOf(base.getCapacidad()));

        JPanel formulario = new JPanel(new GridLayout(0, 2, 5, 5));
        formulario.add(new JLabel("Ciudad"));
        formulario.add(ciudad);
        formulario.add(new JLabel("Nombre"));
        formulario.add(nombre);
        formulario.add(new JLabel("Capacidad (20000 a 150000)"));
        formulario.add(capacidad);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, titulo, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        Ciudad elegida = (Ciudad) ciudad.getSelectedItem();
        if (elegida == null || nombre.getText().isBlank()) {
            mostrarError("Escoja una ciudad y escriba el nombre del estadio.");
            return null;
        }
        try {
            return new Estadio(base.getIdEstadio(), elegida.getIdCiudad(), nombre.getText(),
                    Integer.parseInt(capacidad.getText().trim()), elegida.toString());
        } catch (NumberFormatException ex) {
            mostrarError("La capacidad debe ser un numero.");
            return null;
        }
    }

    private void mostrarError(String mensaje) {
        JOptionPane.showMessageDialog(this, mensaje, "Error", JOptionPane.ERROR_MESSAGE);
    }
}
