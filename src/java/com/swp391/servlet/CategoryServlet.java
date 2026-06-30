package com.swp391.servlet;

import com.swp391.dao.CategoryDAO;
import com.swp391.dao.CategoryDAOImpl;
import com.swp391.model.Category;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CategoryServlet", urlPatterns = {
    "/categories", "/category/add", "/category/edit", "/category/delete"
})
public class CategoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private final CategoryDAO categoryDAO = new CategoryDAOImpl();

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
            case "/categories":
                showList(request, response);
                break;
            case "/category/add":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền thêm danh mục.");
                    return;
                }
                showAddForm(request, response);
                break;
            case "/category/edit":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền chỉnh sửa danh mục.");
                    return;
                }
                showEditForm(request, response);
                break;
            case "/category/delete":
                if (!loggedUser.isAdmin()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Admin mới có quyền xóa danh mục.");
                    return;
                }
                processDelete(request, response, loggedUser.getUsername());
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/categories");
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
            response.sendRedirect(request.getContextPath() + "/categories");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "categories");
        request.setAttribute("pageTitle", "Quản lý Danh mục – FPT Library");

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
            List<Category> list = categoryDAO.search(keyword, sort, order, page, PAGE_SIZE);
            int totalRecords = categoryDAO.count(keyword);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            request.setAttribute("categories", list);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPageNum", page);
            request.setAttribute("keyword", keyword != null ? keyword : "");
            request.setAttribute("sortField", sort);
            request.setAttribute("sortOrder", order);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/category_list.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "categories");
        request.setAttribute("pageTitle", "Thêm danh mục mới – FPT Library");
        request.setAttribute("formMode", "add");
        request.getRequestDispatcher("/category_form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "categories");
        request.setAttribute("pageTitle", "Chỉnh sửa danh mục – FPT Library");
        request.setAttribute("formMode", "edit");

        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        try {
            Category category = categoryDAO.findById(id);
            if (category == null) {
                request.getSession().setAttribute("errorMsg", "Không tìm thấy danh mục với ID: " + id);
                response.sendRedirect(request.getContextPath() + "/categories");
                return;
            }
            request.setAttribute("category", category);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/category_form.jsp").forward(request, response);
    }

    private void processCreate(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        String name = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));

        Category category = new Category();
        category.setName(name);
        category.setDescription(description);
        category.setCreatedBy(username);

        List<String> errors = new ArrayList<>();

        if (name == null || name.isEmpty()) {
            errors.add("Tên danh mục không được để trống.");
        } else if (name.length() > 100) {
            errors.add("Tên danh mục không được vượt quá 100 ký tự.");
        } else {
            try {
                if (categoryDAO.isNameExists(name)) {
                    errors.add("Tên danh mục '" + name + "' đã tồn tại.");
                }
            } catch (Exception e) {
                errors.add("Lỗi kiểm tra trùng tên: " + e.getMessage());
            }
        }

        if (description != null && description.length() > 500) {
            errors.add("Mô tả không được vượt quá 500 ký tự.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("category", category);
            request.setAttribute("formMode", "add");
            request.setAttribute("pageTitle", "Thêm danh mục mới – FPT Library");
            request.getRequestDispatcher("/category_form.jsp").forward(request, response);
            return;
        }

        try {
            Category created = categoryDAO.create(category);
            if (created != null) {
                request.getSession().setAttribute("successMsg", "Thêm danh mục thành công!");
                response.sendRedirect(request.getContextPath() + "/categories");
            } else {
                request.setAttribute("errorMsg", "Không thể tạo danh mục, vui lòng thử lại.");
                request.setAttribute("category", category);
                request.setAttribute("formMode", "add");
                request.getRequestDispatcher("/category_form.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tạo danh mục: " + e.getMessage());
            request.setAttribute("category", category);
            request.setAttribute("formMode", "add");
            request.getRequestDispatcher("/category_form.jsp").forward(request, response);
        }
    }

    private void processUpdate(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        String name = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));

        Category category = new Category();
        category.setId(id);
        category.setName(name);
        category.setDescription(description);
        category.setUpdatedBy(username);

        List<String> errors = new ArrayList<>();

        if (name == null || name.isEmpty()) {
            errors.add("Tên danh mục không được để trống.");
        } else if (name.length() > 100) {
            errors.add("Tên danh mục không được vượt quá 100 ký tự.");
        } else {
            try {
                if (categoryDAO.isNameExistsExcluding(name, id)) {
                    errors.add("Tên danh mục '" + name + "' đã tồn tại ở danh mục khác.");
                }
            } catch (Exception e) {
                errors.add("Lỗi kiểm tra trùng tên: " + e.getMessage());
            }
        }

        if (description != null && description.length() > 500) {
            errors.add("Mô tả không được vượt quá 500 ký tự.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("category", category);
            request.setAttribute("formMode", "edit");
            request.setAttribute("pageTitle", "Chỉnh sửa danh mục – FPT Library");
            request.getRequestDispatcher("/category_form.jsp").forward(request, response);
            return;
        }

        try {
            boolean updated = categoryDAO.update(category);
            if (updated) {
                request.getSession().setAttribute("successMsg", "Cập nhật danh mục thành công!");
                response.sendRedirect(request.getContextPath() + "/categories");
            } else {
                request.setAttribute("errorMsg", "Không thể cập nhật danh mục, vui lòng thử lại.");
                request.setAttribute("category", category);
                request.setAttribute("formMode", "edit");
                request.getRequestDispatcher("/category_form.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi cập nhật danh mục: " + e.getMessage());
            request.setAttribute("category", category);
            request.setAttribute("formMode", "edit");
            request.getRequestDispatcher("/category_form.jsp").forward(request, response);
        }
    }

    private void processDelete(HttpServletRequest request, HttpServletResponse response, String username)
            throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        try {
            boolean hasBooks = categoryDAO.hasActiveBooks(id);
            if (hasBooks) {
                request.getSession().setAttribute("errorMsg", "Không thể xóa danh mục này vì vẫn còn đầu sách đang thuộc về nó.");
                response.sendRedirect(request.getContextPath() + "/categories");
                return;
            }

            boolean deleted = categoryDAO.delete(id, username);
            if (deleted) {
                request.getSession().setAttribute("successMsg", "Xóa danh mục thành công!");
            } else {
                request.getSession().setAttribute("errorMsg", "Không thể xóa danh mục hoặc danh mục đã bị xóa trước đó.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMsg", "Lỗi xảy ra khi xóa danh mục: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/categories");
    }

    private int parseId(String s) {
        if (s == null || s.trim().isEmpty()) return -1;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; }
    }

    private String trim(String s) {
        return (s != null) ? s.trim() : null;
    }
}
