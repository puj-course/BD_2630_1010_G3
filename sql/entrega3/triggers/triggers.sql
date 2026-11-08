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