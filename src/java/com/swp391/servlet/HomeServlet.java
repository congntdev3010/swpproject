package com.swp391.servlet;

import com.swp391.dao.BookDAO;
import com.swp391.dao.BookDAOImpl;
import com.swp391.model.Book;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

/**
 * HomeServlet – xử lý trang chủ.
 * URL: /home
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home", "/Home"})
public class HomeServlet extends HttpServlet {

    private static final int FEATURED_BOOKS_LIMIT = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "home");
        request.setAttribute("pageTitle", "Trang chủ – FPT Library");
        request.setAttribute("pageDesc",
            "Hệ thống thư viện FPT University – Khám phá kho tàng tri thức với hàng ngàn đầu sách học thuật");

        try {
            BookDAO bookDAO = new BookDAOImpl();
            List<Book> featuredBooks = bookDAO.getNewestBooks(FEATURED_BOOKS_LIMIT);
            int totalBooks = bookDAO.countBooks(null, null);
            List<String> categories = bookDAO.getAllCategories();

            request.setAttribute("featuredBooks", featuredBooks);
            request.setAttribute("totalBooks", totalBooks);
            request.setAttribute("totalCategories", categories.size());
        } catch (Exception e) {
            // Không để crash trang chủ nếu DB lỗi
            request.setAttribute("dbError", "Không thể tải dữ liệu sách: " + e.getMessage());
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
