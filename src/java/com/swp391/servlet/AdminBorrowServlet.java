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
 * GET  /admin/borrow                     → Hiển thị danh sách phiếu mượn (nhóm theo phiếu)
 * POST /admin/borrow?action=approveGroup → Duyệt toàn bộ phiếu trong nhóm
 * POST /admin/borrow?action=rejectGroup  → Từ chối toàn bộ phiếu trong nhóm
 * POST /admin/borrow?action=approve      → Duyệt 1 phiếu đơn lẻ (compat)
 * POST /admin/borrow?action=reject       → Từ chối 1 phiếu đơn lẻ (compat)
 * POST /admin/borrow?action=return       → Xác nhận trả sách
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

        try {
            BorrowDAO dao = new BorrowDAO();

            // Phiếu PENDING: lấy theo nhóm (mỗi nhóm = 1 lần gửi giỏ sách)
            List<List<BorrowRecord>> pendingGroups = dao.getPendingGrouped();

            // Phiếu đang mượn / đã trả / từ chối
            List<BorrowRecord> borrowingList = dao.getAllBorrows("BORROWING");
            List<BorrowRecord> returnedList  = dao.getAllBorrows("RETURNED");
            List<BorrowRecord> rejectedList  = dao.getAllBorrows("REJECTED");

            req.setAttribute("pendingGroups",  pendingGroups);
            req.setAttribute("pendingCount",   pendingGroups.size());  // số phiếu (nhóm) chờ duyệt
            req.setAttribute("borrowingList",  borrowingList);
            req.setAttribute("returnedList",   returnedList);
            req.setAttribute("rejectedList",   rejectedList);
            req.setAttribute("activeTab",      "borrow");

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

        try {
            BorrowDAO dao = new BorrowDAO();

            if ("approveGroup".equals(action)) {
                // Duyệt toàn bộ sách trong 1 phiếu (nhóm)
                String groupId = req.getParameter("groupId");
                if (groupId != null && !groupId.isEmpty()) {
                    int approved = dao.approveGroup(groupId);
                    session.setAttribute("adminBorrowMsg", approved > 0 ? "approved" : "approve_failed");
                } else {
                    session.setAttribute("adminBorrowMsg", "approve_failed");
                }

            } else if ("rejectGroup".equals(action)) {
                // Từ chối toàn bộ sách trong 1 phiếu (nhóm)
                String groupId = req.getParameter("groupId");
                if (groupId != null && !groupId.isEmpty()) {
                    boolean ok = dao.rejectGroup(groupId);
                    session.setAttribute("adminBorrowMsg", ok ? "rejected" : "reject_failed");
                } else {
                    session.setAttribute("adminBorrowMsg", "reject_failed");
                }

            } else if ("removeItem".equals(action)) {
                // Xóa 1 sách khỏi phiếu nhóm (từ chối riêng quyển đó do sách gặp vấn đề)
                String borrowIdStr = req.getParameter("borrowId");
                if (borrowIdStr != null && !borrowIdStr.isEmpty()) {
                    boolean ok = dao.rejectRequest(Integer.parseInt(borrowIdStr));
                    session.setAttribute("adminBorrowMsg", ok ? "item_removed" : "approve_failed");
                }

            } else if ("approve".equals(action)) {
                // Duyệt từng phiếu đơn lẻ (tương thích ngược)
                String borrowIdStr = req.getParameter("borrowId");
                if (borrowIdStr != null && !borrowIdStr.isEmpty()) {
                    boolean ok = dao.approveRequest(Integer.parseInt(borrowIdStr));
                    session.setAttribute("adminBorrowMsg", ok ? "approved" : "approve_failed");
                }

            } else if ("reject".equals(action)) {
                // Từ chối từng phiếu đơn lẻ (tương thích ngược)
                String borrowIdStr = req.getParameter("borrowId");
                if (borrowIdStr != null && !borrowIdStr.isEmpty()) {
                    boolean ok = dao.rejectRequest(Integer.parseInt(borrowIdStr));
                    session.setAttribute("adminBorrowMsg", ok ? "rejected" : "reject_failed");
                }

            } else if ("return".equals(action)) {
                // Xác nhận trả sách
                String borrowIdStr = req.getParameter("borrowId");
                if (borrowIdStr != null && !borrowIdStr.isEmpty()) {
                    int borrowId = Integer.parseInt(borrowIdStr);
                    String condition = req.getParameter("condition");
                    if (condition == null || condition.isEmpty()) condition = "GOOD";
                    boolean ok = dao.returnBook(borrowId, condition);
                    session.setAttribute("adminBorrowMsg", ok ? "returned" : "return_failed");
                }
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
