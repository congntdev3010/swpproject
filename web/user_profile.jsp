<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<jsp:include page="/WEB-INF/jsp/header.jsp" />
<div class="container" style="padding:2rem;">
    <h2>Thông tin cá nhân</h2>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("success") %></div>
    <% } %>

    <%
        User profile = (User) request.getAttribute("profileUser");
        User logged = (User) session.getAttribute("loggedUser");
        if (profile == null) {
    %>
        <div>Không tìm thấy người dùng.</div>
    <% } else { %>
    <form method="post" action="<%= request.getContextPath()%>/user/profile">
        <input type="hidden" name="id" value="<%= profile.getId() %>" />
        <div class="form-group">
            <label>Username</label>
            <input value="<%= profile.getUsername() %>" disabled />
        </div>
        <div class="form-group">
            <label>Họ tên</label>
            <input name="fullName" value="<%= profile.getFullName() != null ? profile.getFullName() : "" %>" />
        </div>
        <div class="form-group">
            <label>Email</label>
            <input name="email" value="<%= profile.getEmail() != null ? profile.getEmail() : "" %>" />
        </div>
        <div class="form-group">
            <label>Phone</label>
            <input name="phone" value="<%= profile.getPhone() != null ? profile.getPhone() : "" %>" />
        </div>
        <div class="form-group">
            <label>Student ID</label>
            <input name="studentId" value="<%= profile.getStudentId() != null ? profile.getStudentId() : "" %>" />
        </div>
        <div class="form-group">
            <label>Avatar URL</label>
            <input name="avatar" value="<%= profile.getAvatar() != null ? profile.getAvatar() : "" %>" />
        </div>
        <% if (logged != null && logged.isAdmin()) { %>
            <div class="form-group">
                <label>Role</label>
                <select name="role">
                    <option value="ADMIN" <%= "ADMIN".equals(profile.getRole())?"selected":"" %>>ADMIN</option>
                    <option value="LIBRARIAN" <%= "LIBRARIAN".equals(profile.getRole())?"selected":"" %>>LIBRARIAN</option>
                    <option value="READER" <%= "READER".equals(profile.getRole())?"selected":"" %>>READER</option>
                </select>
            </div>
            <div class="form-group">
                <label>Active</label>
                <select name="active">
                    <option value="1" <%= profile.getActive()==1?"selected":"" %>>Active</option>
                    <option value="0" <%= profile.getActive()==0?"selected":"" %>>Locked</option>
                </select>
            </div>
        <% } %>
        <div class="form-group">
            <label>New password (leave empty to keep)</label>
            <input type="password" name="newPassword" />
        </div>
        <button type="submit" class="btn btn-primary">Lưu</button>
    </form>
    <% } %>
</div>
<jsp:include page="/WEB-INF/jsp/footer.jsp" />

