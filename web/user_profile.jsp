<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User" %>
<%
    String contextPath = request.getContextPath();
    User profile = (User) request.getAttribute("profileUser");
    User logged = (User) session.getAttribute("loggedUser");
    boolean isAdminEditingOther = false;
    if (profile != null && logged != null) {
        isAdminEditingOther = logged.isAdmin() && (logged.getId() != profile.getId());
    }
%>
<jsp:include page="/WEB-INF/jsp/header.jsp" />

<main class="page-wrapper">
    <section class="profile-section">
        <div class="container">
            <div class="profile-header">
                <h1>Hồ sơ cá nhân</h1>
                <p>Quản lý thông tin tài khoản và bảo mật</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check"></i>
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>

            <% if (profile == null) { %>
                <div class="alert alert-warning">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    Không tìm thấy thông tin người dùng.
                </div>
            <% } else { %>
            <div class="profile-grid">
                <!-- LEFT CARD: User Info & Avatar -->
                <div class="profile-card info-card">
                    <form method="POST" action="<%= contextPath %>/user/profile" enctype="multipart/form-data" class="profile-form" onsubmit="return validateProfileForm()">
                        <input type="hidden" name="action" value="updateProfile" />
                        <input type="hidden" name="id" value="<%= profile.getId() %>" />
                        <input type="hidden" name="avatar" value="<%= profile.getAvatar() != null ? profile.getAvatar() : "" %>" />

                        <div class="avatar-upload-container">
                            <div class="avatar-frame">
                                <% if (profile.getAvatar() != null && !profile.getAvatar().trim().isEmpty()) { %>
                                    <img id="avatarPreview" src="<%= profile.getAvatar() %>" alt="Avatar" class="avatar-img" />
                                    <div id="avatarFallback" class="avatar-fallback" style="display: none;">
                                        <%= profile.getFullName() != null && !profile.getFullName().isEmpty() ? profile.getFullName().substring(0, 1).toUpperCase() : profile.getUsername().substring(0, 1).toUpperCase() %>
                                    </div>
                                <% } else { %>
                                    <img id="avatarPreview" src="" alt="Avatar" class="avatar-img" style="display: none;" />
                                    <div id="avatarFallback" class="avatar-fallback">
                                        <%= profile.getFullName() != null && !profile.getFullName().isEmpty() ? profile.getFullName().substring(0, 1).toUpperCase() : profile.getUsername().substring(0, 1).toUpperCase() %>
                                    </div>
                                <% } %>
                                <label for="avatarFile" class="avatar-upload-btn" title="Tải ảnh đại diện mới">
                                    <i class="fa-solid fa-camera"></i>
                                </label>
                            </div>
                            <input type="file" id="avatarFile" name="avatarFile" accept="image/*" style="display: none;" onchange="previewAvatar(event)">
                            <div class="avatar-info-text">
                                <h3><%= profile.getFullName() != null ? profile.getFullName() : profile.getUsername() %></h3>
                                <p class="user-role-text"><%= profile.getRole() %></p>
                            </div>
                        </div>

                        <hr class="divider" />

                        <div class="form-grid">
                            <div class="form-group">
                                <label>Tên đăng nhập</label>
                                <input type="text" class="form-control input-readonly" value="<%= profile.getUsername() %>" readonly disabled />
                            </div>

                            <div class="form-group">
                                <label for="fullName">Họ và tên <span class="required-star">*</span></label>
                                <input type="text" id="fullName" name="fullName" class="form-control"
                                       value="<%= profile.getFullName() != null ? profile.getFullName() : "" %>"
                                       required minlength="2" maxlength="100"
                                       placeholder="Nhập họ và tên..."
                                       oninput="validateFullName(this)" />
                                <div id="fullName-error" class="input-error-msg" style="display:none;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Họ tên phải có ít nhất 2 ký tự và không chứa số.
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="email">Địa chỉ Email <span class="required-star">*</span></label>
                                <input type="email" id="email" name="email" class="form-control"
                                       value="<%= profile.getEmail() != null ? profile.getEmail() : "" %>"
                                       required maxlength="150"
                                       placeholder="example@email.com"
                                       oninput="validateEmail(this)" />
                                <div id="email-error" class="input-error-msg" style="display:none;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Email không đúng định dạng.
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="text" id="phone" name="phone" class="form-control"
                                       value="<%= profile.getPhone() != null ? profile.getPhone() : "" %>"
                                       maxlength="15" placeholder="0xxxxxxxxx"
                                       oninput="validatePhone(this)" />
                                <div id="phone-error" class="input-error-msg" style="display:none;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Số điện thoại phải có 10-11 chữ số và bắt đầu bằng 0.
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="studentId">Mã số sinh viên (MSSV)</label>
                                <input type="text" id="studentId" name="studentId" class="form-control"
                                       value="<%= profile.getStudentId() != null ? profile.getStudentId() : "" %>"
                                       maxlength="20" placeholder="Ví dụ: SS170001"
                                       oninput="validateStudentId(this)" />
                                <div id="studentId-error" class="input-error-msg" style="display:none;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> MSSV chỉ được chứa chữ cái và chữ số.
                                </div>
                            </div>
                        </div>

                        <% if (logged != null && logged.isAdmin()) { %>
                            <div class="admin-controls-section">
                                <h4 class="section-subtitle"><i class="fa-solid fa-shield-halved"></i> Quản trị viên điều khiển</h4>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label for="role">Vai trò</label>
                                        <select id="role" name="role" class="form-select">
                                            <option value="ADMIN" <%= "ADMIN".equals(profile.getRole()) ? "selected" : "" %>>ADMIN</option>
                                            <option value="LIBRARIAN" <%= "LIBRARIAN".equals(profile.getRole()) ? "selected" : "" %>>LIBRARIAN</option>
                                            <option value="READER" <%= "READER".equals(profile.getRole()) ? "selected" : "" %>>READER</option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label for="active">Trạng thái tài khoản</label>
                                        <select id="active" name="active" class="form-select">
                                            <option value="1" <%= profile.getActive() == 1 ? "selected" : "" %>>Hoạt động (Active)</option>
                                            <option value="0" <%= profile.getActive() == 0 ? "selected" : "" %>>Khóa (Locked)</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <div class="form-footer">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu thông tin
                            </button>
                        </div>
                    </form>
                </div>

                <!-- RIGHT CARD: Password Reset -->
                <div class="profile-card password-card">
                    <div class="card-header-with-icon">
                        <div class="header-icon"><i class="fa-solid fa-key"></i></div>
                        <div>
                            <h2>Đổi mật khẩu</h2>
                            <p>Cập nhật mật khẩu để bảo vệ tài khoản</p>
                        </div>
                    </div>

                    <form method="POST" action="<%= contextPath %>/user/profile" class="profile-form" onsubmit="return validatePasswordForm()">
                        <input type="hidden" name="action" value="changePassword" />
                        <input type="hidden" name="id" value="<%= profile.getId() %>" />

                        <% if (!isAdminEditingOther) { %>
                            <div class="form-group">
                                <label for="oldPassword">Mật khẩu hiện tại <span class="required-star">*</span></label>
                                <input type="password" id="oldPassword" name="oldPassword" class="form-control" placeholder="Nhập mật khẩu hiện tại" required />
                            </div>
                        <% } else { %>
                            <div class="info-bubble">
                                <i class="fa-solid fa-circle-info"></i>
                                Bạn đang đổi mật khẩu với tư cách Quản trị viên. Không cần nhập mật khẩu cũ.
                            </div>
                        <% } %>

                        <div class="form-group">
                            <label for="newPassword">Mật khẩu mới <span class="required-star">*</span></label>
                            <input type="password" id="newPassword" name="newPassword" class="form-control"
                                   placeholder="Tối thiểu 6 ký tự" required minlength="6"
                                   oninput="checkPasswordStrength(this.value)" />
                            <div id="password-strength-bar" style="height:4px; border-radius:2px; margin-top:6px; transition:all 0.3s;"></div>
                            <div id="password-strength-text" style="font-size:11px; margin-top:3px; font-weight:600;"></div>
                            <div id="newPassword-error" class="input-error-msg" style="display:none;">
                                <i class="fa-solid fa-triangle-exclamation"></i> Mật khẩu phải có ít nhất 6 ký tự.
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword">Xác nhận mật khẩu mới <span class="required-star">*</span></label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                                   placeholder="Nhập lại mật khẩu mới" required
                                   oninput="checkConfirmPassword(this)" />
                            <div id="password-match-error" class="input-error-msg" style="display: none;">
                                <i class="fa-solid fa-triangle-exclamation"></i> Mật khẩu xác nhận không khớp.
                            </div>
                        </div>

                        <div class="form-footer">
                            <button type="submit" class="btn btn-outline btn-block">
                                <i class="fa-solid fa-shield-check"></i> Cập nhật mật khẩu
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/jsp/footer.jsp" />

<style>
.profile-section {
    padding: 60px 0;
    background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f5 100%);
    min-height: calc(100vh - 200px);
}

.profile-header {
    margin-bottom: 40px;
    text-align: left;
}

.profile-header h1 {
    font-size: 32px;
    font-weight: 800;
    color: var(--text-primary);
    margin-bottom: 8px;
    font-family: 'Be Vietnam Pro', sans-serif;
    letter-spacing: -0.5px;
}

.profile-header p {
    font-size: 15px;
    color: var(--text-muted);
}

.profile-grid {
    display: grid;
    grid-template-columns: 7fr 5fr;
    gap: 32px;
    align-items: start;
}

.profile-card {
    background: var(--bg-card);
    border-radius: var(--radius-md);
    padding: 36px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
    border: 1px solid var(--border);
    transition: transform var(--transition-slow), box-shadow var(--transition-slow);
}

.profile-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.avatar-upload-container {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 30px;
}

.avatar-frame {
    position: relative;
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-light), var(--primary));
    padding: 3px;
    box-shadow: 0 4px 15px rgba(244, 121, 32, 0.25);
}

