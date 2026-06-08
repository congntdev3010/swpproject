package com.swp391.servlet;

import com.swp391.dao.UserDAO;
import com.swp391.dao.UserDAOImpl;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserListServlet", urlPatterns = {"/users"})
public class UserListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String q = request.getParameter("q");
        String role = request.getParameter("role");
        String activeParam = request.getParameter("active");
        Integer active = null;
        if (activeParam != null && !activeParam.isEmpty()) {
            try { active = Integer.parseInt(activeParam); } catch (NumberFormatException e) { active = null; }
        }

        try {
            UserDAO dao = new UserDAOImpl();
            List<User> users = dao.searchUsers(q, role, active);
            request.setAttribute("users", users);
            request.setAttribute("q", q);
            request.setAttribute("roleFilter", role);
            request.setAttribute("activeFilter", active);
        } catch (Exception e) {
            request.setAttribute("error", "Không thể tải danh sách người dùng: " + e.getMessage());
        }

        request.getRequestDispatcher("/users.jsp").forward(request, response);
    }
}

