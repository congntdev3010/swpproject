package com.swp391.dao;

import com.swp391.model.Author;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AuthorDAOImpl implements AuthorDAO {

    private static final Set<String> ALLOWED_SORT_FIELDS = new HashSet<>(
        Arrays.asList("name", "nationality", "birth_date", "created_at")
    );

    @Override
    public Author create(Author author) throws Exception {
        String sql = "INSERT INTO authors (name, nationality, birth_date, bio, avatar_url, created_by, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, author.getName());
            ps.setString(2, author.getNationality());
            ps.setDate(3, author.getBirthDate() == null ? null : java.sql.Date.valueOf(author.getBirthDate()));
            ps.setString(4, author.getBio());
            ps.setString(5, author.getAvatarUrl());
            ps.setString(6, author.getCreatedBy());
            ps.setTimestamp(7, author.getCreatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(author.getCreatedAt()));
            ps.setTimestamp(8, author.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(author.getUpdatedAt()));
            
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    author.setId(rs.getInt(1));
                    return author;
                }
            }
        }
        return null;
    }

    @Override
    public Author findById(int id) throws Exception {
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at, is_deleted, created_by, updated_by "
                   + "FROM authors WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAuthor(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Author> findAll() throws Exception {
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at, is_deleted, created_by, updated_by "
                   + "FROM authors WHERE is_deleted = 0 ORDER BY name";
        List<Author> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAuthor(rs));
                }
            }
        }
        return list;
    }

    @Override
    public Author findByName(String name) throws Exception {
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at, is_deleted, created_by, updated_by "
                   + "FROM authors WHERE name = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAuthor(rs);
                }
            }
        }
        return null;
    }

    @Override
    public boolean update(Author author) throws Exception {
        String sql = "UPDATE authors SET name = ?, nationality = ?, birth_date = ?, bio = ?, avatar_url = ?, updated_by = ?, updated_at = ? "
                   + "WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, author.getName());
            ps.setString(2, author.getNationality());
            ps.setDate(3, author.getBirthDate() == null ? null : java.sql.Date.valueOf(author.getBirthDate()));
            ps.setString(4, author.getBio());
            ps.setString(5, author.getAvatarUrl());
            ps.setString(6, author.getUpdatedBy());
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(8, author.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id, String deletedBy) throws Exception {
        if (hasActiveBooks(id)) {
            throw new IllegalStateException("Cannot delete author: they are still associated with active books.");
        }
        String sql = "UPDATE authors SET is_deleted = 1, updated_by = ?, updated_at = ? WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, deletedBy);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public List<Author> search(String keyword, String sortField, String sortOrder, int page, int pageSize) throws Exception {
        String safeSort = ALLOWED_SORT_FIELDS.contains(sortField) ? sortField : "name";
        String safeOrder = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder(
            "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at, is_deleted, created_by, updated_by "
          + "FROM authors WHERE is_deleted = 0 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE LOWER(?) OR LOWER(nationality) LIKE LOWER(?) OR LOWER(bio) LIKE LOWER(?)) ");
            String matchStr = "%" + keyword.trim() + "%";
            params.add(matchStr);
            params.add(matchStr);
            params.add(matchStr);
        }

        sql.append("ORDER BY ").append(safeSort).append(" ").append(safeOrder).append(" ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<Author> list = new ArrayList<>();
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
                    list.add(mapResultSetToAuthor(rs));
                }
            }
        }
        return list;
    }

    @Override
    public int count(String keyword) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM authors WHERE is_deleted = 0 ");
        List<String> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(name) LIKE LOWER(?) OR LOWER(nationality) LIKE LOWER(?) OR LOWER(bio) LIKE LOWER(?)) ");
            String matchStr = "%" + keyword.trim() + "%";
            params.add(matchStr);
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
        String sql = "SELECT COUNT(*) FROM authors WHERE LOWER(name) = LOWER(?) AND is_deleted = 0";
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
        String sql = "SELECT COUNT(*) FROM authors WHERE LOWER(name) = LOWER(?) AND id != ? AND is_deleted = 0";
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
    public boolean hasActiveBooks(int authorId) throws Exception {
        String sql = "SELECT COUNT(*) FROM book_authors ba JOIN books b ON ba.book_id = b.id "
                   + "WHERE ba.author_id = ? AND b.is_deleted = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, authorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    private Author mapResultSetToAuthor(ResultSet rs) throws SQLException {
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
        Timestamp t2 = rs.getTimestamp("updated_at");
        if (t2 != null) a.setUpdatedAt(t2.toLocalDateTime());
        a.setDeleted(rs.getInt("is_deleted") == 1);
        a.setCreatedBy(rs.getString("created_by"));
        a.setUpdatedBy(rs.getString("updated_by"));
        return a;
    }
}
