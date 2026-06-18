<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    String currentPage = request.getAttribute("currentPage") != null
        ? (String) request.getAttribute("currentPage") : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Thư Viện FPT University" %></title>
    <meta name="description" content="<%= request.getAttribute("pageDesc") != null ? request.getAttribute("pageDesc") : "Hệ thống thư viện điện tử FPT University – Khám phá kho tàng tri thức" %>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Be+Vietnam+Pro:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<nav class="navbar" id="mainNavbar">
    <div class="container">
        <div class="navbar-inner">
            <a href="<%= request.getContextPath() %>/home" class="navbar-brand">
                <div class="brand-icon">📚</div>
                <span>FPT <span class="brand-accent">Library</span></span>
            </a>

            <ul class="navbar-nav">
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/home"
                       class="nav-link <%= "home".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/books"
                       class="nav-link <%= "books".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book"></i> Danh sách sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/about"
                       class="nav-link <%= "about".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-circle-info"></i> Giới thiệu
                    </a>
                </li>
                
                <% if (loggedUser != null) { %>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/borrow?action=list"
                       class="nav-link <%= "borrow".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book-bookmark"></i> Phiếu Mượn
                    </a>
                </li>
                <% } %>

                <% if (loggedUser != null && loggedUser.isAdminOrLibrarian()) { %>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/return-book"
                       class="nav-link <%= "return-book".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-rotate-left"></i> Trả Sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/shelf"
                       class="nav-link <%= "shelf".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-layer-group"></i> Vị trí kệ
                    </a>
                </li>
                <% } %>
            </ul>

            <div class="navbar-actions">
                <% if (loggedUser != null) { %>
                    <a href="<%= request.getContextPath() %>/user/profile" class="user-info" title="Hồ sơ cá nhân">
                        <i class="fa-solid fa-circle-user"></i>
                        <span><%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %></span>
                        <span class="user-role-badge <%= loggedUser.getRole().toLowerCase() %>">
                            <%= loggedUser.getRole() %>
                        </span>
                    </a>
                    <% if (loggedUser.isAdminOrLibrarian()) { %>
                        <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-outline btn-sm navbar-admin-link" title="Quản lý hệ thống">
                            <i class="fa-solid fa-user-gear"></i>
                        </a>
                    <% } %>
                    
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/login" class="btn-login">
                        <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
                    </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<script>
    (function(){
        var nav = document.getElementById('mainNavbar');
        window.addEventListener('scroll', function(){
            nav.classList.toggle('scrolled', window.scrollY > 10);
        });
    })();
</script>
</body>
</html>