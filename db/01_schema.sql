CREATE TABLE rooms (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    number integer NOT NULL UNIQUE,
    beds_count integer NOT NULL CHECK (beds_count > 0)
);

CREATE TABLE students (
       id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
       first_name text NOT NULL,
       last_name text NOT NULL,
       course integer NOT NULL CHECK (course BETWEEN 1 AND 6)
);

CREATE TABLE duties(
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    duty_date date NOT NULL
);

CREATE TABLE residencies
(
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id    integer NOT NULL REFERENCES students (id),
    room_id       integer NOT NULL REFERENCES rooms (id),
    check_in_date date NOT NULL,
    check_out_date date CHECK ( check_out_date >= check_in_date ),
    UNIQUE(student_id, check_in_date)
);

CREATE TABLE repair_requests(
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id integer NOT NULL REFERENCES rooms (id),
    student_id integer NOT NULL REFERENCES students (id),
    description text NOT NULL,
    status text NOT NULL CHECK ( status IN ('accepted', 'in_progress', 'done') ),
    created_at timestamptz NOT NULL
);

CREATE TABLE duty_students(
        duty_id integer NOT NULL REFERENCES duties (id),
        student_id integer NOT NULL REFERENCES students (id),
        PRIMARY KEY(duty_id, student_id)
);



