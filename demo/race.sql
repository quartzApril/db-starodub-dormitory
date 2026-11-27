-- [setup] Комната на одну кровать
DELETE FROM residencies WHERE room_id IN (SELECT id FROM rooms WHERE number = 999);
DELETE FROM rooms WHERE number = 999;
INSERT INTO rooms (number, beds_count) VALUES (999, 1);

-- [A] Окно A: место свободно, заселяем студента 1
BEGIN;
INSERT INTO residencies (student_id, room_id, check_in_date)
SELECT 1, id, current_date FROM rooms WHERE number = 999;

-- [B] Окно B в тот же момент: триггер не видит вставку окна A, заселяет студента 2
BEGIN;
INSERT INTO residencies (student_id, room_id, check_in_date)
SELECT 2, id, current_date FROM rooms WHERE number = 999;

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Жильцов не больше, чем кроватей?
-- expect: false
SELECT count(*) <= (SELECT beds_count FROM rooms WHERE number = 999)
FROM residencies r JOIN rooms ro ON ro.id = r.room_id
WHERE ro.number = 999 AND r.check_out_date IS NULL;

-- [cleanup]
DELETE FROM residencies WHERE room_id IN (SELECT id FROM rooms WHERE number = 999);
DELETE FROM rooms WHERE number = 999;