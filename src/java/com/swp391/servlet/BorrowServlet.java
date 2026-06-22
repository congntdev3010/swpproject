package com.swp391.servlet;

import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.BookDAO;
import com.swp391.dao.BookDAOImpl;
import com.swp391.dao.BorrowRecordDAO;
import com.swp391.model.*;

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
 * Servlet quản lý phiếu mượn sách (Borrow Records).
 *
 * URL: /borrow
 *
 * GET actions:
 *   list    – danh sách phiếu (READER thấy của mình, LIBRARIAN thấy tất cả)
 *   create  – form tạo phiếu (READER)
 *   detail  – chi tiết phiếu (?id=X)
 *   edit    – form sửa ghi chú (?id=X, READER khi PENDING)
 *   confirm – form xác nhận phiếu (?id=X, LIBRARIAN)
 *
 * POST actions:
 *   create         – READER tạo phiếu
 *   updateNote     – READER cập nhật ghi chú (PENDING)
 *   cancel         – READER huỷ phiếu (PENDING)
 *   librarianConfirm – LIBRARIAN xác nhận phiếu
 *   librarianReject  – LIBRARIAN từ chối phiếu
 */
@WebServlet("/borrow")
public class BorrowServlet extends HttpServlet {

    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();
    private final BookDAO bookDAO = new BookDAOImpl();
    private final BookCopyDAO copyDAO = new BookCopyDAO();

    private static final int PAGE_SIZE = 10;

