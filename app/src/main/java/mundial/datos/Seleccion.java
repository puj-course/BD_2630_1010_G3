package mundial.datos;

public class Seleccion {

    private int idSeleccion;
    private int idEdicion;
    // 0 significa que la seleccion todavia no tiene grupo (en la base de datos queda NULL).
    private int idGrupo;
    private String pais;
    private String confederacion;
    // Se llenan con los JOIN, solo para mostrar en la tabla.
    private int anio;
    private String grupo;

    public Seleccion(int idSeleccion, int idEdicion, int idGrupo, String pais, String confederacion,
            int anio, String grupo) {
        this.idSeleccion = idSeleccion;
        this.idEdicion = idEdicion;
        this.idGrupo = idGrupo;
        this.pais = pais;
        this.confederacion = confederacion;
        this.anio = anio;
        this.grupo = grupo;
    }

    public int getIdSeleccion() { return idSeleccion; }
    public void setIdSeleccion(int idSeleccion) { this.idSeleccion = idSeleccion; }

    public int getIdEdicion() { return idEdicion; }
    public void setIdEdicion(int idEdicion) { this.idEdicion = idEdicion; }

    public int getIdGrupo() { return idGrupo; }
    public void setIdGrupo(int idGrupo) { this.idGrupo = idGrupo; }

    public String getPais() { return pais; }
    public void setPais(String pais) { this.pais = pais; }

    public String getConfederacion() { return confederacion; }
    public void setConfederacion(String confederacion) { this.confederacion = confederacion; }

    public int getAnio() { return anio; }
    public void setAnio(int anio) { this.anio = anio; }

    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }

    @Override
    public String toString() {
        return pais + " (" + anio + ")";
    }
}
