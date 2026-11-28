INSERT INTO repair_requests (room_id, student_id, description, status, created_at)
SELECT
    floor(random()*10 +1)::int,
    floor(random()*10+1)::int,
    'Заявка №' || n,
    (ARRAY['accepted', 'in_progress', 'done'])[floor(random() * 3 + 1)::int],
    now() - random() * interval '365 days'
FROM generate_series(1, 1000) AS n;

