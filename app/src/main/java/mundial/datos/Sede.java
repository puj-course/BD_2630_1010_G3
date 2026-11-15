package mundial.datos;

public class Sede {

    private int idSede;
    private int idEdicion;
    private String pais;
    // Se llena con el JOIN a edicion_mundial, solo para mostrar.
    private int anioEdicion;

    public Sede(int idSede, int idEdicion, String pais, int anioEdicion) {
        this.idSede = idSede;
        this.idEdicion = idEdicion;
        this.pais = pais;
        this.anioEdicion = anioEdicion;
    }

    public int getIdSede() { return idSede; }
    public void setIdSede(int idSede) { this.idSede = idSede; }

    public int getIdEdicion() { return idEdicion; }
    public void setIdEdicion(int idEdicion) { this.idEdicion = idEdicion; }

    public String getPais() { return pais; }
    public void setPais(String pais) { this.pais = pais; }

    public int getAnioEdicion() { return anioEdicion; }
    public void setAnioEdicion(int anioEdicion) { this.anioEdicion = anioEdicion; }

    @Override
    public String toString() {
        return pais + " (" + anioEdicion + ")";
    }
}
