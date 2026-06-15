package com.swp391.dao;

import com.swp391.model.Author;
import com.swp391.model.Book;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Implementation của BookDAO theo schema bảng books thực tế.
 *
 * Cột bảng books:
 *   id, isbn, title, category (VARCHAR), category_id (INT),
 *   publisher (VARCHAR), publish_year, price, quantity, available,
 *   description, cover_image, subject, area, shelf, slot,
 *   created_at, updated_at
 */
public class BookDAOImpl implements BookDAO {

    // Whitelist cột sort hợp lệ (tránh SQL injection)
    private static final Set<String> ALLOWED_SORT_FIELDS = new HashSet<>(
        Arrays.asList("title", "publish_year", "available", "price", "created_at")
    );

    // ============================================================
    //  getNewestBooks
    // ============================================================
    @Override
    public List<Book> getNewestBooks(int limit) throws Exception {
        String sql = "SELECT id, isbn, title, category, category_id, publisher, publish_year, "
                   + "price, quantity, available, description, cover_image, subject, "
                   + "area, shelf, slot, created_at, updated_at, is_deleted, created_by, updated_by "
                   + "FROM books "
                   + "WHERE is_deleted = 0 "
                   + "ORDER BY created_at DESC "
                   + "LIMIT ?";
        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ============================================================
    //  searchBooks
    // ============================================================
    @Override
    public List<Book> searchBooks(String keyword, String categoryFilter,
                                  String sortField, String sortOrder,
                                  int page, int pageSize) throws Exception {
        // Sanitize sort
        String safeSort = ALLOWED_SORT_FIELDS.contains(sortField) ? sortField : "title";
        String safeOrder = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder(
            "SELECT id, isbn, title, category, category_id, publisher, publish_year, "
          + "price, quantity, available, description, cover_image, subject, "
          + "area, shelf, slot, created_at, updated_at, is_deleted, created_by, updated_by "
          + "FROM books WHERE is_deleted = 0 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND LOWER(title) LIKE LOWER(?) ");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
            sql.append("AND category = ? ");
            params.add(categoryFilter.trim());
        }

        sql.append("ORDER BY ").append(safeSort).append(" ").append(safeOrder).append(" ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<Book> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ============================================================
    //  countBooks
    // ============================================================
    @Override
    public int countBooks(String keyword, String categoryFilter) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM books WHERE is_deleted = 0 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND LOWER(title) LIKE LOWER(?) ");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
            sql.append("AND category = ? ");
            params.add(categoryFilter.trim());
        }

        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ============================================================
    //  getAllCategories
    // ============================================================
    @Override
    public List<String> getAllCategories() throws Exception {
        String sql = "SELECT DISTINCT category FROM books WHERE category IS NOT NULL ORDER BY category";
        List<String> cats = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cat = rs.getString("category");
                if (cat != null && !cat.trim().isEmpty()) {
                    cats.add(cat.trim());
                }
            }
        }
        return cats;
    }

    // ============================================================
    //  findById
    // ============================================================
    @Override
    public Book findById(int id) throws Exception {
        String sql = "SELECT id, isbn, title, category, category_id, publisher, publish_year, "
                   + "price, quantity, available, description, cover_image, subject, "
                   + "area, shelf, slot, created_at, updated_at, is_deleted, created_by, updated_by "
                   + "FROM books WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ============================================================
    //  createBook
    // ============================================================
    @Override
    public int createBook(Book book) throws Exception {
        String sql = "INSERT INTO books (isbn, title, category, category_id, publisher, "
                   + "publish_year, price, quantity, available, description, cover_image, "
                   + "subject, area, shelf, slot, created_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setString(3, book.getCategory());
            if (book.getCategoryId() > 0) {
                ps.setInt(4, book.getCategoryId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, book.getPublisher());
            if (book.getPublishYear() != null) {
                ps.setInt(6, book.getPublishYear());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            if (book.getPrice() != null) {
                ps.setInt(7, book.getPrice());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setInt(8, book.getQuantity());
            ps.setInt(9, book.getAvailable());
            ps.setString(10, book.getDescription());
            ps.setString(11, book.getCoverImage());
            ps.setString(12, book.getSubject());
            ps.setString(13, book.getArea());
            ps.setString(14, book.getShelf());
            ps.setString(15, book.getSlot());
            ps.setString(16, book.getCreatedBy());

            int affected = ps.executeUpdate();
            if (affected == 0) return -1;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // ============================================================
    //  updateBook
    // ============================================================
    @Override
    public boolean updateBook(Book book) throws Exception {
        String sql = "UPDATE books SET isbn = ?, title = ?, category = ?, category_id = ?, "
                   + "publisher = ?, publish_year = ?, price = ?, quantity = ?, available = ?, "
                   + "description = ?, cover_image = ?, subject = ?, area = ?, shelf = ?, slot = ?, updated_by = ? "
                   + "WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setString(3, book.getCategory());
            if (book.getCategoryId() > 0) {
                ps.setInt(4, book.getCategoryId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, book.getPublisher());
            if (book.getPublishYear() != null) {
                ps.setInt(6, book.getPublishYear());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            if (book.getPrice() != null) {
                ps.setInt(7, book.getPrice());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setInt(8, book.getQuantity());
            ps.setInt(9, book.getAvailable());
            ps.setString(10, book.getDescription());
            ps.setString(11, book.getCoverImage());
            ps.setString(12, book.getSubject());
            ps.setString(13, book.getArea());
            ps.setString(14, book.getShelf());
            ps.setString(15, book.getSlot());
            ps.setString(16, book.getUpdatedBy());
            ps.setInt(17, book.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // ============================================================
    //  deleteBook — SOFT DELETE (blocked if active copies exist)
    // ============================================================
    @Override
    public boolean deleteBook(int id) throws Exception {
        // Kiểm tra còn bản sao vật lý chưa bị xóa không
        String checkSql = "SELECT COUNT(*) FROM book_copies WHERE book_id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(checkSql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new IllegalStateException(
                        "Cannot delete book: there are still active physical copies linked to this book."
                    );
                }
            }
        }

        // Soft delete: đánh dấu is_deleted=1 thay vì xóa vật lý
        String sql = "UPDATE books SET is_deleted = 1 WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ============================================================
    //  isIsbnExists
    // ============================================================
    @Override
    public boolean isIsbnExists(String isbn) throws Exception {
        String sql = "SELECT COUNT(*) FROM books WHERE isbn = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, isbn);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // ============================================================
    //  isIsbnExistsExcluding
    // ============================================================
    @Override
    public boolean isIsbnExistsExcluding(String isbn, int excludeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM books WHERE isbn = ? AND id != ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, isbn);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // ============================================================
    //  hasPhysicalCopies
    // ============================================================
    @Override
    public boolean hasPhysicalCopies(int bookId) throws Exception {
        // Chỉ đếm bản sao chưa bị soft-delete
        String sql = "SELECT COUNT(*) FROM book_copies WHERE book_id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // ============================================================
    //  hasActiveBorrowsOrReservations
    // ============================================================
    @Override
    public boolean hasActiveBorrowsOrReservations(int bookId) throws Exception {
        String sql = "SELECT "
                   + "(SELECT COUNT(*) FROM borrow_records WHERE book_id = ? AND status IN ('BORROWING','OVERDUE')) + "
                   + "(SELECT COUNT(*) FROM book_reservations WHERE book_id = ? AND status IN ('PENDING','READY')) "
                   + "AS total";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total") > 0;
            }
        }
        return false;
    }

    // ============================================================
    //  getAuthorsByBookId
    // ============================================================
    @Override
    public List<Author> getAuthorsByBookId(int bookId) throws Exception {
        String sql = "SELECT a.id, a.name, a.nationality, a.birth_date, a.bio, a.avatar_url, a.created_at "
                   + "FROM authors a "
                   + "INNER JOIN book_authors ba ON a.id = ba.author_id "
                   + "WHERE ba.book_id = ? "
                   + "ORDER BY ba.role, a.name";
        List<Author> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Author a = new Author();
                    a.setId(rs.getInt("id"));
                    a.setName(rs.getString("name"));
                    a.setNationality(rs.getString("nationality"));
                    java.sql.Date sqlDate = rs.getDate("birth_date");
                    if (sqlDate != null) a.setBirthDate(sqlDate.toLocalDate());
                    a.setBio(rs.getString("bio"));
                    a.setAvatarUrl(rs.getString("avatar_url"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) a.setCreatedAt(t1.toLocalDateTime());
                    list.add(a);
                }
            }
        }
        return list;
    }

    // ============================================================
    //  getAuthorIdsByBookId
    // ============================================================
    @Override
    public List<Integer> getAuthorIdsByBookId(int bookId) throws Exception {
        String sql = "SELECT author_id FROM book_authors WHERE book_id = ?";
        List<Integer> ids = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("author_id"));
                }
            }
        }
        return ids;
    }

    // ============================================================
    //  setBookAuthors
    // ============================================================
    @Override
    public void setBookAuthors(int bookId, List<Integer> authorIds) throws Exception {
        // Xóa tất cả liên kết cũ
        String deleteSql = "DELETE FROM book_authors WHERE book_id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(deleteSql)) {
            ps.setInt(1, bookId);
            ps.executeUpdate();
        }

        // Thêm liên kết mới
        if (authorIds != null && !authorIds.isEmpty()) {
            String insertSql = "INSERT INTO book_authors (book_id, author_id, role) VALUES (?, ?, 'PRIMARY')";
            try (Connection con = DBContext.getInstance().getConnection();
                 PreparedStatement ps = con.prepareStatement(insertSql)) {
                for (Integer authorId : authorIds) {
                    ps.setInt(1, bookId);
                    ps.setInt(2, authorId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }
    }

    // ============================================================
    //  Private helpers
    // ============================================================

    /**
     * Map một ResultSet row sang đối tượng Book.
     */
    private Book mapRow(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getInt("id"));
        b.setIsbn(rs.getString("isbn"));
        b.setTitle(rs.getString("title"));
        b.setCategory(rs.getString("category"));

        int catId = rs.getInt("category_id");
        b.setCategoryId(rs.wasNull() ? 0 : catId);

        b.setPublisher(rs.getString("publisher"));

        int year = rs.getInt("publish_year");
        b.setPublishYear(rs.wasNull() ? null : year);

        int price = rs.getInt("price");
        b.setPrice(rs.wasNull() ? null : price);

        b.setQuantity(rs.getInt("quantity"));
        b.setAvailable(rs.getInt("available"));
        b.setDescription(rs.getString("description"));
        b.setCoverImage(rs.getString("cover_image"));
        b.setSubject(rs.getString("subject"));
        b.setArea(rs.getString("area"));
        b.setShelf(rs.getString("shelf"));
        b.setSlot(rs.getString("slot"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        b.setUpdatedAt(rs.getTimestamp("updated_at"));
        b.setDeleted(rs.getInt("is_deleted") == 1);
        b.setCreatedBy(rs.getString("created_by"));
        b.setUpdatedBy(rs.getString("updated_by"));
        return b;
    }

    /**
     * Bind danh sách params vào PreparedStatement theo thứ tự.
     */
    private void setParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof String)  ps.setString(i + 1, (String) p);
            else if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
            else ps.setObject(i + 1, p);
        }
    }
}

