package com.swp391.dao;

import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý toàn bộ nghiệp vụ mượn - trả sách.
 * Status workflow: PENDING → BORROWING | REJECTED
 *                 BORROWING → RETURNED
 */
public class BorrowDAO {

    private Connection getConn() throws ClassNotFoundException, SQLException {
        return DBContext.getInstance().getConnection();
    }

    // ================================================================
    // USER: Tạo phiếu mượn mới (status = PENDING)
    // ================================================================

    /**
     * Tạo nhiều bản ghi borrow_records với status PENDING từ danh sách bookId.
     * @return số bản ghi được tạo thành công
     */
    public int createPendingRequests(int userId, List<Integer> bookIds) {
        if (bookIds == null || bookIds.isEmpty()) return 0;
        String sql = "INSERT INTO borrow_records (user_id, book_id, borrow_date, due_date, status, note) "
                   + "VALUES (?, ?, NULL, NULL, 'PENDING', 'Đơn chờ thủ thư duyệt')";
        int count = 0;
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            for (int bookId : bookIds) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int r : results) if (r > 0) count++;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // ================================================================
    // ADMIN/LIBRARIAN: Lấy danh sách phiếu mượn
    // ================================================================

    /**
     * Lấy tất cả phiếu mượn theo status, kèm thông tin user và book.
     * @param status null = tất cả, hoặc "PENDING","BORROWING","RETURNED","REJECTED"
     */
    public List<BorrowRecord> getAllBorrows(String status) {
        List<BorrowRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT br.id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, "
          + "       br.return_date, br.renewal_count, br.status, br.note, "
          + "       u.username, u.full_name, u.email, u.student_id, "
          + "       b.title AS book_title, b.isbn AS book_isbn, b.available AS book_available, b.quantity AS book_quantity "
          + "FROM borrow_records br "
          + "JOIN users u ON br.user_id = u.id "
          + "JOIN books b ON br.book_id = b.id "
        );
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append("WHERE br.status = ? ");
            params.add(status);
        }
        sql.append("ORDER BY br.id DESC");

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
     * Đếm số phiếu PENDING (dùng cho badge trên header).
     */
    public int countPending() {
        String sql = "SELECT COUNT(*) FROM borrow_records WHERE status = 'PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy lịch sử mượn của một user cụ thể.
     */
    public List<BorrowRecord> getBorrowsByUser(int userId) {
        List<BorrowRecord> list = new ArrayList<>();
        String sql = "SELECT br.id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, "
                   + "       br.return_date, br.renewal_count, br.status, br.note, "
                   + "       u.username, u.full_name, u.email, u.student_id, "
                   + "       b.title AS book_title, b.isbn AS book_isbn, b.available AS book_available, b.quantity AS book_quantity "
                   + "FROM borrow_records br "
                   + "JOIN users u ON br.user_id = u.id "
                   + "JOIN books b ON br.book_id = b.id "
                   + "WHERE br.user_id = ? "
                   + "ORDER BY br.id DESC";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================================================================
    // ADMIN/LIBRARIAN: Duyệt / Từ chối / Trả sách
    // ================================================================

    /**
     * Duyệt phiếu mượn: PENDING → BORROWING
     * Giảm available trong bảng books, cập nhật book_copies nếu có copy_id.
     * @return true nếu thành công
     */
    public boolean approveRequest(int borrowId) {
        try {
            Connection conn = getConn();
            // 1. Lấy thông tin phiếu
            BorrowRecord br = findById(borrowId);
            if (br == null || !"PENDING".equals(br.getStatus())) return false;

            // 2. Kiểm tra còn sách không
            String checkSql = "SELECT available FROM books WHERE id = ?";
            int available = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, br.getBookId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) available = rs.getInt("available");
            }
            if (available <= 0) return false; // Hết sách

            // 3. Tìm bản sao AVAILABLE để gán
            Integer copyId = findAvailableCopy(br.getBookId());

            // 4. Cập nhật phiếu mượn
            LocalDate today = LocalDate.now();
            LocalDate dueDate = today.plusDays(14);
            String updateSql = "UPDATE borrow_records SET status='BORROWING', borrow_date=?, due_date=?, copy_id=? WHERE id=? AND status='PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setDate(1, java.sql.Date.valueOf(today));
                ps.setDate(2, java.sql.Date.valueOf(dueDate));
                if (copyId != null) ps.setInt(3, copyId); else ps.setNull(3, Types.INTEGER);
                ps.setInt(4, borrowId);
                int rows = ps.executeUpdate();
                if (rows == 0) return false;
            }

            // 5. Giảm available trong books
            String updateBook = "UPDATE books SET available = available - 1 WHERE id = ? AND available > 0";
            try (PreparedStatement ps = conn.prepareStatement(updateBook)) {
                ps.setInt(1, br.getBookId());
                ps.executeUpdate();
            }

            // 6. Đánh dấu copy là BORROWED nếu có
            if (copyId != null) {
                String updateCopy = "UPDATE book_copies SET status='BORROWED' WHERE id=?";
                try (PreparedStatement ps = conn.prepareStatement(updateCopy)) {
                    ps.setInt(1, copyId);
                    ps.executeUpdate();
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Từ chối phiếu mượn: PENDING → REJECTED
     */
    public boolean rejectRequest(int borrowId) {
        String sql = "UPDATE borrow_records SET status='REJECTED' WHERE id=? AND status='PENDING'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, borrowId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xác nhận trả sách: BORROWING → RETURNED
     * Tăng available trong books, cập nhật condition của book_copies.
     * @param borrowId ID phiếu mượn
     * @param bookCondition tình trạng sách khi trả (GOOD/WORN/DAMAGED/LOST)
     */
    public boolean returnBook(int borrowId, String bookCondition) {
        try {
            Connection conn = getConn();
            BorrowRecord br = findById(borrowId);
            if (br == null || !"BORROWING".equals(br.getStatus())) return false;

            // 1. Cập nhật phiếu mượn thành RETURNED
            String updateSql = "UPDATE borrow_records SET status='RETURNED', return_date=? WHERE id=? AND status='BORROWING'";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setDate(1, java.sql.Date.valueOf(LocalDate.now()));
                ps.setInt(2, borrowId);
                int rows = ps.executeUpdate();
                if (rows == 0) return false;
            }

            // 2. Tăng available trong books
            String updateBook = "UPDATE books SET available = available + 1 WHERE id = ? AND available < quantity";
            try (PreparedStatement ps = conn.prepareStatement(updateBook)) {
                ps.setInt(1, br.getBookId());
                ps.executeUpdate();
            }

            // 3. Cập nhật trạng thái bản sao
            if (br.getCopyId() != null) {
                String newStatus = "LOST".equalsIgnoreCase(bookCondition) ? "LOST" : "AVAILABLE";
                String updateCopy = "UPDATE book_copies SET status=?, book_condition=? WHERE id=?";
                try (PreparedStatement ps = conn.prepareStatement(updateCopy)) {
                    ps.setString(1, newStatus);
                    ps.setString(2, bookCondition != null ? bookCondition.toUpperCase() : "GOOD");
                    ps.setInt(3, br.getCopyId());
                    ps.executeUpdate();
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // Helpers
    // ================================================================

    public BorrowRecord findById(int id) {
        String sql = "SELECT br.id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, "
                   + "       br.return_date, br.renewal_count, br.status, br.note, "
                   + "       u.username, u.full_name, u.email, u.student_id, "
                   + "       b.title AS book_title, b.isbn AS book_isbn, b.available AS book_available, b.quantity AS book_quantity "
                   + "FROM borrow_records br "
                   + "JOIN users u ON br.user_id = u.id "
                   + "JOIN books b ON br.book_id = b.id "
                   + "WHERE br.id = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Integer findAvailableCopy(int bookId) {
        String sql = "SELECT id FROM book_copies WHERE book_id=? AND status='AVAILABLE' LIMIT 1";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private BorrowRecord mapRow(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getInt("id"));
        br.setUserId(rs.getInt("user_id"));
        br.setBookId(rs.getInt("book_id"));
        int copyIdVal = rs.getInt("copy_id");
        br.setCopyId(rs.wasNull() ? null : copyIdVal);

        java.sql.Date borrowDate = rs.getDate("borrow_date");
        if (borrowDate != null) br.setBorrowDate(borrowDate.toLocalDate());
        java.sql.Date dueDate = rs.getDate("due_date");
        if (dueDate != null) br.setDueDate(dueDate.toLocalDate());
        java.sql.Date returnDate = rs.getDate("return_date");
        if (returnDate != null) br.setReturnDate(returnDate.toLocalDate());

        br.setRenewalCount(rs.getInt("renewal_count"));
        br.setStatus(rs.getString("status"));
        br.setNote(rs.getString("note"));

        // Không load created_at, updated_at vì bảng ko có

        // Nhúng User
        User u = new User();
        u.setId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setStudentId(rs.getString("student_id"));
        br.setUser(u);

        // Nhúng Book
        Book b = new Book();
        b.setId(rs.getInt("book_id"));
        b.setTitle(rs.getString("book_title"));
        b.setIsbn(rs.getString("book_isbn"));
        b.setAvailable(rs.getInt("book_available"));
        b.setQuantity(rs.getInt("book_quantity"));
        br.setBook(b);

        return br;
    }
}
