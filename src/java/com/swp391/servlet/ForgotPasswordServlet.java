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

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Simple input validation
        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("error", "Vui lòng nhập đầy đủ tất cả các trường.");
            request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
            return;
        }

        try {
            UserDAO dao = new UserDAOImpl();
            User user = dao.getUserByUsername(username);

            if (user == null) {
                request.setAttribute("error", "Tên đăng nhập không tồn tại.");
                request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
                return;
            }

            if (user.getEmail() == null || !user.getEmail().trim().equalsIgnoreCase(email.trim())) {
                request.setAttribute("error", "Email không đúng với email đăng ký của tài khoản này.");
                request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
                return;
            }

            // Perform password hashing and update in DB
            String hashed = hashPassword(newPassword);
            boolean success = dao.updatePassword(user.getId(), hashed);

            if (success) {
                request.setAttribute("success", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không thể cập nhật mật khẩu mới vào cơ sở dữ liệu.");
                request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi máy chủ: " + e.getMessage());
            request.getRequestDispatcher("/forgotpassword.jsp").forward(request, response);
        }
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
