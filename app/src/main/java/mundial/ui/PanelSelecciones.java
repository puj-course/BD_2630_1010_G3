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
import mundial.datos.RepositorySeleccion;
import mundial.datos.RepositorySeleccion.Opcion;
import mundial.datos.Seleccion;

public class PanelSelecciones extends JPanel {

    private static final String[] CONFEDERACIONES = {"CONMEBOL", "UEFA", "CAF", "AFC", "CONCACAF", "OFC"};
    private static final String[] LETRAS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"};
    private static final String SIN_GRUPO = "Sin grupo";

    private final RepositorySeleccion repository = new RepositorySeleccion();
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
    private final JComboBox<Edicion> edicion = new JComboBox<>();
    private List<Seleccion> selecciones = new ArrayList<>();

    public PanelSelecciones() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        Estilo.titulo(titulo);
        Estilo.tabla(tabla);
        Tablas.cargarEdiciones(this, edicion);
        edicion.addActionListener(e -> cargar());

        JPanel filtro = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        filtro.add(new JLabel("Edición: "));
        filtro.add(edicion);
        JPanel arriba = new JPanel(new GridLayout(3, 1, 0, 4));
        arriba.add(titulo);
        arriba.add(new JLabel("Selecciones de la edición y el grupo al que pertenecen. Doble clic en una fila para editarla."));
        arriba.add(filtro);
        add(arriba, BorderLayout.NORTH);
        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton agregar = new JButton("Agregar");
        JButton editar = new JButton("Editar");
        JButton eliminar = new JButton("Eliminar");
        JButton agregarGrupo = new JButton("Agregar grupo");
        JButton eliminarGrupo = new JButton("Eliminar grupo");
        JButton recargar = new JButton("Recargar");
        agregar.addActionListener(e -> agregar());
        editar.addActionListener(e -> editar());
        eliminar.addActionListener(e -> eliminar());
        agregarGrupo.addActionListener(e -> agregarGrupo());
        eliminarGrupo.addActionListener(e -> eliminarGrupo());
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
        botones.add(agregarGrupo);
        botones.add(eliminarGrupo);
        botones.add(recargar);
        JPanel abajo = new JPanel(new BorderLayout(0, 8));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estado, BorderLayout.SOUTH);
        add(abajo, BorderLayout.SOUTH);

        cargar();
    }

    private Edicion edicionElegida() {
        return (Edicion) edicion.getSelectedItem();
    }

    private void cargar() {
        modelo.setRowCount(0);
        selecciones = new ArrayList<>();
        Edicion actual = edicionElegida();
        if (actual == null) {
            estado.setText("Primero cree una edición en Catálogos > Ediciones.");
            return;
        }
        try {
            selecciones = repository.consultarSelecciones(actual.getIdEdicion());
            for (Seleccion s : selecciones) {
                String grupo = s.getGrupo() == null ? SIN_GRUPO : "Grupo " + s.getGrupo();
                modelo.addRow(new Object[] {s.getIdSeleccion(), s.getPais(), s.getConfederacion(), s.getAnio(), grupo});
            }
            titulo.setText("Selecciones y grupos (" + selecciones.size() + ")");
            estado.setText(selecciones.isEmpty() ? "No hay selecciones en esta edición. Use Agregar para crear la primera." : " ");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregar() {
        Edicion actual = edicionElegida();
        if (actual == null) {
            return;
        }
        Seleccion seleccion = pedirDatos("Agregar selección", new Seleccion(0, actual.getIdEdicion(), 0, null, null, 0, null));
        if (seleccion == null) {
            return;
        }
        try {
            repository.insertarSeleccion(seleccion);
            cargar();
            for (int i = 0; i < selecciones.size(); i++) {
                if (selecciones.get(i).getPais().equalsIgnoreCase(seleccion.getPais())) {
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
            // Si la seleccion ya tiene partidos o jugadores, Oracle no deja borrarla y Mensajes lo explica
            Mensajes.error(this, ex);
        }
    }

    private void agregarGrupo() {
        Edicion actual = edicionElegida();
        if (actual == null) {
            return;
        }
        JComboBox<Opcion> fase = new JComboBox<>();
        try {
            for (Opcion f : repository.consultarFasesDeGrupos(actual.getIdEdicion())) {
                fase.addItem(f);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return;
        }
        if (fase.getItemCount() == 0) {
            Mensajes.aviso(this, "Esta edición no tiene una fase de grupos.");
            return;
        }
        JComboBox<String> letra = new JComboBox<>(LETRAS);

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Fase"));
        formulario.add(fase);
        formulario.add(new JLabel("Letra del grupo"));
        formulario.add(letra);

        int respuesta = JOptionPane.showConfirmDialog(this, formulario, "Agregar grupo", JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return;
        }
        try {
            // Si la letra ya existe en esa fase, la restriccion uq_grupo_nombre lo impide
            repository.insertarGrupo(((Opcion) fase.getSelectedItem()).getId(), (String) letra.getSelectedItem());
            estado.setText("Se agregó el grupo " + letra.getSelectedItem() + ".");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarGrupo() {
        Edicion actual = edicionElegida();
        if (actual == null) {
            return;
        }
        JComboBox<Opcion> grupo = new JComboBox<>();
        try {
            for (Opcion g : repository.consultarGrupos(actual.getIdEdicion())) {
                grupo.addItem(g);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return;
        }
        if (grupo.getItemCount() == 0) {
            Mensajes.aviso(this, "Esta edición no tiene grupos.");
            return;
        }
        int respuesta = JOptionPane.showConfirmDialog(this, grupo, "Eliminar grupo", JOptionPane.OK_CANCEL_OPTION);
        if (respuesta != JOptionPane.OK_OPTION) {
            return;
        }
        Opcion elegido = (Opcion) grupo.getSelectedItem();
        try {
            // Si el grupo tiene selecciones, Oracle no deja borrarlo y Mensajes lo explica
            repository.eliminarGrupo(elegido.getId());
            cargar();
            estado.setText("Se eliminó el " + elegido + ".");
        } catch (SQLException ex) {
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

    // La edicion es la del filtro; solo se muestran los grupos de esa edicion
    private Seleccion pedirDatos(String tituloVentana, Seleccion base) {
        JComboBox<Object> grupo = new JComboBox<>();
        grupo.addItem(SIN_GRUPO);
        try {
            for (Opcion g : repository.consultarGrupos(base.getIdEdicion())) {
                grupo.addItem(g);
                if (g.getId() == base.getIdGrupo()) {
                    grupo.setSelectedItem(g);
                }
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
            return null;
        }
        JComboBox<String> confederacion = new JComboBox<>(CONFEDERACIONES);
        if (base.getConfederacion() != null) {
            confederacion.setSelectedItem(base.getConfederacion());
        }
        JTextField pais = new JTextField(base.getPais() == null ? "" : base.getPais(), 20);

        JPanel formulario = new JPanel(new GridLayout(0, 2, 8, 8));
        formulario.add(new JLabel("Edición"));
        formulario.add(new JLabel(edicionElegida().toString()));
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
        int idGrupo = 0;
        if (grupo.getSelectedItem() instanceof Opcion) {
            idGrupo = ((Opcion) grupo.getSelectedItem()).getId();
        }
        return new Seleccion(base.getIdSeleccion(), base.getIdEdicion(), idGrupo,
                pais.getText().trim(), (String) confederacion.getSelectedItem(), 0, null);
    }
}
