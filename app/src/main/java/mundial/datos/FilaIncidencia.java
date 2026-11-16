package mundial.datos;

import java.sql.Timestamp;

public class FilaIncidencia {

    private Timestamp fechaHora;
    private String fase;
    private String partido;
    private String estadio;
    private int minuto;
    private String tipo;
    private String descripcion;

    public FilaIncidencia(Timestamp fechaHora, String fase, String partido, String estadio, int minuto,
            String tipo, String descripcion) {
        this.fechaHora = fechaHora;
        this.fase = fase;
        this.partido = partido;
        this.estadio = estadio;
        this.minuto = minuto;
        this.tipo = tipo;
        this.descripcion = descripcion;
    }

    public Timestamp getFechaHora() { return fechaHora; }
    public String getFase() { return fase; }
    public String getPartido() { return partido; }
    public String getEstadio() { return estadio; }
    public int getMinuto() { return minuto; }
    public String getTipo() { return tipo; }
    public String getDescripcion() { return descripcion; }
}
