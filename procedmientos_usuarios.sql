DELIMETER //
CREATE OR REPLACE PROCEDURE crear_usuario(
  p_nombre VARCHAR(50),
  p_email VARCHAR(100),
  p_contra VARCHAR(100),
  p_telefono VARCHAR(20)
)
BEGIN
INSERT INTO Usuarios(nombre, email, contra, telefono, create_at) VALUES
(p_nombre, p_email, p_contra, p_telefono, CURRENT_TIMESTAMP)
END;


CREATE PROCEDURE act_nombre(
  p_id_usuario INT,
  p_nombre VARCHAR(50)
)
BEGIN
UPDATE Usuarios SET nombre = p_nombre WHERE id_usuario = p_id_usuario;
END;


CREATE PROCEDURE act_email(
  p_id_usuario INT,
  p_email VARCHAR(100)
)
BEGIN
UPDATE Usuarios SET email = p_email WHERE id_usuario = p_id_usuario;
END;

CREATE PROCEDURE act_contra(
  p_id_usuario INT,
  p_contra VARCHAR(100)
)
BEGIN
UPDATE Usuarios SET contra = p_contra WHERE id_usuario = p_id_usuario;
END;

CREATE PROCEDURE act_telefono (
  p_id_usuario INT,
  p_telefono VARCHAR(20)
)
BEGIN
UPDATE Usuarios SET telefono = p_ WHERE id_usuario = p_id_usuario;
END;

CREATE TRIGGER
AFTER UPDATE
FOR EACH ROW Usuarios
BEGIN
  SET update_at = CURRENT_TIMESTAMP;
END;
