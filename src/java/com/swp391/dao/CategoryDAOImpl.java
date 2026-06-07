package com.swp391.dao;

import com.swp391.model.Category;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAOImpl implements CategoryDAO {
    @Override
    public Category create(Category category) throws Exception {
        String sql = "INSERT INTO categories (name, description, created_at, updated_at) VALUES (?, ?, ?, ?)";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setTimestamp(3, category.getCreatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(category.getCreatedAt()));
            ps.setTimestamp(4, category.getUpdatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(category.getUpdatedAt()));
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
        String sql = "SELECT id, name, description, created_at, updated_at FROM categories WHERE id = ?";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category c = new Category();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setDescription(rs.getString("description"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) c.setCreatedAt(t1.toLocalDateTime());
                    Timestamp t2 = rs.getTimestamp("updated_at");
                    if (t2 != null) c.setUpdatedAt(t2.toLocalDateTime());
                    return c;
                }
            }
        }
        return null;
    }

    @Override
    public List<Category> findAll() throws Exception {
        String sql = "SELECT id, name, description, created_at, updated_at FROM categories ORDER BY name";
        List<Category> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setDescription(rs.getString("description"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) c.setCreatedAt(t1.toLocalDateTime());
                    Timestamp t2 = rs.getTimestamp("updated_at");
                    if (t2 != null) c.setUpdatedAt(t2.toLocalDateTime());
                    list.add(c);
                }
            }
        }
        return list;
    }

    @Override
    public boolean update(Category category) throws Exception {
        String sql = "UPDATE categories SET name = ?, description = ?, updated_at = ? WHERE id = ?";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setTimestamp(3, category.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(category.getUpdatedAt()));
            ps.setInt(4, category.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM categories WHERE id = ?";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
