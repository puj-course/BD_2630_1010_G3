package mundial.datos;

import java.sql.Date;

public class Edicion {

    private int idEdicion;
    private int anio;
    private String lema;
    private Date fechaInicio;
    private Date fechaFin;

    public Edicion(int idEdicion, int anio, String lema, Date fechaInicio, Date fechaFin) {
        this.idEdicion = idEdicion;
        this.anio = anio;
        this.lema = lema;
        this.fechaInicio = fechaInicio;
        this.fechaFin = fechaFin;
    }

    public int getIdEdicion() { return idEdicion; }
    public void setIdEdicion(int idEdicion) { this.idEdicion = idEdicion; }

    public int getAnio() { return anio; }
    public void setAnio(int anio) { this.anio = anio; }

    public String getLema() { return lema; }
    public void setLema(String lema) { this.lema = lema; }

    public Date getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(Date fechaInicio) { this.fechaInicio = fechaInicio; }

    public Date getFechaFin() { return fechaFin; }
    public void setFechaFin(Date fechaFin) { this.fechaFin = fechaFin; }

    @Override
    public String toString() {
        return "Edicion " + anio + " (" + idEdicion + ")";
    }
}
