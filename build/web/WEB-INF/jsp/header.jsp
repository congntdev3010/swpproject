<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    String currentPage = request.getAttribute("currentPage") != null
        ? (String) request.getAttribute("currentPage") : "";
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
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
                       class="nav-link <%= "home".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/books"
                       class="nav-link <%= "books".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book"></i> Danh sách sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/about"
                       class="nav-link <%= "about".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-circle-info"></i> Giới thiệu
                    </a>
                </li>
                
                <% if (loggedUser != null) { %>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/borrow?action=list"
                       class="nav-link <%= "borrow".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-book-bookmark"></i> Phiếu Mượn
                    </a>
                </li>
                <% } %>

                <% if (loggedUser != null && loggedUser.isAdminOrLibrarian()) { %>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/return-book"
                       class="nav-link <%= "return-book".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-rotate-left"></i> Trả Sách
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/shelf"
                       class="nav-link <%= "shelf".equals(currentPage) ? "active" : "" %>">
                        <i class="fa-solid fa-layer-group"></i> Vị trí kệ
                    </a>
                </li>
                <% } %>
            </ul>

            <div class="navbar-actions">
                <% if (loggedUser != null) { %>
                    <div class="cart-wrapper" style="position: relative; display: inline-block; margin-right: 15px;">
                        <button id="cartToggle" class="btn btn-outline btn-sm" title="Danh sách mượn" style="position: relative;">
                            <i class="fa-solid fa-cart-shopping"></i> Mượn sách
                            <span id="cartBadge" class="cart-badge" style="position: absolute; top: -5px; right: -5px; background: #e74c3c; color: white; border-radius: 50%; padding: 2px 6px; font-size: 10px; display: none;">0</span>
                        </button>
                        <div id="cartMenu" class="cart-menu" style="display: none; position: absolute; right: 0; top: 100%; margin-top: 10px; background: white; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); width: 320px; z-index: 1000; text-align: left;">
                            <div style="padding: 15px; border-bottom: 1px solid #eee;">
                                <h6 style="margin: 0; font-weight: 600; color: #333;">Danh sách sách mượn</h6>
                            </div>
                            <div id="cartItems" style="max-height: 300px; overflow-y: auto; padding: 10px;">
                                <!-- Items -->
                            </div>
                            <div style="padding: 15px; border-top: 1px solid #eee;">
                                <button id="checkoutBtn" class="btn btn-primary" style="width: 100%;">Xác nhận mượn sách</button>
                            </div>
                        </div>
                    </div>

                    <a href="<%= request.getContextPath() %>/user/profile" class="user-info" title="Hồ sơ cá nhân">
                        <i class="fa-solid fa-circle-user"></i>
                        <span><%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %></span>
                        <span class="user-role-badge <%= loggedUser.getRole().toLowerCase() %>">
                            <%= loggedUser.getRole() %>
                        </span>
                    </a>
                    <% if (loggedUser.isAdminOrLibrarian()) { %>
                        <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-outline btn-sm navbar-admin-link" title="Quản lý hệ thống">
                            <i class="fa-solid fa-user-gear"></i>
                        </a>
                    <% } %>
                    
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">
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

        // Cart Logic
        <% if (loggedUser != null) { %>
        const cartToggle = document.getElementById('cartToggle');
        const cartMenu = document.getElementById('cartMenu');
        const cartItemsContainer = document.getElementById('cartItems');
        const cartBadge = document.getElementById('cartBadge');
        const checkoutBtn = document.getElementById('checkoutBtn');

        function loadCart() {
            fetch('<%= request.getContextPath() %>/borrow-cart?action=view')
                .then(res => res.json())
                .then(data => {
                    if(data.status === 'success') {
                        const items = data.cart;
                        updateBadge(items.length);
                        renderCartItems(items);
                    }
                }).catch(err => console.error(err));
        }

        function updateBadge(count) {
            if(count > 0) {
                cartBadge.innerText = count;
                cartBadge.style.display = 'inline-block';
            } else {
                cartBadge.style.display = 'none';
            }
        }

        function renderCartItems(items) {
            if(items.length === 0) {
                cartItemsContainer.innerHTML = '<div style="padding:10px;text-align:center;color:#888;">Chưa có sách nào</div>';
                return;
            }
            let html = '';
            items.forEach(book => {
                html += `
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; border-bottom:1px solid #f9f9f9; padding-bottom:5px;">
                        <div style="flex:1; overflow:hidden;">
                            <div style="font-weight:500; font-size:14px; white-space:nowrap; text-overflow:ellipsis; overflow:hidden;">${book.title}</div>
                        </div>
                        <button class="btn btn-outline btn-sm remove-cart-item" data-id="${book.id}" style="border:none; color:#e74c3c;">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </div>
                `;
            });
            cartItemsContainer.innerHTML = html;

            document.querySelectorAll('.remove-cart-item').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    const bookId = this.getAttribute('data-id');
                    removeFromCart(bookId);
                });
            });
        }

        function removeFromCart(bookId) {
            const formData = new URLSearchParams();
            formData.append('action', 'remove');
            formData.append('bookId', bookId);

            fetch('<%= request.getContextPath() %>/borrow-cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if(data.status === 'success') {
                    loadCart();
                } else {
                    alert(data.message);
                }
            });
        }

        cartToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            const isShowing = cartMenu.style.display === 'block';
            cartMenu.style.display = isShowing ? 'none' : 'block';
            if(!isShowing) loadCart();
        });

        document.addEventListener('click', function(e) {
            if (!cartMenu.contains(e.target) && !cartToggle.contains(e.target)) {
                cartMenu.style.display = 'none';
            }
        });

        checkoutBtn.addEventListener('click', function() {
            checkoutBtn.disabled = true;
            checkoutBtn.innerText = 'Đang xử lý...';
            const formData = new URLSearchParams();
            formData.append('action', 'checkout');

            fetch('<%= request.getContextPath() %>/borrow-cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                alert(data.message);
                loadCart();
            })
            .finally(() => {
                checkoutBtn.disabled = false;
                checkoutBtn.innerText = 'Xác nhận mượn sách';
                cartMenu.style.display = 'none';
            });
        });

        // Expose a global function to add to cart from other pages
        window.addToBorrowCart = function(bookId) {
            const formData = new URLSearchParams();
            formData.append('action', 'add');
            formData.append('bookId', bookId);

            fetch('<%= request.getContextPath() %>/borrow-cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if(data.status === 'success') {
                    alert('Đã thêm vào danh sách mượn sách');
                    updateBadge(data.cartCount);
                } else if(data.status === 'info') {
                    alert(data.message);
                } else {
                    alert(data.message);
                }
            });
        };

        // initial load to set badge
        loadCart();
        <% } %>
    })();
</script>
</body>
</html>