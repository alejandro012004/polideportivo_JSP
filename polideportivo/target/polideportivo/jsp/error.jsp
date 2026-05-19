<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error — Polideportivo Martos</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .error-page {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 60vh;
            text-align: center;
            padding: 40px 20px;
        }
        .error-icono { font-size: 4rem; margin-bottom: 16px; }
        .error-titulo { font-size: 1.6rem; color: var(--rojo); margin-bottom: 8px; }
        .error-msg { color: var(--gris-medio); margin-bottom: 24px; }
    </style>
</head>
<body>
<div class="contenedor">
    <div class="error-page">
        <div class="error-icono">⚠️</div>
        <h1 class="error-titulo">Ha ocurrido un error</h1>
        <p class="error-msg">
            <%= exception != null ? exception.getMessage() : "Error inesperado en el servidor." %>
        </p>
        <a href="${pageContext.request.contextPath}/disponibilidad"
           class="btn btn-primario">← Volver al inicio</a>
    </div>
</div>
</body>
</html>
