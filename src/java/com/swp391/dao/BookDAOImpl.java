package com.swp391.dao;

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
                   + "area, shelf, slot, created_at, updated_at "
                   + "FROM books "
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
          + "area, shelf, slot, created_at, updated_at "
          + "FROM books WHERE 1=1 "
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
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM books WHERE 1=1 ");
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
                   + "area, shelf, slot, created_at, updated_at "
                   + "FROM books WHERE id = ?";
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
