
DROP IF EXISTS DATABASE boletos;
CREATE DATABASE boletos;
use boletos;













CREATE TABLE IF NOT EXISTS Organizadores (
  id_organizador INT AUTO_INCREMENT,
  nombre VARCHAR(200) NOT NULL UNIQUE,
  contra VARCHAR(500) NOT NULL,
  email  VARCHAR(200) NOT NULL UNIQUE,
  descripcion VARCHAR(400) NOT NULL,
  twitter VARCHAR(400),
  instagram VARCHAR(400) NOT NULL,
  website VARCHAR(400),
  ruc VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  imagen_perfil VARCHAR(1000) NOT NULL,
  verify BOOLEAN NOT NULL DEFAULT FALSE,
  create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_at DATETIME,
  CONSTRAINT Organizadores_id_organizador_PK PRIMARY KEY(id_organizador)
);


DROP IF EXISTS PROCEDURE registrar_organizador;
DELIMITER //

CREATE PROCEDURE registrar_organizador(
    IN p_nombre VARCHAR(200),
    IN p_contra VARCHAR(500),
    IN p_email VARCHAR(200),
    IN p_descripcion VARCHAR(400),
    IN p_twitter VARCHAR(400),
    IN p_instagram VARCHAR(400),
    IN p_website VARCHAR(400),
    IN p_ruc VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_imagen_perfil VARCHAR(1000),
    IN p_verify BOOLEAN
)
BEGIN
    INSERT INTO Organizadores (
        nombre,
        contra,
        email,
        descripcion,
        twitter,
        instagram,
        website,
        ruc,
        telefono,
        imagen_perfil,
        verify
    )
    VALUES (
        p_nombre,
        p_contra,
        p_email,
        p_descripcion,
        IFNULL(p_twitter, NULL),
        p_instagram,
        IFNULL(p_website, NULL),
        p_ruc,
        p_telefono,
        p_imagen_perfil,
        p_verify
    );
END //

DELIMITER ;

-- datos para pagarle a los organizadores
CREATE TABLE IF NOT EXISTS Payments_Data(
  id_payment_data INT AUTO_INCREMENT,
  numero_cuenta VARCHAR(200) NOT NULL,
  banco VARCHAR(200) NOT NULL,
  destinatario  VARCHAR(200) NOT NULL,
  organizador INT NOT NULL,
  CONSTRAINT  PaymentsData_organizador_FK FOREIGN KEY(organizador) REFERENCES Organizadores(id_organizador),
  CONSTRAINT  PaymentsData_id_payment_data_PK PRIMARY KEY(id_payment_data)
);

DROP IF EXISTS PROCEDURE registrar_pago_organizador;

