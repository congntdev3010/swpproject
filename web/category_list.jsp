<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Category, java.util.List, java.time.format.DateTimeFormatter" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer currentPageNum = (Integer) request.getAttribute("currentPageNum");
    String keyword = (String) request.getAttribute("keyword");
    String sortField = (String) request.getAttribute("sortField");
    String sortOrder = (String) request.getAttribute("sortOrder");
    String dbError = (String) request.getAttribute("errorMsg");
    
    // Read session messages
    String sessionSuccess = (String) session.getAttribute("successMsg");
    if (sessionSuccess != null) {
        request.setAttribute("successMsg", sessionSuccess);
        session.removeAttribute("successMsg");
    }
    String sessionError = (String) session.getAttribute("errorMsg");
    if (sessionError != null) {
        request.setAttribute("errorMsg", sessionError);
        session.removeAttribute("errorMsg");
    }

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");

    boolean isAdmin = (loggedUser != null && loggedUser.isAdmin());
    String ctx = request.getContextPath();

    if (totalRecords == null) totalRecords = 0;
    if (totalPages == null) totalPages = 1;
    if (currentPageNum == null) currentPageNum = 1;
    if (keyword == null) keyword = "";
    if (sortField == null) sortField = "name";
    if (sortOrder == null) sortOrder = "ASC";

    String nextOrder = "ASC".equals(sortOrder) ? "DESC" : "ASC";
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>

