package com.swp391.dao;

import com.swp391.model.Category;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class CategoryDAOImpl implements CategoryDAO {

    private static final Set<String> ALLOWED_SORT_FIELDS = new HashSet<>(
        Arrays.asList("name", "created_at")
    );

    @Override
    public Category create(Category category) throws Exception {
        String sql = "INSERT INTO categories (name, description, created_by, created_at, updated_at) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setString(3, category.getCreatedBy());
            ps.setTimestamp(4, category.getCreatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(category.getCreatedAt()));
            ps.setTimestamp(5, category.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(category.getUpdatedAt()));
            
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    category.setId(rs.getInt(1));
                    return category;
                }
            }
        }
        return null;
    }

    @Override
    public Category findById(int id) throws Exception {
        String sql = "SELECT id, name, description, created_at, updated_at, is_deleted, created_by, updated_by FROM categories WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Category> findAll() throws Exception {
        String sql = "SELECT id, name, description, created_at, updated_at, is_deleted, created_by, updated_by FROM categories WHERE is_deleted = 0 ORDER BY name";
        List<Category> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    @Override
    public boolean update(Category category) throws Exception {
        String sql = "UPDATE categories SET name = ?, description = ?, updated_by = ?, updated_at = ? WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setString(3, category.getUpdatedBy());
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(5, category.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id, String deletedBy) throws Exception {
        if (hasActiveBooks(id)) {
            throw new IllegalStateException("Cannot delete category: it is still linked to active books.");
        }
        String sql = "UPDATE categories SET is_deleted = 1, updated_by = ?, updated_at = ? WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, deletedBy);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public List<Category> search(String keyword, String sortField, String sortOrder, int page, int pageSize) throws Exception {
        String safeSort = ALLOWED_SORT_FIELDS.contains(sortField) ? sortField : "name";
        String safeOrder = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder(
            "SELECT id, name, description, created_at, updated_at, is_deleted, created_by, updated_by "
          + "FROM categories WHERE is_deleted = 0 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)) ");
            String matchStr = "%" + keyword.trim() + "%";
            params.add(matchStr);
            params.add(matchStr);
        }

        sql.append("ORDER BY ").append(safeSort).append(" ").append(safeOrder).append(" ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<Category> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) ps.setString(i + 1, (String) p);
                else if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                else ps.setObject(i + 1, p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    @Override
    public int count(String keyword) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM categories WHERE is_deleted = 0 ");
        List<String> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)) ");
            String matchStr = "%" + keyword.trim() + "%";
            params.add(matchStr);
            params.add(matchStr);
        }

        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public boolean isNameExists(String name) throws Exception {
        String sql = "SELECT COUNT(*) FROM categories WHERE LOWER(name) = LOWER(?) AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    @Override
    public boolean isNameExistsExcluding(String name, int excludeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM categories WHERE LOWER(name) = LOWER(?) AND id != ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    @Override
    public boolean hasActiveBooks(int categoryId) throws Exception {
        String sql = "SELECT COUNT(*) FROM books WHERE category_id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    private Category mapRow(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setDescription(rs.getString("description"));
        Timestamp t1 = rs.getTimestamp("created_at");
        if (t1 != null) c.setCreatedAt(t1.toLocalDateTime());
        Timestamp t2 = rs.getTimestamp("updated_at");
        if (t2 != null) c.setUpdatedAt(t2.toLocalDateTime());
        c.setDeleted(rs.getInt("is_deleted") == 1);
        c.setCreatedBy(rs.getString("created_by"));
        c.setUpdatedBy(rs.getString("updated_by"));
        return c;
    }
}