DELIMITER //
CREATE PROCEDURE registrar_pago_organizador(
  p_numero_cuenta VARCHAR(200),
  p_banco VARCHAR(200),
  p_destinatario VARCHAR(200),
  p_organizador INT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    ROLLBACK
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se produjo un error, la transacción fue revertida';
    END;
    START TRANSACTION;
    INSERT INTO Payments_Data (numero_cuenta, banco, destinatario, organizador)
    VALUES (p_numero_cuenta, p_banco, p_destinatario, p_organizador);
    COMMIT;
END//
DELIMITER;

CREATE TABLE IF NOT EXISTS Usuarios (
  id_usuario INT AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  contra VARCHAR(500) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  create_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_at DATETIME,
  CONSTRAINT Usuarios_id_usuario_PK PRIMARY KEY(id_usuario)
);

DROP IF EXISTS PROCEDURE registrar_usuario;

DELIMITER //

CREATE PROCEDURE registrar_usuario(
  IN p_nombre VARCHAR(50),
  IN p_apellido VARCHAR(50),
  IN p_email VARCHAR(100),
  IN p_contra VARCHAR(500),
  IN p_telefono VARCHAR(20)
)
BEGIN
INSERT INTO Usuarios (nombre, apellido, email, contra, telefono)
VALUES (p_nombre,p_apellido, p_email, p_contra, p_telefono);

END//
DELIMITER;


-- tabla de ubicacion con longitud y latitud
CREATE TABLE IF NOT EXISTS Ubicacion_Eventos(
  id_ubicacion INT AUTO_INCREMENT,
  latitud  DECIMAL(10,8) NOT NULL,
  longitud DECIMAL(11,8) NOT NULL,
  descripcion VARCHAR(400) NOT NULL,
  CONSTRAINT  Ubicacion_Eventos_id_ubicacion_PK PRIMARY KEY(id_ubicacion)
);



CREATE TABLE IF NOT EXISTS Eventos (
  id_evento INT AUTO_INCREMENT,
  titulo VARCHAR(400) NOT NULL UNIQUE,
  descripcion VARCHAR(2000) NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NOT NULL,
  ubicacion INT NOT NULL,
  imagen_portada VARCHAR(1000) NOT NULL,
  mensaje VARCHAR(300),
  organizador INT NOT NULL,
  create_at DATETIME NOT NULL,
  update_at DATETIME,
  CONSTRAINT Eventos_ubicacion_FK FOREIGN KEY(ubicacion) REFERENCES  Ubicacion_Eventos(id_ubicacion),
  CONSTRAINT Eventos_organizador_FK FOREIGN KEY(organizador) REFERENCES Organizadores(id_organizador),
  CONSTRAINT Eventos_id_evento_PK PRIMARY KEY(id_evento)
);


-- son los diferentes tipos de boletos que va a vender el organizador para un evento
CREATE TABLE IF NOT EXISTS Boletos(
  id_boleto INT AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  aforo INT NOT NULL,
  disponibles INT  NOT NULL,
  precio DECIMAL(7,2) NOT NULL,
  evento INT NOT NULL,
  CONSTRAINT Tipo_Boletos_Evento_FK FOREIGN KEY(evento) REFERENCES Eventos(id_evento),
  CONSTRAINT  Tipo_Boletos_id_tipo_PK PRIMARY KEY(id_boleto)
);

DROP PROCEDURE IF EXISTS insertar_evento_y_tipo_boleto;

DELIMITER //

CREATE PROCEDURE insertar_evento_y_boleto(
    IN p_titulo VARCHAR(400),
    IN p_descripcion_evento VARCHAR(2000),
    IN p_fecha_inicio DATETIME,
    IN p_fecha_fin DATETIME,
    IN p_latitud DECIMAL(10,8),
    IN p_longitud DECIMAL(10,8),
    IN p_descripcion_ubicacion VARCHAR(400),
    IN p_imagen_portada VARCHAR(1000),
    IN p_mensaje VARCHAR(300),
    IN p_organizador INT,
    IN p_json_tipo_boletos JSON
)
BEGIN
    DECLARE v_id_evento INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_length INT;
    DECLARE v_id_ubicacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            -- Si ocurre un error, deshacer los cambios
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se produjo un error, la transacción fue revertida';
        END;

    START TRANSACTION;

    INSERT INTO Ubicacion_Eventos (latitud,longitud, descripcion)VALUES (p_latitud, p_longitud, p_descripcion_ubicacion);
    SET v_id_ubicacion = LAST_INSERT_ID();

    INSERT INTO Eventos (
        titulo,
        descripcion,
        fecha_inicio,
        fecha_fin,
        ubicacion,
        imagen_portada,
        mensaje,
        organizador,
        create_at
    ) VALUES (
        p_titulo,
        p_descripcion_evento,
        p_fecha_inicio,
        p_fecha_fin,
        v_id_ubicacion,
        p_imagen_portada,
        p_mensaje,
        p_organizador,
        CURRENT_TIMESTAMP
    );

    SET v_id_evento = LAST_INSERT_ID();
    SET  v_length = JSON_LENGTH(p_json_tipo_boletos);

    WHILE v_i < v_length DO

      SET @nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json_tipo_boletos, CONCAT('$[',v_i,'].nombre')));
      SET @descripcion = JSON_UNQUOTE(JSON_EXTRACT(p_json_tipo_boletos, CONCAT('$[',v_i,'].descripcion')));
      SET @precio = JSON_UNQUOTE(JSON_EXTRACT(p_json_tipo_boletos, CONCAT('$[',v_i,'].precio')));
      SET @aforo = JSON_UNQUOTE(JSON_EXTRACT(p_json_tipo_boletos,CONCAT('$[',v_i,'].aforo')));

      INSERT INTO Boletos (
        nombre,
        descripcion,
        aforo,
        disponibles,
        precio,
        evento
      ) VALUES (
        @nombre,
        @descripcion,
        @aforo,
        @aforo,
        @precio,
        v_id_evento
      );

      SET v_i = v_i + 1;
    END WHILE;


    COMMIT;