<main class="page-wrapper">

    <!-- ===== CATEGORY PAGE HEADER ===== -->
    <div class="books-page-header">
        <div class="container">
            <div class="books-page-header-inner">
                <div>
                    <div class="hero-eyebrow" style="margin-bottom:10px;">
                        <i class="fa-solid fa-tags"></i> Danh mục
                    </div>
                    <h1 class="books-page-title">Danh mục sách</h1>
                    <p class="books-page-subtitle">Phân loại và tổ chức các chủ đề sách trong hệ thống</p>
                </div>
                <div class="books-page-stats">
                    <div class="bps-item">
                        <span class="bps-num"><%= totalRecords %></span>
                        <span class="bps-lbl">Danh mục</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container" style="padding-top:28px;">

        <!-- ===== SEARCH BAR ===== -->
        <form id="searchForm" action="<%= ctx %>/categories" method="get">
            <input type="hidden" name="sort"  value="<%= sortField %>">
            <input type="hidden" name="order" value="<%= sortOrder %>">
            <input type="hidden" name="page"  value="1">

            <div class="search-bar-wrapper">
                <div class="search-bar-inner">
                    <!-- Keyword -->
                    <div class="search-field" style="flex:2;">
                        <label for="keywordInput">Tìm kiếm danh mục</label>
                        <div class="search-input-wrap">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" id="keywordInput" name="keyword"
                                   class="form-control"
                                   placeholder="Tìm theo tên danh mục, mô tả..."
                                   value="<%= keyword %>"
                                   maxlength="200"
                                   autocomplete="off">
                        </div>
                    </div>

                    <!-- Buttons -->
                    <div style="display:flex; gap:8px; align-items:flex-end;">
                        <button type="submit" class="btn btn-primary" id="searchBtn">
                            <i class="fa-solid fa-search"></i> Tìm
                        </button>
                        <a href="<%= ctx %>/categories" class="btn btn-outline" title="Xóa bộ lọc">
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
        <% if (dbError != null) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-triangle-exclamation"></i> <%= dbError %>
            </div>
        <% } %>

        <!-- ===== TOPBAR ===== -->
        <div class="books-topbar" style="margin-top: 20px;">
            <div class="results-info" style="margin-bottom:0;">
                <% if (!keyword.isEmpty()) { %>
                    <i class="fa-solid fa-filter fa-xs" style="color:var(--primary);"></i>
                    Kết quả: <strong><%= totalRecords %></strong> danh mục cho “<strong><%= keyword %></strong>”
                <% } else { %>
                    <i class="fa-solid fa-tags fa-xs" style="color:var(--primary); margin-right:4px;"></i>
                    Tổng cộng <strong><%= totalRecords %></strong> danh mục
                <% } %>
            </div>

            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <!-- Sort -->
                <div class="sort-group">
                    <span class="sort-label"><i class="fa-solid fa-arrow-up-wide-short"></i> Sắp xếp:</span>
                    <%
                        String[][] sortOptions = {
                            {"name",        "Tên danh mục"},
                            {"created_at",  "Ngày tạo"}
                        };
                        for (String[] so : sortOptions) {
                            String sf = so[0], sl = so[1];
                            boolean active = sf.equals(sortField);
                            String thisOrder = active ? nextOrder : "ASC";
                            String icon = active ? ("ASC".equals(sortOrder) ? " ▲" : " ▼") : "";
                    %>
                        <a href="<%= ctx %>/categories?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&sort=<%= sf %>&order=<%= thisOrder %>&page=<%= currentPageNum %>"
                           class="sort-btn <%= active ? "sort-btn-active" : "" %>">
                            <%= sl %><%= icon %>
                        </a>
                    <% } %>
                </div>

                <!-- Admin add button -->
                <% if (isAdmin) { %>
                    <a href="<%= ctx %>/category/add" class="btn btn-primary btn-sm">
                        <i class="fa-solid fa-plus"></i> Thêm danh mục
                    </a>
                <% } %>
            </div>
        </div>

        <!-- ===== CATEGORIES TABLE CARD ===== -->
        <div class="admin-card" style="background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); border: 1px solid #e5e7eb; overflow: hidden; margin-top: 15px;">
            <div class="admin-section-head" style="padding: 20px 24px; border-bottom: 1px solid #f3f4f6; display: flex; justify-content: space-between; align-items: center;">
                <h2 style="font-size: 18px; font-weight: 600; color: #111827; margin: 0;">Danh sách dữ liệu</h2>
                <span style="font-size: 13px; color: #6b7280; font-weight: 500;"><%= totalRecords %> bản ghi</span>
            </div>
            
            <div class="admin-table-wrap" style="overflow-x: auto;">
                <table class="admin-table" style="width: 100%; border-collapse: collapse; text-align: left;">
                    <thead>
                        <tr style="background: #f9fafb; border-bottom: 1px solid #e5e7eb;">
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563; width: 80px;">ID</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Tên danh mục</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563; max-width: 400px;">Mô tả</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Ngày tạo</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563;">Người tạo</th>
                            <th style="padding: 14px 24px; font-weight: 600; font-size: 13px; color: #4b5563; text-align: center; width: 220px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (categories != null && !categories.isEmpty()) {
                                for (Category c : categories) {
                        %>
                        <tr style="border-bottom: 1px solid #f3f4f6; transition: background 0.15s;" class="copy-row">
                            <td style="padding: 16px 24px; color: #6b7280; font-weight: 600;"><%= c.getId() %></td>
                            <td style="padding: 16px 24px; font-weight: 500; color: #111827;"><%= c.getName() %></td>
                            <td style="padding: 16px 24px; color: #4b5563; font-size: 13.5px; max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= c.getDescription() %>">
                                <%= c.getDescription() != null && !c.getDescription().trim().isEmpty() ? c.getDescription() : "—" %>
                            </td>
                            <td style="padding: 16px 24px; color: #4b5563;">
                                <%= c.getCreatedAt() != null ? c.getCreatedAt().format(formatter) : "—" %>
                            </td>
                            <td style="padding: 16px 24px; color: #6b7280; font-size: 13px;">
                                <%= c.getCreatedBy() != null ? c.getCreatedBy() : "system" %>
                            </td>
                            <td style="padding: 16px 24px; text-align: center;">
                                <div class="admin-row-actions" style="display: flex; gap: 8px; justify-content: center;">
                                    <% if (isAdmin) { %>
                                        <a href="<%= ctx %>/category/edit?id=<%= c.getId() %>" class="btn btn-sm btn-outline" style="border: 1px solid #d1d5db; padding: 6px 12px; border-radius: 6px; text-decoration: none; color: #3b82f6; font-weight: 500; display: inline-flex; align-items: center; gap: 4px;">
                                            <i class="fa-solid fa-pen-to-square"></i> Sửa
                                        </a>
                                        <a href="<%= ctx %>/category/delete?id=<%= c.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục này?');" style="background: #fee2e2; border: 1px solid #fecaca; padding: 6px 12px; border-radius: 6px; text-decoration: none; color: #ef4444; font-weight: 500; display: inline-flex; align-items: center; gap: 4px;">
                                            <i class="fa-solid fa-trash"></i> Xóa
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
                            <td colspan="6" style="padding: 40px; text-align: center;">
                                <div class="empty-state">
                                    <div style="font-size: 48px; margin-bottom: 12px;">🏷️</div>
                                    <h3 style="font-size: 16px; font-weight: 600; color: #4b5563; margin: 0 0 6px 0;">Không tìm thấy danh mục</h3>
                                    <p style="margin: 0; font-size: 14px; color: #9ca3af;">Hãy thử tìm kiếm với tên khác.</p>
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
                <nav aria-label="Page navigation" class="pagination" style="display: inline-flex; gap: 6px; list-style: none; padding: 0; margin: 0;">
                    
                    <!-- Back button -->
                    <a class="page-link" href="<%= ctx %>/categories?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum - 1 %>" 
                       style="padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; text-decoration: none; color: #374151; font-weight: 500; background: white; <%= currentPageNum == 1 ? "pointer-events: none; opacity: 0.5;" : "" %>">
                        <i class="fa-solid fa-angle-left"></i> Trước
                    </a>

                    <% for (int pg = 1; pg <= totalPages; pg++) { %>
                        <a class="page-link" href="<%= ctx %>/categories?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>" 
                           style="padding: 8px 14px; border: 1px solid <%= pg == currentPageNum ? "#3b82f6" : "#d1d5db" %>; border-radius: 6px; text-decoration: none; font-weight: 500; <%= pg == currentPageNum ? "background: #3b82f6; color: white;" : "background: white; color: #374151;" %>">
                            <%= pg %>
                        </a>
                    <% } %>

                    <!-- Next button -->
                    <a class="page-link" href="<%= ctx %>/categories?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum + 1 %>" 
                       style="padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; text-decoration: none; color: #374151; font-weight: 500; background: white; <%= currentPageNum.equals(totalPages) ? "pointer-events: none; opacity: 0.5;" : "" %>">
                        Sau <i class="fa-solid fa-angle-right"></i>
                    </a>
                </nav>
            </div>
            <% } %>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
