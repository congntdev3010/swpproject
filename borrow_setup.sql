-- ============================================================
-- Thêm tài khoản demo: nemo (ADMIN), nemolib (LIBRARIAN), nemouser (READER)
-- MD5("1") = c4ca4238a0b923820dcc509a6f75849b
-- ============================================================

-- Xóa nếu đã tồn tại để tránh lỗi duplicate
DELETE FROM user_memberships WHERE user_id IN (SELECT id FROM users WHERE username IN ('nemo','nemolib','nemouser'));
DELETE FROM users WHERE username IN ('nemo','nemolib','nemouser');

INSERT INTO users (username, password, full_name, email, phone, student_id, role, active)
VALUES
  ('nemo',     'c4ca4238a0b923820dcc509a6f75849b', 'Nemo Admin',    'nemo@thuvien.edu.vn',    '0911111111', NULL,       'ADMIN',     1),
  ('nemolib',  'c4ca4238a0b923820dcc509a6f75849b', 'Nemo Librarian','nemolib@thuvien.edu.vn', '0922222222', NULL,       'LIBRARIAN', 1),
  ('nemouser', 'c4ca4238a0b923820dcc509a6f75849b', 'Nemo Reader',   'nemouser@thuvien.edu.vn','0933333333', 'HE170999', 'READER',    1);

-- Thêm membership cho nemouser
INSERT INTO user_memberships (user_id, tier_id, total_books_borrowed, tier_achieved_at)
SELECT id, 1, 0, CURDATE() FROM users WHERE username = 'nemouser';

-- ============================================================
-- Đảm bảo bảng borrow_records có thể lưu status PENDING và REJECTED
-- ============================================================
ALTER TABLE borrow_records
  MODIFY COLUMN status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
  COMMENT 'PENDING | BORROWING | RETURNED | OVERDUE | LOST | REJECTED';

-- ============================================================
-- Đảm bảo cột borrow_date có thể là NULL (cho đơn PENDING chưa được duyệt)
-- ============================================================
ALTER TABLE borrow_records
  MODIFY COLUMN borrow_date DATE NULL,
  MODIFY COLUMN due_date DATE NULL;
