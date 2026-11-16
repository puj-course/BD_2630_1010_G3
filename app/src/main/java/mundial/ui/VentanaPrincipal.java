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
        agregar(catalogos, colCatalogos, "Selecciones y grupos", () -> pendiente("Selecciones y grupos"));
        agregar(catalogos, colCatalogos, "Jugadores y cuerpo técnico", () -> pendiente("Jugadores y cuerpo técnico"));

        JMenu partidos = new JMenu("Partidos");
        JPanel colPartidos = columna(modulos, "Partidos");
        agregar(partidos, colPartidos, "Registro de partidos", () -> pendiente("Registro de partidos"));
        agregar(partidos, colPartidos, "Estadísticas", () -> pendiente("Estadísticas"));
        agregar(partidos, colPartidos, "Incidencias", () -> pendiente("Incidencias"));

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
