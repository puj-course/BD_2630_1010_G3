package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;
import mundial.Conexion;
import mundial.datos.ConvocatoriaJugador;
import mundial.datos.CuerpoTecnico;
import mundial.datos.Edicion;
import mundial.datos.Jugador;
import mundial.datos.RepositoryCuerpoTecnico;
import mundial.datos.RepositoryEdicion;
import mundial.datos.RepositoryJugador;
import mundial.datos.RepositoryPartido;

public class PanelJugadoresCuerpoTecnico extends JPanel {

    private final RepositoryJugador repoJugador = new RepositoryJugador();
    private final RepositoryCuerpoTecnico repoCuerpoTecnico = new RepositoryCuerpoTecnico();
    private final RepositoryEdicion repoEdicion = new RepositoryEdicion();
    private final RepositoryPartido repoPartido = new RepositoryPartido();

    // --- Pestaña 1: Jugadores ---
    private final DefaultTableModel modeloJugadores = Tablas.modelo("Id", "Nombre", "Posición", "Club");
    private final JTable tablaJugadores = Tablas.crear(modeloJugadores, true);
    private final JTextField txtBuscarJugador = new JTextField(15);
    private final JLabel estadoJugadores = new JLabel(" ");
    private List<Jugador> jugadores = new ArrayList<>();

    // --- Pestaña 2: Cuerpo Técnico ---
    private final DefaultTableModel modeloCT = Tablas.modelo("Id", "Selección", "Nombre", "Cargo");
    private final JTable tablaCT = Tablas.crear(modeloCT, true);
    private final JComboBox<Edicion> comboEdicionCT = new JComboBox<>();
    private final JComboBox<RepositoryPartido.OpcionSeleccion> comboSeleccionCT = new JComboBox<>();
    private final JLabel estadoCT = new JLabel(" ");
    private List<CuerpoTecnico> cuerpoTecnicoList = new ArrayList<>();

    // --- Pestaña 3: Convocatorias ---
    private final DefaultTableModel modeloConvocatoria = Tablas.modelo("Id", "Camiseta", "Jugador", "Posición", "Capitán");
    private final JTable tablaConvocatoria = Tablas.crear(modeloConvocatoria, true);
    private final JComboBox<Edicion> comboEdicionConv = new JComboBox<>();
    private final JComboBox<RepositoryPartido.OpcionSeleccion> comboSeleccionConv = new JComboBox<>();
    private final JLabel lblCupos = new JLabel("Cupos: 26");
    private final JLabel estadoConv = new JLabel(" ");
    private List<ConvocatoriaJugador> convocatorias = new ArrayList<>();

    public PanelJugadoresCuerpoTecnico() {
        super(new BorderLayout());
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        JTabbedPane pestanas = new JTabbedPane();
        pestanas.addTab("Jugadores", armarPanelJugadores());
        pestanas.addTab("Cuerpo Técnico", armarPanelCuerpoTecnico());
        pestanas.addTab("Convocatorias", armarPanelConvocatorias());

        add(pestanas, BorderLayout.CENTER);

        cargarJugadores();
        Tablas.cargarEdiciones(this, comboEdicionCT);
        Tablas.cargarEdiciones(this, comboEdicionConv);
    }

    // ============================================================
    // PESTAÑA 1: JUGADORES
    // ============================================================

    private JPanel armarPanelJugadores() {
        JPanel panel = new JPanel(new BorderLayout(0, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel arriba = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 4));
        arriba.add(new JLabel("Buscar jugador:"));
        arriba.add(txtBuscarJugador);
        JButton btnBuscar = new JButton("Buscar");
        btnBuscar.addActionListener(e -> cargarJugadores());
        arriba.add(btnBuscar);
        JButton btnLimpiar = new JButton("Ver todos");
        btnLimpiar.addActionListener(e -> {
            txtBuscarJugador.setText("");
            cargarJugadores();
        });
        arriba.add(btnLimpiar);

        panel.add(arriba, BorderLayout.NORTH);
        panel.add(new JScrollPane(tablaJugadores), BorderLayout.CENTER);

        JButton btnAgregar = new JButton("Agregar");
        JButton btnEditar = new JButton("Editar");
        JButton btnEliminar = new JButton("Eliminar");
        JButton btnRecargar = new JButton("Recargar");

        btnAgregar.addActionListener(e -> agregarJugador());
        btnEditar.addActionListener(e -> editarJugador());
        btnEliminar.addActionListener(e -> eliminarJugador());
        btnRecargar.addActionListener(e -> cargarJugadores());

        tablaJugadores.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    editarJugador();
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
        abajo.add(estadoJugadores, BorderLayout.SOUTH);
        panel.add(abajo, BorderLayout.SOUTH);

        return panel;
    }

