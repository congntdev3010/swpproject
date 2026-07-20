package com.swp391.servlet;

import com.swp391.dao.UserDAO;
import com.swp391.dao.UserDAOImpl;
import com.swp391.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "UserListServlet", urlPatterns = {"/users"})
public class UserListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 15;

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

        // Sorting params (for UI consistency with author/category)
        String sortField = request.getParameter("sort");
        String sortOrder = request.getParameter("order");
        if (sortField == null || sortField.isEmpty()) sortField = "username";
        if (!"DESC".equalsIgnoreCase(sortOrder)) sortOrder = "ASC";

        // Pagination
        int page = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) page = Integer.parseInt(pageParam);
        } catch (NumberFormatException ignored) {}
        if (page < 1) page = 1;

        try {
            UserDAO dao = new UserDAOImpl();
            List<User> users = dao.searchUsers(q, role, active);
            int totalRecords = users.size();
            int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
            if (page > totalPages) page = totalPages;

            // Manual pagination (slice the list)
            int fromIdx = (page - 1) * PAGE_SIZE;
            int toIdx   = Math.min(fromIdx + PAGE_SIZE, totalRecords);
            List<User> pageUsers = (fromIdx < totalRecords) ? users.subList(fromIdx, toIdx) : users;

            request.setAttribute("users", pageUsers);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPageNum", page);
            request.setAttribute("q", q != null ? q : "");
            request.setAttribute("roleFilter", role);
            request.setAttribute("activeFilter", active);
            request.setAttribute("sortField", sortField);
            request.setAttribute("sortOrder", sortOrder);
            request.setAttribute("currentPage", "users");
        } catch (Exception e) {
            request.setAttribute("error", "Không thể tải danh sách người dùng: " + e.getMessage());
        }

        request.getRequestDispatcher("/users.jsp").forward(request, response);
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
        if (!logged.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        try {
            UserDAO dao = new UserDAOImpl();
            if ("create".equals(action)) {
                String username = request.getParameter("username");
                if (username == null || username.trim().isEmpty()) {
                    session.setAttribute("errorMsg", "Tên đăng nhập không được để trống.");
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }
                username = username.trim();
                
                if (dao.getUserByUsername(username) != null) {
                    session.setAttribute("errorMsg", "Tên đăng nhập đã tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

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
                if (newId > 0) session.setAttribute("successMsg", "Tạo người dùng thành công.");
                else session.setAttribute("errorMsg", "Tạo người dùng thất bại.");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = dao.deleteUser(id);
                if (ok) session.setAttribute("successMsg", "Xóa người dùng thành công.");
                else session.setAttribute("errorMsg", "Xóa thất bại.");
            } else if ("lock".equals(action) || "unlock".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int active = "unlock".equals(action) ? 1 : 0;
                boolean ok = dao.setActive(id, active);
                if (ok) session.setAttribute("successMsg", "Thao tác thành công.");
                else session.setAttribute("errorMsg", "Thao tác thất bại.");
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
                if (ok) session.setAttribute("successMsg", "Cập nhật thành công.");
                else session.setAttribute("errorMsg", "Cập nhật thất bại.");
                String newPassword = request.getParameter("password");
                if (newPassword != null && !newPassword.isEmpty()) {
                    dao.updatePassword(id, hashPassword(newPassword));
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }

        // After action redirect back to users page
        response.sendRedirect(request.getContextPath() + "/users");
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
