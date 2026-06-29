<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Notification, com.swp391.model.User, java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    int total = request.getAttribute("total") != null ? (int) request.getAttribute("total") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String typeFilter = (String) request.getAttribute("type");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    String sentCount = request.getParameter("count");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="page-hero" style="background:linear-gradient(135deg,#0d1117 0%,#1c2951 50%,#283593 100%);padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#4facfe,#00f2fe);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">📢</div>
            <div>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;">Quản lý Thông báo</h1>
                <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;">Soạn & gửi thông báo đến người dùng</p>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">
    <!-- Alerts -->
    <% if ("published".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i>
        Đã gửi thành công đến <strong><%= sentCount != null ? sentCount : "?" %></strong> người dùng!
    </div>
    <% } else if (errorMsg != null) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-xmark"></i> Lỗi: <%= errorMsg %>
    </div>
    <% } %>

    <!-- Compose Panel -->
    <div style="background:#fff;border-radius:12px;padding:1.5rem;box-shadow:0 2px 12px rgba(0,0,0,0.06);margin-bottom:2rem;">
        <h2 style="font-size:1rem;font-weight:700;margin-bottom:1.2rem;color:#1a1a2e;">
            <i class="fa-solid fa-paper-plane" style="color:#4facfe;"></i> Soạn thông báo mới
        </h2>
        <form method="post" action="<%= request.getContextPath() %>/notification/publish">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1rem;">
                <div>
                    <label style="display:block;font-weight:600;margin-bottom:0.4rem;font-size:0.9rem;">Tiêu đề *</label>
                    <input type="text" name="title" required placeholder="Nhập tiêu đề thông báo..."
                           style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                </div>
                <div>
                    <label style="display:block;font-weight:600;margin-bottom:0.4rem;font-size:0.9rem;">Loại thông báo</label>
                    <select name="type" style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                        <option value="SYSTEM">📢 Hệ thống</option>
                        <option value="DUE_REMINDER">📅 Nhắc hạn trả</option>
                        <option value="BOOK_AVAILABLE">📚 Sách có sẵn</option>
                        <option value="FINE_ISSUED">💸 Phát sinh phạt</option>
                    </select>
                </div>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;font-size:0.9rem;">Nội dung *</label>
                <textarea name="message" required rows="3" placeholder="Nhập nội dung thông báo..."
                          style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;resize:vertical;box-sizing:border-box;font-family:inherit;"></textarea>
            </div>
            <div style="display:flex;align-items:flex-end;gap:1rem;">
                <div style="flex:1;">
                    <label style="display:block;font-weight:600;margin-bottom:0.4rem;font-size:0.9rem;">
                        ID người nhận (phân cách bằng dấu phẩy)
                        <span style="font-weight:400;color:#aaa;">— để trống = gửi tất cả</span>
                    </label>
                    <input type="text" name="targetUserIds" placeholder="Vd: 1,2,5 hoặc để trống gửi tất cả..."
                           style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                </div>
                <button type="submit"
                        style="padding:0.65rem 1.5rem;background:linear-gradient(135deg,#4facfe,#00f2fe);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:700;white-space:nowrap;">
                    <i class="fa-solid fa-paper-plane"></i> Gửi ngay
                </button>
            </div>
        </form>
    </div>

    <!-- Filter + Table -->
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:0.8rem;">
        <h2 style="font-size:1rem;font-weight:700;margin:0;color:#1a1a2e;">
            Lịch sử thông báo đã gửi (<%= total %> tổng)
        </h2>
        <form method="get" action="<%= request.getContextPath() %>/notification/manage" style="display:flex;gap:0.5rem;">
            <select name="type" style="padding:0.4rem 0.7rem;border:1px solid #ddd;border-radius:8px;font-size:0.88rem;">
                <option value="">Tất cả loại</option>
                <option value="SYSTEM" <%= "SYSTEM".equals(typeFilter) ? "selected" : "" %>>Hệ thống</option>
                <option value="DUE_REMINDER" <%= "DUE_REMINDER".equals(typeFilter) ? "selected" : "" %>>Nhắc hạn</option>
                <option value="FINE_ISSUED" <%= "FINE_ISSUED".equals(typeFilter) ? "selected" : "" %>>Phạt</option>
                <option value="RESERVATION_CONFIRMED" <%= "RESERVATION_CONFIRMED".equals(typeFilter) ? "selected" : "" %>>Đặt trước</option>
                <option value="ACCOUNT_LOCKED" <%= "ACCOUNT_LOCKED".equals(typeFilter) ? "selected" : "" %>>Khóa TK</option>
            </select>
            <button type="submit" style="padding:0.4rem 0.8rem;background:#e8eaf6;border:1px solid #c5cef5;border-radius:8px;color:#333;cursor:pointer;font-size:0.88rem;">
                <i class="fa-solid fa-filter"></i> Lọc
            </button>
        </form>
    </div>

    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:linear-gradient(135deg,#0d1117,#1c2951);color:#fff;">
                <tr>
                    <th style="padding:0.9rem 0.8rem;text-align:left;font-weight:600;">Người nhận</th>
                    <th style="padding:0.9rem 0.8rem;text-align:left;font-weight:600;">Tiêu đề</th>
                    <th style="padding:0.9rem 0.8rem;text-align:left;font-weight:600;">Loại</th>
                    <th style="padding:0.9rem 0.8rem;text-align:left;font-weight:600;">Đã đọc</th>
                    <th style="padding:0.9rem 0.8rem;text-align:left;font-weight:600;">Ngày gửi</th>
                </tr>
            </thead>
            <tbody>
            <% if (notifications == null || notifications.isEmpty()) { %>
            <tr>
                <td colspan="5" style="padding:3rem;text-align:center;color:#aaa;">
                    Chưa có thông báo nào được gửi.
                </td>
            </tr>
            <% } else { for (Notification n : notifications) {
                String t = n.getType();
            %>
            <tr style="border-bottom:1px solid #f5f5f5;">
                <td style="padding:0.8rem;">
                    <div style="font-weight:600;font-size:0.9rem;"><%= n.getUser() != null ? n.getUser().getFullName() : "N/A" %></div>
                    <div style="color:#aaa;font-size:0.78rem;"><%= n.getUser() != null ? n.getUser().getUsername() : "" %></div>
                </td>
                <td style="padding:0.8rem;max-width:260px;">
                    <div style="font-weight:600;font-size:0.9rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= n.getTitle() %></div>
                    <div style="color:#888;font-size:0.78rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= n.getMessage() %></div>
                </td>
                <td style="padding:0.8rem;">
                    <span style="padding:0.2rem 0.6rem;border-radius:20px;font-size:0.75rem;font-weight:600;background:#e8eaf6;color:#3949ab;">
                        <%= "DUE_REMINDER".equals(t) ? "📅 Nhắc hạn" : "FINE_ISSUED".equals(t) ? "💸 Phạt" :
                            "RESERVATION_CONFIRMED".equals(t) ? "✅ Đặt trước" : "ACCOUNT_LOCKED".equals(t) ? "🔒 Khóa TK" : "📢 Hệ thống" %>
                    </span>
                </td>
                <td style="padding:0.8rem;">
                    <% if (n.isIsRead()) { %>
                    <span style="color:#28a745;font-size:0.85rem;"><i class="fa-solid fa-check"></i> Đã đọc</span>
                    <% } else { %>
                    <span style="color:#f0a500;font-size:0.85rem;"><i class="fa-solid fa-clock"></i> Chưa đọc</span>
                    <% } %>
                </td>
                <td style="padding:0.8rem;color:#888;font-size:0.85rem;"><%= n.getCreatedAt() != null ? n.getCreatedAt().toLocalDate() : "-" %></td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <% if (totalPages > 1) { %>
    <div style="display:flex;justify-content:center;gap:0.4rem;margin-top:1.5rem;">
        <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="?page=<%= i %>&type=<%= typeFilter != null ? typeFilter : "" %>"
           style="padding:0.4rem 0.8rem;border-radius:6px;text-decoration:none;border:1px solid #ddd;
                  background:<%= i == currentPage ? "linear-gradient(135deg,#4facfe,#00f2fe)" : "#fff" %>;
                  color:<%= i == currentPage ? "#fff" : "#333" %>;">
            <%= i %>
        </a>
        <% } %>
    </div>
    <% } %>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
