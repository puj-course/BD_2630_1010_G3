package mundial.datos;

public class FilaGoleador {

    private int posicion;
    private String nombre;
    private String pais;
    private int goles;

    public FilaGoleador(int posicion, String nombre, String pais, int goles) {
        this.posicion = posicion;
        this.nombre = nombre;
        this.pais = pais;
        this.goles = goles;
    }

    public int getPosicion() { return posicion; }
    public String getNombre() { return nombre; }
    public String getPais() { return pais; }
    public int getGoles() { return goles; }
}
