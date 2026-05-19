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
    <title>Mi Perfil — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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

    <%-- Alertas --%>
    <c:if test="${param.ok == 'datos_actualizados'}">
        <div class="alerta alerta-exito">✅ Datos actualizados correctamente.</div>
    </c:if>
    <c:if test="${param.ok == 'contrasena_cambiada'}">
        <div class="alerta alerta-exito">✅ Contraseña cambiada correctamente.</div>
    </c:if>
    <c:if test="${param.error == 'campos_vacios'}">
        <div class="alerta alerta-error">⚠️ Por favor rellena todos los campos obligatorios.</div>
    </c:if>
    <c:if test="${param.error == 'contrasena_incorrecta'}">
        <div class="alerta alerta-error">⚠️ La contraseña actual no es correcta.</div>
    </c:if>
    <c:if test="${param.error == 'contrasenas_no_coinciden'}">
        <div class="alerta alerta-error">⚠️ Las nuevas contraseñas no coinciden.</div>
    </c:if>
    <c:if test="${param.error == 'contrasena_corta'}">
        <div class="alerta alerta-error">⚠️ La contraseña debe tener al menos 6 caracteres.</div>
    </c:if>

    <%-- Datos personales --%>
    <div class="card">
        <h2>✏️ Mis datos personales</h2>
        <form method="post" action="${pageContext.request.contextPath}/usuario/datos">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                <div class="campo">
                    <label for="nombre">Nombre *</label>
                    <input type="text" id="nombre" name="nombre"
                           value="${sessionScope.usuario.nombre}" required>
                </div>
                <div class="campo">
                    <label for="apellidos">Apellidos *</label>
                    <input type="text" id="apellidos" name="apellidos"
                           value="${sessionScope.usuario.apellidos}" required>
                </div>
            </div>
            <div class="campo">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email"
                       value="${sessionScope.usuario.email}" required>
            </div>
            <div class="campo">
                <label for="telefono">Teléfono</label>
                <input type="tel" id="telefono" name="telefono"
                       value="${sessionScope.usuario.telefono}" placeholder="Opcional">
            </div>
            <button type="submit" class="btn btn-primario">💾 Guardar cambios</button>
        </form>
    </div>

    <%-- Cambiar contraseña --%>
    <div class="card">
        <h2>🔒 Cambiar contraseña</h2>
        <form method="post" action="${pageContext.request.contextPath}/usuario/contrasena">
            <div class="campo">
                <label for="passwordActual">Contraseña actual *</label>
                <div class="input-password">
                    <input type="password" id="passwordActual" name="passwordActual"
                           placeholder="Tu contraseña actual" required>
                    <button type="button" class="btn-ojo" onclick="toggle('passwordActual')">👁</button>
                </div>
            </div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                <div class="campo">
                    <label for="passwordNueva">Nueva contraseña *</label>
                    <div class="input-password">
                        <input type="password" id="passwordNueva" name="passwordNueva"
                               placeholder="Mínimo 6 caracteres" minlength="6" required>
                        <button type="button" class="btn-ojo" onclick="toggle('passwordNueva')">👁</button>
                    </div>
                </div>
                <div class="campo">
                    <label for="passwordNueva2">Repetir nueva contraseña *</label>
                    <div class="input-password">
                        <input type="password" id="passwordNueva2" name="passwordNueva2"
                               placeholder="Repite la nueva contraseña" minlength="6" required>
                        <button type="button" class="btn-ojo" onclick="toggle('passwordNueva2')">👁</button>
                    </div>
                </div>
            </div>
            <button type="submit" class="btn btn-primario">🔑 Cambiar contraseña</button>
        </form>
    </div>

</div>

<footer style="text-align:center; padding:20px; color:var(--gris-medio); font-size:0.8rem; margin-top:20px;">
    © 2025 Polideportivo Municipal de Martos
</footer>

<script>
    function toggle(id) {
        const el = document.getElementById(id);
        el.type = el.type === 'password' ? 'text' : 'password';
    }
</script>
</body>
</html>
