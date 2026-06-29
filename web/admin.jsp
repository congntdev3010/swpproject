<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.swp391.model.User" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    if (logged == null || !logged.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin | User Management</title>
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
    <a class="admin-nav-item <%= "users".equals(request.getAttribute("activeTab")) || request.getAttribute("activeTab") != null && !"borrow".equals(request.getAttribute("activeTab")) ? "active" : "" %>"
       href="<%= request.getContextPath() %>/admin/users">
        <i class="fa-solid fa-users"></i>
        <span>Quản lý người dùng</span>
    </a>
    <a class="admin-nav-item <%= "borrow".equals(request.getAttribute("activeTab")) ? "active" : "" %>"
       href="<%= request.getContextPath() %>/admin/borrow">
        <i class="fa-solid fa-book-open-reader"></i>
        <span>Quản lý mượn sách</span>
        <%
            try {
                com.swp391.dao.BorrowDAO borrowDao = new com.swp391.dao.BorrowDAO();
                int pendingCnt = borrowDao.countPending();
                if (pendingCnt > 0) {
        %>
        <span style="background:var(--danger);color:#fff;font-size:0.7rem;font-weight:800;padding:2px 7px;border-radius:99px;margin-left:auto;"><%= pendingCnt %></span>
        <%  }
            } catch (Exception ex) { } %>
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
        <section id="user-management" class="admin-page-header">
            <div>
                <h1>Quản lý người dùng</h1>
                <p>Trang quản trị dành cho role admin và librarian, dùng để quản lý user theo phân quyền.</p>
            </div>
        </section>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <section class="admin-card admin-search-card">
            <form method="get" action="<%= request.getContextPath() %>/admin/users" class="admin-search-form">
                <div class="admin-search-grid">
                    <div>
                        <label for="adminSearchQ">Tìm kiếm</label>
                        <input id="adminSearchQ" class="form-control" type="text" name="q" placeholder="Username, họ tên, email"
                               value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>" />
                    </div>
                    <div>
                        <label for="adminSearchRole">Role</label>
                        <select id="adminSearchRole" class="form-select" name="role">
                            <option value="">-- Tất cả vai trò --</option>
                            <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>ADMIN</option>
                            <option value="LIBRARIAN" <%= "LIBRARIAN".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>LIBRARIAN</option>
                            <option value="READER" <%= "READER".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>READER</option>
                        </select>
                    </div>
                    <div>
                        <label for="adminSearchActive">Trạng thái</label>
                        <select id="adminSearchActive" class="form-select" name="active">
                            <option value="">-- Tất cả --</option>
                            <option value="1" <%= Integer.valueOf(1).equals(request.getAttribute("activeFilter")) ? "selected" : "" %>>Active</option>
                            <option value="0" <%= Integer.valueOf(0).equals(request.getAttribute("activeFilter")) ? "selected" : "" %>>Locked</option>
                        </select>
                    </div>
                    <div class="admin-search-submit">
                        <button class="btn btn-primary" type="submit">Tìm kiếm</button>
                    </div>
                </div>
            </form>
        </section>

        <section id="user-table" class="admin-card">
            <div class="admin-section-head">
                <h2>Danh sách người dùng</h2>
                <span><%= users != null ? users.size() : 0 %> records</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Họ tên</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Active</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (users != null && !users.isEmpty()) {
                            for (User u : users) {
                    %>
                    <tr>
                        <td><%= u.getId() %></td>
                        <td><%= u.getUsername() %></td>
                        <td><%= u.getFullName() %></td>
                        <td><%= u.getEmail() %></td>
                        <td><span class="badge badge-primary"><%= u.getRole() %></span></td>
                        <td>
                            <% if (u.getActive() == 1) { %>
                                <span class="badge badge-success">Active</span>
                            <% } else { %>
                                <span class="badge badge-danger">Locked</span>
                            <% } %>
                        </td>
                        <td>
                            <div class="admin-row-actions">
                                <a class="btn btn-sm btn-outline" href="<%= request.getContextPath() %>/user/profile?id=<%= u.getId() %>">View</a>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users">
                                    <input type="hidden" name="action" value="update" />
                                    <input type="hidden" name="id" value="<%= u.getId() %>" />
                                    <input type="hidden" name="fullName" value="<%= u.getFullName() != null ? u.getFullName() : "" %>" />
                                    <input type="hidden" name="email" value="<%= u.getEmail() != null ? u.getEmail() : "" %>" />
                                    <input type="hidden" name="phone" value="<%= u.getPhone() != null ? u.getPhone() : "" %>" />
                                    <input type="hidden" name="studentId" value="<%= u.getStudentId() != null ? u.getStudentId() : "" %>" />
                                    <input type="hidden" name="avatar" value="<%= u.getAvatar() != null ? u.getAvatar() : "" %>" />
                                    <input type="hidden" name="role" value="<%= u.getRole() != null ? u.getRole() : "READER" %>" />
                                    <input type="hidden" name="active" value="<%= u.getActive() %>" />
                                    <button class="btn btn-sm btn-primary" type="submit">Save</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users">
                                    <input type="hidden" name="action" value="<%= u.getActive() == 1 ? "lock" : "unlock" %>" />
                                    <input type="hidden" name="id" value="<%= u.getId() %>" />
                                    <button class="btn btn-sm btn-outline" type="submit"><%= u.getActive() == 1 ? "Lock" : "Unlock" %></button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/admin/users" onsubmit="return confirm('Xác nhận xóa người dùng này?');">
                                    <input type="hidden" name="action" value="delete" />
                                    <input type="hidden" name="id" value="<%= u.getId() %>" />
                                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                                </form>
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
                                <p>Chưa có người dùng nào để hiển thị.</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

        <section id="create-user" class="admin-card">
            <div class="admin-section-head">
                <h2>Tạo người dùng mới</h2>
                <span>CRUD</span>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/admin/users" class="admin-form-grid">
                <input type="hidden" name="action" value="create" />
                <div>
                    <label for="createUsername">Username</label>
                    <input id="createUsername" class="form-control" name="username" placeholder="username" required />
                </div>
                <div>
                    <label for="createPassword">Password</label>
                    <input id="createPassword" class="form-control" name="password" placeholder="password" />
                </div>
                <div>
                    <label for="createFullName">Họ tên</label>
                    <input id="createFullName" class="form-control" name="fullName" placeholder="Họ tên" />
                </div>
                <div>
                    <label for="createEmail">Email</label>
                    <input id="createEmail" class="form-control" name="email" placeholder="Email" />
                </div>
                <div>
                    <label for="createPhone">Phone</label>
                    <input id="createPhone" class="form-control" name="phone" placeholder="Phone" />
                </div>
                <div>
                    <label for="createStudentId">Student ID</label>
                    <input id="createStudentId" class="form-control" name="studentId" placeholder="Student ID" />
                </div>
                <div>
                    <label for="createAvatar">Avatar</label>
                    <input id="createAvatar" class="form-control" name="avatar" placeholder="Avatar URL" />
                </div>
                <div>
                    <label for="createRole">Role</label>
                    <select id="createRole" class="form-select" name="role">
                        <option value="READER">READER</option>
                        <option value="LIBRARIAN">LIBRARIAN</option>
                        <option value="ADMIN">ADMIN</option>
                    </select>
                </div>
                <div class="admin-form-actions">
                    <button class="btn btn-primary" type="submit">Tạo user</button>
                </div>
            </form>
        </section>


    </main>
</div>
</body>
</html>
