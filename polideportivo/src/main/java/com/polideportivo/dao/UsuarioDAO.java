package com.polideportivo.dao;

import com.polideportivo.model.Usuario;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    private final Connection con;

    public UsuarioDAO() {
        this.con = DBConexion.getInstancia().getConexion();
    }

    // busca el usuario y comprueba la password con bcrypt
    public Usuario login(String username, String password) {
        String sql = "SELECT * FROM usuarios WHERE username = ? AND activo = 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String hashGuardado = rs.getString("password");
                if (BCrypt.checkpw(password, hashGuardado)) {
                    return mapear(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en login: " + e.getMessage());
        }
        return null;
    }

    // inserta el usuario nuevo con la contrasena hasheada
    public boolean registrar(Usuario usuario) {
        String sql = "INSERT INTO usuarios (username, password, nombre, apellidos, email, telefono) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String hash = BCrypt.hashpw(usuario.getPassword(), BCrypt.gensalt());
            ps.setString(1, usuario.getUsername());
            ps.setString(2, hash);
            ps.setString(3, usuario.getNombre());
            ps.setString(4, usuario.getApellidos());
            ps.setString(5, usuario.getEmail());
            ps.setString(6, usuario.getTelefono());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error en registro: " + e.getMessage());
            return false;
        }
    }

    public Usuario buscarPorId(int id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) {
            System.err.println("Error en buscarPorId: " + e.getMessage());
        }
        return null;
    }

    // para el buscador de mensajes
    public List<Usuario> buscarPorUsername(String termino) {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuarios WHERE username LIKE ? AND activo = 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + termino + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) {
            System.err.println("Error en buscarPorUsername: " + e.getMessage());
        }
        return lista;
    }

    public boolean actualizarDatos(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombre=?, apellidos=?, email=?, telefono=? WHERE id=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getApellidos());
            ps.setString(3, usuario.getEmail());
            ps.setString(4, usuario.getTelefono());
            ps.setInt(5, usuario.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error en actualizarDatos: " + e.getMessage());
            return false;
        }
    }

    public boolean cambiarPassword(int idUsuario, String passwordActual, String passwordNueva) {
        // primero verificamos que la actual es correcta
        String sqlGet = "SELECT password FROM usuarios WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlGet)) {
            ps.setInt(1, idUsuario);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String hashActual = rs.getString("password");
                if (!BCrypt.checkpw(passwordActual, hashActual)) {
                    return false;
                }
            } else {
                return false;
            }
        } catch (SQLException e) {
            System.err.println("Error verificando password: " + e.getMessage());
            return false;
        }

        String sqlUp = "UPDATE usuarios SET password = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlUp)) {
            ps.setString(1, BCrypt.hashpw(passwordNueva, BCrypt.gensalt()));
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error cambiando password: " + e.getMessage());
            return false;
        }
    }

    public boolean existeUsername(String username) {
        String sql = "SELECT id FROM usuarios WHERE username = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean existeEmail(String email) {
        String sql = "SELECT id FROM usuarios WHERE email = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            return false;
        }
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setNombre(rs.getString("nombre"));
        u.setApellidos(rs.getString("apellidos"));
        u.setEmail(rs.getString("email"));
        u.setTelefono(rs.getString("telefono"));
        Timestamp ts = rs.getTimestamp("fecha_alta");
        if (ts != null) u.setFechaAlta(ts.toLocalDateTime());
        u.setActivo(rs.getBoolean("activo"));
        return u;
    }
}
