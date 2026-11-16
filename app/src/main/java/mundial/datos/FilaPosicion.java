package mundial.datos;

public class FilaPosicion {

    private String grupo;
    private int posicion;
    private String pais;
    private int jugados;
    private int ganados;
    private int empatados;
    private int perdidos;
    private int golesFavor;
    private int golesContra;
    private int diferencia;
    private int puntos;

    public FilaPosicion(String grupo, int posicion, String pais, int jugados, int ganados, int empatados,
            int perdidos, int golesFavor, int golesContra, int diferencia, int puntos) {
        this.grupo = grupo;
        this.posicion = posicion;
        this.pais = pais;
        this.jugados = jugados;
        this.ganados = ganados;
        this.empatados = empatados;
        this.perdidos = perdidos;
        this.golesFavor = golesFavor;
        this.golesContra = golesContra;
        this.diferencia = diferencia;
        this.puntos = puntos;
    }

    public String getGrupo() { return grupo; }
    public int getPosicion() { return posicion; }
    public String getPais() { return pais; }
    public int getJugados() { return jugados; }
    public int getGanados() { return ganados; }
    public int getEmpatados() { return empatados; }
    public int getPerdidos() { return perdidos; }
    public int getGolesFavor() { return golesFavor; }
    public int getGolesContra() { return golesContra; }
    public int getDiferencia() { return diferencia; }
    public int getPuntos() { return puntos; }
}
