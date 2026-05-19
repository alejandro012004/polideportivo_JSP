<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="pagina-login">

<div class="login-wrapper" style="max-width: 520px;">

    <!-- Cabecera -->
    <div class="login-header">
        <div class="login-icono">🏟️</div>
        <h1>Polideportivo Martos</h1>
        <p>Crea tu cuenta para reservar pistas</p>
    </div>

    <!-- Tarjeta -->
    <div class="login-card">
        <h2>Crear cuenta</h2>

        <c:if test="${not empty error}">
            <div class="alerta alerta-error">${error}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/registro" novalidate>

            <!-- Nombre y apellidos en fila -->
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                <div class="campo">
                    <label for="nombre">Nombre *</label>
                    <input type="text" id="nombre" name="nombre"
                           value="${nombre}"
                           placeholder="Tu nombre"
                           required>
                </div>
                <div class="campo">
                    <label for="apellidos">Apellidos *</label>
                    <input type="text" id="apellidos" name="apellidos"
                           value="${apellidos}"
                           placeholder="Tus apellidos"
                           required>
                </div>
            </div>

            <div class="campo">
                <label for="username">Usuario *</label>
                <input type="text" id="username" name="username"
                       value="${username}"
                       placeholder="Solo letras, números y _"
                       autocomplete="username"
                       minlength="3" maxlength="50"
                       required>
                <small style="color:var(--gris-medio); font-size:0.8rem;">
                    Mínimo 3 caracteres. Solo letras, números y guión bajo.
                </small>
            </div>

            <div class="campo">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email"
                       value="${email}"
                       placeholder="tu@email.com"
                       autocomplete="email"
                       required>
            </div>

            <div class="campo">
                <label for="telefono">Teléfono</label>
                <input type="tel" id="telefono" name="telefono"
                       value="${telefono}"
                       placeholder="600 000 000 (opcional)">
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                <div class="campo">
                    <label for="password">Contraseña *</label>
                    <div class="input-password">
                        <input type="password" id="password" name="password"
                               placeholder="Mínimo 6 caracteres"
                               autocomplete="new-password"
                               minlength="6"
                               required>
                        <button type="button" class="btn-ojo" onclick="togglePass('password')" title="Mostrar">👁</button>
                    </div>
                </div>
                <div class="campo">
                    <label for="password2">Repetir contraseña *</label>
                    <div class="input-password">
                        <input type="password" id="password2" name="password2"
                               placeholder="Repite la contraseña"
                               autocomplete="new-password"
                               minlength="6"
                               required>
                        <button type="button" class="btn-ojo" onclick="togglePass('password2')" title="Mostrar">👁</button>
                    </div>
                </div>
            </div>

            <!-- Indicador de fuerza de contraseña -->
            <div style="margin-bottom:16px;">
                <div id="barra-fuerza" style="height:4px; border-radius:2px; background:#eee; transition:all .3s;">
                    <div id="fuerza-relleno" style="height:100%; width:0; border-radius:2px; transition:all .3s;"></div>
                </div>
                <small id="fuerza-texto" style="font-size:0.8rem; color:var(--gris-medio);"></small>
            </div>

            <button type="submit" class="btn btn-primario btn-bloque">Crear cuenta</button>

        </form>

        <div class="login-footer" style="margin-top:20px;">
            ¿Ya tienes cuenta?
            <a href="${pageContext.request.contextPath}/login">Inicia sesión</a>
        </div>

    </div>
</div>

<script>
    function togglePass(id) {
        const input = document.getElementById(id);
        input.type = input.type === 'password' ? 'text' : 'password';
    }

    // Indicador de fuerza de contraseña
    document.getElementById('password').addEventListener('input', function () {
        const val = this.value;
        let fuerza = 0;
        if (val.length >= 6)                    fuerza++;
        if (val.length >= 10)                   fuerza++;
        if (/[A-Z]/.test(val))                  fuerza++;
        if (/[0-9]/.test(val))                  fuerza++;
        if (/[^a-zA-Z0-9]/.test(val))           fuerza++;

        const colores = ['#e53935','#fb8c00','#fdd835','#43a047','#1b5e20'];
        const textos  = ['Muy débil','Débil','Regular','Fuerte','Muy fuerte'];
        const pct     = (fuerza / 5) * 100;

        document.getElementById('fuerza-relleno').style.width      = pct + '%';
        document.getElementById('fuerza-relleno').style.background = colores[fuerza - 1] || '#eee';
        document.getElementById('fuerza-texto').textContent        = val.length ? textos[fuerza - 1] || '' : '';
    });

    // Validación client-side: las dos contraseñas coinciden
    document.querySelector('form').addEventListener('submit', function (e) {
        const p1 = document.getElementById('password').value;
        const p2 = document.getElementById('password2').value;
        if (p1 !== p2) {
            e.preventDefault();
            alert('Las contraseñas no coinciden.');
            document.getElementById('password2').focus();
        }
    });
</script>

</body>
</html>
