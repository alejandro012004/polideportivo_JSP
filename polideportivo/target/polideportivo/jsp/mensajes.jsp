<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title>Mensajes — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .mensajes-layout {
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 20px;
            margin-top: 20px;
        }
        @media (max-width: 768px) {
            .mensajes-layout { grid-template-columns: 1fr; }
        }
        .mensajes-menu {
            background: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            height: fit-content;
        }
        .mensajes-menu ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .mensajes-menu li { margin-bottom: 10px; }
        .mensajes-menu a {
            display: block;
            padding: 10px 15px;
            border-radius: 6px;
            text-decoration: none;
            color: #333;
            font-weight: 500;
        }
        .mensajes-menu a:hover { background: #f0f4f1; }
        .mensajes-menu a.active {
            background: var(--color-primary, #1a6b3a);
            color: white;
        }
        .mensaje-listado {
            width: 100%;
            border-collapse: collapse;
        }
        .mensaje-listado th, .mensaje-listado td {
            padding: 12px;
            border-bottom: 1px solid #eee;
            text-align: left;
        }
        .mensaje-listado tr:hover { background: #f9f9f9; cursor: pointer; }
        .mensaje-no-leido { font-weight: bold; background: #f4f8f5; }
        .mensaje-leer-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        .mensaje-header {
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 15px;
        }
        .mensaje-cuerpo {
            line-height: 1.6;
            color: #444;
            white-space: pre-wrap;
        }
        .btn-nuevo {
            display: block;
            text-align: center;
            background: var(--color-primary, #1a6b3a);
            color: white;
            padding: 10px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .btn-nuevo:hover { background: #145530; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn-enviar {
            background: var(--color-primary, #1a6b3a);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 1rem;
        }
        .alerta { padding: 10px 16px; border-radius: 6px; margin-bottom: 14px; font-size: 0.9rem; }
        .alerta-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alerta-ok    { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>

<nav class="navbar">
    <a class="navbar-marca" href="${pageContext.request.contextPath}/">
        ⚽ Polideportivo Martos
    </a>
    <ul class="navbar-nav">
        <li><a href="${pageContext.request.contextPath}/jsp/disponibilidad.jsp">🗓 <span>Pistas</span></a></li>
        <li><a href="${pageContext.request.contextPath}/jsp/panel.jsp">👤 <span>Mi panel</span></a></li>
        <li><a href="${pageContext.request.contextPath}/mensaje">✉ <span>Mensajes</span></a></li>
        <li><a href="${pageContext.request.contextPath}/login?action=logout">🚪 <span>Salir</span></a></li>
    </ul>
</nav>

<div class="contenedor mensajes-layout">
    <div class="mensajes-menu">
        <a href="${pageContext.request.contextPath}/mensaje/nuevo" class="btn-nuevo">✏️ Nuevo Mensaje</a>
        <ul>
            <li>
                <a href="${pageContext.request.contextPath}/mensaje/recibidos" class="${vista == 'recibidos' ? 'active' : ''}">
                    📥 Bandeja de entrada
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/mensaje/enviados" class="${vista == 'enviados' ? 'active' : ''}">
                    📤 Enviados
                </a>
            </li>
        </ul>
    </div>

    <div class="mensajes-contenido">
        
        <c:if test="${param.error == 'usuario_no_existe'}">
            <div class="alerta alerta-error">⚠️ El usuario destinatario no existe.</div>
        </c:if>
        <c:if test="${param.error == 'campos_vacios'}">
            <div class="alerta alerta-error">⚠️ Debes rellenar destinatario y cuerpo.</div>
        </c:if>
        <c:if test="${param.error == 'mismo_usuario'}">
            <div class="alerta alerta-error">⚠️ No puedes enviarte un mensaje a ti mismo.</div>
        </c:if>
        <c:if test="${param.exito == 'mensaje_enviado'}">
            <div class="alerta alerta-ok">✔ Mensaje enviado correctamente.</div>
        </c:if>

        <c:choose>
            <%-- VISTA: RECIBIDOS O ENVIADOS --%>
            <c:when test="${vista == 'recibidos' || vista == 'enviados'}">
                <div class="card">
                    <h2>${vista == 'recibidos' ? '📥 Bandeja de entrada' : '📤 Mensajes enviados'}</h2>
                    
                    <c:choose>
                        <c:when test="${empty mensajes}">
                            <p style="color:#888; text-align:center; padding:30px 0;">No tienes mensajes en esta carpeta.</p>
                        </c:when>
                        <c:otherwise>
                            <table class="mensaje-listado">
                                <thead>
                                    <tr>
                                        <th>${vista == 'recibidos' ? 'De' : 'Para'}</th>
                                        <th>Asunto</th>
                                        <th>Fecha</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${mensajes}">
                                        <tr class="${vista == 'recibidos' && !m.leido ? 'mensaje-no-leido' : ''}"
                                            onclick="window.location.href='${pageContext.request.contextPath}/mensaje/leer?id=${m.id}'">
                                            <td>@${vista == 'recibidos' ? m.remitenteUsername : m.destinatarioUsername}</td>
                                            <td>${empty m.asunto ? '(Sin asunto)' : m.asunto}</td>
                                            <td><fmt:parseDate value="${m.fechaEnvio}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" /><fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDate}" /></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>

            <%-- VISTA: LEER MENSAJE --%>
            <c:when test="${vista == 'leer'}">
                <div class="mensaje-leer-card">
                    <div class="mensaje-header">
                        <h2 style="margin-top:0;">${empty mensajeLeido.asunto ? '(Sin asunto)' : mensajeLeido.asunto}</h2>
                        <div style="color:#666; font-size:0.9rem;">
                            <strong>De:</strong> @${mensajeLeido.remitenteUsername} <br>
                            <strong>Para:</strong> @${mensajeLeido.destinatarioUsername} <br>
                            <strong>Fecha:</strong> 
                            <fmt:parseDate value="${mensajeLeido.fechaEnvio}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateFull" type="both" />
                            <c:choose>
                                <c:when test="${not empty parsedDateFull}">
                                    <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDateFull}" />
                                </c:when>
                                <c:otherwise>
                                    <fmt:parseDate value="${mensajeLeido.fechaEnvio}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                                    <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDate}" />
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="mensaje-cuerpo">${mensajeLeido.cuerpo}</div>
                    
                    <div style="margin-top: 30px;">
                        <a href="${pageContext.request.contextPath}/mensaje/nuevo?para=${mensajeLeido.remitenteUsername}" class="btn-enviar" style="text-decoration:none;">↩️ Responder</a>
                    </div>
                </div>
            </c:when>

            <%-- VISTA: NUEVO MENSAJE --%>
            <c:when test="${vista == 'nuevo'}">
                <div class="card">
                    <h2>✏️ Nuevo Mensaje</h2>
                    <form action="${pageContext.request.contextPath}/mensaje/enviar" method="post">
                        <div class="form-group">
                            <label for="destinatario">Para (Username):</label>
                            <input type="text" id="destinatario" name="destinatario" 
                                   value="${not empty param.para ? param.para : (not empty para ? para : '')}" required placeholder="ej: admin">
                        </div>
                        <div class="form-group">
                            <label for="asunto">Asunto:</label>
                            <input type="text" id="asunto" name="asunto" placeholder="Opcional">
                        </div>
                        <div class="form-group">
                            <label for="cuerpo">Mensaje:</label>
                            <textarea id="cuerpo" name="cuerpo" rows="8" required></textarea>
                        </div>
                        <button type="submit" class="btn-enviar">✉ Enviar mensaje</button>
                    </form>
                </div>
            </c:when>
        </c:choose>
    </div>
</div>

</body>
</html>
