package mundial.datos;

public class Ciudad {

    private int idCiudad;
    private int idSede;
    private String nombre;
    // Se llena con el JOIN a sede, solo para mostrar.
    private String sede;

    public Ciudad(int idCiudad, int idSede, String nombre, String sede) {
        this.idCiudad = idCiudad;
        this.idSede = idSede;
        this.nombre = nombre;
        this.sede = sede;
    }

    public int getIdCiudad() { return idCiudad; }
    public void setIdCiudad(int idCiudad) { this.idCiudad = idCiudad; }

    public int getIdSede() { return idSede; }
    public void setIdSede(int idSede) { this.idSede = idSede; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getSede() { return sede; }
    public void setSede(String sede) { this.sede = sede; }

    @Override
    public String toString() {
        return nombre + " - " + sede;
    }
}
