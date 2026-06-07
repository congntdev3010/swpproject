package dao;

import Context.DBContext;
import model.Subject;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAOImpl implements SubjectDAO {
    @Override
    public Subject create(Subject subject) throws Exception {
        String sql = "INSERT INTO subjects (category_id, name, description, created_at, updated_at) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, subject.getCategoryId());
            ps.setString(2, subject.getName());
            ps.setString(3, subject.getDescription());
            ps.setTimestamp(4, subject.getCreatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(subject.getCreatedAt()));
            ps.setTimestamp(5, subject.getUpdatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(subject.getUpdatedAt()));
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    subject.setId(rs.getInt(1));
                    return subject;
                }
            }
        }
        return null;
    }

    @Override
    public Subject findById(int id) throws Exception {
        String sql = "SELECT id, category_id, name, description, created_at, updated_at FROM subjects WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Subject s = new Subject();
                    s.setId(rs.getInt("id"));
                    s.setCategoryId(rs.getInt("category_id"));
                    s.setName(rs.getString("name"));
                    s.setDescription(rs.getString("description"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) s.setCreatedAt(t1.toLocalDateTime());
                    Timestamp t2 = rs.getTimestamp("updated_at");
                    if (t2 != null) s.setUpdatedAt(t2.toLocalDateTime());
                    return s;
                }
            }
        }
        return null;
    }

    @Override
    public List<Subject> findAll() throws Exception {
        String sql = "SELECT id, category_id, name, description, created_at, updated_at FROM subjects ORDER BY category_id, name";
        List<Subject> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Subject s = new Subject();
                    s.setId(rs.getInt("id"));
                    s.setCategoryId(rs.getInt("category_id"));
                    s.setName(rs.getString("name"));
                    s.setDescription(rs.getString("description"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) s.setCreatedAt(t1.toLocalDateTime());
                    Timestamp t2 = rs.getTimestamp("updated_at");
                    if (t2 != null) s.setUpdatedAt(t2.toLocalDateTime());
                    list.add(s);
                }
            }
        }
        return list;
    }

    @Override
    public List<Subject> findByCategoryId(int categoryId) throws Exception {
        String sql = "SELECT id, category_id, name, description, created_at, updated_at FROM subjects WHERE category_id = ? ORDER BY name";
        List<Subject> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Subject s = new Subject();
                    s.setId(rs.getInt("id"));
                    s.setCategoryId(rs.getInt("category_id"));
                    s.setName(rs.getString("name"));
                    s.setDescription(rs.getString("description"));
                    Timestamp t1 = rs.getTimestamp("created_at");
                    if (t1 != null) s.setCreatedAt(t1.toLocalDateTime());
                    Timestamp t2 = rs.getTimestamp("updated_at");
                    if (t2 != null) s.setUpdatedAt(t2.toLocalDateTime());
                    list.add(s);
                }
            }
        }
        return list;
    }

    @Override
    public boolean update(Subject subject) throws Exception {
        String sql = "UPDATE subjects SET category_id = ?, name = ?, description = ?, updated_at = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, subject.getCategoryId());
            ps.setString(2, subject.getName());
            ps.setString(3, subject.getDescription());
            ps.setTimestamp(4, subject.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(subject.getUpdatedAt()));
            ps.setInt(5, subject.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM subjects WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}

