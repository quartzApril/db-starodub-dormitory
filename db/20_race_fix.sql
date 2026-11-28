CREATE FUNCTION check_in_student_safe(p_student integer, p_room integer)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_id integer;
BEGIN
    PERFORM 1 FROM rooms WHERE id = p_room FOR UPDATE;
    INSERT INTO residencies (student_id, room_id, check_in_date)
    VALUES (p_student, p_room, current_date)
    RETURNING id INTO v_id;
    RETURN v_id;
END $$;