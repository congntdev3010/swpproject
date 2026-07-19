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

<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-bookmark"></i> Đặt trước
                </div>
                <h1 class="books-page-title"><%= isStaff ? "Quản lý đặt trước sách" : "Phiếu đặt trước của tôi" %></h1>
                <p class="books-page-subtitle">Quản lý và theo dõi các yêu cầu đặt trước sách của độc giả</p>
            </div>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num"><%= activeCount %></span>
                    <span class="bps-lbl">Đang đặt</span>
                </div>
                <div class="bps-divider"></div>
                <div class="bps-item">
                    <span class="bps-num"><%= maxLimit %></span>
                    <span class="bps-lbl">Giới hạn</span>
                </div>
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
            <form method="post" action="<%= request.getContextPath() %>/reservation/create"
                  style="display:flex;gap:0.5rem;"
                  onsubmit="return validateReservationForm(this)">
                <div style="flex:1;">
                    <input type="number" name="bookId" id="reservationBookId"
                           placeholder="Nhập Book ID..." required min="1" step="1"
                           style="width:100%;padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                    <div id="reservationBookId-error" style="color:#e94560;font-size:11px;margin-top:3px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Vui lòng nhập ID sách hợp lệ (số nguyên dương).
                    </div>
                </div>
                <button type="submit" class="btn btn-primary"
                        style="padding:0.5rem 1rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;white-space:nowrap;align-self:flex-start;">
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
            <button type="submit" class="btn btn-primary" style="padding:0.5rem 1rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:8px;cursor:pointer;">
                <i class="fa-solid fa-magnifying-glass"></i> Tìm
            </button>
        </form>
    </div>
    <% } %>

    <!-- Table -->
    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="text-align:left;">ID</th>
                    <% if (isStaff) { %><th style="text-align:left;">Người đặt</th><% } %>
                    <th style="text-align:left;">Sách</th>
                    <th style="text-align:left;">Ngày đặt</th>
                    <th style="text-align:left;">Trạng thái</th>
                    <th style="text-align:center;">Thao tác</th>
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
                             <input type="hidden" name="userId" value="<%= r.getUserId() %>">
                            <input type="hidden" name="bookId" value="<%= r.getBookId() %>">
                            <button type="submit" style="padding:0.3rem 0.7rem;background:#28a745;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                <i class="fa-solid fa-check"></i> Duyệt
                            </button>
                        </form>
                        <% } %>
                        <% if (isStaff && "READY".equals(st)) { %>
                        <a href="<%= request.getContextPath() %>/borrow/list?checkout=1&userId=<%= r.getUserId() %>&bookId=<%= r.getBookId() %>"
                           style="padding:0.3rem 0.7rem;background:#17a2b8;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;text-decoration:none;display:inline-block;">
                            <i class="fa-solid fa-plus"></i> Tạo Phiếu Mượn
                        </a>
                       <% if (isStaff) { %>
                            <button type="button" onclick="openCancelModal(<%= r.getId() %>)" style="padding:0.3rem 0.7rem;background:#e94560;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                <i class="fa-solid fa-ban"></i> Hủy
                            </button>
                        <% } else { %>
                        <form method="post" action="<%= request.getContextPath() %>/reservation/cancel"
                              onsubmit="return confirm('Xác nhận hủy phiếu đặt trước?')">
                            <input type="hidden" name="reservationId" value="<%= r.getId() %>">
                            <button type="submit" style="padding:0.3rem 0.7rem;background:#e94560;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                <i class="fa-solid fa-ban"></i> Hủy
                            </button>
                        </form>
                        <% } %>
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
        <nav aria-label="Phân trang">
            <ul class="pagination">
                <!-- Prev -->
                <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                    <a class="page-link"
                       href="?page=<%= currentPage - 1 %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>">
                        <i class="fa-solid fa-chevron-left fa-xs"></i>
                    </a>
                </li>

                <% 
                   if (totalPages <= 7) {
                       for (int pg = 1; pg <= totalPages; pg++) { %>
                           <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                               <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                           </li>
                       <% }
                   } else {
                       // Show first 2 pages
                       for (int pg = 1; pg <= 2; pg++) { %>
                           <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                               <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                           </li>
                       <% }

                       if (currentPage <= 4) {
                           // Current page is near the start
                           for (int pg = 3; pg <= 5; pg++) { %>
                               <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                                   <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                               </li>
                           <% } %>
                           <li class="page-item disabled"><span class="page-link">…</span></li>
                       <% } else if (currentPage >= totalPages - 3) {
                           // Current page is near the end %>
                           <li class="page-item disabled"><span class="page-link">…</span></li>
                           <% for (int pg = totalPages - 4; pg <= totalPages - 2; pg++) { %>
                               <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                                   <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                               </li>
                           <% }
                       } else {
                           // Current page is in the middle %>
                           <li class="page-item disabled"><span class="page-link">…</span></li>
                           <% for (int pg = currentPage - 1; pg <= currentPage + 1; pg++) { %>
                               <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                                   <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                               </li>
                           <% } %>
                           <li class="page-item disabled"><span class="page-link">…</span></li>
                       <% }

                       // Show last 2 pages
                       for (int pg = totalPages - 1; pg <= totalPages; pg++) { %>
                           <li class="page-item <%= pg == currentPage ? "active" : "" %>">
                               <a class="page-link" href="?page=<%= pg %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>"><%= pg %></a>
                           </li>
                       <% }
                   }
                %>

                <!-- Next -->
                <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                    <a class="page-link"
                       href="?page=<%= currentPage + 1 %>&keyword=<%= keyword != null ? java.net.URLEncoder.encode(keyword,"UTF-8") : "" %>&status=<%= statusFilter != null ? java.net.URLEncoder.encode(statusFilter,"UTF-8") : "" %>">
                        <i class="fa-solid fa-chevron-right fa-xs"></i>
                    </a>
                </li>
            </ul>
        </nav>
    <% } %>
