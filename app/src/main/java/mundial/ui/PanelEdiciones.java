package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.RepositoryEdicion;

public class PanelEdiciones extends JPanel {

    private final RepositoryEdicion repository = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Año", "Lema", "Inicio", "Fin"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    private final JLabel titulo = new JLabel("Ediciones del Mundial");
    private final JLabel estado = new JLabel(" ");
    private List<Edicion> ediciones = new ArrayList<>();

    public PanelEdiciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        JPanel arriba = new JPanel(new GridLayout(2, 1));
        arriba.add(titulo);
        arriba.add(new JLabel("Cada fila es un Mundial completo. Doble clic en una fila para editarla."));
        add(arriba, BorderLayout.NORTH);
        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton agregar = new JButton("Agregar");
        JButton editar = new JButton("Editar");
        JButton eliminar = new JButton("Eliminar");
        JButton recargar = new JButton("Recargar");
        agregar.addActionListener(e -> agregar());
        editar.addActionListener(e -> editar());
        eliminar.addActionListener(e -> eliminar());
        recargar.addActionListener(e -> {
            cargar();
            estado.setText("Lista actualizada.");
        });
        tabla.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    editar();
                }
            }
        });

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        botones.add(agregar);
        botones.add(editar);
        botones.add(eliminar);
        botones.add(recargar);
        JPanel abajo = new JPanel(new BorderLayout(0, 8));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estado, BorderLayout.SOUTH);
        add(abajo, BorderLayout.SOUTH);

        cargar();
    }

    private void cargar() {
        modelo.setRowCount(0);
        try {
            ediciones = repository.consultarEdiciones();
            for (Edicion e : ediciones) {
                modelo.addRow(new Object[] {e.getIdEdicion(), e.getAnio(), e.getLema(), e.getFechaInicio(), e.getFechaFin()});
            }
            titulo.setText("Ediciones del Mundial (" + ediciones.size() + ")");
            if (ediciones.isEmpty()) {
                estado.setText("No hay ediciones registradas. Use Agregar para crear la primera.");
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Edicion edicion = pedirDatos("Agregar edición", new Edicion(0, 0, null, null, null));
        if (edicion == null) {
            return;
        }
        try {
            repository.insertarEdicion(edicion);
            cargar();
            // El anio no se repite (uq_edicion_anio), asi que sirve para encontrar la fila nueva.
            for (int i = 0; i < ediciones.size(); i++) {
                if (ediciones.get(i).getAnio() == edicion.getAnio()) {
                    seleccionarFila(i);
                }
            }
            estado.setText("Se agregó el Mundial " + edicion.getAnio()
                    + ". Ahora puede agregar sus países sede en Catálogos > Sedes.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editar() {
        Edicion actual = seleccionada();
        if (actual == null) {
            return;
        }
        Edicion edicion = pedirDatos("Editar Mundial " + actual.getAnio(), actual);
        if (edicion == null) {
            return;
        }
        try {
            repository.actualizarEdicion(edicion);
            cargar();
            seleccionarId(edicion.getIdEdicion());
            estado.setText("Se guardaron los cambios del Mundial " + edicion.getAnio() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminar() {
        Edicion actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "¿Eliminar el Mundial " + actual.getAnio() + "?\nEsta acción no se puede deshacer.",
                "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarEdicion(actual.getIdEdicion());
            cargar();
            estado.setText("Se eliminó el Mundial " + actual.getAnio() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private Edicion seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Primero seleccione una edición de la tabla.");
            return null;
        }
        return ediciones.get(fila);
    }

    private void seleccionarId(int id) {
        for (int i = 0; i < ediciones.size(); i++) {
            if (ediciones.get(i).getIdEdicion() == id) {
                seleccionarFila(i);
            }
        }
    }

    private void seleccionarFila(int fila) {
        tabla.setRowSelectionInterval(fila, fila);
        tabla.scrollRectToVisible(tabla.getCellRect(fila, 0, true));
    }

    // Muestra el formulario. Devuelve null si el usuario cancela o escribe mal un dato.
    private Edicion pedirDatos(String tituloVentana, Edicion base) {
        JTextField anio = new JTextField(base.getAnio() == 0 ? "" : String.valueOf(base.getAnio()), 20);
        JTextField lema = new JTextField(base.getLema() == null ? "" : base.getLema());
        JTextField inicio = new JTextField(base.getFechaInicio() == null ? "" : base.getFechaInicio().toString());
        JTextField fin = new JTextField(base.getFechaFin() == null ? "" : base.getFechaFin().toString());

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Año"));
        formulario.add(anio);
        formulario.add(new JLabel("Lema (opcional)"));
        formulario.add(lema);
        formulario.add(new JLabel("Fecha de inicio (AAAA-MM-DD)"));
        formulario.add(inicio);
        formulario.add(new JLabel("Fecha de fin (AAAA-MM-DD)"));
        formulario.add(fin);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, tituloVentana, JOptionPane.OK_CANCEL_OPTION);
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
            Mensajes.aviso(this, "El año debe ser un número y las fechas deben ir como AAAA-MM-DD, por ejemplo 2026-06-11.");
            return null;
        }
    }
}