.avatar-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
    background: white;
}

.avatar-fallback {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background: var(--bg-surface);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    font-weight: 800;
    font-family: 'Be Vietnam Pro', sans-serif;
    border: 2px solid white;
}

.avatar-upload-btn {
    position: absolute;
    bottom: 0;
    right: 0;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--text-primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.25);
    transition: background var(--transition), transform var(--transition);
}

.avatar-upload-btn:hover {
    background: var(--primary);
    transform: scale(1.1);
}

.avatar-info-text h3 {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 4px;
}

.avatar-info-text .user-role-text {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
}

.divider {
    border: 0;
    height: 1px;
    background: var(--border);
    margin: 24px 0;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.form-grid .form-group:first-child {
    grid-column: span 2;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: var(--text-secondary);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.form-control {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    font-size: 14px;
    background: var(--bg-input);
    color: var(--text-primary);
    transition: border-color var(--transition), box-shadow var(--transition);
}

.form-control:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(244, 121, 32, 0.15);
}

.input-readonly {
    background: #f1f3f5;
    color: var(--text-muted);
    cursor: not-allowed;
}

.form-select {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    font-size: 14px;
    background: var(--bg-input);
    color: var(--text-primary);
    transition: border-color var(--transition), box-shadow var(--transition);
}

.form-select:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(244, 121, 32, 0.15);
}