</div>
<% if (isStaff) { %>
<!-- Cancel Modal -->
<div id="cancelModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:9999;align-items:center;justify-content:center;">
    <div style="background:#fff;padding:2rem;border-radius:12px;width:90%;max-width:400px;box-shadow:0 10px 30px rgba(0,0,0,0.2);">
        <h3 style="margin-top:0;margin-bottom:1rem;color:#1a1a2e;font-size:1.2rem;">Lý do hủy đặt trước</h3>
        <form id="cancelForm" method="post" action="<%= request.getContextPath() %>/reservation/cancel">
            <input type="hidden" name="reservationId" id="cancelReservationId">
            <textarea name="cancelReason" rows="4" placeholder="Nhập thông báo gửi đến người đặt (bắt buộc)..." required
                      style="width:100%;padding:0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;margin-bottom:1rem;font-family:inherit;resize:vertical;"></textarea>
            <div style="display:flex;gap:1rem;justify-content:flex-end;">
                <button type="button" onclick="closeCancelModal()" style="padding:0.5rem 1rem;background:#f5f5f5;border:1px solid #ddd;color:#333;border-radius:8px;cursor:pointer;">Đóng</button>
                <button type="submit" style="padding:0.5rem 1rem;background:#e94560;border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">Xác nhận Hủy</button>
            </div>
        </form>
    </div>
</div>
<script>
function openCancelModal(id) {
    document.getElementById('cancelReservationId').value = id;
    document.getElementById('cancelModal').style.display = 'flex';
}
function closeCancelModal() {
    document.getElementById('cancelModal').style.display = 'none';
}
</script>
<% } %>
<script>
function validateReservationForm(form) {
    const bookIdInput = document.getElementById('reservationBookId');
    const errorDiv = document.getElementById('reservationBookId-error');
    const val = parseInt(bookIdInput.value, 10);
    if (!bookIdInput.value || isNaN(val) || val <= 0) {
        errorDiv.style.display = 'block';
        bookIdInput.style.borderColor = '#e94560';
        bookIdInput.focus();
        return false;
    }
    errorDiv.style.display = 'none';
    bookIdInput.style.borderColor = '#28a745';
    return true;
}
</script>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
