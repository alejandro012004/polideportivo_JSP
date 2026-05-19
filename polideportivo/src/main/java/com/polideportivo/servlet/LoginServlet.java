package com.polideportivo.servlet;

import com.polideportivo.dao.UsuarioDAO;
import com.polideportivo.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

// GET /login  -> muestra el formulario
// POST /login -> valida y crea la sesion
// GET /login?action=logout -> destruye la sesion
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession sesion = req.getSession(false);
            if (sesion != null) sesion.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // si ya esta logueado no tiene sentido que vea el login
        HttpSession sesion = req.getSession(false);
        if (sesion != null && sesion.getAttribute("usuario") != null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/panel.jsp");
            return;
        }

        req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String recuerdame = req.getParameter("recuerdame");

        if (username == null || username.isBlank() ||
            password == null || password.isBlank()) {
            req.setAttribute("error", "Introduce usuario y contraseña.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();
        Usuario usuario = dao.login(username.trim(), password);

        if (usuario != null) {
            HttpSession sesion = req.getSession(true);
            sesion.setAttribute("usuario", usuario);
            sesion.setMaxInactiveInterval(30 * 60);

            if ("on".equals(recuerdame)) {
                Cookie cookie = new Cookie("usuario_recordado", usuario.getUsername());
                cookie.setMaxAge(7 * 24 * 60 * 60);
                cookie.setPath(req.getContextPath());
                resp.addCookie(cookie);
            }

            resp.sendRedirect(req.getContextPath() + "/jsp/panel.jsp");
        } else {
            req.setAttribute("error", "Usuario o contraseña incorrectos.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }
}
