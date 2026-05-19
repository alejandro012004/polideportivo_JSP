package com.polideportivo.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class Reserva {
    private int id;
    private int usuarioId;
    private int pistaId;
    private LocalDate fecha;
    private LocalTime horaInicio;
    private LocalTime horaFin;
    private String estado;   // "activa", "cancelada"
    // Campos extra para JOINs
    private String usuarioNombre;
    private String pistaNombre;
    private String pistaTipo;

    public Reserva() {}

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }

    public int getPistaId() { return pistaId; }
    public void setPistaId(int pistaId) { this.pistaId = pistaId; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public LocalTime getHoraInicio() { return horaInicio; }
    public void setHoraInicio(LocalTime horaInicio) { this.horaInicio = horaInicio; }

    public LocalTime getHoraFin() { return horaFin; }
    public void setHoraFin(LocalTime horaFin) { this.horaFin = horaFin; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String usuarioNombre) { this.usuarioNombre = usuarioNombre; }

    public String getPistaNombre() { return pistaNombre; }
    public void setPistaNombre(String pistaNombre) { this.pistaNombre = pistaNombre; }

    public String getPistaTipo() { return pistaTipo; }
    public void setPistaTipo(String pistaTipo) { this.pistaTipo = pistaTipo; }

    public String getTramoHorario() {
        return (horaInicio != null && horaFin != null)
            ? horaInicio.toString() + " - " + horaFin.toString()
            : "";
    }
}
