package mundial;

import java.sql.Connection;
import java.sql.SQLException;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import mundial.ui.VentanaPrincipal;

public class Main {

    public static void main(String[] args) {
        String usuario;
        try (Connection con = Conexion.abrir()) {
            usuario = con.getMetaData().getUserName();
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, e.getMessage(), "Error de conexion", JOptionPane.ERROR_MESSAGE);
            return;
        }
        SwingUtilities.invokeLater(() -> new VentanaPrincipal(usuario).setVisible(true));
    }
}
