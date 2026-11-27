CREATE FUNCTION check_room_capacity() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_beds integer;
    v_busy integer;
BEGIN
    IF NEW.check_out_date IS NULL THEN
        SELECT beds_count INTO v_beds FROM rooms WHERE id = NEW.room_id;
        SELECT count(*) INTO v_busy FROM residencies
        WHERE room_id = NEW.room_id
          AND check_out_date IS NULL
          AND id IS DISTINCT FROM NEW.id;
        IF v_busy >= v_beds THEN
            RAISE EXCEPTION 'В комнате % нет свободных кроватей: занято % из %',
                NEW.room_id, v_busy, v_beds;
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_check_room_capacity
BEFORE INSERT OR UPDATE ON residencies
FOR EACH ROW EXECUTE FUNCTION check_room_capacity();

ALTER TABLE repair_requests ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();

CREATE FUNCTION set_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END $$;

CREATE TRIGGER trg_repair_requests_updated_at
BEFORE UPDATE ON repair_requests
FOR EACH ROW EXECUTE FUNCTION set_updated_at();