package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.sql.Date;
import java.sql.SQLException;
import javax.swing.BorderFactory;
import javax.swing.JButton;
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

public class PanelEdiciones extends JPanel {

    private final RepositoryEdicion repository = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Anio", "Lema", "Inicio", "Fin"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);

    public PanelEdiciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        tabla.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        add(new JLabel("Ediciones del Mundial"), BorderLayout.NORTH);
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
            for (Edicion e : repository.consultarEdiciones()) {
                modelo.addRow(new Object[] {e.getIdEdicion(), e.getAnio(), e.getLema(), e.getFechaInicio(), e.getFechaFin()});
            }
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void nueva() {
        Edicion edicion = pedirDatos("Nueva edicion", new Edicion(0, 0, null, null, null));
        if (edicion == null) {
            return;
        }
        try {
            repository.insertarEdicion(edicion);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void editar() {
        Edicion actual = seleccionada();
        if (actual == null) {
            return;
        }
        Edicion edicion = pedirDatos("Editar edicion " + actual.getAnio(), actual);
        if (edicion == null) {
            return;
        }
        try {
            repository.actualizarEdicion(edicion);
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private void eliminar() {
        Edicion actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "Eliminar la edicion " + actual.getAnio() + "?", "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarEdicion(actual.getIdEdicion());
            cargar();
        } catch (SQLException ex) {
            mostrarError(ex.getMessage());
        }
    }

    private Edicion seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            JOptionPane.showMessageDialog(this, "Seleccione una edicion de la tabla.");
            return null;
        }
        return new Edicion(
                (Integer) modelo.getValueAt(fila, 0),
                (Integer) modelo.getValueAt(fila, 1),
                (String) modelo.getValueAt(fila, 2),
                (Date) modelo.getValueAt(fila, 3),
                (Date) modelo.getValueAt(fila, 4));
    }

    // Muestra el formulario. Devuelve null si el usuario cancela o escribe mal un dato.
    private Edicion pedirDatos(String titulo, Edicion base) {
        JTextField anio = new JTextField(base.getAnio() == 0 ? "" : String.valueOf(base.getAnio()));
        JTextField lema = new JTextField(base.getLema() == null ? "" : base.getLema());
        JTextField inicio = new JTextField(base.getFechaInicio() == null ? "" : base.getFechaInicio().toString());
        JTextField fin = new JTextField(base.getFechaFin() == null ? "" : base.getFechaFin().toString());

        JPanel formulario = new JPanel(new GridLayout(0, 2, 5, 5));
        formulario.add(new JLabel("Anio"));
        formulario.add(anio);
        formulario.add(new JLabel("Lema (opcional)"));
        formulario.add(lema);
        formulario.add(new JLabel("Fecha inicio (AAAA-MM-DD)"));
        formulario.add(inicio);
        formulario.add(new JLabel("Fecha fin (AAAA-MM-DD)"));
        formulario.add(fin);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, titulo, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        try {
            return new Edicion(
                    base.getIdEdicion(),
                    Integer.parseInt(anio.getText().trim()),
                    lema.getText(),
                    Date.valueOf(inicio.getText().trim()),
                    Date.valueOf(fin.getText().trim()));
        } catch (IllegalArgumentException ex) {
            mostrarError("El anio debe ser un numero y las fechas deben ir como AAAA-MM-DD.");
            return null;
        }
    }

    private void mostrarError(String mensaje) {
        JOptionPane.showMessageDialog(this, mensaje, "Error", JOptionPane.ERROR_MESSAGE);
    }
}
