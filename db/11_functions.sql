CREATE FUNCTION free_beds(p_room integer)
RETURNS integer
LANGUAGE sql
AS $$
    SELECT (ro.beds_count - (SELECT count(*) FROM residencies r
                             WHERE r.room_id = ro.id AND r.check_out_date IS NULL))::integer
    FROM rooms ro
    WHERE ro.id = p_room;
$$;

CREATE FUNCTION check_in_student(p_student integer, p_room integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO residencies (student_id, room_id, check_in_date)
    VALUES (p_student, p_room, current_date)
    RETURNING id INTO v_id;
    RETURN v_id;
END $$;