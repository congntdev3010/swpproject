<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.BorrowRecord, com.swp391.model.User, com.swp391.model.Book, java.util.List" %>
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

<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-hand-holding-hand"></i> Quản lý
                </div>
                <h1 class="books-page-title">Quản lý Mượn sách</h1>
                <p class="books-page-subtitle">Thực hiện mượn sách, trả sách và gia hạn cho độc giả</p>
            </div>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num"><%= total %></span>
                    <span class="bps-lbl">Lượt mượn</span>
                </div>
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
    <% if (errorMsg != null && !"copy_not_available".equals(errorMsg)) { %>
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
            <button type="submit" class="btn btn-primary btn-sm" style="padding:0.5rem 1rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:8px;cursor:pointer;">
                <i class="fa-solid fa-magnifying-glass"></i> Tìm
            </button>
        </form>

        <!-- Form Checkout -->
        <button onclick="document.getElementById('checkoutModal').style.display='flex'"
                style="padding:0.55rem 1.2rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
            <i class="fa-solid fa-plus"></i> Checkout sách
        </button>
    </div>

    <!-- Table -->
    <div class="data-table-wrap" style="overflow-x: auto;">
        <table class="data-table" style="width: 100%; min-width: 1250px; table-layout: auto;">
            <thead>
                <tr>
                    <th style="text-align:left; width: 70px; white-space: nowrap;">ID</th>
                    <th style="text-align:left; min-width: 200px; white-space: nowrap;">Người mượn</th>
                    <th style="text-align:left; min-width: 280px; white-space: nowrap;">Sách</th>
                    <th style="text-align:left; width: 110px; white-space: nowrap;">Barcode</th>
                    <th style="text-align:left; width: 110px; white-space: nowrap;">Ngày mượn</th>
                    <th style="text-align:left; width: 110px; white-space: nowrap;">Hạn trả</th>
                    <th style="text-align:left; width: 110px; white-space: nowrap;">Ngày trả</th>
                    <th style="text-align:left; width: 120px; white-space: nowrap;">Trạng thái</th>
                    <th style="text-align:center; width: 180px; min-width: 180px; white-space: nowrap;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <% if (borrows == null || borrows.isEmpty()) { %>
                <tr>
                    <td colspan="9" style="padding:3rem;text-align:center;color:#999;">
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
                    <td style="padding:0.8rem;color:#555;white-space:nowrap;"><%= b.getBorrowDate() %></td>
                    <td style="padding:0.8rem;color:<%= isOverdue ? "#e94560" : "#555" %>;font-weight:<%= isOverdue ? "700" : "400" %>;white-space:nowrap;">
                        <%= b.getDueDate() %><%= isOverdue ? " ⚠️" : "" %>
                    </td>
                    <td style="padding:0.8rem;color:#555;white-space:nowrap;"><%= b.getReturnDate() != null ? b.getReturnDate() : "-" %></td>
                    <td style="padding:0.8rem;white-space:nowrap;">
                        <% String st = b.getStatus(); %>
                        <span style="padding:0.25rem 0.7rem;border-radius:20px;font-size:0.78rem;font-weight:600;white-space:nowrap;
                            background:<%= "BORROWING".equals(st) ? "#e3f2fd" : "OVERDUE".equals(st) ? "#fdecea" : "RETURNED".equals(st) ? "#e8f5e9" : "#f5f5f5" %>;
                            color:<%= "BORROWING".equals(st) ? "#1565c0" : "OVERDUE".equals(st) ? "#c62828" : "RETURNED".equals(st) ? "#2e7d32" : "#555" %>;">
                            <%= "BORROWING".equals(st) ? "Đang mượn" : "OVERDUE".equals(st) ? "Quá hạn" : "RETURNED".equals(st) ? "Đã trả" : st %>
                        </span>
                    </td>
                    <td style="padding:0.8rem;text-align:center;white-space:nowrap;">
                        <div style="display:flex;gap:0.4rem;justify-content:center;flex-wrap:nowrap;">
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
                                <button type="submit"
                                        style="padding:0.3rem 0.7rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.8rem;">
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

<!-- Checkout Modal -->
<div id="checkoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:9000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:16px;padding:2rem;width:90%;max-width:480px;box-shadow:0 20px 60px rgba(0,0,0,0.2);">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
            <h3 style="margin:0;font-size:1.2rem;">📚 Checkout sách</h3>
            <button onclick="document.getElementById('checkoutModal').style.display='none'"
                    style="background:none;border:none;font-size:1.4rem;cursor:pointer;color:#999;">&times;</button>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/borrow/checkout"
              id="checkoutForm" onsubmit="return validateCheckoutForm()">
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Người mượn *</label>
                 <input type="text" name="userId" id="checkoutUserId" list="checkoutUsersList" required
                        placeholder="Nhập user ID..."
                        style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                <datalist id="checkoutUsersList">
                    <% List<User> allUsers = (List<User>) request.getAttribute("allUsers");
                       if (allUsers != null) { for (User u : allUsers) { %>
                       <option value="<%= u.getId() %> - <%= u.getFullName() %> (<%= u.getUsername() %>)"></option>
                    <% } } %>
                </datalist>
                <div id="checkoutUserId-error" style="color:#e94560;font-size:12px;margin-top:3px;display:none;">
                    <i class="fa-solid fa-triangle-exclamation"></i> Vui lòng nhập ID người mượn hợp lệ (số nguyên dương).
                </div>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Sách *</label>
                <input type="text" name="bookId" id="checkoutBookId" list="checkoutBooksList" required
                       placeholder="Nhập book ID..."
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                <datalist id="checkoutBooksList">
                    <% List<Book> allBooks = (List<Book>) request.getAttribute("allBooks");
                       if (allBooks != null) { for (Book bk : allBooks) { %>
                       <option value="<%= bk.getId() %> - <%= bk.getTitle() %>"></option>
                    <% } } %>
                </datalist>
                <div id="checkoutBookId-error" style="color:#e94560;font-size:12px;margin-top:3px;display:none;">
                    <i class="fa-solid fa-triangle-exclamation"></i> Vui lòng nhập ID sách hợp lệ (số nguyên dương).
                </div>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">ID Bản sao (copy_id, nếu có)</label>
                <input type="number" name="copyId" id="checkoutCopyId" placeholder="Để trống nếu không có..." min="1"
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;">
                <div id="checkoutCopyId-error" style="color:#e94560;font-size:12px;margin-top:3px;display:none;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ID Bản sao phải là số nguyên dương.
                </div>
                <div id="checkoutCopyId-server-error" style="color:#e94560;font-size:12px;margin-top:3px;display:none;">
                    <i class="fa-solid fa-triangle-exclamation"></i> Bản sao sách không tồn tại hoặc trạng thái không khả dụng (AVAILABLE).
                </div>
            </div>
            <div style="margin-bottom:1.5rem;">
                <label style="display:block;font-weight:600;margin-bottom:0.4rem;">Ghi chú</label>
                <input type="text" name="note" id="checkoutNote" placeholder="Ghi chú thêm (nếu có)..." maxlength="500"
                       style="width:100%;padding:0.6rem 0.8rem;border:1px solid #ddd;border-radius:8px;box-sizing:border-box;"
                       oninput="document.getElementById('checkoutNote-count').textContent = (500 - this.value.length) + ' ký tự còn lại'">
                <div id="checkoutNote-count" style="font-size:11px;color:#aaa;margin-top:3px;text-align:right;">500 ký tự còn lại</div>
            </div>
            <div style="display:flex;gap:0.8rem;">
                <button type="button" onclick="document.getElementById('checkoutModal').style.display='none'"
                        style="flex:1;padding:0.7rem;background:#f5f5f5;border:1px solid #ddd;border-radius:8px;cursor:pointer;">Hủy</button>
                 <button type="submit"
                        style="flex:2;padding:0.7rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));border:none;color:#fff;border-radius:8px;cursor:pointer;font-weight:600;">
                    <i class="fa-solid fa-check"></i> Xác nhận Checkout
                </button>
            </div>
        </form>
    </div>
</div>

<script>
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('checkout') && urlParams.has('userId') && urlParams.has('bookId')) {
        let userId = urlParams.get('userId');
        let bookId = urlParams.get('bookId');
        let copyId = urlParams.get('copyId');
        let error = urlParams.get('error');

        document.querySelector('input[name="userId"]').value = userId;
        document.querySelector('input[name="bookId"]').value = bookId;
        if (copyId) document.querySelector('input[name="copyId"]').value = copyId;
        
        document.getElementById('checkoutModal').style.display = 'flex';
        
        if (error === 'copy_not_available') {
            document.getElementById('checkoutCopyId-server-error').style.display = 'block';
            document.getElementById('checkoutCopyId').style.borderColor = '#e94560';
        }
        
        setTimeout(() => document.querySelector('input[name="copyId"]').focus(), 100);
    }
}

