<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Book, com.swp391.model.BookCopy, com.swp391.model.User, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    Book book = (Book) request.getAttribute("book");
    List<BookCopy> copies = (List<BookCopy>) request.getAttribute("copies");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer currentPageNum = (Integer) request.getAttribute("currentPageNum");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedArea = (String) request.getAttribute("selectedArea");
    List<String> distinctAreas = (List<String>) request.getAttribute("distinctAreas");

    String ctx = request.getContextPath();
    if (totalRecords == null) totalRecords = 0;
    if (totalPages == null) totalPages = 1;
    if (currentPageNum == null) currentPageNum = 1;
    if (keyword == null) keyword = "";
    if (selectedStatus == null) selectedStatus = "";
    if (selectedArea == null) selectedArea = "";
%>

<main class="page-wrapper">

<!-- ===== PAGE HEADER ===== -->
<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-boxes-stacked"></i> Quản lý bản sao
                </div>
                <h1 class="books-page-title"><%= book != null ? book.getTitle() : "Đầu sách không tồn tại" %></h1>
                <p class="books-page-subtitle">
                    <a href="<%= ctx %>/book/detail?id=<%= book != null ? book.getId() : "" %>" style="color:var(--primary);">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại chi tiết sách
                    </a>
                </p>
            </div>
            <% if (book != null) { %>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num"><%= totalRecords %></span>
                    <span class="bps-lbl">Tổng bản sao</span>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="container" style="padding-top:28px;">

    <!-- ==================== SEARCH & FILTER BAR ==================== -->
    <form id="searchForm" action="<%= ctx %>/book/copies" method="get">
        <input type="hidden" name="bookId" value="<%= book != null ? book.getId() : "" %>">
        <input type="hidden" name="page" value="1">

        <div class="search-bar-wrapper">
            <div class="search-bar-inner">
                <!-- Barcode Keyword -->
                <div class="search-field" style="flex:2;">
                    <label for="keywordInput">Mã bản sao (Barcode)</label>
                    <div class="search-input-wrap">
                        <i class="fa-solid fa-barcode search-icon"></i>
                        <input type="text" id="keywordInput" name="keyword"
                               class="form-control"
                               placeholder="Nhập mã barcode bản sao..."
                               value="<%= keyword %>"
                               maxlength="50"
                               autocomplete="off">
                    </div>
                </div>

                <!-- Status Filter -->
                <div class="search-field select-field">
                    <label for="statusSelect">Trạng thái</label>
                    <select id="statusSelect" name="status" class="form-select">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="AVAILABLE" <%= "AVAILABLE".equals(selectedStatus) ? "selected" : "" %>>AVAILABLE (Sẵn sàng)</option>
                        <option value="BORROWED" <%= "BORROWED".equals(selectedStatus) ? "selected" : "" %>>BORROWED (Đang mượn)</option>
                        <option value="RESERVED" <%= "RESERVED".equals(selectedStatus) ? "selected" : "" %>>RESERVED (Đặt giữ)</option>
                        <option value="MAINTENANCE" <%= "MAINTENANCE".equals(selectedStatus) ? "selected" : "" %>>MAINTENANCE (Bảo trì)</option>
                        <option value="LOST" <%= "LOST".equals(selectedStatus) ? "selected" : "" %>>LOST (Đã mất)</option>
                    </select>
                </div>

                <!-- Location Area Filter -->
                <div class="search-field select-field">
                    <label for="areaSelect">Khu vực / Tầng</label>
                    <select id="areaSelect" name="area" class="form-select">
                        <option value="">-- Tất cả vị trí --</option>
                        <% if (distinctAreas != null) {
                            for (String a : distinctAreas) {
                                if (a != null) {
                                    String sel = a.equals(selectedArea) ? "selected" : "";
                        %>
                            <option value="<%= a %>" <%= sel %>><%= a %></option>
                        <%      }
                            }
                        } %>
                    </select>
                </div>

                <!-- Buttons -->
                <div style="display:flex; gap:8px; align-items:flex-end;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-search"></i> Tìm
                    </button>
                    <a href="<%= ctx %>/book/copies?bookId=<%= book != null ? book.getId() : "" %>" class="btn btn-outline" title="Xóa bộ lọc">
                        <i class="fa-solid fa-rotate-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </form>

    <!-- ==================== COPIES TABLE ==================== -->
    <% if (copies == null || copies.isEmpty()) { %>
        <div class="empty-state" style="padding:80px 24px;">
            <div class="empty-icon"><i class="fa-solid fa-magnifying-glass"></i></div>
            <h3>Không tìm thấy bản sao nào</h3>
            <p>Thử thay đổi từ khóa barcode hoặc bộ lọc trạng thái/vị trí.</p>
            <a href="<%= ctx %>/book/copies?bookId=<%= book != null ? book.getId() : "" %>" class="btn btn-outline" style="margin-top:16px;">
                <i class="fa-solid fa-rotate-right"></i> Xóa bộ lọc
            </a>
        </div>
    <% } else { %>
        <div class="data-table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Mã bản sao (Barcode)</th>
                        <th>Tình trạng (Condition)</th>
                        <th>Trạng thái (Status)</th>
                        <th>Khu vực / Tầng</th>
                        <th>Kệ / Ngăn</th>
                        <th>Ghi chú</th>
                    </tr>
                </thead>
                <tbody>
                    <% int rowNum = (currentPageNum - 1) * 20 + 1;
                       for (BookCopy bc : copies) { 
                           // Mapping Condition display
                           String conditionLabel = "Tốt";
                           String conditionClass = "badge-success";
                           if ("WORN".equals(bc.getBookCondition())) {
                               conditionLabel = "Hao mòn";
                               conditionClass = "badge-warning";
                           } else if ("DAMAGED".equals(bc.getBookCondition())) {
                               conditionLabel = "Hỏng";
                               conditionClass = "badge-danger";
                           } else if ("LOST".equals(bc.getBookCondition())) {
                               conditionLabel = "Mất";
                               conditionClass = "badge-danger";
                           }

                           // Mapping Status display
                           String statusLabel = "Sẵn sàng";
                           String statusClass = "badge-success";
                           if ("BORROWED".equals(bc.getStatus())) {
                               statusLabel = "Đang mượn";
                               statusClass = "badge-info";
                           } else if ("RESERVED".equals(bc.getStatus())) {
                               statusLabel = "Đặt giữ";
                               statusClass = "badge-warning";
                           } else if ("MAINTENANCE".equals(bc.getStatus())) {
                               statusLabel = "Bảo trì";
                               statusClass = "badge-danger";
                           } else if ("LOST".equals(bc.getStatus())) {
                               statusLabel = "Đã mất";
                               statusClass = "badge-danger";
                           }
                    %>
                        <tr>
                            <td style="color:var(--text-muted); font-size:0.82rem;"><%= rowNum++ %></td>
                            <td style="font-weight: 600; font-family: monospace; letter-spacing: 0.5px;"><%= bc.getBarcode() %></td>
                            <td>
                                <span class="badge <%= conditionClass %>">
                                    <%= conditionLabel %>
                                </span>
                            </td>
                            <td>
                                <span class="badge <%= statusClass %>">
                                    <%= statusLabel %>
                                </span>
                            </td>
                            <td><%= bc.getArea() != null ? bc.getArea() : "—" %></td>
                            <td>
                                <% if (bc.getShelf() != null || bc.getSlot() != null) { %>
                                    <%= bc.getShelf() != null ? bc.getShelf() : "—" %> / <%= bc.getSlot() != null ? bc.getSlot() : "—" %>
                                <% } else { %>
                                    —
                                <% } %>
                            </td>
                            <td style="font-size:0.85rem; color:var(--text-secondary); max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= bc.getNote() != null ? bc.getNote() : "" %>">
                                <%= bc.getNote() != null ? bc.getNote() : "—" %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- ==================== PAGINATION ==================== -->
        <% if (totalPages > 1) { %>
            <nav aria-label="Phân trang">
                <ul class="pagination">
                    <!-- Prev -->
                    <li class="page-item <%= currentPageNum <= 1 ? "disabled" : "" %>">
                        <a class="page-link"
                           href="<%= ctx %>/book/copies?bookId=<%= book.getId() %>&keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&status=<%= java.net.URLEncoder.encode(selectedStatus,"UTF-8") %>&area=<%= java.net.URLEncoder.encode(selectedArea,"UTF-8") %>&page=<%= currentPageNum - 1 %>">
                            <i class="fa-solid fa-chevron-left fa-xs"></i>
                        </a>
                    </li>

                    <% for (int pg = 1; pg <= totalPages; pg++) { %>
                        <li class="page-item <%= pg == currentPageNum ? "active" : "" %>">
                            <a class="page-link" href="<%= ctx %>/book/copies?bookId=<%= book.getId() %>&keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&status=<%= java.net.URLEncoder.encode(selectedStatus,"UTF-8") %>&area=<%= java.net.URLEncoder.encode(selectedArea,"UTF-8") %>&page=<%= pg %>"><%= pg %></a>
                        </li>
                    <% } %>

                    <!-- Next -->
                    <li class="page-item <%= currentPageNum >= totalPages ? "disabled" : "" %>">
                        <a class="page-link"
                           href="<%= ctx %>/book/copies?bookId=<%= book.getId() %>&keyword=<%= java.net.URLEncoder.encode(keyword,"UTF-8") %>&status=<%= java.net.URLEncoder.encode(selectedStatus,"UTF-8") %>&area=<%= java.net.URLEncoder.encode(selectedArea,"UTF-8") %>&page=<%= currentPageNum + 1 %>">
                            <i class="fa-solid fa-chevron-right fa-xs"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        <% } %>
    <% } %>

</div>
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
