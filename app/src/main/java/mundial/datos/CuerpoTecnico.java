package mundial.datos;

public class CuerpoTecnico {

    private int idCuerpoTecnico;
    private int idSeleccion;
    private String nombre;
    private String cargo;
    // Se llena con JOIN a seleccion
    private String paisSeleccion;

    public CuerpoTecnico(int idCuerpoTecnico, int idSeleccion, String nombre, String cargo, String paisSeleccion) {
        this.idCuerpoTecnico = idCuerpoTecnico;
        this.idSeleccion = idSeleccion;
        this.nombre = nombre;
        this.cargo = cargo;
        this.paisSeleccion = paisSeleccion;
    }

    public int getIdCuerpoTecnico() { return idCuerpoTecnico; }
    public void setIdCuerpoTecnico(int idCuerpoTecnico) { this.idCuerpoTecnico = idCuerpoTecnico; }

    public int getIdSeleccion() { return idSeleccion; }
    public void setIdSeleccion(int idSeleccion) { this.idSeleccion = idSeleccion; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCargo() { return cargo; }
    public void setCargo(String cargo) { this.cargo = cargo; }

    public String getPaisSeleccion() { return paisSeleccion; }
    public void setPaisSeleccion(String paisSeleccion) { this.paisSeleccion = paisSeleccion; }

    @Override
    public String toString() {
        return nombre + " (" + cargo + " - " + paisSeleccion + ")";
    }
}
