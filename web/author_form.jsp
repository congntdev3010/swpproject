<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Author, java.util.List, java.time.format.DateTimeFormatter" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    String formMode = (String) request.getAttribute("formMode");
    Author author = (Author) request.getAttribute("author");
    List<String> errors = (List<String>) request.getAttribute("errors");
    String errorMsg = (String) request.getAttribute("errorMsg");

    boolean isEdit = "edit".equals(formMode);
    String title = isEdit ? "Chỉnh sửa tác giả" : "Thêm tác giả mới";
    String actionUrl = isEdit ? request.getContextPath() + "/author/edit" : request.getContextPath() + "/author/add";
    String actionName = isEdit ? "update" : "create";

    String nameVal = (author != null && author.getName() != null) ? author.getName() : "";
    String natVal = (author != null && author.getNationality() != null) ? author.getNationality() : "";
    String bioVal = (author != null && author.getBio() != null) ? author.getBio() : "";
    String avatarVal = (author != null && author.getAvatarUrl() != null) ? author.getAvatarUrl() : "";
    String birthVal = "";
    if (author != null && author.getBirthDate() != null) {
        birthVal = author.getBirthDate().toString(); // yyyy-MM-dd
    }
%>

<main class="page-wrapper">
    <div class="container" style="max-width: 800px; margin-top: 40px; margin-bottom: 60px;">
        <!-- ===== BREADCRUMB ===== -->
        <div style="margin-bottom: 20px;">
            <a href="<%= request.getContextPath() %>/authors" style="text-decoration: none; color: #3b82f6; font-weight: 500; font-size: 14px; display: inline-flex; align-items: center; gap: 6px;">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>

        <div class="admin-card" style="background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e5e7eb; overflow: hidden;">
            <!-- ===== HEADER ===== -->
            <div style="background: #1e3a8a; padding: 24px 32px; color: white;">
                <h1 style="font-size: 22px; font-weight: 600; margin: 0; font-family: 'Be Vietnam Pro', sans-serif;"><%= title %></h1>
                <p style="margin: 6px 0 0 0; font-size: 13.5px; opacity: 0.85;">Vui lòng điền đầy đủ các trường thông tin bên dưới.</p>
            </div>

            <!-- ===== BODY ===== -->
            <div style="padding: 32px;">
                
                <!-- ===== ERROR ALERTS ===== -->
                <% if (errorMsg != null) { %>
                    <div class="alert alert-danger" style="padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; font-size: 14px; background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b;">
                        <i class="fa-solid fa-circle-exclamation" style="font-size: 18px;"></i>
                        <span><%= errorMsg %></span>
                    </div>
                <% } %>

                <% if (errors != null && !errors.isEmpty()) { %>
                    <div class="alert alert-danger" style="padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; font-size: 14px; background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b;">
                        <div style="font-weight: 600; margin-bottom: 6px; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size: 18px;"></i>
                            <span>Vui lòng sửa các lỗi sau:</span>
                        </div>
                        <ul style="margin: 0; padding-left: 20px;">
                            <% for (String err : errors) { %>
                                <li style="margin-bottom: 2px;"><%= err %></li>
                            <% } %>
                        </ul>
                    </div>
                <% } %>

                <!-- ===== FORM ===== -->
                <form id="authorForm" method="POST" action="<%= actionUrl %>" onsubmit="return validateAuthorForm()" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="<%= actionName %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="id" value="<%= author.getId() %>">
                    <% } %>

                    <!-- Tên tác giả -->
                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="name" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                            Tên tác giả <span style="color: #ef4444;">*</span>
                        </label>
                        <input type="text" id="name" name="name" class="form-control" placeholder="Nhập tên đầy đủ của tác giả" value="<%= nameVal %>" required style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box;">
                        <div id="nameError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px;">
                        <!-- Quốc tịch -->
                        <div class="form-group">
                            <label for="nationality" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                                Quốc tịch
                            </label>
                            <input type="text" id="nationality" name="nationality" class="form-control" placeholder="Ví dụ: Việt Nam, Anh, Mỹ..." value="<%= natVal %>" style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box;">
                            <div id="natError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                        </div>

                        <!-- Ngày sinh -->
                        <div class="form-group">
                            <label for="birthDate" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                                Ngày sinh
                            </label>
                            <input type="date" id="birthDate" name="birthDate" class="form-control" value="<%= birthVal %>" style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box;">
                            <div id="birthError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                        </div>
                    </div>

                    <!-- Ảnh đại diện File -->
                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="avatarFile" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                            Ảnh đại diện
                        </label>
                        <input type="file" id="avatarFile" name="avatarFile" accept="image/*" onchange="previewImage(this, 'avatarPreview')" style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box;">
                        <input type="hidden" name="existingAvatarUrl" value="<%= avatarVal %>">
                        <div id="avatarError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                        <div style="margin-top: 10px;">
                            <img id="avatarPreview" src="<%= avatarVal != null && !avatarVal.isEmpty() ? com.swp391.util.UploadUtility.resolveUrl(avatarVal, request.getContextPath()) : "" %>" style="max-height: 150px; display: <%= avatarVal != null && !avatarVal.isEmpty() ? "block" : "none" %>; border-radius: 8px; border: 1px solid #e5e7eb;" alt="Xem trước ảnh đại diện">
                        </div>
                    </div>

                    <!-- Tiểu sử -->
                    <div class="form-group" style="margin-bottom: 32px;">
                        <label for="bio" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                            Tiểu sử tác giả
                        </label>
                        <textarea id="bio" name="bio" rows="6" class="form-control" placeholder="Tóm tắt về cuộc đời và sự nghiệp viết lách của tác giả..." style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box; resize: vertical; font-family: inherit;"><%= bioVal %></textarea>
                        <div id="bioError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                    </div>

                    <!-- ACTIONS -->
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e5e7eb; padding-top: 24px;">
                        <a href="<%= request.getContextPath() %>/authors" class="btn btn-outline" style="border: 1px solid #d1d5db; border-radius: 8px; padding: 12px 24px; text-decoration: none; color: #4b5563; font-weight: 500; font-size: 14px;">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="btn btn-primary" style="background: #3b82f6; border: none; border-radius: 8px; padding: 12px 30px; color: white; font-weight: 600; font-size: 14px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu lại
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<script>
function validateAuthorForm() {
    var name = document.getElementById('name').value.trim();
    var nationality = document.getElementById('nationality').value.trim();
    var birthDate = document.getElementById('birthDate').value;
    var avatarFile = document.getElementById('avatarFile');
    var bio = document.getElementById('bio').value;

    var isValid = true;

    // Clear previous errors
    document.getElementById('nameError').style.display = 'none';
    document.getElementById('natError').style.display = 'none';
    document.getElementById('birthError').style.display = 'none';
    document.getElementById('avatarError').style.display = 'none';
    document.getElementById('bioError').style.display = 'none';

    if (name === "") {
        showError('nameError', 'Tên tác giả không được để trống.');
        isValid = false;
    } else if (name.length > 150) {
        showError('nameError', 'Tên tác giả không được vượt quá 150 ký tự.');
        isValid = false;
    }

    if (nationality.length > 100) {
        showError('natError', 'Quốc tịch không được vượt quá 100 ký tự.');
        isValid = false;
    }

    if (birthDate !== "") {
        var selectedDate = new Date(birthDate);
        var today = new Date();
        // Remove time for comparison
        today.setHours(0,0,0,0);
        if (selectedDate > today) {
            showError('birthError', 'Ngày sinh không được lớn hơn ngày hiện tại.');
            isValid = false;
        }
    }

    if (avatarFile.files && avatarFile.files[0]) {
        var file = avatarFile.files[0];
        if (!file.type.startsWith('image/')) {
            showError('avatarError', 'Vui lòng chọn một tệp hình ảnh.');
            isValid = false;
        } else if (file.size > 5 * 1024 * 1024) {
            showError('avatarError', 'Kích thước ảnh đại diện không được vượt quá 5MB.');
            isValid = false;
        }
    }

    if (bio.length > 5000) {
        showError('bioError', 'Tiểu sử không được vượt quá 5000 ký tự.');
        isValid = false;
    }

    return isValid;
}

function showError(id, message) {
    var errorDiv = document.getElementById(id);
    errorDiv.innerText = message;
    errorDiv.style.display = 'block';
}

function previewImage(input, previewId) {
    var preview = document.getElementById(previewId);
    if (input.files && input.files[0]) {
        var file = input.files[0];
        if (!file.type.startsWith('image/')) {
            alert('Vui lòng chọn một tệp hình ảnh hợp lệ (JPG, PNG, GIF, WEBP, etc.)!');
            input.value = '';
            return;
        }
        if (file.size > 5 * 1024 * 1024) {
            alert('Kích thước ảnh không được vượt quá 5MB!');
            input.value = '';
            return;
        }
        var reader = new FileReader();
        reader.onload = function(e) {
            preview.src = e.target.result;
            preview.style.display = 'block';
        }
        reader.readAsDataURL(input.files[0]);
    }
}
</script>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
