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
    private final JLabel titulo = new JLabel("Ciudades");
    private final JLabel estado = new JLabel(" ");
    private List<Ciudad> ciudades = new ArrayList<>();

    public PanelCiudades() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        JPanel arriba = new JPanel(new GridLayout(2, 1));
        arriba.add(titulo);
        arriba.add(new JLabel("Ciudades de cada país sede. Doble clic en una fila para editarla."));
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
            ciudades = repository.consultarCiudades();
            for (Ciudad c : ciudades) {
                modelo.addRow(new Object[] {c.getIdCiudad(), c.getNombre(), c.getSede()});
            }
            titulo.setText("Ciudades (" + ciudades.size() + ")");
            if (ciudades.isEmpty()) {
                estado.setText("No hay ciudades registradas. Use Agregar para crear la primera.");
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Ciudad ciudad = pedirDatos("Agregar ciudad", new Ciudad(0, 0, null, null));
        if (ciudad == null) {
            return;
        }
        try {
            repository.insertarCiudad(ciudad);
            cargar();
            for (int i = 0; i < ciudades.size(); i++) {
                if (ciudades.get(i).getIdSede() == ciudad.getIdSede()
                        && ciudades.get(i).getNombre().equalsIgnoreCase(ciudad.getNombre())) {
                    seleccionarFila(i);
                }
            }
            estado.setText("Se agregó la ciudad " + ciudad.getNombre()
                    + ". Ahora puede agregar sus estadios en Catálogos > Estadios.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
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
            seleccionarId(ciudad.getIdCiudad());
            estado.setText("Se guardaron los cambios de la ciudad " + ciudad.getNombre() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminar() {
        Ciudad actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "¿Eliminar la ciudad " + actual.getNombre() + "?\nEsta acción no se puede deshacer.",
                "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarCiudad(actual.getIdCiudad());
            cargar();
            estado.setText("Se eliminó la ciudad " + actual.getNombre() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private Ciudad seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Primero seleccione una ciudad de la tabla.");
            return null;
        }
        return ciudades.get(fila);
    }

    private void seleccionarId(int id) {
        for (int i = 0; i < ciudades.size(); i++) {
            if (ciudades.get(i).getIdCiudad() == id) {
                seleccionarFila(i);
            }
        }
    }

    private void seleccionarFila(int fila) {
        tabla.setRowSelectionInterval(fila, fila);
        tabla.scrollRectToVisible(tabla.getCellRect(fila, 0, true));
    }

    private Ciudad pedirDatos(String tituloVentana, Ciudad base) {
        JComboBox<Sede> sede = new JComboBox<>();
        try {
            for (Sede s : repositorySede.consultarSedes()) {
                sede.addItem(s);
                if (s.getIdSede() == base.getIdSede()) {
                    sede.setSelectedItem(s);
                }
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return null;
        }
        if (sede.getItemCount() == 0) {
            Mensajes.aviso(this, "Primero cree una sede en Catálogos > Sedes.");
            return null;
        }
        JTextField nombre = new JTextField(base.getNombre() == null ? "" : base.getNombre(), 20);

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Sede"));
        formulario.add(sede);
        formulario.add(new JLabel("Nombre"));
        formulario.add(nombre);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, tituloVentana, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        if (nombre.getText().isBlank()) {
            Mensajes.aviso(this, "Escriba el nombre de la ciudad.");
            return null;
        }
        Sede elegida = (Sede) sede.getSelectedItem();
        return new Ciudad(base.getIdCiudad(), elegida.getIdSede(), nombre.getText().trim(), elegida.toString());
    }
}
