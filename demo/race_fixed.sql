-- [setup] Комната на одну кровать
DELETE FROM residencies WHERE room_id IN (SELECT id FROM rooms WHERE number = 999);
DELETE FROM rooms WHERE number = 999;
INSERT INTO rooms (number, beds_count) VALUES (999, 1);

-- [A] Окно A заселяет студента 1 через безопасную операцию
BEGIN;
SELECT check_in_student_safe(1, (SELECT id FROM rooms WHERE number = 999));

-- [B] Окно B ждёт, пока A закончит
BEGIN;
-- expect: blocked
SELECT check_in_student_safe(2, (SELECT id FROM rooms WHERE number = 999));

-- [A]
COMMIT;

-- [B]
ROLLBACK;

-- [check] Жильцов не больше, чем кроватей?
-- expect: true
SELECT count(*) <= (SELECT beds_count FROM rooms WHERE number = 999)
FROM residencies r JOIN rooms ro ON ro.id = r.room_id
WHERE ro.number = 999 AND r.check_out_date IS NULL;

-- [cleanup]
DELETE FROM residencies WHERE room_id IN (SELECT id FROM rooms WHERE number = 999);
DELETE FROM rooms WHERE number = 999;