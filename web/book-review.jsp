<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<style>
    .star-rating { color: #f5a623; font-size: 1.1rem; }
    .star-empty { color: #ccc; font-size: 1.1rem; }
    .review-card { border-left: 3px solid #f5a623; background: var(--bg-card); padding: 16px; border-radius: var(--radius-md); box-shadow: var(--shadow-sm); margin-bottom: 16px; }
    .avg-rating { font-size: 2.5rem; font-weight: bold; color: #f5a623; }
    .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .review-section { margin-bottom: 32px; background: var(--bg-card); padding: 24px; border-radius: var(--radius-md); box-shadow: var(--shadow-sm); border: 1px solid var(--border); }
    .form-group { margin-bottom: 16px; }
    .form-label { display: block; margin-bottom: 8px; font-weight: 600; }
    .form-control { width: 100%; padding: 10px; border: 1px solid var(--border); border-radius: var(--radius-sm); background: var(--bg-surface); color: var(--text-primary); }
</style>
<main class="page-wrapper">
    <div class="container" style="padding-top:28px;">
        <div class="review-header">
            <h1 class="section-title mb-0">Đánh giá sách</h1>
            <a href="${pageContext.request.contextPath}/book-detail?id=${bookId}" class="btn btn-outline">
                <i class="fa-solid fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="fa-solid fa-triangle-exclamation"></i> ${error}
            </div>
        </c:if>

        <%-- Rating trung bình --%>
        <div class="review-section" style="text-align: center;">
            <div class="avg-rating">
                <fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/> / 5
            </div>
            <div class="star-rating mb-1" style="font-size: 1.5rem;">
                <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                        <c:when test="${i <= avgRating}">★</c:when>
                        <c:otherwise><span class="star-empty">★</span></c:otherwise>
                    </c:choose>
                </c:forEach>
            </div>
            <div style="color: var(--text-muted);">${reviews.size()} đánh giá</div>
        </div>

        <%-- Form thêm / sửa review --%>
        <c:if test="${canReview}">
            <div class="review-section">
                <h3 style="margin-bottom: 16px; font-size: 1.1rem; color: var(--text-primary);">
                    <c:choose>
                        <c:when test="${myReview != null}">Chỉnh sửa đánh giá của bạn</c:when>
                        <c:otherwise>Viết đánh giá</c:otherwise>
                    </c:choose>
                </h3>
                <form method="post" action="${pageContext.request.contextPath}/book-review">
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

                    <div class="form-group">
                        <label class="form-label">Số sao <span style="color: var(--danger);">*</span></label>
                        <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                            <c:forEach begin="1" end="5" var="star">
                                <label style="cursor: pointer; display: flex; align-items: center; gap: 4px;">
                                    <input type="radio" name="rating" value="${star}"
                                           <c:if test="${myReview != null && myReview.rating == star}">checked</c:if>
                                           required>
                                    <span class="star-rating">${star} ★</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Nhận xét</label>
                        <textarea class="form-control" name="comment" rows="4"
                                  placeholder="Chia sẻ cảm nhận của bạn..."><c:out value="${myReview != null ? myReview.comment : ''}"/></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <c:choose>
                            <c:when test="${myReview != null}">Cập nhật</c:when>
                            <c:otherwise>Gửi đánh giá</c:otherwise>
                        </c:choose>
                    </button>
                </form>

                <c:if test="${myReview != null}">
                    <form method="post" action="${pageContext.request.contextPath}/book-review" style="display: inline-block; margin-top: 12px;"
                          onsubmit="return confirm('Bạn có chắc muốn xóa đánh giá này?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="bookId" value="${bookId}">
                        <input type="hidden" name="reviewId" value="${myReview.id}">
                        <button type="submit" class="btn btn-danger btn-sm" style="background: transparent; border-color: var(--danger); color: var(--danger);">
                            <i class="fa-solid fa-trash"></i> Xóa đánh giá
                        </button>
                    </form>
                </c:if>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.loggedUser && sessionScope.loggedUser.role == 'READER' && !canReview && myReview == null}">
            <div class="alert alert-info" style="margin-bottom: 24px;">
                <i class="fa-solid fa-circle-info"></i> Bạn cần mượn và trả sách này trước khi có thể đánh giá.
            </div>
        </c:if>

        <%-- Danh sách review --%>
        <h2 class="section-title" style="margin-bottom: 20px;">Tất cả đánh giá</h2>
        <c:choose>
            <c:when test="${empty reviews}">
                <div style="text-align: center; padding: 40px; color: var(--text-muted); background: var(--bg-card); border-radius: var(--radius-md); border: 1px dashed var(--border);">
                    <i class="fa-regular fa-comment-dots" style="font-size: 2rem; margin-bottom: 12px; display: block;"></i>
                    Chưa có đánh giá nào.
                </div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 16px;">
                    <c:forEach var="review" items="${reviews}">
                        <div class="review-card">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                                <div>
                                    <strong style="color: var(--text-primary);">${review.userFullName}</strong>
                                    <c:if test="${not empty review.userStudentId}">
                                        <span style="color: var(--text-muted); font-size: 0.85rem; margin-left: 8px;">(${review.userStudentId})</span>
                                    </c:if>
                                </div>
                                <span style="color: var(--text-muted); font-size: 0.85rem;">
                                    <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </span>
                            </div>
                            <div class="star-rating" style="margin-bottom: 8px;">
                                <c:forEach begin="1" end="5" var="i">
                                    <c:choose>
                                        <c:when test="${i <= review.rating}">★</c:when>
                                        <c:otherwise><span class="star-empty">★</span></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                                <span style="color: var(--text-muted); font-size: 0.85rem; margin-left: 4px;">(${review.rating}/5)</span>
                            </div>
                            <c:if test="${not empty review.comment}">
                                <p style="margin: 0; color: var(--text-secondary); line-height: 1.6;">${review.comment}</p>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
<%@ include file="/WEB-INF/jsp/footer.jsp" %>
