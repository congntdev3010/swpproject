package com.swp391.servlet;

import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.BorrowRecordDAO;
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

@WebServlet("/admin/reservation")
public class AdminReservationServlet extends HttpServlet {

    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();
    private final BookCopyDAO copyDAO = new BookCopyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        String q = request.getParameter("q");
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (Exception ignored) {}
        }
        
        int pageSize = 10;
        
        List<BorrowRecord> pendingRecords = borrowDAO.getAll("PENDING", q, page, pageSize);
        int total = borrowDAO.countAll("PENDING", q);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        request.setAttribute("reservations", pendingRecords);
        request.setAttribute("q", q);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        String action = request.getParameter("action");
        int recordId;
        try {
            recordId = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/reservation?error=Invalid ID");
            return;
        }

        BorrowRecord record = borrowDAO.getById(recordId);
        if (record == null || !"PENDING".equals(record.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/admin/reservation?error=Đơn mượn không tồn tại hoặc đã xử lý");
            return;
        }

        if ("approve".equals(action)) {
            List<BookCopy> availableCopies = copyDAO.getAvailableCopiesByBookId(record.getBookId());
            if (availableCopies == null || availableCopies.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/reservation?error=Hết sách trong kho để duyệt");
                return;
            }
            
            int copyId = availableCopies.get(0).getId();
            LocalDate borrowDate = LocalDate.now();
            LocalDate dueDate = borrowDate.plusDays(14); // default 14 days
            
            boolean ok = borrowDAO.librarianConfirm(recordId, copyId, borrowDate, dueDate, "Duyệt nhanh từ Admin", logged.getId());
            if (ok) {
                borrowDAO.updateCopyStatusBorrowed(copyId);
                response.sendRedirect(request.getContextPath() + "/admin/reservation?success=Đã duyệt đơn thành công");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/reservation?error=Lỗi khi duyệt đơn");
            }
        } else if ("reject".equals(action)) {
            boolean ok = borrowDAO.librarianReject(recordId, "Từ chối từ Admin", logged.getId());
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/reservation?success=Đã từ chối đơn mượn");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/reservation?error=Lỗi khi từ chối đơn");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/reservation");
        }
    }
}
