-- 1. Студент 3 видит только свои заявки: чужих нет
-- expect: value 0
SET ROLE rls_student;
SET app.student_id = '3';
SELECT count(*) FROM repair_requests WHERE student_id <> 3;

-- 2. Свои заявки видит
SELECT count(*) > 0 AS sees_own FROM repair_requests WHERE student_id = 3;

-- 3. Другой студент: видны только его заявки
SET app.student_id = '5';
SELECT DISTINCT student_id FROM repair_requests;
RESET ROLE;