package com.polideportivo.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

// Singleton para la conexion a MySQL
// uso: Connection con = DBConexion.getInstancia().getConexion();
public class DBConexion {

    private static DBConexion instancia;
    private Connection conexion;

    private String url;
    private String usuario;
    private String password;
    private String driver;

    private DBConexion() {
        cargarPropiedades();
        conectar();
    }

    public static synchronized DBConexion getInstancia() {
        if (instancia == null) {
            instancia = new DBConexion();
        }
        return instancia;
    }

    public Connection getConexion() {
        try {
            if (conexion == null || conexion.isClosed()) {
                conectar();
            }
        } catch (SQLException e) {
            conectar();
        }
        return conexion;
    }

    private void cargarPropiedades() {
        Properties props = new Properties();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("db.properties")) {
            if (is == null) {
                throw new RuntimeException("No se encontro db.properties");
            }
            props.load(is);
            this.driver   = props.getProperty("db.driver");
            this.url      = props.getProperty("db.url");
            this.usuario  = props.getProperty("db.usuario");
            this.password = props.getProperty("db.password");
        } catch (IOException e) {
            throw new RuntimeException("Error al leer db.properties: " + e.getMessage(), e);
        }
    }

    private void conectar() {
        try {
            Class.forName(driver);
            this.conexion = DriverManager.getConnection(url, usuario, password);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver MySQL no encontrado: " + e.getMessage(), e);
        } catch (SQLException e) {
            throw new RuntimeException("Error al conectar: " + e.getMessage(), e);
        }
    }

    public void cerrar() {
        if (conexion != null) {
            try {
                conexion.close();
            } catch (SQLException e) {
                System.err.println("Error al cerrar conexion: " + e.getMessage());
            } finally {
                conexion  = null;
                instancia = null;
            }
        }
    }
}
