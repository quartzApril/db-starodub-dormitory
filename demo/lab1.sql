-- 1. Вставляем комнату 2-ой раз: ошибка UNIQUE
-- expect: error unique
INSERT INTO rooms (number, beds_count) VALUES (100, 3);

-- 2. Нарушение CHECK
-- expect: error check
INSERT INTO repair_requests (room_id, student_id, description, status, created_at) VALUES (3, 3, 'У мен нет пиццы', 'iWantPizza', '2027-09-10 14:30:00+03');

-- 3. Ссылка на несуществующую строку
-- expect: error fk
INSERT INTO duty_students(duty_id, student_id) VALUES (1, 100)
