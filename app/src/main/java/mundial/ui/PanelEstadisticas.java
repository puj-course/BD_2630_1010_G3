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
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.EstadisticaJugador;
import mundial.datos.Partido;
import mundial.datos.RepositoryEstadistica;
import mundial.datos.RepositoryPartido;

public class PanelEstadisticas extends JPanel {

    private final RepositoryEstadistica repository = new RepositoryEstadistica();
    private final RepositoryPartido repoPartido = new RepositoryPartido();

    private final DefaultTableModel modelo = Tablas.modelo("Id", "Jugador", "Selección", "Titular", "Entrada", "Salida", "Minutos", "Goles", "Asistencias", "Amarillas", "Rojas");
    private final JTable tabla = Tablas.crear(modelo, true);
    private final JComboBox<Edicion> comboEdiciones = new JComboBox<>();
    private final JComboBox<Partido> comboPartidos = new JComboBox<>();
    private final JLabel titulo = new JLabel("Estadísticas Individuales por Partido");
    private final JLabel estado = new JLabel(" ");

    private List<EstadisticaJugador> estadisticas = new ArrayList<>();
    private List<Partido> partidos = new ArrayList<>();

    public PanelEstadisticas() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        Estilo.titulo(titulo);

        JPanel encabezado = new JPanel(new GridLayout(2, 1, 0, 4));
        encabezado.add(titulo);
        encabezado.add(new JLabel("Rendimiento de los jugadores convocados en cada partido."));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
        filtros.add(new JLabel("Edición:"));
        filtros.add(comboEdiciones);
        filtros.add(new JLabel("Partido:"));
        filtros.add(comboPartidos);

        comboEdiciones.addActionListener(e -> recargarPartidos());
        comboPartidos.addActionListener(e -> cargarEstadisticas());

        JPanel arriba = new JPanel(new BorderLayout(0, 8));
        arriba.add(encabezado, BorderLayout.NORTH);
        arriba.add(filtros, BorderLayout.SOUTH);
        add(arriba, BorderLayout.NORTH);

        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton btnAgregar = new JButton("Agregar Estadística");
        JButton btnEditar = new JButton("Editar Estadística");
        JButton btnEliminar = new JButton("Eliminar");
        JButton btnRecargar = new JButton("Recargar");

        btnAgregar.addActionListener(e -> agregarEstadistica());
        btnEditar.addActionListener(e -> editarEstadistica());
        btnEliminar.addActionListener(e -> eliminarEstadistica());
        btnRecargar.addActionListener(e -> cargarEstadisticas());

        tabla.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    editarEstadistica();
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

