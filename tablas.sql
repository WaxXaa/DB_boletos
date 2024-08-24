
DROP IF EXISTS DATABASE boletos;
CREATE DATABASE boletos;
use boletos;














CREATE TABLE IF NOT EXISTS organizadores (
  id_organizador INT AUTO_INCREMENT,
  nombre VARCHAR(200) NOT NULL,
  descripcion VARCHAR(400) NOT NUll,
  twitter VARCHAR(400),
  instagram VARCHAR(400),
  website VARCHAR(400),
  ruc VARCHAR(100),
  telefono VARCHAR(20) NOT NULL,
  imagen_perfil VARCHAR NOT NULL,
  verify BOOLEAN NOT NULL DEFAULT FALSE,
  create_at DATETIME NOT NULL,
  update_at DATETIME,

)








CREATE TABLE IF NOT EXISTS Usuarios (
  id_usuario INT AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  contra VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  create_at DATETIME NOT NULL,
  update_at DATETIME,
  CONSTRAINT Usuarios_id_usuario_PK PRIMARY KEY(id_usuario)
);

CREATE TABLE IF NOT EXISTS Eventos (
  id_evento INT AUTO_INCREMENT,
  titulo VARCHAR(400) NOT NULL UNIQUE,
  descripcion VARCHAR(2000) NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NOT NULL,
  ubicacion VARCHAR(600) NOT NULL,
  imagen_portada VARCHAR(1000) NOT NULL,
  mensaje_especial VARCHAR(300) NOT NULL,
  organizador INT NOT NULL,
  precio MONEY NOT NULL,
  aforo INT NOT NULL,
  estado_activo boolean NOT NULL DEFAULT TRUE,
  asistentes INT NOT NULL DEFAULT 0,
  create_at DATETIME NOT NULL,
  update_at DATETIME,
  CONSTRAINT Eventos_organizador_FK FOREIGN KEY(organizador) REFERENCES Organizadores(id_organizador),
  CONSTRAINT Eventos_usuario_FK FOREIGN KEY(Usuarios) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
  CONSTRAINT Eventos_id_evento_PK PRIMARY KEY(id_evento)
);

CREATE TABLE IF NOT EXISTS Metodo_Pago(
  id_metodo_pago INT AUTO_INCREMENT,
  nombre VARCHAR(200) NOT NULL UNIQUE,
  CONSTRAINT Metodo_Compras_id_metodo_compra_PK PRIMARY KEY(id_metodo_pago)
);

CREATE TABLE IF NOT EXISTS Boletos (
  id_pago INT AUTO_INCREMENT,
  evento INT NOT NULL,
  usuario INT NOT NULL,
  fecha DATETIME NOT NULL,
  metodo_pago INT,
  transaction_id UID NOT NULL,
  check_in BOOLEAN NOT NULL DEFAULT FALSE,
  precio MONEY--seguir
  CONSTRAINT Pagos_metodo_pago_FK FOREIGN KEY(metodo_pago) REFERENCES Metodo_Pago(id_metodo_pago),
  CONSTRAINT Pagos_evento_FK FOREIGN KEY(evento) REFERENCES Eventos(id_evento),
  CONSTRAINT Pagos_usuario_FK FOREIGN KEY(usuario) REFERENCES Usuarios(id_usuario),
  CONSTRAINT Pagos_id_pago_PK PRIMARY KEY(id_pago)
);


CREATE PROCEDURE crear_evento(
  IN p_titulo VARCHAR(400),
  IN p_descripcion VARCHAR(2000),
  IN p_fecha_inicio DATETIME,
  IN p_fecha_fin DATETIME,
  IN p_ubicacion VARCHAR(600),
  IN p_imagen VARCHAR(1000),
  IN p_mensaje_especial VARCHAR(300),
  IN p_organizador VARCHAR(200),
  IN p_descripcion_org VARCHAR(400),
  IN p_twitter VARCHAR(400),
  IN p_instagram VARCHAR(400),
  IN p_usuario INT,
  IN p_precio MONEY,
  IN p_aforo INT
)
BEGIN
INSERT INTO Eventos (titulo, descripcion, fecha_inicio, fecha_fin, ubicacion, imagen_portada
, mensaje_especial, organizador, descripcion_org, twitter, instagram, usuario, precio,
aforo, create_at) VALUES
(p_titulo, p_descripcion, p_fecha_inicio, p_fecha_fin, p_ubicacion
, p_imagen, p_mensaje_especial, p_organizador, p_descripcion_org
, p_twitter, p_instagram, p_usuario, p_precio, p_aforo,CURRENT_TIMESTAMP)
END;

CREATE PROCEDURE crear_Boletos(
  IN p_evento INT,
  IN p_usuario INT,
  IN p_metodo_pago INT
)
BEGIN
INSERT INTO Boletos (evento, usuario, metodo_pago, fecha) VALUES
(p_evento, p_usuario, p_metodo_pago, CURRENT_TIMESTAMP);
END;


CREATE TRIGGER
AFTER CREATE
ON Boletos
FOR EACH ROW
BEGIN
UPDATE Eventos SET asistentes = asistentes + 1 WHERE id_evento = NEW.evento;
END;


CREATE VIEW v_eventos_home AS
SELECT
    e.id_evento,
    e.titulo,
    e.fecha_inicio,
    e.imagen,
    e.precio,
    o.nombre AS organizador_nombre,
    o.imagen AS organizador_imagen
FROM
    Eventos e
JOIN
    Organizadores o ON e.organizador = o.id_organizador;
