package com.swp391.servlet;

import com.swp391.dao.BorrowDAO;
import com.swp391.dao.BorrowDAOImpl;
import com.swp391.dao.ReservationDAO;
import com.swp391.dao.ReservationDAOImpl;
import com.swp391.model.ReservationRecord;
import com.swp391.model.User;
import com.swp391.util.NotificationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý nghiệp vụ đặt trước sách.
 * Spec: library-rules-spec-v2.md §1.1, §1.3, §4.2
 *
 * URL patterns:
 *   GET  /reservation/my     — User: phiếu đặt trước của mình
 *   GET  /reservation/list   — Librarian/Admin: toàn bộ phiếu
 *   POST /reservation/create — User tạo phiếu
 *   POST /reservation/confirm — Librarian/Admin duyệt
 *   POST /reservation/cancel  — hủy phiếu (kiểm tra quyền)
 */
@WebServlet(name = "ReservationServlet", urlPatterns = {
    "/reservation/my", "/reservation/list",
    "/reservation/create", "/reservation/confirm", "/reservation/cancel"
})
public class ReservationServlet extends HttpServlet {

    private static final int PAGE_SIZE = 15;
    private final ReservationDAO reservationDAO = new ReservationDAOImpl();
    private final BorrowDAO borrowDAO = new BorrowDAOImpl();

    // -------------------------------------------------------------------------
    // GET
    // -------------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            switch (request.getServletPath()) {
                case "/reservation/list":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    showList(request, response, loggedUser);
                    break;
                case "/reservation/my":
                    showMyReservations(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/reservation/my");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    // -------------------------------------------------------------------------
    // POST
    // -------------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        try {
            switch (request.getServletPath()) {
                case "/reservation/create": processCreate(request, response, loggedUser); break;
                case "/reservation/confirm":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    processConfirm(request, response, loggedUser);
                    break;
                case "/reservation/cancel": processCancel(request, response, loggedUser); break;
                default: response.sendRedirect(request.getContextPath() + "/reservation/my");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    // -------------------------------------------------------------------------
    // Handlers
    // -------------------------------------------------------------------------

    private void showList(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        String status = req.getParameter("status");
        String keyword = req.getParameter("keyword");
        int page = parseIntOrDefault(req.getParameter("page"), 1);
        List<ReservationRecord> reservations = reservationDAO.getAll(status, keyword, page, PAGE_SIZE);
        int total = reservationDAO.countAll(status, keyword);
        req.setAttribute("reservations", reservations);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("status", status);
        req.setAttribute("keyword", keyword);
        req.setAttribute("pageTitle", "Quản lý đặt trước sách");
        req.setAttribute("activePage", "reservations");
        req.getRequestDispatcher("/reservation_list.jsp").forward(req, resp);
    }

    private void showMyReservations(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        List<ReservationRecord> reservations = reservationDAO.getByUser(loggedUser.getId());
        int activeCount = borrowDAO.countActiveBorrowsAndReservations(loggedUser.getId());
        int maxLimit = borrowDAO.getMaxBorrowLimit(loggedUser.getId());
        req.setAttribute("reservations", reservations);
        req.setAttribute("activeCount", activeCount);
        req.setAttribute("maxLimit", maxLimit);
        req.setAttribute("pageTitle", "Phiếu đặt trước của tôi");
        req.setAttribute("activePage", "reservations");
        req.getRequestDispatcher("/reservation_list.jsp").forward(req, resp);
    }

    /**
     * §1.1, §1.3 User tạo phiếu đặt trước.
     * Kiểm tra ngưỡng (mượn + đặt trước) trước khi cho phép.
     */
    private void processCreate(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int bookId = parseIntOrDefault(req.getParameter("bookId"), 0);
        if (bookId == 0) {
            resp.sendRedirect(req.getContextPath() + "/reservation/my?error=invalid_params");
            return;
        }
        // §1.1 Kiểm tra ngưỡng
        int activeCount = borrowDAO.countActiveBorrowsAndReservations(loggedUser.getId());
        int maxLimit = borrowDAO.getMaxBorrowLimit(loggedUser.getId());
        if (activeCount >= maxLimit) {
            resp.sendRedirect(req.getContextPath() + "/reservation/my?error=over_limit");
            return;
        }
        ReservationRecord created = reservationDAO.create(loggedUser.getId(), bookId);
        resp.sendRedirect(req.getContextPath() + "/reservation/my?success=" + (created != null ? "created" : "failed"));
    }

    /** §4.2 Librarian/Admin duyệt phiếu đặt trước */
    private void processConfirm(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int id = parseIntOrDefault(req.getParameter("reservationId"), 0);
         int userId = parseIntOrDefault(req.getParameter("userId"), 0);
        int bookId = parseIntOrDefault(req.getParameter("bookId"), 0);
        if (id == 0) { resp.sendRedirect(req.getContextPath() + "/reservation/list?error=invalid_params"); return; }
        boolean ok = reservationDAO.confirm(id, loggedUser.getUsername());
       if (ok && userId > 0 && bookId > 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow/list?checkout=1&userId=" + userId + "&bookId=" + bookId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/reservation/list?success=" + (ok ? "confirmed" : "failed"));
        }
    }

    /**
     * §4.2 Hủy phiếu:
     *   - User: chỉ được hủy phiếu của mình
     *   - Librarian/Admin: hủy bất kỳ phiếu nào
     */
    private void processCancel(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int id = parseIntOrDefault(req.getParameter("reservationId"), 0);
        if (id == 0) { resp.sendRedirect(req.getContextPath() + "/reservation/my?error=invalid_params"); return; }

        String cancelReason = req.getParameter("cancelReason");
        
        ReservationRecord record = reservationDAO.findById(id);
        // Nếu là User thường, kiểm tra phiếu có thuộc về user này không
        if (!loggedUser.isAdminOrLibrarian()) {

            if (record == null || record.getUserId() != loggedUser.getId()) {
                resp.sendError(403, "Bạn không có quyền hủy phiếu này.");
                return;
            }
        }
        boolean ok = reservationDAO.cancel(id, loggedUser.getUsername());
        
        if (ok && loggedUser.isAdminOrLibrarian() && cancelReason != null && !cancelReason.trim().isEmpty() && record != null) {
            NotificationUtil.sendSystemMessage(record.getUserId(), "Thông báo hủy đơn đặt trước", cancelReason.trim());
        }
        String redirect = loggedUser.isAdminOrLibrarian()
                ? req.getContextPath() + "/reservation/list"
                : req.getContextPath() + "/reservation/my";
        resp.sendRedirect(redirect + "?success=" + (ok ? "cancelled" : "failed"));
    }

    // -------------------------------------------------------------------------
    private int parseIntOrDefault(String val, int def) {
        if (val == null || val.isEmpty()) return def;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return def; }
    }
}
