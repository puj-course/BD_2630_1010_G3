package mundial.datos;

public class FilaSeleccion {

    private String pais;
    private String grupo;
    private int jugados;
    private int ganados;
    private int empatados;
    private int perdidos;
    private int golesFavor;
    private int golesContra;
    private int diferencia;

    public FilaSeleccion(String pais, String grupo, int jugados, int ganados, int empatados, int perdidos,
            int golesFavor, int golesContra, int diferencia) {
        this.pais = pais;
        this.grupo = grupo;
        this.jugados = jugados;
        this.ganados = ganados;
        this.empatados = empatados;
        this.perdidos = perdidos;
        this.golesFavor = golesFavor;
        this.golesContra = golesContra;
        this.diferencia = diferencia;
    }

    public String getPais() { return pais; }
    public String getGrupo() { return grupo; }
    public int getJugados() { return jugados; }
    public int getGanados() { return ganados; }
    public int getEmpatados() { return empatados; }
    public int getPerdidos() { return perdidos; }
    public int getGolesFavor() { return golesFavor; }
    public int getGolesContra() { return golesContra; }
    public int getDiferencia() { return diferencia; }
}
