package com.polideportivo.servlet;

import com.polideportivo.dao.UsuarioDAO;
import com.polideportivo.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * RegistroServlet — gestiona el registro de nuevos usuarios.
 *
 * GET  /registro → muestra registro.jsp
 * POST /registro → valida datos, crea usuario y redirige al panel
 */
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Si ya está logueado, no tiene sentido registrarse
        HttpSession sesion = req.getSession(false);
        if (sesion != null && sesion.getAttribute("usuario") != null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/panel.jsp");
            return;
        }

        req.getRequestDispatcher("/jsp/registro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username   = req.getParameter("username");
        String password   = req.getParameter("password");
        String password2  = req.getParameter("password2");
        String nombre     = req.getParameter("nombre");
        String apellidos  = req.getParameter("apellidos");
        String email      = req.getParameter("email");
        String telefono   = req.getParameter("telefono");

        // --- Validaciones ---
        String error = validar(username, password, password2, nombre, apellidos, email);

        if (error == null) {
            UsuarioDAO dao = new UsuarioDAO();

            if (dao.existeUsername(username.trim())) {
                error = "Ese nombre de usuario ya está en uso.";
            } else if (dao.existeEmail(email.trim())) {
                error = "Ese email ya está registrado.";
            }
        }

        if (error != null) {
            // Devolvemos los campos para no borrarlos
            req.setAttribute("error",    error);
            req.setAttribute("username", username);
            req.setAttribute("nombre",   nombre);
            req.setAttribute("apellidos",apellidos);
            req.setAttribute("email",    email);
            req.setAttribute("telefono", telefono);
            req.getRequestDispatcher("/jsp/registro.jsp").forward(req, resp);
            return;
        }

        // --- Crear usuario ---
        Usuario nuevo = new Usuario();
        nuevo.setUsername(username.trim());
        nuevo.setPassword(password);           // UsuarioDAO hashea con BCrypt
        nuevo.setNombre(nombre.trim());
        nuevo.setApellidos(apellidos.trim());
        nuevo.setEmail(email.trim());
        nuevo.setTelefono(telefono != null ? telefono.trim() : "");

        UsuarioDAO dao = new UsuarioDAO();
        boolean ok = dao.registrar(nuevo);

        if (ok) {
            // Login automático tras registro
            Usuario registrado = dao.login(nuevo.getUsername(), password);
            HttpSession sesion = req.getSession(true);
            sesion.setAttribute("usuario", registrado);
            resp.sendRedirect(req.getContextPath() + "/jsp/panel.jsp");
        } else {
            req.setAttribute("error", "Error al crear la cuenta. Inténtalo de nuevo.");
            req.getRequestDispatcher("/jsp/registro.jsp").forward(req, resp);
        }
    }

    // ------------------------------------------------------------------
    // Validaciones básicas del formulario
    // ------------------------------------------------------------------
    private String validar(String username, String password, String password2,
                           String nombre, String apellidos, String email) {

        if (username == null || username.isBlank())   return "El nombre de usuario es obligatorio.";
        if (username.length() < 3)                    return "El usuario debe tener al menos 3 caracteres.";
        if (username.length() > 50)                   return "El usuario no puede superar 50 caracteres.";
        if (!username.matches("[a-zA-Z0-9_]+"))        return "El usuario solo puede contener letras, números y guión bajo.";

        if (nombre == null || nombre.isBlank())        return "El nombre es obligatorio.";
        if (apellidos == null || apellidos.isBlank())  return "Los apellidos son obligatorios.";

        if (email == null || email.isBlank())          return "El email es obligatorio.";
        if (!email.matches(".+@.+\\..+"))              return "El email no tiene un formato válido.";

        if (password == null || password.isBlank())    return "La contraseña es obligatoria.";
        if (password.length() < 6)                    return "La contraseña debe tener al menos 6 caracteres.";
        if (!password.equals(password2))               return "Las contraseñas no coinciden.";

        return null; // Sin errores
    }
}
