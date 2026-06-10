<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sơ đồ kho thư viện</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .area-block   { border: 2px solid #0d6efd; border-radius:8px; margin-bottom:24px; }
        .area-header  { background:#0d6efd; color:#fff; padding:8px 16px; font-weight:600; border-radius:6px 6px 0 0; }
        .shelf-block  { border: 1px solid #dee2e6; border-radius:6px; margin:12px; }
        .shelf-header { background:#e9f0ff; padding:6px 12px; font-weight:500; border-radius:6px 6px 0 0; }
        .copy-row:hover { background:#f8f9fa; }
        .highlight { background:#fff3cd !important; }
        .badge-AVAILABLE   { background:#198754; color:#fff; }
        .badge-BORROWED    { background:#dc3545; color:#fff; }
        .badge-RESERVED    { background:#ffc107; color:#000; }
        .badge-MAINTENANCE { background:#6c757d; color:#fff; }
        .badge-LOST        { background:#343a40; color:#fff; }
    </style>
</head>
<body class="bg-light">
<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0">Sơ đồ kho thư viện</h4>
    </div>

    <c:if test="${successMsg == 'updated'}">
        <div class="alert alert-success">Cập nhật vị trí thành công.</div>
    </c:if>

    <%-- Tìm kiếm theo barcode --%>
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <form method="get" action="shelf" class="row g-2 align-items-end">
                <input type="hidden" name="action" value="search">
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Tìm vị trí theo barcode</label>
                    <input type="text" class="form-control" name="barcode"
                           value="${searchBarcode}" placeholder="Nhập barcode bản sao...">
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-primary">Tìm</button>
                    <a href="shelf" class="btn btn-outline-secondary ms-1">Xem tất cả</a>
                </div>
            </form>

            <c:if test="${searchBarcode != null}">
                <div class="mt-3">
                    <c:choose>
                        <c:when test="${foundCopy != null}">
                            <div class="alert alert-success mb-0">
                                Tìm thấy: <strong>${foundCopy.barcode}</strong> —
                                Sách: <strong>${foundCopy.book.title}</strong> —
                                Vị trí: <strong>${foundCopy.area} / ${foundCopy.shelf} / ${foundCopy.slot}</strong> —
                                Trạng thái: <strong>${foundCopy.status}</strong>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-warning mb-0">
                                Không tìm thấy barcode "<strong>${searchBarcode}</strong>".
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>

    <%-- Sơ đồ kho --%>
    <c:choose>
        <c:when test="${empty layout}">
            <div class="text-center text-muted py-5">Chưa có dữ liệu vị trí sách.</div>
        </c:when>
        <c:otherwise>
            <c:forEach var="areaEntry" items="${layout}">
                <div class="area-block shadow-sm">
                    <div class="area-header">Khu vực: ${areaEntry.key}</div>
                    <div class="p-2">
                        <c:forEach var="shelfEntry" items="${areaEntry.value}">
                            <div class="shelf-block mb-2">
                                <div class="shelf-header">
                                    Kệ: ${shelfEntry.key}
                                    <span class="text-muted small ms-2">(${shelfEntry.value.size()} bản sao)</span>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-sm mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Barcode</th>
                                                <th>Ngăn</th>
                                                <th>Tên sách</th>
                                                <th>Tình trạng</th>
                                                <th>Trạng thái</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="copy" items="${shelfEntry.value}">
                                                <tr class="copy-row ${not empty foundCopy and foundCopy.id == copy.id ? 'highlight' : ''}">
                                                    <td><code>${copy.barcode}</code></td>
                                                    <td>${copy.slot}</td>
                                                    <td>${copy.book.title}</td>
                                                    <td>${copy.bookCondition}</td>
                                                    <td>
                                                        <span class="badge badge-${copy.status} px-2 py-1">
                                                            ${copy.status}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                                            <a href="shelf?action=editForm&copyId=${copy.id}"
                                                               class="btn btn-outline-primary btn-sm">Sửa vị trí</a>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
