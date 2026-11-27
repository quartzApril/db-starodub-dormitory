-- [setup]
DELETE FROM rooms WHERE number IN (997, 998);
INSERT INTO rooms (number, beds_count) VALUES (997, 2), (998, 2);

-- [A] Окно A блокирует комнату 998
BEGIN;
UPDATE rooms SET beds_count = 2 WHERE number = 998;

-- [B] Окно B блокирует комнату 997
BEGIN;
UPDATE rooms SET beds_count = 2 WHERE number = 997;

-- [A] A хочет 997 и ждёт B
-- expect: blocked
UPDATE rooms SET beds_count = 2 WHERE number = 997;

-- [B] B хочет 998 и ждёт A: взаимоблокировка
-- expect: error deadlock
UPDATE rooms SET beds_count = 2 WHERE number = 998;

-- [B]
ROLLBACK;

-- [A]
COMMIT;

-- [cleanup]
DELETE FROM rooms WHERE number IN (997, 998);