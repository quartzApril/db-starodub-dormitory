-- 1. Кто сейчас живёт в общежитии?
SELECT * FROM v_current_residents;

-- 2. Сколько кроватей в каждой комнате и сколько занято?
SELECT * FROM v_room_occupancy ORDER BY number;

-- 3. Сколько свободных кроватей в комнате с id 3?
SELECT free_beds(3);

-- 4. Заселяем студента 1 в комнату 3, где есть место
BEGIN;
SELECT check_in_student(1, 3);
SELECT * FROM v_current_residents ORDER BY room_number;
ROLLBACK;

-- 5. Комната с id 5 на одну кровать уже занята: ошибка триггера
-- expect: error "нет свободных кроватей"
SELECT check_in_student(2, 5);

-- 6. Меняем статус заявки: служебный триггер обновляет updated_at
BEGIN;
SELECT id, status, updated_at FROM repair_requests WHERE id = 1;
UPDATE repair_requests SET status = 'done' WHERE id = 1;
SELECT id, status, updated_at FROM repair_requests WHERE id = 1;
ROLLBACK;

-- 7. Сколько заявок по месяцам и сколько из них выполнено?
SELECT * FROM mv_requests_by_month ORDER BY month DESC;

-- 8. Добавили заявку: отчёт не изменился, пока его не обновили
BEGIN;
INSERT INTO repair_requests (room_id, student_id, description, status, created_at)
VALUES (1, 1, 'Проверка отчёта', 'accepted', now());
SELECT * FROM mv_requests_by_month WHERE month = date_trunc('month', now())::date;
REFRESH MATERIALIZED VIEW mv_requests_by_month;
SELECT * FROM mv_requests_by_month WHERE month = date_trunc('month', now())::date;
ROLLBACK;

-- 9. Поиск заявок: только по статусу
SELECT * FROM search_requests(p_status => 'done') LIMIT 5;

-- 10. Поиск заявок: только по номеру комнаты
SELECT * FROM search_requests(p_room => 103) LIMIT 5;

-- 11. Поиск заявок: оба фильтра сразу
SELECT * FROM search_requests('accepted', 103) LIMIT 5;

-- 12. Заселили студента и выселили: в журнале по записи на каждое изменение
BEGIN;
INSERT INTO residencies (student_id, room_id, check_in_date) VALUES (1, 3, current_date);
UPDATE residencies SET check_out_date = current_date WHERE student_id = 1 AND check_in_date = current_date;
SELECT operation, old_data->>'check_out_date' AS old_out, new_data->>'check_out_date' AS new_out, changed_by
FROM residencies_log
ORDER BY id DESC
LIMIT 2;
ROLLBACK;

-- 13. Состояние заселения на момент начала транзакции и сейчас
BEGIN;
INSERT INTO residencies (student_id, room_id, check_in_date) VALUES (1, 3, current_date);
UPDATE residencies SET check_out_date = current_date WHERE student_id = 1 AND check_in_date = current_date;
SELECT residency_state_at(r.id, now()) AS at_start,
       residency_state_at(r.id, clock_timestamp())->>'check_out_date' AS out_now
FROM residencies r
WHERE r.student_id = 1 AND r.check_in_date = current_date;
ROLLBACK;