END //

DELIMITER ;


INSERT INTO Organizadores (nombre, descripcion, ruc, telefono, imagen_perfil)
VALUES ('eventos magicos', 'una empresa de eventos', '6486dawd46548', '64554495', 'url de imagen');
CALL insertar_evento_y_tipo_boleto(
    'la velada del año',
    'es una pelea de animales',
    '2024-10-28 18:00:00',
    '2024-10-29 05:00:00',
    40.785091,
    -73.968285,
    'un parque en medio de la nada',
    'aqui va la url de la foto',
    'aqui va un mensaje del organizador para el evento',
    1,
    '[{"nombre": "premium", "descripcion": "cerca del artista", "precio": 70.00, "aforo": 50},{"nombre": "pobre", "descripcion": "lejos del artista", "precio": 50.00, "aforo": 10}]'
);

CREATE TABLE IF NOT EXISTS Boletos_Ventas (
  id_boleto_venta INT AUTO_INCREMENT,
  usuario INT NOT NULL,
  fecha_compra DATETIME NOT NULL,
  boleto INT NOT NULL,
  evento INT NOT NULL,
  num_boleto CHAR(36) NOT NULL UNIQUE,
  CONSTRAINT Boletos_evento_FK FOREIGN KEY(evento) REFERENCES Eventos(id_evento),
  CONSTRAINT Boletos_tipo_FK FOREIGN KEY(boleto) REFERENCES Boletos(id_boleto),
  CONSTRAINT Pagos_usuario_FK FOREIGN KEY(usuario) REFERENCES Usuarios(id_usuario),
  CONSTRAINT Pagos_id_pago_PK PRIMARY KEY(id_boleto_venta)
);



DROP IF EXISTS PROCEDURE insertar_boleto_venta;
--cuando un usuario compra un boleto
DELIMITER //

CREATE PROCEDURE insertar_boleto_venta(
    IN p_usuario INT,
    IN p_evento INT,
    IN p_json_boleto_cantidad
)
BEGIN
  DECLARE v_i INT DEFAULT 0;
  DECLARE v_j INT DEFAULT 0;
  DECLARE v_aforo INT;
  DECLARE v_disponibles INT;
  DECLARE v_json_length INT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al insertar el boleto de venta';
    END;

    START TRANSACTION;
    v_json_length = JSON_LENGTH(p_json_boleto_cantidad);
  SET v_i = 0;
  WHILE v_i < v_json_length DO
    SET @boleto = JSON_UNQUOTE(JSON_EXTRACT(p_json_boleto_cantidad,CONCAT('$[',v_i,'].boleto')));
    SET @cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_json_boleto_cantidad,CONCAT('$[',v_i,'].cantidad')))

        SELECT aforo, disponibles INTO v_aforo, v_disponibles FROM Boletos WHERE id_boleto = @boleto;

        IF v_disponibles = 0 OR v_aforo - @cantidad <= 0 OR v_disponibles - @cantidad <= 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El aforo para el boleto es 0. No se pueden vender boletos';
        END IF;

    SET v_j = 0;
    WHILE v_j < @cantidad DO
      INSERT INTO Boletos_Ventas (
          usuario,
          fecha_compra,
          boleto,
          evento,
          num_boleto
      ) VALUES (
          p_usuario,
          CURRENT_TIMESTAMP,
          @boleto,
          p_evento,
          UUID()
      );
      SET v_j = v_j + 1;
    END WHILE;

    SET v_i = v_i + 1;
  END WHILE;
    COMMIT;
    SELECT num_boleto from Boletos_Ventas WHERE usuario = p_usuario;
