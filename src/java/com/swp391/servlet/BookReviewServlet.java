package com.swp391.servlet;

import com.swp391.dao.BookReviewDAO;
import com.swp391.model.BookReview;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class BookReviewServlet extends HttpServlet {

    private final BookReviewDAO reviewDAO = new BookReviewDAO();

    // GET: hiển thị danh sách review của 1 đầu sách
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookIdParam = request.getParameter("bookId");
        if (bookIdParam == null || bookIdParam.isEmpty()) {
            response.sendRedirect("books");
            return;
        }

        try {
            int bookId = Integer.parseInt(bookIdParam);
            HttpSession session = request.getSession(false);
            User loggedInUser = (session != null) ? (User) session.getAttribute("user") : null;

            // Lấy danh sách review + rating trung bình
            List<BookReview> reviews = reviewDAO.getReviewsByBookId(bookId);
            double avgRating = reviewDAO.getAverageRating(bookId);

            // Nếu đã đăng nhập: kiểm tra user đã có review chưa và đã từng trả sách chưa
            BookReview myReview = null;
            boolean canReview = false;
            if (loggedInUser != null && "READER".equals(loggedInUser.getRole())) {
                myReview = reviewDAO.getReviewByBookAndUser(bookId, loggedInUser.getId());
                canReview = reviewDAO.hasReturnedBook(bookId, loggedInUser.getId());
            }

            request.setAttribute("bookId", bookId);
            request.setAttribute("reviews", reviews);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("myReview", myReview);
            request.setAttribute("canReview", canReview);
            request.setAttribute("loggedInUser", loggedInUser);

            request.getRequestDispatcher("/book-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID sách không hợp lệ");
        }
    }

    // POST: xử lý thêm / sửa / xóa review
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Kiểm tra user đã đăng nhập
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (loggedInUser == null) {
            response.sendRedirect("login");
            return;
        }

        // Không phải READER → không có quyền
        if (!"READER".equals(loggedInUser.getRole())) {
            request.setAttribute("error", "Bạn không có quyền thực hiện hành động này");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ độc giả mới được phép");
            return;
        }

        try {
            String bookIdParam = request.getParameter("bookId");
            if (bookIdParam == null || bookIdParam.isEmpty()) {
                request.setAttribute("error", "ID sách không hợp lệ");
                response.sendRedirect("book-list");
                return;
            }

            int bookId = Integer.parseInt(bookIdParam);
            int userId = loggedInUser.getId();
            String action = request.getParameter("action");

            if (action == null || action.isEmpty()) {
                request.setAttribute("error", "Hành động không hợp lệ");
                doGet(request, response);
                return;
            }

            switch (action) {
                case "add": {
                    handleAddReview(request, response, bookId, userId);
                    break;
                }
                case "update": {
                    handleUpdateReview(request, response, bookId, userId);
                    break;
                }
                case "delete": {
                    handleDeleteReview(request, response, bookId, userId);
                    break;
                }
                default: {
                    request.setAttribute("error", "Hành động không được hỗ trợ");
                    doGet(request, response);
                    return;
                }
            }

            response.sendRedirect("book-review?bookId=" + bookId);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
    }

    // Xử lý thêm review mới
    private void handleAddReview(HttpServletRequest request, HttpServletResponse response, 
                                  int bookId, int userId) throws ServletException, IOException {
        // Kiểm tra đã trả sách chưa
        if (!reviewDAO.hasReturnedBook(bookId, userId)) {
            request.setAttribute("error", "Bạn chỉ có thể đánh giá sách đã mượn và trả.");
            doGet(request, response);
            return;
        }

        // Kiểm tra đã review chưa
        if (reviewDAO.getReviewByBookAndUser(bookId, userId) != null) {
            request.setAttribute("error", "Bạn đã đánh giá cuốn sách này rồi.");
            doGet(request, response);
            return;
        }

        try {
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");

            // Validation rating
            if (ratingParam == null || ratingParam.isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn rating");
                doGet(request, response);
                return;
            }

            int rating = Integer.parseInt(ratingParam);

            // Validation comment
            if (comment != null) {
                comment = comment.trim();
                if (comment.length() > 1000) {
                    request.setAttribute("error", "Comment không được vượt quá 1000 ký tự");
                    doGet(request, response);
                    return;
                }
            }

            if (reviewDAO.addReview(bookId, userId, rating, comment)) {
                request.setAttribute("success", "Thêm đánh giá thành công!");
            } else {
                request.setAttribute("error", "Thêm đánh giá thất bại");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Rating phải là số nguyên");
            doGet(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }

    // Xử lý cập nhật review
    private void handleUpdateReview(HttpServletRequest request, HttpServletResponse response, 
                                    int bookId, int userId) throws ServletException, IOException {
        try {
            String reviewIdParam = request.getParameter("reviewId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");

            if (reviewIdParam == null || reviewIdParam.isEmpty()) {
                request.setAttribute("error", "ID review không hợp lệ");
                doGet(request, response);
                return;
            }

            int reviewId = Integer.parseInt(reviewIdParam);

            // Validation rating
            if (ratingParam == null || ratingParam.isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn rating");
                doGet(request, response);
                return;
            }

            int rating = Integer.parseInt(ratingParam);

            // Validation comment
            if (comment != null) {
                comment = comment.trim();
                if (comment.length() > 1000) {
                    request.setAttribute("error", "Comment không được vượt quá 1000 ký tự");
                    doGet(request, response);
                    return;
                }
            }

            if (reviewDAO.updateReview(reviewId, userId, rating, comment)) {
                request.setAttribute("success", "Cập nhật đánh giá thành công!");
            } else {
                request.setAttribute("error", "Cập nhật đánh giá thất bại");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: rating phải là số nguyên");
            doGet(request, response);
        } catch (SecurityException e) {
            request.setAttribute("error", e.getMessage());
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }

    // Xử lý xóa review
    private void handleDeleteReview(HttpServletRequest request, HttpServletResponse response, 
                                    int bookId, int userId) throws ServletException, IOException {
        try {
            String reviewIdParam = request.getParameter("reviewId");

            if (reviewIdParam == null || reviewIdParam.isEmpty()) {
                request.setAttribute("error", "ID review không hợp lệ");
                doGet(request, response);
                return;
            }

            int reviewId = Integer.parseInt(reviewIdParam);

            if (reviewDAO.deleteReview(reviewId, userId)) {
                request.setAttribute("success", "Xóa đánh giá thành công!");
            } else {
                request.setAttribute("error", "Xóa đánh giá thất bại");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID review không hợp lệ");
            doGet(request, response);
        } catch (SecurityException e) {
            request.setAttribute("error", e.getMessage());
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }
}
