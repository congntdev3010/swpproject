package com.swp391.servlet;

import com.swp391.dao.AuthorDAO;
import com.swp391.dao.AuthorDAOImpl;
import com.swp391.model.Author;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import com.swp391.util.UploadUtility;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AuthorServlet", urlPatterns = {
    "/authors", "/author/add", "/author/edit", "/author/delete"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AuthorServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private final AuthorDAO authorDAO = new AuthorDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Authentication & Authorization check
        HttpSession session = request.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // View is allowed for both ADMIN and LIBRARIAN
        if (!loggedUser.isAdminOrLibrarian()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        switch (path) {
            case "/authors":
                showList(request, response);
                break;
            case "/author/add":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền thêm tác giả.");
                    return;
                }
                showAddForm(request, response);
                break;
            case "/author/edit":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền chỉnh sửa tác giả.");
                    return;
                }
                showEditForm(request, response);
                break;
            case "/author/delete":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền xóa tác giả.");
                    return;
                }
                processDelete(request, response, loggedUser.getUsername());
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/authors");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null || !loggedUser.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            processCreate(request, response, loggedUser.getUsername());
        } else if ("update".equals(action)) {
            processUpdate(request, response, loggedUser.getUsername());
        } else {
            response.sendRedirect(request.getContextPath() + "/authors");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "authors");
        request.setAttribute("pageTitle", "Quản lý Tác giả – FPT Library");

        String keyword = trim(request.getParameter("keyword"));
        String sort = trim(request.getParameter("sort"));
        String order = trim(request.getParameter("order"));

        if (sort == null || sort.isEmpty()) sort = "name";
        if (order == null || order.isEmpty()) order = "ASC";

        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p.trim()));
        } catch (NumberFormatException ignored) {}

        try {
            List<Author> list = authorDAO.search(keyword, sort, order, page, PAGE_SIZE);
            int totalRecords = authorDAO.count(keyword);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            request.setAttribute("authors", list);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPageNum", page);
            request.setAttribute("keyword", keyword != null ? keyword : "");
            request.setAttribute("sortField", sort);
            request.setAttribute("sortOrder", order);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/author_list.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "authors");
        request.setAttribute("pageTitle", "Thêm tác giả mới – FPT Library");
        request.setAttribute("formMode", "add");
        request.getRequestDispatcher("/author_form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "authors");
        request.setAttribute("pageTitle", "Chỉnh sửa tác giả – FPT Library");
        request.setAttribute("formMode", "edit");

        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/authors");
            return;
        }

        try {
            Author author = authorDAO.findById(id);
            if (author == null) {
                request.getSession().setAttribute("errorMsg", "Không tìm thấy tác giả với ID: " + id);
                response.sendRedirect(request.getContextPath() + "/authors");
                return;
            }
            request.setAttribute("author", author);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/author_form.jsp").forward(request, response);
    }

    private void processCreate(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        String name = trim(request.getParameter("name"));
        String nationality = trim(request.getParameter("nationality"));
        String birthDateStr = trim(request.getParameter("birthDate"));
        String bio = trim(request.getParameter("bio"));
        
        // Handle avatar upload using UploadUtility
        String avatarUrl = trim(request.getParameter("existingAvatarUrl"));
        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0) {
                String savedPath = UploadUtility.saveFile(filePart, request.getServletContext());
                if (savedPath != null) {
                    avatarUrl = savedPath;
                }
            }
        } catch (Exception e) {
            // Log or ignore
        }

        Author author = new Author();
        author.setName(name);
        author.setNationality(nationality);
        author.setBio(bio);
        author.setAvatarUrl(avatarUrl);
        author.setCreatedBy(username);

        LocalDate birthDate = null;
        List<String> errors = new ArrayList<>();

        if (name == null || name.isEmpty()) {
            errors.add("Tên tác giả không được để trống.");
        } else if (name.length() > 150) {
            errors.add("Tên tác giả không được vượt quá 150 ký tự.");
        } else {
            try {
                if (authorDAO.isNameExists(name)) {
                    errors.add("Tên tác giả '" + name + "' đã tồn tại.");
                }
            } catch (Exception e) {
                errors.add("Lỗi kiểm tra trùng tên: " + e.getMessage());
            }
        }

        if (nationality != null && nationality.length() > 100) {
            errors.add("Quốc tịch không được vượt quá 100 ký tự.");
        }

        if (birthDateStr != null && !birthDateStr.isEmpty()) {
            try {
                birthDate = LocalDate.parse(birthDateStr);
                if (birthDate.isAfter(LocalDate.now())) {
                    errors.add("Ngày sinh không được lớn hơn ngày hiện tại.");
                }
                author.setBirthDate(birthDate);
            } catch (DateTimeParseException e) {
                errors.add("Định dạng ngày sinh không hợp lệ (yyyy-MM-dd).");
            }
        }

        if (bio != null && bio.length() > 5000) {
            errors.add("Tiểu sử không được vượt quá 5000 ký tự.");
        }

        if (avatarUrl != null && avatarUrl.length() > 500) {
            errors.add("Đường dẫn ảnh đại diện không được vượt quá 500 ký tự.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("author", author);
            request.setAttribute("formMode", "add");
            request.setAttribute("pageTitle", "Thêm tác giả mới – FPT Library");
            request.getRequestDispatcher("/author_form.jsp").forward(request, response);
            return;
        }

        try {
            Author created = authorDAO.create(author);
            if (created != null) {
                request.getSession().setAttribute("successMsg", "Thêm tác giả thành công!");
                response.sendRedirect(request.getContextPath() + "/authors");
            } else {
                request.setAttribute("errorMsg", "Không thể tạo tác giả, vui lòng thử lại.");
                request.setAttribute("author", author);
                request.setAttribute("formMode", "add");
                request.getRequestDispatcher("/author_form.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tạo tác giả: " + e.getMessage());
            request.setAttribute("author", author);
            request.setAttribute("formMode", "add");
            request.getRequestDispatcher("/author_form.jsp").forward(request, response);
        }
    }

    private void processUpdate(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/authors");
            return;
        }

        String name = trim(request.getParameter("name"));
        String nationality = trim(request.getParameter("nationality"));
        String birthDateStr = trim(request.getParameter("birthDate"));
        String bio = trim(request.getParameter("bio"));
        
        // Handle avatar upload using UploadUtility
        String avatarUrl = trim(request.getParameter("existingAvatarUrl"));
        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0) {
                String savedPath = UploadUtility.saveFile(filePart, request.getServletContext());
                if (savedPath != null) {
                    avatarUrl = savedPath;
                }
            }
        } catch (Exception e) {
            // Log or ignore
        }

        Author author = new Author();
        author.setId(id);
        author.setName(name);
        author.setNationality(nationality);
        author.setBio(bio);
        author.setAvatarUrl(avatarUrl);
        author.setUpdatedBy(username);

        LocalDate birthDate = null;
        List<String> errors = new ArrayList<>();

        if (name == null || name.isEmpty()) {
            errors.add("Tên tác giả không được để trống.");
        } else if (name.length() > 150) {
            errors.add("Tên tác giả không được vượt quá 150 ký tự.");
        } else {
            try {
                if (authorDAO.isNameExistsExcluding(name, id)) {
                    errors.add("Tên tác giả '" + name + "' đã tồn tại ở bản ghi khác.");
                }
            } catch (Exception e) {
                errors.add("Lỗi kiểm tra trùng tên: " + e.getMessage());
            }
        }

        if (nationality != null && nationality.length() > 100) {
            errors.add("Quốc tịch không được vượt quá 100 ký tự.");
        }

        if (birthDateStr != null && !birthDateStr.isEmpty()) {
            try {
                birthDate = LocalDate.parse(birthDateStr);
                if (birthDate.isAfter(LocalDate.now())) {
                    errors.add("Ngày sinh không được lớn hơn ngày hiện tại.");
                }
                author.setBirthDate(birthDate);
            } catch (DateTimeParseException e) {
                errors.add("Định dạng ngày sinh không hợp lệ (yyyy-MM-dd).");
            }
        }

        if (bio != null && bio.length() > 5000) {
            errors.add("Tiểu sử không được vượt quá 5000 ký tự.");
        }

        if (avatarUrl != null && avatarUrl.length() > 500) {
            errors.add("Đường dẫn ảnh đại diện không được vượt quá 500 ký tự.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("author", author);
            request.setAttribute("formMode", "edit");
            request.setAttribute("pageTitle", "Chỉnh sửa tác giả – FPT Library");
            request.getRequestDispatcher("/author_form.jsp").forward(request, response);
            return;
        }

        try {
            boolean updated = authorDAO.update(author);
            if (updated) {
                request.getSession().setAttribute("successMsg", "Cập nhật thông tin tác giả thành công!");
                response.sendRedirect(request.getContextPath() + "/authors");
            } else {
                request.setAttribute("errorMsg", "Không thể cập nhật thông tin tác giả, vui lòng thử lại.");
                request.setAttribute("author", author);
                request.setAttribute("formMode", "edit");
                request.getRequestDispatcher("/author_form.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi cập nhật tác giả: " + e.getMessage());
            request.setAttribute("author", author);
            request.setAttribute("formMode", "edit");
            request.getRequestDispatcher("/author_form.jsp").forward(request, response);
        }
    }

    private void processDelete(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/authors");
            return;
        }

        try {
            boolean hasBooks = authorDAO.hasActiveBooks(id);
            if (hasBooks) {
                request.getSession().setAttribute("errorMsg", "Không thể xóa tác giả này vì đang có các đầu sách thuộc về họ.");
                response.sendRedirect(request.getContextPath() + "/authors");
                return;
            }

            boolean deleted = authorDAO.delete(id, username);
            if (deleted) {
                request.getSession().setAttribute("successMsg", "Xóa tác giả thành công!");
            } else {
                request.getSession().setAttribute("errorMsg", "Không thể xóa tác giả hoặc tác giả đã bị xóa trước đó.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMsg", "Lỗi xảy ra khi xóa tác giả: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/authors");
    }

    private int parseId(String s) {
        if (s == null || s.trim().isEmpty()) return -1;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; }
    }

    private String trim(String s) {
        return (s != null) ? s.trim() : null;
    }
}
