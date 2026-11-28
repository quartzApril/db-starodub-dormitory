CREATE VIEW v_current_residents AS
SELECT s.last_name, ro.number AS room_number, r.check_in_date
FROM residencies r
JOIN students s ON s.id = r.student_id
JOIN rooms ro ON ro.id = r.room_id
WHERE r.check_out_date IS NULL;

CREATE VIEW v_room_occupancy AS
SELECT ro.id, ro.number, ro.beds_count, count(r.id) AS occupied
FROM rooms ro
LEFT JOIN residencies r ON r.room_id = ro.id AND r.check_out_date IS NULL
GROUP BY ro.id, ro.number, ro.beds_count;