package com.swp391.servlet;

import com.swp391.dao.BorrowRecordDAO;
import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.FineDAO;
import com.swp391.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Servlet trả sách & tính phạt – chỉ dành cho LIBRARIAN / ADMIN.
 *
 * URL: /return-book
 *
 * GET actions:
 *   (default) – form tìm kiếm bằng barcode / mã phiếu
 *   search    – tìm phiếu theo barcode bản sao hoặc record id
 *   preview   – hiển thị chi tiết phiếu + preview tiền phạt
 *
 * POST actions:
 *   processReturn – thực hiện trả sách, tạo fine nếu trễ hạn
 *   updateFine    – cập nhật trạng thái thanh toán fine
 */
@WebServlet("/return-book")
public class ReturnBookServlet extends HttpServlet {

    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();
    private final BookCopyDAO     copyDAO   = new BookCopyDAO();
    private final FineDAO         fineDAO   = new FineDAO();

    // ================================================================
    // GET
    // ================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User loggedUser = getLoggedUser(req);
        if (loggedUser == null || !loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "form";

        switch (action) {
            case "search":
                handleSearch(req, resp);
                break;
            case "preview":
                showPreview(req, resp, loggedUser);
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

        User loggedUser = getLoggedUser(req);
        if (loggedUser == null || !loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "processReturn":
                processReturn(req, resp, loggedUser);
                break;
            case "updateFine":
                updateFine(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/return-book");
        }
    }

    // ================================================================
    // GET handlers
    // ================================================================

    /** Form tìm kiếm mặc định */
    private void showForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("pageTitle",       "Trả Sách & Tính Phạt – FPT Library");
        req.setAttribute("currentPage_nav", "return-book");
        req.getRequestDispatcher("/return-book.jsp").forward(req, resp);
    }

    /** Tìm phiếu theo barcode hoặc record id */
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

        resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + found.getId());
    }

    /** Hiển thị preview phiếu + tính phạt */
    private void showPreview(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        BorrowRecord record = borrowDAO.getById(id);

        if (record == null) {
            req.setAttribute("errorMsg", "Không tìm thấy phiếu mượn #" + id);
            showForm(req, resp);
            return;
        }

        // Tính phạt dự kiến (nếu trả ngay hôm nay)
        LocalDate today = LocalDate.now();
        Object[] fineCalc = FineDAO.calculateFine(record.getDueDate(), today);
        int overdueDays      = (Integer) fineCalc[0];
        BigDecimal fineAmount = (BigDecimal) fineCalc[1];

        // Lấy fines đã tồn tại (nếu có)
        var existingFines = fineDAO.getByBorrowRecordId(id);

        req.setAttribute("record",       record);
        req.setAttribute("overdueDays",  overdueDays);
        req.setAttribute("fineAmount",   fineAmount);
        req.setAttribute("existingFines", existingFines);
        req.setAttribute("today",        today.toString());
        req.setAttribute("pageTitle",    "Xác nhận Trả Sách #" + id + " – FPT Library");
        req.setAttribute("currentPage_nav", "return-book");
        req.getRequestDispatcher("/return-book.jsp").forward(req, resp);
    }

    // ================================================================
    // POST handlers
    // ================================================================

    /** LIBRARIAN thực hiện trả sách và tạo fine nếu trễ hạn */
    private void processReturn(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        int recordId = parseId(req.getParameter("recordId"));
        String returnDateStr = trim(req.getParameter("returnDate"));
        String note          = trim(req.getParameter("note"));
        boolean createFine   = "true".equals(req.getParameter("createFine"));

        if (recordId <= 0 || returnDateStr == null || returnDateStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + recordId + "&error=missing");
            return;
        }

        LocalDate returnDate;
        try { returnDate = LocalDate.parse(returnDateStr); }
        catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + recordId + "&error=dateFormat");
            return;
        }

        // Lấy phiếu
        BorrowRecord record = borrowDAO.getById(recordId);
        if (record == null || (!"BORROWING".equals(record.getStatus()) && !"OVERDUE".equals(record.getStatus()))) {
            resp.sendRedirect(req.getContextPath() + "/return-book?error=notActive");
            return;
        }

        // Thực hiện trả sách
        boolean returned = borrowDAO.returnBook(recordId, returnDate, note);
        if (!returned) {
            resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + recordId + "&error=returnFail");
            return;
        }

        // Cập nhật trạng thái bản sao → AVAILABLE
        if (record.getCopyId() != null) {
            borrowDAO.updateCopyStatusAvailable(record.getCopyId());
        }

        // Tạo fine nếu trễ hạn và được tích chọn
        if (createFine && record.getDueDate() != null) {
            Object[] calc = FineDAO.calculateFine(record.getDueDate(), returnDate);
            int overdueDays = (Integer) calc[0];
            BigDecimal amount = (BigDecimal) calc[1];
            if (overdueDays > 0) {
                fineDAO.createFine(recordId, record.getUserId(), amount, overdueDays, "OVERDUE");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + recordId + "&success=returned");
    }

    /** Cập nhật trạng thái thanh toán fine */
    private void updateFine(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        int fineId       = parseId(req.getParameter("fineId"));
        String status    = trim(req.getParameter("status"));
        String method    = trim(req.getParameter("paymentMethod"));
        String fineNote  = trim(req.getParameter("paymentNote"));

        boolean ok = fineDAO.updateFineStatus(fineId, status, method, fineNote);

        String redirectId = trim(req.getParameter("recordId"));
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + redirectId + "&success=fineUpdated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/return-book?action=preview&id=" + redirectId + "&error=fineFail");
        }
    }

    // ================================================================
    // Utility
    // ================================================================

    private User getLoggedUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("loggedUser") : null;
    }

    private int parseId(String s) {
        if (s == null) return 0;
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