END //

DELIMITER ;

DROP IF EXISTS PROCEDURE consulta_boletos_ventas_usuario;
DELIMITER //

CREATE OR REPLACE PROCEDURE consulta_boletos_ventas_usuario(
  IN p_id_usuario INT
) 
BEGIN
SELECT e.titulo as titulo,
b.nombre as numbreBoleto,
u.nomobre + ' ' + u.apellido as nombreUsuario,
e.fecha_inicio as fechaInicio,
bv.num_boleto as numeroBoleto,
bv.fecha_compra as fechaCompra,
b.precio as precioBoleto
FROM Boletos_Ventas as bv
JOIN Boletos b on bv.boleto = b.id_boleto
JOIN Eventos e on b.evento = e.id_evento
JOIN  Usuarios u on bv.usuario = u.id_usuario
WHERE bv.usuario = p_usuario;
END//
DELIMITER;


DROP IF EXISTS PROCEDURE consulta_boletos_ventas_organizador;
DELIMITER //

CREATE OR REPLACE PROCEDURE consulta_boletos_ventas_usuario_organizador(
  IN p_num_boleto INT
)
BEGIN
SELECT bv.num_boleto as numeroBoleto,
bv.fecha_compra as fechaCompra,
u.nomobre + ' ' + u.apellido as nombreUsuario,
e.titulo as evento,
e.fecha_inicio as fechaInicio
FROM Boletos_Ventas as bv
JOIN Usuarios as u on bv.usuario = u.id_usuario
JOIN Eventos as e on e.id_evento = bv.evento WHERE bv.num_boleto = p_num_boleto;
END//
DELIMITER;


CREATE TABLE IF NOT EXISTS Checkout(
  usuario INT NOT NULL,
  boleto INT NOT NULL,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Checkout_usuario_FK FOREIGN KEY(usuario) REFERENCES Usuarios(id_usuario),
  CONSTRAINT Checkout_evento_FK FOREIGN KEY(boleto) REFERENCES Boletos_Ventas(id_boleto_venta),
  CONSTRAINT Checkout_PK PRIMARY KEY(usuario, boleto)
);

DROP IF EXISTS PROCEDURE  checkout;

DELIMITER //
CREATE PROCEDURE checkout(
  IN p_boleto_uuid INT
)
BEGIN
  DECLARE v_id_boleto INT;
  DECLARE v_id_usuario INT;

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR AL REALIZAR CHECKOUT';

    END;

    START TRANSACTION
    SELECT id_boleto_venta, usuario
    INTO v_id_boleto, v_id_usuario
    FROM Boletos_Ventas
    WHERE transaction_id = p_boleto_uuid;

    INSERT INTO Checkout (usuario, boleto)
    VALUES (v_id_usuario, v_id_boleto);
    COMMIT;

END //
DELIMITER;




CREATE VIEW Vista_Eventos_Proximos AS
SELECT
    e.id_evento as idEvento,
    e.imagen_portada as portada,
    e.fecha_inicio as fecha,
    e.titulo as titulo,
    MIN(b.precio) as precio_minimo
FROM
    Eventos e
JOIN
    Boletos b ON e.id_evento = b.evento
WHERE
    e.fecha_inicio > NOW()
GROUP BY
    e.id_evento, e.imagen_portada, e.titulo;


DROP IF EXISTS PROCEDURE ver_evento;
DELIMITER//
CREATE PROCEDURE ver_evento(
  IN p_id_evento INT
)
BEGIN
SELECT e.titulo as titulo,
e.descripcion as descripcionEvento,
e.fecha_inicio as fechaInicio,
e.fecha_fin as fechaFin,
ue.latitud as latitud,
ue.longitud as longitud,
ue.descripcion as descripcionUbicacion,
e.imagen_portada as imagenPortada,
e.mensaje as mensaje,
o.nombre as nombreOrganizador,
o.descripcion as descripcionOrganizador,
o.email as emailOrganizador,
o.verify as verify
FROM Eventos as e
JOIN Ubicacion_Eventos as ue on e.ubicacion = ue.id_ubicacion
JOIN Organizadores as o on e.organizador = o.id_organizador
WHERE id_evento = p_id_evento;

