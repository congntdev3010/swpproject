<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.swp391.model.User" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    List<User> users = (List<User>) request.getAttribute("users");
    String ctx = request.getContextPath();
    String qVal = request.getAttribute("q") != null ? (String) request.getAttribute("q") : "";
    String roleFilter = request.getAttribute("roleFilter") != null ? (String) request.getAttribute("roleFilter") : "";
    Object activeFilterObj = request.getAttribute("activeFilter");
%>
<jsp:include page="/WEB-INF/jsp/header.jsp" />

<div class="container" style="padding:2rem;">
    <h2>Quản lý người dùng</h2>

    <%-- Thông báo lỗi / thành công --%>
    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
    <div class="alert alert-success"><%= request.getAttribute("success") %></div>
    <% } %>

    <%-- ===== 1. TẠO NGƯỜI DÙNG MỚI (chỉ ADMIN) ===== --%>
    <% if (logged != null && logged.isAdmin()) { %>
    <div style="background:#f8f9fa; border:1px solid #dee2e6; border-radius:8px; padding:1.2rem 1.5rem; margin-bottom:1.5rem;">
        <h4 style="margin-top:0; margin-bottom:1rem;">Tạo người dùng mới</h4>
        <form method="post" action="<%= ctx %>/admin/users" style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
            <input type="hidden" name="action" value="create" />
            <input name="username"  placeholder="Username"   required style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;" />
            <input name="password"  placeholder="Password"   type="password" style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;" />
            <input name="fullName"  placeholder="Họ tên"     style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;" />
            <input name="email"     placeholder="Email"      type="email" style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;" />
            <select name="role" style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;">
                <option value="READER">READER</option>
                <option value="LIBRARIAN">LIBRARIAN</option>
                <option value="ADMIN">ADMIN</option>
            </select>
            <button type="submit" class="btn btn-primary">Tạo</button>
        </form>
    </div>
    <% } %>

    <%-- ===== 2. TÌM KIẾM NGƯỜI DÙNG ===== --%>
    <form method="get" action="<%= ctx %>/users" style="display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:1.2rem;">
        <input type="text" name="q"
               placeholder="Tìm theo tên đăng nhập, họ tên, email"
               value="<%= qVal %>"
               style="flex:1; min-width:200px; padding:6px 10px; border:1px solid #ced4da; border-radius:4px;" />
        <select name="role" style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;">
            <option value="">-- Tất cả vai trò --</option>
            <option value="ADMIN"      <%= "ADMIN".equals(roleFilter)      ? "selected" : "" %>>ADMIN</option>
            <option value="LIBRARIAN"  <%= "LIBRARIAN".equals(roleFilter)  ? "selected" : "" %>>LIBRARIAN</option>
            <option value="READER"     <%= "READER".equals(roleFilter)     ? "selected" : "" %>>READER</option>
        </select>
        <select name="active" style="padding:6px 10px; border:1px solid #ced4da; border-radius:4px;">
            <option value="">-- Tất cả trạng thái --</option>
            <option value="1" <%= Integer.valueOf(1).equals(activeFilterObj) ? "selected" : "" %>>Active</option>
            <option value="0" <%= Integer.valueOf(0).equals(activeFilterObj) ? "selected" : "" %>>Locked</option>
        </select>
        <button type="submit" class="btn">Tìm kiếm</button>
    </form>

    <%-- ===== 3. DANH SÁCH NGƯỜI DÙNG ===== --%>
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Họ tên</th>
                <th>Email</th>
                <th>Role</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
        <% if (users != null && !users.isEmpty()) {
               for (User u : users) { %>
        <tr>
            <td><%= u.getId() %></td>
            <td>
                <a href="<%= ctx %>/user/profile?id=<%= u.getId() %>"><%= u.getUsername() %></a>
            </td>
            <td><%= u.getFullName() %></td>
            <td><%= u.getEmail() %></td>
            <td><%= u.getRole() %></td>
            <td><%= u.getActive() == 1 ? "Active" : "Locked" %></td>
            <td style="white-space:nowrap;">
                <a href="<%= ctx %>/user/profile?id=<%= u.getId() %>">View</a>
                <% if (logged != null && logged.isAdmin()) { %>
                &nbsp;|&nbsp;
                <form method="post" action="<%= ctx %>/admin/users" style="display:inline;">
                    <input type="hidden" name="action" value="delete" />
                    <input type="hidden" name="id" value="<%= u.getId() %>" />
                    <button onclick="return confirm('Xác nhận xóa người dùng này?')">Delete</button>
                </form>
                &nbsp;|&nbsp;
                <form method="post" action="<%= ctx %>/admin/users" style="display:inline;">
                    <input type="hidden" name="action" value="<%= u.getActive() == 1 ? "lock" : "unlock" %>" />
                    <input type="hidden" name="id" value="<%= u.getId() %>" />
                    <button><%= u.getActive() == 1 ? "Lock" : "Unlock" %></button>
                </form>
                <% } %>
            </td>
        </tr>
        <% } } else { %>
        <tr>
            <td colspan="7" style="text-align:center; color:#888; padding:1.5rem;">
                Không tìm thấy người dùng nào.
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/jsp/footer.jsp" />