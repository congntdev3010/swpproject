<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    String currentPage = request.getAttribute("currentPage") != null
        ? (String) request.getAttribute("currentPage") : "";
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Thư Viện FPT" %></title>
    <meta name="description" content="<%= request.getAttribute("pageDesc") != null ? request.getAttribute("pageDesc") : "Hệ thống thư viện điện tử FPT - Khám phá kho tàng tri thức" %>">
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Main CSS -->
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
</head>
<body>

<!-- ===== NAVBAR ===== -->
<nav class="navbar" id="mainNavbar">
    <div class="container">
        <div class="navbar-inner">
            <!-- Brand -->
            <a href="<%= contextPath %>/home" class="navbar-brand">
                <div class="brand-icon">📚</div>
                <span>FPT Library</span>
            </a>

            <!-- Nav Links -->
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a href="<%= contextPath %>/home"
                       class="nav-link <%= "home".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= contextPath %>/books"
                       class="nav-link <%= "books".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book"></i> Danh sách sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= contextPath %>/about"
                       class="nav-link <%= "about".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-circle-info"></i> Giới thiệu
                    </a>
                </li>
            </ul>

            <!-- Actions -->
            <div class="navbar-actions">
                <% if (loggedUser != null) { %>
                    <div class="user-info">
                        <i class="fa-solid fa-circle-user"></i>
                        <span><%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %></span>
                        <span class="user-role-badge <%= loggedUser.getRole().toLowerCase() %>">
                            <%= loggedUser.getRole() %>
                        </span>
                    </div>
                    <a href="<%= contextPath %>/logout" class="btn btn-outline btn-sm">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </a>
                <% } else { %>
                    <a href="<%= contextPath %>/login" class="btn-login">
                        <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
                    </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<!-- Sticky navbar scroll effect -->
<script>
    (function(){
        var nav = document.getElementById('mainNavbar');
        window.addEventListener('scroll', function(){
            nav.classList.toggle('scrolled', window.scrollY > 10);
        });
    })();
</script>
