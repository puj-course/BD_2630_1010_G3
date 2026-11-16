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
import mundial.datos.Incidencia;
import mundial.datos.Partido;
import mundial.datos.RepositoryIncidencia;
import mundial.datos.RepositoryPartido;

public class PanelIncidencias extends JPanel {

    private final RepositoryIncidencia repository = new RepositoryIncidencia();
    private final RepositoryPartido repoPartido = new RepositoryPartido();

    private final DefaultTableModel modelo = Tablas.modelo("Id", "Minuto", "Tipo", "Descripción");
    private final JTable tabla = Tablas.crear(modelo, true);
    private final JComboBox<Edicion> comboEdiciones = new JComboBox<>();
    private final JComboBox<Partido> comboPartidos = new JComboBox<>();
    private final JLabel titulo = new JLabel("Incidencias del Partido");
    private final JLabel estado = new JLabel(" ");

    private List<Incidencia> incidencias = new ArrayList<>();
    private List<Partido> partidos = new ArrayList<>();

    private static final String[] TIPOS_INCIDENCIA = {"TARJETA", "LESION", "VAR", "INVASION", "SUSPENSION", "OTRO"};

    public PanelIncidencias() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        Estilo.titulo(titulo);

        JPanel encabezado = new JPanel(new GridLayout(2, 1, 0, 4));
        encabezado.add(titulo);
        encabezado.add(new JLabel("Registro de eventos disciplinarios, médicos y arbitrales ocurridos durante el juego."));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
        filtros.add(new JLabel("Edición:"));
        filtros.add(comboEdiciones);
        filtros.add(new JLabel("Partido:"));
        filtros.add(comboPartidos);

        comboEdiciones.addActionListener(e -> recargarPartidos());
        comboPartidos.addActionListener(e -> cargarIncidencias());

        JPanel arriba = new JPanel(new BorderLayout(0, 8));
        arriba.add(encabezado, BorderLayout.NORTH);
        arriba.add(filtros, BorderLayout.SOUTH);
        add(arriba, BorderLayout.NORTH);

        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton btnAgregar = new JButton("Agregar Incidencia");
        JButton btnEditar = new JButton("Editar Incidencia");
        JButton btnEliminar = new JButton("Eliminar");
        JButton btnRecargar = new JButton("Recargar");

        btnAgregar.addActionListener(e -> agregarIncidencia());
        btnEditar.addActionListener(e -> editarIncidencia());
        btnEliminar.addActionListener(e -> eliminarIncidencia());
        btnRecargar.addActionListener(e -> cargarIncidencias());

        tabla.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    editarIncidencia();
                }
            }
        });

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        botones.add(btnAgregar);
        botones.add(btnEditar);
        botones.add(btnEliminar);
        botones.add(btnRecargar);

        JPanel abajo = new JPanel(new BorderLayout(0, 4));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estado, BorderLayout.SOUTH);
        add(abajo, BorderLayout.SOUTH);

        Tablas.cargarEdiciones(this, comboEdiciones);
    }

    private void recargarPartidos() {
        comboPartidos.removeAllItems();
        Edicion ed = (Edicion) comboEdiciones.getSelectedItem();
        if (ed == null) return;

        try {
            partidos = repoPartido.consultarPartidos(ed.getIdEdicion(), null);
            for (Partido p : partidos) {
                comboPartidos.addItem(p);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void cargarIncidencias() {
        modelo.setRowCount(0);
        Partido p = (Partido) comboPartidos.getSelectedItem();
        if (p == null) {
            estado.setText("Seleccione un partido para consultar o registrar incidencias.");
            return;
        }

        try {
            incidencias = repository.consultarIncidencias(p.getIdPartido());
            for (Incidencia inc : incidencias) {
                modelo.addRow(new Object[] {
                        inc.getIdIncidencia(),
                        inc.getMinuto() + "'",
                        inc.getTipo(),
                        inc.getDescripcion() != null ? inc.getDescripcion() : ""
                });
            }
            estado.setText("Partido #" + p.getIdPartido() + ": " + incidencias.size() + " incidencia(s) registradas.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregarIncidencia() {
        Partido p = (Partido) comboPartidos.getSelectedItem();
        if (p == null) {
            Mensajes.aviso(this, "Seleccione primero un partido.");
            return;
        }

        JComboBox<String> cboTipo = new JComboBox<>(TIPOS_INCIDENCIA);
        JTextField txtMinuto = new JTextField("45", 5);
        JTextField txtDescripcion = new JTextField(25);

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Partido:"));
        form.add(new JLabel(p.toString()));
        form.add(new JLabel("Tipo de incidencia:"));
        form.add(cboTipo);
        form.add(new JLabel("Minuto (0-120):"));
        form.add(txtMinuto);
        form.add(new JLabel("Descripción (opcional):"));
        form.add(txtDescripcion);

        int opt = JOptionPane.showConfirmDialog(this, form, "Nueva Incidencia", JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        int minuto;
        try {
            minuto = Integer.parseInt(txtMinuto.getText().trim());
            if (minuto < 0 || minuto > 120) {
                Mensajes.aviso(this, "El minuto debe estar entre 0 y 120.");
                return;
            }
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "El minuto debe ser un número entero.");
            return;
        }

        Incidencia inc = new Incidencia(0, p.getIdPartido(), (String) cboTipo.getSelectedItem(), minuto, txtDescripcion.getText().trim(), p.toString());
        try {
            repository.insertarIncidencia(inc);
            cargarIncidencias();
            estado.setText("Incidencia registrada al minuto " + minuto + "'.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editarIncidencia() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione una incidencia de la tabla.");
            return;
        }

        Incidencia actual = incidencias.get(fila);

        JComboBox<String> cboTipo = new JComboBox<>(TIPOS_INCIDENCIA);
        cboTipo.setSelectedItem(actual.getTipo());
        JTextField txtMinuto = new JTextField(String.valueOf(actual.getMinuto()), 5);
        JTextField txtDescripcion = new JTextField(actual.getDescripcion() != null ? actual.getDescripcion() : "", 25);

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Tipo de incidencia:"));
        form.add(cboTipo);
        form.add(new JLabel("Minuto (0-120):"));
        form.add(txtMinuto);
        form.add(new JLabel("Descripción:"));
        form.add(txtDescripcion);

        int opt = JOptionPane.showConfirmDialog(this, form, "Editar Incidencia #" + actual.getIdIncidencia(), JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        try {
            int minuto = Integer.parseInt(txtMinuto.getText().trim());
            if (minuto < 0 || minuto > 120) {
                Mensajes.aviso(this, "El minuto debe estar entre 0 y 120.");
                return;
            }
            actual.setTipo((String) cboTipo.getSelectedItem());
            actual.setMinuto(minuto);
            actual.setDescripcion(txtDescripcion.getText().trim());

            repository.actualizarIncidencia(actual);
            cargarIncidencias();
            estado.setText("Incidencia #" + actual.getIdIncidencia() + " actualizada.");
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "El minuto debe ser un número entero.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarIncidencia() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione una incidencia de la tabla.");
            return;
        }
        Incidencia actual = incidencias.get(fila);
        int resp = JOptionPane.showConfirmDialog(this, "¿Eliminar la incidencia #" + actual.getIdIncidencia() + " (" + actual.getTipo() + ")?",
                "Confirmar eliminación", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repository.eliminarIncidencia(actual.getIdIncidencia());
            cargarIncidencias();
            estado.setText("Incidencia #" + actual.getIdIncidencia() + " eliminada.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }
}
