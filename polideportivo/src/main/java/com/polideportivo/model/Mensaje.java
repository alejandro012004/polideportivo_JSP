package com.polideportivo.model;

import java.time.LocalDateTime;

/**
 * Modelo que representa un mensaje privado entre dos usuarios.
 */
public class Mensaje {
    private int id;
    private int idRemitente;
    private int idDestinatario;
    private String asunto;
    private String cuerpo;
    private LocalDateTime fechaEnvio;
    private boolean leido;

    // Campos auxiliares para no hacer más consultas al pintar la vista
    private String remitenteUsername;
    private String destinatarioUsername;

    public Mensaje() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdRemitente() {
        return idRemitente;
    }

    public void setIdRemitente(int idRemitente) {
        this.idRemitente = idRemitente;
    }

    public int getIdDestinatario() {
        return idDestinatario;
    }

    public void setIdDestinatario(int idDestinatario) {
        this.idDestinatario = idDestinatario;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getCuerpo() {
        return cuerpo;
    }

    public void setCuerpo(String cuerpo) {
        this.cuerpo = cuerpo;
    }

    public LocalDateTime getFechaEnvio() {
        return fechaEnvio;
    }

    public void setFechaEnvio(LocalDateTime fechaEnvio) {
        this.fechaEnvio = fechaEnvio;
    }

    public boolean isLeido() {
        return leido;
    }

    public void setLeido(boolean leido) {
        this.leido = leido;
    }

    public String getRemitenteUsername() {
        return remitenteUsername;
    }

    public void setRemitenteUsername(String remitenteUsername) {
        this.remitenteUsername = remitenteUsername;
    }

    public String getDestinatarioUsername() {
        return destinatarioUsername;
    }

    public void setDestinatarioUsername(String destinatarioUsername) {
        this.destinatarioUsername = destinatarioUsername;
    }
}
