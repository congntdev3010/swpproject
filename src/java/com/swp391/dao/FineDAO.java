package com.swp391.dao;

import com.swp391.model.Fine;
import com.swp391.model.User;
import com.swp391.model.Book;
import com.swp391.model.BorrowRecord;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

/**
 * DAO cho bảng fines.
 * Mức phạt mặc định: FINE_RATE_PER_DAY VND/ngày trễ hạn.
 */
public class FineDAO {

    /** Mức phạt trễ hạn: 5.000 VND / ngày */
    public static final BigDecimal FINE_RATE_PER_DAY = new BigDecimal("5000");

    private Connection getConn() throws ClassNotFoundException, SQLException {
        return DBContext.getInstance().getConnection();
    }

    // ================================================================
    // CREATE
    // ================================================================

    /**
     * Tạo bản ghi phạt mới (sau khi trả sách trễ hạn).
     * @return id mới hoặc -1 nếu thất bại.
     */
    public int createFine(int borrowRecordId, int userId, BigDecimal amount,
                          int overdueDays, String reason) {
        String sql = "INSERT INTO fines (borrow_record_id, user_id, amount, overdue_days, "
                   + "reason, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, 'UNPAID', NOW(), NOW())";
        try (PreparedStatement ps = getConn().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, borrowRecordId);
            ps.setInt(2, userId);
            ps.setBigDecimal(3, amount);
            ps.setInt(4, overdueDays);
            ps.setString(5, reason);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ================================================================
    // READ
    // ================================================================

    /** Lấy fine theo id. */
    public Fine getById(int id) {
        String sql = buildBaseSelect() + " WHERE f.id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Lấy danh sách fines theo borrow_record_id. */
    public List<Fine> getByBorrowRecordId(int borrowRecordId) {
        List<Fine> list = new ArrayList<>();
        String sql = buildBaseSelect() + " WHERE f.borrow_record_id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lấy danh sách fines của một user (kèm thông tin sách). */
    public List<Fine> getByUserId(int userId) {
        List<Fine> list = new ArrayList<>();
        String sql = buildBaseSelect() + " WHERE f.user_id = ? ORDER BY f.created_at DESC";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lấy tất cả fines (Librarian / Admin xem). */
    public List<Fine> getAll(String statusFilter, String search, int page, int pageSize) {
        List<Fine> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(buildBaseSelect() + " WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append(" AND f.status = ?");
            params.add(statusFilter);
        }
        if (search != null && !search.trim().isEmpty()) {
            String like = "%" + search.trim() + "%";
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ? OR b.title LIKE ?)");
            params.add(like); params.add(like); params.add(like);
        }
        sql.append(" ORDER BY f.created_at DESC");
        if (pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add((page - 1) * pageSize);
        }

        try (PreparedStatement ps = getConn().prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================================================================
    // UPDATE
    // ================================================================

    /**
     * Librarian cập nhật trạng thái thanh toán fine.
     */
    public boolean updateFineStatus(int fineId, String status,
                                    String paymentMethod, String paymentNote) {
        String sql = "UPDATE fines SET status = ?, payment_method = ?, payment_note = ?, "
                   + "paid_date = ?, updated_at = NOW() WHERE id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, paymentMethod);
            ps.setString(3, paymentNote);
            ps.setDate(4, "PAID".equals(status) ? Date.valueOf(LocalDate.now()) : null);
            ps.setInt(5, fineId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // Business Logic Helper
    // ================================================================

    /**
     * Tính số ngày trễ hạn và tiền phạt.
     * @param dueDate    Ngày hạn trả
     * @param returnDate Ngày thực tế trả
     * @return mảng [overdueDays, fineAmount] hoặc [0, 0] nếu không trễ
     */
    public static Object[] calculateFine(LocalDate dueDate, LocalDate returnDate) {
        if (dueDate == null || returnDate == null || !returnDate.isAfter(dueDate)) {
            return new Object[]{0, BigDecimal.ZERO};
        }
        long days = java.time.temporal.ChronoUnit.DAYS.between(dueDate, returnDate);
        BigDecimal amount = FINE_RATE_PER_DAY.multiply(new BigDecimal(days));
        return new Object[]{(int) days, amount};
    }

    // ================================================================
    // Helpers
    // ================================================================

    private String buildBaseSelect() {
        return "SELECT f.*, "
             + " u.username, u.full_name, u.student_id, "
             + " br.borrow_date, br.due_date, br.return_date, br.status AS record_status, "
             + " b.title AS book_title, b.isbn "
             + " FROM fines f"
             + " LEFT JOIN users u           ON f.user_id           = u.id"
             + " LEFT JOIN borrow_records br ON f.borrow_record_id   = br.id"
             + " LEFT JOIN books b           ON br.book_id           = b.id";
    }

    private Fine mapRow(ResultSet rs) throws SQLException {
        Fine f = new Fine();
        f.setId(rs.getInt("id"));
        f.setBorrowRecordId(rs.getInt("borrow_record_id"));
        f.setUserId(rs.getInt("user_id"));
        f.setAmount(rs.getBigDecimal("amount"));
        f.setOverdueDays(rs.getInt("overdue_days"));
        f.setReason(rs.getString("reason"));
        f.setStatus(rs.getString("status"));
        f.setPaymentMethod(rs.getString("payment_method"));
        f.setPaymentNote(rs.getString("payment_note"));

        Date paidDate = rs.getDate("paid_date");
        if (paidDate != null) f.setPaidDate(paidDate.toLocalDate());

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) f.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) f.setUpdatedAt(updatedAt.toLocalDateTime());

        // Embedded user
        User user = new User();
        user.setId(rs.getInt("user_id"));
        try {
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setStudentId(rs.getString("student_id"));
        } catch (SQLException ignored) {}
        f.setUser(user);

        // Embedded borrow record (lightweight)
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getInt("borrow_record_id"));
        try {
            Date bDate = rs.getDate("borrow_date");
            if (bDate != null) br.setBorrowDate(bDate.toLocalDate());
            Date dDate = rs.getDate("due_date");
            if (dDate != null) br.setDueDate(dDate.toLocalDate());
            Date rDate = rs.getDate("return_date");
            if (rDate != null) br.setReturnDate(rDate.toLocalDate());
            br.setStatus(rs.getString("record_status"));
            // Book title
            Book book = new Book();
            book.setTitle(rs.getString("book_title"));
            book.setIsbn(rs.getString("isbn"));
            br.setBook(book);
        } catch (SQLException ignored) {}
        f.setBorrowRecord(br);

        return f;
    }
}