function validateCheckoutForm() {
    let valid = true;
    const serverErr = document.getElementById('checkoutCopyId-server-error');
    if (serverErr) serverErr.style.display = 'none';

    // Validate userId
    const userIdInput = document.getElementById('checkoutUserId');
    const userIdErr = document.getElementById('checkoutUserId-error');
    const userIdRaw = userIdInput.value.trim().split(' - ')[0].trim();
    const userId = parseInt(userIdRaw, 10);
    if (!userIdRaw || isNaN(userId) || userId <= 0) {
        userIdErr.style.display = 'block';
        userIdInput.style.borderColor = '#e94560';
        valid = false;
    } else {
        userIdErr.style.display = 'none';
        userIdInput.style.borderColor = '#28a745';
    }

    // Validate bookId
    const bookIdInput = document.getElementById('checkoutBookId');
    const bookIdErr = document.getElementById('checkoutBookId-error');
    const bookIdRaw = bookIdInput.value.trim().split(' - ')[0].trim();
    const bookId = parseInt(bookIdRaw, 10);
    if (!bookIdRaw || isNaN(bookId) || bookId <= 0) {
        bookIdErr.style.display = 'block';
        bookIdInput.style.borderColor = '#e94560';
        valid = false;
    } else {
        bookIdErr.style.display = 'none';
        bookIdInput.style.borderColor = '#28a745';
    }

    // Validate copyId (optional but must be positive if provided)
    const copyIdInput = document.getElementById('checkoutCopyId');
    const copyIdErr = document.getElementById('checkoutCopyId-error');
    if (copyIdInput.value.trim() !== '') {
        const copyId = parseInt(copyIdInput.value, 10);
        if (isNaN(copyId) || copyId <= 0) {
            copyIdErr.style.display = 'block';
            copyIdInput.style.borderColor = '#e94560';
            valid = false;
        } else {
            copyIdErr.style.display = 'none';
            copyIdInput.style.borderColor = '#28a745';
        }
    } else {
        copyIdErr.style.display = 'none';
    }

    if (!valid) {
        const firstErr = document.querySelector('#checkoutForm [style*="block"]');
        if (firstErr) firstErr.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    return valid;
}
</script>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
