<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Disponibilidad de Pistas – Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .grid-disponibilidad { overflow-x: auto; }
        table.pistas-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 600px;
            font-size: 0.9rem;
        }
        table.pistas-table th {
            background: var(--verde);
            color: #fff;
            padding: 10px 8px;
            text-align: center;
            font-weight: 600;
        }
        table.pistas-table td {
            border: 1px solid #ddd;
            padding: 6px 8px;
            text-align: center;
            vertical-align: middle;
        }
        table.pistas-table tr:nth-child(even) td { background: #f5f9f6; }
        .slot-libre {
            background: #d4edda !important;
            color: #155724;
            font-weight: 600;
            cursor: pointer;
        }
        .slot-ocupado {
            background: #f8d7da !important;
            color: #721c24;
            font-weight: 600;
            cursor: default;
        }
        .slot-libre:hover { background: #b8dfc5 !important; }
        .btn-reservar {
            background: var(--verde);
            color: white;
            border: none;
            padding: 4px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.82rem;
        }
        .btn-reservar:hover { background: var(--verde-claro); }
        .link-usuario {
            display: block;
            font-size: 0.78rem;
            color: #721c24;
            text-decoration: underline;
            margin-top: 3px;
        }
        .link-usuario:hover { color: #490d14; }
        .filtros-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 20px;
            background: #f8f9fa;
            padding: 14px 16px;
            border-radius: 8px;
            border: 1px solid #dee2e6;
        }
        .filtros-bar label { font-weight: 600; font-size: 0.9rem; }
        .filtros-bar input[type=date],
        .filtros-bar select {
            padding: 6px 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 0.9rem;
        }
        .btn-filtrar {
            background: var(--verde);
            color: white;
            border: none;
            padding: 7px 18px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
        }
        .btn-filtrar:hover { background: var(--verde-claro); }
        .leyenda {
            display: flex;
            gap: 18px;
            margin-bottom: 14px;
            font-size: 0.85rem;
            align-items: center;
        }
        .leyenda span { display: inline-flex; align-items: center; gap: 6px; }
        .color-box {
            width: 16px; height: 16px;
            border-radius: 3px;
            display: inline-block;
        }
        .pista-header { font-size: 0.85rem; }
        .pista-tipo-badge {
            display: inline-block;
            font-size: 0.72rem;
            background: rgba(255,255,255,0.2);
            padding: 1px 6px;
            border-radius: 8px;
            margin-top: 2px;
        }
        .sin-sesion-aviso {
            background: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
            padding: 10px 16px;
            border-radius: 6px;
            margin-bottom: 14px;
            font-size: 0.88rem;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a class="navbar-marca" href="${pageContext.request.contextPath}/disponibilidad">
        🏟️ Polideportivo Martos
    </a>
    <ul class="navbar-nav">
        <li><a href="${pageContext.request.contextPath}/disponibilidad">🗓 <span>Pistas</span></a></li>
        <c:choose>
            <c:when test="${not empty sessionScope.usuario}">
                <li><a href="${pageContext.request.contextPath}/usuario/reservas">📋 <span>Mis Reservas</span></a></li>
                <li><a href="${pageContext.request.contextPath}/mensaje">✉ <span>Mensajes</span></a></li>
                <li><a href="${pageContext.request.contextPath}/usuario/datos">👤 <span>${sessionScope.usuario.nombre}</span></a></li>
                <li><a href="${pageContext.request.contextPath}/login?action=logout">🚪 <span>Salir</span></a></li>
            </c:when>
            <c:otherwise>
                <li><a href="${pageContext.request.contextPath}/login">Iniciar sesión</a></li>
                <li><a href="${pageContext.request.contextPath}/registro">Registrarse</a></li>
            </c:otherwise>
        </c:choose>
    </ul>
</nav>

<div class="contenedor">
    <h1 style="font-size:1.5rem; margin-bottom:6px;">Disponibilidad de Pistas</h1>
    <p style="color:var(--gris-medio); margin-bottom:16px;">
        Consulta los horarios libres y reserva tu pista fácilmente.
        Horario: 9:00–14:00 y 16:00–23:00. Máximo 7 días de antelación.
    </p>

    <%-- Alertas --%>
    <c:if test="${param.error == 'ya_ocupada'}">
        <div class="alerta alerta-error">⚠️ Ese tramo ya está reservado. Elige otro horario.</div>
    </c:if>
    <c:if test="${param.error == 'fecha_pasada'}">
        <div class="alerta alerta-error">⚠️ No puedes reservar en una fecha pasada.</div>
    </c:if>
    <c:if test="${param.error == 'demasiado_lejos'}">
        <div class="alerta alerta-error">⚠️ Solo se puede reservar con un máximo de 7 días de antelación.</div>
    </c:if>
    <c:if test="${param.error == 'error_general'}">
        <div class="alerta alerta-error">⚠️ Ha ocurrido un error. Inténtalo de nuevo.</div>
    </c:if>

    <%-- Aviso si no hay sesion --%>
    <c:if test="${empty sessionScope.usuario}">
        <div class="sin-sesion-aviso">
            ℹ️ Para realizar una reserva debes
            <a href="${pageContext.request.contextPath}/login">iniciar sesión</a>
            o <a href="${pageContext.request.contextPath}/registro">registrarte</a>.
        </div>
    </c:if>

    <%-- Filtros --%>
    <form method="get" action="${pageContext.request.contextPath}/disponibilidad" class="filtros-bar">
        <label for="fecha">Fecha:</label>
        <input type="date" id="fecha" name="fecha" value="${fecha}" required>

        <label for="tipo">Tipo:</label>
        <select id="tipo" name="tipo">
            <option value="" ${tipoFiltro == '' ? 'selected' : ''}>Todas</option>
            <option value="futbol_sala" ${tipoFiltro == 'futbol_sala' ? 'selected' : ''}>⚽ Fútbol Sala</option>
            <option value="tenis" ${tipoFiltro == 'tenis' ? 'selected' : ''}>🎾 Tenis</option>
        </select>

        <button type="submit" class="btn-filtrar">🔍 Buscar</button>
    </form>

    <%-- Leyenda --%>
    <div class="leyenda">
        <span><span class="color-box" style="background:#d4edda; border:1px solid #c3e6cb;"></span> Libre</span>
        <span><span class="color-box" style="background:#f8d7da; border:1px solid #f5c6cb;"></span> Ocupado</span>
        <c:if test="${not empty sessionScope.usuario}">
            <span style="color:#555; font-size:0.8rem;">· Pulsa en el usuario para enviarle un mensaje</span>
        </c:if>
    </div>

    <%-- Tabla de disponibilidad --%>
    <div class="grid-disponibilidad">
        <c:choose>
            <c:when test="${empty pistas}">
                <p style="color:#888; text-align:center; padding:40px 0;">No hay pistas disponibles para los filtros seleccionados.</p>
            </c:when>
            <c:otherwise>
                <table class="pistas-table">
                    <thead>
                        <tr>
                            <th>Horario</th>
                            <c:forEach var="pista" items="${pistas}">
                                <th>
                                    <div class="pista-header">
                                        ${pista.icono} ${pista.nombre}
                                        <div><span class="pista-tipo-badge">${pista.tipoLabel}</span></div>
                                    </div>
                                </th>
                            </c:forEach>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="tramo" items="${tramos}">
                            <tr>
                                <td><strong>${tramo}</strong></td>
                                <c:forEach var="pista" items="${pistas}">
                                    <c:set var="ocupados" value="${ocupacion[pista.id]}" />
                                    <c:set var="claveUsuario" value="${pista.id}_${tramo}" />
                                    <c:set var="usuarioOcupa" value="${usuariosOcupacion[claveUsuario]}" />
                                    <c:choose>
                                        <c:when test="${ocupados.contains(tramo)}">
                                            <td class="slot-ocupado">
                                                ✖ Ocupado
                                                <%-- mostramos quien lo tiene y enlace a mensaje si estamos logueados --%>
                                                <c:if test="${not empty usuarioOcupa}">
                                                    <c:choose>
                                                        <c:when test="${not empty sessionScope.usuario}">
                                                            <a class="link-usuario"
                                                               href="${pageContext.request.contextPath}/mensaje/nuevo?para=${usuarioOcupa}"
                                                               title="Enviar mensaje a ${usuarioOcupa}">
                                                                @${usuarioOcupa}
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="display:block; font-size:0.78rem; margin-top:3px;">
                                                                @${usuarioOcupa}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                            </td>
                                        </c:when>
                                        <c:otherwise>
                                            <td class="slot-libre">
                                                <c:choose>
                                                    <c:when test="${not empty sessionScope.usuario}">
                                                        <form method="post" action="${pageContext.request.contextPath}/reserva" style="margin:0;">
                                                            <input type="hidden" name="action" value="crear">
                                                            <input type="hidden" name="pistaId" value="${pista.id}">
                                                            <input type="hidden" name="fecha" value="${fecha}">
                                                            <input type="hidden" name="hora" value="${tramo}">
                                                            <button type="submit" class="btn-reservar">✔ Reservar</button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>✔ Libre</c:otherwise>
                                                </c:choose>
                                            </td>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<footer style="text-align:center; padding:20px; color:var(--gris-medio); font-size:0.8rem; margin-top:40px;">
    © 2025 Polideportivo Municipal de Martos
</footer>

<script>
    const hoy = new Date().toISOString().split('T')[0];
    const max7 = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const inputFecha = document.getElementById('fecha');
    inputFecha.min = hoy;
    inputFecha.max = max7;
    if (!inputFecha.value) inputFecha.value = hoy;
</script>
</body>
</html>
