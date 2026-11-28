CREATE TABLE residencies_log (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    operation  text NOT NULL,
    row_id     integer NOT NULL,
    old_data   jsonb,
    new_data   jsonb,
    changed_by text NOT NULL DEFAULT session_user,
    changed_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE FUNCTION log_residencies() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO residencies_log (operation, row_id, old_data, new_data)
        VALUES ('INSERT', NEW.id, NULL, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO residencies_log (operation, row_id, old_data, new_data)
        VALUES ('UPDATE', NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSE
        INSERT INTO residencies_log (operation, row_id, old_data, new_data)
        VALUES ('DELETE', OLD.id, to_jsonb(OLD), NULL);
        RETURN OLD;
    END IF;
END $$;

CREATE TRIGGER trg_log_residencies
AFTER INSERT OR UPDATE OR DELETE ON residencies
FOR EACH ROW EXECUTE FUNCTION log_residencies();

CREATE FUNCTION residency_state_at(p_id integer, p_at timestamptz)
RETURNS jsonb
LANGUAGE sql
AS $$
    SELECT new_data
    FROM residencies_log
    WHERE row_id = p_id AND changed_at <= p_at
    ORDER BY changed_at DESC, id DESC
    LIMIT 1;
$$;