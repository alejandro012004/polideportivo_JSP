package com.polideportivo.servlet;

import com.polideportivo.dao.ReservaDAO;
import com.polideportivo.model.Reserva;
import com.polideportivo.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;

public class ReservaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = req.getParameter("action");

        if ("crear".equals(action)) {
            crearReserva(req, resp, usuario);
        } else if ("cancelar".equals(action)) {
            cancelarReserva(req, resp, usuario);
        } else {
            resp.sendRedirect(req.getContextPath() + "/disponibilidad");
        }
    }

    private void crearReserva(HttpServletRequest req, HttpServletResponse resp, Usuario usuario)
            throws IOException {
        try {
            int pistaId = Integer.parseInt(req.getParameter("pistaId"));
            String fechaStr = req.getParameter("fecha");
            String horaStr = req.getParameter("hora");  // "HH:mm"

            LocalDate fecha = LocalDate.parse(fechaStr);
            LocalTime horaInicio = LocalTime.parse(horaStr);
            LocalTime horaFin = horaInicio.plusHours(1);

            // Validación: no puede reservar en el pasado
            if (fecha.isBefore(LocalDate.now())) {
                resp.sendRedirect(req.getContextPath() + "/disponibilidad?error=fecha_pasada&fecha=" + fechaStr);
                return;
            }

            // Validación: máximo 1 semana de antelación
            if (fecha.isAfter(LocalDate.now().plusDays(7))) {
                resp.sendRedirect(req.getContextPath() + "/disponibilidad?error=demasiado_lejos&fecha=" + fechaStr);
                return;
            }

            Reserva r = new Reserva();
            r.setUsuarioId(usuario.getId());
            r.setPistaId(pistaId);
            r.setFecha(fecha);
            r.setHoraInicio(horaInicio);
            r.setHoraFin(horaFin);

            ReservaDAO dao = new ReservaDAO();
            boolean ok = dao.crear(r);

            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/usuario/reservas?ok=reserva_creada");
            } else {
                resp.sendRedirect(req.getContextPath() + "/disponibilidad?error=ya_ocupada&fecha=" + fechaStr);
            }

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/disponibilidad?error=error_general");
        }
    }

    private void cancelarReserva(HttpServletRequest req, HttpServletResponse resp, Usuario usuario)
            throws IOException {
        try {
            int reservaId = Integer.parseInt(req.getParameter("reservaId"));
            ReservaDAO dao = new ReservaDAO();
            dao.cancelar(reservaId, usuario.getId());
            resp.sendRedirect(req.getContextPath() + "/usuario/reservas?ok=cancelada");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/usuario/reservas?error=error_cancelar");
        }
    }
}
