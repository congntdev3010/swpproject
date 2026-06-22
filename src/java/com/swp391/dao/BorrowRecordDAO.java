package com.swp391.dao;

import com.swp391.model.*;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/**
 * DAO cho bảng borrow_records.
 * Phân quyền: READER tạo/huỷ phiếu; LIBRARIAN xác nhận/từ chối/trả sách.
 */
public class BorrowRecordDAO {

    private Connection getConn() throws ClassNotFoundException, SQLException {
        return DBContext.getInstance().getConnection();
    }

    // ================================================================
    // CREATE
    // ================================================================

    /**
     * READER tạo phiếu mượn mới – status = PENDING.
     * @return id của record mới, hoặc -1 nếu thất bại.
     */
    public int createBorrowRecord(int userId, int bookId, String note) {
        String sql = "INSERT INTO borrow_records (user_id, book_id, note, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, 'PENDING', NOW(), NOW())";
        try (PreparedStatement ps = getConn().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            ps.setString(3, note);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ================================================================
    // READ
    // ================================================================

    /** Lấy phiếu mượn theo id (kèm thông tin user, book, copy). */
    public BorrowRecord getById(int id) {
        String sql = buildBaseSelect()
                   + " WHERE br.id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm phiếu đang mượn (BORROWING / OVERDUE) theo barcode bản sao.
     * Dùng trong màn hình Return Book.
     */
    public BorrowRecord findActiveByCopyBarcode(String barcode) {
        String sql = buildBaseSelect()
                   + " JOIN book_copies bc2 ON br.copy_id = bc2.id"
                   + " WHERE bc2.barcode = ? AND br.status IN ('BORROWING', 'OVERDUE')"
                   + " ORDER BY br.created_at DESC LIMIT 1";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, barcode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm phiếu theo copy_id bất kỳ trạng thái BORROWING/OVERDUE.
     */
    public BorrowRecord findActiveByCopyId(int copyId) {
        String sql = buildBaseSelect()
                   + " WHERE br.copy_id = ? AND br.status IN ('BORROWING', 'OVERDUE')"
                   + " ORDER BY br.created_at DESC LIMIT 1";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Danh sách phiếu của một user (READER xem phiếu của mình).
     * Hỗ trợ filter theo status, search theo tên sách.
     */
    public List<BorrowRecord> getByUserId(int userId, String statusFilter, String search,
                                          int page, int pageSize) {
        List<BorrowRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(buildBaseSelect());
        List<Object> params = new ArrayList<>();

        sql.append(" WHERE br.user_id = ?");
        params.add(userId);

        appendFilters(sql, params, statusFilter, search);
        sql.append(" ORDER BY br.created_at DESC");
        appendPaging(sql, params, page, pageSize);

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            bindParams(ps, params);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Đếm tổng phiếu của user (dùng cho paging). */
    public int countByUserId(int userId, String statusFilter, String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM borrow_records br"
              + " JOIN books b ON br.book_id = b.id"
              + " WHERE br.user_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(userId);
        appendFilters(sql, params, statusFilter, search);

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            bindParams(ps, params);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Danh sách toàn bộ phiếu (LIBRARIAN xem).
     * Hỗ trợ search theo tên user/sách, filter status, paging.
     */
    public List<BorrowRecord> getAll(String statusFilter, String search, int page, int pageSize) {
        List<BorrowRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(buildBaseSelect());
        List<Object> params = new ArrayList<>();

        sql.append(" WHERE 1=1");
        appendFilters(sql, params, statusFilter, search);
        sql.append(" ORDER BY br.created_at DESC");
        appendPaging(sql, params, page, pageSize);

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            bindParams(ps, params);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Đếm tổng tất cả phiếu (dùng cho paging của Librarian). */
    public int countAll(String statusFilter, String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM borrow_records br"
              + " JOIN books b ON br.book_id = b.id"
              + " LEFT JOIN users u ON br.user_id = u.id"
              + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, statusFilter, search);

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            bindParams(ps, params);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================================================================
    // UPDATE – READER actions
    // ================================================================

    /**
     * READER cập nhật ghi chú phiếu (chỉ khi status = PENDING).
     */
    public boolean updateNote(int recordId, int userId, String note) {
        String sql = "UPDATE borrow_records SET note = ?, updated_at = NOW() "
                   + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, note);
            ps.setInt(2, recordId);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * READER huỷ phiếu (chỉ khi status = PENDING).
     */
    public boolean cancelRecord(int recordId, int userId) {
        String sql = "UPDATE borrow_records SET status = 'CANCELLED', updated_at = NOW() "
                   + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, recordId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // UPDATE – LIBRARIAN actions
    // ================================================================

    /**
     * LIBRARIAN xác nhận phiếu: gán bản sao, đặt ngày mượn / hạn trả.
     * Status chuyển từ PENDING → BORROWING.
     */
    public boolean librarianConfirm(int recordId, int copyId, LocalDate borrowDate,
                                    LocalDate dueDate, String librarianNote, int confirmedBy) {
        String sql = "UPDATE borrow_records "
                   + "SET copy_id = ?, borrow_date = ?, due_date = ?, "
                   + "    librarian_note = ?, status = 'BORROWING', "
                   + "    confirmed_by = ?, confirmed_at = NOW(), updated_at = NOW() "
                   + "WHERE id = ? AND status = 'PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            ps.setDate(2, java.sql.Date.valueOf(borrowDate));
            ps.setDate(3, java.sql.Date.valueOf(dueDate));
            ps.setString(4, librarianNote);
            ps.setInt(5, confirmedBy);
            ps.setInt(6, recordId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * LIBRARIAN từ chối phiếu.
     */
    public boolean librarianReject(int recordId, String librarianNote, int confirmedBy) {
        String sql = "UPDATE borrow_records "
                   + "SET status = 'REJECTED', librarian_note = ?, "
                   + "    confirmed_by = ?, confirmed_at = NOW(), updated_at = NOW() "
                   + "WHERE id = ? AND status = 'PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, librarianNote);
            ps.setInt(2, confirmedBy);
            ps.setInt(3, recordId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * LIBRARIAN thực hiện trả sách → status = RETURNED.
     */
    public boolean returnBook(int recordId, LocalDate returnDate, String note) {
        String sql = "UPDATE borrow_records "
                   + "SET return_date = ?, status = 'RETURNED', note = CONCAT(COALESCE(note,''), ?), "
                   + "    updated_at = NOW() "
                   + "WHERE id = ? AND status IN ('BORROWING', 'OVERDUE')";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(returnDate));
            ps.setString(2, (note != null && !note.isEmpty()) ? "\n[Librarian]: " + note : "");
            ps.setInt(3, recordId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái bản sao về AVAILABLE sau khi trả.
     */
    public boolean updateCopyStatusAvailable(int copyId) {
        String sql = "UPDATE book_copies SET status = 'AVAILABLE', updated_at = NOW() WHERE id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái bản sao về BORROWED sau khi librarian confirm.
     */
    public boolean updateCopyStatusBorrowed(int copyId) {
        String sql = "UPDATE book_copies SET status = 'BORROWED', updated_at = NOW() WHERE id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // Helpers / Query builders
    // ================================================================

    private String buildBaseSelect() {
        return "SELECT br.*, "
             + " u.username, u.full_name, u.email, u.student_id, u.role AS user_role, "
             + " b.title AS book_title, b.isbn, "
             + " bc.barcode AS copy_barcode, bc.book_condition, bc.status AS copy_status "
             + " FROM borrow_records br"
             + " LEFT JOIN users u  ON br.user_id  = u.id"
             + " LEFT JOIN books b  ON br.book_id  = b.id"
             + " LEFT JOIN book_copies bc ON br.copy_id = bc.id";
    }

    private void appendFilters(StringBuilder sql, List<Object> params,
                               String statusFilter, String search) {
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append(" AND br.status = ?");
            params.add(statusFilter);
        }
        if (search != null && !search.trim().isEmpty()) {
            String like = "%" + search.trim() + "%";
            sql.append(" AND (b.title LIKE ? OR u.full_name LIKE ? OR u.username LIKE ? OR u.student_id LIKE ?)");
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
    }

    private void appendPaging(StringBuilder sql, List<Object> params, int page, int pageSize) {
        if (pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add((page - 1) * pageSize);
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private BorrowRecord mapRow(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getInt("id"));
        br.setUserId(rs.getInt("user_id"));
        br.setBookId(rs.getInt("book_id"));

        int copyId = rs.getInt("copy_id");
        br.setCopyId(rs.wasNull() ? null : copyId);

        java.sql.Date borrowDate = rs.getDate("borrow_date");
        if (borrowDate != null) br.setBorrowDate(borrowDate.toLocalDate());

        java.sql.Date dueDate = rs.getDate("due_date");
        if (dueDate != null) br.setDueDate(dueDate.toLocalDate());

        java.sql.Date returnDate = rs.getDate("return_date");
        if (returnDate != null) br.setReturnDate(returnDate.toLocalDate());

        br.setRenewalCount(rs.getInt("renewal_count"));
        br.setStatus(rs.getString("status"));
        br.setNote(rs.getString("note"));

        // Thử đọc librarian_note nếu có trong ResultSet
        try { br.setLibrarianNote(rs.getString("librarian_note")); } catch (SQLException ignored) {}

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) br.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) br.setUpdatedAt(updatedAt.toLocalDateTime());

        // Embedded user info
        User user = new User();
        user.setId(rs.getInt("user_id"));
        try {
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setEmail(rs.getString("email"));
            user.setStudentId(rs.getString("student_id"));
            user.setRole(rs.getString("user_role"));
        } catch (SQLException ignored) {}
        br.setUser(user);

        // Embedded book info
        Book book = new Book();
        book.setId(rs.getInt("book_id"));
        try {
            book.setTitle(rs.getString("book_title"));
            book.setIsbn(rs.getString("isbn"));
        } catch (SQLException ignored) {}
        br.setBook(book);

        // Embedded copy info
        if (br.getCopyId() != null) {
            BookCopy bc = new BookCopy();
            bc.setId(br.getCopyId());
            try {
                bc.setBarcode(rs.getString("copy_barcode"));
                bc.setBookCondition(rs.getString("book_condition"));
                bc.setStatus(rs.getString("copy_status"));
            } catch (SQLException ignored) {}
            br.setBookCopy(bc);
        }

        return br;
    }
}
