package com.swp391.servlet;

import com.swp391.dao.UserDAO;
import com.swp391.dao.UserDAOImpl;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

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

        String q = request.getParameter("q");
        String role = request.getParameter("role");
        String activeParam = request.getParameter("active");
        Integer active = null;
        if (activeParam != null && !activeParam.isEmpty()) {
            try { active = Integer.parseInt(activeParam); } catch (NumberFormatException e) { active = null; }
        }

        try {
            UserDAO dao = new UserDAOImpl();
            request.setAttribute("users", dao.searchUsers(q, role, active));
            request.setAttribute("q", q);
            request.setAttribute("roleFilter", role);
            request.setAttribute("activeFilter", active);
        } catch (Exception e) {
            request.setAttribute("error", "Không thể tải danh sách người dùng: " + e.getMessage());
        }

        request.setAttribute("activeTab", "users");
        request.getRequestDispatcher("/admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String action = request.getParameter("action");
        try {
            UserDAO dao = new UserDAOImpl();
            if ("create".equals(action)) {
                User u = new User();
                u.setUsername(request.getParameter("username"));
                u.setFullName(request.getParameter("fullName"));
                u.setEmail(request.getParameter("email"));
                u.setPhone(request.getParameter("phone"));
                u.setStudentId(request.getParameter("studentId"));
                u.setAvatar(request.getParameter("avatar"));
                u.setRole(request.getParameter("role"));
                u.setActive(1);
                String rawPassword = request.getParameter("password");
                if (rawPassword == null || rawPassword.isEmpty()) rawPassword = "password";
                String hashed = hashPassword(rawPassword);
                int newId = dao.createUser(u, hashed);
                if (newId > 0) request.setAttribute("success", "Tạo người dùng thành công.");
                else request.setAttribute("error", "Tạo người dùng thất bại.");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = dao.deleteUser(id);
                if (ok) request.setAttribute("success", "Xóa người dùng thành công.");
                else request.setAttribute("error", "Xóa thất bại.");
            } else if ("lock".equals(action) || "unlock".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int active = "unlock".equals(action) ? 1 : 0;
                boolean ok = dao.setActive(id, active);
                if (ok) request.setAttribute("success", "Thao tác thành công.");
                else request.setAttribute("error", "Thao tác thất bại.");
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                User u = dao.getUserById(id);
                u.setFullName(request.getParameter("fullName"));
                u.setEmail(request.getParameter("email"));
                u.setPhone(request.getParameter("phone"));
                u.setStudentId(request.getParameter("studentId"));
                u.setAvatar(request.getParameter("avatar"));
                u.setRole(request.getParameter("role"));
                try { u.setActive(Integer.parseInt(request.getParameter("active"))); } catch (Exception ex) {}
                boolean ok = dao.updateUser(u);
                if (ok) request.setAttribute("success", "Cập nhật thành công.");
                else request.setAttribute("error", "Cập nhật thất bại.");
                String newPassword = request.getParameter("password");
                if (newPassword != null && !newPassword.isEmpty()) {
                    dao.updatePassword(id, hashPassword(newPassword));
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi: " + e.getMessage());
        }

        // After action redirect back to admin page
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private String hashPassword(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("MD5 not available", e);
        }
    }
}

