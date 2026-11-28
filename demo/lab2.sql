-- 1.  Какие студенты подавали заявки на ремонт?
SELECT DISTINCT s.last_name
FROM students s
JOIN repair_requests r ON r.student_id = s.id;

-- 2. В каких комнатах были заявки со статусом done?
SELECT DISTINCT r.number
FROM rooms r
JOIN repair_requests rep ON rep.room_id = r.id
WHERE rep.status = 'done';

-- 3. Кто дежурит 2026-09-05?
SELECT s.first_name, s.last_name
FROM duties d
JOIN duty_students ds ON ds.duty_id = d.id
JOIN students s ON s.id = ds.student_id
WHERE d.duty_date = '2026-09-05';

-- 4. Сколько проживаний в каждой комнате
SELECT r.number, count(*) AS residents
FROM rooms r
JOIN residencies res ON res.room_id = r.id
GROUP BY r.id, r.number
ORDER BY r.number;

-- 5. Сколько заявок по каждому статусу?
SELECT status, count(*) AS cnt
FROM repair_requests
GROUP BY status;

-- 6. Студенты с 2+ заявками
SELECT s.first_name, s.last_name, count(*) AS cnt
FROM students s
JOIN repair_requests rr ON rr.student_id = s.id
GROUP BY s.id, s.first_name, s.last_name
HAVING count(*) >= 2;

-- 7. Сколько всего мест в занятых комнатах (среднее)
SELECT round(avg(r.beds_count), 2) AS avg_beds
FROM rooms r
JOIN residencies res ON res.room_id = r.id;

-- 8. Комнаты без заявок на ремонт («сироты»)
SELECT r.id, r.number
FROM rooms r
LEFT JOIN repair_requests rr ON rr.room_id = r.id
WHERE rr.id IS NULL;

-- 9. Студенты, у которых есть заявка 'accepted' (подзапрос IN)
SELECT first_name, last_name
FROM students
WHERE id IN (
    SELECT student_id FROM repair_requests WHERE status = 'accepted'
);

-- 10. Студенты, которые ни разу не дежурили (подзапрос NOT IN)
SELECT first_name, last_name
FROM students
WHERE id NOT IN (SELECT student_id FROM duty_students);

-- 11. Добавляем студента и заселяем его. SELECT до/после, потом откат.
BEGIN;
SELECT count(*) AS students_before FROM students;

WITH new_student AS (
    INSERT INTO students (first_name, last_name, course)
    VALUES ('Новый', 'Студент', 1)
    RETURNING id
)
INSERT INTO residencies (student_id, room_id, check_in_date)
SELECT id, 1, '2026-09-01' FROM new_student;

SELECT count(*) AS students_after FROM students;
ROLLBACK;

-- 12. Закрываем все 'accepted' заявки в комнате 3. SELECT до/после, откат.
BEGIN;
SELECT id, status FROM repair_requests WHERE room_id = 3 AND status = 'accepted';

UPDATE repair_requests SET status = 'done'
WHERE room_id = 3 AND status = 'accepted';

SELECT id, status FROM repair_requests WHERE room_id = 3;
ROLLBACK;

-- 11b. Удаляем одно дежурство студента 1. SELECT до/после, откат.
BEGIN;
SELECT count(*) AS before FROM duty_students WHERE student_id = 1;
DELETE FROM duty_students WHERE student_id = 1 AND duty_id = 1;
SELECT count(*) AS after FROM duty_students WHERE student_id = 1;
ROLLBACK;

-- 13. Топ-3 комнаты по числу заявок внутри каждого статуса
WITH counts AS (
    SELECT r.number, rr.status, count(*) AS cnt,
           ROW_NUMBER() OVER (PARTITION BY rr.status ORDER BY count(*) DESC, r.id) AS rn
    FROM rooms r
    JOIN repair_requests rr ON rr.room_id = r.id
    GROUP BY r.id, r.number, rr.status
)
SELECT status, number, cnt
FROM counts
WHERE rn <= 3
ORDER BY status, rn;

-- 14. Накопительная сумма заявок по дням
WITH daily AS (
    SELECT created_at::date AS d, count(*) AS cnt
    FROM repair_requests
    GROUP BY created_at::date
)
SELECT d, cnt, sum(cnt) OVER (ORDER BY d) AS running_total
FROM daily
ORDER BY d;

-- 15. По каждой комнате: всего заявок, done, accepted, процент done
SELECT r.number,
       count(*) AS total,
       count(*) FILTER (WHERE rr.status = 'done')     AS done_cnt,
       count(*) FILTER (WHERE rr.status = 'accepted') AS accepted_cnt,
       round(100.0 * count(*) FILTER (WHERE rr.status = 'done') / count(*), 1) AS done_pct
FROM rooms r
JOIN repair_requests rr ON rr.room_id = r.id
GROUP BY r.id, r.number
ORDER BY r.number;

-- 16. Помесячная динамика заявок и процент к прошлому месяцу
WITH monthly AS (
    SELECT date_trunc('month', created_at)::date AS month,
           count(*) AS cnt
    FROM repair_requests
    GROUP BY date_trunc('month', created_at)
)
SELECT month,
       cnt,
       lag(cnt) OVER (ORDER BY month) AS prev_cnt,
       round(100.0 * (cnt - lag(cnt) OVER (ORDER BY month))
             / lag(cnt) OVER (ORDER BY month), 1) AS pct_change
FROM monthly
ORDER BY month;

-- 17. Календарь всех дней между первым и последним дежурством,
--     с пометкой «есть ли дежурство в этот день»
WITH RECURSIVE calendar AS (
    SELECT min(duty_date) AS d FROM duties
    UNION ALL
    SELECT (d + 1)::date FROM calendar
    WHERE d < (SELECT max(duty_date) FROM duties)
)
SELECT c.d AS day,
       (duty.id IS NOT NULL) AS has_duty
FROM calendar c
LEFT JOIN duties duty ON duty.duty_date = c.d
ORDER BY c.d;
