<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đánh giá sách</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .star-rating { color: #f5a623; font-size: 1.1rem; }
        .star-empty { color: #ccc; font-size: 1.1rem; }
        .review-card { border-left: 3px solid #f5a623; }
        .avg-rating { font-size: 2.5rem; font-weight: bold; color: #f5a623; }
    </style>
</head>
<body class="bg-light">
<div class="container py-4">
<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0">Đánh giá sách</h4>
    <a href="book-detail?id=${bookId}" class="btn btn-outline-secondary btn-sm">← Quay lại</a>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<%-- Rating trung bình --%>
<div class="card mb-4 shadow-sm">
    <div class="card-body text-center">
        <div class="avg-rating">
            <fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/> / 5
        </div>
        <div class="star-rating mb-1">
            <c:forEach begin="1" end="5" var="i">
                <c:choose>
                    <c:when test="${i <= avgRating}">★</c:when>
                    <c:otherwise><span class="star-empty">★</span></c:otherwise>
                </c:choose>
            </c:forEach>
        </div>
        <div class="text-muted">${reviews.size()} đánh giá</div>
    </div>
</div>

<%-- Form thêm / sửa review --%>
<c:if test="${canReview}">
    <div class="card mb-4 shadow-sm">
        <div class="card-header fw-semibold">
            <c:choose>
                <c:when test="${myReview != null}">Chỉnh sửa đánh giá của bạn</c:when>
                <c:otherwise>Viết đánh giá</c:otherwise>
            </c:choose>
        </div>
        <div class="card-body">
            <form method="post" action="book-review">
                <input type="hidden" name="bookId" value="${bookId}">
                <c:choose>
                    <c:when test="${myReview != null}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="reviewId" value="${myReview.id}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="add">
                    </c:otherwise>
                </c:choose>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Số sao <span class="text-danger">*</span></label>
                    <div class="d-flex gap-2 flex-wrap">
                        <c:forEach begin="1" end="5" var="star">
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="rating"
                                       id="star${star}" value="${star}"
                                       <c:if test="${myReview != null && myReview.rating == star}">checked</c:if>
                                       required>
                                <label class="form-check-label star-rating" for="star${star}">${star} ★</label>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Nhận xét</label>
                    <textarea class="form-control" name="comment" rows="3"
                              placeholder="Chia sẻ cảm nhận của bạn..."
                    ><c:out value="${myReview != null ? myReview.comment : ''}"/></textarea>
                </div>

                <button type="submit" class="btn btn-primary">
                    <c:choose>
                        <c:when test="${myReview != null}">Cập nhật</c:when>
                        <c:otherwise>Gửi đánh giá</c:otherwise>
                    </c:choose>
                </button>
            </form>

            <c:if test="${myReview != null}">
                <form method="post" action="book-review" class="d-inline mt-2"
                      onsubmit="return confirm('Bạn có chắc muốn xóa đánh giá này?')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="bookId" value="${bookId}">
                    <input type="hidden" name="reviewId" value="${myReview.id}">
                    <button type="submit" class="btn btn-outline-danger btn-sm">Xóa đánh giá</button>
                </form>
            </c:if>
        </div>
    </div>
</c:if>

<c:if test="${not empty sessionScope.user && sessionScope.user.role == 'READER' && !canReview && myReview == null}">
    <div class="alert alert-info mb-4">
        Bạn cần mượn và trả sách này trước khi có thể đánh giá.
    </div>
</c:if>

<%-- Danh sách review --%>
<h5 class="mb-3">Tất cả đánh giá</h5>
<c:choose>
    <c:when test="${empty reviews}">
        <div class="text-muted text-center py-4">Chưa có đánh giá nào.</div>
    </c:when>
    <c:otherwise>
        <c:forEach var="review" items="${reviews}">
            <div class="card mb-3 shadow-sm review-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="fw-semibold">${review.userFullName}</span>
                            <c:if test="${not empty review.userStudentId}">
                                <span class="text-muted ms-2 small">(${review.userStudentId})</span>
                            </c:if>
                        </div>
                        <span class="text-muted small">
                            <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    <div class="star-rating my-1">
                        <c:forEach begin="1" end="5" var="i">
                            <c:choose>
                                <c:when test="${i <= review.rating}">★</c:when>
                                <c:otherwise><span class="star-empty">★</span></c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <span class="ms-1 text-muted small">(${review.rating}/5)</span>
                    </div>
                    <c:if test="${not empty review.comment}">
                        <p class="mb-0 mt-1">${review.comment}</p>
                    </c:if>
                </div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>