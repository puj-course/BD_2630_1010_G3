package mundial;

import com.formdev.flatlaf.FlatLightLaf;
import java.awt.Color;
import java.sql.Connection;
import java.sql.SQLException;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import mundial.ui.VentanaPrincipal;

public class Main {

    public static void main(String[] args) {
        // Tema FlatLaf: se ve igual en Windows y en Mac
        FlatLightLaf.setup();
        UIManager.put("Button.arc", 10);
        UIManager.put("Component.arc", 10);
        UIManager.put("TextComponent.arc", 10);
        UIManager.put("ScrollBar.showButtons", false);
        UIManager.put("Table.showHorizontalLines", true);
        UIManager.put("Table.showVerticalLines", false);
        UIManager.put("Table.alternateRowColor", new Color(244, 247, 252));
        UIManager.put("TableHeader.background", new Color(30, 70, 140));
        UIManager.put("TableHeader.foreground", Color.WHITE);
        UIManager.put("TabbedPane.showTabSeparators", true);

        String usuario;
        try (Connection con = Conexion.abrir()) {
            usuario = con.getMetaData().getUserName();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null,
                    "No se pudo conectar con Oracle.\n"
                    + "Revise que la VPN de la Javeriana esté activa y que config.properties tenga sus datos.\n\n"
                    + "Detalle: " + e.getMessage(),
                    "Error de conexión", JOptionPane.ERROR_MESSAGE);
            return;
        }
        SwingUtilities.invokeLater(() -> new VentanaPrincipal(usuario).setVisible(true));
    }
}
