package com.swp391.servlet;

import com.swp391.dao.FineDAO;
import com.swp391.dao.FineDAOImpl;
import com.swp391.model.Fine;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet xử lý nghiệp vụ phạt.
 * Spec: library-rules-spec-v2.md §2, §4.2
 *
 * URL patterns:
 *   GET  /fine/my    — User: xem phạt của mình
 *   GET  /fine/list  — Librarian/Admin: xem toàn bộ
 *   POST /fine/create — Librarian tạo phạt DAMAGE/LOST
 *   POST /fine/waive  — Admin miễn giảm phạt
 *   POST /fine/pay    — Librarian ghi nhận thanh toán
 */
@WebServlet(name = "FineServlet", urlPatterns = {
    "/fine/my", "/fine/list", "/fine/create", "/fine/waive", "/fine/pay"
})
public class FineServlet extends HttpServlet {

    private static final int PAGE_SIZE = 15;
    private final FineDAO fineDAO = new FineDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        try {
            switch (request.getServletPath()) {
                case "/fine/list":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    showList(request, response, loggedUser);
                    break;
                case "/fine/my":
                    showMyFines(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/fine/my");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        try {
            switch (request.getServletPath()) {
                case "/fine/create":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    processCreate(request, response, loggedUser);
                    break;
                case "/fine/waive":
                    if (!loggedUser.isAdmin()) { response.sendError(403, "Chỉ Admin mới có quyền miễn giảm phạt."); return; }
                    processWaive(request, response, loggedUser);
                    break;
                case "/fine/pay":
                    if (!loggedUser.isAdminOrLibrarian()) { response.sendError(403); return; }
                    processPay(request, response, loggedUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/fine/list");
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
        List<Fine> fines = fineDAO.getAllFines(status, keyword, page, PAGE_SIZE);
        int total = fineDAO.countAllFines(status, keyword);
        req.setAttribute("fines", fines);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("status", status);
        req.setAttribute("keyword", keyword);
        req.setAttribute("pageTitle", "Quản lý phạt");
        req.setAttribute("activePage", "fines");
        req.getRequestDispatcher("/fine_list.jsp").forward(req, resp);
    }

    private void showMyFines(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, ServletException, IOException {
        List<Fine> fines = fineDAO.getFinesByUser(loggedUser.getId());
        req.setAttribute("fines", fines);
        req.setAttribute("pageTitle", "Phạt của tôi");
        req.setAttribute("activePage", "fines");
        req.getRequestDispatcher("/fine_list.jsp").forward(req, resp);
    }

    /** §2.3 Librarian tạo phiếu phạt Damage hoặc Lost */
    private void processCreate(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int borrowRecordId = parseIntOrDefault(req.getParameter("borrowRecordId"), 0);
        String type = req.getParameter("type"); // DAMAGE or LOST
        if (borrowRecordId == 0 || type == null) {
            resp.sendRedirect(req.getContextPath() + "/fine/list?error=invalid_params");
            return;
        }
        Fine created;
        if ("DAMAGE".equalsIgnoreCase(type)) {
            created = fineDAO.applyDamageFine(borrowRecordId, loggedUser.getUsername());
        } else if ("LOST".equalsIgnoreCase(type)) {
            created = fineDAO.applyLostFine(borrowRecordId, loggedUser.getUsername());
        } else {
            resp.sendRedirect(req.getContextPath() + "/fine/list?error=invalid_type");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/fine/list?success=" + (created != null ? "created" : "failed"));
    }

    /** §4.2 Admin miễn giảm phạt */
    private void processWaive(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int fineId = parseIntOrDefault(req.getParameter("fineId"), 0);
        String note = req.getParameter("note");
        if (fineId == 0) { resp.sendRedirect(req.getContextPath() + "/fine/list?error=invalid_params"); return; }
        boolean ok = fineDAO.waiveFine(fineId, loggedUser.getUsername(), note);
        resp.sendRedirect(req.getContextPath() + "/fine/list?success=" + (ok ? "waived" : "failed"));
    }

    /** Librarian ghi nhận thanh toán */
    private void processPay(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws Exception, IOException {
        int fineId = parseIntOrDefault(req.getParameter("fineId"), 0);
        String method = req.getParameter("method"); // CASH or ONLINE
        String note = req.getParameter("note");
        if (fineId == 0) { resp.sendRedirect(req.getContextPath() + "/fine/list?error=invalid_params"); return; }
        boolean ok = fineDAO.markPaid(fineId, method, note);
        resp.sendRedirect(req.getContextPath() + "/fine/list?success=" + (ok ? "paid" : "failed"));
    }

    private int parseIntOrDefault(String val, int def) {
        if (val == null || val.isEmpty()) return def;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return def; }
    }
}
