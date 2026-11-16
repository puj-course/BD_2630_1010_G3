package mundial.datos;

public class Fase {

    private int idFase;
    private int idEdicion;
    private String nombre;
    private int ordenFase;
    private String tipo;

    public Fase(int idFase, int idEdicion, String nombre, int ordenFase, String tipo) {
        this.idFase = idFase;
        this.idEdicion = idEdicion;
        this.nombre = nombre;
        this.ordenFase = ordenFase;
        this.tipo = tipo;
    }

    public int getIdFase() { return idFase; }
    public void setIdFase(int idFase) { this.idFase = idFase; }

    public int getIdEdicion() { return idEdicion; }
    public void setIdEdicion(int idEdicion) { this.idEdicion = idEdicion; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public int getOrdenFase() { return ordenFase; }
    public void setOrdenFase(int ordenFase) { this.ordenFase = ordenFase; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    @Override
    public String toString() {
        return nombre + " (" + tipo + ")";
    }
}
