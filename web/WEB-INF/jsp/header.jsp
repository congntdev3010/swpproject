<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<%
    User navUser = (User) session.getAttribute("loggedUser");
    String navCurrentPage = "";
    if (request.getAttribute("activePage") instanceof String) {
        navCurrentPage = (String) request.getAttribute("activePage");
    } else if (request.getAttribute("currentPage") instanceof String) {
        navCurrentPage = (String) request.getAttribute("currentPage");
    }
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
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
                       class="nav-link <%= "home".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/books"
                       class="nav-link <%= "books".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book"></i> Danh sách sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/about"
                       class="nav-link <%= "about".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-circle-info"></i> Giới thiệu
                    </a>
                </li>
                
                <% if (navUser != null && !navUser.isAdminOrLibrarian()) { %>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/borrow/my"
                       class="nav-link <%= "borrows".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book-open"></i> Mượn sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/reservation/my"
                       class="nav-link <%= "reservations".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-bookmark"></i> Đặt trước
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/fine/my"
                       class="nav-link <%= "fines".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-coins"></i> Phạt
                    </a>
                </li>
                <li class="nav-item" style="position:relative;">
                    <a href="<%= request.getContextPath() %>/notification/my"
                       class="nav-link <%= "notifications".equals(navCurrentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-bell"></i> Thông báo
                    </a>
                </li>
                <% } %>
                <% if (navUser != null && navUser.isAdminOrLibrarian()) { %>
                <% 
                    boolean isManageActive = java.util.Arrays.asList("borrows", "reservations", "fines", "notifications", "shelf", "authors", "categories", "users").contains(navCurrentPage);
                %>
                <li class="nav-item dropdown">
                    <a href="#" class="nav-link <%= isManageActive ? "active" : "" %>">
                        <i class="fa-solid fa-briefcase"></i> Quản lý <i class="fa-solid fa-chevron-down fa-xs" style="margin-left: 4px;"></i>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="<%= request.getContextPath() %>/borrow/list"
                               class="dropdown-item <%= "borrows".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-hand-holding-hand"></i> Mượn sách
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/reservation/list"
                               class="dropdown-item <%= "reservations".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-list-check"></i> Đặt trước
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/fine/list"
                               class="dropdown-item <%= "fines".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-file-invoice-dollar"></i> Phạt
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/notification/manage"
                               class="dropdown-item <%= "notifications".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-bullhorn"></i> Thông báo
                            </a>
                        </li>
                        <li class="dropdown-divider"></li>
                        <li>
                            <a href="<%= request.getContextPath() %>/shelf"
                               class="dropdown-item <%= "shelf".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-layer-group"></i> Vị trí kệ
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/authors"
                               class="dropdown-item <%= "authors".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-user-pen"></i> Tác giả
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/categories"
                               class="dropdown-item <%= "categories".equals(navCurrentPage) ? "active" : "" %>">
                                <i class="fa-solid fa-tags"></i> Danh mục
                            </a>
                        </li>
                        <li class="dropdown-divider"></li>
                        <% if (navUser.isAdmin()) { %>
                        <li>
                            <a href="<%= request.getContextPath() %>/users" class="dropdown-item">
                                <i class="fa-solid fa-user-gear"></i> Tài khoản
                            </a>
                        </li>
                        <% } %>
                    </ul>
                </li>
                <% } %>
            </ul>

            <div class="navbar-actions">
                <% if (navUser != null) { %>
                    <a href="<%= request.getContextPath() %>/user/profile" class="user-info" title="Hồ sơ cá nhân">
                        <i class="fa-solid fa-circle-user fa-xl"></i>
                        <div class="user-info-text">
                            <span class="user-info-name"><%= navUser.getFullName() != null ? navUser.getFullName() : navUser.getUsername() %></span>
                            <span class="user-role-badge <%= navUser.getRole().toLowerCase() %>"><%= navUser.getRole() %></span>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm btn-logout" title="Đăng xuất">
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
