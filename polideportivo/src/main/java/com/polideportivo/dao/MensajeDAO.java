package com.polideportivo.dao;

import com.polideportivo.model.Mensaje;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MensajeDAO {
    private final Connection con;

    public MensajeDAO() {
        this.con = DBConexion.getInstancia().getConexion();
    }

    public boolean enviarMensaje(Mensaje mensaje) {
        String sql = "INSERT INTO mensajes (id_remitente, id_destinatario, asunto, cuerpo) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, mensaje.getIdRemitente());
            ps.setInt(2, mensaje.getIdDestinatario());
            ps.setString(3, mensaje.getAsunto());
            ps.setString(4, mensaje.getCuerpo());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error enviando mensaje: " + e.getMessage());
            return false;
        }
    }

    public List<Mensaje> listarRecibidos(int idDestinatario) {
        List<Mensaje> lista = new ArrayList<>();
        String sql = "SELECT m.*, u.username AS remitente_username FROM mensajes m " +
                     "JOIN usuarios u ON m.id_remitente = u.id " +
                     "WHERE m.id_destinatario = ? ORDER BY m.fecha_envio DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idDestinatario);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(mapearConRemitente(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error listarRecibidos: " + e.getMessage());
        }
        return lista;
    }

    public List<Mensaje> listarEnviados(int idRemitente) {
        List<Mensaje> lista = new ArrayList<>();
        String sql = "SELECT m.*, u.username AS destinatario_username FROM mensajes m " +
                     "JOIN usuarios u ON m.id_destinatario = u.id " +
                     "WHERE m.id_remitente = ? ORDER BY m.fecha_envio DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idRemitente);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(mapearConDestinatario(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error listarEnviados: " + e.getMessage());
        }
        return lista;
    }

    public Mensaje leerMensaje(int idMensaje, int idUsuarioLogueado) {
        String sql = "SELECT m.*, u1.username AS remitente_username, u2.username AS destinatario_username " +
                     "FROM mensajes m " +
                     "JOIN usuarios u1 ON m.id_remitente = u1.id " +
                     "JOIN usuarios u2 ON m.id_destinatario = u2.id " +
                     "WHERE m.id = ? AND (m.id_destinatario = ? OR m.id_remitente = ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idMensaje);
            ps.setInt(2, idUsuarioLogueado);
            ps.setInt(3, idUsuarioLogueado);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Mensaje m = mapearBasico(rs);
                m.setRemitenteUsername(rs.getString("remitente_username"));
                m.setDestinatarioUsername(rs.getString("destinatario_username"));
                
                // Si el usuario es el destinatario y el mensaje no está leído, marcar como leído
                if (m.getIdDestinatario() == idUsuarioLogueado && !m.isLeido()) {
                    marcarLeido(idMensaje);
                    m.setLeido(true);
                }
                return m;
            }
        } catch (SQLException e) {
            System.err.println("Error leerMensaje: " + e.getMessage());
        }
        return null;
    }

    private void marcarLeido(int idMensaje) {
        String sql = "UPDATE mensajes SET leido = 1 WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idMensaje);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error marcarLeido: " + e.getMessage());
        }
    }
    
    public int contarNoLeidos(int idDestinatario) {
        String sql = "SELECT COUNT(*) FROM mensajes WHERE id_destinatario = ? AND leido = 0";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idDestinatario);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("Error contarNoLeidos: " + e.getMessage());
        }
        return 0;
    }

    private Mensaje mapearBasico(ResultSet rs) throws SQLException {
        Mensaje m = new Mensaje();
        m.setId(rs.getInt("id"));
        m.setIdRemitente(rs.getInt("id_remitente"));
        m.setIdDestinatario(rs.getInt("id_destinatario"));
        m.setAsunto(rs.getString("asunto"));
        m.setCuerpo(rs.getString("cuerpo"));
        Timestamp ts = rs.getTimestamp("fecha_envio");
        if (ts != null) m.setFechaEnvio(ts.toLocalDateTime());
        m.setLeido(rs.getBoolean("leido"));
        return m;
    }

    private Mensaje mapearConRemitente(ResultSet rs) throws SQLException {
        Mensaje m = mapearBasico(rs);
        m.setRemitenteUsername(rs.getString("remitente_username"));
        return m;
    }

    private Mensaje mapearConDestinatario(ResultSet rs) throws SQLException {
        Mensaje m = mapearBasico(rs);
        m.setDestinatarioUsername(rs.getString("destinatario_username"));
        return m;
    }
}
