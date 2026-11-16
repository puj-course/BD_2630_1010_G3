package mundial.ui;

import java.awt.Font;
import javax.swing.JLabel;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;

public class Estilo {

    // Todas las tablas de la app se ven igual.
    public static void tabla(JTable tabla) {
        tabla.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        tabla.setRowHeight(26);
        tabla.setFillsViewportHeight(true);
        tabla.getTableHeader().setReorderingAllowed(false);
        tabla.getTableHeader().setFont(tabla.getTableHeader().getFont().deriveFont(Font.BOLD));
        // La primera columna siempre es el id: no necesita tanto espacio.
        tabla.getColumnModel().getColumn(0).setMaxWidth(70);
    }

    public static void titulo(JLabel label) {
        label.setFont(label.getFont().deriveFont(Font.BOLD, 20f));
    }
}
