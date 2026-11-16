package mundial;

import java.sql.Connection;
import java.sql.SQLException;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import mundial.ui.VentanaPrincipal;

public class Main {

    public static void main(String[] args) {
        // Usa el aspecto del sistema operativo (en Mac se ve como una app nativa).
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            // Si falla, Swing queda con su aspecto por defecto.
        }

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
