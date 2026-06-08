<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.swp391.model.User" %>
<jsp:include page="/WEB-INF/jsp/header.jsp" />
<div class="container" style="padding:2rem;">
    <h2>Quản lý người dùng</h2>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("success") %></div>
    <% } %>

    <form method="get" action="<%= request.getContextPath() %>/users" style="margin-bottom:1rem;">
        <input type="text" name="q" placeholder="Tìm theo tên đăng nhập, tên đầy đủ, email" value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>" />
        <select name="role">
            <option value="">-- Tất cả vai trò --</option>
            <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>ADMIN</option>
            <option value="LIBRARIAN" <%= "LIBRARIAN".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>LIBRARIAN</option>
            <option value="READER" <%= "READER".equals(request.getAttribute("roleFilter")) ? "selected" : "" %>>READER</option>
        </select>
        <select name="active">
            <option value="">-- Tất cả trạng thái --</option>
            <option value="1" <%= Integer.valueOf(1).equals(request.getAttribute("activeFilter")) ? "selected" : "" %>>Active</option>
            <option value="0" <%= Integer.valueOf(0).equals(request.getAttribute("activeFilter")) ? "selected" : "" %>>Locked</option>
        </select>
        <button class="btn">Tìm</button>
    </form>

    <table class="table">
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
            List<User> users = (List<User>) request.getAttribute("users");
            User logged = (User) session.getAttribute("loggedUser");
            if (users != null) {
                for (User u : users) {
        %>
            <tr>
                <td><%= u.getId() %></td>
                <td><a href="<%= request.getContextPath()%>/user/profile?id=<%=u.getId()%>"><%= u.getUsername() %></a></td>
                <td><%= u.getFullName() %></td>
                <td><%= u.getEmail() %></td>
                <td><%= u.getRole() %></td>
                <td><%= u.getActive() == 1 ? "Active" : "Locked" %></td>
                <td>
                    <a href="<%= request.getContextPath()%>/user/profile?id=<%=u.getId()%>">View</a>
                    <% if (logged != null && logged.isAdmin()) { %>
                        | <form method="post" action="<%= request.getContextPath()%>/admin/users" style="display:inline;">
                            <input type="hidden" name="action" value="delete" />
                            <input type="hidden" name="id" value="<%= u.getId() %>" />
                            <button onclick="return confirm('Xác nhận xóa?')">Delete</button>
                          </form>
                        | <form method="post" action="<%= request.getContextPath()%>/admin/users" style="display:inline;">
                            <input type="hidden" name="action" value="<%= u.getActive()==1?"lock":"unlock" %>" />
                            <input type="hidden" name="id" value="<%= u.getId() %>" />
                            <button><%= u.getActive()==1?"Lock":"Unlock" %></button>
                          </form>
                    <% } %>
                </td>
            </tr>
        <%      }
            }
        %>
        </tbody>
    </table>

    <% if (session.getAttribute("loggedUser") != null && ((User)session.getAttribute("loggedUser")).isAdmin()) { %>
        <h3>Tạo người dùng mới</h3>
        <form method="post" action="<%= request.getContextPath()%>/admin/users">
            <input type="hidden" name="action" value="create" />
            <input name="username" placeholder="username" required />
            <input name="password" placeholder="password" />
            <input name="fullName" placeholder="Họ tên" />
            <input name="email" placeholder="Email" />
            <select name="role">
                <option value="READER">READER</option>
                <option value="LIBRARIAN">LIBRARIAN</option>
                <option value="ADMIN">ADMIN</option>
            </select>
            <button type="submit">Tạo</button>
        </form>
    <% } %>

</div>
<jsp:include page="/WEB-INF/jsp/footer.jsp" />

