<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Book, com.swp391.model.User, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    List<Book>   books            = (List<Book>)   request.getAttribute("books");
    List<String> categories       = (List<String>) request.getAttribute("categories");
    Integer      totalRecords     = (Integer)       request.getAttribute("totalRecords");
    Integer      totalPages       = (Integer)       request.getAttribute("totalPages");
    Integer      currentPageNum   = (Integer)       request.getAttribute("currentPageNum");
    String       keyword          = (String)        request.getAttribute("keyword");
    String       selectedCategory = (String)        request.getAttribute("selectedCategory");
    String       sortField        = (String)        request.getAttribute("sortField");
    String       sortOrder        = (String)        request.getAttribute("sortOrder");
    String       viewMode         = (String)        request.getAttribute("viewMode");
    String       dbError          = (String)        request.getAttribute("dbError");

    boolean isAdmin    = (loggedUser != null && loggedUser.isAdmin());
    boolean isAdminLib = (loggedUser != null && loggedUser.isAdminOrLibrarian());

    String ctx         = contextPath;
    if (totalRecords     == null) totalRecords     = 0;
    if (totalPages       == null) totalPages       = 1;
    if (currentPageNum   == null) currentPageNum   = 1;
    if (keyword          == null) keyword          = "";
    if (selectedCategory == null) selectedCategory = "";
    if (sortField        == null) sortField        = "title";
    if (sortOrder        == null) sortOrder        = "ASC";
    if (viewMode         == null) viewMode         = "grid";

    String nextOrder = "ASC".equals(sortOrder) ? "DESC" : "ASC";

    // Helper: build URL giữ nguyên params hiện tại khi thay 1 param
    // (dùng inline trong JSP)
%>

