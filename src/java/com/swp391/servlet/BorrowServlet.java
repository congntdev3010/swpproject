package com.swp391.servlet;

import com.swp391.dao.BookDAOImpl;
import com.swp391.dao.BorrowDAO;
import com.swp391.model.Book;
import com.swp391.model.BorrowCartItem;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet quản lý giỏ sách mượn cho role READER.
 * URL: /borrow
 *
 * GET  /borrow              → Hiển thị giỏ sách
 * POST /borrow?action=add   → Thêm sách vào giỏ
 * POST /borrow?action=remove → Xóa sách khỏi giỏ
 * POST /borrow?action=confirm → Tạo phiếu mượn PENDING
 */
@WebServlet(name = "BorrowServlet", urlPatterns = {"/borrow"})
public class BorrowServlet extends HttpServlet {

    private static final String CART_ATTR = "borrowCart";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Cả READER, ADMIN, LIBRARIAN đều có thể xem giỏ
        // (admin/librarian dùng để test)

        @SuppressWarnings("unchecked")
        List<BorrowCartItem> cart = (List<BorrowCartItem>) session.getAttribute(CART_ATTR);
        if (cart == null) cart = new ArrayList<>();

        req.setAttribute("cart", cart);
        req.setAttribute("pageTitle", "Giỏ sách mượn – FPT Library");
        req.setAttribute("currentPage", "borrow");
        req.getRequestDispatcher("/borrow_cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        @SuppressWarnings("unchecked")
        List<BorrowCartItem> cart = (List<BorrowCartItem>) session.getAttribute(CART_ATTR);
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute(CART_ATTR, cart);
        }

        if ("add".equals(action)) {
            handleAdd(req, resp, session, cart, loggedUser);
        } else if ("remove".equals(action)) {
            handleRemove(req, resp, session, cart);
        } else if ("confirm".equals(action)) {
            handleConfirm(req, resp, session, cart, loggedUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp,
                           HttpSession session, List<BorrowCartItem> cart, User loggedUser)
            throws IOException {
        String bookIdStr = req.getParameter("bookId");
        String referer = req.getHeader("Referer");
        String redirectUrl = (referer != null && !referer.isEmpty()) ? referer : req.getContextPath() + "/books";

        if (bookIdStr == null || bookIdStr.isEmpty()) {
            resp.sendRedirect(redirectUrl);
            return;
        }

        try {
            int bookId = Integer.parseInt(bookIdStr);

            // Kiểm tra sách đã có trong giỏ chưa
            for (BorrowCartItem item : cart) {
                if (item.getBookId() == bookId) {
                    // Đã có → redirect về với thông báo
                    session.setAttribute("cartMsg", "already");
                    resp.sendRedirect(redirectUrl);
                    return;
                }
            }

            // Lấy thông tin sách
            BookDAOImpl bookDao = new BookDAOImpl();
            Book book = bookDao.findById(bookId);
            if (book == null || book.getAvailable() <= 0) {
                session.setAttribute("cartMsg", "unavailable");
                resp.sendRedirect(redirectUrl);
                return;
            }

            BorrowCartItem item = new BorrowCartItem(
                bookId, book.getTitle(), book.getIsbn(),
                book.getCategory(), book.getAvailable()
            );
            cart.add(item);
            session.setAttribute(CART_ATTR, cart);
            session.setAttribute("cartMsg", "added");
        } catch (NumberFormatException e) {
            // ignore
        } catch (Exception e) {
            e.printStackTrace();
        }
        resp.sendRedirect(redirectUrl);
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session, List<BorrowCartItem> cart)
            throws IOException {
        String bookIdStr = req.getParameter("bookId");
        if (bookIdStr != null) {
            try {
                int bookId = Integer.parseInt(bookIdStr);
                cart.removeIf(item -> item.getBookId() == bookId);
                session.setAttribute(CART_ATTR, cart);
            } catch (NumberFormatException ignore) {}
        }
        resp.sendRedirect(req.getContextPath() + "/borrow");
    }

    private void handleConfirm(HttpServletRequest req, HttpServletResponse resp,
                               HttpSession session, List<BorrowCartItem> cart, User loggedUser)
            throws IOException {
        if (cart.isEmpty()) {
            session.setAttribute("borrowMsg", "empty");
            resp.sendRedirect(req.getContextPath() + "/borrow");
            return;
        }

        List<Integer> bookIds = new ArrayList<>();
        for (BorrowCartItem item : cart) {
            bookIds.add(item.getBookId());
        }

        try {
            BorrowDAO borrowDAO = new BorrowDAO();
            int created = borrowDAO.createPendingRequests(loggedUser.getId(), bookIds);
            if (created > 0) {
                cart.clear();
                session.setAttribute(CART_ATTR, cart);
                session.setAttribute("borrowMsg", "success");
            } else {
                session.setAttribute("borrowMsg", "failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("borrowMsg", "failed");
        }
        resp.sendRedirect(req.getContextPath() + "/borrow");
    }
}
