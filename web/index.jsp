<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        <div class="container">
            <div class="hero-content">
                <div class="hero-eyebrow">
                    <i class="fa-solid fa-star"></i>
                    Thư viện FPT University
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
                <form class="hero-search" action="<%= contextPath %>/books" method="get" role="search">
                    <input type="text" name="keyword" id="heroSearchInput"
                           placeholder="Tìm tên sách, tác giả, chủ đề..."
                           maxlength="200"
                           autocomplete="off">
                    <button type="submit">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        Tìm kiếm
                    </button>
                </form>

                <!-- Stats -->
                <div class="hero-stats">
                    <div class="hero-stat">
                        <span class="number"><%= totalBooks != null ? totalBooks : "—" %>+</span>
                        <span class="label">Đầu sách</span>
                    </div>
                    <div class="hero-stat">
                        <span class="number"><%= totalCategories != null ? totalCategories : "—" %></span>
                        <span class="label">Danh mục</span>
                    </div>
                    <div class="hero-stat">
                        <span class="number">24/7</span>
                        <span class="label">Tra cứu online</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== FEATURED BOOKS ==================== -->
    <section style="padding: 64px 0;">
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
    <section style="padding: 60px 0; background: var(--bg-card); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
        <div class="container">
            <div style="text-align:center; margin-bottom:40px;">
                <h2 class="section-title" style="display:inline-block;">Tại sao chọn FPT Library?</h2>
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
        </div>
    </section>

</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
