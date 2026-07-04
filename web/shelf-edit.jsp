<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sửa vị trí bản sao</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .btn-primary {
            background-color: #f47920 !important;
            border-color: #f47920 !important;
        }
        .btn-primary:hover {
            background-color: #d4600a !important;
            border-color: #d4600a !important;
        }
    </style>
</head>
<body class="bg-light">
<div class="container py-4" style="max-width:560px">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="mb-0">Sửa vị trí bản sao</h5>
        <a href="shelf" class="btn btn-outline-secondary btn-sm">← Quay lại</a>
    </div>

    <c:choose>
        <c:when test="${editCopy == null}">
            <div class="alert alert-warning">Không tìm thấy bản sao.</div>
        </c:when>
        <c:otherwise>
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <p class="mb-1"><strong>Barcode:</strong> <code>${editCopy.barcode}</code></p>
                    <p class="mb-1"><strong>Sách:</strong> ${editCopy.book.title}</p>
                    <p class="mb-0"><strong>Trạng thái:</strong> ${editCopy.status}</p>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-header fw-semibold">Cập nhật vị trí</div>
                <div class="card-body">
                    <form method="post" action="shelf">
                        <input type="hidden" name="action" value="updateLocation">
                        <input type="hidden" name="copyId" value="${editCopy.id}">

                        <div class="mb-3">
                            <label class="form-label">Khu vực <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="area"
                                   value="${editCopy.area}" placeholder="VD: Tầng 1" required>
                            <div class="form-text">
                                Khu vực hiện có:
                                <c:forEach var="a" items="${areas}" varStatus="s">
                                    <strong>${a}</strong><c:if test="${!s.last}">, </c:if>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Kệ <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="shelf"
                                   value="${editCopy.shelf}" placeholder="VD: K01" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ngăn</label>
                            <input type="text" class="form-control" name="slot"
                                   value="${editCopy.slot}" placeholder="VD: N01">
                        </div>

                        <button type="submit" class="btn btn-primary w-100">Lưu vị trí</button>
                    </form>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
