package com.polideportivo.dao;

import com.polideportivo.model.Reserva;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReservaDAO {

    public static final String[] TRAMOS = {
            "09:00", "10:00", "11:00", "12:00", "13:00",
            "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    };

    public List<String> tramosOcupados(int pistaId, LocalDate fecha) throws SQLException {
        List<String> ocupados = new ArrayList<>();
        String sql = "SELECT hora_inicio FROM reservas WHERE id_pista = ? AND fecha = ? AND estado = 'activa'";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pistaId);
            ps.setDate(2, Date.valueOf(fecha));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ocupados.add(rs.getTime("hora_inicio").toLocalTime()
                            .toString().substring(0, 5));
                }
            }
        }
        return ocupados;
    }

    // devuelve mapa tramo -> username de quien lo tiene reservado
    // se usa en la vista de disponibilidad para mostrar quien ha reservado
    public Map<String, String> tramosConUsuario(int pistaId, LocalDate fecha) throws SQLException {
        Map<String, String> mapa = new HashMap<>();
        String sql = "SELECT r.hora_inicio, u.username " +
                     "FROM reservas r JOIN usuarios u ON r.id_usuario = u.id " +
                     "WHERE r.id_pista = ? AND r.fecha = ? AND r.estado = 'activa'";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pistaId);
            ps.setDate(2, Date.valueOf(fecha));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String tramo = rs.getTime("hora_inicio").toLocalTime().toString().substring(0, 5);
                    mapa.put(tramo, rs.getString("username"));
                }
            }
        }
        return mapa;
    }

    public boolean crear(Reserva r) throws SQLException {
        String sql = "INSERT INTO reservas (id_usuario, id_pista, fecha, hora_inicio, hora_fin, estado) " +
                "VALUES (?, ?, ?, ?, ?, 'activa')";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, r.getUsuarioId());
            ps.setInt(2, r.getPistaId());
            ps.setDate(3, Date.valueOf(r.getFecha()));
            ps.setTime(4, Time.valueOf(r.getHoraInicio()));
            ps.setTime(5, Time.valueOf(r.getHoraFin()));
            return ps.executeUpdate() > 0;
        }
    }

    public List<Reserva> listarPorUsuario(int usuarioId) throws SQLException {
        List<Reserva> lista = new ArrayList<>();
        String sql = "SELECT r.*, p.nombre AS pista_nombre, p.tipo AS pista_tipo " +
                "FROM reservas r JOIN pistas p ON r.id_pista = p.id " +
                "WHERE r.id_usuario = ? AND r.estado = 'activa' " +
                "ORDER BY r.fecha DESC, r.hora_inicio";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    public boolean cancelar(int reservaId, int usuarioId) throws SQLException {
        String sql = "UPDATE reservas SET estado = 'cancelada' " +
                "WHERE id = ? AND id_usuario = ? AND estado = 'activa'";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservaId);
            ps.setInt(2, usuarioId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Reserva> listarTodas() throws SQLException {
        List<Reserva> lista = new ArrayList<>();
        String sql = "SELECT r.*, p.nombre AS pista_nombre, p.tipo AS pista_tipo, " +
                "u.nombre AS usuario_nombre " +
                "FROM reservas r " +
                "JOIN pistas p ON r.id_pista = p.id " +
                "JOIN usuarios u ON r.id_usuario = u.id " +
                "WHERE r.estado = 'activa' ORDER BY r.fecha, r.hora_inicio";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    private Reserva mapear(ResultSet rs) throws SQLException {
        Reserva r = new Reserva();
        r.setId(rs.getInt("id"));
        r.setUsuarioId(rs.getInt("id_usuario"));
        r.setPistaId(rs.getInt("id_pista"));
        r.setFecha(rs.getDate("fecha").toLocalDate());
        r.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
        r.setHoraFin(rs.getTime("hora_fin").toLocalTime());
        r.setEstado(rs.getString("estado"));
        try { r.setPistaNombre(rs.getString("pista_nombre")); } catch (SQLException ignored) {}
        try { r.setPistaTipo(rs.getString("pista_tipo")); } catch (SQLException ignored) {}
        try { r.setUsuarioNombre(rs.getString("usuario_nombre")); } catch (SQLException ignored) {}
        return r;
    }
}
