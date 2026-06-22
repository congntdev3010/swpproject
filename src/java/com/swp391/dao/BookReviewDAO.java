package com.swp391.dao;

import com.swp391.model.BookReview;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookReviewDAO {

    

    // Lấy tất cả review của 1 đầu sách (kèm tên user)
    public List<BookReview> getReviewsByBookId(int bookId) {
        List<BookReview> list = new ArrayList<>();
        String sql = "SELECT br.id, br.book_id, br.user_id, br.rating, br.comment, "
                + "br.created_at, br.updated_at, "
                + "u.full_name, u.student_id "
                + "FROM book_reviews br "
                + "JOIN users u ON br.user_id = u.id "
                + "WHERE br.book_id = ? "
                + "ORDER BY br.created_at DESC";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookReview r = new BookReview();
                r.setId(rs.getInt("id"));
                r.setBookId(rs.getInt("book_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setRating(rs.getInt("rating"));
                r.setComment(rs.getString("comment"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUpdatedAt(rs.getTimestamp("updated_at"));
                r.setUserFullName(rs.getString("full_name"));
                r.setUserStudentId(rs.getString("student_id"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tính rating trung bình của 1 đầu sách
    public double getAverageRating(int bookId) {
        String sql = "SELECT AVG(rating) FROM book_reviews WHERE book_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy review của 1 user cho 1 đầu sách (kiểm tra đã review chưa)
    public BookReview getReviewByBookAndUser(int bookId, int userId) {
        String sql = "SELECT br.id, br.book_id, br.user_id, br.rating, br.comment, "
                + "br.created_at, br.updated_at, "
                + "u.full_name, u.student_id "
                + "FROM book_reviews br "
                + "JOIN users u ON br.user_id = u.id "
                + "WHERE br.book_id = ? AND br.user_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BookReview r = new BookReview();
                r.setId(rs.getInt("id"));
                r.setBookId(rs.getInt("book_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setRating(rs.getInt("rating"));
                r.setComment(rs.getString("comment"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUpdatedAt(rs.getTimestamp("updated_at"));
                r.setUserFullName(rs.getString("full_name"));
                r.setUserStudentId(rs.getString("student_id"));
                return r;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Kiểm tra user đã trả sách này chưa (điều kiện được phép review)
    // *** Cần xác nhận tên cột join trong borrow_records trước khi dùng hàm này ***
    public boolean hasReturnedBook(int bookId, int userId) {
    String sql = "SELECT COUNT(*) FROM borrow_records "
            + "WHERE book_id = ? AND user_id = ? AND status = 'RETURNED'";
    try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, bookId);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

    // Thêm review mới
    public boolean addReview(int bookId, int userId, int rating, String comment) {
        String sql = "INSERT INTO book_reviews (book_id, user_id, rating, comment) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật review
    public boolean updateReview(int reviewId, int userId, int rating, String comment) {
        String sql = "UPDATE book_reviews SET rating = ?, comment = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rating);
            ps.setString(2, comment);
            ps.setInt(3, reviewId);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa review
    public boolean deleteReview(int reviewId, int userId) {
        String sql = "DELETE FROM book_reviews WHERE id = ? AND user_id = ?";
        try (Connection conn = DBContext.getInstance().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
