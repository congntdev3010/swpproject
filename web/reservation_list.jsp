<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.ReservationRecord, com.swp391.model.User, java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    boolean isStaff = loggedUser.isAdminOrLibrarian();
    List<ReservationRecord> reservations = (List<ReservationRecord>) request.getAttribute("reservations");
    int activeCount = request.getAttribute("activeCount") != null ? (int) request.getAttribute("activeCount") : 0;
    int maxLimit = request.getAttribute("maxLimit") != null ? (int) request.getAttribute("maxLimit") : 5;
    int total = request.getAttribute("total") != null ? (int) request.getAttribute("total") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String statusFilter = (String) request.getAttribute("status");
    String keyword = (String) request.getAttribute("keyword");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="page-hero" style="background:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%);padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#f093fb,#f5576c);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">📌</div>
            <div>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;"><%= isStaff ? "Quản lý đặt trước sách" : "Phiếu đặt trước của tôi" %></h1>
                <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;">Đặt trước · Xác nhận · Hủy phiếu</p>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">
    <!-- Alerts -->
    <% if ("created".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Đặt trước thành công! Vui lòng chờ Thủ thư xác nhận.
    </div>
    <% } else if ("confirmed".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Phiếu đặt trước đã được xác nhận!
    </div>
    <% } else if ("cancelled".equals(successMsg)) { %>
    <div style="background:#fff3cd;border:1px solid #ffc107;color:#856404;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-ban"></i> Phiếu đặt trước đã được hủy.
    </div>
    <% } else if ("over_limit".equals(errorMsg)) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <strong>Không thể đặt trước:</strong> Bạn đã đạt giới hạn <%= maxLimit %> lượt mượn/đặt trước đồng thời (§1.1).
    </div>
    <% } else if (errorMsg != null) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-xmark"></i> Có lỗi xảy ra. Vui lòng thử lại.
    </div>
    <% } %>

    <!-- User: quota indicator + create form -->
    <% if (!isStaff) { %>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1.5rem;">
        <div style="background:#fff;border-radius:12px;padding:1.2rem;box-shadow:0 2px 12px rgba(0,0,0,0.06);border-left:4px solid <%= activeCount >= maxLimit ? "#e94560" : "#667eea" %>;">
            <div style="font-size:0.85rem;color:#888;">Đang mượn + Đặt trước / Giới hạn</div>
            <div style="font-size:1.8rem;font-weight:800;color:<%= activeCount >= maxLimit ? "#e94560" : "#1a1a2e" %>;"><%= activeCount %> / <%= maxLimit %></div>
        </div>
        <div style="background:#fff;border-radius:12px;padding:1.2rem;box-shadow:0 2px 12px rgba(0,0,0,0.06);">
            <div style="font-size:0.85rem;color:#888;margin-bottom:0.8rem;">Đặt trước sách mới</div>
            <form method="post" action="<%= request.getContextPath() %>/reservation/create" style="display:flex;gap:0.5rem;">
                <input type="number" name="bookId" placeholder="Nhập Book ID..." required
                       style="flex:1;padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                <button type="submit"
                        style="padding:0.5rem 1rem;background:linear-gradient(135deg,#667eea,#764ba2);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;white-space:nowrap;">
                    <i class="fa-solid fa-plus"></i> Đặt trước
                </button>
            </form>
        </div>
    </div>
    <% } else { %>
    <!-- Staff: filter toolbar -->
    <div style="display:flex;justify-content:space-between;flex-wrap:wrap;gap:1rem;margin-bottom:1.5rem;">
        <form method="get" action="<%= request.getContextPath() %>/reservation/list" style="display:flex;gap:0.6rem;flex-wrap:wrap;">
            <input type="text" name="keyword" placeholder="Tìm theo tên, sách..."
                   value="<%= keyword != null ? keyword : "" %>"
                   style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;min-width:200px;">
            <select name="status" style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                <option value="">Tất cả</option>
                <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Chờ duyệt</option>
                <option value="READY" <%= "READY".equals(statusFilter) ? "selected" : "" %>>Đã duyệt</option>
                <option value="COMPLETED" <%= "COMPLETED".equals(statusFilter) ? "selected" : "" %>>Hoàn thành</option>
                <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Đã hủy</option>
            </select>
            <button type="submit" style="padding:0.5rem 1rem;background:linear-gradient(135deg,#e94560,#c62a47);border:none;color:#fff;border-radius:8px;cursor:pointer;">
                <i class="fa-solid fa-magnifying-glass"></i> Tìm
            </button>
        </form>
    </div>
    <% } %>

    <!-- Table -->
    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:linear-gradient(135deg,#1a1a2e,#16213e);color:#fff;">
                <tr>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">ID</th>
                    <% if (isStaff) { %><th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Người đặt</th><% } %>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Sách</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Ngày đặt</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Trạng thái</th>
                    <th style="padding:1rem 0.8rem;text-align:center;font-weight:600;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
            <% if (reservations == null || reservations.isEmpty()) { %>
            <tr>
                <td colspan="<%= isStaff ? "6" : "5" %>" style="padding:3rem;text-align:center;color:#aaa;">
                    <i class="fa-solid fa-bookmark" style="font-size:2rem;display:block;margin-bottom:0.5rem;"></i>
                    Chưa có phiếu đặt trước nào.
                </td>
            </tr>
            <% } else { for (ReservationRecord r : reservations) {
                String st = r.getStatus();
            %>
            <tr style="border-bottom:1px solid #f5f5f5;" onmouseover="this.style.background='#fafafa'" onmouseout="this.style.background=''">
                <td style="padding:0.8rem;color:#666;">#<%= r.getId() %></td>
                <% if (isStaff) { %>
                <td style="padding:0.8rem;">
                    <div style="font-weight:600;"><%= r.getUser() != null ? r.getUser().getFullName() : "N/A" %></div>
                    <div style="font-size:0.8rem;color:#aaa;"><%= r.getUser() != null ? r.getUser().getUsername() : "" %></div>
                </td>
                <% } %>
                <td style="padding:0.8rem;font-weight:500;"><%= r.getBook() != null ? r.getBook().getTitle() : "N/A" %></td>
                <td style="padding:0.8rem;color:#666;"><%= r.getReserveDate() != null ? r.getReserveDate().toLocalDate() : "-" %></td>
                <td style="padding:0.8rem;">
                    <span style="padding:0.25rem 0.7rem;border-radius:20px;font-size:0.78rem;font-weight:600;
                        background:<%= "PENDING".equals(st) ? "#fff3cd" : "READY".equals(st) ? "#d4edda" : "COMPLETED".equals(st) ? "#e3f2fd" : "#f5f5f5" %>;
                        color:<%= "PENDING".equals(st) ? "#856404" : "READY".equals(st) ? "#155724" : "COMPLETED".equals(st) ? "#1565c0" : "#777" %>;">
                        <%= "PENDING".equals(st) ? "Chờ duyệt" : "READY".equals(st) ? "Đã duyệt" : "COMPLETED".equals(st) ? "Hoàn thành" : "Đã hủy" %>
                    </span>
                </td>
                <td style="padding:0.8rem;text-align:center;">
                    <div style="display:flex;gap:0.4rem;justify-content:center;">
                    <% if ("PENDING".equals(st) || "READY".equals(st)) { %>
                        <% if (isStaff && "PENDING".equals(st)) { %>
                        <form method="post" action="<%= request.getContextPath() %>/reservation/confirm">
                            <input type="hidden" name="reservationId" value="<%= r.getId() %>">
                            <button type="submit" style="padding:0.3rem 0.7rem;background:#28a745;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                <i class="fa-solid fa-check"></i> Duyệt
                            </button>
                        </form>
                        <% } %>
                        <form method="post" action="<%= request.getContextPath() %>/reservation/cancel"
                              onsubmit="return confirm('Xác nhận hủy phiếu đặt trước?')">
                            <input type="hidden" name="reservationId" value="<%= r.getId() %>">
                            <button type="submit" style="padding:0.3rem 0.7rem;background:#e94560;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                <i class="fa-solid fa-ban"></i> Hủy
                            </button>
                        </form>
                    <% } else { %>
                        <span style="color:#ccc;font-size:0.8rem;">—</span>
                    <% } %>
                    </div>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>

    <!-- Pagination (staff only) -->
    <% if (isStaff && totalPages > 1) { %>
    <div style="display:flex;justify-content:center;gap:0.4rem;margin-top:1.5rem;">
        <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="?page=<%= i %>&keyword=<%= keyword != null ? keyword : "" %>&status=<%= statusFilter != null ? statusFilter : "" %>"
           style="padding:0.4rem 0.8rem;border-radius:6px;text-decoration:none;border:1px solid #ddd;
                  background:<%= i == currentPage ? "linear-gradient(135deg,#e94560,#c62a47)" : "#fff" %>;
                  color:<%= i == currentPage ? "#fff" : "#333" %>;">
            <%= i %>
        </a>
        <% } %>
    </div>
    <% } %>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