.admin-controls-section {
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px dashed var(--border);
}

.section-subtitle {
    font-size: 14px;
    font-weight: 700;
    color: var(--danger);
    margin-bottom: 16px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.form-footer {
    margin-top: 30px;
    display: flex;
    justify-content: flex-end;
}

.card-header-with-icon {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 30px;
}

.header-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-sm);
    background: rgba(244, 121, 32, 0.1);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}

.card-header-with-icon h2 {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0;
}

.card-header-with-icon p {
    font-size: 13px;
    color: var(--text-muted);
    margin: 0;
}

.info-bubble {
    background: rgba(30, 144, 255, 0.08);
    border: 1px solid rgba(30, 144, 255, 0.2);
    border-radius: var(--radius-sm);
    padding: 12px 16px;
    color: #0b69c5;
    font-size: 13px;
    line-height: 1.5;
    margin-bottom: 20px;
    display: flex;
    align-items: flex-start;
    gap: 10px;
}

.info-bubble i {
    margin-top: 2px;
}

.required-star {
    color: var(--danger);
}

.input-error-msg {
    color: var(--danger);
    font-size: 12px;
    font-weight: 600;
    margin-top: 6px;
    display: flex;
    align-items: center;
    gap: 6px;
}

.alert {
    padding: 16px;
    border-radius: var(--radius-sm);
    margin-bottom: 24px;
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 14px;
    font-weight: 500;
}

.alert-danger {
    background: rgba(255, 71, 87, 0.1);
    border-left: 4px solid var(--danger);
    color: var(--danger);
}

.alert-success {
    background: rgba(46, 213, 115, 0.1);
    border-left: 4px solid var(--success);
    color: var(--success);
}

.alert-warning {
    background: rgba(255, 165, 2, 0.1);
    border-left: 4px solid var(--warning);
    color: var(--warning);
}

.btn-block {
    width: 100%;
    justify-content: center;
}

@media (max-width: 992px) {
    .profile-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 576px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
    .form-grid .form-group:first-child {
        grid-column: span 1;
    }
}
</style>

<script>
function previewAvatar(event) {
    const input = event.target;
    if (input.files && input.files[0]) {
        const file = input.files[0];
        // Validate file type
        const allowedTypes = ['image/jpeg','image/png','image/gif','image/webp'];
        if (!allowedTypes.includes(file.type)) {
            alert('Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WEBP)!');
            input.value = '';
            return;
        }
        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert('Kích thước ảnh không được vượt quá 5MB!');
            input.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = function(e) {
            const preview = document.getElementById('avatarPreview');
            const fallback = document.getElementById('avatarFallback');
            if (preview) {
                preview.src = e.target.result;
                preview.style.display = 'block';
            }
            if (fallback) {
                fallback.style.display = 'none';
            }
        };
        reader.readAsDataURL(file);
    }
}

