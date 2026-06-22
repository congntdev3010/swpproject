package com.swp391.servlet;

import com.swp391.dao.BorrowRecordDAO;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

/**
 * AdminBorrowServlet – xử lý URL /admin/borrow.
 * Hiển thị danh sách phiếu mượn trong giao diện admin panel.
 */
@WebServlet(name = "AdminBorrowServlet", urlPatterns = {"/admin/borrow"})
public class AdminBorrowServlet extends HttpServlet {

    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User logged = (User) session.getAttribute("loggedUser");
        if (!logged.isAdminOrLibrarian()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String statusFilter = request.getParameter("status");
        String search       = request.getParameter("search");
        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p.trim()));
        } catch (NumberFormatException ignored) {}

        try {
            List<BorrowRecord> records = borrowDAO.getAll(statusFilter, search, page, PAGE_SIZE);
            int total = borrowDAO.countAll(statusFilter, search);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;

            request.setAttribute("records",      records);
            request.setAttribute("total",        total);
            request.setAttribute("totalPages",   totalPages);
            request.setAttribute("currentPage",  page);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("search",       search);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Không thể tải danh sách phiếu mượn: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin-borrow.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chuyển các action POST sang BorrowServlet
        response.sendRedirect(request.getContextPath() + "/admin/borrow");
    }
}
