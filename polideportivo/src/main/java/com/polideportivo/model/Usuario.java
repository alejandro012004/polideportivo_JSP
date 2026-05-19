package com.polideportivo.model;

import java.time.LocalDateTime;

/**
 * Usuario — representa un usuario registrado en el sistema.
 * Se almacena en sesión tras el login: session.setAttribute("usuario", usuario)
 */
public class Usuario {

    private int           id;
    private String        username;
    private String        password;   // hash, nunca se manda a la vista
    private String        nombre;
    private String        apellidos;
    private String        email;
    private String        telefono;
    private LocalDateTime fechaAlta;
    private boolean       activo;

    public Usuario() {}

    public Usuario(int id, String username, String nombre,
                   String apellidos, String email, String telefono,
                   LocalDateTime fechaAlta, boolean activo) {
        this.id        = id;
        this.username  = username;
        this.nombre    = nombre;
        this.apellidos = apellidos;
        this.email     = email;
        this.telefono  = telefono;
        this.fechaAlta = fechaAlta;
        this.activo    = activo;
    }

    // Getters y setters
    public int getId()                        { return id; }
    public void setId(int id)                 { this.id = id; }

    public String getUsername()               { return username; }
    public void setUsername(String username)  { this.username = username; }

    public String getPassword()               { return password; }
    public void setPassword(String password)  { this.password = password; }

    public String getNombre()                 { return nombre; }
    public void setNombre(String nombre)      { this.nombre = nombre; }

    public String getApellidos()              { return apellidos; }
    public void setApellidos(String ap)       { this.apellidos = ap; }

    public String getEmail()                  { return email; }
    public void setEmail(String email)        { this.email = email; }

    public String getTelefono()               { return telefono; }
    public void setTelefono(String telefono)  { this.telefono = telefono; }

    public LocalDateTime getFechaAlta()                  { return fechaAlta; }
    public void setFechaAlta(LocalDateTime fechaAlta)    { this.fechaAlta = fechaAlta; }

    public boolean isActivo()                 { return activo; }
    public void setActivo(boolean activo)     { this.activo = activo; }

    /** Nombre completo para mostrar en la interfaz */
    public String getNombreCompleto() {
        return nombre + " " + apellidos;
    }

    @Override
    public String toString() {
        return "Usuario{id=" + id + ", username='" + username + "', email='" + email + "'}";
    }
}
