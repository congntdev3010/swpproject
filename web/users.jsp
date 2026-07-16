<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.swp391.model.User" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    Integer totalPages   = (Integer) request.getAttribute("totalPages");
    Integer currentPageNum = (Integer) request.getAttribute("currentPageNum");
    String q           = (String) request.getAttribute("q");
    String roleFilter  = (String) request.getAttribute("roleFilter");
    Integer activeFilter = (Integer) request.getAttribute("activeFilter");
    String sortField   = (String) request.getAttribute("sortField");
    String sortOrder   = (String) request.getAttribute("sortOrder");

    // Read session messages (pattern consistent with author/category)
    String sessionSuccess = (String) session.getAttribute("successMsg");
    if (sessionSuccess != null) { request.setAttribute("successMsg", sessionSuccess); session.removeAttribute("successMsg"); }
    String sessionError = (String) session.getAttribute("errorMsg");
    if (sessionError != null) { request.setAttribute("errorMsg", sessionError); session.removeAttribute("errorMsg"); }

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg   = (String) request.getAttribute("errorMsg");
    // Also support legacy request params from AdminUserServlet redirects
    if (successMsg == null) successMsg = (String) request.getAttribute("success");
    if (errorMsg   == null) errorMsg   = (String) request.getAttribute("error");

    User logged = (User) session.getAttribute("loggedUser");
    boolean isAdmin = (logged != null && logged.isAdmin());
    String ctx = request.getContextPath();

    if (totalRecords   == null) totalRecords   = (users != null ? users.size() : 0);
    if (totalPages     == null) totalPages     = 1;
    if (currentPageNum == null) currentPageNum = 1;
    if (q              == null) q              = "";
    if (sortField      == null) sortField      = "username";
    if (sortOrder      == null) sortOrder      = "ASC";

    String nextOrder = "ASC".equals(sortOrder) ? "DESC" : "ASC";
%>

