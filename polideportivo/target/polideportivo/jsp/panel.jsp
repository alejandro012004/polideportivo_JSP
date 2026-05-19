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
    <title>Mi Panel — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .panel-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        .acceso-rapido {
            text-decoration: none;
            display: block;
        }
        .acceso-rapido .card {
            text-align: center;
            cursor: pointer;
            transition: transform 0.15s, box-shadow 0.15s;
            margin-bottom: 0;
        }
        .acceso-rapido .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.13);
        }
        .acceso-icono { font-size: 2rem; margin-bottom: 8px; }
        .badge-tipo {
            display:inline-block; padding:2px 10px; border-radius:10px;
            font-size:0.78rem; font-weight:600;
        }
        .badge-futbol { background:#cce5ff; color:#004085; }
        .badge-tenis  { background:#d4edda; color:#155724; }
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

    <%-- Bienvenida --%>
    <div class="card">
        <h2>👋 Bienvenido/a, ${sessionScope.usuario.nombre}</h2>
        <p style="color:var(--gris-medio);">
            @${sessionScope.usuario.username} &bull;
            ${sessionScope.usuario.email}
        </p>
    </div>

    <%-- Accesos rápidos --%>
    <div class="panel-grid">
        <a class="acceso-rapido" href="${pageContext.request.contextPath}/disponibilidad">
            <div class="card">
                <div class="acceso-icono">🗓</div>
                <strong>Ver disponibilidad</strong>
                <p style="font-size:0.85rem; color:var(--gris-medio); margin-top:4px;">
                    Consulta y reserva pistas
                </p>
            </div>
        </a>

        <a class="acceso-rapido" href="${pageContext.request.contextPath}/usuario/reservas">
            <div class="card">
                <div class="acceso-icono">📋</div>
                <strong>Mis reservas</strong>
                <p style="font-size:0.85rem; color:var(--gris-medio); margin-top:4px;">
                    <c:choose>
                        <c:when test="${empty reservas}">Sin reservas activas</c:when>
                        <c:otherwise>${reservas.size()} reserva(s) activa(s)</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </a>

        <a class="acceso-rapido" href="${pageContext.request.contextPath}/mensaje">
            <div class="card">
                <div class="acceso-icono">✉️</div>
                <strong>Mensajes</strong>
                <p style="font-size:0.85rem; color:var(--gris-medio); margin-top:4px;">
                    Mensajes privados
                </p>
            </div>
        </a>

        <a class="acceso-rapido" href="${pageContext.request.contextPath}/usuario/datos">
            <div class="card">
                <div class="acceso-icono">✏️</div>
                <strong>Mis datos</strong>
                <p style="font-size:0.85rem; color:var(--gris-medio); margin-top:4px;">
                    Editar perfil y contraseña
                </p>
            </div>
        </a>
    </div>

    <%-- Resumen de reservas activas --%>
    <div class="card">
        <h2>📋 Mis próximas reservas</h2>
        <c:choose>
            <c:when test="${empty reservas}">
                <p style="color:var(--gris-medio); text-align:center; padding:20px 0;">
                    No tienes reservas activas. <br>
                    <a href="${pageContext.request.contextPath}/disponibilidad"
                       style="color:var(--verde); font-weight:600;">
                        ¡Reserva una pista ahora!
                    </a>
                </p>
            </c:when>
            <c:otherwise>
                <table class="tabla-reservas">
                    <thead>
                        <tr>
                            <th>Pista</th>
                            <th>Tipo</th>
                            <th>Fecha</th>
                            <th>Horario</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${reservas}" begin="0" end="4">
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
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${reservas.size() > 5}">
                    <p style="text-align:right; margin-top:10px; font-size:0.9rem;">
                        <a href="${pageContext.request.contextPath}/usuario/reservas"
                           style="color:var(--verde);">
                            Ver todas las reservas →
                        </a>
                    </p>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<footer style="text-align:center; padding:20px; color:var(--gris-medio); font-size:0.8rem; margin-top:20px;">
    © 2025 Polideportivo Municipal de Martos
</footer>

</body>
</html>
