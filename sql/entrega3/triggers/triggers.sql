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