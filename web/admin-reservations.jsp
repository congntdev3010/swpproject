<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.swp391.model.User" %>
<%@ page import="com.swp391.model.BorrowRecord" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    if (logged == null || !logged.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<BorrowRecord> reservations = (List<BorrowRecord>) request.getAttribute("reservations");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin | Reservation Management</title>
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
            <a class="admin-nav-item admin-nav-user" href="<%= request.getContextPath() %>/admin/users">
                <i class="fa-solid fa-users"></i>
                <span>Quản lý người dùng</span>
            </a>
            <a class="admin-nav-item admin-nav-user active" href="<%= request.getContextPath() %>/admin/reservation">
                <i class="fa-solid fa-list-check"></i>
                <span>Duyệt đơn mượn</span>
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
                <h1>Duyệt đơn mượn sách</h1>
                <p>Quản lý các yêu cầu mượn sách từ người dùng.</p>
            </div>
        </section>

        <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>
        <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success"><%= request.getParameter("success") %></div>
        <% } %>

        <section class="admin-card admin-search-card">
            <form method="get" action="<%= request.getContextPath() %>/admin/reservation" class="admin-search-form">
                <div class="admin-search-grid" style="grid-template-columns: 1fr auto;">
                    <div>
                        <label for="adminSearchQ">Tìm kiếm sách, người dùng</label>
                        <input id="adminSearchQ" class="form-control" type="text" name="q" placeholder="Nhập từ khóa..."
                               value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>" />
                    </div>
                    <div class="admin-search-submit">
                        <button class="btn btn-primary" type="submit">Tìm kiếm</button>
                    </div>
                </div>
            </form>
        </section>

        <section class="admin-card">
            <div class="admin-section-head">
                <h2>Danh sách chờ duyệt</h2>
                <span><%= reservations != null ? reservations.size() : 0 %> đơn</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Người mượn</th>
                        <th>Sách</th>
                        <th>Ngày yêu cầu</th>
                        <th>Ghi chú</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (reservations != null && !reservations.isEmpty()) {
                            for (BorrowRecord r : reservations) {
                    %>
                    <tr>
                        <td>#<%= r.getId() %></td>
                        <td>
                            <strong><%= r.getUser() != null ? r.getUser().getFullName() : "" %></strong><br>
                            <small class="text-muted"><%= r.getUser() != null ? r.getUser().getStudentId() : "" %></small>
                        </td>
                        <td>
                            <strong><%= r.getBook() != null ? r.getBook().getTitle() : "" %></strong><br>
                            <small class="text-muted">ISBN: <%= r.getBook() != null ? r.getBook().getIsbn() : "" %></small>
                        </td>
                        <td><%= r.getCreatedAt() != null ? r.getCreatedAt().format(dtf) : "" %></td>
                        <td><%= r.getNote() != null ? r.getNote() : "" %></td>
                        <td>
                            <div class="admin-row-actions">
                                <form method="post" action="<%= request.getContextPath() %>/admin/reservation">
                                    <input type="hidden" name="action" value="approve" />
                                    <input type="hidden" name="id" value="<%= r.getId() %>" />
                                    <button class="btn btn-sm btn-success" type="submit"><i class="fa-solid fa-check"></i> Duyệt</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/admin/reservation" onsubmit="return confirm('Bạn muốn từ chối đơn mượn này?');">
                                    <input type="hidden" name="action" value="reject" />
                                    <input type="hidden" name="id" value="<%= r.getId() %>" />
                                    <button class="btn btn-sm btn-danger" type="submit"><i class="fa-solid fa-xmark"></i> Từ chối</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6">
                            <div class="empty-state">
                                <h3>Không có đơn mượn</h3>
                                <p>Hiện không có yêu cầu mượn sách nào đang chờ duyệt.</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
            
            <%
                Integer totalPages = (Integer) request.getAttribute("totalPages");
                Integer currentPage = (Integer) request.getAttribute("currentPage");
                if (totalPages != null && totalPages > 1) {
            %>
            <div style="margin-top: 15px; display: flex; justify-content: center;">
                <nav aria-label="Phân trang">
                    <ul class="pagination">
                        <% for (int i = 1; i <= totalPages; i++) { %>
                            <li class="page-item <%= (currentPage != null && currentPage == i) ? "active" : "" %>">
                                <a class="page-link" href="<%= request.getContextPath() %>/admin/reservation?page=<%= i %>&q=<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>"><%= i %></a>
                            </li>
                        <% } %>
                    </ul>
                </nav>
            </div>
            <% } %>
        </section>
    </main>
</div>
</body>
</html>
