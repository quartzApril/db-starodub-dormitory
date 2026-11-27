CREATE MATERIALIZED VIEW mv_requests_by_month AS
SELECT date_trunc('month', created_at)::date AS month,
       count(*) AS requests,
       count(*) FILTER (WHERE status = 'done') AS done_requests
FROM repair_requests
GROUP BY date_trunc('month', created_at)::date;

CREATE FUNCTION search_requests(
    p_status text DEFAULT NULL,
    p_room   integer DEFAULT NULL
)
RETURNS TABLE (
    request_id     integer,
    room_number    integer,
    student_name   text,
    request_status text,
    created        timestamptz
)
LANGUAGE sql
AS $$
    SELECT rr.id, ro.number, s.last_name, rr.status, rr.created_at
    FROM repair_requests rr
    JOIN rooms ro ON ro.id = rr.room_id
    JOIN students s ON s.id = rr.student_id
    WHERE (p_status IS NULL OR rr.status = p_status)
      AND (p_room IS NULL OR ro.number = p_room)
    ORDER BY rr.created_at DESC;
$$;