-- ============================================================
--  MIGRATION: Thêm audit fields cho bảng books & book_copies
--  Chạy script này một lần trên database hiện có.
--  (updated_at đã tồn tại sẵn với ON UPDATE CURRENT_TIMESTAMP)
-- ============================================================

-- ── 1. Bảng books ──────────────────────────────────────────
ALTER TABLE books
    ADD COLUMN is_deleted  TINYINT(1)  NOT NULL DEFAULT 0
        COMMENT 'Soft delete: 0 = active, 1 = deleted'
        AFTER updated_at,
    ADD COLUMN created_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản tạo bản ghi'
        AFTER is_deleted,
    ADD COLUMN updated_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản cập nhật gần nhất'
        AFTER created_by;

CREATE INDEX idx_books_is_deleted ON books (is_deleted);

-- ── 2. Bảng book_copies ────────────────────────────────────
ALTER TABLE book_copies
    ADD COLUMN is_deleted  TINYINT(1)  NOT NULL DEFAULT 0
        COMMENT 'Soft delete: 0 = active, 1 = deleted'
        AFTER updated_at,
    ADD COLUMN created_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản thêm bản sao'
        AFTER is_deleted,
    ADD COLUMN updated_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản cập nhật gần nhất'
        AFTER created_by;

CREATE INDEX idx_copies_is_deleted ON book_copies (is_deleted);
