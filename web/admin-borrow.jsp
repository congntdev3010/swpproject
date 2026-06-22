<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.swp391.model.User" %>
<%@ page import="com.swp391.model.BorrowRecord" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    if (logged == null || !logged.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<BorrowRecord> records = (List<BorrowRecord>) request.getAttribute("records");
    Integer total      = (Integer) request.getAttribute("total");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer currentPage= (Integer) request.getAttribute("currentPage");
    String statusFilter= (String)  request.getAttribute("statusFilter");
    String search      = (String)  request.getAttribute("search");
    String errorMsg    = (String)  request.getAttribute("errorMsg");

    if (total == null)      total = 0;
    if (totalPages == null) totalPages = 1;
    if (currentPage == null) currentPage = 1;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin | Quản lý Phiếu Mượn</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />
</head>
<body>
<div class="admin-shell">
    <aside class="admin-sidebar">
        <div class="admin-sidebar-brand">
            <div class="brand-icon">A</div>
            <div>
                <div class="brand-title">Admin Panel</div>
                <div class="brand-subtitle"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %> · <%= logged.getRole() %></div>
            </div>
        </div>

        <nav class="admin-nav" aria-label="Admin management menu">
            <a class="admin-nav-item admin-nav-user"
               href="<%= request.getContextPath() %>/admin/users">
                <i class="fa-solid fa-users"></i>
                <span>Quản lý người dùng</span>
            </a>
            <a class="admin-nav-item admin-nav-user active"
               href="<%= request.getContextPath() %>/admin/borrow">
                <i class="fa-solid fa-book-bookmark"></i>
                <span>Phiếu mượn</span>
            </a>
            <a class="admin-nav-item admin-nav-user"
               href="<%= request.getContextPath() %>/admin/return">
                <i class="fa-solid fa-rotate-left"></i>
                <span>Trả sách</span>
            </a>
        </nav>

        <div class="admin-sidebar-footer">
            <div class="admin-sidebar-card admin-sidebar-usercard">
                <div class="admin-sidebar-label">Logged as</div>
                <div class="admin-sidebar-value"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %></div>
                <div class="admin-sidebar-badge"><%= logged.getRole() %></div>
            </div>
            <a class="btn btn-outline btn-sm admin-sidebar-footer-btn" href="<%= request.getContextPath() %>/home">
                <i class="fa-solid fa-house"></i> Màn hình chính
            </a>
            <a class="btn btn-danger btn-sm admin-sidebar-footer-btn" href="<%= request.getContextPath() %>/logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </div>
    </aside>

    <main class="admin-main">
        <section class="admin-page-header">
            <div>
                <h1><i class="fa-solid fa-book-bookmark" style="color: var(--primary);"></i> Quản lý Phiếu Mượn</h1>
                <p>Xem và xác nhận toàn bộ phiếu mượn trong hệ thống (<%= total %> phiếu).</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/return" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-rotate-left"></i> Xử lý Trả Sách
                </a>
            </div>
        </section>

        <% if (errorMsg != null) { %>
        <div class="alert alert-danger"><%= errorMsg %></div>
        <% } %>

        <!-- Filter Bar -->
        <section class="admin-card admin-search-card">
            <form method="GET" action="<%= request.getContextPath() %>/admin/borrow" class="admin-search-form">
                <div class="admin-search-grid">
                    <div>
                        <label for="adminSearchQ">Tìm kiếm</label>
                        <input id="adminSearchQ" class="form-control" type="text" name="search"
                               placeholder="Tên sách, tên sinh viên..."
                               value="<%= search != null ? search : "" %>" />
                    </div>
                    <div>
                        <label for="adminSearchStatus">Trạng thái</label>
                        <select id="adminSearchStatus" class="form-select" name="status">
                            <option value="">-- Tất cả --</option>
                            <option value="PENDING"   <%= "PENDING".equals(statusFilter)   ? "selected" : "" %>>Chờ xác nhận</option>
                            <option value="BORROWING" <%= "BORROWING".equals(statusFilter) ? "selected" : "" %>>Đang mượn</option>
                            <option value="OVERDUE"   <%= "OVERDUE".equals(statusFilter)   ? "selected" : "" %>>Quá hạn</option>
                            <option value="RETURNED"  <%= "RETURNED".equals(statusFilter)  ? "selected" : "" %>>Đã trả</option>
                            <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Đã huỷ</option>
                            <option value="REJECTED"  <%= "REJECTED".equals(statusFilter)  ? "selected" : "" %>>Bị từ chối</option>
                        </select>
                    </div>
                    <div class="admin-search-submit">
                        <button class="btn btn-primary" type="submit">Tìm kiếm</button>
                    </div>
                </div>
            </form>
        </section>

        <!-- Table -->
        <section class="admin-card">
            <div class="admin-section-head">
                <h2>Danh sách Phiếu Mượn</h2>
                <span><%= total %> records</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>#ID</th>
                        <th>Sách</th>
                        <th>Người mượn</th>
                        <th>Ngày tạo</th>
                        <th>Hạn trả</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (records != null && !records.isEmpty()) {
                            for (BorrowRecord br : records) {
                                String statusCss = "status-" + br.getStatus().toLowerCase().replace("_", "-");
                                String statusLabel;
                                switch (br.getStatus()) {
                                    case "PENDING":   statusLabel = "Chờ xác nhận"; break;
                                    case "BORROWING": statusLabel = "Đang mượn";    break;
                                    case "OVERDUE":   statusLabel = "Quá hạn";      break;
                                    case "RETURNED":  statusLabel = "Đã trả";       break;
                                    case "CANCELLED": statusLabel = "Đã huỷ";       break;
                                    case "REJECTED":  statusLabel = "Bị từ chối";   break;
                                    default:          statusLabel = br.getStatus();
                                }
                    %>
                    <tr>
                        <td><strong>#<%= br.getId() %></strong></td>
                        <td>
                            <div><strong><%= br.getBook() != null ? br.getBook().getTitle() : "—" %></strong></div>
                            <small style="color: var(--text-muted);">ISBN: <%= br.getBook() != null && br.getBook().getIsbn() != null ? br.getBook().getIsbn() : "" %></small>
                        </td>
                        <td>
                            <div><%= br.getUser() != null ? br.getUser().getFullName() : "—" %></div>
                            <small style="color: var(--text-muted);"><%= br.getUser() != null && br.getUser().getStudentId() != null ? br.getUser().getStudentId() : "" %></small>
                        </td>
                        <td><%= br.getCreatedAt() != null ? br.getCreatedAt().toLocalDate() : "—" %></td>
                        <td>
                            <% if (br.getDueDate() != null) { %>
                                <span style="<%= java.time.LocalDate.now().isAfter(br.getDueDate()) && "BORROWING".equals(br.getStatus()) ? "color:#dc2626;font-weight:700;" : "" %>">
                                    <%= br.getDueDate() %>
                                </span>
                            <% } else { %>—<% } %>
                        </td>
                        <td><span class="badge <%= "BORROWING".equals(br.getStatus()) ? "badge-success" : "PENDING".equals(br.getStatus()) ? "badge-warning" : "OVERDUE".equals(br.getStatus()) ? "badge-danger" : "badge-primary" %>"><%= statusLabel %></span></td>
                        <td>
                            <div class="admin-row-actions">
                                <a href="<%= request.getContextPath() %>/borrow?action=detail&id=<%= br.getId() %>"
                                   class="btn btn-sm btn-outline" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i> Xem
                                </a>
                                <% if ("PENDING".equals(br.getStatus())) { %>
                                <a href="<%= request.getContextPath() %>/borrow?action=confirm&id=<%= br.getId() %>"
                                   class="btn btn-sm btn-primary" title="Xác nhận">
                                    <i class="fa-solid fa-check"></i> Duyệt
                                </a>
                                <% } %>
                                <% if ("BORROWING".equals(br.getStatus()) || "OVERDUE".equals(br.getStatus())) { %>
                                <a href="<%= request.getContextPath() %>/admin/return?action=preview&id=<%= br.getId() %>"
                                   class="btn btn-sm btn-outline" style="color: #d97706; border-color: #d97706;" title="Trả sách">
                                    <i class="fa-solid fa-rotate-left"></i> Trả
                                </a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <h3>Không có dữ liệu</h3>
                                <p>Chưa có phiếu mượn nào để hiển thị.</p>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div style="padding: 16px 20px; border-top: 1px solid var(--border);">
                <nav aria-label="Phân trang">
                    <ul class="pagination">
                        <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                            <a class="page-link" href="<%= request.getContextPath() %>/admin/borrow?page=<%= currentPage - 1 %><%= statusFilter != null ? "&status=" + statusFilter : "" %><%= search != null ? "&search=" + search : "" %>">
                                <i class="fa-solid fa-chevron-left fa-xs"></i>
                            </a>
                        </li>
                        <% for (int p = 1; p <= totalPages; p++) { %>
                        <li class="page-item <%= p == currentPage ? "active" : "" %>">
                            <a class="page-link" href="<%= request.getContextPath() %>/admin/borrow?page=<%= p %><%= statusFilter != null ? "&status=" + statusFilter : "" %><%= search != null ? "&search=" + search : "" %>"><%= p %></a>
                        </li>
                        <% } %>
                        <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                            <a class="page-link" href="<%= request.getContextPath() %>/admin/borrow?page=<%= currentPage + 1 %><%= statusFilter != null ? "&status=" + statusFilter : "" %><%= search != null ? "&search=" + search : "" %>">
                                <i class="fa-solid fa-chevron-right fa-xs"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
            <% } %>
        </section>
    </main>
</div>
</body>
</html>
