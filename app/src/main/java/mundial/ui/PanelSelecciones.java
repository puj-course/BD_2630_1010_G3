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
import mundial.datos.RepositorySeleccion;
import mundial.datos.RepositorySeleccion.OpcionGrupo;
import mundial.datos.Seleccion;

public class PanelSelecciones extends JPanel {

    private static final String[] CONFEDERACIONES = {"CONMEBOL", "UEFA", "CAF", "AFC", "CONCACAF", "OFC"};
    private static final String SIN_GRUPO = "Sin grupo";

    private final RepositorySeleccion repository = new RepositorySeleccion();
    private final RepositoryEdicion repositoryEdicion = new RepositoryEdicion();
    private final DefaultTableModel modelo = new DefaultTableModel(
            new String[] {"Id", "País", "Confederación", "Edición", "Grupo"}, 0) {
        @Override
        public boolean isCellEditable(int fila, int columna) {
            return false;
        }
    };
    private final JTable tabla = new JTable(modelo);
    private final JLabel titulo = new JLabel("Selecciones y grupos");
    private final JLabel estado = new JLabel(" ");
    private List<Seleccion> selecciones = new ArrayList<>();

    public PanelSelecciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        JPanel arriba = new JPanel(new GridLayout(2, 1));
        arriba.add(titulo);
        arriba.add(new JLabel("Selecciones de cada edición y el grupo al que pertenecen. Doble clic en una fila para editarla."));
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
            selecciones = repository.consultarSelecciones();
            for (Seleccion s : selecciones) {
                String grupo = s.getGrupo() == null ? SIN_GRUPO : "Grupo " + s.getGrupo();
                modelo.addRow(new Object[] {s.getIdSeleccion(), s.getPais(), s.getConfederacion(), s.getAnio(), grupo});
            }
            titulo.setText("Selecciones y grupos (" + selecciones.size() + ")");
            if (selecciones.isEmpty()) {
                estado.setText("No hay selecciones registradas. Use Agregar para crear la primera.");
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Seleccion seleccion = pedirDatos("Agregar selección", new Seleccion(0, 0, 0, null, null, 0, null));
        if (seleccion == null) {
            return;
        }
        try {
            repository.insertarSeleccion(seleccion);
            cargar();
            for (int i = 0; i < selecciones.size(); i++) {
                if (selecciones.get(i).getIdEdicion() == seleccion.getIdEdicion()
                        && selecciones.get(i).getPais().equalsIgnoreCase(seleccion.getPais())) {
                    seleccionarFila(i);
                }
            }
            estado.setText("Se agregó la selección " + seleccion.getPais() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editar() {
        Seleccion actual = seleccionada();
        if (actual == null) {
            return;
        }
        Seleccion seleccion = pedirDatos("Editar selección " + actual.getPais(), actual);
        if (seleccion == null) {
            return;
        }
        try {
            repository.actualizarSeleccion(seleccion);
            cargar();
            seleccionarId(seleccion.getIdSeleccion());
            estado.setText("Se guardaron los cambios de la selección " + seleccion.getPais() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminar() {
        Seleccion actual = seleccionada();
        if (actual == null) {
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this,
                "¿Eliminar la selección " + actual.getPais() + "?\nEsta acción no se puede deshacer.",
                "Confirmar", JOptionPane.YES_NO_OPTION);
        if (respuesta != JOptionPane.YES_OPTION) {
            return;
        }
        try {
            repository.eliminarSeleccion(actual.getIdSeleccion());
            cargar();
            estado.setText("Se eliminó la selección " + actual.getPais() + ".");
        } catch (SQLException ex) {
            // Si la seleccion ya tiene partidos o jugadores, Oracle no deja borrarla y Mensajes lo explica.
            Mensajes.error(this, ex);
        }
    }

    private Seleccion seleccionada() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Primero seleccione una selección de la tabla.");
            return null;
        }
        return selecciones.get(fila);
    }

    private void seleccionarId(int id) {
        for (int i = 0; i < selecciones.size(); i++) {
            if (selecciones.get(i).getIdSeleccion() == id) {
                seleccionarFila(i);
            }
        }
    }

    private void seleccionarFila(int fila) {
        tabla.setRowSelectionInterval(fila, fila);
        tabla.scrollRectToVisible(tabla.getCellRect(fila, 0, true));
    }

    private Seleccion pedirDatos(String tituloVentana, Seleccion base) {
        JComboBox<Edicion> edicion = new JComboBox<>();
        JComboBox<Object> grupo = new JComboBox<>();
        grupo.addItem(SIN_GRUPO);
        try {
            for (Edicion e : repositoryEdicion.consultarEdiciones()) {
                edicion.addItem(e);
                if (e.getIdEdicion() == base.getIdEdicion()) {
                    edicion.setSelectedItem(e);
                }
            }
            for (OpcionGrupo g : repository.consultarGrupos()) {
                grupo.addItem(g);
                if (g.getIdGrupo() == base.getIdGrupo()) {
                    grupo.setSelectedItem(g);
                }
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return null;
        }
        if (edicion.getItemCount() == 0) {
            Mensajes.aviso(this, "Primero cree una edición en Catálogos > Ediciones.");
            return null;
        }
        JComboBox<String> confederacion = new JComboBox<>(CONFEDERACIONES);
        if (base.getConfederacion() != null) {
            confederacion.setSelectedItem(base.getConfederacion());
        }
        JTextField pais = new JTextField(base.getPais() == null ? "" : base.getPais(), 20);

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Edición"));
        formulario.add(edicion);
        formulario.add(new JLabel("País"));
        formulario.add(pais);
        formulario.add(new JLabel("Confederación"));
        formulario.add(confederacion);
        formulario.add(new JLabel("Grupo"));
        formulario.add(grupo);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, tituloVentana, JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return null;
        }
        if (pais.getText().isBlank()) {
            Mensajes.aviso(this, "Escriba el país de la selección.");
            return null;
        }
        Edicion edicionElegida = (Edicion) edicion.getSelectedItem();
        int idGrupo = 0;
        if (grupo.getSelectedItem() instanceof OpcionGrupo) {
            OpcionGrupo grupoElegido = (OpcionGrupo) grupo.getSelectedItem();
            // El grupo tiene que ser de la misma edicion que la seleccion.
            if (grupoElegido.getIdEdicion() != edicionElegida.getIdEdicion()) {
                Mensajes.aviso(this, "El grupo elegido es de otra edición. Escoja un grupo de la misma edición.");
                return null;
            }
            idGrupo = grupoElegido.getIdGrupo();
        }
        return new Seleccion(base.getIdSeleccion(), edicionElegida.getIdEdicion(), idGrupo,
                pais.getText().trim(), (String) confederacion.getSelectedItem(), 0, null);
    }
}
