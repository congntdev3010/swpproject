-- Script: insert_fake_reservations.sql
-- Thêm dữ liệu giả (fake data) vào bảng book_reservations để test giao diện.

USE library_management_swp391;

INSERT INTO book_reservations 
(user_id, book_id, status, reserve_date, expiry_date, created_at)
VALUES
(2, 5, 'PENDING', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), NOW()),
(3, 12, 'PENDING', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), NOW()),
(4, 18, 'COMPLETED', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(5, 40, 'CANCELLED', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)),
(6, 60, 'PENDING', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), NOW());
