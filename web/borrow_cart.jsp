<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.BorrowCartItem, com.swp391.model.User, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    List<BorrowCartItem> cart = (List<BorrowCartItem>) request.getAttribute("cart");
    String ctx = request.getContextPath();

    // Messages từ session
    String cartMsg   = (String) session.getAttribute("cartMsg");
    String borrowMsg = (String) session.getAttribute("borrowMsg");
    session.removeAttribute("cartMsg");
    session.removeAttribute("borrowMsg");
%>

<main class="page-wrapper">

<!-- ===== PAGE HEADER ===== -->
<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-cart-shopping"></i> Giỏ sách mượn
                </div>
                <h1 class="books-page-title">Giỏ sách của tôi</h1>
                <p class="books-page-subtitle">Xem lại và xác nhận danh sách sách bạn muốn mượn</p>
            </div>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num"><%= cart != null ? cart.size() : 0 %></span>
                    <span class="bps-lbl">Sách đã chọn</span>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding-top:32px; padding-bottom:60px;">

    <!-- ===== MESSAGES ===== -->
    <% if ("added".equals(cartMsg)) { %>
    <div class="alert alert-success" style="margin-bottom:20px;">
        <i class="fa-solid fa-circle-check"></i> Đã thêm sách vào giỏ thành công!
    </div>
    <% } else if ("already".equals(cartMsg)) { %>
    <div class="alert alert-warning" style="margin-bottom:20px;">
        <i class="fa-solid fa-triangle-exclamation"></i> Sách này đã có trong giỏ của bạn rồi.
    </div>
    <% } else if ("unavailable".equals(cartMsg)) { %>
    <div class="alert alert-danger" style="margin-bottom:20px;">
        <i class="fa-solid fa-circle-xmark"></i> Sách này hiện không còn bản nào để mượn.
    </div>
    <% } %>

    <% if ("success".equals(borrowMsg)) { %>
    <div class="alert alert-success" style="margin-bottom:20px; background: rgba(46,213,115,0.12); border-left: 4px solid var(--success); padding: 18px 20px; border-radius: var(--radius-md); display:flex; align-items:flex-start; gap:14px;">
        <i class="fa-solid fa-circle-check" style="color:var(--success); font-size:1.3rem; margin-top:2px;"></i>
        <div>
            <strong style="color:var(--success); display:block; font-size:1rem; margin-bottom:4px;">Gửi phiếu mượn thành công!</strong>
            <span style="color:var(--text-secondary); font-size:0.9rem;">Phiếu mượn của bạn đã được gửi đến thủ thư để xét duyệt. Bạn sẽ được thông báo khi phiếu được chấp nhận.</span>
        </div>
    </div>
    <% } else if ("failed".equals(borrowMsg)) { %>
    <div class="alert alert-danger" style="margin-bottom:20px;">
        <i class="fa-solid fa-circle-xmark"></i> Gửi phiếu mượn thất bại. Vui lòng thử lại.
    </div>
    <% } else if ("empty".equals(borrowMsg)) { %>
    <div class="alert alert-warning" style="margin-bottom:20px;">
        <i class="fa-solid fa-triangle-exclamation"></i> Giỏ sách trống, vui lòng chọn ít nhất 1 sách.
    </div>
    <% } %>

    <div class="borrow-cart-layout">

        <!-- ===== LEFT: CART ITEMS ===== -->
        <div class="borrow-cart-items">
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:20px;">
                <h2 style="font-size:1.1rem; font-weight:700; color:var(--text-primary);">
                    <i class="fa-solid fa-list-check" style="color:var(--primary);"></i>
                    Danh sách sách đã chọn
                </h2>
                <% if (cart != null && !cart.isEmpty()) { %>
                <a href="<%= ctx %>/books" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-plus"></i> Thêm sách
                </a>
                <% } %>
            </div>

            <% if (cart == null || cart.isEmpty()) { %>
            <!-- Empty State -->
            <div style="text-align:center; padding:80px 24px; background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-lg);">
                <div style="font-size:4rem; margin-bottom:16px; opacity:0.4;">🛒</div>
                <h3 style="color:var(--text-primary); font-size:1.1rem; font-weight:700; margin-bottom:8px;">Giỏ sách trống</h3>
                <p style="color:var(--text-muted); font-size:0.9rem; margin-bottom:24px;">Bạn chưa chọn sách nào. Hãy duyệt danh sách sách và thêm vào giỏ!</p>
                <a href="<%= ctx %>/books" class="btn btn-primary">
                    <i class="fa-solid fa-book"></i> Xem danh sách sách
                </a>
            </div>
            <% } else {
                int idx = 1;
                for (BorrowCartItem item : cart) { %>
            <div class="borrow-cart-item-card" style="animation-delay:<%= (idx-1) * 0.08 %>s">
                <div class="borrow-cart-item-num"><%= idx++ %></div>
                <div class="borrow-cart-item-icon">
                    <i class="fa-solid fa-book-open"></i>
                </div>
                <div class="borrow-cart-item-info">
                    <div class="borrow-cart-item-title"><%= item.getBookTitle() %></div>
                    <div class="borrow-cart-item-meta">
                        <% if (item.getBookIsbn() != null) { %>
                        <span><i class="fa-solid fa-barcode fa-xs"></i> <%= item.getBookIsbn() %></span>
                        <% } %>
                        <% if (item.getBookCategory() != null) { %>
                        <span class="badge badge-primary" style="font-size:0.72rem;"><%= item.getBookCategory() %></span>
                        <% } %>
                        <span style="color:<%= item.getAvailable() > 0 ? "var(--success)" : "var(--danger)" %>; font-size:0.78rem; font-weight:600;">
                            <i class="fa-solid fa-layer-group fa-xs"></i>
                            Còn <%= item.getAvailable() %> bản
                        </span>
                    </div>
                </div>
                <form method="post" action="<%= ctx %>/borrow" style="flex-shrink:0;">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="bookId" value="<%= item.getBookId() %>">
                    <button type="submit" class="btn btn-danger btn-sm" title="Xóa khỏi giỏ"
                            onclick="return confirm('Xóa sách này khỏi giỏ?')">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </form>
            </div>
            <% } } %>
        </div>

        <!-- ===== RIGHT: ORDER SUMMARY ===== -->
        <div class="borrow-cart-summary">
            <div style="background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-lg); overflow:hidden; position:sticky; top:80px;">
                <!-- Summary header -->
                <div style="background:linear-gradient(135deg,var(--primary),var(--primary-dark)); padding:20px 24px; color:#fff;">
                    <div style="font-size:0.78rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; opacity:0.85; margin-bottom:4px;">
                        <i class="fa-solid fa-clipboard-list"></i> Tóm tắt đơn mượn
                    </div>
                    <div style="font-size:1.6rem; font-weight:800;">
                        <%= cart != null ? cart.size() : 0 %> <span style="font-size:1rem; opacity:0.8;">quyển sách</span>
                    </div>
                </div>

                <div style="padding:20px 24px;">
                    <!-- Policy info -->
                    <div style="background:rgba(244,121,32,0.06); border:1px solid rgba(244,121,32,0.15); border-radius:var(--radius-sm); padding:14px; margin-bottom:20px;">
                        <div style="font-size:0.8rem; font-weight:700; color:var(--primary); margin-bottom:10px;">
                            <i class="fa-solid fa-circle-info"></i> Quy định mượn sách
                        </div>
                        <ul style="font-size:0.82rem; color:var(--text-secondary); line-height:1.8; padding-left:16px;">
                            <li>Thời hạn mượn: <strong>14 ngày</strong></li>
                            <li>Phiếu cần được <strong>thủ thư xét duyệt</strong></li>
                            <li>Vui lòng đến quầy để nhận sách</li>
                            <li>Trễ hạn sẽ bị tính phí phạt</li>
                        </ul>
                    </div>

                    <!-- Borrower info -->
                    <% if (loggedUser != null) { %>
                    <div style="border-bottom:1px solid var(--border); padding-bottom:14px; margin-bottom:14px;">
                        <div style="font-size:0.78rem; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px; margin-bottom:8px; font-weight:700;">
                            Người mượn
                        </div>
                        <div style="display:flex; align-items:center; gap:10px;">
                            <div style="width:36px; height:36px; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); border-radius:50%; display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:0.9rem; flex-shrink:0;">
                                <%= loggedUser.getFullName() != null ? loggedUser.getFullName().charAt(0) : loggedUser.getUsername().charAt(0) %>
                            </div>
                            <div>
                                <div style="font-size:0.9rem; font-weight:600; color:var(--text-primary);">
                                    <%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %>
                                </div>
                                <div style="font-size:0.78rem; color:var(--text-muted);"><%= loggedUser.getEmail() != null ? loggedUser.getEmail() : "" %></div>
                            </div>
                        </div>
                    </div>
                    <% } %>

                    <!-- Confirm button -->
                    <% if (cart != null && !cart.isEmpty()) { %>
                    <form method="post" action="<%= ctx %>/borrow"
                          onsubmit="return confirm('Xác nhận gửi phiếu mượn <%= cart.size() %> sách đến thủ thư để duyệt?')">
                        <input type="hidden" name="action" value="confirm">
                        <button type="submit" class="btn btn-primary" style="width:100%; justify-content:center; padding:14px; font-size:0.95rem; border-radius:var(--radius-md);">
                            <i class="fa-solid fa-paper-plane"></i>
                            Xác nhận mượn
                        </button>
                    </form>
                    <p style="font-size:0.78rem; color:var(--text-muted); text-align:center; margin-top:10px;">
                        Phiếu sẽ được gửi đến thủ thư xét duyệt
                    </p>
                    <% } else { %>
                    <button class="btn btn-outline" style="width:100%; justify-content:center; padding:14px; border-radius:var(--radius-md); opacity:0.5; cursor:not-allowed;" disabled>
                        <i class="fa-solid fa-paper-plane"></i> Xác nhận mượn
                    </button>
                    <% } %>

                    <a href="<%= ctx %>/books" style="display:block; text-align:center; margin-top:12px; font-size:0.85rem; color:var(--text-muted);">
                        <i class="fa-solid fa-arrow-left fa-xs"></i> Tiếp tục chọn sách
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<style>
/* ===== Borrow Cart Layout ===== */
.borrow-cart-layout {
    display: grid;
    grid-template-columns: 1fr 340px;
    gap: 28px;
    align-items: flex-start;
}
@media (max-width: 900px) {
    .borrow-cart-layout { grid-template-columns: 1fr; }
}

/* Cart Item Card */
.borrow-cart-item-card {
    display: flex;
    align-items: center;
    gap: 16px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 16px 18px;
    margin-bottom: 12px;
    transition: all 0.2s ease;
    animation: slideInUp 0.3s ease both;
}
.borrow-cart-item-card:hover {
    border-color: rgba(244,121,32,0.3);
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
}
@keyframes slideInUp {
    from { opacity: 0; transform: translateY(12px); }
    to   { opacity: 1; transform: translateY(0); }
}

.borrow-cart-item-num {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: var(--bg-surface);
    color: var(--text-muted);
    font-size: 0.78rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.borrow-cart-item-icon {
    width: 48px;
    height: 60px;
    background: linear-gradient(135deg, rgba(244,121,32,0.1), rgba(244,121,32,0.05));
    border: 1px solid rgba(244,121,32,0.15);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--primary);
    font-size: 1.2rem;
    flex-shrink: 0;
}

.borrow-cart-item-info {
    flex: 1;
    min-width: 0;
}

.borrow-cart-item-title {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-primary);
    line-height: 1.4;
    margin-bottom: 6px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.borrow-cart-item-meta {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    font-size: 0.8rem;
    color: var(--text-muted);
}
</style>
