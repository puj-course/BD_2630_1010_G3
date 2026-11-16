package mundial.ui;

import java.awt.Component;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;
import mundial.datos.Edicion;
import mundial.datos.RepositoryEdicion;

// Utilidades que comparten los paneles de consultas y reportes
final class Tablas {

    static final String TODOS = "Todos";

    private Tablas() {
    }

    static DefaultTableModel modelo(String... columnas) {
        return new DefaultTableModel(columnas, 0) {
            @Override
            public boolean isCellEditable(int fila, int columna) {
                return false;
            }
        };
    }

    // Llena el combo y deja seleccionada la edicion mas reciente
    static void cargarEdiciones(Component padre, JComboBox<Edicion> combo) {
        try {
            List<Edicion> ediciones = new RepositoryEdicion().consultarEdiciones();
            for (Edicion e : ediciones) {
                combo.addItem(e);
            }
            if (!ediciones.isEmpty()) {
                combo.setSelectedIndex(ediciones.size() - 1);
            }
        } catch (SQLException ex) {
            error(padre, ex);
        }
    }

    static void llenarOpciones(JComboBox<String> combo, List<String> opciones) {
        combo.removeAllItems();
        combo.addItem(TODOS);
        for (String opcion : opciones) {
            combo.addItem(opcion);
        }
    }

    // Devuelve null cuando esta elegido "Todos"
    static String filtro(JComboBox<String> combo) {
        Object valor = combo.getSelectedItem();
        return valor == null || TODOS.equals(valor) ? null : valor.toString();
    }

    static String fecha(Timestamp fecha) {
        return fecha == null ? "" : new SimpleDateFormat("yyyy-MM-dd HH:mm").format(fecha);
    }

    static void error(Component padre, SQLException ex) {
        JOptionPane.showMessageDialog(padre, ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    }
}
