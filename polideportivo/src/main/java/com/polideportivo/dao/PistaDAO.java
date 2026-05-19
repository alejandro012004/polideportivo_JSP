package com.polideportivo.dao;

import com.polideportivo.model.Pista;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PistaDAO {

    public List<Pista> listarTodas() throws SQLException {
        List<Pista> lista = new ArrayList<>();
        String sql = "SELECT * FROM pistas WHERE activa = 1 ORDER BY tipo, nombre";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        }
        return lista;
    }

    public Pista buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM pistas WHERE id = ?";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public List<Pista> listarPorTipo(String tipo) throws SQLException {
        List<Pista> lista = new ArrayList<>();
        String sql = "SELECT * FROM pistas WHERE tipo = ? AND activa = 1 ORDER BY nombre";
        try (Connection con = DBConexion.getInstancia().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tipo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    private Pista mapear(ResultSet rs) throws SQLException {
        Pista p = new Pista();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setTipo(rs.getString("tipo"));
        p.setActiva(rs.getBoolean("activa"));
        return p;
    }
}