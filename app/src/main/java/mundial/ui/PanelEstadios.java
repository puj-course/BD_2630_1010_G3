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
    private final JLabel titulo = new JLabel("Estadios");
    private final JLabel estado = new JLabel(" ");
    private List<Estadio> estadios = new ArrayList<>();

    public PanelEstadios() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        JPanel arriba = new JPanel(new GridLayout(2, 1));
        arriba.add(titulo);
        arriba.add(new JLabel("Estadios de cada ciudad sede. Doble clic en una fila para editarla."));
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
            estadios = repository.consultarEstadios();
            for (Estadio e : estadios) {
                modelo.addRow(new Object[] {e.getIdEstadio(), e.getNombre(), e.getCapacidad(), e.getCiudad()});
            }
            titulo.setText("Estadios (" + estadios.size() + ")");
            if (estadios.isEmpty()) {
                estado.setText("No hay estadios registrados. Use Agregar para crear el primero.");
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Estadio estadio = pedirDatos("Agregar estadio", new Estadio(0, 0, null, 0, null));
        if (estadio == null) {
            return;
        }
        try {
            repository.insertarEstadio(estadio);
            cargar();
            for (int i = 0; i < estadios.size(); i++) {
                if (estadios.get(i).getIdCiudad() == estadio.getIdCiudad()
                        && estadios.get(i).getNombre().equalsIgnoreCase(estadio.getNombre())) {
                    seleccionarFila(i);
                }
            }
            estado.setText("Se agregó el estadio " + estadio.getNombre() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
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
            seleccionarId(estadio.getIdEstadio());
            estado.setText("Se guardaron los cambios del estadio " + estadio.getNombre() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminar() {
        Estadio actual = seleccionado();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "¿Eliminar el estadio " + actual.getNombre() + "?\nEsta acción no se puede deshacer.",
                "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarEstadio(actual.getIdEstadio());
            cargar();
            estado.setText("Se eliminó el estadio " + actual.getNombre() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private Estadio seleccionado() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Primero seleccione un estadio de la tabla.");
            return null;
        }
        return estadios.get(fila);
    }

    private void seleccionarId(int id) {
        for (int i = 0; i < estadios.size(); i++) {
            if (estadios.get(i).getIdEstadio() == id) {
                seleccionarFila(i);
            }
        }
    }

    private void seleccionarFila(int fila) {
        tabla.setRowSelectionInterval(fila, fila);
        tabla.scrollRectToVisible(tabla.getCellRect(fila, 0, true));
    }

    private Estadio pedirDatos(String tituloVentana, Estadio base) {
        JComboBox<Ciudad> ciudad = new JComboBox<>();
        try {
            for (Ciudad c : repositoryCiudad.consultarCiudades()) {
                ciudad.addItem(c);
                if (c.getIdCiudad() == base.getIdCiudad()) {
                    ciudad.setSelectedItem(c);
                }
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return null;
        }
        if (ciudad.getItemCount() == 0) {
            Mensajes.aviso(this, "Primero cree una ciudad en Catálogos > Ciudades.");
            return null;
        }
        JTextField nombre = new JTextField(base.getNombre() == null ? "" : base.getNombre(), 20);
        JTextField capacidad = new JTextField(base.getCapacidad() == 0 ? "" : String.valueOf(base.getCapacidad()));

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Ciudad"));
        formulario.add(ciudad);
        formulario.add(new JLabel("Nombre"));
        formulario.add(nombre);
        formulario.add(new JLabel("Capacidad (20.000 a 150.000)"));
        formulario.add(capacidad);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, tituloVentana, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        if (nombre.getText().isBlank()) {
            Mensajes.aviso(this, "Escriba el nombre del estadio.");
            return null;
        }
        int numero;
        try {
            numero = Integer.parseInt(capacidad.getText().trim());
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "La capacidad debe ser un número entero, sin puntos. Por ejemplo: 45000.");
            return null;
        }
        Ciudad elegida = (Ciudad) ciudad.getSelectedItem();
        return new Estadio(base.getIdEstadio(), elegida.getIdCiudad(), nombre.getText().trim(), numero, elegida.toString());
    }
}
