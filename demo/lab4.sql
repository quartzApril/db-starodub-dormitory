-- 1. Сколько заявок на ремонт сейчас?
SELECT count(*) FROM repair_requests;

-- 2. Транзакция падает на второй вставке: первая тоже должна отмениться
-- expect: error check
BEGIN;
INSERT INTO repair_requests (room_id, student_id, description, status, created_at)
VALUES (1, 1, 'Проверка отката', 'accepted', now());
INSERT INTO repair_requests (room_id, student_id, description, status, created_at)
VALUES (1, 1, 'Неверный статус', 'broken', now());
COMMIT;
ROLLBACK;

-- 3. Заявок столько же, сколько в шаге 1
-- expect: same 1
SELECT count(*) FROM repair_requests;

-- 4. app_reader читает представление
SET ROLE app_reader;
SELECT * FROM v_current_residents;
RESET ROLE;

-- 5. app_reader пытается удалить данные
-- expect: error "permission denied"
SET ROLE app_reader;
DELETE FROM repair_requests;
RESET ROLE;

-- 6. app_writer пытается изменить таблицу напрямую
-- expect: error "permission denied"
SET ROLE app_writer;
UPDATE rooms SET beds_count = 10;
RESET ROLE;