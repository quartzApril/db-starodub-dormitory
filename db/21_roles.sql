\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD
CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app_reader;
GRANT SELECT ON v_current_residents, v_room_occupancy TO app_reader;
GRANT EXECUTE ON FUNCTION check_in_student_safe(integer, integer) TO app_writer;