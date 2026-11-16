package mundial.datos;

public class FilaIncidenciasEstadio {

    private String fase;
    private String estadio;
    private int incidencias;

    public FilaIncidenciasEstadio(String fase, String estadio, int incidencias) {
        this.fase = fase;
        this.estadio = estadio;
        this.incidencias = incidencias;
    }

    public String getFase() { return fase; }
    public String getEstadio() { return estadio; }
    public int getIncidencias() { return incidencias; }
}
