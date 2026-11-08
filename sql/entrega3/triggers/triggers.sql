-- Triggers - Entrega 3

CREATE OR REPLACE TRIGGER trg_rangos_estadistica
BEFORE INSERT OR UPDATE ON estadistica_jugador_partido
FOR EACH ROW
BEGIN
  IF :NEW.goles < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Los goles no pueden ser negativos');
  END IF;
  IF :NEW.asistencias < 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Las asistencias no pueden ser negativas');
  END IF;
END;
/

-- Trigger 3: Anti-duplicidad (una seleccion no puede repetirse en un partido)
CREATE OR REPLACE TRIGGER trg_antiduplicidad_participacion
BEFORE INSERT ON participacion_partido
FOR EACH ROW
DECLARE
  v_existe NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_existe
  FROM participacion_partido
  WHERE id_partido = :NEW.id_partido
    AND id_seleccion = :NEW.id_seleccion;

  IF v_existe > 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'La seleccion ya participa en este partido');
  END IF;
END;
/

-- Trigger 1: Auditoria (registra cambios en partido y estadisticas)
-- La primera vez el DROP da ORA-00942 porque la tabla aun no existe.
DROP TABLE auditoria_evento PURGE;

CREATE TABLE auditoria_evento (
  id_auditoria    NUMBER GENERATED ALWAYS AS IDENTITY,
  tabla           VARCHAR2(40)  NOT NULL,
  operacion       VARCHAR2(10)  NOT NULL,
  id_registro     NUMBER(10),
  valor_anterior  VARCHAR2(100),
  valor_nuevo     VARCHAR2(100),
  usuario         VARCHAR2(30)  NOT NULL,
  fecha           DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria)
);

CREATE OR REPLACE TRIGGER trg_auditoria_partido
AFTER INSERT OR UPDATE OR DELETE ON partido
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('PARTIDO', 'INSERT', :NEW.id_partido, NULL, :NEW.asistencia_registrada, USER);
  ELSIF UPDATING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('PARTIDO', 'UPDATE', :NEW.id_partido, :OLD.asistencia_registrada, :NEW.asistencia_registrada, USER);
  ELSIF DELETING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('PARTIDO', 'DELETE', :OLD.id_partido, :OLD.asistencia_registrada, NULL, USER);
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_auditoria_estadistica
AFTER INSERT OR UPDATE OR DELETE ON estadistica_jugador_partido
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('ESTADISTICA_JUGADOR_PARTIDO', 'INSERT', :NEW.id_estadistica, NULL, :NEW.goles, USER);
  ELSIF UPDATING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('ESTADISTICA_JUGADOR_PARTIDO', 'UPDATE', :NEW.id_estadistica, :OLD.goles, :NEW.goles, USER);
  ELSIF DELETING THEN
    INSERT INTO auditoria_evento (tabla, operacion, id_registro, valor_anterior, valor_nuevo, usuario)
    VALUES ('ESTADISTICA_JUGADOR_PARTIDO', 'DELETE', :OLD.id_estadistica, :OLD.goles, NULL, USER);
  END IF;
END;
/