<main class="page-wrapper">

    <!-- ===== PAGE HEADER ===== -->
    <div class="books-page-header">
        <div class="container">
            <div class="books-page-header-inner">
                <div>
                    <div class="hero-eyebrow" style="margin-bottom:10px;">
                        <i class="fa-solid fa-users"></i> Người dùng
                    </div>
                    <h1 class="books-page-title">Quản lý Người dùng</h1>
                    <p class="books-page-subtitle">Xem, tìm kiếm và quản lý tài khoản trong hệ thống thư viện</p>
                </div>
                <div class="books-page-stats">
                    <div class="bps-item">
                        <span class="bps-num"><%= totalRecords %></span>
                        <span class="bps-lbl">Người dùng</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container" style="padding-top:28px;">

        <!-- ===== SEARCH BAR ===== -->
        <form id="searchForm" action="<%= ctx %>/users" method="get">
            <input type="hidden" name="sort"  value="<%= sortField %>">
            <input type="hidden" name="order" value="<%= sortOrder %>">
            <input type="hidden" name="page"  value="1">

            <div class="search-bar-wrapper">
                <div class="search-bar-inner">
                    <!-- Keyword -->
                    <div class="search-field" style="flex:2;">
                        <label for="keywordInput">Tìm kiếm người dùng</label>
                        <div class="search-input-wrap">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" id="keywordInput" name="q"
                                   class="form-control"
                                   placeholder="Tìm theo tên đăng nhập, họ tên, email..."
                                   value="<%= q %>"
                                   maxlength="200"
                                   autocomplete="off">
                        </div>
                    </div>

                    <!-- Role filter -->
                    <div class="search-field select-field">
                        <label for="roleSelect">Vai trò</label>
                        <select id="roleSelect" name="role" class="form-select">
                            <option value="">-- Tất cả vai trò --</option>
                            <option value="ADMIN"     <%= "ADMIN".equals(roleFilter)     ? "selected" : "" %>>ADMIN</option>
                            <option value="LIBRARIAN" <%= "LIBRARIAN".equals(roleFilter) ? "selected" : "" %>>LIBRARIAN</option>
                            <option value="READER"    <%= "READER".equals(roleFilter)    ? "selected" : "" %>>READER</option>
                        </select>
                    </div>

                    <!-- Active filter -->
                    <div class="search-field select-field">
                        <label for="activeSelect">Trạng thái</label>
                        <select id="activeSelect" name="active" class="form-select">
                            <option value="">-- Tất cả --</option>
                            <option value="1" <%= Integer.valueOf(1).equals(activeFilter) ? "selected" : "" %>>Active</option>
                            <option value="0" <%= Integer.valueOf(0).equals(activeFilter) ? "selected" : "" %>>Locked</option>
                        </select>
                    </div>

                    <!-- Buttons -->
                    <div style="display:flex; gap:8px; align-items:flex-end;">
                        <button type="submit" class="btn btn-primary" id="searchBtn">
                            <i class="fa-solid fa-search"></i> Tìm
                        </button>
                        <a href="<%= ctx %>/users" class="btn btn-outline" title="Xóa bộ lọc">
                            <i class="fa-solid fa-rotate-right"></i>
                        </a>
                    </div>
                </div>
            </div>
        </form>

        <!-- ===== NOTIFICATIONS ===== -->
        <% if (successMsg != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i> <%= successMsg %>
            </div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMsg %>
            </div>
        <% } %>

        <!-- ===== TOPBAR ===== -->
        <div class="books-topbar" style="margin-top: 20px;">
            <div class="results-info" style="margin-bottom:0;">
                <% if (!q.isEmpty() || roleFilter != null && !roleFilter.isEmpty() || activeFilter != null) { %>
                    <i class="fa-solid fa-filter fa-xs" style="color:var(--primary);"></i>
                    Kết quả: <strong><%= totalRecords %></strong> người dùng
                <% } else { %>
                    <i class="fa-solid fa-users fa-xs" style="color:var(--primary); margin-right:4px;"></i>
                    Tổng cộng <strong><%= totalRecords %></strong> người dùng
                <% } %>
            </div>

            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <!-- Sort -->
                <div class="sort-group">
                    <span class="sort-label"><i class="fa-solid fa-arrow-up-wide-short"></i> Sắp xếp:</span>
                    <%
                        String[][] sortOptions = {
                            {"username", "Tên đăng nhập"},
                            {"full_name","Họ tên"},
                            {"role",     "Vai trò"},
                            {"active",   "Trạng thái"}
                        };
                        for (String[] so : sortOptions) {
                            String sf = so[0], sl = so[1];
                            boolean active = sf.equals(sortField);
                            String thisOrder = active ? nextOrder : "ASC";
                            String icon = active ? ("ASC".equals(sortOrder) ? " ▲" : " ▼") : "";
                    %>
                        <a href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sf %>&order=<%= thisOrder %>&page=1"
                           class="sort-btn <%= active ? "sort-btn-active" : "" %>">
                            <%= sl %><%= icon %>
                        </a>
                    <% } %>
                </div>

                <!-- Admin: Thêm người dùng button -->
                <% if (isAdmin) { %>
                    <button type="button" class="btn btn-primary btn-sm" onclick="document.getElementById('createUserModal').style.display='flex'">
                        <i class="fa-solid fa-plus"></i> Thêm người dùng
                    </button>
                <% } %>
            </div>
        </div>

        <!-- ===== USERS TABLE CARD ===== -->
        <div class="admin-card" style="background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); border: 1px solid #e5e7eb; overflow: hidden; margin-top: 15px;">
            <div class="admin-section-head" style="padding: 20px 24px; border-bottom: 1px solid #f3f4f6; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="font-size: 18px; font-weight: 600; color: #111827; margin: 0;">Danh sách người dùng</h2>
                <span style="font-size: 13px; color: #6b7280; font-weight: 500;"><%= totalRecords %> bản ghi</span>
            </div>

            <div class="admin-table-wrap" style="overflow-x: auto;">
                <table class="admin-table" style="width: 100%; border-collapse: collapse; text-align: left;">
                    <thead>
                        <tr style="background: #f9fafb; border-bottom: 1px solid #e5e7eb;">
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563; width:60px;">ID</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Tên đăng nhập</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Họ tên</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Email</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Vai trò</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Trạng thái</th>
                            <th style="padding: 14px 16px; font-weight: 600; font-size: 13px; color: #4b5563; text-align: center; min-width: 200px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (users != null && !users.isEmpty()) {
                            for (User u : users) {
                                String roleClass = "ADMIN".equals(u.getRole()) ? "badge-danger" :
                                                   "LIBRARIAN".equals(u.getRole()) ? "badge-warning" : "badge-primary";
                    %>
                        <tr style="border-bottom: 1px solid #f3f4f6; transition: background 0.15s;" class="copy-row">
                            <td style="padding: 16px 24px; color: #6b7280; font-weight: 600;"><%= u.getId() %></td>
                            <td style="padding: 16px 24px; font-weight: 500; color: #111827;">
                                <a href="<%= ctx %>/user/profile?id=<%= u.getId() %>" style="color: #3b82f6; text-decoration: none; font-weight: 600;">
                                    <%= u.getUsername() %>
                                </a>
                            </td>
                            <td style="padding: 16px 24px; color: #374151;"><%= u.getFullName() != null ? u.getFullName() : "—" %></td>
                            <td style="padding: 16px 24px; color: #6b7280; font-size: 13.5px;"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
                            <td style="padding: 16px 24px;">
                                <span class="badge <%= roleClass %>"><%= u.getRole() %></span>
                            </td>
                            <td style="padding: 16px 24px;">
                                <% if (u.getActive() == 1) { %>
                                    <span style="display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:20px;font-size:0.76rem;font-weight:600;background:#d1fae5;color:#065f46;">
                                        <i class="fa-solid fa-circle" style="font-size:7px;"></i> Active
                                    </span>
                                <% } else { %>
                                    <span style="display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:20px;font-size:0.76rem;font-weight:600;background:#fee2e2;color:#991b1b;">
                                        <i class="fa-solid fa-circle" style="font-size:7px;"></i> Locked
                                    </span>
                                <% } %>
                            </td>
                            <td style="padding: 12px 16px; text-align: center;">
                                <div class="admin-row-actions" style="display: flex; gap: 6px; justify-content: center; flex-wrap: nowrap; align-items: center;">
                                    <a href="<%= ctx %>/user/profile?id=<%= u.getId() %>"
                                       style="border: 1px solid #d1d5db; padding: 5px 10px; border-radius: 6px; text-decoration: none; color: #6b7280; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; font-size: 12px; white-space:nowrap;">
                                        <i class="fa-solid fa-eye"></i> Xem
                                    </a>
                                    <% if (logged != null && logged.isAdmin()) { %>
                                    <form method="post" action="<%= ctx %>/users" style="display:inline;margin:0;">
                                        <input type="hidden" name="action" value="<%= u.getActive()==1 ? "lock" : "unlock" %>">
                                        <input type="hidden" name="id" value="<%= u.getId() %>">
                                        <button type="submit"
                                                style="padding: 5px 10px; border-radius: 6px; border: 1px solid <%= u.getActive()==1 ? "#fcd34d" : "#6ee7b7" %>; background: <%= u.getActive()==1 ? "#fef9c3" : "#d1fae5" %>; color: <%= u.getActive()==1 ? "#92400e" : "#065f46" %>; font-weight: 500; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 12px; white-space:nowrap;">
                                            <i class="fa-solid <%= u.getActive()==1 ? "fa-lock" : "fa-lock-open" %>"></i>
                                            <%= u.getActive()==1 ? "Khóa" : "Mở khóa" %>
                                        </button>
                                    </form>
                                    <form method="post" action="<%= ctx %>/users" style="display:inline;margin:0;"
                                          onsubmit="return confirm('Xác nhận xóa người dùng <%= u.getUsername().replace("'", "\\'") %>?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= u.getId() %>">
                                        <button type="submit"
                                                style="background: #fee2e2; border: 1px solid #fecaca; padding: 5px 10px; border-radius: 6px; color: #ef4444; font-weight: 500; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; font-size: 12px; white-space:nowrap;">
                                            <i class="fa-solid fa-trash"></i> Xóa
                                        </button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7" style="padding: 40px; text-align: center;">
                                <div class="empty-state">
                                    <div style="font-size: 48px; margin-bottom: 12px;">👤</div>
                                    <h3 style="font-size: 16px; font-weight: 600; color: #4b5563; margin: 0 0 6px 0;">Không tìm thấy người dùng</h3>
                                    <p style="margin: 0; font-size: 14px; color: #9ca3af;">Hãy thử tìm kiếm với từ khóa khác.</p>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- ===== PAGINATION ===== -->
            <% if (totalPages > 1) { %>
            <div style="padding: 16px 24px; border-top: 1px solid #e5e7eb; display: flex; justify-content: center; background: #f9fafb;">
                <nav aria-label="Phân trang">
                    <ul class="pagination" style="margin-top: 0;">
                        <!-- Prev -->
                        <li class="page-item <%= currentPageNum <= 1 ? "disabled" : "" %>">
                            <a class="page-link"
                               href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum - 1 %>">
                                <i class="fa-solid fa-chevron-left fa-xs"></i>
                            </a>
                        </li>

                        <% 
                           if (totalPages <= 7) {
                               for (int pg = 1; pg <= totalPages; pg++) { %>
                                   <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                       <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                   </li>
                               <% }
                           } else {
                               // Show first 2 pages
                               for (int pg = 1; pg <= 2; pg++) { %>
                                   <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                       <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                   </li>
                               <% }

                               if (currentPageNum <= 4) {
                                   // Current page is near the start
                                   for (int pg = 3; pg <= 5; pg++) { %>
                                       <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                           <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                       </li>
                                   <% } %>
                                   <li class="page-item disabled"><span class="page-link">…</span></li>
                               <% } else if (currentPageNum >= totalPages - 3) {
                                   // Current page is near the end %>
                                   <li class="page-item disabled"><span class="page-link">…</span></li>
                                   <% for (int pg = totalPages - 4; pg <= totalPages - 2; pg++) { %>
                                       <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                           <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                       </li>
                                   <% }
                               } else {
                                   // Current page is in the middle %>
                                   <li class="page-item disabled"><span class="page-link">…</span></li>
                                   <% for (int pg = currentPageNum - 1; pg <= currentPageNum + 1; pg++) { %>
                                       <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                           <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                       </li>
                                   <% } %>
                                   <li class="page-item disabled"><span class="page-link">…</span></li>
                               <% }

                               // Show last 2 pages
                               for (int pg = totalPages - 1; pg <= totalPages; pg++) { %>
                                   <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                                       <a class="page-link" href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>"><%= pg %></a>
                                   </li>
                               <% }
                           }
                        %>

                        <!-- Next -->
                        <li class="page-item <%= currentPageNum >= totalPages ? "disabled" : "" %>">
                            <a class="page-link"
                               href="<%= ctx %>/users?q=<%= java.net.URLEncoder.encode(q,"UTF-8") %>&role=<%= roleFilter != null ? roleFilter : "" %>&active=<%= activeFilter != null ? activeFilter : "" %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum + 1 %>">
                                <i class="fa-solid fa-chevron-right fa-xs"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
            <% } %>
        </div>
    </div>
</main>

<!-- ===== CREATE USER MODAL (Admin only) ===== -->
<% if (isAdmin) { %>
<div id="createUserModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(4px);">
    <div style="background:var(--bg-card, #fff); border-radius:var(--radius-md, 16px); padding:36px; max-width:520px; width:92%; box-shadow:0 20px 60px rgba(0,0,0,0.2); position:relative; max-height:90vh; overflow-y:auto;">
        <div style="position:absolute; top:0; left:0; right:0; height:4px; background:var(--primary); border-radius:16px 16px 0 0;"></div>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px;">
            <h3 style="font-size:1.2rem; font-weight:700; color:var(--text-primary); margin:0;">
                <i class="fa-solid fa-user-plus" style="color:var(--primary);"></i> Tạo người dùng mới
            </h3>
            <button onclick="document.getElementById('createUserModal').style.display='none'"
                    style="background:none;border:none;font-size:1.4rem;cursor:pointer;color:var(--text-muted);line-height:1;">×</button>
        </div>
        <form method="post" action="<%= ctx %>/users" id="createUserForm" onsubmit="return validateCreateUserForm()">
            <input type="hidden" name="action" value="create">
            <div style="display:grid; gap:14px;">
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Tên đăng nhập *</label>
                    <input id="cu_username" name="username" required placeholder="Nhập username (chữ cái, số, dấu _)..."
                           maxlength="50" autocomplete="off" class="form-control">
                    <div id="cu_username_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Tên đăng nhập chỉ chứa chữ cái, số và dấu gạch dưới (_), tối thiểu 3 ký tự.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Mật khẩu</label>
                    <input id="cu_password" name="password" type="password" placeholder="Để trống = mặc định 'password'"
                           minlength="6" maxlength="100" class="form-control">
                    <div id="cu_password_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Mật khẩu phải có ít nhất 6 ký tự.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Họ và tên</label>
                    <input id="cu_fullName" name="fullName" placeholder="Nhập họ tên..."
                           maxlength="100" class="form-control">
                    <div id="cu_fullName_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Họ tên không được chứa số.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Email</label>
                    <input id="cu_email" name="email" type="email" placeholder="example@email.com"
                           maxlength="150" class="form-control">
                    <div id="cu_email_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Email không đúng định dạng.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Số điện thoại</label>
                    <input id="cu_phone" name="phone" placeholder="0xxxxxxxxx"
                           maxlength="15" class="form-control">
                    <div id="cu_phone_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Số điện thoại phải có 10-11 chữ số và bắt đầu bằng 0.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Mã sinh viên</label>
                    <input id="cu_studentId" name="studentId" placeholder="Ví dụ: SS170001"
                           maxlength="20" class="form-control">
                    <div id="cu_studentId_err" style="color:var(--danger);font-size:12px;margin-top:4px;display:none;">
                        <i class="fa-solid fa-triangle-exclamation"></i> Mã sinh viên chỉ được chứa chữ cái và chữ số.
                    </div>
                </div>
                <div>
                    <label style="font-size:13px;font-weight:600;color:var(--text-secondary);display:block;margin-bottom:5px;">Vai trò</label>
                    <select name="role" class="form-select">
                        <option value="READER">READER</option>
                        <option value="LIBRARIAN">LIBRARIAN</option>
                        <option value="ADMIN">ADMIN</option>
                    </select>
                </div>
            </div>
            <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:24px;">
                <button type="button" class="btn btn-outline" onclick="document.getElementById('createUserModal').style.display='none'">
                    Hủy
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i> Tạo người dùng
                </button>
            </div>
        </form>
    </div>
</div>
<script>
document.getElementById('createUserModal').addEventListener('click', function(e) {
    if (e.target === this) this.style.display = 'none';
});

function validateCreateUserForm() {
    let valid = true;

    // Username: min 3, only letters/numbers/underscore
    const username = document.getElementById('cu_username');
    const usernameErr = document.getElementById('cu_username_err');
    const usernameRegex = /^[a-zA-Z0-9_]{3,50}$/;
    if (!usernameRegex.test(username.value.trim())) {
        usernameErr.style.display = 'block';
        username.style.borderColor = '#ef4444';
        valid = false;
    } else {
        usernameErr.style.display = 'none';
        username.style.borderColor = '#22c55e';
    }

    // Password: if provided, min 6 chars
    const password = document.getElementById('cu_password');
    const passwordErr = document.getElementById('cu_password_err');
    if (password.value.length > 0 && password.value.length < 6) {
        passwordErr.style.display = 'block';
        password.style.borderColor = '#ef4444';
        valid = false;
    } else {
        passwordErr.style.display = 'none';
        if (password.value.length > 0) password.style.borderColor = '#22c55e';
    }

    // FullName: no digits if provided
    const fullName = document.getElementById('cu_fullName');
    const fullNameErr = document.getElementById('cu_fullName_err');
    if (fullName.value.trim().length > 0 && /\d/.test(fullName.value)) {
        fullNameErr.style.display = 'block';
        fullName.style.borderColor = '#ef4444';
        valid = false;
    } else {
        fullNameErr.style.display = 'none';
        if (fullName.value.trim()) fullName.style.borderColor = '#22c55e';
    }

    // Email: valid format if provided
    const email = document.getElementById('cu_email');
    const emailErr = document.getElementById('cu_email_err');
    if (email.value.trim().length > 0) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email.value.trim())) {
            emailErr.style.display = 'block';
            email.style.borderColor = '#ef4444';
            valid = false;
        } else {
            emailErr.style.display = 'none';
            email.style.borderColor = '#22c55e';
        }
    } else {
        emailErr.style.display = 'none';
    }

    // Phone: 10-11 digits starting with 0, if provided
    const phone = document.getElementById('cu_phone');
    const phoneErr = document.getElementById('cu_phone_err');
    if (phone.value.trim().length > 0) {
        const phoneRegex = /^0[0-9]{9,10}$/;
        if (!phoneRegex.test(phone.value.trim())) {
            phoneErr.style.display = 'block';
            phone.style.borderColor = '#ef4444';
            valid = false;
        } else {
            phoneErr.style.display = 'none';
            phone.style.borderColor = '#22c55e';
        }
    } else {
        phoneErr.style.display = 'none';
    }

    // StudentId: alphanumeric only if provided
    const studentId = document.getElementById('cu_studentId');
    const studentIdErr = document.getElementById('cu_studentId_err');
    if (studentId.value.trim().length > 0) {
        const sidRegex = /^[a-zA-Z0-9]+$/;
        if (!sidRegex.test(studentId.value.trim())) {
            studentIdErr.style.display = 'block';
            studentId.style.borderColor = '#ef4444';
            valid = false;
        } else {
            studentIdErr.style.display = 'none';
            studentId.style.borderColor = '#22c55e';
        }
    } else {
        studentIdErr.style.display = 'none';
    }

    return valid;
}
</script>
<% } %>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
