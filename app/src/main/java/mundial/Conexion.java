package mundial;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class Conexion {

    private static final String ARCHIVO = "config.properties";

    public static Connection abrir() throws SQLException {
        Properties config = new Properties();
        try (FileInputStream entrada = new FileInputStream(ARCHIVO)) {
            config.load(entrada);
        } catch (IOException e) {
            throw new SQLException("No se encontro " + ARCHIVO + ". Copie config.example.properties y llenelo.");
        }
        return DriverManager.getConnection(
                config.getProperty("db.url"),
                config.getProperty("db.usuario"),
                config.getProperty("db.contrasena"));
    }
}
