<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Notification, com.swp391.model.User, java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    int unreadCount = request.getAttribute("unreadCount") != null ? (int) request.getAttribute("unreadCount") : 0;
    String successMsg = request.getParameter("success");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-bell"></i> Thông báo
                </div>
                <h1 class="books-page-title">Thông báo của tôi</h1>
                <p class="books-page-subtitle">Nhận các cập nhật và thông báo mới nhất từ thư viện</p>
            </div>
            <div style="display:flex; align-items:center; gap:16px; flex-wrap:wrap;">
                <div class="books-page-stats">
                    <div class="bps-item">
                        <span class="bps-num"><%= unreadCount %></span>
                        <span class="bps-lbl">Chưa đọc</span>
                    </div>
                </div>
                <% if (unreadCount > 0) { %>
                <form method="post" action="<%= request.getContextPath() %>/notification/mark-all-read" style="margin:0;">
                    <button type="submit" class="btn btn-outline" style="font-weight:600; padding:10px 18px; border-radius:var(--radius-md);">
                        <i class="fa-solid fa-check-double"></i> Đánh dấu tất cả đã đọc
                    </button>
                </form>
                <% } %>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">
    <% if ("all_read".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Đã đánh dấu tất cả thông báo là đã đọc.
    </div>
    <% } %>

    <div style="display:flex;flex-direction:column;gap:0.8rem;">
    <% if (notifications == null || notifications.isEmpty()) { %>
    <div style="background:#fff;border-radius:12px;padding:3rem;text-align:center;box-shadow:0 2px 12px rgba(0,0,0,0.06);">
        <div style="font-size:3rem;margin-bottom:1rem;">🔔</div>
        <h3 style="color:#ccc;font-weight:500;">Bạn chưa có thông báo nào.</h3>
    </div>
    <% } else { for (Notification n : notifications) {
        String t = n.getType();
        String icon = "DUE_REMINDER".equals(t) ? "📅" : "BOOK_AVAILABLE".equals(t) ? "📚" :
                "RESERVATION_CONFIRMED".equals(t) ? "✅" : "FINE_ISSUED".equals(t) ? "💸" :
                "ACCOUNT_LOCKED".equals(t) ? "🔒" : "📢";
        String badgeColor = "DUE_REMINDER".equals(t) ? "#f0a500" : "FINE_ISSUED".equals(t) ? "#e94560" :
                "ACCOUNT_LOCKED".equals(t) ? "#c62a47" : "RESERVATION_CONFIRMED".equals(t) ? "#28a745" : "#667eea";
    %>
    <div style="background:#fff;border-radius:12px;padding:1.2rem 1.4rem;box-shadow:0 2px 8px rgba(0,0,0,0.05);
                border-left:4px solid <%= n.isIsRead() ? "#e0e0e0" : badgeColor %>;
                opacity:<%= n.isIsRead() ? "0.75" : "1" %>;">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:1rem;">
            <div style="display:flex;align-items:flex-start;gap:0.8rem;flex:1;">
                <span style="font-size:1.4rem;line-height:1.4;"><%= icon %></span>
                <div>
                    <div style="font-weight:700;color:#1a1a2e;margin-bottom:0.3rem;">
                        <%= n.getTitle() %>
                        <% if (!n.isIsRead()) { %>
                        <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#e94560;margin-left:6px;vertical-align:middle;"></span>
                        <% } %>
                    </div>
                    <div style="color:#555;font-size:0.9rem;line-height:1.5;"><%= n.getMessage() %></div>
                    <div style="color:#aaa;font-size:0.78rem;margin-top:0.4rem;">
                        <%= n.getCreatedAt() != null ? n.getCreatedAt().toLocalDate() : "" %>
                    </div>
                </div>
            </div>
            <% if (!n.isIsRead()) { %>
            <form method="post" action="<%= request.getContextPath() %>/notification/mark-read" style="flex-shrink:0;">
                <input type="hidden" name="notificationId" value="<%= n.getId() %>">
                <button type="submit" title="Đánh dấu đã đọc"
                        style="padding:0.3rem 0.7rem;background:#f0f4ff;border:1px solid #c5cef5;color:#667eea;border-radius:6px;cursor:pointer;font-size:0.78rem;white-space:nowrap;">
                    <i class="fa-solid fa-check"></i> Đọc rồi
                </button>
            </form>
            <% } %>
        </div>
    </div>
    <% } } %>
    </div>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
