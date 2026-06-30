-- ============================================================
-- FIX borrow_records: hỗ trợ PENDING, REJECTED và nhóm phiếu
-- Chạy script này một lần để cập nhật schema database
-- ============================================================

-- 1. Đổi cột status sang VARCHAR để hỗ trợ PENDING / REJECTED
ALTER TABLE borrow_records
  MODIFY COLUMN status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
  COMMENT 'PENDING | BORROWING | RETURNED | OVERDUE | LOST | REJECTED';

-- 2. Cho phép borrow_date và due_date là NULL (đơn PENDING chưa được duyệt)
ALTER TABLE borrow_records
  MODIFY COLUMN borrow_date DATE NULL,
  MODIFY COLUMN due_date DATE NULL;

-- 3. Thêm cột request_group_id để nhóm các sách cùng 1 lần mượn thành 1 phiếu
ALTER TABLE borrow_records
  ADD COLUMN request_group_id VARCHAR(36) NULL
  COMMENT 'UUID nhóm các sách trong cùng 1 phiếu mượn'
  AFTER note;

-- 4. Index cho request_group_id để tăng tốc truy vấn nhóm
CREATE INDEX idx_borrow_group ON borrow_records(request_group_id);

-- Kiểm tra kết quả
DESCRIBE borrow_records;
