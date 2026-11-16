package mundial.ui;

import java.awt.Component;
import java.sql.SQLException;
import javax.swing.JOptionPane;

public class Mensajes {

    // Explica en palabras simples los errores de Oracle que mas salen en los catalogos.
    // Debajo deja el mensaje original de Oracle para saber que restriccion fallo.
    public static void error(Component padre, SQLException ex) {
        String texto;
        int codigo = ex.getErrorCode();
        if (codigo == 1) {
            texto = "Ya existe un registro con esos mismos datos.";
        } else if (codigo == 2290) {
            texto = "Algún dato está fuera de lo permitido por la base de datos.";
        } else if (codigo == 2291) {
            texto = "El registro relacionado ya no existe. Recargue la lista e intente de nuevo.";
        } else if (codigo == 2292) {
            texto = "No se puede eliminar porque hay otros registros que dependen de este.";
        } else if (codigo == 1400) {
            texto = "Falta llenar un dato obligatorio.";
        } else if (codigo == 17002 || codigo == 12170) {
            texto = "No hay conexión con Oracle. Revise que la VPN de la Javeriana esté activa.";
        } else if (codigo == 0) {
            texto = "No se pudo completar la operación.";
        } else {
            texto = "Oracle no aceptó la operación.";
        }
        JOptionPane.showMessageDialog(padre, texto + "\n\nDetalle: " + primeraLinea(ex.getMessage()),
                "No se pudo completar", JOptionPane.ERROR_MESSAGE);
    }

    public static void aviso(Component padre, String texto) {
        JOptionPane.showMessageDialog(padre, texto, "Aviso", JOptionPane.WARNING_MESSAGE);
    }

    private static String primeraLinea(String mensaje) {
        if (mensaje == null) {
            return "";
        }
        int salto = mensaje.indexOf('\n');
        return salto < 0 ? mensaje : mensaje.substring(0, salto);
    }
}
