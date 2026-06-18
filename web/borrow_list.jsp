<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.BorrowRecord, com.swp391.model.User, java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<BorrowRecord> borrows = (List<BorrowRecord>) request.getAttribute("borrows");
    int total = request.getAttribute("total") != null ? (int) request.getAttribute("total") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String statusFilter = (String) request.getAttribute("status");
    String keyword = (String) request.getAttribute("keyword");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    String warningMsg = request.getParameter("warning");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="page-hero" style="background: linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%); padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;gap:1rem;margin-bottom:0.5rem;">
            <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#e94560,#c62a47);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">📋</div>
            <div>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;">Quản lý Mượn sách</h1>
                <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;">Checkout · Trả sách · Gia hạn</p>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">

    <% if ("checkout".equals(successMsg)) { %>
    <div class="alert alert-success" style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Checkout thành công!
    </div>
    <% } else if ("returned".equals(successMsg)) { %>
    <div class="alert alert-success" style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Trả sách thành công!
    </div>
    <% } else if ("renewed".equals(successMsg)) { %>
    <div class="alert alert-success" style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Gia hạn thành công!
    </div>
    <% } %>
    <% if ("over_limit".equals(warningMsg)) { %>
    <div style="background:#fff3cd;border:1px solid #ffc107;color:#856404;padding:1rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <strong>Cảnh báo:</strong> Người dùng đã đạt/vượt ngưỡng số sách mượn tối đa.
        Với tư cách Thủ thư/Admin, bạn có thể override và tiếp tục checkout:
        <form method="post" action="<%= request.getContextPath() %>/borrow/checkout" style="display:inline;margin-left:1rem;">
            <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
            <input type="hidden" name="bookId" value="<%= request.getParameter("bookId") %>">
            <% if (request.getParameter("copyId") != null) { %><input type="hidden" name="copyId" value="<%= request.getParameter("copyId") %>"><% } %>
            <input type="hidden" name="overrideLimit" value="true">
            <button type="submit" class="btn btn-warning btn-sm" style="background:#ffc107;border:none;padding:0.4rem 1rem;border-radius:6px;cursor:pointer;font-weight:600;">
                <i class="fa-solid fa-bolt"></i> Xác nhận override
            </button>
        </form>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-xmark"></i> Có lỗi xảy ra: <%= errorMsg %>
    </div>
    <% } %>

    <!-- Toolbar -->
    <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;margin-bottom:1.5rem;">
        <form method="get" action="<%= request.getContextPath() %>/borrow/list" style="display:flex;gap:0.6rem;flex-wrap:wrap;">
            <input type="text" name="keyword" placeholder="Tìm theo tên, username, sách..."
                   value="<%= keyword != null ? keyword : "" %>"
                   style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;min-width:220px;">
            <select name="status" style="padding:0.5rem 0.8rem;border:1px solid #ddd;border-radius:8px;">
                <option value="">Tất cả trạng thái</option>
                <option value="BORROWING" <%= "BORROWING".equals(statusFilter) ? "selected" : "" %>>Đang mượn</option>
                <option value="OVERDUE" <%= "OVERDUE".equals(statusFilter) ? "selected" : "" %>>Quá hạn</option>
                <option value="RETURNED" <%= "RETURNED".equals(statusFilter) ? "selected" : "" %>>Đã trả</option>
            </select>
            <button type="submit" class="btn btn-primary btn-sm" style="padding:0.5rem 1rem;background:linear-gradient(135deg,#e94560,#c62a47);border:none;color:#fff;border-radius:8px;cursor:pointer;">
                <i class="fa-solid fa-magnifying-glass"></i> Tìm
            </button>
        </form>

        <!-- Form Checkout -->
        <button onclick="document.getElementById('checkoutModal').style.display='flex'"
                style="padding:0.55rem 1.2rem;background:linear-gradient(135deg,#28a745,#1e7e34);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
            <i class="fa-solid fa-plus"></i> Checkout sách
        </button>
    </div>

    <!-- Table -->
    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:linear-gradient(135deg,#1a1a2e,#16213e);color:#fff;">
                <tr>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">ID</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Người mượn</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Sách</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Barcode</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Ngày mượn</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Hạn trả</th>
                    <th style="padding:1rem 0.8rem;text-align:left;font-weight:600;">Trạng thái</th>
                    <th style="padding:1rem 0.8rem;text-align:center;font-weight:600;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <% if (borrows == null || borrows.isEmpty()) { %>
                <tr>
                    <td colspan="8" style="padding:3rem;text-align:center;color:#999;">
                        <i class="fa-solid fa-inbox" style="font-size:2rem;margin-bottom:0.5rem;display:block;"></i>
                        Không có phiếu mượn nào.
                    </td>
                </tr>
                <% } else { for (BorrowRecord b : borrows) {
                    boolean isOverdue = b.getDueDate() != null && b.getDueDate().isBefore(java.time.LocalDate.now()) && !"RETURNED".equals(b.getStatus());
                %>
                <tr style="border-bottom:1px solid #f0f0f0;" onmouseover="this.style.background='#fafafa'" onmouseout="this.style.background=''">
                    <td style="padding:0.8rem;color:#666;">#<%= b.getId() %></td>
                    <td style="padding:0.8rem;">
                        <div style="font-weight:600;"><%= b.getUser() != null ? b.getUser().getFullName() : "N/A" %></div>
                        <div style="font-size:0.8rem;color:#999;"><%= b.getUser() != null ? b.getUser().getUsername() : "" %></div>
                    </td>
                    <td style="padding:0.8rem;font-weight:500;"><%= b.getBook() != null ? b.getBook().getTitle() : "N/A" %></td>
                    <td style="padding:0.8rem;font-family:monospace;color:#666;"><%= b.getBookCopy() != null ? b.getBookCopy().getBarcode() : "-" %></td>
                    <td style="padding:0.8rem;color:#555;"><%= b.getBorrowDate() %></td>
                    <td style="padding:0.8rem;color:<%= isOverdue ? "#e94560" : "#555" %>;font-weight:<%= isOverdue ? "700" : "400" %>;">
                        <%= b.getDueDate() %><%= isOverdue ? " ⚠️" : "" %>
                    </td>
                    <td style="padding:0.8rem;">
                        <% String st = b.getStatus(); %>
                        <span style="padding:0.25rem 0.7rem;border-radius:20px;font-size:0.78rem;font-weight:600;
                            background:<%= "BORROWING".equals(st) ? "#e3f2fd" : "OVERDUE".equals(st) ? "#fdecea" : "RETURNED".equals(st) ? "#e8f5e9" : "#f5f5f5" %>;
                            color:<%= "BORROWING".equals(st) ? "#1565c0" : "OVERDUE".equals(st) ? "#c62828" : "RETURNED".equals(st) ? "#2e7d32" : "#555" %>;">
                            <%= "BORROWING".equals(st) ? "Đang mượn" : "OVERDUE".equals(st) ? "Quá hạn" : "RETURNED".equals(st) ? "Đã trả" : st %>
                        </span>
                    </td>
                    <td style="padding:0.8rem;text-align:center;">
                        <div style="display:flex;gap:0.4rem;justify-content:center;">
                        <% if (!"RETURNED".equals(b.getStatus())) { %>
                            <form method="post" action="<%= request.getContextPath() %>/borrow/return" onsubmit="return confirm('Xác nhận trả sách?')">
                                <input type="hidden" name="borrowId" value="<%= b.getId() %>">
                                <button type="submit" title="Trả sách"
                                        style="padding:0.3rem 0.7rem;background:#28a745;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                    <i class="fa-solid fa-rotate-left"></i> Trả
                                </button>
                            </form>
                            <form method="post" action="<%= request.getContextPath() %>/borrow/renew">
                                <input type="hidden" name="borrowId" value="<%= b.getId() %>">
                                <button type="submit" title="Gia hạn"
                                        style="padding:0.3rem 0.7rem;background:#17a2b8;border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
                                    <i class="fa-solid fa-arrows-rotate"></i> Gia hạn
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

    <!-- Pagination -->
    <% if (totalPages > 1) { %>
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

<!-- Checkout Modal -->
<div id="checkoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:9000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:16px;padding:2rem;width:90%;max-width:480px;box-shadow:0 20px 60px rgba(0,0,0,0.2);">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
            <h3 style="margin:0;font-size:1.2rem;">📚 Checkout sách</h3>
            <button onclick="document.getElementById('checkoutModal').style.display='none'"
                    style="background:none;border:none;font-size:1.4rem;cursor:pointer;color:#999;">&times;</button>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/borrow/checkout">
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Người mượn *</label>
                <input type="number" name="userId" required placeholder="Nhập user ID..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
            </div>
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Sách *</label>
                <input type="number" name="bookId" required placeholder="Nhập book ID..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
            </div>
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Bản sao (copy_id, nếu có)</label>
                <input type="number" name="copyId" placeholder="Để trống nếu không có..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
            </div>
            <div style="margin-bottom:1.5rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">Ghi chú</label>
                <input type="text" name="note" placeholder="Ghi chú thêm (nếu có)..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
            </div>
            <div style="display:flex;gap:0.8rem;">
                <button type="button" onclick="document.getElementById('checkoutModal').style.display='none'"
                        style="flex:1;padding:0.7rem;background:#f5f5f5;border:1px solid #ddd;border-radius:8px;cursor:pointer;">Hủy</button>
                <button type="submit"
                        style="flex:2;padding:0.7rem;background:linear-gradient(135deg,#28a745,#1e7e34);border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
                    <i class="fa-solid fa-check"></i> Xác nhận Checkout
                </button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
