package com.polideportivo.servlet;

import com.polideportivo.dao.MensajeDAO;
import com.polideportivo.dao.UsuarioDAO;
import com.polideportivo.model.Mensaje;
import com.polideportivo.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class MensajeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuarioLogueado = (Usuario) req.getSession().getAttribute("usuario");
        if (usuarioLogueado == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();
        if (path == null || path.equals("/") || path.equals("/recibidos")) {
            mostrarRecibidos(req, resp, usuarioLogueado);
        } else if (path.equals("/enviados")) {
            mostrarEnviados(req, resp, usuarioLogueado);
        } else if (path.equals("/nuevo")) {
            String para = req.getParameter("para");
            if (para != null) {
                req.setAttribute("para", para);
            }
            req.setAttribute("vista", "nuevo");
            req.getRequestDispatcher("/jsp/mensajes.jsp").forward(req, resp);
        } else if (path.equals("/leer")) {
            leerMensaje(req, resp, usuarioLogueado);
        } else {
            resp.sendRedirect(req.getContextPath() + "/mensaje/recibidos");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuarioLogueado = (Usuario) req.getSession().getAttribute("usuario");
        if (usuarioLogueado == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();
        if (path != null && path.equals("/enviar")) {
            enviarMensaje(req, resp, usuarioLogueado);
        } else {
            resp.sendRedirect(req.getContextPath() + "/mensaje/recibidos");
        }
    }

    private void mostrarRecibidos(HttpServletRequest req, HttpServletResponse resp, Usuario u) throws ServletException, IOException {
        MensajeDAO dao = new MensajeDAO();
        List<Mensaje> mensajes = dao.listarRecibidos(u.getId());
        req.setAttribute("mensajes", mensajes);
        req.setAttribute("vista", "recibidos");
        req.getRequestDispatcher("/jsp/mensajes.jsp").forward(req, resp);
    }

    private void mostrarEnviados(HttpServletRequest req, HttpServletResponse resp, Usuario u) throws ServletException, IOException {
        MensajeDAO dao = new MensajeDAO();
        List<Mensaje> mensajes = dao.listarEnviados(u.getId());
        req.setAttribute("mensajes", mensajes);
        req.setAttribute("vista", "enviados");
        req.getRequestDispatcher("/jsp/mensajes.jsp").forward(req, resp);
    }

    private void leerMensaje(HttpServletRequest req, HttpServletResponse resp, Usuario u) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/mensaje");
            return;
        }
        
        try {
            int idMensaje = Integer.parseInt(idParam);
            MensajeDAO dao = new MensajeDAO();
            Mensaje m = dao.leerMensaje(idMensaje, u.getId());
            
            if (m == null) {
                resp.sendRedirect(req.getContextPath() + "/mensaje?error=no_encontrado");
                return;
            }
            
            req.setAttribute("mensajeLeido", m);
            req.setAttribute("vista", "leer");
            req.getRequestDispatcher("/jsp/mensajes.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/mensaje");
        }
    }

    private void enviarMensaje(HttpServletRequest req, HttpServletResponse resp, Usuario u) throws IOException {
        String destinatarioUsername = req.getParameter("destinatario");
        String asunto = req.getParameter("asunto");
        String cuerpo = req.getParameter("cuerpo");

        if (destinatarioUsername == null || destinatarioUsername.trim().isEmpty() ||
            cuerpo == null || cuerpo.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/mensaje/nuevo?error=campos_vacios");
            return;
        }

        UsuarioDAO uDao = new UsuarioDAO();
        List<Usuario> encontrados = uDao.buscarPorUsername(destinatarioUsername);
        
        Usuario destinatario = null;
        for (Usuario user : encontrados) {
            if (user.getUsername().equalsIgnoreCase(destinatarioUsername)) {
                destinatario = user;
                break;
            }
        }

        if (destinatario == null) {
            resp.sendRedirect(req.getContextPath() + "/mensaje/nuevo?error=usuario_no_existe");
            return;
        }

        if (destinatario.getId() == u.getId()) {
            resp.sendRedirect(req.getContextPath() + "/mensaje/nuevo?error=mismo_usuario");
            return;
        }

        Mensaje m = new Mensaje();
        m.setIdRemitente(u.getId());
        m.setIdDestinatario(destinatario.getId());
        m.setAsunto(asunto == null ? "" : asunto);
        m.setCuerpo(cuerpo);

        MensajeDAO mDao = new MensajeDAO();
        if (mDao.enviarMensaje(m)) {
            resp.sendRedirect(req.getContextPath() + "/mensaje/enviados?exito=mensaje_enviado");
        } else {
            resp.sendRedirect(req.getContextPath() + "/mensaje/nuevo?error=error_db");
        }
    }
}
