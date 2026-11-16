package mundial.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
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
import mundial.datos.Estadio;
import mundial.datos.Fase;
import mundial.datos.Partido;
import mundial.datos.RepositoryPartido;

public class PanelPartidos extends JPanel {

    private final RepositoryPartido repository = new RepositoryPartido();

    private final DefaultTableModel modelo = Tablas.modelo("Id", "Fecha / Hora", "Fase", "Local", "Marcador", "Visitante", "Estadio", "Asistencia");
    private final JTable tabla = Tablas.crear(modelo, true);
    private final JComboBox<Edicion> comboEdiciones = new JComboBox<>();
    private final JComboBox<Object> comboFases = new JComboBox<>();
    private final JLabel titulo = new JLabel("Registro de Partidos");
    private final JLabel estado = new JLabel(" ");

    private List<Partido> partidos = new ArrayList<>();
    private List<Fase> fases = new ArrayList<>();

    public PanelPartidos() {
        super(new BorderLayout(0, 10));
        setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        Estilo.titulo(titulo);

        JPanel encabezado = new JPanel(new GridLayout(2, 1, 0, 4));
        encabezado.add(titulo);
        encabezado.add(new JLabel("Programación, registro de marcadores y cierre de fases del torneo."));

        JPanel filtros = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 4));
        filtros.add(new JLabel("Edición:"));
        filtros.add(comboEdiciones);
        filtros.add(new JLabel("Fase:"));
        filtros.add(comboFases);

        comboEdiciones.addActionListener(e -> {
            cargarFases();
            cargarPartidos();
        });
        comboFases.addActionListener(e -> cargarPartidos());

        JPanel arriba = new JPanel(new BorderLayout(0, 8));
        arriba.add(encabezado, BorderLayout.NORTH);
        arriba.add(filtros, BorderLayout.SOUTH);
        add(arriba, BorderLayout.NORTH);

        add(new JScrollPane(tabla), BorderLayout.CENTER);

        JButton btnProgramar = new JButton("Programar Partido");
        JButton btnResultado = new JButton("Registrar Resultado");
        JButton btnCerrarFase = new JButton("Cerrar Fase");
        JButton btnEliminar = new JButton("Eliminar");
        JButton btnRecargar = new JButton("Recargar");

        btnProgramar.addActionListener(e -> programarPartido());
        btnResultado.addActionListener(e -> registrarResultado());
        btnCerrarFase.addActionListener(e -> cerrarFase());
        btnEliminar.addActionListener(e -> eliminarPartido());
        btnRecargar.addActionListener(e -> cargarPartidos());

        tabla.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    registrarResultado();
                }
            }
        });

        JPanel botones = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        botones.add(btnProgramar);
        botones.add(btnResultado);
        botones.add(btnCerrarFase);
        botones.add(btnEliminar);
        botones.add(btnRecargar);

        JPanel abajo = new JPanel(new BorderLayout(0, 4));
        abajo.add(botones, BorderLayout.NORTH);
        abajo.add(estado, BorderLayout.SOUTH);
        add(abajo, BorderLayout.SOUTH);

        Tablas.cargarEdiciones(this, comboEdiciones);
    }

    private void cargarFases() {
        comboFases.removeAllItems();
        comboFases.addItem(Tablas.TODOS);
        Edicion ed = (Edicion) comboEdiciones.getSelectedItem();
        if (ed == null) return;

        try {
            fases = repository.consultarFases(ed.getIdEdicion());
            for (Fase f : fases) {
                comboFases.addItem(f);
            }
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void cargarPartidos() {
        modelo.setRowCount(0);
        Edicion ed = (Edicion) comboEdiciones.getSelectedItem();
        if (ed == null) return;

        Object faseSel = comboFases.getSelectedItem();
        Integer idFase = (faseSel instanceof Fase) ? ((Fase) faseSel).getIdFase() : null;

        try {
            partidos = repository.consultarPartidos(ed.getIdEdicion(), idFase);
            for (Partido p : partidos) {
                modelo.addRow(new Object[] {
                        p.getIdPartido(),
                        Tablas.fecha(p.getFechaHora()),
                        p.getNombreFase(),
                        p.getPaisLocal(),
                        p.getMarcador(),
                        p.getPaisVisitante(),
                        p.getNombreEstadio(),
                        p.getAsistenciaRegistrada() != null ? String.format("%,d", p.getAsistenciaRegistrada()) : "Pendiente"
                });
            }
            titulo.setText("Registro de Partidos (" + partidos.size() + ")");
            estado.setText("Mostrando " + partidos.size() + " partido(s).");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void programarPartido() {
        Edicion ed = (Edicion) comboEdiciones.getSelectedItem();
        if (ed == null) {
            Mensajes.aviso(this, "Seleccione primero una edición.");
            return;
        }

        try {
            List<Fase> listaFases = repository.consultarFases(ed.getIdEdicion());
            List<Estadio> listaEstadios = repository.consultarEstadiosPorEdicion(ed.getIdEdicion());
            List<RepositoryPartido.OpcionSeleccion> selecciones = repository.consultarSeleccionesPorEdicion(ed.getIdEdicion());

            if (listaFases.isEmpty() || listaEstadios.isEmpty() || selecciones.size() < 2) {
                Mensajes.aviso(this, "Para programar un partido se requieren fases, estadios y al menos 2 selecciones registradas en la edición.");
                return;
            }

            JComboBox<Fase> cboFase = new JComboBox<>();
            for (Fase f : listaFases) cboFase.addItem(f);

            JComboBox<Estadio> cboEstadio = new JComboBox<>();
            for (Estadio es : listaEstadios) cboEstadio.addItem(es);

            JComboBox<RepositoryPartido.OpcionSeleccion> cboLocal = new JComboBox<>();
            JComboBox<RepositoryPartido.OpcionSeleccion> cboVis = new JComboBox<>();
            for (RepositoryPartido.OpcionSeleccion s : selecciones) {
                cboLocal.addItem(s);
                cboVis.addItem(s);
            }
            if (selecciones.size() > 1) {
                cboVis.setSelectedIndex(1);
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            JTextField txtFecha = new JTextField(sdf.format(new Date()), 16);

            JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
            form.add(new JLabel("Fase del torneo:"));
            form.add(cboFase);
            form.add(new JLabel("Estadio:"));
            form.add(cboEstadio);
            form.add(new JLabel("Selección Local:"));
            form.add(cboLocal);
            form.add(new JLabel("Selección Visitante:"));
            form.add(cboVis);
            form.add(new JLabel("Fecha y Hora (AAAA-MM-DD HH:MM):"));
            form.add(txtFecha);

            int opt = JOptionPane.showConfirmDialog(this, form, "Programar Nuevo Partido", JOptionPane.OK_CANCEL_OPTION);
            if (opt != JOptionPane.OK_OPTION) return;

            RepositoryPartido.OpcionSeleccion selLoc = (RepositoryPartido.OpcionSeleccion) cboLocal.getSelectedItem();
            RepositoryPartido.OpcionSeleccion selVis = (RepositoryPartido.OpcionSeleccion) cboVis.getSelectedItem();
            if (selLoc == null || selVis == null) return;

            if (selLoc.getIdSeleccion() == selVis.getIdSeleccion()) {
                Mensajes.aviso(this, "El equipo local y el visitante no pueden ser la misma selección.");
                return;
            }

            Timestamp ts;
            try {
                Date d = sdf.parse(txtFecha.getText().trim());
                ts = new Timestamp(d.getTime());
            } catch (ParseException ex) {
                Mensajes.aviso(this, "Formato de fecha inválido. Utilice AAAA-MM-DD HH:MM, por ejemplo 2026-06-15 16:00.");
                return;
            }

            Fase faseElegida = (Fase) cboFase.getSelectedItem();
            Estadio estadioElegido = (Estadio) cboEstadio.getSelectedItem();

            int nuevoId = repository.insertarPartido(
                    ed.getIdEdicion(),
                    faseElegida.getIdFase(),
                    estadioElegido.getIdEstadio(),
                    ts,
                    selLoc.getIdSeleccion(),
                    selVis.getIdSeleccion());

            cargarPartidos();
            estado.setText("Partido #" + nuevoId + " programado exitosamente: " + selLoc.getPais() + " vs " + selVis.getPais());
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void registrarResultado() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un partido de la tabla para registrar su resultado.");
            return;
        }

        int modeloFila = tabla.convertRowIndexToModel(fila);
        Partido p = partidos.get(modeloFila);

        if (p.getIdLocal() == null || p.getIdVisitante() == null) {
            Mensajes.aviso(this, "El partido #" + p.getIdPartido() + " aún no tiene ambas selecciones participantes asignadas.");
            return;
        }

        JTextField txtGolesLocal = new JTextField(p.getGolesLocal() != null ? String.valueOf(p.getGolesLocal()) : "0", 5);
        JTextField txtGolesVis = new JTextField(p.getGolesVisitante() != null ? String.valueOf(p.getGolesVisitante()) : "0", 5);
        JTextField txtAsistencia = new JTextField(p.getAsistenciaRegistrada() != null ? String.valueOf(p.getAsistenciaRegistrada()) : String.valueOf(p.getCapacidadEstadio()), 10);

        JPanel form = new JPanel(new GridLayout(0, 2, 6, 6));
        form.add(new JLabel("Partido:"));
        form.add(new JLabel("#" + p.getIdPartido() + " (" + p.getNombreFase() + ")"));
        form.add(new JLabel("Estadio:"));
        form.add(new JLabel(p.getNombreEstadio() + " (Aforo: " + String.format("%,d", p.getCapacidadEstadio()) + ")"));
        form.add(new JLabel("Goles " + p.getPaisLocal() + " (Local):"));
        form.add(txtGolesLocal);
        form.add(new JLabel("Goles " + p.getPaisVisitante() + " (Visitante):"));
        form.add(txtGolesVis);
        form.add(new JLabel("Asistencia registrada:"));
        form.add(txtAsistencia);

        int opt = JOptionPane.showConfirmDialog(this, form, "Registrar Marcador Final", JOptionPane.OK_CANCEL_OPTION);
        if (opt != JOptionPane.OK_OPTION) return;

        int gLocal, gVis;
        Integer asistencia = null;
        try {
            gLocal = Integer.parseInt(txtGolesLocal.getText().trim());
            gVis = Integer.parseInt(txtGolesVis.getText().trim());
            if (!txtAsistencia.getText().trim().isEmpty()) {
                asistencia = Integer.parseInt(txtAsistencia.getText().trim());
            }
        } catch (NumberFormatException ex) {
            Mensajes.aviso(this, "Los goles y la asistencia deben ser números enteros.");
            return;
        }

        try {
            // Llama a pr_registrar_resultado a traves del repositorio
            repository.registrarResultado(p.getIdPartido(), gLocal, gVis, asistencia);
            cargarPartidos();
            estado.setText("Resultado asentado para el partido #" + p.getIdPartido() + " (" + gLocal + " - " + gVis + ")");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void cerrarFase() {
        Edicion ed = (Edicion) comboEdiciones.getSelectedItem();
        if (ed == null) return;

        Object faseSel = comboFases.getSelectedItem();
        if (!(faseSel instanceof Fase)) {
            Mensajes.aviso(this, "Para cerrar una fase, primero selecciónela en el filtro de Fase.");
            return;
        }

        Fase f = (Fase) faseSel;
        int resp = JOptionPane.showConfirmDialog(this,
                "¿Desea cerrar formalmente la fase '" + f.getNombre() + "' (" + f.getTipo() + ")?\n\n" +
                "El procedimiento validará que todos los partidos estén concluidos, sin empates en eliminatorias,\n" +
                "y avanzará a los ganadores a la fase siguiente o consolidará la tabla de posiciones.",
                "Confirmar Cierre de Fase", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repository.cerrarFase(ed.getIdEdicion(), f.getIdFase());
            cargarPartidos();
            estado.setText("La fase '" + f.getNombre() + "' se cerró exitosamente mediante pr_cierre_fase.");
            JOptionPane.showMessageDialog(this, "Fase '" + f.getNombre() + "' cerrada con éxito.", "Cierre de fase exitoso", JOptionPane.INFORMATION_MESSAGE);
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }

    private void eliminarPartido() {
        int fila = tabla.getSelectedRow();
        if (fila < 0) {
            Mensajes.aviso(this, "Seleccione un partido de la tabla.");
            return;
        }
        int modeloFila = tabla.convertRowIndexToModel(fila);
        Partido p = partidos.get(modeloFila);
        int resp = JOptionPane.showConfirmDialog(this,
                "¿Eliminar el partido #" + p.getIdPartido() + " (" + p.getPaisLocal() + " vs " + p.getPaisVisitante() + ")?\n" +
                "Se eliminarán en cascada sus participaciones, estadísticas e incidencias.",
                "Confirmar eliminación", JOptionPane.YES_NO_OPTION);
        if (resp != JOptionPane.YES_OPTION) return;

        try {
            repository.eliminarPartido(p.getIdPartido());
            cargarPartidos();
            estado.setText("Partido #" + p.getIdPartido() + " eliminado.");
        } catch (SQLException ex) {
            Mensajes.error(this, ex);
        }
    }
}
