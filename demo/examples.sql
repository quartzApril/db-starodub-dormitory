-- Покажи имена и фамилии студентов 2 курса.
SELECT s.last_name, s.first_name
FROM students s
WHERE s.course = 2;

--Покажи номера комнат, в которых ровно одна кровать.
SELECT r.number
FROM rooms r
WHERE r.beds_count = 1;

-- Покажи описания заявок со статусом accepted
SELECT r.description
FROM repair_requests r
WHERE r.status = 'accepted'
LIMIT 10;

--Покажи даты дежурств, которые были после 5 сентября 2026 года.
SELECT d.duty_date
FROM duties d
WHERE d.duty_date  > '2026-09-05';

--Покажи заселения, у которых дата выселения не указана (то есть студент живёт сейчас).
SELECT r.student_id, r.room_id
FROM residencies r
WHERE r.check_out_date IS NULL;


--Покажи фамилии студентов, которые сейчас живут в общежитии (то есть заселение без даты выселения).
SELECT s.last_name
FROM students s
JOIN residencies r ON r.student_id = s.id
WHERE r.check_out_date IS NULL;

--Покажи фамилии студентов, которые хотя бы раз дежурили.
SELECT DISTINCT s.last_name
FROM students s
JOIN duty_students d ON d.student_id = s.id;

--Покажи описания заявок, поданных из комнаты с номером 103.
SELECT r.description
FROM repair_requests r
JOIN rooms ro ON ro.id = r.room_id
WHERE ro.number = 103;

--Покажи описания заявок, поданных из комнаты с номером 103, и фамилию студентки, подавшей заявку.
SELECT r.description, s.last_name
FROM repair_requests r
JOIN rooms ro ON ro.id = r.room_id
JOIN students s ON r.student_id = s.id
WHERE ro.number = 103
LIMIT 10;