<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (request.getAttribute("featuredBooks") == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
%>
<%@ page import="com.swp391.model.Book, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    List<Book> featuredBooks = (List<Book>) request.getAttribute("featuredBooks");
    Integer totalBooks       = (Integer) request.getAttribute("totalBooks");
    Integer totalCategories  = (Integer) request.getAttribute("totalCategories");
    String  dbError          = (String)  request.getAttribute("dbError");
%>

<main class="page-wrapper">

    <!-- ==================== HERO BANNER ==================== -->
    <section class="hero">
        <div class="hero-grid-bg"></div>
        <div class="container" style="position:relative;z-index:1;">
            <div class="hero-content">
                <div class="hero-eyebrow">
                    <i class="fa-solid fa-graduation-cap"></i>
                    FPT University Library System
                </div>
                <h1 class="hero-title">
                    Kho tri thức<br>
                    <span class="highlight">dành cho bạn</span>
                </h1>
                <p class="hero-description">
                    Khám phá hàng nghìn đầu sách học thuật, tài liệu chuyên ngành và tạp chí khoa học.
                    Đặt mượn trực tuyến, tra cứu nhanh chóng – mọi lúc, mọi nơi.
                </p>

                <!-- Quick Search -->
                <form class="hero-search" action="<%= contextPath %>/books" method="get" role="search"
                      onsubmit="return validateHeroSearch(this)">
                    <input type="text" name="keyword" id="heroSearchInput"
                           placeholder="Tìm tên sách, tác giả, chủ đề..."
                           maxlength="200"
                           autocomplete="off">
                    <button type="submit">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        Tìm kiếm
                    </button>
                </form>
                <div id="heroSearchError" style="color:var(--danger);font-size:0.82rem;margin-top:6px;display:none;"></div>

                <!-- Stats -->
                <div class="hero-stats">
                    <div class="hero-stat">
                        <span class="number"><span><%= totalBooks != null ? totalBooks : "—" %></span>+</span>
                        <span class="label">Đầu sách</span>
                    </div>
                    <div class="hero-stat">
                        <span class="number"><span><%= totalCategories != null ? totalCategories : "—" %></span></span>
                        <span class="label">Danh mục</span>
                    </div>
                    <div class="hero-stat">
                        <span class="number">24/7</span>
                        <span class="label">Tra cứu online</span>
                    </div>
                </div>
            </div>

            <!-- Decorative book stack -->
            <div class="hero-visual">
                <div class="hero-visual-inner">
                    <div class="hero-book-stack">📗</div>
                    <div class="hero-book-stack">📘</div>
                    <div class="hero-book-stack">📙</div>
                    <div class="hero-book-stack">📕</div>
                    <div class="hero-book-stack">📓</div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== FEATURED BOOKS ==================== -->
    <section style="padding: 72px 0;">
        <div class="container">

            <% if (dbError != null) { %>
                <div class="alert alert-warning">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <%= dbError %>
                </div>
            <% } %>

            <div class="section-header">
                <div>
                    <h2 class="section-title">Sách mới nhất</h2>
                    <p class="section-subtitle">Những đầu sách vừa được bổ sung vào thư viện</p>
                </div>
                <a href="<%= contextPath %>/books" class="btn btn-outline">
                    Xem tất cả <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

            <% if (featuredBooks != null && !featuredBooks.isEmpty()) { %>
                <div class="books-grid">
                    <% for (Book book : featuredBooks) { %>
                        <div class="book-card">
                            <div class="book-cover">
                                <% if (book.getCoverImage() != null && !book.getCoverImage().trim().isEmpty()) { %>
                                    <img src="<%= book.getCoverImage() %>"
                                         alt="<%= book.getTitle() %>"
                                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                    <div class="book-cover-placeholder" style="display:none;">
                                        <i class="fa-solid fa-book-open"></i>
                                        <span><%= book.getTitle() %></span>
                                    </div>
                                <% } else { %>
                                    <div class="book-cover-placeholder">
                                        <i class="fa-solid fa-book-open"></i>
                                        <span><%= book.getTitle() %></span>
                                    </div>
                                <% } %>
                                <span class="book-status-tag <%= book.getStatusClass() %>">
                                    <%= book.getStatusLabel() %>
                                </span>
                            </div>
                            <div class="book-body">
                                <div class="book-category"><%= book.getCategory() != null ? book.getCategory() : "—" %></div>
                                <div class="book-title" title="<%= book.getTitle() %>"><%= book.getTitle() %></div>
                                <% if (book.getPublisher() != null) { %>
                                    <div class="book-publisher">
                                        <i class="fa-solid fa-building fa-xs"></i>
                                        <%= book.getPublisher() %>
                                        <% if (book.getPublishYear() != null) { %> · <%= book.getPublishYear() %><% } %>
                                    </div>
                                <% } %>
                                <div class="book-price"><%= book.getFormattedPrice() %></div>
                            </div>
                            <div class="book-footer">
                                <span style="font-size:0.78rem;color:var(--text-muted);">
                                    <i class="fa-solid fa-layer-group fa-xs"></i>
                                    <%= book.getAvailable() %>/<%= book.getQuantity() %> còn lại
                                </span>
                                <a href="<%= contextPath %>/books?keyword=<%= java.net.URLEncoder.encode(book.getTitle(),"UTF-8") %>"
                                   class="btn btn-primary btn-sm">Chi tiết</a>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <div class="empty-icon"><i class="fa-solid fa-box-open"></i></div>
                    <h3>Chưa có dữ liệu sách</h3>
                    <p>Hệ thống chưa có sách nào hoặc không kết nối được CSDL.</p>
                </div>
            <% } %>
        </div>
    </section>

    <!-- ==================== WHY SECTION ==================== -->
    <section class="why-section">
        <div class="container">
            <div style="text-align:center; margin-bottom:48px;">
                <h2 class="section-title" style="display:inline-block;">Tại sao chọn FPT Library?</h2>
                <p class="section-subtitle" style="margin-top:16px;">Trải nghiệm thư viện hiện đại – thông minh – tiện lợi</p>
            </div>
            <div class="info-grid">
                <div class="info-card">
                    <div class="info-card-icon">🔍</div>
                    <h3>Tìm kiếm thông minh</h3>
                    <p>Tra cứu sách theo tên, tác giả, danh mục và môn học. Kết quả hiển thị ngay tức thì.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">📦</div>
                    <h3>Quản lý bản sao</h3>
                    <p>Theo dõi số lượng bản in còn lại, trạng thái mượn trả và vị trí kệ sách chính xác.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">📅</div>
                    <h3>Đặt trước trực tuyến</h3>
                    <p>Khi sách đang được mượn, bạn có thể đặt trước để nhận thông báo khi sách được trả.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">🔔</div>
                    <h3>Nhắc nhở thông minh</h3>
                    <p>Hệ thống tự động gửi thông báo nhắc trả sách, hạn mượn và phí phạt (nếu có).</p>
                </div>
            </div>

            <!-- Stat strip -->
            <div class="stat-strip">
                <div class="stat-item">
                    <div class="stat-number"><%= totalBooks != null ? totalBooks : "300" %>+</div>
                    <div class="stat-label">Đầu sách</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= totalCategories != null ? totalCategories : "10" %></div>
                    <div class="stat-label">Danh mục</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">50+</div>
                    <div class="stat-label">Tác giả</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">24/7</div>
                    <div class="stat-label">Tra cứu online</div>
                </div>
            </div>
        </div>
    </section>

</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<script>
function validateHeroSearch(form) {
    var kw = document.getElementById('heroSearchInput').value;
    var errEl = document.getElementById('heroSearchError');
    if (kw.length > 200) {
        errEl.textContent = 'Từ khóa không được vượt quá 200 ký tự.';
        errEl.style.display = 'block';
        return false;
    }
    errEl.style.display = 'none';
    return true;
}
</script>
