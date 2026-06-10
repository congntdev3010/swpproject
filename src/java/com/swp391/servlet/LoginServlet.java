package com.swp391.servlet;

import com.swp391.dao.DBContext;
import com.swp391.dao.UserDAO;
import com.swp391.dao.UserDAOImpl;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import com.swp391.util.BCrypt;
import java.io.Console;
import java.sql.Connection;
import java.sql.SQLException;

    @WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        
        try {
            UserDAO dao = new UserDAOImpl();
            User user = dao.getUserByUsername(username);
            if (user != null && user.getPassword() != null && checkPassword(password, user.getPassword())) {
                // login success
                HttpSession session = request.getSession();
                session.setAttribute("loggedUser", user);
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            } else {
                request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi máy chủ: " + e.getMessage());
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
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

    private boolean checkPassword(String raw, String hashed) {
        if (raw == null || hashed == null) return false;
        // If the stored hash is a bcrypt hash ($2a/$2b/$2y), verify with BCrypt
        if (hashed.startsWith("$2")) {
            return BCrypt.checkpw(raw, hashed);
        }
        // Fallback: legacy MD5 comparison
        return hashPassword(raw).equals(hashed);
    }
    
}