SELECT b.nombre as nombreBoleto,
b.descripcion as descripcionBoleto,
b.disponibles as boletosDisponibles,
b.precio as precioBoleto FROM Boletos as b
JOIN Eventos as e on b.evento = e.id_evento
WHERE evento = p_id_evento;


END//
DELIMITER;


DROP IF EXISTS PROCEDURE ver_ventas_evento;
DELIMITER //
CREATE PROCEDURE ver_ventas_evento(
  IN p_id_evento INT
)
BEGIN
SELECT bv.num_boleto, bv.fecha_compra, b.precio, b.nombre
FROM Boletos_Ventas as bv
JOIN Boletos as b on bv.boleto = b.id_boleto
WHERE evento = p_id_evento;

END //
DELIMITER;

CREATE TABLE IF NOT EXISTS AuditoriaBD(
  id_auditoria INT AUTO_INCREMENT NOT NULL,
  tabla_modificada VARCHAR(100) NOT NULL,
  accion VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
  registro_id INT NOT NULL,
  usuario_modificador INT NOT NULL, -- ID del usuario que hizo la modificación
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT AUDITORIABD_ID_AUDITORIA_PK PRIMARY KEY (id_auditoria);
);

-------------------------------------------------------------------


CREATE TRIGGER t_after_insert_eventos
AFTER INSERT ON Eventos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Eventos', 'INSERT', NEW.id_evento, CURRENT_USER());
END;


CREATE TRIGGER t_after_update_eventos
AFTER UPDATE ON Eventos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Eventos', 'UPDATE', NEW.id_evento, CURRENT_USER());
END;


CREATE TRIGGER t_after_delete_eventos
AFTER DELETE ON Eventos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Eventos', 'DELETE', NEW.id_evento, CURRENT_USER());
END;

----------------------------------------------------------------------------

CREATE TRIGGER t_after_insert_organizadores
AFTER INSERT ON Organizadores
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Organizadores', 'INSERT', NEW.id_organizador, CURRENT_USER());
END;


CREATE TRIGGER t_after_update_organizadores
AFTER UPDATE ON Organizadores
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Organizadores', 'UPDATE', NEW.id_evento, CURRENT_USER());
END;


CREATE TRIGGER t_after_delete_organizadores
AFTER DELETE ON Organizadores
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Organizadores', 'DELETE', NEW.id_evento, CURRENT_USER());
END;

----------------------------------------------------------------------------

CREATE TRIGGER t_after_insert_boletos
AFTER INSERT ON Boletos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Boletos', 'INSERT', NEW.id_organizador, CURRENT_USER());
END;


CREATE TRIGGER t_after_update_boletos
AFTER UPDATE ON Boletos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Boletos', 'UPDATE', NEW.id_evento, CURRENT_USER());
END;


CREATE TRIGGER t_after_delete_boletos
AFTER DELETE ON Boletos
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Boletos', 'DELETE', NEW.id_evento, CURRENT_USER());
END;

----------------------------------------------------------------------------

CREATE TRIGGER t_after_insert_payment_data
AFTER INSERT ON Payments_Data
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Payments_Data', 'INSERT', NEW.id_organizador, CURRENT_USER());
END;

CREATE TRIGGER t_after_update_payment_data
AFTER UPDATE ON Payments_Data
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Payments_Data', 'UPDATE', NEW.id_evento, CURRENT_USER());
END;

CREATE TRIGGER t_after_delete_payment_data
AFTER DELETE ON Payments_Data
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria_BaseDatos(tabla_modificada, accion, registro_id, usuario_modificador)
  VALUES ('Payments_Data', 'DELETE', NEW.id_evento, CURRENT_USER());
END;

----------------------------------------------------------------------------

