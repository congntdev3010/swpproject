package com.swp391.dao;

import com.swp391.model.Notification;
import com.swp391.model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Triển khai NotificationDAO — quản lý thông báo theo spec §3.
 */
public class NotificationDAOImpl implements NotificationDAO {

    @Override
    public Notification sendAutoNotification(int userId, String type, String title, String message) throws Exception {
        String sql = "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES (?, ?, ?, ?, 0, NOW())";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return findById(rs.getInt(1));
                }
            }
        }
        return null;
    }

    @Override
    public Notification createDraft(String title, String message, String type, int creatorId) throws Exception {
        // Bản nháp không target user cụ thể (user_id = 0 = chưa gửi)
        String sql = "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES (0, ?, ?, ?, 0, NOW())";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title);
            ps.setString(2, message);
            ps.setString(3, type != null ? type : "SYSTEM");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return findById(rs.getInt(1));
            }
        }
        return null;
    }

    @Override
    public int publish(String title, String message, String type, List<Integer> targetUserIds) throws Exception {
        List<Integer> recipients = targetUserIds;
        if (recipients == null || recipients.isEmpty()) {
            // Gửi tất cả users đang active
            recipients = getAllActiveUserIds();
        }
        if (recipients.isEmpty()) return 0;

        String sql = "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES (?, ?, ?, ?, 0, NOW())";
        int count = 0;
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int uid : recipients) {
                ps.setInt(1, uid);
                ps.setString(2, title);
                ps.setString(3, message);
                ps.setString(4, type != null ? type : "SYSTEM");
                ps.addBatch();
                count++;
            }
            ps.executeBatch();
        }
        return count;
    }

    @Override
    public boolean markRead(int notificationId, int userId) throws Exception {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean markAllRead(int userId) throws Exception {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public Notification findById(int id) throws Exception {
        String sql = "SELECT n.*, u.full_name, u.username FROM notifications n LEFT JOIN users u ON u.id = n.user_id WHERE n.id = ?";
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
    public List<Notification> getByUser(int userId, int page, int pageSize) throws Exception {
        String sql = "SELECT n.*, u.full_name, u.username FROM notifications n "
                + "LEFT JOIN users u ON u.id = n.user_id "
                + "WHERE n.user_id = ? ORDER BY n.created_at DESC LIMIT ? OFFSET ?";
        List<Notification> list = new ArrayList<>();
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public int countUnread(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public List<Notification> getAll(String type, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT n.*, u.full_name, u.username FROM notifications n "
                + "LEFT JOIN users u ON u.id = n.user_id WHERE n.user_id > 0");
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isEmpty()) { sql.append(" AND n.type = ?"); params.add(type); }
        sql.append(" ORDER BY n.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        List<Notification> list = new ArrayList<>();
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
    public int countAll(String type) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM notifications WHERE user_id > 0");
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isEmpty()) { sql.append(" AND type = ?"); params.add(type); }
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
    // Helpers
    // -------------------------------------------------------------------------

    private List<Integer> getAllActiveUserIds() throws Exception {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT id FROM users WHERE active = 1";
        try (Connection con = DBContext.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) ids.add(rs.getInt("id"));
        }
        return ids;
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setIsRead(rs.getBoolean("is_read"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) n.setCreatedAt(createdAt.toLocalDateTime());
        // Join: user
        try {
            User user = new User();
            user.setId(rs.getInt("user_id"));
            user.setFullName(rs.getString("full_name"));
            user.setUsername(rs.getString("username"));
            n.setUser(user);
        } catch (SQLException ignored) {}
        return n;
    }
}
