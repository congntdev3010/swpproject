package com.swp391.servlet;

import com.swp391.dao.BookDAO;
import com.swp391.dao.BookDAOImpl;
import com.swp391.model.Book;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;


@WebServlet(name = "BookListServlet", urlPatterns = {"/books", "/Books"})
public class BookListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "books");
        request.setAttribute("pageTitle", "Danh sách sách – FPT Library");
        request.setAttribute("pageDesc",
            "Tìm kiếm và khám phá hàng trăm đầu sách học thuật trong thư viện FPT University.");

        // ---- Đọc tham số ----
        String keyword  = trim(request.getParameter("keyword"));
        String category = trim(request.getParameter("category"));
        String sort     = trim(request.getParameter("sort"));
        String order    = trim(request.getParameter("order"));
        String view     = trim(request.getParameter("view"));

        if (sort  == null || sort.isEmpty())  sort  = "title";
        if (order == null || order.isEmpty()) order = "ASC";
        if (view  == null || view.isEmpty())  view  = "grid";

        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p.trim()));
        } catch (NumberFormatException ignored) {}

        // ---- Gọi DAO ----
        try {
            BookDAO dao = new BookDAOImpl();

            List<Book> books = dao.searchBooks(keyword, category, sort, order, page, PAGE_SIZE);
            int totalRecords = dao.countBooks(keyword, category);
            int totalPages   = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<String> categories = dao.getAllCategories();

            // ---- Set attributes ----
            request.setAttribute("books",            books);
            request.setAttribute("totalRecords",     totalRecords);
            request.setAttribute("totalPages",       totalPages);
            request.setAttribute("currentPageNum",   page);
            request.setAttribute("categories",       categories);
            request.setAttribute("keyword",          keyword != null ? keyword : "");
            request.setAttribute("selectedCategory", category != null ? category : "");
            request.setAttribute("sortField",        sort);
            request.setAttribute("sortOrder",        order);
            request.setAttribute("viewMode",         view);
            request.setAttribute("pageSize",         PAGE_SIZE);

        } catch (Exception e) {
            request.setAttribute("dbError", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/books.jsp").forward(request, response);
    }

    /** Hỗ trợ form POST (trường hợp submit từ form search). */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private String trim(String s) {
        return (s != null) ? s.trim() : null;
    }
}
