package com.polideportivo.servlet;

import com.polideportivo.dao.PistaDAO;
import com.polideportivo.dao.ReservaDAO;
import com.polideportivo.model.Pista;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DisponibilidadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        PistaDAO pistaDAO = new PistaDAO();
        ReservaDAO reservaDAO = new ReservaDAO();

        try {
            String fechaParam = req.getParameter("fecha");
            LocalDate fecha;
            try {
                fecha = (fechaParam != null && !fechaParam.isEmpty())
                        ? LocalDate.parse(fechaParam)
                        : LocalDate.now();
            } catch (DateTimeParseException e) {
                fecha = LocalDate.now();
            }

            if (fecha.isBefore(LocalDate.now())) {
                fecha = LocalDate.now();
            }

            String tipoFiltro = req.getParameter("tipo");

            List<Pista> pistas;
            if (tipoFiltro != null && !tipoFiltro.isEmpty()) {
                pistas = pistaDAO.listarPorTipo(tipoFiltro);
            } else {
                pistas = pistaDAO.listarTodas();
            }

            // tramos ocupados por pista
            Map<Integer, List<String>> ocupacion = new HashMap<>();
            // usuario que ocupa cada tramo (clave: pistaId_tramo -> username)
            Map<String, String> usuariosOcupacion = new HashMap<>();

            for (Pista p : pistas) {
                ocupacion.put(p.getId(), reservaDAO.tramosOcupados(p.getId(), fecha));
                // cargamos el mapa tramo->username para esta pista
                Map<String, String> porPista = reservaDAO.tramosConUsuario(p.getId(), fecha);
                for (Map.Entry<String, String> e : porPista.entrySet()) {
                    usuariosOcupacion.put(p.getId() + "_" + e.getKey(), e.getValue());
                }
            }

            req.setAttribute("pistas", pistas);
            req.setAttribute("ocupacion", ocupacion);
            req.setAttribute("usuariosOcupacion", usuariosOcupacion);
            req.setAttribute("tramos", ReservaDAO.TRAMOS);
            req.setAttribute("fecha", fecha.toString());
            req.setAttribute("tipoFiltro", tipoFiltro != null ? tipoFiltro : "");

            req.getRequestDispatcher("/jsp/disponibilidad.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Error al cargar disponibilidad", e);
        }
    }
}
