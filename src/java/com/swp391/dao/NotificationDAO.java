package com.swp391.dao;

import com.swp391.model.Notification;
import java.util.List;

/**
 * DAO interface cho module Thông báo.
 * Spec: library-rules-spec-v2.md §3
 */
public interface NotificationDAO {

    /** §3.1 Gửi thông báo tự động đến một user */
    Notification sendAutoNotification(int userId, String type, String title, String message) throws Exception;

    /** §3.2 Admin/Librarian tạo thông báo thủ công (bản nháp) */
    Notification createDraft(String title, String message, String type, int creatorId) throws Exception;

    /**
     * §3.2 Gửi thông báo thủ công đến danh sách user.
     * targetUserIds: danh sách userId; nếu null → gửi tất cả users
     */
    int publish(String title, String message, String type, List<Integer> targetUserIds) throws Exception;

    /** Đánh dấu đã đọc */
    boolean markRead(int notificationId, int userId) throws Exception;

    /** Đánh dấu tất cả đã đọc cho một user */
    boolean markAllRead(int userId) throws Exception;

    /** Lấy thông báo theo ID */
    Notification findById(int id) throws Exception;

    /** Lấy danh sách thông báo của user (mới nhất trước) */
    List<Notification> getByUser(int userId, int page, int pageSize) throws Exception;

    /** Đếm số thông báo chưa đọc của user */
    int countUnread(int userId) throws Exception;

    /** Admin/Librarian: lấy tất cả thông báo (quản lý) */
    List<Notification> getAll(String type, int page, int pageSize) throws Exception;

    /** Đếm tổng thông báo cho phân trang */
    int countAll(String type) throws Exception;
}
