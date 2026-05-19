package com.polideportivo.servlet;

import com.polideportivo.dao.ReservaDAO;
import com.polideportivo.dao.UsuarioDAO;
import com.polideportivo.model.Reserva;
import com.polideportivo.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class UsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String pathInfo = req.getPathInfo(); // ej: "/reservas", "/datos"

        if ("/reservas".equals(pathInfo)) {
            mostrarReservas(req, resp);
        } else if ("/datos".equals(pathInfo)) {
            req.getRequestDispatcher("/jsp/perfil.jsp").forward(req, resp);
        } else {
            // Panel principal — cargamos las reservas para mostrarlas
            mostrarPanel(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String pathInfo = req.getPathInfo();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if ("/datos".equals(pathInfo)) {
            actualizarDatos(req, resp, usuario, session);
        } else if ("/contrasena".equals(pathInfo)) {
            cambiarContrasena(req, resp, usuario);
        } else {
            resp.sendRedirect(req.getContextPath() + "/usuario");
        }
    }

    private void mostrarPanel(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getSession().getAttribute("usuario");
        try {
            ReservaDAO dao = new ReservaDAO();
            List<Reserva> reservas = dao.listarPorUsuario(usuario.getId());
            req.setAttribute("reservas", reservas);
        } catch (Exception e) {
            // Si falla, simplemente el panel cargará sin reservas
        }
        req.getRequestDispatcher("/jsp/panel.jsp").forward(req, resp);
    }

    private void mostrarReservas(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getSession().getAttribute("usuario");
        try {
            ReservaDAO dao = new ReservaDAO();
            List<Reserva> reservas = dao.listarPorUsuario(usuario.getId());
            req.setAttribute("reservas", reservas);
            req.getRequestDispatcher("/jsp/mis_reservas.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Error al cargar reservas", e);
        }
    }

    private void actualizarDatos(HttpServletRequest req, HttpServletResponse resp,
                                  Usuario usuario, HttpSession session)
            throws IOException {
        req.setCharacterEncoding("UTF-8");
        String nombre    = req.getParameter("nombre");
        String apellidos = req.getParameter("apellidos");
        String email     = req.getParameter("email");
        String telefono  = req.getParameter("telefono");

        if (nombre == null || nombre.isBlank() || apellidos == null || apellidos.isBlank()
                || email == null || email.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=campos_vacios");
            return;
        }

        usuario.setNombre(nombre.trim());
        usuario.setApellidos(apellidos.trim());
        usuario.setEmail(email.trim());
        usuario.setTelefono(telefono != null ? telefono.trim() : "");

        UsuarioDAO dao = new UsuarioDAO();
        if (dao.actualizarDatos(usuario)) {
            session.setAttribute("usuario", usuario); // actualizamos la sesión
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?ok=datos_actualizados");
        } else {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=error_db");
        }
    }

    private void cambiarContrasena(HttpServletRequest req, HttpServletResponse resp,
                                    Usuario usuario) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String actual  = req.getParameter("passwordActual");
        String nueva   = req.getParameter("passwordNueva");
        String nueva2  = req.getParameter("passwordNueva2");

        if (actual == null || nueva == null || nueva2 == null
                || actual.isBlank() || nueva.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=campos_vacios");
            return;
        }
        if (!nueva.equals(nueva2)) {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=contrasenas_no_coinciden");
            return;
        }
        if (nueva.length() < 6) {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=contrasena_corta");
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();
        if (dao.cambiarPassword(usuario.getId(), actual, nueva)) {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?ok=contrasena_cambiada");
        } else {
            resp.sendRedirect(req.getContextPath() + "/usuario/datos?error=contrasena_incorrecta");
        }
    }
}

