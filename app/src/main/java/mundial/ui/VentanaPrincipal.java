package mundial.ui;

import java.awt.BorderLayout;
import java.awt.Font;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.SwingConstants;

public class VentanaPrincipal extends JFrame {

    public VentanaPrincipal(String usuario) {
        super("Copa Mundial FIFA - " + usuario);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(1000, 650);
        setLocationRelativeTo(null);

        JMenuBar barra = new JMenuBar();

        // Cada integrante cambia pendiente(...) por su propio panel.
        JMenu catalogos = new JMenu("Catalogos");
        agregar(catalogos, "Ediciones del Mundial", PanelEdiciones::new);
        agregar(catalogos, "Sedes", () -> pendiente("Sedes"));
        agregar(catalogos, "Ciudades", () -> pendiente("Ciudades"));
        agregar(catalogos, "Estadios", () -> pendiente("Estadios"));
        catalogos.addSeparator();
        agregar(catalogos, "Selecciones y grupos", () -> pendiente("Selecciones y grupos"));
        agregar(catalogos, "Jugadores y cuerpo tecnico", () -> pendiente("Jugadores y cuerpo tecnico"));

        JMenu partidos = new JMenu("Partidos");
        agregar(partidos, "Registro de partidos", () -> pendiente("Registro de partidos"));
        agregar(partidos, "Estadisticas", () -> pendiente("Estadisticas"));
        agregar(partidos, "Incidencias", () -> pendiente("Incidencias"));

        JMenu consultas = new JMenu("Consultas");
        agregar(consultas, "Tabla de posiciones", () -> pendiente("Tabla de posiciones"));
        agregar(consultas, "Resultados", () -> pendiente("Resultados"));
        agregar(consultas, "Incidencias", () -> pendiente("Consulta de incidencias"));

        JMenu reportes = new JMenu("Reportes");
        agregar(reportes, "Panel de reportes", () -> pendiente("Panel de reportes"));

        barra.add(catalogos);
        barra.add(partidos);
        barra.add(consultas);
        barra.add(reportes);
        setJMenuBar(barra);

        mostrar(inicio(usuario));
    }

    private void agregar(JMenu menu, String titulo, Pantalla pantalla) {
        JMenuItem item = new JMenuItem(titulo);
        item.addActionListener(e -> mostrar(pantalla.crear()));
        menu.add(item);
    }

    private void mostrar(JPanel panel) {
        getContentPane().removeAll();
        getContentPane().add(panel, BorderLayout.CENTER);
        revalidate();
        repaint();
    }

    private JPanel inicio(String usuario) {
        JPanel panel = new JPanel(new BorderLayout());
        JLabel texto = new JLabel("Conectado a Oracle como " + usuario + ". Elija un modulo en el menu.",
                SwingConstants.CENTER);
        texto.setFont(texto.getFont().deriveFont(Font.PLAIN, 16f));
        panel.add(texto, BorderLayout.CENTER);
        return panel;
    }

    private JPanel pendiente(String titulo) {
        JPanel panel = new JPanel(new BorderLayout());
        panel.add(new JLabel(titulo + ": pendiente", SwingConstants.CENTER), BorderLayout.CENTER);
        return panel;
    }

    @FunctionalInterface
    private interface Pantalla {
        JPanel crear();
    }
}