    // ================================================================
    // GET
    // ================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User loggedUser = getLoggedUser(req);
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "create":
                showCreateForm(req, resp, loggedUser);
                break;
            case "detail":
                showDetail(req, resp, loggedUser);
                break;
            case "edit":
                showEditForm(req, resp, loggedUser);
                break;
            case "confirm":
                showConfirmForm(req, resp, loggedUser);
                break;
            default:
                showList(req, resp, loggedUser);
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
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "create":
                handleCreate(req, resp, loggedUser);
                break;
            case "updateNote":
                handleUpdateNote(req, resp, loggedUser);
                break;
            case "cancel":
                handleCancel(req, resp, loggedUser);
                break;
            case "librarianConfirm":
                handleLibrarianConfirm(req, resp, loggedUser);
                break;
            case "librarianReject":
                handleLibrarianReject(req, resp, loggedUser);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
        }
    }

    // ================================================================
    // GET handlers
    // ================================================================

    /** Hiển thị danh sách phiếu mượn. */
    private void showList(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        String statusFilter = req.getParameter("status");
        String search       = req.getParameter("search");
        int page = parsePage(req.getParameter("page"));

        List<BorrowRecord> records;
        int total;

        if (loggedUser.isAdminOrLibrarian()) {
            // Librarian / Admin xem tất cả phiếu
            records = borrowDAO.getAll(statusFilter, search, page, PAGE_SIZE);
            total   = borrowDAO.countAll(statusFilter, search);
        } else {
            // Reader chỉ xem phiếu của mình
            records = borrowDAO.getByUserId(loggedUser.getId(), statusFilter, search, page, PAGE_SIZE);
            total   = borrowDAO.countByUserId(loggedUser.getId(), statusFilter, search);
        }

        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("records",     records);
        req.setAttribute("total",       total);
        req.setAttribute("totalPages",  totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("search",       search);
        req.setAttribute("currentPage_nav", "borrow");
        req.setAttribute("pageTitle",    "Quản lý Phiếu Mượn – FPT Library");

        req.getRequestDispatcher("/borrow-list.jsp").forward(req, resp);
    }

    /** Form tạo phiếu mượn mới (READER). */
    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        if (!loggedUser.isReader() && !loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        // Lấy book_id từ param (nếu đến từ trang sách)
        String bookIdParam = req.getParameter("bookId");
        Book preselectedBook = null;
        if (bookIdParam != null) {
            try {
                preselectedBook = bookDAO.findById(Integer.parseInt(bookIdParam));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        req.setAttribute("preselectedBook", preselectedBook);
        req.setAttribute("currentPage_nav", "borrow");
        req.setAttribute("pageTitle", "Tạo Phiếu Mượn – FPT Library");
        req.getRequestDispatcher("/borrow-form.jsp").forward(req, resp);
    }

    /** Chi tiết phiếu mượn. */
    private void showDetail(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        int id = parseId(req.getParameter("id"));
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        BorrowRecord record = borrowDAO.getById(id);
        if (record == null) {
            req.setAttribute("errorMsg", "Không tìm thấy phiếu mượn.");
            req.getRequestDispatcher("/borrow-list.jsp").forward(req, resp);
            return;
        }

        // Reader chỉ được xem phiếu của mình
        if (loggedUser.isReader() && record.getUserId() != loggedUser.getId()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        req.setAttribute("record", record);
        req.setAttribute("currentPage_nav", "borrow");
        req.setAttribute("pageTitle", "Chi tiết Phiếu Mượn #" + id + " – FPT Library");
        req.getRequestDispatcher("/borrow-form.jsp").forward(req, resp);
    }

    /** Form sửa ghi chú phiếu (READER, chỉ khi PENDING). */
    private void showEditForm(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        if (!loggedUser.isReader()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        int id = parseId(req.getParameter("id"));
        BorrowRecord record = borrowDAO.getById(id);

        if (record == null || record.getUserId() != loggedUser.getId()
                || !"PENDING".equals(record.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        req.setAttribute("record",     record);
        req.setAttribute("editMode",   true);
        req.setAttribute("currentPage_nav", "borrow");
        req.setAttribute("pageTitle",  "Chỉnh sửa Phiếu Mượn – FPT Library");
        req.getRequestDispatcher("/borrow-form.jsp").forward(req, resp);
    }

    /** Form Librarian xác nhận phiếu. */
    private void showConfirmForm(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException {

        if (!loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        int id = parseId(req.getParameter("id"));
        BorrowRecord record = borrowDAO.getById(id);

        if (record == null || !"PENDING".equals(record.getStatus())) {
            req.setAttribute("errorMsg", "Phiếu không tồn tại hoặc đã được xử lý.");
            showList(req, resp, loggedUser);
            return;
        }

        // Lấy danh sách bản sao AVAILABLE của cuốn sách đó
        List<BookCopy> availableCopies = copyDAO.getAvailableCopiesByBookId(record.getBookId());

        req.setAttribute("record",           record);
        req.setAttribute("availableCopies",  availableCopies);
        req.setAttribute("editMode",         true);
        req.setAttribute("librarianMode",    true);
        req.setAttribute("currentPage_nav",  "borrow");
        req.setAttribute("pageTitle",        "Xác nhận Phiếu Mượn – FPT Library");
        req.getRequestDispatcher("/borrow-form.jsp").forward(req, resp);
    }

    // ================================================================
    // POST handlers
    // ================================================================

    /** READER tạo phiếu mượn. */
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        String bookIdParam = req.getParameter("bookId");
        String note = trim(req.getParameter("note"));

        // Validation
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=create&error=noBook");
            return;
        }

        int bookId;
        try { bookId = Integer.parseInt(bookIdParam); }
        catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=create&error=invalid");
            return;
        }

        int newId = borrowDAO.createBorrowRecord(loggedUser.getId(), bookId, note);
        if (newId > 0) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=detail&id=" + newId + "&success=created");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=create&error=db");
        }
    }

    /** READER cập nhật ghi chú phiếu (chỉ PENDING). */
    private void handleUpdateNote(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        int id = parseId(req.getParameter("id"));
        String note = trim(req.getParameter("note"));

        boolean ok = borrowDAO.updateNote(id, loggedUser.getId(), note);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=detail&id=" + id + "&success=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=edit&id=" + id + "&error=updateFail");
        }
    }

    /** READER huỷ phiếu (chỉ PENDING). */
    private void handleCancel(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        int id = parseId(req.getParameter("id"));
        boolean ok = borrowDAO.cancelRecord(id, loggedUser.getId());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list&success=cancelled");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=detail&id=" + id + "&error=cancelFail");
        }
    }

    /** LIBRARIAN xác nhận phiếu mượn. */
    private void handleLibrarianConfirm(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        if (!loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        int recordId = parseId(req.getParameter("recordId"));
        int copyId   = parseId(req.getParameter("copyId"));

        String borrowDateStr = req.getParameter("borrowDate");
        String dueDateStr    = req.getParameter("dueDate");
        String libNote       = trim(req.getParameter("librarianNote"));

        // Validation
        if (copyId <= 0 || borrowDateStr == null || dueDateStr == null) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=confirm&id=" + recordId + "&error=missingFields");
            return;
        }

        LocalDate borrowDate, dueDate;
        try {
            borrowDate = LocalDate.parse(borrowDateStr);
            dueDate    = LocalDate.parse(dueDateStr);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=confirm&id=" + recordId + "&error=dateFormat");
            return;
        }

        if (!dueDate.isAfter(borrowDate)) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=confirm&id=" + recordId + "&error=dateOrder");
            return;
        }

        boolean ok = borrowDAO.librarianConfirm(recordId, copyId, borrowDate, dueDate, libNote, loggedUser.getId());
        if (ok) {
            // Cập nhật trạng thái bản sao → BORROWED
            borrowDAO.updateCopyStatusBorrowed(copyId);
            resp.sendRedirect(req.getContextPath() + "/borrow?action=detail&id=" + recordId + "&success=confirmed");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=confirm&id=" + recordId + "&error=confirmFail");
        }
    }

    /** LIBRARIAN từ chối phiếu mượn. */
    private void handleLibrarianReject(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws IOException {

        if (!loggedUser.isAdminOrLibrarian()) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list");
            return;
        }

        int recordId = parseId(req.getParameter("recordId"));
        String libNote = trim(req.getParameter("librarianNote"));

        boolean ok = borrowDAO.librarianReject(recordId, libNote, loggedUser.getId());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=list&success=rejected");
        } else {
            resp.sendRedirect(req.getContextPath() + "/borrow?action=confirm&id=" + recordId + "&error=rejectFail");
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

    private int parsePage(String s) {
        if (s == null) return 1;
        try { int p = Integer.parseInt(s); return p > 0 ? p : 1; }
        catch (NumberFormatException e) { return 1; }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