<main class="page-wrapper" style="padding-top:32px;">
<div class="container">

    <!-- ==================== PAGE TITLE ==================== -->
    <div style="margin-bottom:24px;">
        <h1 style="font-family:'Playfair Display',serif; font-size:1.8rem; font-weight:700; color:var(--text-primary); margin-bottom:4px;">
            <i class="fa-solid fa-book" style="color:var(--primary); margin-right:8px;"></i>Danh sách sách
        </h1>
        <p style="color:var(--text-muted); font-size:0.9rem;">Tra cứu, tìm kiếm và lọc đầu sách trong thư viện</p>
    </div>

    <!-- ==================== SEARCH & FILTER BAR ==================== -->
    <form id="searchForm" action="<%= ctx %>/books" method="get" novalidate>
        <input type="hidden" name="view"  value="<%= viewMode %>">
        <input type="hidden" name="sort"  value="<%= sortField %>">
        <input type="hidden" name="order" value="<%= sortOrder %>">
        <input type="hidden" name="page"  value="1">

        <div class="search-bar-wrapper">
            <div class="search-bar-inner">
                <!-- Keyword -->
                <div class="search-field" style="flex:2;">
                    <label for="keywordInput">Tìm kiếm</label>
                    <div class="search-input-wrap">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="keywordInput" name="keyword"
                               class="form-control"
                               placeholder="Nhập tên sách, ISBN..."
                               value="<%= keyword %>"
                               maxlength="200"
                               autocomplete="off">
                    </div>
                </div>

                <!-- Category Filter -->
                <div class="search-field select-field">
                    <label for="categorySelect">Danh mục</label>
                    <select id="categorySelect" name="category" class="form-select">
                        <option value="">-- Tất cả danh mục --</option>
                        <% if (categories != null) {
                            for (String cat : categories) {
                                String sel = cat.equals(selectedCategory) ? "selected" : "";
                        %>
                            <option value="<%= cat %>" <%= sel %>><%= cat %></option>
                        <% }} %>
                    </select>
                </div>

                <!-- Buttons -->
                <div style="display:flex; gap:8px; align-items:flex-end;">
                    <button type="submit" class="btn btn-primary" id="searchBtn">
                        <i class="fa-solid fa-search"></i> Tìm
                    </button>
                    <a href="<%= ctx %>/books" class="btn btn-outline" title="Xóa bộ lọc">
                        <i class="fa-solid fa-rotate-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </form>

    <% if (dbError != null) { %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-xmark"></i> <%= dbError %>
        </div>
    <% } %>

    <!-- ==================== TOPBAR (Result info + View toggle + Sort) ==================== -->
    <div class="books-topbar">
        <div class="results-info">
            <% if (!keyword.isEmpty() || !selectedCategory.isEmpty()) { %>
                Kết quả: <strong><%= totalRecords %></strong> sách
                <% if (!keyword.isEmpty()) { %> cho "<strong><%= keyword %></strong>"<% } %>
                <% if (!selectedCategory.isEmpty()) { %> trong "<strong><%= selectedCategory %></strong>"<% } %>
            <% } else { %>
                Tổng cộng <strong><%= totalRecords %></strong> đầu sách
            <% } %>
            &nbsp;·&nbsp; Trang <strong><%= currentPageNum %></strong>/<strong><%= totalPages %></strong>
        </div>

        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
            <!-- Sort -->
            <div style="display:flex; align-items:center; gap:6px; font-size:0.85rem; color:var(--text-muted);">
                <i class="fa-solid fa-arrow-up-wide-short"></i>
                <span>Sắp xếp:</span>
                <%
                    String[][] sortOptions = {
                        {"title",        "Tên sách"},
                        {"publish_year", "Năm XB"},
                        {"available",    "Còn sách"},
                        {"price",        "Giá"}
                    };
                    for (String[] so : sortOptions) {
                        String sf = so[0], sl = so[1];
                        boolean active = sf.equals(sortField);
                        String thisOrder = active ? nextOrder : "ASC";
                        String icon = active ? ("ASC".equals(sortOrder) ? " ▲" : " ▼") : "";
                %>
                    <a href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sf %>&order=<%= thisOrder %>&page=1&view=<%= viewMode %>"
                       style="padding:4px 10px; border-radius:4px; font-size:0.82rem; font-weight:<%= active ? "700" : "500" %>; color:<%= active ? "var(--primary)" : "var(--text-muted)" %>; border:1px solid <%= active ? "var(--primary)" : "var(--border)" %>; background:<%= active ? "rgba(79,142,247,0.08)" : "transparent" %>; transition:all .15s;">
                        <%= sl %><%= icon %>
                    </a>
                <% } %>
            </div>

            <!-- View Toggle -->
            <div class="view-toggle">
                <button type="button" id="viewGrid" class="view-toggle-btn <%= "grid".equals(viewMode) ? "active" : "" %>"
                        title="Dạng lưới" onclick="setView('grid')">
                    <i class="fa-solid fa-grip"></i>
                </button>
                <button type="button" id="viewTable" class="view-toggle-btn <%= "table".equals(viewMode) ? "active" : "" %>"
                        title="Dạng bảng" onclick="setView('table')">
                    <i class="fa-solid fa-list"></i>
                </button>
            </div>

            <!-- Admin add button -->
            <% if (isAdminLib) { %>
                <a href="<%= ctx %>/admin/books/add" class="btn btn-primary btn-sm">
                    <i class="fa-solid fa-plus"></i> Thêm sách
                </a>
            <% } %>
        </div>
    </div>

    <!-- ==================== BOOK LIST ==================== -->
    <% if (books == null || books.isEmpty()) { %>
        <div class="empty-state" style="padding:80px 24px;">
            <div class="empty-icon"><i class="fa-solid fa-magnifying-glass"></i></div>
            <h3>Không tìm thấy sách nào</h3>
            <p>Thử thay đổi từ khóa hoặc bộ lọc danh mục.</p>
            <a href="<%= ctx %>/books" class="btn btn-outline" style="margin-top:16px;">
                <i class="fa-solid fa-rotate-right"></i> Xóa bộ lọc
            </a>
        </div>

    <% } else if ("table".equals(viewMode)) { %>
        <!-- ===== TABLE VIEW ===== -->
        <div class="data-table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:50px;">#</th>
                        <th style="width:48px;"></th>
                        <th>
                            <a href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=title&order=<%= "title".equals(sortField) ? nextOrder : "ASC" %>&page=1&view=table">
                                Tên sách <i class="fa-solid <%= "title".equals(sortField) ? ("ASC".equals(sortOrder)?"fa-sort-up":"fa-sort-down") : "fa-sort" %> sort-icon fa-xs"></i>
                            </a>
                        </th>
                        <th>Danh mục</th>
                        <th>
                            <a href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=publish_year&order=<%= "publish_year".equals(sortField) ? nextOrder : "DESC" %>&page=1&view=table">
                                Năm XB <i class="fa-solid <%= "publish_year".equals(sortField) ? ("ASC".equals(sortOrder)?"fa-sort-up":"fa-sort-down") : "fa-sort" %> sort-icon fa-xs"></i>
                            </a>
                        </th>
                        <th>
                            <a href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=available&order=<%= "available".equals(sortField) ? nextOrder : "DESC" %>&page=1&view=table">
                                Trạng thái <i class="fa-solid <%= "available".equals(sortField) ? ("ASC".equals(sortOrder)?"fa-sort-up":"fa-sort-down") : "fa-sort" %> sort-icon fa-xs"></i>
                            </a>
                        </th>
                        <th>
                            <a href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=price&order=<%= "price".equals(sortField) ? nextOrder : "ASC" %>&page=1&view=table">
                                Giá <i class="fa-solid <%= "price".equals(sortField) ? ("ASC".equals(sortOrder)?"fa-sort-up":"fa-sort-down") : "fa-sort" %> sort-icon fa-xs"></i>
                            </a>
                        </th>
                        <% if (isAdminLib) { %><th style="width:100px; text-align:center;">Thao tác</th><% } %>
                    </tr>
                </thead>
                <tbody>
                    <% int rowNum = (currentPageNum - 1) * 12 + 1;
                       for (Book b : books) { %>
                        <tr>
                            <td style="color:var(--text-muted); font-size:0.82rem;"><%= rowNum++ %></td>
                            <td>
                                <% if (b.getCoverImage() != null && !b.getCoverImage().isEmpty()) { %>
                                    <img src="<%= b.getCoverImage() %>" class="book-thumb"
                                         alt="<%= b.getTitle() %>"
                                         onerror="this.src=''; this.style.background='var(--bg-surface)';">
                                <% } else { %>
                                    <div class="book-thumb" style="background:var(--bg-surface);display:flex;align-items:center;justify-content:center;color:var(--text-muted);font-size:1rem;">
                                        <i class="fa-solid fa-book"></i>
                                    </div>
                                <% } %>
                            </td>
                            <td class="book-info-cell">
                                <span class="book-title-link" title="<%= b.getTitle() %>"><%= b.getTitle() %></span>
                                <span class="book-isbn"><%= b.getIsbn() %></span>
                            </td>
                            <td>
                                <a href="<%= ctx %>/books?category=<%= java.net.URLEncoder.encode(b.getCategory() != null ? b.getCategory() : "","UTF-8") %>&view=table"
                                   class="badge badge-primary">
                                    <%= b.getCategory() != null ? b.getCategory() : "—" %>
                                </a>
                            </td>
                            <td><%= b.getPublishYear() != null ? b.getPublishYear() : "—" %></td>
                            <td>
                                <span class="badge <%= b.getAvailable() > 0 ? "badge-success" : (b.getQuantity() > 0 ? "badge-warning" : "badge-danger") %>">
                                    <%= b.getStatusLabel() %>
                                </span>
                                <span style="font-size:0.75rem;color:var(--text-muted);display:block;margin-top:2px;">
                                    <%= b.getAvailable() %>/<%= b.getQuantity() %> bản
                                </span>
                            </td>
                            <td style="font-weight:600; color:var(--accent);"><%= b.getFormattedPrice() %></td>
                            <% if (isAdminLib) { %>
                            <td style="text-align:center;">
                                <div style="display:flex; gap:6px; justify-content:center;">
                                    <a href="<%= ctx %>/admin/books/edit?id=<%= b.getId() %>"
                                       class="btn btn-outline btn-sm" title="Chỉnh sửa">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <% if (isAdmin) { %>
                                    <button type="button"
                                            class="btn btn-danger btn-sm"
                                            title="Ẩn / Xóa sách"
                                            onclick="confirmDelete(<%= b.getId() %>, '<%= b.getTitle().replace("'", "\\'") %>')">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

    <% } else { %>
        <!-- ===== GRID VIEW ===== -->
        <div class="books-grid">
            <% for (Book b : books) { %>
                <div class="book-card">
                    <div class="book-cover">
                        <% if (b.getCoverImage() != null && !b.getCoverImage().trim().isEmpty()) { %>
                            <img src="<%= b.getCoverImage() %>"
                                 alt="<%= b.getTitle() %>"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                            <div class="book-cover-placeholder" style="display:none;">
                                <i class="fa-solid fa-book-open"></i>
                                <span><%= b.getTitle() %></span>
                            </div>
                        <% } else { %>
                            <div class="book-cover-placeholder">
                                <i class="fa-solid fa-book-open"></i>
                                <span><%= b.getTitle() %></span>
                            </div>
                        <% } %>
                        <span class="book-status-tag <%= b.getStatusClass() %>">
                            <%= b.getStatusLabel() %>
                        </span>
                    </div>
                    <div class="book-body">
                        <div class="book-category">
                            <a href="<%= ctx %>/books?category=<%= java.net.URLEncoder.encode(b.getCategory() != null ? b.getCategory() : "","UTF-8") %>&view=grid"
                               style="color:var(--primary); text-decoration:none;">
                                <%= b.getCategory() != null ? b.getCategory() : "—" %>
                            </a>
                        </div>
                        <div class="book-title" title="<%= b.getTitle() %>"><%= b.getTitle() %></div>
                        <% if (b.getPublisher() != null) { %>
                            <div class="book-publisher">
                                <i class="fa-solid fa-building fa-xs"></i>
                                <%= b.getPublisher() %>
                                <% if (b.getPublishYear() != null) { %> · <%= b.getPublishYear() %><% } %>
                            </div>
                        <% } %>
                        <div class="book-price"><%= b.getFormattedPrice() %></div>
                    </div>
                    <div class="book-footer">
                        <span style="font-size:0.78rem;color:var(--text-muted);">
                            <i class="fa-solid fa-layer-group fa-xs"></i>
                            <%= b.getAvailable() %>/<%= b.getQuantity() %> còn
                        </span>
                        <div style="display:flex; gap:6px;">
                            <% if (isAdmin) { %>
                            <button type="button"
                                    class="btn btn-danger btn-sm"
                                    title="Ẩn / Xóa sách"
                                    onclick="confirmDelete(<%= b.getId() %>, '<%= b.getTitle().replace("'", "\\'") %>')">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>

    <!-- ==================== PAGINATION ==================== -->
    <% if (totalPages > 1) { %>
        <nav aria-label="Phân trang">
            <ul class="pagination">
                <!-- Prev -->
                <li class="page-item <%= currentPageNum <= 1 ? "disabled" : "" %>">
                    <a class="page-link"
                       href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum - 1 %>&view=<%= viewMode %>">
                        <i class="fa-solid fa-chevron-left fa-xs"></i>
                    </a>
                </li>

                <% // Hiện tối đa 7 nút trang
                   int startPage = Math.max(1, currentPageNum - 3);
                   int endPage   = Math.min(totalPages, startPage + 6);
                   startPage     = Math.max(1, endPage - 6);

                   if (startPage > 1) { %>
                    <li class="page-item">
                        <a class="page-link" href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=1&view=<%= viewMode %>">1</a>
                    </li>
                    <% if (startPage > 2) { %><li class="page-item disabled"><span class="page-link">…</span></li><% } %>
                <% }
                   for (int pg = startPage; pg <= endPage; pg++) { %>
                    <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                        <a class="page-link"
                           href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= pg %>&view=<%= viewMode %>">
                            <%= pg %>
                        </a>
                    </li>
                <% }
                   if (endPage < totalPages) {
                       if (endPage < totalPages - 1) { %><li class="page-item disabled"><span class="page-link">…</span></li><% } %>
                    <li class="page-item">
                        <a class="page-link" href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= totalPages %>&view=<%= viewMode %>"><%= totalPages %></a>
                    </li>
                <% } %>

                <!-- Next -->
                <li class="page-item <%= currentPageNum >= totalPages ? "disabled" : "" %>">
                    <a class="page-link"
                       href="<%= ctx %>/books?keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&category=<%= java.net.URLEncoder.encode(selectedCategory,"UTF-8") %>&sort=<%= sortField %>&order=<%= sortOrder %>&page=<%= currentPageNum + 1 %>&view=<%= viewMode %>">
                        <i class="fa-solid fa-chevron-right fa-xs"></i>
                    </a>
                </li>
            </ul>
        </nav>
    <% } %>

</div><!-- /container -->
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<!-- ==================== DELETE MODAL ==================== -->
<div id="deleteModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.65); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-lg); padding:32px; max-width:420px; width:90%; box-shadow:var(--shadow-lg);">
        <div style="font-size:2rem; margin-bottom:12px;">🗑️</div>
        <h3 style="font-size:1.1rem; font-weight:700; color:var(--text-primary); margin-bottom:8px;">Xác nhận xóa sách</h3>
        <p style="color:var(--text-secondary); font-size:0.9rem; margin-bottom:24px;" id="deleteBookTitle"></p>
        <div style="display:flex; gap:12px; justify-content:flex-end;">
            <button onclick="closeDeleteModal()" class="btn btn-outline">Hủy</button>
            <a id="deleteConfirmBtn" href="#" class="btn btn-danger">
                <i class="fa-solid fa-trash"></i> Xóa
            </a>
        </div>
    </div>
</div>

<script>
// ---- View toggle ----
function setView(mode) {
    var url = new URL(window.location.href);
    url.searchParams.set('view', mode);
    url.searchParams.set('page', '1');
    window.location.href = url.toString();
}

// ---- Delete modal ----
function confirmDelete(bookId, bookTitle) {
    document.getElementById('deleteBookTitle').textContent =
        'Bạn có chắc muốn xóa/ẩn sách: "' + bookTitle + '"?';
    document.getElementById('deleteConfirmBtn').href =
        '<%= ctx %>/admin/books/delete?id=' + bookId;
    document.getElementById('deleteModal').style.display = 'flex';
}
function closeDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
}
document.getElementById('deleteModal').addEventListener('click', function(e) {
    if (e.target === this) closeDeleteModal();
});

// ---- Search validation ----
document.getElementById('searchForm').addEventListener('submit', function(e) {
    var kw = document.getElementById('keywordInput').value.trim();
    if (kw.length > 200) {
        alert('Từ khóa không được vượt quá 200 ký tự.');
        e.preventDefault();
    }
});
</script>
