package com.swp391.dao;

import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import java.sql.*;
import java.util.*;

public class BookCopyDAO {

    private Connection getConn() throws ClassNotFoundException, SQLException {
        return DBContext.getInstance().getConnection();
    }

    // ================================================================
    //  Các method CŨ — giữ nguyên hoàn toàn
    // ================================================================

    /** Lấy danh sách bản sao theo book_id */
    public List<BookCopy> getCopiesByBookId(int bookId) {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.book_id = ? AND bc.is_deleted = 0 ORDER BY bc.barcode";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lấy toàn bộ bản sao (cho sơ đồ kho) */
    public List<BookCopy> getAllCopies() {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.is_deleted = 0 "
                + "ORDER BY bc.area, bc.shelf, bc.slot, bc.barcode";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tìm bản sao theo barcode */
    public BookCopy findByBarcode(String barcode) {
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.barcode = ? AND bc.is_deleted = 0";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, barcode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Danh sách tầng phân biệt, tự động thêm "Chưa xếp" nếu có NULL */
    public List<String> getDistinctAreas() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT area FROM book_copies "
                + "WHERE area IS NOT NULL AND is_deleted = 0 ORDER BY area";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(rs.getString("area"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (countUnplaced() > 0) list.add("Chưa xếp");
        return list;
    }

    /** Cập nhật vị trí bản sao */
    public boolean updateLocation(int copyId, String area, String shelf, String slot) {
        String sql = "UPDATE book_copies SET area=?, shelf=?, slot=? WHERE id=?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, area);
            ps.setString(2, shelf);
            ps.setString(3, slot);
            ps.setInt(4, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Thêm bản sao mới */
    public boolean addCopy(int bookId, String barcode, String area, String shelf, String slot) {
        String sql = "INSERT INTO book_copies (book_id, barcode, book_condition, status, area, shelf, slot) "
                + "VALUES (?, ?, 'GOOD', 'AVAILABLE', ?, ?, ?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setString(2, barcode);
            ps.setString(3, area);
            ps.setString(4, shelf);
            ps.setString(5, slot);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                updateBookStock(bookId);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Xóa mềm bản sao (soft delete, chỉ khi status khác BORROWED và RESERVED) */
    public boolean deleteCopy(int copyId) {
        int bookId = -1;
        String sqlGetBook = "SELECT book_id FROM book_copies WHERE id = ? AND is_deleted = 0";
        try (PreparedStatement ps = getConn().prepareStatement(sqlGetBook)) {
            ps.setInt(1, copyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    bookId = rs.getInt("book_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Soft delete: đánh dấu is_deleted=1 thay vì xóa vật lý
        String sql = "UPDATE book_copies SET is_deleted = 1 "
                   + "WHERE id = ? AND is_deleted = 0 AND status NOT IN ('BORROWED', 'RESERVED')";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok && bookId > 0) {
                updateBookStock(bookId);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    //  Các method MỚI — phục vụ filter cascade & move
    // ================================================================

    /**
     * Lọc bản sao theo tầng / kệ / ngăn.
     * Bất kỳ param nào null/rỗng → bỏ qua điều kiện đó.
     * "Chưa xếp" → lọc WHERE field IS NULL.
     */
    public List<BookCopy> getCopiesFiltered(String area, String shelf, String slot) {
        List<BookCopy> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.is_deleted = 0 AND 1=1");

        List<Object> params = new ArrayList<>();

        if (area != null && !area.isEmpty()) {
            if ("Chưa xếp".equals(area)) {
                sql.append(" AND bc.area IS NULL");
            } else {
                sql.append(" AND bc.area = ?");
                params.add(area);
            }
        }
        if (shelf != null && !shelf.isEmpty()) {
            if ("Chưa xếp".equals(shelf)) {
                sql.append(" AND bc.shelf IS NULL");
            } else {
                sql.append(" AND bc.shelf = ?");
                params.add(shelf);
            }
        }
        if (slot != null && !slot.isEmpty()) {
            if ("Chưa xếp".equals(slot)) {
                sql.append(" AND bc.slot IS NULL");
            } else {
                sql.append(" AND bc.slot = ?");
                params.add(slot);
            }
        }

        sql.append(" ORDER BY bc.area, bc.shelf, bc.slot, bc.barcode");

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Danh sách kệ (shelf) phân biệt theo tầng — dùng cho dropdown cascade.
     */
    public List<String> getDistinctShelvesByArea(String area) {
        List<String> list = new ArrayList<>();
        String sql = "Chưa xếp".equals(area)
                ? "SELECT DISTINCT shelf FROM book_copies WHERE area IS NULL AND shelf IS NOT NULL AND is_deleted = 0 ORDER BY shelf"
                : "SELECT DISTINCT shelf FROM book_copies WHERE area = ? AND shelf IS NOT NULL AND is_deleted = 0 ORDER BY shelf";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            if (!"Chưa xếp".equals(area)) ps.setString(1, area);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(rs.getString("shelf"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Danh sách ngăn (slot) phân biệt theo tầng + kệ — dùng cho dropdown cascade.
     */
    public List<String> getDistinctSlotsByAreaAndShelf(String area, String shelf) {
        List<String> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT slot FROM book_copies WHERE slot IS NOT NULL AND is_deleted = 0");

        List<String> params = new ArrayList<>();
        if (area != null && !area.isEmpty()) {
            if ("Chưa xếp".equals(area)) sql.append(" AND area IS NULL");
            else { sql.append(" AND area = ?"); params.add(area); }
        }
        if (shelf != null && !shelf.isEmpty()) {
            if ("Chưa xếp".equals(shelf)) sql.append(" AND shelf IS NULL");
            else { sql.append(" AND shelf = ?"); params.add(shelf); }
        }
        sql.append(" ORDER BY slot");

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setString(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(rs.getString("slot"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm kiếm & lọc bản sao thuộc một đầu sách có phân trang.
     */
    public List<BookCopy> searchCopies(int bookId, String barcode, String status, String area, int page, int pageSize) {
        List<BookCopy> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.book_id = ? AND bc.is_deleted = 0 "
        );
        List<Object> params = new ArrayList<>();
        params.add(bookId);

        if (barcode != null && !barcode.trim().isEmpty()) {
            sql.append("AND bc.barcode LIKE ? ");
            params.add("%" + barcode.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND bc.status = ? ");
            params.add(status.trim());
        }
        if (area != null && !area.trim().isEmpty()) {
            if ("Chưa xếp".equals(area)) {
                sql.append("AND bc.area IS NULL ");
            } else {
                sql.append("AND bc.area = ? ");
                params.add(area.trim());
            }
        }

        sql.append("ORDER BY bc.barcode LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số bản sao thỏa mãn điều kiện lọc (dùng cho phân trang).
     */
    public int countCopies(int bookId, String barcode, String status, String area) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM book_copies bc WHERE bc.book_id = ? AND bc.is_deleted = 0 "
        );
        List<Object> params = new ArrayList<>();
        params.add(bookId);

        if (barcode != null && !barcode.trim().isEmpty()) {
            sql.append("AND bc.barcode LIKE ? ");
            params.add("%" + barcode.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND bc.status = ? ");
            params.add(status.trim());
        }
        if (area != null && !area.trim().isEmpty()) {
            if ("Chưa xếp".equals(area)) {
                sql.append("AND bc.area IS NULL ");
            } else {
                sql.append("AND bc.area = ? ");
                params.add(area.trim());
            }
        }

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================================================================
    //  Helpers
    // ================================================================

    private int countUnplaced() {
        String sql = "SELECT COUNT(*) FROM book_copies WHERE area IS NULL AND is_deleted = 0";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================================================================
    //  Các method CRUD & AUDIT LOG MỚI
    // ================================================================

    /** Tự động tạo bảng logs nếu chưa tồn tại */
    public void ensureAuditLogTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS book_copy_logs ("
                   + "    id INT AUTO_INCREMENT PRIMARY KEY,"
                   + "    copy_id INT NOT NULL,"
                   + "    action VARCHAR(20) NOT NULL,"
                   + "    changed_by VARCHAR(50) NOT NULL,"
                   + "    old_status VARCHAR(20),"
                   + "    new_status VARCHAR(20),"
                   + "    old_condition VARCHAR(20),"
                   + "    new_condition VARCHAR(20),"
                   + "    note VARCHAR(255),"
                   + "    created_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                   + ")";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Ghi log lịch sử thay đổi */
    public boolean addAuditLog(int copyId, String action, String changedBy, 
                               String oldStatus, String newStatus, 
                               String oldCondition, String newCondition, String note) {
        ensureAuditLogTableExists();
        String sql = "INSERT INTO book_copy_logs (copy_id, action, changed_by, old_status, new_status, old_condition, new_condition, note) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            ps.setString(2, action);
            ps.setString(3, changedBy);
            ps.setString(4, oldStatus);
            ps.setString(5, newStatus);
            ps.setString(6, oldCondition);
            ps.setString(7, newCondition);
            ps.setString(8, note);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Đồng bộ lại số lượng quantity và available của sách */
    public void updateBookStock(int bookId) {
        String sqlCount = "SELECT COUNT(*) AS total, SUM(CASE WHEN status='AVAILABLE' THEN 1 ELSE 0 END) AS avail FROM book_copies WHERE book_id=?";
        String sqlUpdate = "UPDATE books SET quantity=?, available=? WHERE id=?";
        try {
            int total = 0;
            int avail = 0;
            try (PreparedStatement ps = getConn().prepareStatement(sqlCount)) {
                ps.setInt(1, bookId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getInt("total");
                        avail = rs.getInt("avail");
                    }
                }
            }
            try (PreparedStatement ps = getConn().prepareStatement(sqlUpdate)) {
                ps.setInt(1, total);
                ps.setInt(2, avail);
                ps.setInt(3, bookId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Tìm kiếm bản sao theo ID (chỉ lấy bản chưa xóa) */
    public BookCopy findById(int id) {
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                   + "JOIN books b ON bc.book_id = b.id "
                   + "WHERE bc.id = ? AND bc.is_deleted = 0";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Kiểm tra xem barcode có bị trùng lặp không (loại trừ ID hiện tại) */
    public boolean isBarcodeExists(String barcode, int excludeId) {
        String sql = excludeId > 0
                ? "SELECT COUNT(*) FROM book_copies WHERE barcode = ? AND id != ?"
                : "SELECT COUNT(*) FROM book_copies WHERE barcode = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, barcode);
            if (excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Thêm bản sao mới đầy đủ thông tin (ghi nhận created_by) */
    public boolean addCopy(BookCopy copy) {
        String sql = "INSERT INTO book_copies (book_id, barcode, book_condition, status, area, shelf, slot, note, created_by, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (PreparedStatement ps = getConn().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, copy.getBookId());
            ps.setString(2, copy.getBarcode());
            ps.setString(3, copy.getBookCondition());
            ps.setString(4, copy.getStatus());
            ps.setString(5, copy.getArea());
            ps.setString(6, copy.getShelf());
            ps.setString(7, copy.getSlot());
            ps.setString(8, copy.getNote());
            ps.setString(9, copy.getCreatedBy());
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        copy.setId(keys.getInt(1));
                    }
                }
                updateBookStock(copy.getBookId());
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Cập nhật thông tin bản sao (ghi nhận updated_by) */
    public boolean updateCopy(BookCopy copy) {
        String sql = "UPDATE book_copies SET barcode = ?, book_condition = ?, status = ?, area = ?, shelf = ?, slot = ?, note = ?, updated_by = ?, updated_at = NOW() WHERE id = ? AND is_deleted = 0";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, copy.getBarcode());
            ps.setString(2, copy.getBookCondition());
            ps.setString(3, copy.getStatus());
            ps.setString(4, copy.getArea());
            ps.setString(5, copy.getShelf());
            ps.setString(6, copy.getSlot());
            ps.setString(7, copy.getNote());
            ps.setString(8, copy.getUpdatedBy());
            ps.setInt(9, copy.getId());
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                updateBookStock(copy.getBookId());
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Map ResultSet → BookCopy — giữ nguyên hoàn toàn so với bản gốc */
    private BookCopy mapRow(ResultSet rs) throws SQLException {
        BookCopy bc = new BookCopy();
        bc.setId(rs.getInt("id"));
        bc.setBookId(rs.getInt("book_id"));
        bc.setBarcode(rs.getString("barcode"));
        bc.setBookCondition(rs.getString("book_condition"));
        bc.setStatus(rs.getString("status"));
        bc.setNote(rs.getString("note"));
        bc.setArea(rs.getString("area"));
        bc.setShelf(rs.getString("shelf"));
        bc.setSlot(rs.getString("slot"));
        bc.setDeleted(rs.getInt("is_deleted") == 1);
        bc.setCreatedBy(rs.getString("created_by"));
        bc.setUpdatedBy(rs.getString("updated_by"));

        Book book = new Book();
        book.setId(rs.getInt("book_id"));
        book.setTitle(rs.getString("title"));
        book.setIsbn(rs.getString("isbn"));
        bc.setBook(book);

        return bc;
    }
}