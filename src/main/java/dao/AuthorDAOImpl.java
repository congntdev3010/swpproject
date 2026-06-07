package dao;

import Context.DBContext;
import model.Author;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AuthorDAOImpl implements AuthorDAO {
    @Override
    public Author create(Author author) throws Exception {
        String sql = "INSERT INTO authors (name, nationality, birth_date, bio, avatar_url, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, author.getName());
            ps.setString(2, author.getNationality());
            ps.setDate(3, author.getBirthDate() == null ? null : java.sql.Date.valueOf(author.getBirthDate()));
            ps.setString(4, author.getBio());
            ps.setString(5, author.getAvatarUrl());
            ps.setTimestamp(6, author.getCreatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(author.getCreatedAt()));
            ps.setTimestamp(7, author.getUpdatedAt() == null ? new Timestamp(System.currentTimeMillis()) : Timestamp.valueOf(author.getUpdatedAt()));
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
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at FROM authors WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at FROM authors ORDER BY name";
        List<Author> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
        String sql = "SELECT id, name, nationality, birth_date, bio, avatar_url, created_at, updated_at FROM authors WHERE name = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
        String sql = "UPDATE authors SET name = ?, nationality = ?, birth_date = ?, bio = ?, avatar_url = ?, updated_at = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, author.getName());
            ps.setString(2, author.getNationality());
            ps.setDate(3, author.getBirthDate() == null ? null : java.sql.Date.valueOf(author.getBirthDate()));
            ps.setString(4, author.getBio());
            ps.setString(5, author.getAvatarUrl());
            ps.setTimestamp(6, author.getUpdatedAt() == null ? Timestamp.valueOf(LocalDateTime.now()) : Timestamp.valueOf(author.getUpdatedAt()));
            ps.setInt(7, author.getId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(int id) throws Exception {
        String sql = "DELETE FROM authors WHERE id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
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
        return a;
    }
}

