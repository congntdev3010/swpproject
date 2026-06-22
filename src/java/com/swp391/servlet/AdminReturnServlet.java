package com.swp391.servlet;

import com.swp391.dao.BorrowRecordDAO;
import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.FineDAO;
import com.swp391.model.BorrowRecord;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * AdminReturnServlet – xử lý URL /admin/return.
 * Hiển thị giao diện trả sách trong admin panel.
 */
@WebServlet(name = "AdminReturnServlet", urlPatterns = {"/admin/return"})
public class AdminReturnServlet extends HttpServlet {

    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();
    private final BookCopyDAO     copyDAO   = new BookCopyDAO();
    private final FineDAO         fineDAO   = new FineDAO();

    // ================================================================
    // GET
    // ================================================================
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

        String action = req.getParameter("action");
        if (action == null) action = "form";

        switch (action) {
            case "search":
                handleSearch(req, resp);
                break;
            case "preview":
                showPreview(req, resp, logged);
                break;
            default:
                showForm(req, resp);
        }
    }

    // ================================================================
    // POST
    // ================================================================
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
        if (action == null) action = "";

        switch (action) {
            case "processReturn":
                processReturn(req, resp, logged);
                break;
            case "updateFine":
                updateFine(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/return");
        }
    }

    // ================================================================
    // GET handlers
    // ================================================================

    private void showForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("pageTitle", "Trả Sách – Admin Panel");
        req.getRequestDispatcher("/admin-return.jsp").forward(req, resp);
    }

    private void handleSearch(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String barcode   = trim(req.getParameter("barcode"));
        String recordIdS = trim(req.getParameter("recordId"));

        BorrowRecord found = null;

        if (barcode != null && !barcode.isEmpty()) {
            found = borrowDAO.findActiveByCopyBarcode(barcode);
        } else if (recordIdS != null && !recordIdS.isEmpty()) {
            try {
                int id = Integer.parseInt(recordIdS);
                BorrowRecord br = borrowDAO.getById(id);
                if (br != null && ("BORROWING".equals(br.getStatus()) || "OVERDUE".equals(br.getStatus()))) {
                    found = br;
                }
            } catch (NumberFormatException ignored) {}
        }

        if (found == null) {
            req.setAttribute("errorMsg", "Không tìm thấy phiếu mượn đang hoạt động với thông tin đã nhập.");
            showForm(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + found.getId());
    }

    private void showPreview(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        BorrowRecord record = borrowDAO.getById(id);

        if (record == null) {
            req.setAttribute("errorMsg", "Không tìm thấy phiếu mượn #" + id);
            showForm(req, resp);
            return;
        }

        LocalDate today = LocalDate.now();
        Object[] fineCalc = FineDAO.calculateFine(record.getDueDate(), today);
        int overdueDays       = (Integer) fineCalc[0];
        BigDecimal fineAmount = (BigDecimal) fineCalc[1];

        var existingFines = fineDAO.getByBorrowRecordId(id);

        req.setAttribute("record",        record);
        req.setAttribute("overdueDays",   overdueDays);
        req.setAttribute("fineAmount",    fineAmount);
        req.setAttribute("existingFines", existingFines);
        req.setAttribute("today",         today.toString());
        req.setAttribute("pageTitle",     "Xác nhận Trả Sách #" + id + " – Admin Panel");
        req.getRequestDispatcher("/admin-return.jsp").forward(req, resp);
    }

    // ================================================================
    // POST handlers
    // ================================================================

    private void processReturn(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        int recordId = parseId(req.getParameter("recordId"));
        String returnDateStr = trim(req.getParameter("returnDate"));
        String note          = trim(req.getParameter("note"));
        boolean createFine   = "true".equals(req.getParameter("createFine"));

        if (recordId <= 0 || returnDateStr == null || returnDateStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + recordId + "&error=missing");
            return;
        }

        LocalDate returnDate;
        try { returnDate = LocalDate.parse(returnDateStr); }
        catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + recordId + "&error=dateFormat");
            return;
        }

        BorrowRecord record = borrowDAO.getById(recordId);
        if (record == null || (!"BORROWING".equals(record.getStatus()) && !"OVERDUE".equals(record.getStatus()))) {
            resp.sendRedirect(req.getContextPath() + "/admin/return?error=notActive");
            return;
        }

        boolean returned = borrowDAO.returnBook(recordId, returnDate, note);
        if (!returned) {
            resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + recordId + "&error=returnFail");
            return;
        }

        if (record.getCopyId() != null) {
            borrowDAO.updateCopyStatusAvailable(record.getCopyId());
        }

        if (createFine && record.getDueDate() != null) {
            Object[] calc = FineDAO.calculateFine(record.getDueDate(), returnDate);
            int overdueDays = (Integer) calc[0];
            BigDecimal amount = (BigDecimal) calc[1];
            if (overdueDays > 0) {
                fineDAO.createFine(recordId, record.getUserId(), amount, overdueDays, "OVERDUE");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + recordId + "&success=returned");
    }

    private void updateFine(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        int fineId      = parseId(req.getParameter("fineId"));
        String status   = trim(req.getParameter("status"));
        String method   = trim(req.getParameter("paymentMethod"));
        String fineNote = trim(req.getParameter("paymentNote"));

        boolean ok = fineDAO.updateFineStatus(fineId, status, method, fineNote);

        String redirectId = trim(req.getParameter("recordId"));
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + redirectId + "&success=fineUpdated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/return?action=preview&id=" + redirectId + "&error=fineFail");
        }
    }

    // ================================================================
    // Utility
    // ================================================================

    private int parseId(String s) {
        if (s == null) return 0;
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