    private void cargarJugadores() {
        modeloJugadores.setRowCount(0);
        try {
            jugadores = repoJugador.consultarJugadores(txtBuscarJugador.getText());
            for (Jugador j : jugadores) {
                modeloJugadores.addRow(new Object[] {
                        j.getIdJugador(),
                        j.getNombre(),
                        j.getPosicion(),
                        j.getClub() != null ? j.getClub() : ""
                });
            }
            estadoJugadores.setText("Se encontraron " + jugadores.size() + " jugador(es).");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregarJugador() {
        JTextField txtNombre = new JTextField(20);
        JComboBox<String> cboPosicion = new JComboBox<>(new String[] {"Arquero", "Defensa", "Volante", "Delantero"});
        JTextField txtClub = new JTextField(20);

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Nombre completo:"));
        form.add(txtNombre);
        form.add(new JLabel("Posición:"));
        form.add(cboPosicion);
        form.add(new JLabel("Club actual (opcional):"));
        form.add(txtClub);

        int opt = JOptionPane.showConfirmDialog(this, form, "Nuevo Jugador", JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        if (txtNombre.getText().trim().isEmpty()) {
            Mensajes.aviso(this, "El nombre del jugador es obligatorio.");
            return;
        }

        Jugador nuevo = new Jugador(0, txtNombre.getText().trim(), (String) cboPosicion.getSelectedItem(), txtClub.getText().trim());
        try {
            repoJugador.insertarJugador(nuevo);
            cargarJugadores();
            estadoJugadores.setText("Jugador agregado: " + nuevo.getNombre());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editarJugador() {
        int fila = tablaJugadores.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un jugador de la tabla.");
            return;
        }
        Jugador actual = jugadores.get(fila);

        JTextField txtNombre = new JTextField(actual.getNombre(), 20);
        JComboBox<String> cboPosicion = new JComboBox<>(new String[] {"Arquero", "Defensa", "Volante", "Delantero"});
        cboPosicion.setSelectedItem(actual.getPosicion());
        JTextField txtClub = new JTextField(actual.getClub() != null ? actual.getClub() : "", 20);

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Nombre completo:"));
        form.add(txtNombre);
        form.add(new JLabel("Posición:"));
        form.add(cboPosicion);
        form.add(new JLabel("Club actual:"));
        form.add(txtClub);

        int opt = JOptionPane.showConfirmDialog(this, form, "Editar Jugador #" + actual.getIdJugador(), JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        actual.setNombre(txtNombre.getText().trim());
        actual.setPosicion((String) cboPosicion.getSelectedItem());
        actual.setClub(txtClub.getText().trim());

        try {
            repoJugador.actualizarJugador(actual);
            cargarJugadores();
            estadoJugadores.setText("Jugador actualizado: " + actual.getNombre());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarJugador() {
        int fila = tablaJugadores.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un jugador de la tabla.");
            return;
        }
        Jugador actual = jugadores.get(fila);
        int resp = JOptionPane.showConfirmDialog(this,
                "¿Eliminar a " + actual.getNombre() + "?\nSi tiene convocatorias o estadísticas asociadas, Oracle rechazará el borrado.",
                "Confirmar eliminación", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repoJugador.eliminarJugador(actual.getIdJugador());
            cargarJugadores();
            estadoJugadores.setText("Se eliminó el jugador #" + actual.getIdJugador());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    // ============================================================
    // PESTAÑA 2: CUERPO TÉCNICO
    // ============================================================

    private JPanel armarPanelCuerpoTecnico() {
        JPanel panel = new JPanel(new BorderLayout(0, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
        filtros.add(new JLabel("Edición:"));
        filtros.add(comboEdicionCT);
        filtros.add(new JLabel("Selección:"));
        filtros.add(comboSeleccionCT);

        comboEdicionCT.addActionListener(e -> recargarSeleccionesCT());
        comboSeleccionCT.addActionListener(e -> cargarCuerpoTecnico());

        panel.add(filtros, BorderLayout.NORTH);
        panel.add(new JScrollPane(tablaCT), BorderLayout.CENTER);

        JButton btnAgregar = new JButton("Agregar");
        JButton btnEditar = new JButton("Editar");
        JButton btnEliminar = new JButton("Eliminar");
        JButton btnRecargar = new JButton("Recargar");

        btnAgregar.addActionListener(e -> agregarCuerpoTecnico());
        btnEditar.addActionListener(e -> editarCuerpoTecnico());
        btnEliminar.addActionListener(e -> eliminarCuerpoTecnico());
        btnRecargar.addActionListener(e -> cargarCuerpoTecnico());

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        botones.add(btnAgregar);
        botones.add(btnEditar);
        botones.add(btnEliminar);
        botones.add(btnRecargar);

        JPanel abajo = new JPanel(new BorderLayout(0, 4));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estadoCT, BorderLayout.SOUTH);
        panel.add(abajo, BorderLayout.SOUTH);

        return panel;
    }

    private void recargarSeleccionesCT() {
        comboSeleccionCT.removeAllItems();
        Edicion ed = (Edicion) comboEdicionCT.getSelectedItem();
        if (ed == null) return;
        try {
            List<RepositoryPartido.OpcionSeleccion> selList = repoPartido.consultarSeleccionesPorEdicion(ed.getIdEdicion());
            for (RepositoryPartido.OpcionSeleccion s : selList) {
                comboSeleccionCT.addItem(s);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void cargarCuerpoTecnico() {
        modeloCT.setRowCount(0);
        Edicion ed = (Edicion) comboEdicionCT.getSelectedItem();
        RepositoryPartido.OpcionSeleccion sel = (RepositoryPartido.OpcionSeleccion) comboSeleccionCT.getSelectedItem();
        if (ed == null) return;

        Integer idSel = sel != null ? sel.getIdSeleccion() : null;
        try {
            cuerpoTecnicoList = repoCuerpoTecnico.consultarCuerpoTecnico(ed.getIdEdicion(), idSel);
            for (CuerpoTecnico ct : cuerpoTecnicoList) {
                modeloCT.addRow(new Object[] {
                        ct.getIdCuerpoTecnico(),
                        ct.getPaisSeleccion(),
                        ct.getNombre(),
                        ct.getCargo()
                });
            }
            estadoCT.setText("Registros: " + cuerpoTecnicoList.size());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregarCuerpoTecnico() {
        RepositoryPartido.OpcionSeleccion sel = (RepositoryPartido.OpcionSeleccion) comboSeleccionCT.getSelectedItem();
        if (sel == null) {
            Mensajes.aviso(this, "Seleccione primero una selección.");
            return;
        }

        JTextField txtNombre = new JTextField(20);
        JComboBox<String> cboCargo = new JComboBox<>(new String[] {
                "Director tecnico", "Asistente tecnico", "Preparador fisico", "Entrenador de porteros", "Medico"
        });

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Selección:"));
        form.add(new JLabel(sel.getPais()));
        form.add(new JLabel("Nombre:"));
        form.add(txtNombre);
        form.add(new JLabel("Cargo:"));
        form.add(cboCargo);

        int opt = JOptionPane.showConfirmDialog(this, form, "Nuevo Miembro de Cuerpo Técnico", JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        if (txtNombre.getText().trim().isEmpty()) {
            Mensajes.aviso(this, "El nombre es obligatorio.");
            return;
        }

        CuerpoTecnico ct = new CuerpoTecnico(0, sel.getIdSeleccion(), txtNombre.getText().trim(), (String) cboCargo.getSelectedItem(), sel.getPais());
        try {
            repoCuerpoTecnico.insertarCuerpoTecnico(ct);
            cargarCuerpoTecnico();
            estadoCT.setText("Agregado al cuerpo técnico: " + ct.getNombre());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editarCuerpoTecnico() {
        int fila = tablaCT.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un registro de cuerpo técnico.");
            return;
        }
        CuerpoTecnico actual = cuerpoTecnicoList.get(fila);

        JTextField txtNombre = new JTextField(actual.getNombre(), 20);
        JComboBox<String> cboCargo = new JComboBox<>(new String[] {
                "Director tecnico", "Asistente tecnico", "Preparador fisico", "Entrenador de porteros", "Medico"
        });
        cboCargo.setSelectedItem(actual.getCargo());

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Selección:"));
        form.add(new JLabel(actual.getPaisSeleccion()));
        form.add(new JLabel("Nombre:"));
        form.add(txtNombre);
        form.add(new JLabel("Cargo:"));
        form.add(cboCargo);

        int opt = JOptionPane.showConfirmDialog(this, form, "Editar Cuerpo Técnico #" + actual.getIdCuerpoTecnico(), JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        actual.setNombre(txtNombre.getText().trim());
        actual.setCargo((String) cboCargo.getSelectedItem());

        try {
            repoCuerpoTecnico.actualizarCuerpoTecnico(actual);
            cargarCuerpoTecnico();
            estadoCT.setText("Actualizado: " + actual.getNombre());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarCuerpoTecnico() {
        int fila = tablaCT.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un registro de cuerpo técnico.");
            return;
        }
        CuerpoTecnico actual = cuerpoTecnicoList.get(fila);
        int resp = JOptionPane.showConfirmDialog(this, "¿Eliminar a " + actual.getNombre() + " (" + actual.getCargo() + ")?",
                "Confirmar eliminación", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repoCuerpoTecnico.eliminarCuerpoTecnico(actual.getIdCuerpoTecnico());
            cargarCuerpoTecnico();
            estadoCT.setText("Se eliminó el registro #" + actual.getIdCuerpoTecnico());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    // ============================================================
    // PESTAÑA 3: CONVOCATORIAS
    // ============================================================

    private JPanel armarPanelConvocatorias() {
        JPanel panel = new JPanel(new BorderLayout(0, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
        filtros.add(new JLabel("Edición:"));
        filtros.add(comboEdicionConv);
        filtros.add(new JLabel("Selección:"));
        filtros.add(comboSeleccionConv);
        filtros.add(lblCupos);

        comboEdicionConv.addActionListener(e -> recargarSeleccionesConv());
        comboSeleccionConv.addActionListener(e -> cargarConvocatorias());

        panel.add(filtros, BorderLayout.NORTH);
        panel.add(new JScrollPane(tablaConvocatoria), BorderLayout.CENTER);

        JButton btnConvocar = new JButton("Convocar Jugador");
        JButton btnDesconvocar = new JButton("Desconvocar");
        JButton btnRecargar = new JButton("Recargar");

        btnConvocar.addActionListener(e -> convocarJugador());
        btnDesconvocar.addActionListener(e -> desconvocarJugador());
        btnRecargar.addActionListener(e -> cargarConvocatorias());

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        botones.add(btnConvocar);
        botones.add(btnDesconvocar);
        botones.add(btnRecargar);

        JPanel abajo = new JPanel(new BorderLayout(0, 4));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estadoConv, BorderLayout.SOUTH);
        panel.add(abajo, BorderLayout.SOUTH);

        return panel;
    }

    private void recargarSeleccionesConv() {
        comboSeleccionConv.removeAllItems();
        Edicion ed = (Edicion) comboEdicionConv.getSelectedItem();
        if (ed == null) return;
        try {
            List<RepositoryPartido.OpcionSeleccion> selList = repoPartido.consultarSeleccionesPorEdicion(ed.getIdEdicion());
            for (RepositoryPartido.OpcionSeleccion s : selList) {
                comboSeleccionConv.addItem(s);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void cargarConvocatorias() {
        modeloConvocatoria.setRowCount(0);
        RepositoryPartido.OpcionSeleccion sel = (RepositoryPartido.OpcionSeleccion) comboSeleccionConv.getSelectedItem();
        if (sel == null) {
            lblCupos.setText("Cupos: --");
            return;
        }

        try {
            convocatorias = repoJugador.consultarConvocatorias(sel.getIdSeleccion());
            for (ConvocatoriaJugador c : convocatorias) {
                modeloConvocatoria.addRow(new Object[] {
                        c.getIdConvocatoria(),
                        "#" + c.getNumeroCamiseta(),
                        c.getNombreJugador(),
                        c.getPosicionJugador(),
                        c.getEsCapitan() == 1 ? "Sí (Capitán)" : "No"
                });
            }
            int cuposLibres = 26 - convocatorias.size();
            lblCupos.setText("Convocados: " + convocatorias.size() + " / 26 (Libres: " + cuposLibres + ")");
            estadoConv.setText("Convocatoria de " + sel.getPais() + " cargada.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void convocarJugador() {
        RepositoryPartido.OpcionSeleccion sel = (RepositoryPartido.OpcionSeleccion) comboSeleccionConv.getSelectedItem();
        if (sel == null) {
            Mensajes.aviso(this, "Seleccione primero una selección.");
            return;
        }

        if (convocatorias.size() >= 26) {
            Mensajes.aviso(this, "La selección ya completó el cupo máximo de 26 jugadores convocados.");
            return;
        }

        try {
            List<Jugador> disponibles = repoJugador.consultarJugadoresDisponibles(sel.getIdSeleccion());
            if (disponibles.isEmpty()) {
                Mensajes.aviso(this, "No hay más jugadores disponibles en el catálogo para convocar.");
                return;
            }

            JComboBox<Jugador> cboJugador = new JComboBox<>();
            for (Jugador j : disponibles) {
                cboJugador.addItem(j);
            }

            JTextField txtCamiseta = new JTextField("1", 5);
            JCheckBox chkCapitan = new JCheckBox("Es Capitán del equipo");

            JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
            form.add(new JLabel("Selección:"));
            form.add(new JLabel(sel.getPais()));
            form.add(new JLabel("Jugador:"));
            form.add(cboJugador);
            form.add(new JLabel("Número de camiseta (1-26):"));
            form.add(txtCamiseta);
            form.add(new JLabel("Capitanía:"));
            form.add(chkCapitan);

            int opt = JOptionPane.showConfirmDialog(this, form, "Convocar Jugador", JOptionPane.OK_CANCEL_OPTION);
            if (opt != JOptionPane.OK_OPTION) return;

            int dorsal;
            try {
                dorsal = Integer.parseInt(txtCamiseta.getText().trim());
                if (dorsal < 1 || dorsal > 26) {
                    Mensajes.aviso(this, "El número de camiseta debe estar entre 1 y 26.");
                    return;
                }
            } catch (NumberFormatException ex) {
                Mensajes.aviso(this, "El número de camiseta debe ser un número entero.");
                return;
            }

            Jugador eleg = (Jugador) cboJugador.getSelectedItem();
            if (eleg == null) return;

            ConvocatoriaJugador conv = new ConvocatoriaJugador(
                    0, eleg.getIdJugador(), sel.getIdSeleccion(), dorsal,
                    chkCapitan.isSelected() ? 1 : 0, eleg.getNombre(), eleg.getPosicion(), sel.getPais());

            repoJugador.insertarConvocatoria(conv);
            cargarConvocatorias();
            estadoConv.setText("Jugador #" + dorsal + " " + eleg.getNombre() + " convocado a " + sel.getPais());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void desconvocarJugador() {
        int fila = tablaConvocatoria.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione una convocatoria de la tabla.");
            return;
        }
        ConvocatoriaJugador c = convocatorias.get(fila);
        int resp = JOptionPane.showConfirmDialog(this,
                "¿Desconvocar a " + c.getNombreJugador() + " (#" + c.getNumeroCamiseta() + ")?\nSi tiene estadísticas en partidos jugados, Oracle rechazará el borrado.",
                "Confirmar desconvocatoria", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repoJugador.eliminarConvocatoria(c.getIdConvocatoria());
            cargarConvocatorias();
            estadoConv.setText("Se desconvocó al jugador.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }
}
