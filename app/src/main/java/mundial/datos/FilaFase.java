package mundial.datos;

public class FilaFase {

    private String fase;
    private int partidos;
    private int goles;
    private double promedioGoles;
    private long asistencia;

    public FilaFase(String fase, int partidos, int goles, double promedioGoles, long asistencia) {
        this.fase = fase;
        this.partidos = partidos;
        this.goles = goles;
        this.promedioGoles = promedioGoles;
        this.asistencia = asistencia;
    }

    public String getFase() { return fase; }
    public int getPartidos() { return partidos; }
    public int getGoles() { return goles; }
    public double getPromedioGoles() { return promedioGoles; }
    public long getAsistencia() { return asistencia; }
}
