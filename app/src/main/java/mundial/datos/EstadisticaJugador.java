package mundial.datos;

public class EstadisticaJugador {

    private int idEstadistica;
    private int idPartido;
    private int idJugador;
    private int titular;
    private Integer minutoEntrada;
    private Integer minutoSalida;
    private int minutosJugados;
    private int goles;
    private int asistencias;
    private int tarjetasAmarillas;
    private int tarjetasRojas;

    // Campos auxiliares con JOIN
    private String nombreJugador;
    private String posicionJugador;
    private String paisSeleccion;
    private String partidoInfo;

    public EstadisticaJugador(int idEstadistica, int idPartido, int idJugador, int titular,
                              Integer minutoEntrada, Integer minutoSalida, int minutosJugados,
                              int goles, int asistencias, int tarjetasAmarillas, int tarjetasRojas,
                              String nombreJugador, String posicionJugador, String paisSeleccion, String partidoInfo) {
        this.idEstadistica = idEstadistica;
        this.idPartido = idPartido;
        this.idJugador = idJugador;
        this.titular = titular;
        this.minutoEntrada = minutoEntrada;
        this.minutoSalida = minutoSalida;
        this.minutosJugados = minutosJugados;
        this.goles = goles;
        this.asistencias = asistencias;
        this.tarjetasAmarillas = tarjetasAmarillas;
        this.tarjetasRojas = tarjetasRojas;
        this.nombreJugador = nombreJugador;
        this.posicionJugador = posicionJugador;
        this.paisSeleccion = paisSeleccion;
        this.partidoInfo = partidoInfo;
    }

    public int getIdEstadistica() { return idEstadistica; }
    public void setIdEstadistica(int idEstadistica) { this.idEstadistica = idEstadistica; }

    public int getIdPartido() { return idPartido; }
    public void setIdPartido(int idPartido) { this.idPartido = idPartido; }

    public int getIdJugador() { return idJugador; }
    public void setIdJugador(int idJugador) { this.idJugador = idJugador; }

    public int getTitular() { return titular; }
    public void setTitular(int titular) { this.titular = titular; }

    public Integer getMinutoEntrada() { return minutoEntrada; }
    public void setMinutoEntrada(Integer minutoEntrada) { this.minutoEntrada = minutoEntrada; }

    public Integer getMinutoSalida() { return minutoSalida; }
    public void setMinutoSalida(Integer minutoSalida) { this.minutoSalida = minutoSalida; }

    public int getMinutosJugados() { return minutosJugados; }
    public void setMinutosJugados(int minutosJugados) { this.minutosJugados = minutosJugados; }

    public int getGoles() { return goles; }
    public void setGoles(int goles) { this.goles = goles; }

    public int getAsistencias() { return asistencias; }
    public void setAsistencias(int asistencias) { this.asistencias = asistencias; }

    public int getTarjetasAmarillas() { return tarjetasAmarillas; }
    public void setTarjetasAmarillas(int tarjetasAmarillas) { this.tarjetasAmarillas = tarjetasAmarillas; }

    public int getTarjetasRojas() { return tarjetasRojas; }
    public void setTarjetasRojas(int tarjetasRojas) { this.tarjetasRojas = tarjetasRojas; }

    public String getNombreJugador() { return nombreJugador; }
    public void setNombreJugador(String nombreJugador) { this.nombreJugador = nombreJugador; }

    public String getPosicionJugador() { return posicionJugador; }
    public void setPosicionJugador(String posicionJugador) { this.posicionJugador = posicionJugador; }

    public String getPaisSeleccion() { return paisSeleccion; }
    public void setPaisSeleccion(String paisSeleccion) { this.paisSeleccion = paisSeleccion; }

    public String getPartidoInfo() { return partidoInfo; }
    public void setPartidoInfo(String partidoInfo) { this.partidoInfo = partidoInfo; }
}