    private void cargarEstadisticas() {
        modelo.setRowCount(0);
        Partido p = (Partido) comboPartidos.getSelectedItem();
        if (p == null) {
            estado.setText("Seleccione un partido para consultar o registrar estadísticas.");
            return;
        }

        try {
            estadisticas = repository.consultarEstadisticas(p.getIdPartido());
            for (EstadisticaJugador e : estadisticas) {
                modelo.addRow(new Object[] {
                        e.getIdEstadistica(),
                        e.getNombreJugador(),
                        e.getPaisSeleccion() != null ? e.getPaisSeleccion() : "",
                        e.getTitular() == 1 ? "Sí" : "Suplente",
                        e.getMinutoEntrada() != null ? e.getMinutoEntrada() : "-",
                        e.getMinutoSalida() != null ? e.getMinutoSalida() : "-",
                        e.getMinutosJugados(),
                        e.getGoles(),
                        e.getAsistencias(),
                        e.getTarjetasAmarillas(),
                        e.getTarjetasRojas()
                });
            }
            estado.setText("Partido #" + p.getIdPartido() + ": " + estadisticas.size() + " jugador(es) con estadísticas registradas.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void agregarEstadistica() {
        Partido p = (Partido) comboPartidos.getSelectedItem();
        if (p == null) {
            Mensajes.aviso(this, "Seleccione primero un partido.");
            return;
        }

        try {
            List<RepositoryEstadistica.OpcionJugadorPartido> jugadores = repository.consultarJugadoresPartido(p.getIdPartido());
            if (jugadores.isEmpty()) {
                Mensajes.aviso(this, "No se encontraron jugadores convocados para las selecciones de este partido.\n" +
                        "Revise en 'Catálogos > Jugadores y cuerpo técnico > Convocatorias'.");
                return;
            }

            JComboBox<RepositoryEstadistica.OpcionJugadorPartido> cboJugador = new JComboBox<>();
            for (RepositoryEstadistica.OpcionJugadorPartido j : jugadores) cboJugador.addItem(j);

            JCheckBox chkTitular = new JCheckBox("Es titular", true);
            JTextField txtMinEntrada = new JTextField(5);
            txtMinEntrada.setEnabled(false);
            JTextField txtMinSalida = new JTextField(5);
            JTextField txtMinJugados = new JTextField("90", 5);
            JTextField txtGoles = new JTextField("0", 5);
            JTextField txtAsistencias = new JTextField("0", 5);
            JTextField txtAmarillas = new JTextField("0", 5);
            JTextField txtRojas = new JTextField("0", 5);

            chkTitular.addActionListener(e -> {
                boolean titular = chkTitular.isSelected();
                txtMinEntrada.setEnabled(!titular);
                if (titular) {
                    txtMinEntrada.setText("");
                } else if (txtMinEntrada.getText().trim().isEmpty()) {
                    txtMinEntrada.setText("45");
                }
            });

            JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
            form.add(new JLabel("Jugador convocado:"));
            form.add(cboJugador);
            form.add(new JLabel("Alineación:"));
            form.add(chkTitular);
            form.add(new JLabel("Minuto entrada (suplentes):"));
            form.add(txtMinEntrada);
            form.add(new JLabel("Minuto salida (opcional):"));
            form.add(txtMinSalida);
            form.add(new JLabel("Minutos jugados (0-120):"));
            form.add(txtMinJugados);
            form.add(new JLabel("Goles marcados:"));
            form.add(txtGoles);
            form.add(new JLabel("Asistencias:"));
            form.add(txtAsistencias);
            form.add(new JLabel("Tarjetas amarillas:"));
            form.add(txtAmarillas);
            form.add(new JLabel("Tarjetas rojas:"));
            form.add(txtRojas);

            int opt = JOptionPane.showConfirmDialog(this, form, "Agregar Estadística de Jugador", JOptionPane.OK_CANCEL_OPTION);
            if (opt != JOptionPane.OK_OPTION) return;

            RepositoryEstadistica.OpcionJugadorPartido jElegido = (RepositoryEstadistica.OpcionJugadorPartido) cboJugador.getSelectedItem();
            if (jElegido == null) return;

            int titular = chkTitular.isSelected() ? 1 : 0;
            Integer minEntrada = null;
            if (titular == 0) {
                if (txtMinEntrada.getText().trim().isEmpty()) {
                    Mensajes.aviso(this, "Para jugadores suplentes se debe ingresar el minuto de entrada (0-120).");
                    return;
                }
                minEntrada = Integer.parseInt(txtMinEntrada.getText().trim());
            }

            Integer minSalida = txtMinSalida.getText().trim().isEmpty() ? null : Integer.parseInt(txtMinSalida.getText().trim());
            int minJugados = Integer.parseInt(txtMinJugados.getText().trim());
            int goles = Integer.parseInt(txtGoles.getText().trim());
            int asist = Integer.parseInt(txtAsistencias.getText().trim());
            int amarillas = Integer.parseInt(txtAmarillas.getText().trim());
            int rojas = Integer.parseInt(txtRojas.getText().trim());

            EstadisticaJugador nueva = new EstadisticaJugador(
                    0, p.getIdPartido(), jElegido.getIdJugador(), titular,
                    minEntrada, minSalida, minJugados, goles, asist, amarillas, rojas,
                    jElegido.getNombre(), jElegido.getPosicion(), jElegido.getPais(), p.toString());

            repository.insertarEstadistica(nueva);
            cargarEstadisticas();
            estado.setText("Estadística guardada para " + jElegido.getNombre());
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "Los minutos, goles y tarjetas deben ser números enteros.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void editarEstadistica() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione una estadística de la tabla.");
            return;
        }

        EstadisticaJugador actual = estadisticas.get(fila);

        JCheckBox chkTitular = new JCheckBox("Es titular", actual.getTitular() == 1);
        JTextField txtMinEntrada = new JTextField(actual.getMinutoEntrada() != null ? String.valueOf(actual.getMinutoEntrada()) : "", 5);
        txtMinEntrada.setEnabled(actual.getTitular() == 0);
        JTextField txtMinSalida = new JTextField(actual.getMinutoSalida() != null ? String.valueOf(actual.getMinutoSalida()) : "", 5);
        JTextField txtMinJugados = new JTextField(String.valueOf(actual.getMinutosJugados()), 5);
        JTextField txtGoles = new JTextField(String.valueOf(actual.getGoles()), 5);
        JTextField txtAsistencias = new JTextField(String.valueOf(actual.getAsistencias()), 5);
        JTextField txtAmarillas = new JTextField(String.valueOf(actual.getTarjetasAmarillas()), 5);
        JTextField txtRojas = new JTextField(String.valueOf(actual.getTarjetasRojas()), 5);

        chkTitular.addActionListener(e -> {
            boolean titular = chkTitular.isSelected();
            txtMinEntrada.setEnabled(!titular);
            if (titular) {
                txtMinEntrada.setText("");
            }
        });

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Jugador:"));
        form.add(new JLabel(actual.getNombreJugador() + " (" + actual.getPaisSeleccion() + ")"));
        form.add(new JLabel("Alineación:"));
        form.add(chkTitular);
        form.add(new JLabel("Minuto entrada:"));
        form.add(txtMinEntrada);
        form.add(new JLabel("Minuto salida:"));
        form.add(txtMinSalida);
        form.add(new JLabel("Minutos jugados:"));
        form.add(txtMinJugados);
        form.add(new JLabel("Goles:"));
        form.add(txtGoles);
        form.add(new JLabel("Asistencias:"));
        form.add(txtAsistencias);
        form.add(new JLabel("Amarillas:"));
        form.add(txtAmarillas);
        form.add(new JLabel("Rojas:"));
        form.add(txtRojas);

        int opt = JOptionPane.showConfirmDialog(this, form, "Editar Estadística #" + actual.getIdEstadistica(), JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        try {
            int titular = chkTitular.isSelected() ? 1 : 0;
            Integer minEntrada = null;
            if (titular == 0) {
                if (txtMinEntrada.getText().trim().isEmpty()) {
                    Mensajes.aviso(this, "Para suplentes debe indicar el minuto de entrada.");
                    return;
                }
                minEntrada = Integer.parseInt(txtMinEntrada.getText().trim());
            }

            Integer minSalida = txtMinSalida.getText().trim().isEmpty() ? null : Integer.parseInt(txtMinSalida.getText().trim());
            int minJugados = Integer.parseInt(txtMinJugados.getText().trim());
            int goles = Integer.parseInt(txtGoles.getText().trim());
            int asist = Integer.parseInt(txtAsistencias.getText().trim());
            int amarillas = Integer.parseInt(txtAmarillas.getText().trim());
            int rojas = Integer.parseInt(txtRojas.getText().trim());

            actual.setTitular(titular);
            actual.setMinutoEntrada(minEntrada);
            actual.setMinutoSalida(minSalida);
            actual.setMinutosJugados(minJugados);
            actual.setGoles(goles);
            actual.setAsistencias(asist);
            actual.setTarjetasAmarillas(amarillas);
            actual.setTarjetasRojas(rojas);

            repository.actualizarEstadistica(actual);
            cargarEstadisticas();
            estado.setText("Estadística actualizada para " + actual.getNombreJugador());
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "Los minutos, goles y tarjetas deben ser números enteros.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarEstadistica() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione una estadística de la tabla.");
            return;
        }
        EstadisticaJugador actual = estadisticas.get(fila);
        int resp = JOptionPane.showConfirmDialog(this, "¿Eliminar estadística de " + actual.getNombreJugador() + "?",
                "Confirmar eliminación", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repository.eliminarEstadistica(actual.getIdEstadistica());
            cargarEstadisticas();
            estado.setText("Estadística #" + actual.getIdEstadistica() + " eliminada.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }
}
