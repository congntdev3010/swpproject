<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- ===== FOOTER ===== -->
<footer class="footer">
    <div class="container">
        <div class="footer-grid">
            <!-- Brand Column -->
            <div class="footer-brand">
                <div class="brand-name" style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">
                    <img src="${pageContext.request.contextPath}/images/logo.png" alt="FPT University" style="height:32px;width:auto;display:block;">
                    <span>FPT <span style="color:var(--primary);">Library</span></span>
                </div>
                <p>Hệ thống quản lý thư viện hiện đại, phục vụ sinh viên và giảng viên FPT University với kho tài liệu học thuật phong phú.</p>
            </div>

            <!-- Quick Links -->
            <div>
                <div class="footer-heading">Liên kết nhanh</div>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house fa-xs"></i> Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/books"><i class="fa-solid fa-book fa-xs"></i> Danh sách sách</a></li>
                    <li><a href="${pageContext.request.contextPath}/about"><i class="fa-solid fa-circle-info fa-xs"></i> Giới thiệu</a></li>
                    <c:choose>
                        <c:when test="${empty sessionScope.loggedUser}">
                            <li><a href="${pageContext.request.contextPath}/login"><i class="fa-solid fa-right-to-bracket fa-xs"></i> Đăng nhập</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-right-from-bracket fa-xs"></i> Đăng xuất</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>

            <!-- Contact -->
            <div>
                <div class="footer-heading">Liên hệ</div>
                <div class="footer-contact-item">
                    <span class="icon"><i class="fa-solid fa-location-dot"></i></span>
                    <span>Khu CNC Hòa Lạc, Thạch Thất, Hà Nội</span>
                </div>
                <div class="footer-contact-item">
                    <span class="icon"><i class="fa-solid fa-phone"></i></span>
                    <span>0247.3005.588</span>
                </div>
                <div class="footer-contact-item">
                    <span class="icon"><i class="fa-solid fa-envelope"></i></span>
                    <span>quaswp391@gmail.com</span>
                </div>
                <div class="footer-contact-item">
                    <span class="icon"><i class="fa-solid fa-clock"></i></span>
                    <span>Thứ 2 – Thứ 7: 7:30 – 20:00</span>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <span>© 2025 <span class="fpt-tag">FPT Library System</span> · SWP391</span>
            <span>Thiết kế bởi <span class="fpt-tag">Team SWP391</span></span>
        </div>
    </div>
</footer>

</body>
</html>
