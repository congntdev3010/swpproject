package com.swp391.servlet;

import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

/**
 * AdminServlet – xử lý URL /admin.
 * Redirect admin/librarian về trang quản lý người dùng mặc định.
 */
@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {

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
        // Redirect về trang quản lý người dùng
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
