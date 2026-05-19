-- Fix password hash for admin account 0909000000
-- Password: admin123
UPDATE users
SET password_hash = '$2a$10$2PCTAysv7yNADgTIFh8jEOS2yAHlZwQfssk0iTDJK1sBNjjtVURNi'
WHERE phone = '0909000000';
