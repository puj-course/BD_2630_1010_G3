package mundial.datos;

import java.sql.Timestamp;

public class Partido {

    private int idPartido;
    private int idEdicion;
    private int idFase;
    private int idEstadio;
    private Integer idPartidoSiguiente;
    private Timestamp fechaHora;
    private Integer asistenciaRegistrada;

    // Campos complementarios obtenidos mediante JOIN
    private String nombreFase;
    private String tipoFase;
    private String nombreEstadio;
    private int capacidadEstadio;
    private int anioEdicion;
    private Integer idLocal;
    private String paisLocal;
    private Integer golesLocal;
    private Integer idVisitante;
    private String paisVisitante;
    private Integer golesVisitante;

    public Partido(int idPartido, int idEdicion, int idFase, int idEstadio, Integer idPartidoSiguiente,
                   Timestamp fechaHora, Integer asistenciaRegistrada, String nombreFase, String tipoFase,
                   String nombreEstadio, int capacidadEstadio, int anioEdicion,
                   Integer idLocal, String paisLocal, Integer golesLocal,
                   Integer idVisitante, String paisVisitante, Integer golesVisitante) {
        this.idPartido = idPartido;
        this.idEdicion = idEdicion;
        this.idFase = idFase;
        this.idEstadio = idEstadio;
        this.idPartidoSiguiente = idPartidoSiguiente;
        this.fechaHora = fechaHora;
        this.asistenciaRegistrada = asistenciaRegistrada;
        this.nombreFase = nombreFase;
        this.tipoFase = tipoFase;
        this.nombreEstadio = nombreEstadio;
        this.capacidadEstadio = capacidadEstadio;
        this.anioEdicion = anioEdicion;
        this.idLocal = idLocal;
        this.paisLocal = paisLocal;
        this.golesLocal = golesLocal;
        this.idVisitante = idVisitante;
        this.paisVisitante = paisVisitante;
        this.golesVisitante = golesVisitante;
    }

    public int getIdPartido() { return idPartido; }
    public void setIdPartido(int idPartido) { this.idPartido = idPartido; }

    public int getIdEdicion() { return idEdicion; }
    public void setIdEdicion(int idEdicion) { this.idEdicion = idEdicion; }

    public int getIdFase() { return idFase; }
    public void setIdFase(int idFase) { this.idFase = idFase; }

    public int getIdEstadio() { return idEstadio; }
    public void setIdEstadio(int idEstadio) { this.idEstadio = idEstadio; }

    public Integer getIdPartidoSiguiente() { return idPartidoSiguiente; }
    public void setIdPartidoSiguiente(Integer idPartidoSiguiente) { this.idPartidoSiguiente = idPartidoSiguiente; }

    public Timestamp getFechaHora() { return fechaHora; }
    public void setFechaHora(Timestamp fechaHora) { this.fechaHora = fechaHora; }

    public Integer getAsistenciaRegistrada() { return asistenciaRegistrada; }
    public void setAsistenciaRegistrada(Integer asistenciaRegistrada) { this.asistenciaRegistrada = asistenciaRegistrada; }

    public String getNombreFase() { return nombreFase; }
    public void setNombreFase(String nombreFase) { this.nombreFase = nombreFase; }

    public String getTipoFase() { return tipoFase; }
    public void setTipoFase(String tipoFase) { this.tipoFase = tipoFase; }

    public String getNombreEstadio() { return nombreEstadio; }
    public void setNombreEstadio(String nombreEstadio) { this.nombreEstadio = nombreEstadio; }

    public int getCapacidadEstadio() { return capacidadEstadio; }
    public void setCapacidadEstadio(int capacidadEstadio) { this.capacidadEstadio = capacidadEstadio; }

    public int getAnioEdicion() { return anioEdicion; }
    public void setAnioEdicion(int anioEdicion) { this.anioEdicion = anioEdicion; }

    public Integer getIdLocal() { return idLocal; }
    public void setIdLocal(Integer idLocal) { this.idLocal = idLocal; }

    public String getPaisLocal() { return paisLocal != null ? paisLocal : "Por definir"; }
    public void setPaisLocal(String paisLocal) { this.paisLocal = paisLocal; }

    public Integer getGolesLocal() { return golesLocal; }
    public void setGolesLocal(Integer golesLocal) { this.golesLocal = golesLocal; }

    public Integer getIdVisitante() { return idVisitante; }
    public void setIdVisitante(Integer idVisitante) { this.idVisitante = idVisitante; }

    public String getPaisVisitante() { return paisVisitante != null ? paisVisitante : "Por definir"; }
    public void setPaisVisitante(String paisVisitante) { this.paisVisitante = paisVisitante; }

    public Integer getGolesVisitante() { return golesVisitante; }
    public void setGolesVisitante(Integer golesVisitante) { this.golesVisitante = golesVisitante; }

    public String getMarcador() {
        if (golesLocal != null && golesVisitante != null) {
            return golesLocal + " - " + golesVisitante;
        }
        return "vs";
    }

    @Override
    public String toString() {
        return "#" + idPartido + " " + getPaisLocal() + " " + getMarcador() + " " + getPaisVisitante() + " (" + nombreFase + ")";
    }
}
