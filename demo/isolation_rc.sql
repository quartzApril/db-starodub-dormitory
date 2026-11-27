-- [setup]
DELETE FROM rooms WHERE number = 998;
INSERT INTO rooms (number, beds_count) VALUES (998, 2);

-- [A] Окно A читает число кроватей (READ COMMITTED)
BEGIN ISOLATION LEVEL READ COMMITTED;
-- expect: value 2
SELECT beds_count FROM rooms WHERE number = 998;

-- [B] Окно B меняет значение и фиксирует
BEGIN;
UPDATE rooms SET beds_count = 3 WHERE number = 998;
COMMIT;

-- [A] Второе чтение видит новое значение
-- expect: value 3
SELECT beds_count FROM rooms WHERE number = 998;
COMMIT;

-- [cleanup]
DELETE FROM rooms WHERE number = 998;