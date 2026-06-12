-- Fix user passwords with proper MD5 hashes
-- MD5 hash of "12345" = 827ccb0eea8a706c4c34a16891f84e7b

UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'admin';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'librarian1';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'librarian2';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username LIKE 'reader%';

-- Verify the updates
SELECT username, password FROM users LIMIT 20;

