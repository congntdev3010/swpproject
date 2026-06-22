<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Fine, com.swp391.model.User, java.util.List, java.text.NumberFormat, java.util.Locale" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    boolean isStaff = loggedUser.isAdminOrLibrarian();
    boolean isAdmin = loggedUser.isAdmin();
    List<Fine> fines = (List<Fine>) request.getAttribute("fines");
    int total = request.getAttribute("total") != null ? (int) request.getAttribute("total") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String statusFilter = (String) request.getAttribute("status");
    String keyword = (String) request.getAttribute("keyword");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    NumberFormat vndFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="page-hero" style="background:linear-gradient(135deg,#1a1a2e 0%,#3a0000 50%,#6b0000 100%);padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#ff6b6b,#ee5a24);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">💸</div>
            <div>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;"><%= isStaff ? "Quản lý Phạt" : "Phạt của tôi" %></h1>
                <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;">Trễ hạn · Hư hỏng · Mất sách</p>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">
    <!-- Alerts -->
    <% if ("created".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Tạo phiếu phạt thành công!
    </div>
    <% } else if ("waived".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Miễn giảm phạt thành công!
    </div>
    <% } else if ("paid".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Ghi nhận thanh toán thành công!
    </div>
    <% } else if (errorMsg != null) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-xmark"></i> Có lỗi xảy ra: <%= errorMsg %>
    </div>
    <% } %>

    <!-- Staff toolbar -->
    <% if (isStaff) { %>
    <div style="display:flex;justify-content:space-between;flex-wrap:wrap;gap:1rem;margin-bottom:1.5rem;">
        <form method="get" action="<%= request.getContextPath() %>/fine/list" style="display:flex;gap:0.6rem;flex-wrap:wrap;">
            <input type="text" name="keyword" placeholder="Tìm theo tên người dùng..."
                   value="<%= keyword != null ? keyword : "" %>"
                   style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;min-width:200px;">
            <select name="status" style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                <option value="">Tất cả</option>
                <option value="UNPAID" <%= "UNPAID".equals(statusFilter) ? "selected" : "" %>>Chưa thanh toán</option>
                <option value="PAID" <%= "PAID".equals(statusFilter) ? "selected" : "" %>>Đã thanh toán</option>
                <option value="WAIVED" <%= "WAIVED".equals(statusFilter) ? "selected" : "" %>>Đã miễn giảm</option>
            </select>
            <button type="submit" style="padding:0.5rem 1rem;background:linear-gradient(135deg,#ff6b6b,#ee5a24);border:none;color:#fff;border-radius:8px;cursor:pointer;">
                <i class="fa-solid fa-magnifying-glass"></i> Tìm
            </button>
        </form>
        <button onclick="document.getElementById('createFineModal').style.display='flex'"
                style="padding:0.55rem 1.2rem;background:linear-gradient(135deg,#ff6b6b,#ee5a24);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
            <i class="fa-solid fa-plus"></i> Tạo phiếu phạt
        </button>
    </div>
    <% } %>

    <!-- Fine Table -->
    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:linear-gradient(135deg,#1a1a2e,#3a0000);color:#fff;">
                <tr>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">ID</th>
                    <% if (isStaff) { %><th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Người dùng</th><% } %>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Lý do</th>
                    <th style="padding:1rem 0.8rem;text-align:right;font-weight:600;">Số tiền</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Trạng thái</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Ngày tạo</th>
                    <% if (isStaff) { %><th style="padding:1rem 0.8rem;text-align:center;font-weight:600;">Thao tác</th><% } %>
                </tr>
            </thead>
            <tbody>
            <% if (fines == null || fines.isEmpty()) { %>
            <tr>
                <td colspan="<%= isStaff ? "7" : "5" %>" style="padding:3rem;text-align:center;color:#aaa;">
                    <i class="fa-solid fa-circle-check" style="font-size:2rem;display:block;margin-bottom:0.5rem;color:#28a745;"></i>
                    Không có phiếu phạt nào. 🎉
                </td>
            </tr>
            <% } else { for (Fine f : fines) {
                String st = f.getStatus();
                String reason = f.getReason();
            %>
            <tr style="border-bottom:1px solid #f5f5f5;" onmouseover="this.style.background='#fafafa'" onmouseout="this.style.background=''">
                <td style="padding:0.8rem;color:#666;">#<%= f.getId() %></td>
                <% if (isStaff) { %>
                <td style="padding:0.8rem;">
                    <div style="font-weight:600;"><%= f.getUser() != null ? f.getUser().getFullName() : "N/A" %></div>
                    <div style="font-size:0.8rem;color:#aaa;"><%= f.getUser() != null ? f.getUser().getUsername() : "" %></div>
                </td>
                <% } %>
                <td style="padding:0.8rem;">
                    <span style="padding:0.2rem 0.6rem;border-radius:6px;font-size:0.78rem;font-weight:600;
                        background:<%= "OVERDUE".equalsIgnoreCase(reason) ? "#fff3cd" : "DAMAGE".equalsIgnoreCase(reason) ? "#fde8e8" : "#f8d7da" %>;
                        color:<%= "OVERDUE".equalsIgnoreCase(reason) ? "#856404" : "DAMAGE".equalsIgnoreCase(reason) ? "#c62a47" : "#721c24" %>;">
                        <%= "OVERDUE".equalsIgnoreCase(reason) ? "⏰ Trễ hạn" : "DAMAGE".equalsIgnoreCase(reason) ? "🔧 Hư hỏng" : "❌ Mất sách" %>
                    </span>
                    <% if (f.getOverdueDays() > 0) { %><div style="font-size:0.75rem;color:#999;margin-top:0.2rem;"><%= f.getOverdueDays() %> ngày trễ</div><% } %>
                </td>
                <td style="padding:0.8rem;text-align:right;font-weight:700;color:<%= "PAID".equals(st) || "WAIVED".equals(st) ? "#28a745" : "#e94560" %>;">
                    <%= f.getAmount() != null ? vndFormat.format(f.getAmount()) : "—" %>
                </td>
                <td style="padding:0.8rem;">
                    <span style="padding:0.25rem 0.7rem;border-radius:20px;font-size:0.78rem;font-weight:600;
                        background:<%= "UNPAID".equals(st) ? "#fdecea" : "PAID".equals(st) ? "#e8f5e9" : "WAIVED".equals(st) ? "#e3f2fd" : "#f5f5f5" %>;
                        color:<%= "UNPAID".equals(st) ? "#c62828" : "PAID".equals(st) ? "#2e7d32" : "WAIVED".equals(st) ? "#1565c0" : "#666" %>;">
                        <%= "UNPAID".equals(st) ? "Chưa thanh toán" : "PAID".equals(st) ? "Đã thanh toán" : "WAIVED".equals(st) ? "Miễn giảm" : st %>
                    </span>
                </td>
                <td style="padding:0.8rem;color:#888;font-size:0.88rem;"><%= f.getCreatedAt() != null ? f.getCreatedAt().toLocalDate() : "-" %></td>
                <% if (isStaff) { %>
                <td style="padding:0.8rem;text-align:center;">
                    <div style="display:flex;gap:0.4rem;justify-content:center;">
                    <% if ("UNPAID".equals(st)) { %>
                        <!-- Thanh toán -->
                        <form method="post" action="<%= request.getContextPath() %>/fine/pay">
                            <input type="hidden" name="fineId" value="<%= f.getId() %>">
                            <input type="hidden" name="method" value="CASH">
                            <button type="submit" style="padding:0.3rem 0.6rem;background:#28a745;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.78rem;" title="Ghi nhận đã thanh toán">
                                <i class="fa-solid fa-money-bill"></i> Thanh toán
                            </button>
                        </form>
                        <% if (isAdmin) { %>
                        <!-- Miễn giảm (Admin only) -->
                        <form method="post" action="<%= request.getContextPath() %>/fine/waive"
                              onsubmit="return confirm('Xác nhận miễn giảm phạt này?')">
                            <input type="hidden" name="fineId" value="<%= f.getId() %>">
                            <button type="submit" style="padding:0.3rem 0.6rem;background:#17a2b8;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.78rem;" title="Miễn giảm phạt">
                                <i class="fa-solid fa-circle-xmark"></i> Miễn
                            </button>
                        </form>
                        <% } %>
                    <% } else { %>
                        <span style="color:#ccc;font-size:0.8rem;">—</span>
                    <% } %>
                    </div>
                </td>
                <% } %>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <% if (isStaff && totalPages > 1) { %>
    <div style="display:flex;justify-content:center;gap:0.4rem;margin-top:1.5rem;">
        <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="?page=<%= i %>&keyword=<%= keyword != null ? keyword : "" %>&status=<%= statusFilter != null ? statusFilter : "" %>"
           style="padding:0.4rem 0.8rem;border-radius:6px;text-decoration:none;border:1px solid #ddd;
                  background:<%= i == currentPage ? "linear-gradient(135deg,#ff6b6b,#ee5a24)" : "#fff" %>;
                  color:<%= i == currentPage ? "#fff" : "#333" %>;">
            <%= i %>
        </a>
        <% } %>
    </div>
    <% } %>
</div>

<!-- Create Fine Modal -->
<div id="createFineModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:9000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:16px;padding:2rem;width:90%;max-width:440px;box-shadow:0 20px 60px rgba(0,0,0,0.2);">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
            <h3 style="margin:0;font-size:1.2rem;">💸 Tạo phiếu phạt</h3>
            <button onclick="document.getElementById('createFineModal').style.display='none'"
                    style="background:none;border:none;font-size:1.4rem;cursor:pointer;color:#999;">&times;</button>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/fine/create">
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Phiếu mượn *</label>
                <input type="number" name="borrowRecordId" required placeholder="Nhập borrow record ID..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
            </div>
            <div style="margin-bottom:1.5rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">Loại phạt *</label>
                <select name="type" required style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                    <option value="DAMAGE">🔧 Hư hỏng (70% giá gốc)</option>
                    <option value="LOST">❌ Mất sách (100% giá gốc)</option>
                </select>
            </div>
            <div style="display:flex;gap:0.8rem;">
                <button type="button" onclick="document.getElementById('createFineModal').style.display='none'"
                        style="flex:1;padding:0.7rem;background:#f5f5f5;border:1px solid #ddd;border-radius:8px;cursor:pointer;">Hủy</button>
                <button type="submit"
                        style="flex:2;padding:0.7rem;background:linear-gradient(135deg,#ff6b6b,#ee5a24);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
                    <i class="fa-solid fa-check"></i> Tạo phiếu phạt
                </button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
