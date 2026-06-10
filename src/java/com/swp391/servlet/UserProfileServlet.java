package com.swp391.servlet;

import com.swp391.dao.UserDAO;
import com.swp391.dao.UserDAOImpl;
import com.swp391.model.User;
import com.swp391.util.BCrypt;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import java.io.IOException;
import java.io.File;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "UserProfileServlet", urlPatterns = {"/user/profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
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
            try { 
                id = Integer.parseInt(idParam); 
                if (logged.getId() != id) {
                    isAdminEditingOther = true; 
                }
            } catch (NumberFormatException e) { }
        }

        String action = request.getParameter("action");

        try {
            UserDAO dao = new UserDAOImpl();
            User user = dao.getUserById(id);
            if (user == null) {
                request.setAttribute("error", "Người dùng không tồn tại.");
                doGet(request, response);
                return;
            }

            if ("updateProfile".equals(action)) {
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String studentId = request.getParameter("studentId");
                String avatar = request.getParameter("avatar");
                String role = request.getParameter("role");
                String activeParam = request.getParameter("active");
                int active = 1;
                try { if (activeParam != null) active = Integer.parseInt(activeParam); } catch (NumberFormatException e) {}

                // Handle file upload for avatar
                Part filePart = request.getPart("avatarFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = getFileName(filePart);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Unique name
                        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                        // Path inside the deployed web application
                        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "uploads";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdir();
                        }
                        // Write the file
                        filePart.write(uploadPath + File.separator + uniqueFileName);
                        // Store the relative path in the database
                        avatar = request.getContextPath() + "/uploads/" + uniqueFileName;
                    }
                }

                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setStudentId(studentId);
                user.setAvatar(avatar);

                // Only admin can change role/active for other users
                if (logged.isAdmin()) {
                    if (role != null) user.setRole(role);
                    user.setActive(active);
                }

                boolean ok = dao.updateUser(user);
                if (ok) {
                    request.setAttribute("success", "Cập nhật thông tin cá nhân thành công.");
                    // Refresh session if logged user updated themselves
                    if (!isAdminEditingOther) {
                        session.setAttribute("loggedUser", user);
                    }
                } else {
                    request.setAttribute("error", "Cập nhật thông tin thất bại.");
                }

            } else if ("changePassword".equals(action)) {
                String oldPassword = request.getParameter("oldPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (newPassword == null || newPassword.trim().isEmpty() ||
                    confirmPassword == null || confirmPassword.trim().isEmpty()) {
                    request.setAttribute("error", "Vui lòng nhập mật khẩu mới.");
                } else if (!newPassword.equals(confirmPassword)) {
                    request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
                } else {
                    // Check old password only if user is changing their own password
                    boolean canChange = true;
                    if (!isAdminEditingOther) {
                        if (oldPassword == null || oldPassword.isEmpty()) {
                            request.setAttribute("error", "Vui lòng nhập mật khẩu cũ để xác thực.");
                            canChange = false;
                        } else if (!checkPassword(oldPassword, user.getPassword())) {
                            request.setAttribute("error", "Mật khẩu cũ không chính xác.");
                            canChange = false;
                        }
                    }

                    if (canChange) {
                        String hashed = hashPassword(newPassword);
                        boolean ok = dao.updatePassword(id, hashed);
                        if (ok) {
                            request.setAttribute("success", "Đổi mật khẩu thành công.");
                            // Refresh the cached password in session if updating own profile
                            if (!isAdminEditingOther) {
                                user.setPassword(hashed);
                                session.setAttribute("loggedUser", user);
                            }
                        } else {
                            request.setAttribute("error", "Cập nhật mật khẩu thất bại.");
                        }
                    }
                }
            }

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi xử lý: " + e.getMessage());
        }

        doGet(request, response);
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }

    private boolean checkPassword(String raw, String hashed) {
        if (raw == null || hashed == null) return false;
        if (hashed.startsWith("$2")) {
            return BCrypt.checkpw(raw, hashed);
        }
        return hashPassword(raw).equals(hashed);
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
