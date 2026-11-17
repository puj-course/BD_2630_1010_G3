package mundial.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridLayout;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.SwingConstants;

public class VentanaPrincipal extends JFrame {

    private final String usuario;
    private final JPanel inicio;

    public VentanaPrincipal(String usuario) {
        super("Copa Mundial FIFA - " + usuario);
        this.usuario = usuario;
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(1100, 680);
        setMinimumSize(new Dimension(900, 560));
        setLocationRelativeTo(null);

        // Cada modulo aparece en el menu y en la pantalla de inicio.
        JPanel modulos = new JPanel(new GridLayout(1, 4, 15, 0));

        JMenu catalogos = new JMenu("Catálogos");
        JPanel colCatalogos = columna(modulos, "Catálogos");
        agregar(catalogos, colCatalogos, "Ediciones del Mundial", PanelEdiciones::new);
        agregar(catalogos, colCatalogos, "Sedes", PanelSedes::new);
        agregar(catalogos, colCatalogos, "Ciudades", PanelCiudades::new);
        agregar(catalogos, colCatalogos, "Estadios", PanelEstadios::new);
        catalogos.addSeparator();
        // Cada integrante cambia pendiente(...) por su propio panel.
        agregar(catalogos, colCatalogos, "Selecciones y grupos", PanelSelecciones::new);
        agregar(catalogos, colCatalogos, "Jugadores y cuerpo técnico", PanelJugadoresCuerpoTecnico::new);

        JMenu partidos = new JMenu("Partidos");
        JPanel colPartidos = columna(modulos, "Partidos");
        agregar(partidos, colPartidos, "Registro de partidos", PanelPartidos::new);
        agregar(partidos, colPartidos, "Estadísticas", PanelEstadisticas::new);
        agregar(partidos, colPartidos, "Incidencias", PanelIncidencias::new);

        JMenu consultas = new JMenu("Consultas");
        JPanel colConsultas = columna(modulos, "Consultas");
        agregar(consultas, colConsultas, "Tabla de posiciones", PanelPosiciones::new);
        agregar(consultas, colConsultas, "Resultados", PanelResultados::new);
        agregar(consultas, colConsultas, "Incidencias", PanelConsultaIncidencias::new);

        JMenu reportes = new JMenu("Reportes");
        JPanel colReportes = columna(modulos, "Reportes");
        agregar(reportes, colReportes, "Panel de reportes", PanelReportes::new);


        JMenu aplicacion = new JMenu("Aplicación");
        JMenuItem irInicio = new JMenuItem("Inicio");
        irInicio.addActionListener(e -> mostrarInicio());
        JMenuItem salir = new JMenuItem("Salir");
        salir.addActionListener(e -> dispose());
        aplicacion.add(irInicio);
        aplicacion.addSeparator();
        aplicacion.add(salir);

        JMenuBar barra = new JMenuBar();
        barra.add(aplicacion);
        barra.add(catalogos);
        barra.add(partidos);
        barra.add(consultas);
        barra.add(reportes);
        setJMenuBar(barra);

        inicio = armarInicio(modulos);
        mostrarInicio();
    }

    private void agregar(JMenu menu, JPanel columna, String titulo, Pantalla pantalla) {
        JMenuItem item = new JMenuItem(titulo);
        item.addActionListener(e -> mostrar(pantalla.crear()));
        menu.add(item);

        JButton boton = new JButton(titulo);
        boton.addActionListener(e -> mostrar(pantalla.crear()));
        columna.add(boton);
    }

    // Devuelve la lista de botones del modulo. Va dentro de un recuadro con el titulo.
    private JPanel columna(JPanel modulos, String titulo) {
        JPanel botones = new JPanel(new GridLayout(0, 1, 0, 8));
        JPanel recuadro = new JPanel(new BorderLayout());
        recuadro.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createTitledBorder(titulo),
                BorderFactory.createEmptyBorder(8, 8, 8, 8)));
        recuadro.add(botones, BorderLayout.NORTH);
        modulos.add(recuadro);
        return botones;
    }

    private JPanel armarInicio(JPanel modulos) {
        JLabel titulo = new JLabel("Copa Mundial de la FIFA");
        titulo.setFont(titulo.getFont().deriveFont(Font.BOLD, 26f));
        JLabel subtitulo = new JLabel("Sistema de gestión del torneo. Conectado a Oracle como " + usuario + ".");
        subtitulo.setFont(subtitulo.getFont().deriveFont(Font.PLAIN, 14f));

        JPanel encabezado = new JPanel(new GridLayout(2, 1, 0, 4));
        encabezado.add(titulo);
        encabezado.add(subtitulo);

        JLabel ayuda = new JLabel("Elija un módulo. También puede usar el menú de arriba y volver aquí con Aplicación > Inicio.");

        JPanel panel = new JPanel(new BorderLayout(0, 20));
        panel.setBorder(BorderFactory.createEmptyBorder(30, 30, 30, 30));
        panel.add(encabezado, BorderLayout.NORTH);
        // En NORTH las columnas quedan del alto de su contenido y no se estiran hasta abajo.
        JPanel centro = new JPanel(new BorderLayout());
        centro.add(modulos, BorderLayout.NORTH);
        panel.add(centro, BorderLayout.CENTER);
        panel.add(ayuda, BorderLayout.SOUTH);
        return panel;
    }

    private void mostrarInicio() {
        mostrar(inicio);
    }

    private void mostrar(JPanel panel) {
        getContentPane().removeAll();
        getContentPane().add(panel, BorderLayout.CENTER);
        revalidate();
        repaint();
    }

    private JPanel pendiente(String titulo) {
        JLabel texto = new JLabel(titulo + ": este módulo todavía está en construcción.", SwingConstants.CENTER);
        texto.setFont(texto.getFont().deriveFont(Font.PLAIN, 16f));
        JButton volver = new JButton("Volver al inicio");
        volver.addActionListener(e -> mostrarInicio());
        JPanel abajo = new JPanel();
        abajo.add(volver);

        JPanel panel = new JPanel(new BorderLayout());
        panel.add(texto, BorderLayout.CENTER);
        panel.add(abajo, BorderLayout.SOUTH);
        return panel;
    }

    @FunctionalInterface
    private interface Pantalla {
        JPanel crear();
    }
}
