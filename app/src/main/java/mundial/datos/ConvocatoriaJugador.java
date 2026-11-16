package mundial.datos;

public class ConvocatoriaJugador {

    private int idConvocatoria;
    private int idJugador;
    private int idSeleccion;
    private int numeroCamiseta;
    private int esCapitan;
    // Se llenan con JOIN
    private String nombreJugador;
    private String posicionJugador;
    private String paisSeleccion;

    public ConvocatoriaJugador(int idConvocatoria, int idJugador, int idSeleccion, int numeroCamiseta, int esCapitan,
                               String nombreJugador, String posicionJugador, String paisSeleccion) {
        this.idConvocatoria = idConvocatoria;
        this.idJugador = idJugador;
        this.idSeleccion = idSeleccion;
        this.numeroCamiseta = numeroCamiseta;
        this.esCapitan = esCapitan;
        this.nombreJugador = nombreJugador;
        this.posicionJugador = posicionJugador;
        this.paisSeleccion = paisSeleccion;
    }

    public int getIdConvocatoria() { return idConvocatoria; }
    public void setIdConvocatoria(int idConvocatoria) { this.idConvocatoria = idConvocatoria; }

    public int getIdJugador() { return idJugador; }
    public void setIdJugador(int idJugador) { this.idJugador = idJugador; }

    public int getIdSeleccion() { return idSeleccion; }
    public void setIdSeleccion(int idSeleccion) { this.idSeleccion = idSeleccion; }

    public int getNumeroCamiseta() { return numeroCamiseta; }
    public void setNumeroCamiseta(int numeroCamiseta) { this.numeroCamiseta = numeroCamiseta; }

    public int getEsCapitan() { return esCapitan; }
    public void setEsCapitan(int esCapitan) { this.esCapitan = esCapitan; }

    public String getNombreJugador() { return nombreJugador; }
    public void setNombreJugador(String nombreJugador) { this.nombreJugador = nombreJugador; }

    public String getPosicionJugador() { return posicionJugador; }
    public void setPosicionJugador(String posicionJugador) { this.posicionJugador = posicionJugador; }

    public String getPaisSeleccion() { return paisSeleccion; }
    public void setPaisSeleccion(String paisSeleccion) { this.paisSeleccion = paisSeleccion; }

    @Override
    public String toString() {
        return "#" + numeroCamiseta + " " + nombreJugador + (esCapitan == 1 ? " (C)" : "");
    }
}
