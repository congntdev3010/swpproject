package controller;

import dao.BookReviewDAO;
import model.BookReview;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/book-review")
public class BookReviewServlet extends HttpServlet {

    private final BookReviewDAO reviewDAO = new BookReviewDAO();

    // GET: hiển thị danh sách review của 1 đầu sách
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookIdParam = request.getParameter("bookId");
        if (bookIdParam == null) {
            response.sendRedirect("book-list");
            return;
        }

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

        request.getRequestDispatcher("/view/book-review.jsp").forward(request, response);
    }

    // POST: xử lý thêm / sửa / xóa review
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("user") : null;

        // Chưa đăng nhập → redirect về login
        if (loggedInUser == null) {
            response.sendRedirect("login");
            return;
        }

        // Không phải READER → không có quyền
        if (!"READER".equals(loggedInUser.getRole())) {
            response.sendRedirect("book-list");
            return;
        }

        String action = request.getParameter("action");
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        int userId = loggedInUser.getId();

        switch (action) {
            case "add": {
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
                int rating = Integer.parseInt(request.getParameter("rating"));
                String comment = request.getParameter("comment");
                reviewDAO.addReview(bookId, userId, rating, comment);
                break;
            }
            case "update": {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                int rating = Integer.parseInt(request.getParameter("rating"));
                String comment = request.getParameter("comment");
                reviewDAO.updateReview(reviewId, userId, rating, comment);
                break;
            }
            case "delete": {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                reviewDAO.deleteReview(reviewId, userId);
                break;
            }
        }

        response.sendRedirect("book-review?bookId=" + bookId);
    }
}