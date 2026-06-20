package com.swp391.dao;

import com.swp391.model.BorrowRecord;
import com.swp391.model.Fine;
import com.swp391.model.User;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * Triển khai FineDAO — tính phạt theo spec §2.
 *
 * §2.1 Overdue fine = days × 5,000 VND, trần = 30% giá gốc sách
 * §2.2 Nếu overdue_fine > 30% giá sách → DAMAGED + apply damage fine
 * §2.3 Damage fine = 70%, Lost fine = 100% giá gốc sách
 */
public class FineDAOImpl implements FineDAO {

    private static final int FINE_PER_DAY = 5000;
    private static final double OVERDUE_CAP_RATE = 0.30;
    private static final double DAMAGE_RATE = 0.70;
    private static final double LOST_RATE = 1.00;

    // -------------------------------------------------------------------------
    // §2.1 + §2.2 Tính phạt trễ hạn
    // -------------------------------------------------------------------------

    @Override
    public BigDecimal calculateOverdueFine(int borrowRecordId) throws Exception {
        // Lấy thông tin phiếu mượn và giá sách
        String sql = "SELECT br.due_date, br.return_date, br.status, br.copy_id, "
                + "bc.original_price, bc.id AS copy_id_val, br.book_id "
                + "FROM borrow_records br "
                + "LEFT JOIN book_copies bc ON bc.id = br.copy_id "
                + "WHERE br.id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return BigDecimal.ZERO;

                Date dueDateSql = rs.getDate("due_date");
                if (dueDateSql == null) return BigDecimal.ZERO;
                LocalDate dueDate = dueDateSql.toLocalDate();
                LocalDate now = LocalDate.now();
                if (!now.isAfter(dueDate)) return BigDecimal.ZERO; // chưa quá hạn

                long overdueDays = ChronoUnit.DAYS.between(dueDate, now);
                BigDecimal originalPrice = rs.getBigDecimal("original_price");
                if (originalPrice == null) originalPrice = BigDecimal.ZERO;

                BigDecimal rawFine = BigDecimal.valueOf(overdueDays * FINE_PER_DAY);
                BigDecimal fineCap = originalPrice.multiply(BigDecimal.valueOf(OVERDUE_CAP_RATE));

                // §2.2: vượt trần → đánh nhãn DAMAGED
                if (rawFine.compareTo(fineCap) > 0) {
                    int copyId = rs.getInt("copy_id_val");
                    if (!rs.wasNull() && copyId > 0) {
                        // Đánh dấu bản sao DAMAGED
                        String updateCopy = "UPDATE book_copies SET status = 'DAMAGED', updated_at = NOW() WHERE id = ?";
                        try (PreparedStatement ps2 = con.prepareStatement(updateCopy)) {
                            ps2.setInt(1, copyId);
                            ps2.executeUpdate();
                        }
                    }
                    // Trả về fine_cap (không tính quá mức)
                    return fineCap;
                }
                return rawFine;
            }
        }
    }

    // -------------------------------------------------------------------------
    // §2.3 Phạt hư hỏng / mất sách
    // -------------------------------------------------------------------------

    @Override
    public Fine applyDamageFine(int borrowRecordId, String performedBy) throws Exception {
        BigDecimal originalPrice = getOriginalPrice(borrowRecordId);
        BigDecimal fineAmount = originalPrice.multiply(BigDecimal.valueOf(DAMAGE_RATE));
        Fine fine = buildFine(borrowRecordId, fineAmount, 0, "DAMAGE");
        return createFine(fine);
    }

    @Override
    public Fine applyLostFine(int borrowRecordId, String performedBy) throws Exception {
        BigDecimal originalPrice = getOriginalPrice(borrowRecordId);
        BigDecimal fineAmount = originalPrice.multiply(BigDecimal.valueOf(LOST_RATE));
        Fine fine = buildFine(borrowRecordId, fineAmount, 0, "LOST");
        return createFine(fine);
    }

    @Override
    public Fine createFine(Fine fine) throws Exception {
        String sql = "INSERT INTO fines (borrow_record_id, user_id, amount, overdue_days, reason, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, 'UNPAID', NOW(), NOW())";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, fine.getBorrowRecordId());
            ps.setInt(2, fine.getUserId());
            ps.setBigDecimal(3, fine.getAmount());
            ps.setInt(4, fine.getOverdueDays());
            ps.setString(5, fine.getReason());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        fine.setId(rs.getInt(1));
                        fine.setStatus("UNPAID");
                        return fine;
                    }
                }
            }
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // Thanh toán & miễn giảm
    // -------------------------------------------------------------------------

    @Override
    public boolean waiveFine(int fineId, String adminUsername, String note) throws Exception {
        String sql = "UPDATE fines SET status = 'WAIVED', payment_note = ?, updated_at = NOW() WHERE id = ? AND status IN ('UNPAID','PENDING_VERIFY')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "[Waived by " + adminUsername + "] " + (note != null ? note : ""));
            ps.setInt(2, fineId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean markPaid(int fineId, String paymentMethod, String note) throws Exception {
        String sql = "UPDATE fines SET status = 'PAID', payment_method = ?, payment_note = ?, paid_date = CURDATE(), updated_at = NOW() "
                + "WHERE id = ? AND status IN ('UNPAID','PENDING_VERIFY')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, paymentMethod);
            ps.setString(2, note);
            ps.setInt(3, fineId);
            return ps.executeUpdate() > 0;
        }
    }

    // -------------------------------------------------------------------------
    // Queries
    // -------------------------------------------------------------------------

    @Override
    public Fine findById(int id) throws Exception {
        String sql = "SELECT f.*, u.full_name, u.username FROM fines f LEFT JOIN users u ON u.id = f.user_id WHERE f.id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    @Override
    public List<Fine> getFinesByUser(int userId) throws Exception {
        String sql = "SELECT f.*, u.full_name, u.username FROM fines f "
                + "LEFT JOIN users u ON u.id = f.user_id WHERE f.user_id = ? ORDER BY f.created_at DESC";
        List<Fine> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<Fine> getAllFines(String status, String keyword, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT f.*, u.full_name, u.username FROM fines f LEFT JOIN users u ON u.id = f.user_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND f.status = ?"); params.add(status); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        sql.append(" ORDER BY f.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        List<Fine> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public int countAllFines(String status, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM fines f LEFT JOIN users u ON u.id = f.user_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND f.status = ?"); params.add(status); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private BigDecimal getOriginalPrice(int borrowRecordId) throws Exception {
        String sql = "SELECT bc.original_price FROM borrow_records br "
                + "LEFT JOIN book_copies bc ON bc.id = br.copy_id WHERE br.id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal price = rs.getBigDecimal("original_price");
                    return price != null ? price : BigDecimal.ZERO;
                }
            }
        }
        return BigDecimal.ZERO;
    }

    private Fine buildFine(int borrowRecordId, BigDecimal amount, int overdueDays, String reason) throws Exception {
        // Lấy userId từ borrow record
        String sql = "SELECT user_id FROM borrow_records WHERE id = ?";
        int userId = 0;
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) userId = rs.getInt("user_id");
            }
        }
        return new Fine(borrowRecordId, userId, amount, overdueDays, reason, "UNPAID");
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
        // Join: user
        try {
            User user = new User();
            user.setId(rs.getInt("user_id"));
            user.setFullName(rs.getString("full_name"));
            user.setUsername(rs.getString("username"));
            f.setUser(user);
        } catch (SQLException ignored) {}
        return f;
    }
}
