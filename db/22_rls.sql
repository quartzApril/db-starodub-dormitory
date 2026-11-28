CREATE ROLE rls_student NOLOGIN;
GRANT USAGE ON SCHEMA public TO rls_student;
GRANT SELECT ON repair_requests TO rls_student;

ALTER TABLE repair_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY own_requests ON repair_requests
FOR SELECT TO rls_student
USING (student_id = current_setting('app.student_id', true)::integer);