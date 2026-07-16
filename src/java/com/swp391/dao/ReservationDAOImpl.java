package com.swp391.dao;

import com.swp391.model.Book;
import com.swp391.model.ReservationRecord;
import com.swp391.model.User;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Triển khai ReservationDAO — đặt trước sách theo spec §1.1, §1.3, §4.2.
 */
public class ReservationDAOImpl implements ReservationDAO {

    @Override
    public ReservationRecord create(int userId, int bookId) throws Exception {
        String sql = "INSERT INTO book_reservations (user_id, book_id, status, reserve_date, created_at, updated_at) "
                + "VALUES (?, ?, 'PENDING', NOW(), NOW(), NOW())";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return findById(rs.getInt(1));
                    }
                }
            }
        }
        return null;
    }

    @Override
    public boolean confirm(int reservationId, String performedBy) throws Exception {
        String sql = "UPDATE book_reservations SET status = 'READY', notified_at = NOW(), updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean cancel(int reservationId, String performedBy) throws Exception {
        String sql = "UPDATE book_reservations SET status = 'CANCELLED', updated_at = NOW() "
                + "WHERE id = ? AND status IN ('PENDING','READY')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public int countPendingReservations(int bookId) throws Exception {
        String sql = "SELECT COUNT(*) FROM book_reservations WHERE book_id = ? AND status IN ('PENDING','READY')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public boolean completeByUserAndBook(int userId, int bookId) throws Exception {
        String sql = "UPDATE book_reservations SET status = 'COMPLETED', updated_at = NOW() "
                + "WHERE user_id = ? AND book_id = ? AND status IN ('PENDING', 'READY')";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public ReservationRecord findById(int id) throws Exception {
        String sql = "SELECT rr.*, u.full_name, u.username, b.title AS book_title "
                + "FROM book_reservations rr "
                + "LEFT JOIN users u ON u.id = rr.user_id "
                + "LEFT JOIN books b ON b.id = rr.book_id "
                + "WHERE rr.id = ?";
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
    public List<ReservationRecord> getByUser(int userId) throws Exception {
        String sql = "SELECT rr.*, u.full_name, u.username, b.title AS book_title "
                + "FROM book_reservations rr "
                + "LEFT JOIN users u ON u.id = rr.user_id "
                + "LEFT JOIN books b ON b.id = rr.book_id "
                + "WHERE rr.user_id = ? ORDER BY rr.created_at DESC";
        List<ReservationRecord> list = new ArrayList<>();
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
    public List<ReservationRecord> getAll(String status, String keyword, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT rr.*, u.full_name, u.username, b.title AS book_title "
                + "FROM book_reservations rr "
                + "LEFT JOIN users u ON u.id = rr.user_id "
                + "LEFT JOIN books b ON b.id = rr.book_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND rr.status = ?"); params.add(status); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.username LIKE ? OR b.title LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        sql.append(" ORDER BY rr.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        List<ReservationRecord> list = new ArrayList<>();
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
    public int countAll(String status, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM book_reservations rr "
                + "LEFT JOIN users u ON u.id = rr.user_id "
                + "LEFT JOIN books b ON b.id = rr.book_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) { sql.append(" AND rr.status = ?"); params.add(status); }
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
    // Helper
    // -------------------------------------------------------------------------

    private ReservationRecord mapRow(ResultSet rs) throws SQLException {
        ReservationRecord r = new ReservationRecord();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setBookId(rs.getInt("book_id"));
        r.setStatus(rs.getString("status"));
        Timestamp reserveDate = rs.getTimestamp("reserve_date");
        if (reserveDate != null) r.setReserveDate(reserveDate.toLocalDateTime());
        Timestamp expiryDate = rs.getTimestamp("expiry_date");
        if (expiryDate != null) r.setExpiryDate(expiryDate.toLocalDateTime());
        Timestamp notifiedAt = rs.getTimestamp("notified_at");
        if (notifiedAt != null) r.setNotifiedAt(notifiedAt.toLocalDateTime());
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
            r.setUser(user);
        } catch (SQLException ignored) {}

        // Join: book info
        try {
            Book book = new Book();
            book.setId(rs.getInt("book_id"));
            book.setTitle(rs.getString("book_title"));
            r.setBook(book);
        } catch (SQLException ignored) {}

        return r;
    }
}
