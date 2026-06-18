package com.swp391.dao;

import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Triển khai BorrowDAO — xử lý nghiệp vụ mượn sách theo spec §1.
 */
public class BorrowDAOImpl implements BorrowDAO {

    private static final int DEFAULT_BORROW_DAYS = 14;
    private static final int OVERDUE_FINE_PER_DAY = 5000; // VND

    // -------------------------------------------------------------------------
    // §1.1 Kiểm tra ngưỡng mượn
    // -------------------------------------------------------------------------

    @Override
    public int countActiveBorrowsAndReservations(int userId) throws Exception {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM borrow_records WHERE user_id = ? AND status IN ('BORROWING','OVERDUE')) "
                + "+ "
                + "(SELECT COUNT(*) FROM reservation_records WHERE user_id = ? AND status IN ('PENDING','READY')) "
                + "AS total";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total");
            }
        }
        return 0;
    }

    @Override
    public int getMaxBorrowLimit(int userId) throws Exception {
        // Lấy giới hạn mượn theo hạng membership của user
        String sql = "SELECT COALESCE(mt.max_simultaneous_borrows, 5) AS max_limit "
                + "FROM users u "
                + "LEFT JOIN membership_tiers mt ON mt.id = u.tier_id "
                + "WHERE u.id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("max_limit");
            }
        }
        return 5; // default
    }

    // -------------------------------------------------------------------------
    // §1.4 Kiểm tra điều kiện gia hạn
    // -------------------------------------------------------------------------

    @Override
    public boolean canRenew(int borrowRecordId) throws Exception {
        String sql = "SELECT br.book_id, "
                + "(SELECT COUNT(*) FROM book_copy bc WHERE bc.book_id = br.book_id AND bc.status = 'AVAILABLE') AS available_copies, "
                + "(SELECT COUNT(*) FROM reservation_records rr WHERE rr.book_id = br.book_id AND rr.status IN ('PENDING','READY')) AS pending_reservations "
                + "FROM borrow_records br WHERE br.id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int availableCopies = rs.getInt("available_copies");
                    int pendingReservations = rs.getInt("pending_reservations");
                    // §1.4: available_copies > 0 AND pending_reservations <= available_copies
                    return availableCopies > 0 && pendingReservations <= availableCopies;
                }
            }
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // CRUD
    // -------------------------------------------------------------------------

    @Override
    public BorrowRecord createBorrow(BorrowRecord record) throws Exception {
        String sql = "INSERT INTO borrow_records (user_id, book_id, copy_id, borrow_date, due_date, renewal_count, status, note, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, 0, 'BORROWING', ?, NOW(), NOW())";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, record.getUserId());
            ps.setInt(2, record.getBookId());
            if (record.getCopyId() != null) ps.setInt(3, record.getCopyId());
            else ps.setNull(3, Types.INTEGER);
            ps.setDate(4, Date.valueOf(record.getBorrowDate() != null ? record.getBorrowDate() : LocalDate.now()));
            ps.setDate(5, Date.valueOf(record.getDueDate() != null ? record.getDueDate() : LocalDate.now().plusDays(DEFAULT_BORROW_DAYS)));
            ps.setString(6, record.getNote());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        record.setId(rs.getInt(1));
                        record.setStatus("BORROWING");
                        return record;
                    }
                }
            }
        }
        return null;
    }

    @Override
    public boolean renewBorrow(int borrowRecordId, String performedBy) throws Exception {
        String sql = "UPDATE borrow_records SET due_date = DATE_ADD(due_date, INTERVAL 14 DAY), "
                + "renewal_count = renewal_count + 1, status = 'BORROWING', updated_at = NOW() "
                + "WHERE id = ? AND status IN ('BORROWING','OVERDUE')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, borrowRecordId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean returnBook(int borrowRecordId, String performedBy) throws Exception {
        Connection con = DBContext.getInstance().getConnection();
        try {
            con.setAutoCommit(false);
            // 1. Lấy thông tin phiếu mượn
            BorrowRecord record = findByIdWithConnection(borrowRecordId, con);
            if (record == null) { con.rollback(); return false; }

            // 2. Cập nhật trạng thái phiếu mượn
            String updateRecord = "UPDATE borrow_records SET return_date = CURDATE(), status = 'RETURNED', updated_at = NOW() WHERE id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateRecord)) {
                ps.setInt(1, borrowRecordId);
                ps.executeUpdate();
            }

            // 3. Cập nhật trạng thái bản sao sách (nếu có copy_id)
            if (record.getCopyId() != null) {
                String updateCopy = "UPDATE book_copy SET status = 'AVAILABLE', updated_at = NOW() WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(updateCopy)) {
                    ps.setInt(1, record.getCopyId());
                    ps.executeUpdate();
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    @Override
    public BorrowRecord findById(int id) throws Exception {
        return findByIdWithConnection(id, DBContext.getInstance().getConnection());
    }

    private BorrowRecord findByIdWithConnection(int id, Connection con) throws Exception {
        String sql = "SELECT br.*, u.full_name, u.username, u.email, "
                + "b.title AS book_title, bc.barcode "
                + "FROM borrow_records br "
                + "LEFT JOIN users u ON u.id = br.user_id "
                + "LEFT JOIN books b ON b.id = br.book_id "
                + "LEFT JOIN book_copy bc ON bc.id = br.copy_id "
                + "WHERE br.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    @Override
    public List<BorrowRecord> getActiveBorrowsByUser(int userId) throws Exception {
        String sql = "SELECT br.*, u.full_name, u.username, u.email, "
                + "b.title AS book_title, bc.barcode "
                + "FROM borrow_records br "
                + "LEFT JOIN users u ON u.id = br.user_id "
                + "LEFT JOIN books b ON b.id = br.book_id "
                + "LEFT JOIN book_copy bc ON bc.id = br.copy_id "
                + "WHERE br.user_id = ? AND br.status IN ('BORROWING','OVERDUE') "
                + "ORDER BY br.due_date ASC";
        return queryList(sql, userId);
    }

    @Override
    public List<BorrowRecord> getAllBorrowsByUser(int userId) throws Exception {
        String sql = "SELECT br.*, u.full_name, u.username, u.email, "
                + "b.title AS book_title, bc.barcode "
                + "FROM borrow_records br "
                + "LEFT JOIN users u ON u.id = br.user_id "
                + "LEFT JOIN books b ON b.id = br.book_id "
                + "LEFT JOIN book_copy bc ON bc.id = br.copy_id "
                + "WHERE br.user_id = ? ORDER BY br.created_at DESC";
        return queryList(sql, userId);
    }

    @Override
    public List<BorrowRecord> getAllBorrows(String status, String keyword, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT br.*, u.full_name, u.username, u.email, "
                + "b.title AS book_title, bc.barcode "
                + "FROM borrow_records br "
                + "LEFT JOIN users u ON u.id = br.user_id "
                + "LEFT JOIN books b ON b.id = br.book_id "
                + "LEFT JOIN book_copy bc ON bc.id = br.copy_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND br.status = ?"); params.add(status); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ? OR b.title LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        sql.append(" ORDER BY br.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        return queryWithParams(sql.toString(), params);
    }

    @Override
    public int countAllBorrows(String status, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM borrow_records br LEFT JOIN users u ON u.id = br.user_id LEFT JOIN books b ON b.id = br.book_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND br.status = ?"); params.add(status); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ? OR b.title LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
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

    private List<BorrowRecord> queryList(String sql, int userId) throws Exception {
        List<BorrowRecord> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private List<BorrowRecord> queryWithParams(String sql, List<Object> params) throws Exception {
        List<BorrowRecord> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private BorrowRecord mapRow(ResultSet rs) throws SQLException {
        BorrowRecord r = new BorrowRecord();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setBookId(rs.getInt("book_id"));
        int copyId = rs.getInt("copy_id");
        r.setCopyId(rs.wasNull() ? null : copyId);
        Date borrowDate = rs.getDate("borrow_date");
        if (borrowDate != null) r.setBorrowDate(borrowDate.toLocalDate());
        Date dueDate = rs.getDate("due_date");
        if (dueDate != null) r.setDueDate(dueDate.toLocalDate());
        Date returnDate = rs.getDate("return_date");
        if (returnDate != null) r.setReturnDate(returnDate.toLocalDate());
        r.setRenewalCount(rs.getInt("renewal_count"));
        r.setStatus(rs.getString("status"));
        r.setNote(rs.getString("note"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) r.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) r.setUpdatedAt(updatedAt.toLocalDateTime());

        // Join: user info
        try {
            User user = new User();
            user.setId(rs.getInt("user_id"));
            user.setFullName(rs.getString("full_name"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            r.setUser(user);
        } catch (SQLException ignored) {}

        // Join: book info
        try {
            Book book = new Book();
            book.setId(rs.getInt("book_id"));
            book.setTitle(rs.getString("book_title"));
            r.setBook(book);
        } catch (SQLException ignored) {}

        // Join: copy info
        try {
            if (r.getCopyId() != null) {
                BookCopy copy = new BookCopy();
                copy.setId(r.getCopyId());
                copy.setBarcode(rs.getString("barcode"));
                r.setBookCopy(copy);
            }
        } catch (SQLException ignored) {}

        return r;
    }
}
