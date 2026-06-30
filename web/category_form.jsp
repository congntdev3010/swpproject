<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Category, java.util.List" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    String formMode = (String) request.getAttribute("formMode");
    Category category = (Category) request.getAttribute("category");
    List<String> errors = (List<String>) request.getAttribute("errors");
    String errorMsg = (String) request.getAttribute("errorMsg");

    boolean isEdit = "edit".equals(formMode);
    String title = isEdit ? "Chỉnh sửa danh mục" : "Thêm danh mục mới";
    String actionUrl = isEdit ? request.getContextPath() + "/category/edit" : request.getContextPath() + "/category/add";
    String actionName = isEdit ? "update" : "create";

    String nameVal = (category != null && category.getName() != null) ? category.getName() : "";
    String descVal = (category != null && category.getDescription() != null) ? category.getDescription() : "";
%>

<main class="page-wrapper">
    <div class="container" style="max-width: 700px; margin-top: 40px; margin-bottom: 60px;">
        <!-- ===== BREADCRUMB ===== -->
        <div style="margin-bottom: 20px;">
            <a href="<%= request.getContextPath() %>/categories" style="text-decoration: none; color: #3b82f6; font-weight: 500; font-size: 14px; display: inline-flex; align-items: center; gap: 6px;">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>

        <div class="admin-card" style="background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e5e7eb; overflow: hidden;">
            <!-- ===== HEADER ===== -->
            <div style="background: #1e3a8a; padding: 24px 32px; color: white;">
                <h1 style="font-size: 22px; font-weight: 600; margin: 0; font-family: 'Be Vietnam Pro', sans-serif;"><%= title %></h1>
                <p style="margin: 6px 0 0 0; font-size: 13.5px; opacity: 0.85;">Vui lòng điền đầy đủ các thông tin của danh mục sách.</p>
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
                <form id="categoryForm" method="POST" action="<%= actionUrl %>" onsubmit="return validateCategoryForm()">
                    <input type="hidden" name="action" value="<%= actionName %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="id" value="<%= category.getId() %>">
                    <% } %>

                    <!-- Tên danh mục -->
                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="name" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                            Tên danh mục <span style="color: #ef4444;">*</span>
                        </label>
                        <input type="text" id="name" name="name" class="form-control" placeholder="Ví dụ: Công nghệ thông tin, Kinh tế, Ngoại ngữ..." value="<%= nameVal %>" required style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box;">
                        <div id="nameError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                    </div>

                    <!-- Mô tả -->
                    <div class="form-group" style="margin-bottom: 32px;">
                        <label for="description" style="display: block; font-weight: 500; font-size: 14px; color: #374151; margin-bottom: 8px;">
                            Mô tả danh mục
                        </label>
                        <textarea id="description" name="description" rows="5" class="form-control" placeholder="Mô tả ngắn gọn về phạm vi tài liệu thuộc danh mục này..." style="width: 100%; border: 1px solid #d1d5db; padding: 12px; border-radius: 8px; font-size: 14px; box-sizing: border-box; resize: vertical; font-family: inherit;"><%= descVal %></textarea>
                        <div id="descError" style="color: #ef4444; font-size: 12.5px; margin-top: 5px; display: none;"></div>
                    </div>

                    <!-- ACTIONS -->
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e5e7eb; padding-top: 24px;">
                        <a href="<%= request.getContextPath() %>/categories" class="btn btn-outline" style="border: 1px solid #d1d5db; border-radius: 8px; padding: 12px 24px; text-decoration: none; color: #4b5563; font-weight: 500; font-size: 14px;">
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
function validateCategoryForm() {
    var name = document.getElementById('name').value.trim();
    var description = document.getElementById('description').value;

    var isValid = true;

    // Clear previous errors
    document.getElementById('nameError').style.display = 'none';
    document.getElementById('descError').style.display = 'none';

    if (name === "") {
        showError('nameError', 'Tên danh mục không được để trống.');
        isValid = false;
    } else if (name.length > 100) {
        showError('nameError', 'Tên danh mục không được vượt quá 100 ký tự.');
        isValid = false;
    }

    if (description.length > 500) {
        showError('descError', 'Mô tả không được vượt quá 500 ký tự.');
        isValid = false;
    }

    return isValid;
}

function showError(id, message) {
    var errorDiv = document.getElementById(id);
    errorDiv.innerText = message;
    errorDiv.style.display = 'block';
}
</script>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
