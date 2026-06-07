package dao;

import Context.DBContext;
import model.Book;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BookDAOImpl implements BookDAO {
    @Override
    public Book create(Book book) throws Exception {
        String sql = "INSERT INTO books (isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setInt(3, book.getCategoryId());
            if (book.getSubjectId() > 0) {
                ps.setInt(4, book.getSubjectId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            if (book.getPublisherId() > 0) {
                ps.setInt(5, book.getPublisherId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            if (book.getPublishYear() > 0) {
                ps.setInt(6, book.getPublishYear());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setString(7, book.getDescription());
            ps.setString(8, book.getCoverImage());
            ps.setBigDecimal(9, book.getPrice());
            ps.setInt(10, book.getTotalCopies());
            ps.setTimestamp(11, book.getCreatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(book.getCreatedAt()));
            ps.setTimestamp(12, book.getUpdatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(book.getUpdatedAt()));
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    book.setId(rs.getInt(1));
                    return book;
                }
            }
        }
        return null;
    }

    @Override
    public Book findById(int id) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBook(rs);
                }
            }
        }
        return null;
    }

    @Override
    public Book findByIsbn(String isbn) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE isbn = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, isbn);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBook(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Book> findAll() throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books ORDER BY title";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToBook(rs));
                }
            }
        }
        return list;
    }

    @Override
    public List<Book> findByCategoryId(int categoryId) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE category_id = ? ORDER BY title";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToBook(rs));
                }
            }
        }
        return list;
    }

    @Override
    public List<Book> findBySubjectId(int subjectId) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE subject_id = ? ORDER BY title";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToBook(rs));
                }
            }
        }
        return list;
    }

    @Override
    public List<Book> findByPublisherId(int publisherId) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE publisher_id = ? ORDER BY title";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, publisherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToBook(rs));
                }
            }
        }
        return list;
    }

    @Override
    public List<Book> findByTitle(String title) throws Exception {
        String sql = "SELECT id, isbn, title, category_id, subject_id, publisher_id, publish_year, description, cover_image, price, total_copies, created_at, updated_at FROM books WHERE LOWER(title) LIKE LOWER(?) ORDER BY title";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + title + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToBook(rs));
                }
            }
        }
        return list;
    }

    @Override
    public boolean update(Book book) throws Exception {
        String sql = "UPDATE books SET isbn = ?, title = ?, category_id = ?, subject_id = ?, publisher_id = ?, publish_year = ?, description = ?, cover_image = ?, price = ?, total_copies = ?, updated_at = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setInt(3, book.getCategoryId());
            if (book.getSubjectId() > 0) {
                ps.setInt(4, book.getSubjectId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            if (book.getPublisherId() > 0) {
                ps.setInt(5, book.getPublisherId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            if (book.getPublishYear() > 0) {
                ps.setInt(6, book.getPublishYear());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setString(7, book.getDescription());
            ps.setString(8, book.getCoverImage());
            ps.setBigDecimal(9, book.getPrice());
            ps.setInt(10, book.getTotalCopies());
            ps.setTimestamp(11, book.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(book.getUpdatedAt()));
            ps.setInt(12, book.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM books WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Book mapResultSetToBook(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getInt("id"));
        b.setIsbn(rs.getString("isbn"));
        b.setTitle(rs.getString("title"));
        b.setCategoryId(rs.getInt("category_id"));
        int subjectId = rs.getInt("subject_id");
        b.setSubjectId(rs.wasNull() ? 0 : subjectId);
        int publisherId = rs.getInt("publisher_id");
        b.setPublisherId(rs.wasNull() ? 0 : publisherId);
        int publishYear = rs.getInt("publish_year");
        b.setPublishYear(rs.wasNull() ? 0 : publishYear);
        b.setDescription(rs.getString("description"));
        b.setCoverImage(rs.getString("cover_image"));
        b.setPrice(rs.getBigDecimal("price"));
        b.setTotalCopies(rs.getInt("total_copies"));
        Timestamp t1 = rs.getTimestamp("created_at");
        if (t1 != null) b.setCreatedAt(t1.toLocalDateTime());
        Timestamp t2 = rs.getTimestamp("updated_at");
        if (t2 != null) b.setUpdatedAt(t2.toLocalDateTime());
        return b;
    }
}

