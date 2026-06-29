package com.swp391.servlet;

import com.swp391.dao.NotificationDAO;
import com.swp391.dao.NotificationDAOImpl;
import com.swp391.model.Notification;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servlet xử lý module Thông báo.
 * Spec: library-rules-spec-v2.md §3, §4.2
 *
 * URL patterns:
 *   GET  /notification/my      — User: xem thông báo của mình
 *   GET  /notification/manage  — Librarian/Admin: quản lý thông báo
 *   POST /notification/publish — Librarian/Admin: tạo & gửi thông báo
 *   POST /notification/mark-read — User: đánh dấu đã đọc
 *   POST /notification/mark-all-read — User: đánh dấu tất cả đã đọc
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {
    "/notification/my", "/notification/manage",
    "/notification/publish", "/notification/mark-read", "/notification/mark-all-read"
})
public class NotificationServlet extends HttpServlet {

    private static final int PAGE_SIZE = 20;
    private final NotificationDAO notifDAO = new NotificationDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            switch (request.getServletPath()) {
                case "/notification/manage":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    showManage(request, response, loggedUser);
                    break;
                case "/notification/my":
                default:
                    showMyNotifications(request, response, loggedUser);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            switch (request.getServletPath()) {
                case "/notification/publish":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    processPublish(request, response, loggedUser);
                    break;
                case "/notification/mark-read":
                    processMarkRead(request, response, loggedUser);
                    break;
                case "/notification/mark-all-read":
                    processMarkAllRead(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/notification/my");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    // -------------------------------------------------------------------------
    // Handlers
    // -------------------------------------------------------------------------

    /** User: xem thông báo của mình */
    private void showMyNotifications(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        int page = parseIntOrDefault(req.getParameter("page"), 1);
        List<Notification> notifications = notifDAO.getByUser(loggedUser.getId(), page, PAGE_SIZE);
        int unread = notifDAO.countUnread(loggedUser.getId());
        req.setAttribute("notifications", notifications);
        req.setAttribute("unreadCount", unread);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageTitle", "Thông báo của tôi");
        req.setAttribute("activePage", "notifications");
        req.getRequestDispatcher("/notification_list.jsp").forward(req, resp);
    }

    /** Librarian/Admin: quản lý thông báo */
    private void showManage(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        String type = req.getParameter("type");
        int page = parseIntOrDefault(req.getParameter("page"), 1);
        List<Notification> notifications = notifDAO.getAll(type, page, PAGE_SIZE);
        int total = notifDAO.countAll(type);
        req.setAttribute("notifications", notifications);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("type", type);
        req.setAttribute("pageTitle", "Quản lý Thông báo");
        req.setAttribute("activePage", "notifications");
        req.getRequestDispatcher("/notification_manage.jsp").forward(req, resp);
    }

    /**
     * §3.2 Librarian/Admin: gửi thông báo thủ công.
     * Nếu targetUserIds để trống → gửi tất cả active users.
     */
    private void processPublish(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        String title = req.getParameter("title");
        String message = req.getParameter("message");
        String type = req.getParameter("type");
        String targetIdsStr = req.getParameter("targetUserIds"); // comma-separated, empty = all

        if (title == null || title.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/notification/manage?error=missing_fields");
            return;
        }

        List<Integer> targetIds = null;
        if (targetIdsStr != null && !targetIdsStr.trim().isEmpty()) {
            try {
                targetIds = Arrays.stream(targetIdsStr.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .map(Integer::parseInt)
                        .collect(Collectors.toList());
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/notification/manage?error=invalid_target_ids");
                return;
            }
        }

        int sent = notifDAO.publish(title.trim(), message.trim(), type != null ? type : "SYSTEM", targetIds);
        resp.sendRedirect(req.getContextPath() + "/notification/manage?success=published&count=" + sent);
    }

    /** User: đánh dấu một thông báo đã đọc */
    private void processMarkRead(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int notifId = parseIntOrDefault(req.getParameter("notificationId"), 0);
        if (notifId > 0) notifDAO.markRead(notifId, loggedUser.getId());
        String referer = req.getHeader("Referer");
        resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/notification/my");
    }

    /** User: đánh dấu tất cả đã đọc */
    private void processMarkAllRead(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        notifDAO.markAllRead(loggedUser.getId());
        resp.sendRedirect(req.getContextPath() + "/notification/my?success=all_read");
    }

    private int parseIntOrDefault(String val, int def) {
        if (val == null || val.isEmpty()) return def;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return def; }
    }
}
