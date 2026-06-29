<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.ArrayList, com.swp391.model.User, com.swp391.model.BorrowRecord" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    if (logged == null || !logged.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<BorrowRecord> pendingList   = (List<BorrowRecord>) request.getAttribute("pendingList");
    List<BorrowRecord> borrowingList = (List<BorrowRecord>) request.getAttribute("borrowingList");
    List<BorrowRecord> returnedList  = (List<BorrowRecord>) request.getAttribute("returnedList");
    List<BorrowRecord> rejectedList  = (List<BorrowRecord>) request.getAttribute("rejectedList");
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");
    if (pendingCount == null) pendingCount = 0;

    String ctx = request.getContextPath();

    String msg = (String) session.getAttribute("adminBorrowMsg");
    session.removeAttribute("adminBorrowMsg");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quản lý phiếu mượn | FPT Library</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
</head>
<body>
<div class="admin-shell">

    <!-- ===== SIDEBAR ===== -->
    <aside class="admin-sidebar">
        <div class="admin-sidebar-brand">
            <div class="brand-icon">📚</div>
            <div>
                <div class="brand-title">Admin Panel</div>
                <div class="brand-subtitle"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %> · <%= logged.getRole() %></div>
            </div>
        </div>

        <nav class="admin-nav" aria-label="Admin management menu">
            <a class="admin-nav-item" href="<%= ctx %>/admin/users">
                <i class="fa-solid fa-users"></i>
                <span>Quản lý người dùng</span>
            </a>
            <a class="admin-nav-item active" href="<%= ctx %>/admin/borrow">
                <i class="fa-solid fa-book-open-reader"></i>
                <span>Quản lý mượn sách</span>
                <% if (pendingCount > 0) { %>
                <span class="admin-nav-badge"><%= pendingCount %></span>
                <% } %>
            </a>
        </nav>

        <div class="admin-sidebar-footer">
            <div class="admin-sidebar-card admin-sidebar-usercard">
                <div class="admin-sidebar-label">Logged as</div>
                <div class="admin-sidebar-value"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %></div>
                <div class="admin-sidebar-badge"><%= logged.getRole() %></div>
            </div>
            <a class="btn btn-outline btn-sm admin-sidebar-footer-btn" href="<%= ctx %>/home">
                <i class="fa-solid fa-house"></i> Màn hình chính
            </a>
            <a class="btn btn-danger btn-sm admin-sidebar-footer-btn" href="<%= ctx %>/logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </div>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="admin-main">
        <section class="admin-page-header">
            <div>
                <h1><i class="fa-solid fa-book-open-reader" style="color:var(--primary);"></i> Quản lý phiếu mượn sách</h1>
                <p>Xem xét, duyệt hoặc từ chối phiếu mượn. Xác nhận trả sách.</p>
            </div>
            <div style="display:flex; gap:10px;">
                <a href="<%= ctx %>/admin/borrow" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-rotate-right"></i> Làm mới
                </a>
            </div>
        </section>

        <!-- Messages -->
        <% if (msg != null) { %>
        <div class="alert <%= msg.contains("failed") || msg.contains("error") ? "alert-danger" : "alert-success" %>">
            <i class="fa-solid <%= msg.contains("failed") || msg.contains("error") ? "fa-circle-xmark" : "fa-circle-check" %>"></i>
            <%
                if ("approved".equals(msg)) out.print("Đã duyệt phiếu mượn thành công! Sách đã được đánh dấu là đang mượn.");
                else if ("rejected".equals(msg)) out.print("Đã từ chối phiếu mượn.");
                else if ("returned".equals(msg)) out.print("Xác nhận trả sách thành công! Số lượng tồn kho đã được cập nhật.");
                else if ("approve_failed".equals(msg)) out.print("Duyệt thất bại – có thể sách đã hết bản hoặc phiếu không hợp lệ.");
                else if ("reject_failed".equals(msg)) out.print("Từ chối thất bại.");
                else if ("return_failed".equals(msg)) out.print("Xác nhận trả thất bại.");
                else out.print("Đã xảy ra lỗi, vui lòng thử lại.");
            %>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> <%= error %></div>
        <% } %>

        <!-- ==================== PENDING SECTION ==================== -->
        <section class="admin-card" style="margin-bottom:28px;">
            <div class="admin-section-head">
                <h2>
                    <i class="fa-solid fa-clock" style="color:var(--warning);"></i>
                    Phiếu chờ duyệt
                    <% if (pendingCount > 0) { %>
                    <span class="badge badge-warning" style="font-size:0.78rem; vertical-align:middle;"><%= pendingCount %> chờ</span>
                    <% } %>
                </h2>
                <span style="color:var(--text-muted); font-size:0.85rem;">Phiếu mượn từ độc giả đang chờ xét duyệt</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width:50px;">STT</th>
                            <th>Tên người dùng</th>
                            <th>Danh sách sách</th>
                            <th style="width:140px;">Ngày yêu cầu</th>
                            <th style="width:200px; text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (pendingList != null && !pendingList.isEmpty()) {
                            int idx = 1;
                            for (BorrowRecord br : pendingList) {
                    %>
                    <tr>
                        <td style="color:var(--text-muted); font-size:0.82rem;"><%= idx++ %></td>
                        <td>
                            <div style="font-weight:600; color:var(--text-primary);">
                                <%= br.getUser() != null ? (br.getUser().getFullName() != null ? br.getUser().getFullName() : br.getUser().getUsername()) : "N/A" %>
                            </div>
                            <div style="font-size:0.78rem; color:var(--text-muted);">
                                <%= br.getUser() != null ? br.getUser().getEmail() : "" %>
                                <% if (br.getUser() != null && br.getUser().getStudentId() != null) { %>
                                · <%= br.getUser().getStudentId() %>
                                <% } %>
                            </div>
                        </td>
                        <td>
                            <div style="font-size:0.9rem; font-weight:500; color:var(--text-primary);">
                                <i class="fa-solid fa-book fa-xs" style="color:var(--primary); margin-right:4px;"></i>
                                <%= br.getBook() != null ? br.getBook().getTitle() : "#" + br.getBookId() %>
                            </div>
                            <% if (br.getBook() != null) { %>
                            <div style="font-size:0.75rem; color:var(--text-muted);">
                                Còn <strong style="color:var(--success);"><%= br.getBook().getAvailable() %></strong>/<%= br.getBook().getQuantity() %> bản
                            </div>
                            <% } %>
                        </td>
                        <td style="font-size:0.82rem; color:var(--text-muted);">
                            <%= br.getCreatedAt() != null ? br.getCreatedAt().toLocalDate() : "—" %>
                        </td>
                        <td style="text-align:center;">
                            <div style="display:flex; gap:8px; justify-content:center; flex-wrap:wrap;">
                                <!-- Approve -->
                                <form method="post" action="<%= ctx %>/admin/borrow"
                                      onsubmit="return confirm('Duyệt phiếu mượn sách «<%= br.getBook() != null ? br.getBook().getTitle().replace("'","") : "này" %>»?')">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="borrowId" value="<%= br.getId() %>">
                                    <button type="submit" class="btn btn-primary btn-sm">
                                        <i class="fa-solid fa-check"></i> Chấp nhận
                                    </button>
                                </form>
                                <!-- Reject -->
                                <form method="post" action="<%= ctx %>/admin/borrow"
                                      onsubmit="return confirm('Từ chối phiếu mượn này?')">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="borrowId" value="<%= br.getId() %>">
                                    <button type="submit" class="btn btn-danger btn-sm">
                                        <i class="fa-solid fa-xmark"></i> Từ chối
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr>
                        <td colspan="5">
                            <div class="empty-state" style="padding:40px 24px;">
                                <div class="empty-icon"><i class="fa-solid fa-inbox"></i></div>
                                <h3>Không có phiếu nào đang chờ</h3>
                                <p>Tất cả phiếu mượn đã được xử lý.</p>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- ==================== BORROWING SECTION (Đang mượn - Trả sách) ==================== -->
        <section class="admin-card" style="margin-bottom:28px;">
            <div class="admin-section-head">
                <h2>
                    <i class="fa-solid fa-book-open" style="color:var(--primary);"></i>
                    Đang được mượn
                    <% if (borrowingList != null && !borrowingList.isEmpty()) { %>
                    <span class="badge badge-primary" style="font-size:0.78rem; vertical-align:middle;"><%= borrowingList.size() %></span>
                    <% } %>
                </h2>
                <span style="color:var(--text-muted); font-size:0.85rem;">Sách đang được mượn – Xác nhận trả sách khi người dùng hoàn trả</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width:50px;">STT</th>
                            <th>Tên người dùng</th>
                            <th>Danh sách mượn</th>
                            <th style="width:110px;">Ngày mượn</th>
                            <th style="width:110px;">Hạn trả</th>
                            <th style="width:140px;">Tình trạng sách</th>
                            <th style="width:160px; text-align:center;">Trả sách</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (borrowingList != null && !borrowingList.isEmpty()) {
                            int idx = 1;
                            for (BorrowRecord br : borrowingList) {
                                java.time.LocalDate today = java.time.LocalDate.now();
                                boolean overdue = br.getDueDate() != null && br.getDueDate().isBefore(today);
                    %>
                    <tr style="<%= overdue ? "background:rgba(255,71,87,0.03);" : "" %>">
                        <td style="color:var(--text-muted); font-size:0.82rem;"><%= idx++ %></td>
                        <td>
                            <div style="font-weight:600; color:var(--text-primary);">
                                <%= br.getUser() != null ? (br.getUser().getFullName() != null ? br.getUser().getFullName() : br.getUser().getUsername()) : "N/A" %>
                            </div>
                            <div style="font-size:0.78rem; color:var(--text-muted);">
                                <%= br.getUser() != null ? br.getUser().getEmail() : "" %>
                            </div>
                        </td>
                        <td>
                            <div style="font-size:0.9rem; font-weight:500; color:var(--text-primary);">
                                <i class="fa-solid fa-book fa-xs" style="color:var(--primary); margin-right:4px;"></i>
                                <%= br.getBook() != null ? br.getBook().getTitle() : "#" + br.getBookId() %>
                            </div>
                        </td>
                        <td style="font-size:0.82rem; color:var(--text-muted);">
                            <%= br.getBorrowDate() != null ? br.getBorrowDate() : "—" %>
                        </td>
                        <td style="font-size:0.82rem; font-weight:600; color:<%= overdue ? "var(--danger)" : "var(--text-secondary)" %>;">
                            <%= br.getDueDate() != null ? br.getDueDate() : "—" %>
                            <% if (overdue) { %>
                            <div style="font-size:0.72rem; color:var(--danger);"><i class="fa-solid fa-exclamation-triangle"></i> Quá hạn</div>
                            <% } %>
                        </td>
                        <td>
                            <select id="cond_<%= br.getId() %>" class="form-select" style="font-size:0.82rem; padding:6px 10px;">
                                <option value="GOOD">Tốt</option>
                                <option value="WORN">Cũ / Sờn</option>
                                <option value="DAMAGED">Hỏng</option>
                                <option value="LOST">Mất</option>
                            </select>
                        </td>
                        <td style="text-align:center;">
                            <form method="post" action="<%= ctx %>/admin/borrow" id="returnForm_<%= br.getId() %>"
                                  onsubmit="document.getElementById('condInput_<%= br.getId() %>').value=document.getElementById('cond_<%= br.getId() %>').value; return confirm('Xác nhận trả sách «<%= br.getBook() != null ? br.getBook().getTitle().replace("'","") : "này" %>»?')">
                                <input type="hidden" name="action" value="return">
                                <input type="hidden" name="borrowId" value="<%= br.getId() %>">
                                <input type="hidden" name="condition" id="condInput_<%= br.getId() %>" value="GOOD">
                                <button type="submit" class="btn btn-outline btn-sm" style="border-color:var(--success); color:var(--success);">
                                    <i class="fa-solid fa-rotate-left"></i> Xác nhận trả
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state" style="padding:40px 24px;">
                                <div class="empty-icon"><i class="fa-solid fa-book-open"></i></div>
                                <h3>Không có sách nào đang mượn</h3>
                                <p>Hiện tại không có sách nào đang trong trạng thái được mượn.</p>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- ==================== RETURNED/REJECTED SECTION ==================== -->
        <section class="admin-card">
            <div class="admin-section-head">
                <h2>
                    <i class="fa-solid fa-history" style="color:var(--text-muted);"></i>
                    Lịch sử phiếu mượn
                </h2>
                <div style="display:flex; gap:8px; align-items:center;">
                    <span class="badge badge-success"><%= returnedList != null ? returnedList.size() : 0 %> đã trả</span>
                    <span class="badge badge-danger"><%= rejectedList != null ? rejectedList.size() : 0 %> từ chối</span>
                </div>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width:50px;">STT</th>
                            <th>Tên người dùng</th>
                            <th>Sách</th>
                            <th style="width:110px;">Ngày mượn</th>
                            <th style="width:110px;">Ngày trả</th>
                            <th style="width:120px;">Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        java.util.List<BorrowRecord> historyList = new java.util.ArrayList<>();
                        if (returnedList != null) historyList.addAll(returnedList);
                        if (rejectedList != null) historyList.addAll(rejectedList);

                        if (!historyList.isEmpty()) {
                            int idx = 1;
                            for (BorrowRecord br : historyList) {
                    %>
                    <tr>
                        <td style="color:var(--text-muted); font-size:0.82rem;"><%= idx++ %></td>
                        <td>
                            <div style="font-weight:600; color:var(--text-primary);">
                                <%= br.getUser() != null ? (br.getUser().getFullName() != null ? br.getUser().getFullName() : br.getUser().getUsername()) : "N/A" %>
                            </div>
                        </td>
                        <td style="font-size:0.9rem; color:var(--text-secondary);">
                            <i class="fa-solid fa-book fa-xs" style="color:var(--primary); margin-right:4px;"></i>
                            <%= br.getBook() != null ? br.getBook().getTitle() : "#" + br.getBookId() %>
                        </td>
                        <td style="font-size:0.82rem; color:var(--text-muted);">
                            <%= br.getBorrowDate() != null ? br.getBorrowDate() : "—" %>
                        </td>
                        <td style="font-size:0.82rem; color:var(--text-muted);">
                            <%= br.getReturnDate() != null ? br.getReturnDate() : "—" %>
                        </td>
                        <td>
                            <% if ("RETURNED".equals(br.getStatus())) { %>
                            <span class="badge badge-success"><i class="fa-solid fa-check"></i> Đã trả</span>
                            <% } else if ("REJECTED".equals(br.getStatus())) { %>
                            <span class="badge badge-danger"><i class="fa-solid fa-xmark"></i> Từ chối</span>
                            <% } %>
                        </td>
                    </tr>
                    <%      }
                        } else { %>
                    <tr>
                        <td colspan="6">
                            <div class="empty-state" style="padding:40px 24px;">
                                <div class="empty-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
                                <h3>Chưa có lịch sử</h3>
                                <p>Lịch sử phiếu mượn đã hoàn thành sẽ hiển thị ở đây.</p>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<style>
.admin-nav-badge {
    background: var(--danger);
    color: #fff;
    font-size: 0.7rem;
    font-weight: 700;
    padding: 2px 7px;
    border-radius: 99px;
    margin-left: auto;
    min-width: 20px;
    text-align: center;
}
</style>
</body>
</html>
