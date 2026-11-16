package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
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
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.RepositoryEdicion;
import mundial.datos.RepositorySede;
import mundial.datos.Sede;

public class PanelSedes extends JPanel {

    private final RepositorySede repository = new RepositorySede();
    private final RepositoryEdicion repositoryEdicion = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "Edición", "País"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    private final JLabel titulo = new JLabel("Sedes");
    private final JLabel estado = new JLabel(" ");
    // Las filas de la tabla van en el mismo orden que esta lista.
    private List<Sede> sedes = new ArrayList<>();

    public PanelSedes() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        JPanel arriba = new JPanel(new GridLayout(2, 1));
        arriba.add(titulo);
        arriba.add(new JLabel("Países que organizan cada edición. Doble clic en una fila para editarla."));
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
            sedes = repository.consultarSedes();
            for (Sede s : sedes) {
                modelo.addRow(new Object[] {s.getIdSede(), s.getAnioEdicion(), s.getPais()});
            }
            titulo.setText("Sedes (" + sedes.size() + ")");
            if (sedes.isEmpty()) {
                estado.setText("No hay sedes registradas. Use Agregar para crear la primera.");
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Sede sede = pedirDatos("Agregar sede", new Sede(0, 0, null, 0));
        if (sede == null) {
            return;
        }
        try {
            repository.insertarSede(sede);
            cargar();
            // El id lo pone la base, asi que se busca la sede por edicion y pais.
            for (int i = 0; i < sedes.size(); i++) {
                if (sedes.get(i).getIdEdicion() == sede.getIdEdicion()
                        && sedes.get(i).getPais().equalsIgnoreCase(sede.getPais().trim())) {
                    seleccionarFila(i);
                }
            }
            estado.setText("Se agregó la sede " + sede + ". Ahora puede agregar sus ciudades en Catálogos > Ciudades.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
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
            seleccionarId(sede.getIdSede());
            estado.setText("Se guardaron los cambios de la sede " + sede + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminar() {
        Sede actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "¿Eliminar la sede " + actual + "?\nEsta acción no se puede deshacer.",
                "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarSede(actual.getIdSede());
            cargar();
            estado.setText("Se eliminó la sede " + actual + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private Sede seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Primero seleccione una sede de la tabla.");
            return null;
        }
        return sedes.get(fila);
    }

    private void seleccionarId(int id) {
        for (int i = 0; i < sedes.size(); i++) {
            if (sedes.get(i).getIdSede() == id) {
                seleccionarFila(i);
            }
        }
    }

    private void seleccionarFila(int fila) {
        tabla.setRowSelectionInterval(fila, fila);
        tabla.scrollRectToVisible(tabla.getCellRect(fila, 0, true));
    }

    // Muestra el formulario. Devuelve null si el usuario cancela o deja el pais vacio.
    private Sede pedirDatos(String tituloVentana, Sede base) {
        JComboBox<Edicion> edicion = new JComboBox<>();
        try {
            for (Edicion e : repositoryEdicion.consultarEdiciones()) {
                edicion.addItem(e);
                if (e.getIdEdicion() == base.getIdEdicion()) {
                    edicion.setSelectedItem(e);
                }
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return null;
        }
        if (edicion.getItemCount() == 0) {
            Mensajes.aviso(this, "Primero cree una edición en Catálogos > Ediciones del Mundial.");
            return null;
        }
        JTextField pais = new JTextField(base.getPais() == null ? "" : base.getPais(), 20);

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Edición"));
        formulario.add(edicion);
        formulario.add(new JLabel("País"));
        formulario.add(pais);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, tituloVentana, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        if (pais.getText().isBlank()) {
            Mensajes.aviso(this, "Escriba el nombre del país.");
            return null;
        }
        Edicion elegida = (Edicion) edicion.getSelectedItem();
        return new Sede(base.getIdSede(), elegida.getIdEdicion(), pais.getText().trim(), elegida.getAnio());
    }
}