function validateFullName(input) {
    const val = input.value.trim();
    const err = document.getElementById('fullName-error');
    if (val.length < 2 || /\d/.test(val)) {
        err.style.display = 'flex';
        input.style.borderColor = 'var(--danger)';
        return false;
    }
    err.style.display = 'none';
    input.style.borderColor = 'var(--success)';
    return true;
}

function validateEmail(input) {
    const val = input.value.trim();
    const err = document.getElementById('email-error');
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(val)) {
        err.style.display = 'flex';
        input.style.borderColor = 'var(--danger)';
        return false;
    }
    err.style.display = 'none';
    input.style.borderColor = 'var(--success)';
    return true;
}

function validatePhone(input) {
    const val = input.value.trim();
    const err = document.getElementById('phone-error');
    if (val === '') { err.style.display = 'none'; input.style.borderColor = ''; return true; }
    const phoneRegex = /^0[0-9]{9,10}$/;
    if (!phoneRegex.test(val)) {
        err.style.display = 'flex';
        input.style.borderColor = 'var(--danger)';
        return false;
    }
    err.style.display = 'none';
    input.style.borderColor = 'var(--success)';
    return true;
}

function validateStudentId(input) {
    const val = input.value.trim();
    const err = document.getElementById('studentId-error');
    if (val === '') { err.style.display = 'none'; input.style.borderColor = ''; return true; }
    const sidRegex = /^[a-zA-Z0-9]+$/;
    if (!sidRegex.test(val)) {
        err.style.display = 'flex';
        input.style.borderColor = 'var(--danger)';
        return false;
    }
    err.style.display = 'none';
    input.style.borderColor = 'var(--success)';
    return true;
}

function validateProfileForm() {
    let valid = true;
    const fullNameEl = document.getElementById('fullName');
    const emailEl = document.getElementById('email');
    const phoneEl = document.getElementById('phone');
    const studentIdEl = document.getElementById('studentId');
    if (fullNameEl && !validateFullName(fullNameEl)) valid = false;
    if (emailEl && !validateEmail(emailEl)) valid = false;
    if (phoneEl && !validatePhone(phoneEl)) valid = false;
    if (studentIdEl && !validateStudentId(studentIdEl)) valid = false;
    if (!valid) {
        const firstErr = document.querySelector('.input-error-msg[style*="flex"]');
        if (firstErr) firstErr.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    return valid;
}

function checkPasswordStrength(password) {
    const bar = document.getElementById('password-strength-bar');
    const text = document.getElementById('password-strength-text');
    const errDiv = document.getElementById('newPassword-error');
    if (!bar || !text) return;
    if (password.length === 0) { bar.style.background=''; bar.style.width='0'; text.textContent=''; return; }
    if (password.length < 6) {
        bar.style.background='#ff4757'; bar.style.width='33%';
        text.style.color='#ff4757'; text.textContent='Yếu';
        if (errDiv) errDiv.style.display = 'flex';
        return;
    }
    if (errDiv) errDiv.style.display = 'none';
    let score = 0;
    if (password.length >= 8) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[^a-zA-Z0-9]/.test(password)) score++;
    if (score <= 1) { bar.style.background='#ffa502'; bar.style.width='50%'; text.style.color='#ffa502'; text.textContent='Trung bình'; }
    else if (score <= 2) { bar.style.background='#2ed573'; bar.style.width='75%'; text.style.color='#2ed573'; text.textContent='Tốt'; }
    else { bar.style.background='#1e90ff'; bar.style.width='100%'; text.style.color='#1e90ff'; text.textContent='Rất mạnh 💪'; }
}

function checkConfirmPassword(input) {
    const newPwd = document.getElementById('newPassword').value;
    const errorDiv = document.getElementById('password-match-error');
    if (input.value && newPwd !== input.value) {
        if (errorDiv) errorDiv.style.display = 'flex';
        input.style.borderColor = 'var(--danger)';
    } else {
        if (errorDiv) errorDiv.style.display = 'none';
        input.style.borderColor = input.value ? 'var(--success)' : '';
    }
}

function validatePasswordForm() {
    const newPwd = document.getElementById('newPassword');
    const confPwd = document.getElementById('confirmPassword');
    const errorDiv = document.getElementById('password-match-error');
    const newPwdErr = document.getElementById('newPassword-error');

    let valid = true;
    if (newPwd.value.length < 6) {
        if (newPwdErr) newPwdErr.style.display = 'flex';
        newPwd.style.borderColor = 'var(--danger)';
        valid = false;
    }
    if (newPwd.value !== confPwd.value) {
        if (errorDiv) errorDiv.style.display = 'flex';
        confPwd.style.borderColor = 'var(--danger)';
        valid = false;
    } else {
        if (errorDiv) errorDiv.style.display = 'none';
    }
    return valid;
}
</script>
