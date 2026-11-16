package mundial.datos;

public class Incidencia {

    private int idIncidencia;
    private int idPartido;
    private String tipo;
    private int minuto;
    private String descripcion;
    // Se llena con JOIN
    private String partidoInfo;

    public Incidencia(int idIncidencia, int idPartido, String tipo, int minuto, String descripcion, String partidoInfo) {
        this.idIncidencia = idIncidencia;
        this.idPartido = idPartido;
        this.tipo = tipo;
        this.minuto = minuto;
        this.descripcion = descripcion;
        this.partidoInfo = partidoInfo;
    }

    public int getIdIncidencia() { return idIncidencia; }
    public void setIdIncidencia(int idIncidencia) { this.idIncidencia = idIncidencia; }

    public int getIdPartido() { return idPartido; }
    public void setIdPartido(int idPartido) { this.idPartido = idPartido; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public int getMinuto() { return minuto; }
    public void setMinuto(int minuto) { this.minuto = minuto; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getPartidoInfo() { return partidoInfo; }
    public void setPartidoInfo(String partidoInfo) { this.partidoInfo = partidoInfo; }
}
