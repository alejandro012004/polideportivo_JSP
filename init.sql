-- ============================================================
-- Polideportivo de Martos — Script de inicialización de BD
-- MySQL 8.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS polideportivo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE polideportivo;

-- ------------------------------------------------------------
-- TABLA: usuarios
-- Obligatorio en MySQL según el enunciado.
-- La contraseña se guardará hasheada (SHA-256 o bcrypt).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,          -- hash, nunca texto plano
    nombre      VARCHAR(100) NOT NULL,
    apellidos   VARCHAR(150) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    telefono    VARCHAR(15),
    fecha_alta  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    activo      TINYINT(1)   DEFAULT 1
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: pistas
-- 2 de fútbol sala + 4 de tenis = 6 pistas en total.
-- Precargadas con INSERT al final del script.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pistas (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(50)                       NOT NULL,
    tipo     ENUM('futbol_sala', 'tenis')       NOT NULL,
    activa   TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: reservas
-- Horario: lun-dom, 9-14h y 16-23h, tramos de 1 hora.
-- Máximo 1 semana de antelación.
-- estado: 'activa' | 'cancelada'
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reservas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,
    id_pista        INT          NOT NULL,
    fecha           DATE         NOT NULL,
    hora_inicio     TIME         NOT NULL,   -- ej: 09:00:00
    hora_fin        TIME         NOT NULL,   -- ej: 10:00:00
    fecha_creacion  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    estado          ENUM('activa', 'cancelada') DEFAULT 'activa',

    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (id_pista)   REFERENCES pistas(id)   ON DELETE CASCADE,

    -- No se puede reservar la misma pista en el mismo tramo horario
    UNIQUE KEY uk_pista_fecha_hora (id_pista, fecha, hora_inicio, estado)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: mensajes
-- Mensajes privados entre usuarios registrados.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mensajes (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_remitente    INT          NOT NULL,
    id_destinatario INT          NOT NULL,
    asunto          VARCHAR(150),
    cuerpo          TEXT         NOT NULL,
    fecha_envio     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    leido           TINYINT(1)   DEFAULT 0,

    FOREIGN KEY (id_remitente)    REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (id_destinatario) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Pistas del polideportivo
INSERT INTO pistas (nombre, tipo) VALUES
    ('Fútbol Sala 1', 'futbol_sala'),
    ('Fútbol Sala 2', 'futbol_sala'),
    ('Tenis 1',       'tenis'),
    ('Tenis 2',       'tenis'),
    ('Tenis 3',       'tenis'),
    ('Tenis 4',       'tenis');

-- Usuario de prueba (password: "admin123" — SHA-256)
INSERT INTO usuarios (username, password, nombre, apellidos, email) VALUES
    ('admin',
     '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
     'Administrador',
     'Polideportivo',
     'admin@polideportivo.com'),

    ('alumno',
     '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
     'Alumno',
     'De Prueba',
     'alumno@test.com');

-- ============================================================
-- VISTAS ÚTILES (opcionales, facilitan las consultas en JSP)
-- ============================================================

-- Vista: reservas activas con datos del usuario y la pista
CREATE OR REPLACE VIEW v_reservas_activas AS
    SELECT
        r.id,
        r.fecha,
        r.hora_inicio,
        r.hora_fin,
        p.nombre   AS pista,
        p.tipo     AS tipo_pista,
        u.username,
        u.nombre   AS nombre_usuario,
        u.apellidos
    FROM reservas r
    JOIN pistas   p ON p.id = r.id_pista
    JOIN usuarios u ON u.id = r.id_usuario
    WHERE r.estado = 'activa'
    ORDER BY r.fecha, r.hora_inicio, p.id;

-- Vista: disponibilidad de pistas para los próximos 7 días
-- Devuelve los tramos ya ocupados; los que NO aparecen están libres.
CREATE OR REPLACE VIEW v_ocupacion_semana AS
    SELECT
        r.fecha,
        r.hora_inicio,
        r.hora_fin,
        p.id       AS id_pista,
        p.nombre   AS pista,
        p.tipo,
        u.username AS reservado_por
    FROM reservas r
    JOIN pistas   p ON p.id = r.id_pista
    JOIN usuarios u ON u.id = r.id_usuario
    WHERE r.estado  = 'activa'
      AND r.fecha  BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    ORDER BY r.fecha, r.hora_inicio, p.id;
