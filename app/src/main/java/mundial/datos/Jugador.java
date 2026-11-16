package mundial.datos;

public class Jugador {

    private int idJugador;
    private String nombre;
    private String posicion;
    private String club;

    public Jugador(int idJugador, String nombre, String posicion, String club) {
        this.idJugador = idJugador;
        this.nombre = nombre;
        this.posicion = posicion;
        this.club = club;
    }

    public int getIdJugador() { return idJugador; }
    public void setIdJugador(int idJugador) { this.idJugador = idJugador; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getPosicion() { return posicion; }
    public void setPosicion(String posicion) { this.posicion = posicion; }

    public String getClub() { return club; }
    public void setClub(String club) { this.club = club; }

    @Override
    public String toString() {
        return nombre + " (" + posicion + (club != null && !club.isEmpty() ? " - " + club : "") + ")";
    }
}
