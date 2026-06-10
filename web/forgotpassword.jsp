<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<main class="page-wrapper">
    <section class="forgot-section">
        <div class="container">
            <div class="forgot-container">
                <!-- Forgot Password Card -->
                <div class="forgot-card">
                    <div class="forgot-header">
                        <h1>Quên mật khẩu?</h1>
                        <p>Nhập thông tin tài khoản của bạn để đặt lại mật khẩu</p>
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } %>

                    <form method="POST" action="<%= contextPath %>/forgot-password" class="forgot-form" onsubmit="return validateForm()">
                        <div class="form-group">
                            <label for="username">Tên đăng nhập</label>
                            <input type="text" id="username" name="username"
                                   required placeholder="Nhập tên đăng nhập của bạn"
                                   value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="email">Email đã đăng ký</label>
                            <input type="email" id="email" name="email"
                                   required placeholder="Nhập email của bạn"
                                   value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="newPassword">Mật khẩu mới</label>
                            <input type="password" id="newPassword" name="newPassword"
                                   required placeholder="Nhập mật khẩu mới"
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   required placeholder="Nhập lại mật khẩu mới"
                                   class="form-control">
                            <div id="passwordError" class="validation-error" style="display:none; color:var(--danger, #ef4444); font-size:13px; margin-top:6px;"></div>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">
                            <i class="fa-solid fa-rotate"></i> Đặt lại mật khẩu
                        </button>
                    </form>

                    <div class="form-actions-sub">
                        <a href="<%= contextPath %>/login" class="btn-back-login">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại Đăng nhập
                        </a>
                    </div>
                </div>

                <!-- Info Section (Identical to login for brand consistency) -->
                <div class="forgot-info">
                    <div class="info-box">
                        <div class="info-icon">🔐</div>
                        <h3>Bảo mật tài khoản</h3>
                        <p>Để bảo vệ tài khoản của bạn, hệ thống yêu cầu:</p>
                        <ul>
                            <li><i class="fa-solid fa-check"></i> Xác minh đúng tên đăng nhập</li>
                            <li><i class="fa-solid fa-check"></i> Khớp chính xác email đã đăng ký</li>
                            <li><i class="fa-solid fa-check"></i> Mật khẩu mới an toàn và dễ nhớ</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<style>
.forgot-section {
    padding: 60px 0;
    background: linear-gradient(135deg, #f5f7fa 0%, #f0f4f8 100%);
    min-height: calc(100vh - 200px);
}

.forgot-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 48px;
    align-items: center;
}

.forgot-card {
    background: white;
    border-radius: 12px;
    padding: 48px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
    border: 1px solid #e5e7eb;
}

.forgot-header {
    margin-bottom: 32px;
    text-align: center;
}

.forgot-header h1 {
    font-size: 28px;
    font-weight: 700;
    color: var(--text-primary, #1f2937);
    margin-bottom: 8px;
}

.forgot-header p {
    font-size: 14px;
    color: var(--text-muted, #6b7280);
}

.forgot-form {
    margin-bottom: 24px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: var(--text-primary, #1f2937);
    font-size: 14px;
}

.form-control {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
    transition: all 0.2s;
    box-sizing: border-box;
}

.form-control:focus {
    outline: none;
    border-color: var(--primary, #3b82f6);
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.btn-block {
    width: 100%;
    padding: 12px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    background: var(--primary, #3b82f6);
    color: white;
}

.btn-block:hover {
    background: var(--primary-dark, #2563eb);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.form-actions-sub {
    text-align: center;
    margin-top: 20px;
    margin-bottom: -10px;
}

.btn-back-login {
    font-size: 14px;
    color: var(--text-secondary, #4b5563);
    text-decoration: none;
    transition: all 0.2s;
    font-weight: 500;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.btn-back-login:hover {
    color: var(--primary, #3b82f6);
    transform: translateX(-2px);
}

.forgot-info {
    display: flex;
    align-items: center;
}

.info-box {
    text-align: center;
    width: 100%;
}

.info-icon {
    font-size: 64px;
    margin-bottom: 24px;
}

.info-box h3 {
    font-size: 24px;
    font-weight: 700;
    color: var(--text-primary, #1f2937);
    margin-bottom: 16px;
}

.info-box p {
    font-size: 14px;
    color: var(--text-muted, #6b7280);
    margin-bottom: 16px;
}

.info-box ul {
    list-style: none;
    padding: 0;
    text-align: left;
    display: inline-block;
}

.info-box li {
    font-size: 14px;
    color: var(--text-secondary, #374151);
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.info-box i {
    color: var(--primary, #3b82f6);
    font-weight: bold;
}

.alert {
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 24px;
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 14px;
}

.alert-danger {
    background: #fee2e2;
    border: 1px solid #fecaca;
    color: #991b1b;
}

.alert i {
    font-size: 16px;
}

@media (max-width: 768px) {
    .forgot-container {
        grid-template-columns: 1fr;
        gap: 32px;
    }

    .forgot-card {
        padding: 32px;
    }

    .forgot-header h1 {
        font-size: 24px;
    }

    .forgot-info {
        display: none;
    }
}
</style>

<script>
function validateForm() {
    var password = document.getElementById("newPassword").value;
    var confirmPassword = document.getElementById("confirmPassword").value;
    var errorDiv = document.getElementById("passwordError");
    
    if (password !== confirmPassword) {
        errorDiv.textContent = "Mật khẩu xác nhận không khớp.";
        errorDiv.style.display = "block";
        return false;
    }
    
    errorDiv.style.display = "none";
    return true;
}
</script>
