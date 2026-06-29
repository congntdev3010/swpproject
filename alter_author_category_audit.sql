-- ============================================================
--  MIGRATION: Thêm audit fields cho bảng authors & categories
-- ============================================================

-- ── 1. Bảng authors ──────────────────────────────────────────
ALTER TABLE authors
    ADD COLUMN updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        COMMENT 'Thời gian cập nhật gần nhất'
        AFTER created_at,
    ADD COLUMN is_deleted  TINYINT(1)  NOT NULL DEFAULT 0
        COMMENT 'Soft delete: 0 = active, 1 = deleted'
        AFTER updated_at,
    ADD COLUMN created_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản tạo bản ghi'
        AFTER is_deleted,
    ADD COLUMN updated_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản cập nhật gần nhất'
        AFTER created_by;

CREATE INDEX idx_authors_is_deleted ON authors (is_deleted);

-- ── 2. Bảng categories ───────────────────────────────────────
ALTER TABLE categories
    ADD COLUMN is_deleted  TINYINT(1)  NOT NULL DEFAULT 0
        COMMENT 'Soft delete: 0 = active, 1 = deleted'
        AFTER updated_at,
    ADD COLUMN created_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản tạo bản ghi'
        AFTER is_deleted,
    ADD COLUMN updated_by  VARCHAR(50) NULL DEFAULT NULL
        COMMENT 'Tài khoản cập nhật gần nhất'
        AFTER created_by;

CREATE INDEX idx_categories_is_deleted ON categories (is_deleted);
