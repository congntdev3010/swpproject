<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Book, com.swp391.model.Author, com.swp391.model.User, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    Book book       = (Book) request.getAttribute("book");
    List<Author> authors = (List<Author>) request.getAttribute("authors");
    String errorMsg  = (String) request.getAttribute("errorMsg");
    Boolean isAdmin  = (Boolean) request.getAttribute("isAdmin");
    if (isAdmin == null) isAdmin = false;

    String ctx       = request.getContextPath();

    // Success/error messages from redirect
    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>

<main class="page-wrapper">

<!-- ===== PAGE HEADER ===== -->
<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-book-open"></i> Chi tiết sách
                </div>
                <h1 class="books-page-title"><%= book != null ? book.getTitle() : "Sách không tồn tại" %></h1>
                <p class="books-page-subtitle">
                    <a href="<%= ctx %>/books" style="color:var(--primary);"><i class="fa-solid fa-arrow-left"></i> Quay lại danh sách</a>
                </p>
            </div>
            <% if (book != null) { %>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num"><%= book.getAvailable() %>/<%= book.getQuantity() %></span>
                    <span class="bps-lbl">Bản sao còn</span>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="container" style="padding-top:28px;">

    <!-- Alerts -->
    <% if ("created".equals(success)) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Thêm sách thành công!</div>
    <% } else if ("updated".equals(success)) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Cập nhật sách thành công!</div>
    <% } %>
    <% if ("has_copies".equals(error)) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> Không thể xóa sách: còn bản sao vật lý liên kết.</div>
    <% } else if ("has_active".equals(error)) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> Không thể xóa sách: đang có lượt mượn hoặc đặt trước.</div>
    <% } else if ("delete_failed".equals(error) || "exception".equals(error)) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> Xóa sách thất bại do lỗi hệ thống hoặc dữ liệu liên kết.</div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> <%= errorMsg %></div>
    <% } %>

    <% if (book == null) { %>
        <div class="empty-state" style="padding:80px 24px;">
            <div class="empty-icon"><i class="fa-solid fa-book"></i></div>
            <h3>Không tìm thấy sách</h3>
            <p>Sách bạn đang tìm không tồn tại hoặc đã bị xóa.</p>
            <a href="<%= ctx %>/books" class="btn btn-outline" style="margin-top:16px;">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    <% } else { %>

    <!-- ===== BOOK DETAIL CONTENT ===== -->
    <div class="book-detail-layout">
        <!-- Left: Cover -->
        <div class="book-detail-cover-section">
            <div class="book-detail-cover">
                <% if (book.getCoverImage() != null && !book.getCoverImage().trim().isEmpty()) { %>
                    <img src="<%= book.getCoverImage() %>" alt="<%= book.getTitle() %>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                    <div class="book-detail-cover-placeholder" style="display:none;">
                        <i class="fa-solid fa-book-open"></i>
                        <span><%= book.getTitle() %></span>
                    </div>
                <% } else { %>
                    <div class="book-detail-cover-placeholder">
                        <i class="fa-solid fa-book-open"></i>
                        <span><%= book.getTitle() %></span>
                    </div>
                <% } %>
            </div>
            <div class="book-detail-status">
                <span class="badge <%= book.getAvailable() > 0 ? "badge-success" : (book.getQuantity() > 0 ? "badge-warning" : "badge-danger") %>" style="font-size:0.85rem; padding:6px 16px;">
                    <i class="fa-solid <%= book.getAvailable() > 0 ? "fa-circle-check" : "fa-circle-xmark" %>"></i>
                    <%= book.getStatusLabel() %>
                </span>
            </div>
            <!-- Admin Actions -->
            <% if (isAdmin) { %>
            <div class="book-detail-actions">
                <a href="<%= ctx %>/book/edit?id=<%= book.getId() %>" class="btn btn-primary" style="flex:1;">
                    <i class="fa-solid fa-pen"></i> Chỉnh sửa
                </a>
                <button type="button" class="btn btn-danger" style="flex:1;" onclick="confirmDeleteBook()">
                    <i class="fa-solid fa-trash"></i> Xóa sách
                </button>
            </div>
            <% } %>
        </div>

        <!-- Right: Info -->
        <div class="book-detail-info-section">
            <!-- Basic Info Card -->
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="fa-solid fa-circle-info"></i> Thông tin cơ bản
                </div>
                <div class="detail-card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-hashtag"></i> ISBN</span>
                            <span class="detail-value"><code><%= book.getIsbn() %></code></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-heading"></i> Tiêu đề</span>
                            <span class="detail-value" style="font-weight:600;"><%= book.getTitle() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-layer-group"></i> Danh mục</span>
                            <span class="detail-value">
                                <a href="<%= ctx %>/books?category=<%= java.net.URLEncoder.encode(book.getCategory() != null ? book.getCategory() : "", "UTF-8") %>" class="badge badge-primary">
                                    <%= book.getCategory() != null ? book.getCategory() : "—" %>
                                </a>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-users"></i> Tác giả</span>
                            <span class="detail-value">
                                <% if (authors != null && !authors.isEmpty()) {
                                    StringBuilder authorNames = new StringBuilder();
                                    for (int i = 0; i < authors.size(); i++) {
                                        if (i > 0) authorNames.append(", ");
                                        authorNames.append(authors.get(i).getName());
                                    }
                                %>
                                    <%= authorNames.toString() %>
                                <% } else { %>
                                    <span style="color:var(--text-muted);">Chưa có thông tin</span>
                                <% } %>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-building"></i> Nhà xuất bản</span>
                            <span class="detail-value"><%= book.getPublisher() != null ? book.getPublisher() : "—" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-calendar"></i> Năm xuất bản</span>
                            <span class="detail-value"><%= book.getPublishYear() != null ? book.getPublishYear() : "—" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-tag"></i> Giá</span>
                            <span class="detail-value" style="color:var(--accent); font-weight:700;"><%= book.getFormattedPrice() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-book"></i> Môn học</span>
                            <span class="detail-value"><%= book.getSubject() != null ? book.getSubject() : "—" %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Inventory Card -->
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="fa-solid fa-boxes-stacked"></i> Thông tin tồn kho
                </div>
                <div class="detail-card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-cubes"></i> Tổng số bản</span>
                            <span class="detail-value" style="font-weight:700; font-size:1.1rem;"><%= book.getQuantity() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-check-circle"></i> Còn cho mượn</span>
                            <span class="detail-value" style="font-weight:700; font-size:1.1rem; color:var(--success);"><%= book.getAvailable() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-location-dot"></i> Khu vực</span>
                            <span class="detail-value"><%= book.getArea() != null ? book.getArea() : "—" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label"><i class="fa-solid fa-table-cells"></i> Kệ / Ngăn</span>
                            <span class="detail-value">
                                <%= book.getShelf() != null ? book.getShelf() : "—" %> / <%= book.getSlot() != null ? book.getSlot() : "—" %>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Description Card -->
            <% if (book.getDescription() != null && !book.getDescription().trim().isEmpty()) { %>
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="fa-solid fa-align-left"></i> Mô tả
                </div>
                <div class="detail-card-body">
                    <p style="color:var(--text-secondary); line-height:1.8; font-size:0.92rem;">
                        <%= book.getDescription() %>
                    </p>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <% } %> <!-- end if book != null -->

</div><!-- /container -->
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<% if (book != null && isAdmin) { %>
<!-- ===== DELETE CONFIRMATION MODAL ===== -->
<div id="deleteBookModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.7); z-index:9999; align-items:center; justify-content:center; backdrop-filter:blur(4px);">
    <div style="background:var(--bg-card); border:1px solid var(--border-light); border-radius:var(--radius-lg); padding:36px; max-width:440px; width:90%; box-shadow:var(--shadow-lg); position:relative;">
        <div style="position:absolute; top:0; left:0; right:0; height:3px; background:linear-gradient(to right,var(--danger),#ff6b6b); border-radius:var(--radius-lg) var(--radius-lg) 0 0;"></div>
        <div style="font-size:2.5rem; margin-bottom:14px; text-align:center;">🗑️</div>
        <h3 style="font-size:1.15rem; font-weight:700; color:var(--text-primary); margin-bottom:10px; text-align:center;">Xác nhận xóa sách</h3>
        <p style="color:var(--text-secondary); font-size:0.9rem; margin-bottom:28px; text-align:center; line-height:1.6;">
            Bạn có chắc muốn xóa sách: "<strong><%= book.getTitle() %></strong>"?<br>
            <span style="color:var(--danger); font-size:0.82rem;">Hành động này không thể hoàn tác.</span>
        </p>
        <div style="display:flex; gap:12px; justify-content:flex-end;">
            <button onclick="document.getElementById('deleteBookModal').style.display='none'" class="btn btn-outline">Hủy</button>
            <a href="<%= ctx %>/book/delete?id=<%= book.getId() %>" class="btn btn-danger">
                <i class="fa-solid fa-trash"></i> Xóa
            </a>
        </div>
    </div>
</div>

<script>
function confirmDeleteBook() {
    document.getElementById('deleteBookModal').style.display = 'flex';
}
document.getElementById('deleteBookModal').addEventListener('click', function(e) {
    if (e.target === this) this.style.display = 'none';
});
</script>
<% } %>
