-- ============================================================
-- alter_add_audit_logs.sql
-- Tạo bảng audit_logs để ghi lại các hành động override/ngoại lệ
-- Spec: library-rules-spec-v2.md §4.3, §5
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    action          VARCHAR(100)    NOT NULL COMMENT 'Tên hành động: OVERRIDE_BORROW_LIMIT, WAIVE_FINE, LOCK_ACCOUNT, ...',
    performed_by    VARCHAR(100)    NOT NULL COMMENT 'Username người thực hiện hành động',
    target_user_id  INT             NOT NULL DEFAULT 0 COMMENT 'User ID bị ảnh hưởng (0 nếu không liên quan đến user)',
    detail          TEXT            NULL     COMMENT 'Chi tiết hành động (JSON hoặc text tự do)',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian ghi log',

    INDEX idx_action        (action),
    INDEX idx_performed_by  (performed_by),
    INDEX idx_target_user   (target_user_id),
    INDEX idx_created_at    (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit log cho tất cả hành động override/ngoại lệ trong hệ thống thư viện';
