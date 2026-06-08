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

@WebServlet(name = "UserProfileServlet", urlPatterns = {"/user/profile"})
public class UserProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User logged = (User) session.getAttribute("loggedUser");
        String idParam = request.getParameter("id");
        int id = logged.getId();
        // if admin and id param provided, allow viewing other user
        if (idParam != null && logged.isAdmin()) {
            try { id = Integer.parseInt(idParam); } catch (NumberFormatException e) { /* ignore */ }
        }

        try {
            UserDAO dao = new UserDAOImpl();
            User user = dao.getUserById(id);
            request.setAttribute("profileUser", user);
        } catch (Exception e) {
            request.setAttribute("error", "Không thể tải thông tin người dùng: " + e.getMessage());
        }
        request.getRequestDispatcher("/user_profile.jsp").forward(request, response);
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
        String idParam = request.getParameter("id");
        int id = logged.getId();
        boolean isAdminEditingOther = false;
        if (idParam != null && logged.isAdmin()) {
            try { id = Integer.parseInt(idParam); isAdminEditingOther = true; } catch (NumberFormatException e) { }
        }

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String studentId = request.getParameter("studentId");
        String avatar = request.getParameter("avatar");
        String role = request.getParameter("role");
        String activeParam = request.getParameter("active");
        int active = 1;
        try { if (activeParam != null) active = Integer.parseInt(activeParam); } catch (NumberFormatException e) {}

        String newPassword = request.getParameter("newPassword");

        try {
            UserDAO dao = new UserDAOImpl();
            User user = dao.getUserById(id);
            if (user == null) {
                request.setAttribute("error", "Người dùng không tồn tại.");
            } else {
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setStudentId(studentId);
                user.setAvatar(avatar);
                // only admin can change role/active for other users
                if (logged.isAdmin()) {
                    if (role != null) user.setRole(role);
                    user.setActive(active);
                }
                boolean ok = dao.updateUser(user);
                if (!ok) request.setAttribute("error", "Cập nhật thất bại.");
                else request.setAttribute("success", "Cập nhật thành công.");
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    String hashed = hashPassword(newPassword);
                    dao.updatePassword(id, hashed);
                    request.setAttribute("success", "Cập nhật thành công (mật khẩu đã được thay đổi).");
                }
                // if the logged user updated themselves, refresh session
                if (!isAdminEditingOther && logged.getId() == id) {
                    User refreshed = dao.getUserById(id);
                    session.setAttribute("loggedUser", refreshed);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi khi cập nhật: " + e.getMessage());
        }

        doGet(request, response);
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

