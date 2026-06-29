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

<div class="page-hero" style="background:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f2460 100%);padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem;">
            <div style="display:flex;align-items:center;gap:1rem;">
                <div style="position:relative;width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#667eea,#764ba2);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">
                    🔔
                    <% if (unreadCount > 0) { %>
                    <span style="position:absolute;top:-6px;right:-6px;background:#e94560;color:#fff;border-radius:50%;width:20px;height:20px;font-size:0.7rem;display:flex;align-items:center;justify-content:center;font-weight:700;"><%= unreadCount > 9 ? "9+" : unreadCount %></span>
                    <% } %>
                </div>
                <div>
                    <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;">Thông báo của tôi</h1>
                    <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;"><%= unreadCount %> chưa đọc</p>
                </div>
            </div>
            <% if (unreadCount > 0) { %>
            <form method="post" action="<%= request.getContextPath() %>/notification/mark-all-read">
                <button type="submit" style="padding:0.5rem 1.2rem;background:rgba(255,255,255,0.15);border:1px solid rgba(255,255,255,0.3);color:#fff;border-radius:8px;cursor:pointer;font-weight:500;">
                    <i class="fa-solid fa-check-double"></i> Đánh dấu tất cả đã đọc
                </button>
            </form>
            <% } %>
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
