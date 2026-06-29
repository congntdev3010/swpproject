package com.swp391.servlet;

import com.swp391.dao.BorrowDAO;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

/**
 * Servlet quản lý phiếu mượn sách cho ADMIN và LIBRARIAN.
 * URL: /admin/borrow
 *
 * GET  /admin/borrow                → Hiển thị danh sách phiếu mượn
 * POST /admin/borrow?action=approve → Duyệt phiếu
 * POST /admin/borrow?action=reject  → Từ chối phiếu
 * POST /admin/borrow?action=return  → Xác nhận trả sách
 */
@WebServlet(name = "AdminBorrowServlet", urlPatterns = {"/admin/borrow"})
public class AdminBorrowServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User logged = (User) session.getAttribute("loggedUser");
        if (!logged.isAdminOrLibrarian()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String statusFilter = req.getParameter("status"); // null = tất cả

        try {
            BorrowDAO dao = new BorrowDAO();
            // Lấy danh sách PENDING riêng (luôn hiển thị ở đầu)
            List<BorrowRecord> pendingList  = dao.getAllBorrows("PENDING");
            List<BorrowRecord> borrowingList = dao.getAllBorrows("BORROWING");
            List<BorrowRecord> returnedList = dao.getAllBorrows("RETURNED");
            List<BorrowRecord> rejectedList = dao.getAllBorrows("REJECTED");

            req.setAttribute("pendingList",  pendingList);
            req.setAttribute("borrowingList", borrowingList);
            req.setAttribute("returnedList", returnedList);
            req.setAttribute("rejectedList", rejectedList);
            req.setAttribute("pendingCount", pendingList.size());
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("activeTab", "borrow");

        } catch (Exception e) {
            req.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        req.getRequestDispatcher("/admin_borrow.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User logged = (User) session.getAttribute("loggedUser");
        if (!logged.isAdminOrLibrarian()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        String borrowIdStr = req.getParameter("borrowId");

        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/borrow");
            return;
        }

        try {
            int borrowId = Integer.parseInt(borrowIdStr);
            BorrowDAO dao = new BorrowDAO();

            if ("approve".equals(action)) {
                boolean ok = dao.approveRequest(borrowId);
                session.setAttribute("adminBorrowMsg", ok ? "approved" : "approve_failed");
            } else if ("reject".equals(action)) {
                boolean ok = dao.rejectRequest(borrowId);
                session.setAttribute("adminBorrowMsg", ok ? "rejected" : "reject_failed");
            } else if ("return".equals(action)) {
                String condition = req.getParameter("condition");
                if (condition == null || condition.isEmpty()) condition = "GOOD";
                boolean ok = dao.returnBook(borrowId, condition);
                session.setAttribute("adminBorrowMsg", ok ? "returned" : "return_failed");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("adminBorrowMsg", "invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminBorrowMsg", "error");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/borrow");
    }
}
