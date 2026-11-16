package mundial.datos;

import java.sql.Timestamp;

public class FilaResultado {

    private Timestamp fechaHora;
    private String fase;
    private String local;
    private int golesLocal;
    private int golesVisitante;
    private String visitante;
    private String estadio;
    private String ciudad;
    private Integer asistencia;

    public FilaResultado(Timestamp fechaHora, String fase, String local, int golesLocal, int golesVisitante,
            String visitante, String estadio, String ciudad, Integer asistencia) {
        this.fechaHora = fechaHora;
        this.fase = fase;
        this.local = local;
        this.golesLocal = golesLocal;
        this.golesVisitante = golesVisitante;
        this.visitante = visitante;
        this.estadio = estadio;
        this.ciudad = ciudad;
        this.asistencia = asistencia;
    }

    public Timestamp getFechaHora() { return fechaHora; }
    public String getFase() { return fase; }
    public String getLocal() { return local; }
    public int getGolesLocal() { return golesLocal; }
    public int getGolesVisitante() { return golesVisitante; }
    public String getVisitante() { return visitante; }
    public String getEstadio() { return estadio; }
    public String getCiudad() { return ciudad; }
    public Integer getAsistencia() { return asistencia; }

    public String getMarcador() {
        return golesLocal + " - " + golesVisitante;
    }
}
