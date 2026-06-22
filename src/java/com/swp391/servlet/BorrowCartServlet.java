package com.swp391.servlet;

import com.swp391.dao.BookCopyDAO;
import com.swp391.dao.BookDAO;
import com.swp391.dao.BookDAOImpl;
import com.swp391.dao.BorrowRecordDAO;
import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import com.swp391.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/borrow-cart")
public class BorrowCartServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAOImpl();
    private final BookCopyDAO copyDAO = new BookCopyDAO();
    private final BorrowRecordDAO borrowDAO = new BorrowRecordDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("view".equals(action)) {
            handleViewCart(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "add":
                handleAdd(request, response);
                break;
            case "remove":
                handleRemove(request, response);
                break;
            case "checkout":
                handleCheckout(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                break;
        }
    }

    private void handleViewCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            out.print("{\"status\":\"error\", \"message\":\"Bạn cần đăng nhập để xem giỏ hàng.\"}");
            out.flush();
            return;
        }

        Map<Integer, Book> cart = (Map<Integer, Book>) session.getAttribute("borrowCart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        List<Book> cartItems = new ArrayList<>(cart.values());
        StringBuilder jsonCart = new StringBuilder("[");
        for (int i = 0; i < cartItems.size(); i++) {
            Book b = cartItems.get(i);
            String safeTitle = b.getTitle() != null ? b.getTitle().replace("\"", "\\\"").replace("\n", " ") : "";
            jsonCart.append("{\"id\":").append(b.getId())
                    .append(", \"title\":\"").append(safeTitle).append("\"}");
            if (i < cartItems.size() - 1) {
                jsonCart.append(",");
            }
        }
        jsonCart.append("]");

        out.print("{\"status\":\"success\", \"cart\":" + jsonCart.toString() + "}");
        out.flush();
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            out.print("{\"status\":\"error\", \"message\":\"Bạn cần đăng nhập để mượn sách.\"}");
            out.flush();
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(request.getParameter("bookId"));
        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\", \"message\":\"ID sách không hợp lệ.\"}");
            out.flush();
            return;
        }

        try {
            Book book = bookDAO.findById(bookId);
            if (book == null) {
                out.print("{\"status\":\"error\", \"message\":\"Không tìm thấy sách.\"}");
                out.flush();
                return;
            }

            Map<Integer, Book> cart = (Map<Integer, Book>) session.getAttribute("borrowCart");
            if (cart == null) {
                cart = new HashMap<>();
            }

            if (cart.containsKey(bookId)) {
                out.print("{\"status\":\"info\", \"message\":\"Sách đã có trong danh sách mượn.\"}");
                out.flush();
                return;
            }

            cart.put(bookId, book);
            session.setAttribute("borrowCart", cart);

            out.print("{\"status\":\"success\", \"message\":\"Đã thêm sách vào danh sách mượn.\", \"cartCount\":" + cart.size() + "}");
            out.flush();

        } catch (Exception e) {
            out.print("{\"status\":\"error\", \"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
            out.flush();
        }
    }

    private void handleRemove(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            out.print("{\"status\":\"error\", \"message\":\"Bạn cần đăng nhập.\"}");
            out.flush();
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(request.getParameter("bookId"));
        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\", \"message\":\"ID sách không hợp lệ.\"}");
            out.flush();
            return;
        }

        Map<Integer, Book> cart = (Map<Integer, Book>) session.getAttribute("borrowCart");
        if (cart != null) {
            cart.remove(bookId);
            session.setAttribute("borrowCart", cart);
            out.print("{\"status\":\"success\", \"message\":\"Đã xóa sách khỏi danh sách mượn.\", \"cartCount\":" + cart.size() + "}");
        } else {
            out.print("{\"status\":\"success\", \"message\":\"Đã xóa sách khỏi danh sách mượn.\", \"cartCount\":0}");
        }
        out.flush();
    }

    private void handleCheckout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            out.print("{\"status\":\"error\", \"message\":\"Bạn cần đăng nhập để xác nhận mượn.\"}");
            out.flush();
            return;
        }
        User loggedUser = (User) session.getAttribute("loggedUser");

        Map<Integer, Book> cart = (Map<Integer, Book>) session.getAttribute("borrowCart");
        if (cart == null || cart.isEmpty()) {
            out.print("{\"status\":\"error\", \"message\":\"Danh sách mượn trống.\"}");
            out.flush();
            return;
        }

        List<String> successMessages = new ArrayList<>();
        List<String> errorMessages = new ArrayList<>();
        List<Integer> successBookIds = new ArrayList<>();

        for (Map.Entry<Integer, Book> entry : cart.entrySet()) {
            int bookId = entry.getKey();
            Book book = entry.getValue();

            // Check if there are available copies
            List<BookCopy> availableCopies = copyDAO.getAvailableCopiesByBookId(bookId);
            if (availableCopies == null || availableCopies.isEmpty()) {
                errorMessages.add("Sách '" + book.getTitle() + "' hiện đã hết bản sao hoặc bị hỏng.");
                continue;
            }

            // Create pending borrow record
            int recordId = borrowDAO.createBorrowRecord(loggedUser.getId(), bookId, "Tạo từ giỏ hàng");
            if (recordId > 0) {
                successMessages.add("Sách '" + book.getTitle() + "' đã được tạo đơn mượn.");
                successBookIds.add(bookId);
            } else {
                errorMessages.add("Không thể tạo đơn mượn cho sách '" + book.getTitle() + "'.");
            }
        }

        // Remove successful items from cart
        for (int id : successBookIds) {
            cart.remove(id);
        }
        session.setAttribute("borrowCart", cart);

        if (successBookIds.isEmpty()) {
            String safeError = String.join(" ", errorMessages).replace("\"", "\\\"").replace("\n", " ");
            out.print("{\"status\":\"error\", \"message\":\"Tạo đơn thất bại: " + safeError + "\"}");
        } else {
            String safeMessage = ("Đã tạo đơn mượn sách thành công! " + String.join(" ", errorMessages)).replace("\"", "\\\"").replace("\n", " ");
            out.print("{\"status\":\"success\", \"message\":\"" + safeMessage + "\"}");
        }
        
        out.flush();
    }
}
