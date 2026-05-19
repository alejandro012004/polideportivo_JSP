package com.polideportivo.model;

public class Pista {
    private int id;
    private String nombre;
    private String tipo;       // "futbol_sala" o "tenis"
    private String descripcion;
    private boolean activa;

    public Pista() {}

    public Pista(int id, String nombre, String tipo, String descripcion, boolean activa) {
        this.id = id;
        this.nombre = nombre;
        this.tipo = tipo;
        this.descripcion = descripcion;
        this.activa = activa;
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public boolean isActiva() { return activa; }
    public void setActiva(boolean activa) { this.activa = activa; }

    public String getTipoLabel() {
        if ("futbol_sala".equals(tipo)) return "Fútbol Sala";
        if ("tenis".equals(tipo)) return "Tenis";
        return tipo;
    }

    public String getIcono() {
        if ("futbol_sala".equals(tipo)) return "⚽";
        if ("tenis".equals(tipo)) return "🎾";
        return "🏟️";
    }
}
