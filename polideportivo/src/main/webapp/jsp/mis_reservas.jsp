<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login?error=sesion");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Reservas – Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .reservas-table { width:100%; border-collapse:collapse; margin-top:16px; }
        .reservas-table th { background: var(--verde); color:#fff; padding:10px 12px; text-align:left; }
        .reservas-table td { border-bottom:1px solid #eee; padding:10px 12px; vertical-align:middle; }
        .reservas-table tr:hover td { background: var(--verde-bg); }
        .badge-tipo {
            display:inline-block; padding:2px 10px; border-radius:10px;
            font-size:0.78rem; font-weight:600;
        }
        .badge-futbol { background:#cce5ff; color:#004085; }
        .badge-tenis  { background:#d4edda; color:#155724; }
        .sin-reservas { text-align:center; color:#888; padding:50px 0; }
    </style>
</head>
<body>

<nav class="navbar">
    <a class="navbar-marca" href="${pageContext.request.contextPath}/disponibilidad">
        🏟️ Polideportivo Martos
    </a>
    <ul class="navbar-nav">
        <li><a href="${pageContext.request.contextPath}/disponibilidad">🗓 <span>Pistas</span></a></li>
        <li><a href="${pageContext.request.contextPath}/usuario/reservas">📋 <span>Mis Reservas</span></a></li>
        <li><a href="${pageContext.request.contextPath}/mensaje">✉ <span>Mensajes</span></a></li>
        <li><a href="${pageContext.request.contextPath}/usuario/datos">👤 <span>Mi perfil</span></a></li>
        <li><a href="${pageContext.request.contextPath}/login?action=logout">🚪 <span>Salir</span></a></li>
    </ul>
</nav>

<div class="contenedor">
    <div class="card">
        <h2>📋 Mis Reservas</h2>
        <p style="color:var(--gris-medio); margin-bottom: 12px;">Aquí puedes ver y cancelar tus reservas activas.</p>

        <c:if test="${param.ok == 'reserva_creada'}">
            <div class="alerta alerta-exito">✅ Reserva realizada correctamente.</div>
        </c:if>
        <c:if test="${param.ok == 'cancelada'}">
            <div class="alerta alerta-exito">✅ Reserva cancelada correctamente.</div>
        </c:if>
        <c:if test="${param.error == 'error_cancelar'}">
            <div class="alerta alerta-error">⚠️ No se pudo cancelar la reserva.</div>
        </c:if>

        <c:choose>
            <c:when test="${empty reservas}">
                <div class="sin-reservas">
                    <p style="font-size:3rem;">📅</p>
                    <p>No tienes reservas activas.</p>
                    <a href="${pageContext.request.contextPath}/disponibilidad"
                       class="btn btn-primario" style="display:inline-block;margin-top:12px;text-decoration:none;">
                        Ver disponibilidad
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <table class="reservas-table">
                    <thead>
                        <tr>
                            <th>Pista</th>
                            <th>Tipo</th>
                            <th>Fecha</th>
                            <th>Horario</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${reservas}">
                            <tr>
                                <td><strong>${r.pistaNombre}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.pistaTipo == 'futbol_sala'}">
                                            <span class="badge-tipo badge-futbol">⚽ Fútbol Sala</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-tipo badge-tenis">🎾 Tenis</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${r.fecha}</td>
                                <td>${r.tramoHorario}</td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/reserva"
                                          onsubmit="return confirm('¿Seguro que quieres cancelar esta reserva?');">
                                        <input type="hidden" name="action" value="cancelar">
                                        <input type="hidden" name="reservaId" value="${r.id}">
                                        <button type="submit" class="btn btn-peligro" style="font-size:0.82rem; padding:5px 12px;">✖ Cancelar</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<footer style="text-align:center; padding:20px; color:var(--gris-medio); font-size:0.8rem; margin-top:20px;">
    © 2025 Polideportivo Municipal de Martos
</footer>
</body>
</html>
