package com.swp391.servlet;

import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.BookDAO;
import com.swp391.dao.BookDAOImpl;
import com.swp391.dao.BorrowDAO;
import com.swp391.dao.BorrowDAOImpl;
import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet xử lý nghiệp vụ mượn sách.
 * Spec: library-rules-spec-v2.md §1, §4.2
 *
 * URL patterns:
 *   GET  /borrow/list  — Librarian/Admin: danh sách toàn bộ
 *   GET  /borrow/my    — User: lịch sử mượn của mình
 *   POST /borrow/checkout — Librarian/Admin: checkout (tạo phiếu mượn)
 *   POST /borrow/return   — Librarian/Admin: trả sách
 *   POST /borrow/renew    — User/Librarian: yêu cầu gia hạn
 */
@WebServlet(name = "BorrowServlet", urlPatterns = {
    "/borrow/list", "/borrow/my", "/borrow/checkout", "/borrow/return", "/borrow/renew"
})
public class BorrowServlet extends HttpServlet {

    private static final int PAGE_SIZE = 15;
    private final BorrowDAO borrowDAO = new BorrowDAOImpl();

    // -------------------------------------------------------------------------
    // GET
    // -------------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        try {
            switch (path) {
                case "/borrow/list":
                    if (!loggedUser.isAdminOrLibrarian()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                        return;
                    }
                    showList(request, response, loggedUser);
                    break;
                case "/borrow/my":
                    showMyBorrows(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/borrow/my");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // -------------------------------------------------------------------------
    // POST
    // -------------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        try {
            switch (path) {
                case "/borrow/checkout":
                    if (!loggedUser.isAdminOrLibrarian()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    processCheckout(request, response, loggedUser);
                    break;
                case "/borrow/return":
                    if (!loggedUser.isAdminOrLibrarian()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    processReturn(request, response, loggedUser);
                    break;
                case "/borrow/renew":
                    processRenew(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/borrow/my");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // -------------------------------------------------------------------------
    // Handlers
    // -------------------------------------------------------------------------

    /** Librarian/Admin: xem danh sách tất cả phiếu mượn */
    private void showList(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        String status = req.getParameter("status");
        String keyword = req.getParameter("keyword");
        int page = parseIntOrDefault(req.getParameter("page"), 1);

        List<BorrowRecord> borrows = borrowDAO.getAllBorrows(status, keyword, page, PAGE_SIZE);
        int total = borrowDAO.countAllBorrows(status, keyword);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("borrows", borrows);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("status", status);
        req.setAttribute("keyword", keyword);
        req.setAttribute("pageTitle", "Quản lý mượn sách");
        req.setAttribute("activePage", "borrows");
        
        // Fetch data for checkout datalists
        try {
            com.swp391.dao.BookDAO bookDAO = new com.swp391.dao.BookDAOImpl();
            com.swp391.dao.UserDAO userDAO = new com.swp391.dao.UserDAOImpl();
            com.swp391.dao.BookCopyDAO copyDAO = new com.swp391.dao.BookCopyDAO();
            req.setAttribute("allBooks", bookDAO.searchBooks(null, null, "title", "ASC", 1, 1000));
            req.setAttribute("allUsers", userDAO.searchUsers(null, null, 1));
            req.setAttribute("allCopies", copyDAO.getAllCopies());
        } catch (Exception e) {}
        
        req.getRequestDispatcher("/borrow_list.jsp").forward(req, resp);
    }

    /** User: xem lịch sử mượn của mình */
    private void showMyBorrows(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        List<BorrowRecord> active = borrowDAO.getActiveBorrowsByUser(loggedUser.getId());
        List<BorrowRecord> history = borrowDAO.getAllBorrowsByUser(loggedUser.getId());
        int activeCount = borrowDAO.countActiveBorrowsAndReservations(loggedUser.getId());
        int maxLimit = borrowDAO.getMaxBorrowLimit(loggedUser.getId());

        req.setAttribute("activeBorrows", active);
        req.setAttribute("borrowHistory", history);
        req.setAttribute("activeCount", activeCount);
        req.setAttribute("maxLimit", maxLimit);
        req.setAttribute("pageTitle", "Sách đang mượn");
        req.setAttribute("activePage", "borrows");
        req.getRequestDispatcher("/borrow_my.jsp").forward(req, resp);
    }

    /**
     * §1.1, §1.2 Librarian/Admin: checkout tạo phiếu mượn mới.
     * Hiển thị cảnh báo nếu user vượt ngưỡng; Librarian/Admin có thể override.
     */
    private void processCheckout(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        BookDAO bookDAO = new BookDAOImpl();
        BookCopyDAO bookCopyDAO = new BookCopyDAO();
        int userId = parseIntOrDefault(req.getParameter("userId"), 0);
        int bookId = parseIntOrDefault(req.getParameter("bookId"), 0);
        String copyIdStr = req.getParameter("copyId");
        Integer copyId = null;

        try {
            if (copyIdStr != null && !copyIdStr.trim().isEmpty()) {
                copyId = Integer.parseInt(copyIdStr.trim());
            } else {
                resp.sendRedirect(req.getContextPath() + "/borrow/list?error=invalid_params");
                return;
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?error=invalid_params");
            return;
        }

        if (userId == 0 || bookId == 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?error=invalid_params");
            return;
        }

        Book b = bookDAO.findById(bookId);
        BookCopy bc = bookCopyDAO.findById(copyId);

        if (bc == null || !"AVAILABLE".equalsIgnoreCase(bc.getStatus())) {
            String redirectUrl = req.getContextPath() + "/borrow/list?checkout=true&error=copy_not_available"
                    + "&userId=" + userId + "&bookId=" + bookId 
                    + (copyId != null ? "&copyId=" + copyId : "");
            resp.sendRedirect(redirectUrl);
            return;
        }

        boolean overrideLimit = "true".equals(req.getParameter("overrideLimit"));
        String note = req.getParameter("note");

        // §1.1 Kiểm tra ngưỡng mượn
        int activeCount = borrowDAO.countActiveBorrowsAndReservations(userId);
        int maxLimit = borrowDAO.getMaxBorrowLimit(userId);
        if (activeCount >= maxLimit && !overrideLimit) {
            // Redirect về form với cảnh báo để Librarian xác nhận override
            resp.sendRedirect(req.getContextPath() + "/borrow/list?warning=over_limit&userId=" + userId
                    + "&bookId=" + bookId + (copyId != null ? "&copyId=" + copyId : ""));
            return;
        }

        BorrowRecord record = new BorrowRecord();
        record.setUserId(userId);
        record.setBookId(bookId);
        record.setCopyId(copyId);
        record.setBorrowDate(LocalDate.now());
        record.setDueDate(LocalDate.now().plusDays(14));
        record.setNote(note);
        record.setStatus("BORROWING");

        BorrowRecord created = borrowDAO.createBorrow(record);
        if (created != null) {
            b.setAvailable(b.getAvailable() - 1);
            bookDAO.updateBook(b);
            bc.setStatus("BORROWED");
            bookCopyDAO.updateCopy(bc);
            
            // Đánh dấu phiếu đặt trước thành COMPLETED nếu có
            com.swp391.dao.ReservationDAO resDAO = new com.swp391.dao.ReservationDAOImpl();
            resDAO.completeByUserAndBook(userId, bookId);

            resp.sendRedirect(req.getContextPath() + "/borrow/list?success=checkout");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?error=checkout_failed");
        }
    }

    /** Librarian/Admin: xử lý trả sách */
    private void processReturn(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int borrowId = parseIntOrDefault(req.getParameter("borrowId"), 0);
        if (borrowId == 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?error=invalid_params");
            return;
        }
        boolean ok = borrowDAO.returnBook(borrowId, loggedUser.getUsername());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?success=returned");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?error=return_failed");
        }
    }

    /**
     * §1.4 Gia hạn sách — User/Librarian.
     * Kiểm tra điều kiện: available_copies > 0 AND pending_reservations <= available_copies.
     */
    private void processRenew(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int borrowId = parseIntOrDefault(req.getParameter("borrowId"), 0);
        if (borrowId == 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow/my?error=invalid_params");
            return;
        }

        // §1.4 Kiểm tra điều kiện gia hạn
        if (!borrowDAO.canRenew(borrowId)) {
            resp.sendRedirect(req.getContextPath() + "/borrow/my?error=cannot_renew");
            return;
        }

        boolean ok = borrowDAO.renewBorrow(borrowId, loggedUser.getUsername());
        String redirectUrl = loggedUser.isAdminOrLibrarian()
                ? req.getContextPath() + "/borrow/list"
                : req.getContextPath() + "/borrow/my";
        resp.sendRedirect(redirectUrl + (ok ? "?success=renewed" : "?error=renew_failed"));
    }

    // -------------------------------------------------------------------------
    // Utilities
    // -------------------------------------------------------------------------

    private int parseIntOrDefault(String val, int def) {
        if (val == null || val.isEmpty()) return def;
        try { 
            String numStr = val.split(" - ")[0].trim();
            return Integer.parseInt(numStr); 
        } catch (NumberFormatException e) { 
            return def; 
        }
    }
}
