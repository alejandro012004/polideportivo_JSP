<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="pagina-login">

<div class="login-wrapper">

    <!-- Logo / Cabecera -->
    <div class="login-header">
        <div class="login-icono">⚽</div>
        <h1>Polideportivo Martos</h1>
        <p>Reserva de instalaciones deportivas</p>
    </div>

    <!-- Tarjeta del formulario -->
    <div class="login-card">
        <h2>Iniciar sesión</h2>

        <!-- Mensaje de error -->
        <c:if test="${not empty error}">
            <div class="alerta alerta-error">${error}</div>
        </c:if>

        <!-- Mensaje si la sesión expiró -->
        <c:if test="${param.error eq 'sesion'}">
            <div class="alerta alerta-info">Tu sesión ha expirado. Vuelve a iniciar sesión.</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">

            <div class="campo">
                <label for="username">Usuario</label>
                <input type="text"
                       id="username"
                       name="username"
                       value="${not empty username ? username : cookie['usuario_recordado'].value}"
                       placeholder="Tu nombre de usuario"
                       autocomplete="username"
                       required>
            </div>

            <div class="campo">
                <label for="password">Contraseña</label>
                <div class="input-password">
                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="Tu contraseña"
                           autocomplete="current-password"
                           required>
                    <button type="button" class="btn-ojo" onclick="togglePassword()" title="Mostrar contraseña">👁</button>
                </div>
            </div>

            <div class="campo-fila">
                <label class="checkbox-label">
                    <input type="checkbox" name="recuerdame"> Recuérdame
                </label>
                <a href="${pageContext.request.contextPath}/jsp/recuperar.jsp" class="enlace-secundario">
                    ¿Olvidaste tu contraseña?
                </a>
            </div>

            <button type="submit" class="btn btn-primario btn-bloque">Entrar</button>

        </form>

        <div class="login-footer">
            ¿No tienes cuenta?
            <a href="${pageContext.request.contextPath}/registro">Regístrate aquí</a>
        </div>

        <div class="login-footer">
            <a href="${pageContext.request.contextPath}/disponibilidad">
                Ver disponibilidad sin registrarse →
            </a>
        </div>
    </div>

</div>

<script>
    function togglePassword() {
        const input = document.getElementById('password');
        input.type = input.type === 'password' ? 'text' : 'password';
    }
</script>

</body>
</html>
