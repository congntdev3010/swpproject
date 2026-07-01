package com.swp391.servlet;

import com.swp391.dao.*;
import com.swp391.model.Author;
import com.swp391.model.Book;
import com.swp391.model.Category;
import com.swp391.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * BookDetailServlet – xử lý CRUD sách.
 *
 * URL patterns:
 *   /book/detail?id=X  – Xem chi tiết (mọi người)
 *   /book/add          – Form thêm sách (Admin only)
 *   /book/edit?id=X    – Form sửa sách (Admin only)
 *   /book/delete?id=X  – Xóa sách (Admin only)
 */
@WebServlet(name = "BookDetailServlet", urlPatterns = {
    "/book/detail", "/book/add", "/book/edit", "/book/delete"
})
public class BookDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String ctx = request.getContextPath();

        switch (path) {
            case "/book/detail":
                showDetail(request, response);
                break;
            case "/book/add":
                showAddForm(request, response);
                break;
            case "/book/edit":
                showEditForm(request, response);
                break;
            case "/book/delete":
                processDelete(request, response);
                break;
            default:
                response.sendRedirect(ctx + "/books");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            processCreate(request, response);
        } else if ("update".equals(action)) {
            processUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/books");
        }
    }

    // ============================================================
    //  VIEW DETAIL
    // ============================================================
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "books");

        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        try {
            BookDAO dao = new BookDAOImpl();
            Book book = dao.findById(id);
            if (book == null) {
                request.setAttribute("errorMsg", "Không tìm thấy sách với ID: " + id);
                request.setAttribute("pageTitle", "Sách không tồn tại – FPT Library");
                request.getRequestDispatcher("/book_detail.jsp").forward(request, response);
                return;
            }

            List<Author> authors = dao.getAuthorsByBookId(id);

            request.setAttribute("book", book);
            request.setAttribute("authors", authors);
            request.setAttribute("pageTitle", book.getTitle() + " – FPT Library");
            request.setAttribute("pageDesc", "Chi tiết sách: " + book.getTitle());

            // Check if user is admin (for showing edit/delete buttons)
            HttpSession session = request.getSession(false);
            User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
            request.setAttribute("isAdmin", loggedUser != null && loggedUser.isAdmin());

        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/book_detail.jsp").forward(request, response);
    }

    // ============================================================
    //  SHOW ADD FORM
    // ============================================================
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAdmin(request, response)) return;

        request.setAttribute("currentPage", "books");
        request.setAttribute("pageTitle", "Thêm sách mới – FPT Library");
        request.setAttribute("formMode", "add");

        try {
            loadFormData(request);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/book_form.jsp").forward(request, response);
    }

    // ============================================================
    //  SHOW EDIT FORM
    // ============================================================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAdmin(request, response)) return;

        request.setAttribute("currentPage", "books");
        request.setAttribute("formMode", "edit");

        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        try {
            BookDAO bookDao = new BookDAOImpl();
            Book book = bookDao.findById(id);
            if (book == null) {
                response.sendRedirect(request.getContextPath() + "/books");
                return;
            }

            boolean hasCopies = bookDao.hasPhysicalCopies(id);
            List<Integer> selectedAuthorIds = bookDao.getAuthorIdsByBookId(id);

            request.setAttribute("book", book);
            request.setAttribute("hasCopies", hasCopies);
            request.setAttribute("selectedAuthorIds", selectedAuthorIds);
            request.setAttribute("pageTitle", "Sửa sách: " + book.getTitle() + " – FPT Library");

            loadFormData(request);

        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/book_form.jsp").forward(request, response);
    }

    // ============================================================
    //  PROCESS CREATE
    // ============================================================
    private void processCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAdmin(request, response)) return;

        String ctx = request.getContextPath();

        try {
            BookDAO dao = new BookDAOImpl();
            Book book = extractBookFromRequest(request);

            // Validate
            List<String> errors = validateBook(book, dao, true, 0);
            List<Integer> authorIds = getSelectedAuthorIds(request);
            if (authorIds.isEmpty()) {
                errors.add("Vui lòng chọn ít nhất một tác giả.");
            }
            if (!errors.isEmpty()) {
                request.setAttribute("formMode", "add");
                request.setAttribute("book", book);
                request.setAttribute("errors", errors);
                request.setAttribute("currentPage", "books");
                request.setAttribute("pageTitle", "Thêm sách mới – FPT Library");
                request.setAttribute("selectedAuthorIds", authorIds);
                loadFormData(request);
                request.getRequestDispatcher("/book_form.jsp").forward(request, response);
                return;
            }

            int newId = dao.createBook(book);
            if (newId > 0) {
                // Set authors
                if (!authorIds.isEmpty()) {
                    dao.setBookAuthors(newId, authorIds);
                }
                response.sendRedirect(ctx + "/book/detail?id=" + newId + "&success=created");
            } else {
                request.setAttribute("formMode", "add");
                request.setAttribute("book", book);
                request.setAttribute("errorMsg", "Thêm sách thất bại.");
                request.setAttribute("currentPage", "books");
                request.setAttribute("pageTitle", "Thêm sách mới – FPT Library");
                loadFormData(request);
                request.getRequestDispatcher("/book_form.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            request.setAttribute("formMode", "add");
            request.setAttribute("currentPage", "books");
            request.setAttribute("pageTitle", "Thêm sách mới – FPT Library");
            try { loadFormData(request); } catch (Exception ex) {}
            request.getRequestDispatcher("/book_form.jsp").forward(request, response);
        }
    }

    // ============================================================
    //  PROCESS UPDATE
    // ============================================================
    private void processUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAdmin(request, response)) return;

        String ctx = request.getContextPath();
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(ctx + "/books");
            return;
        }

        try {
            BookDAO dao = new BookDAOImpl();
            Book book = extractBookFromRequest(request);
            book.setId(id);

            // If has physical copies, keep original ISBN
            boolean hasCopies = dao.hasPhysicalCopies(id);
            if (hasCopies) {
                Book original = dao.findById(id);
                if (original != null) {
                    book.setIsbn(original.getIsbn());
                }
            }

            // Validate
            List<String> errors = validateBook(book, dao, false, id);
            List<Integer> authorIds = getSelectedAuthorIds(request);
            if (authorIds.isEmpty()) {
                errors.add("Vui lòng chọn ít nhất một tác giả.");
            }
            if (!errors.isEmpty()) {
                request.setAttribute("formMode", "edit");
                request.setAttribute("book", book);
                request.setAttribute("errors", errors);
                request.setAttribute("hasCopies", hasCopies);
                request.setAttribute("currentPage", "books");
                request.setAttribute("pageTitle", "Sửa sách – FPT Library");
                request.setAttribute("selectedAuthorIds", authorIds);
                loadFormData(request);
                request.getRequestDispatcher("/book_form.jsp").forward(request, response);
                return;
            }

            boolean updated = dao.updateBook(book);
            if (updated) {
                // Update authors
                dao.setBookAuthors(id, authorIds);
                response.sendRedirect(ctx + "/book/detail?id=" + id + "&success=updated");
            } else {
                request.setAttribute("errorMsg", "Cập nhật thất bại.");
                request.setAttribute("formMode", "edit");
                request.setAttribute("book", book);
                request.setAttribute("currentPage", "books");
                request.setAttribute("pageTitle", "Sửa sách – FPT Library");
                loadFormData(request);
                request.getRequestDispatcher("/book_form.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            request.setAttribute("formMode", "edit");
            request.setAttribute("currentPage", "books");
            request.setAttribute("pageTitle", "Sửa sách – FPT Library");
            try { loadFormData(request); } catch (Exception ex) {}
            request.getRequestDispatcher("/book_form.jsp").forward(request, response);
        }
    }

    // ============================================================
    //  DELETE
    // ============================================================
    private void processDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAdmin(request, response)) return;

        String ctx = request.getContextPath();
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(ctx + "/books");
            return;
        }

        // Lấy username từ session để ghi vào updated_by
        com.swp391.model.User currentUser = (com.swp391.model.User) request.getSession().getAttribute("loggedUser");
        String operator = (currentUser != null) ? currentUser.getUsername() : "system";

        try {
            BookDAO dao = new BookDAOImpl();

            // Kiểm tra có lượt mượn/đặt chỗ đang hoạt động không
            if (dao.hasActiveBorrowsOrReservations(id)) {
                response.sendRedirect(ctx + "/book/detail?id=" + id + "&error=has_active");
                return;
            }

            // Xóa liên kết tác giả trước
            dao.setBookAuthors(id, new ArrayList<>());

            // deleteBook đã tích hợp guard: nếu còn active copies sẽ throw IllegalStateException
            boolean deleted = dao.deleteBook(id, operator);

            if (deleted) {
                response.sendRedirect(ctx + "/books?success=deleted");
            } else {
                response.sendRedirect(ctx + "/book/detail?id=" + id + "&error=delete_failed");
            }

        } catch (IllegalStateException e) {
            // Còn bản sao vật lý active
            response.sendRedirect(ctx + "/book/detail?id=" + id + "&error=has_copies");
        } catch (Exception e) {
            response.sendRedirect(ctx + "/book/detail?id=" + id + "&error=exception");
        }
    }

    // ============================================================
    //  HELPER METHODS
    // ============================================================

    /**
     * Kiểm tra quyền Admin. Redirect nếu không đủ quyền.
     * @return true nếu user là Admin
     */
    private boolean requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("loggedUser");
        if (!user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return false;
        }
        return true;
    }

    /**
     * Load dữ liệu cho form (categories, authors).
     */
    private void loadFormData(HttpServletRequest request) throws Exception {
        CategoryDAO catDao = new CategoryDAOImpl();
        AuthorDAO authorDao = new AuthorDAOImpl();
        request.setAttribute("categoriesList", catDao.findAll());
        request.setAttribute("authorsList", authorDao.findAll());
    }

    /**
     * Parse book data từ request parameters.
     */
    private Book extractBookFromRequest(HttpServletRequest request) {
        Book book = new Book();
        book.setTitle(trim(request.getParameter("title")));
        book.setIsbn(trim(request.getParameter("isbn")));
        book.setCategory(trim(request.getParameter("category")));

        String catIdStr = request.getParameter("categoryId");
        if (catIdStr != null && !catIdStr.trim().isEmpty()) {
            try { book.setCategoryId(Integer.parseInt(catIdStr.trim())); } catch (NumberFormatException e) {}
        }

        book.setPublisher(trim(request.getParameter("publisher")));

        String yearStr = request.getParameter("publishYear");
        if (yearStr != null && !yearStr.trim().isEmpty()) {
            try { book.setPublishYear(Integer.parseInt(yearStr.trim())); } catch (NumberFormatException e) {}
        }

        String priceStr = request.getParameter("price");
        if (priceStr != null && !priceStr.trim().isEmpty()) {
            try { book.setPrice(Integer.parseInt(priceStr.trim())); } catch (NumberFormatException e) {}
        }

        String qtyStr = request.getParameter("quantity");
        if (qtyStr != null && !qtyStr.trim().isEmpty()) {
            try { book.setQuantity(Integer.parseInt(qtyStr.trim())); } catch (NumberFormatException e) {}
        }

        // available = quantity for new books
        String availStr = request.getParameter("available");
        if (availStr != null && !availStr.trim().isEmpty()) {
            try { book.setAvailable(Integer.parseInt(availStr.trim())); } catch (NumberFormatException e) {}
        } else {
            book.setAvailable(book.getQuantity());
        }

        book.setDescription(trim(request.getParameter("description")));
        book.setCoverImage(trim(request.getParameter("coverImage")));
        book.setSubject(trim(request.getParameter("subject")));
        book.setArea(trim(request.getParameter("area")));
        book.setShelf(trim(request.getParameter("shelf")));
        book.setSlot(trim(request.getParameter("slot")));

        return book;
    }

    /**
     * Lấy danh sách author IDs được chọn.
     */
    private List<Integer> getSelectedAuthorIds(HttpServletRequest request) {
        List<Integer> ids = new ArrayList<>();
        String[] authorIdStrs = request.getParameterValues("authorIds");
        if (authorIdStrs != null) {
            for (String s : authorIdStrs) {
                try { ids.add(Integer.parseInt(s.trim())); } catch (NumberFormatException e) {}
            }
        }
        return ids;
    }

    /**
     * Validate thông tin sách.
     */
    private List<String> validateBook(Book book, BookDAO dao, boolean isCreate, int excludeId) throws Exception {
        List<String> errors = new ArrayList<>();

        // Required fields
        if (book.getTitle() == null || book.getTitle().trim().isEmpty()) {
            errors.add("Tiêu đề sách không được để trống.");
        } else if (book.getTitle().length() > 255) {
            errors.add("Tiêu đề sách không được vượt quá 255 ký tự.");
        }

        if (book.getIsbn() == null || book.getIsbn().trim().isEmpty()) {
            errors.add("ISBN không được để trống.");
        } else if (book.getIsbn().length() > 20) {
            errors.add("ISBN không được vượt quá 20 ký tự.");
        } else {
            // ISBN uniqueness
            if (isCreate) {
                if (dao.isIsbnExists(book.getIsbn())) {
                    errors.add("ISBN '" + book.getIsbn() + "' đã tồn tại trong hệ thống.");
                }
            } else {
                if (dao.isIsbnExistsExcluding(book.getIsbn(), excludeId)) {
                    errors.add("ISBN '" + book.getIsbn() + "' đã được sử dụng bởi sách khác.");
                }
            }
        }

        if (book.getCategory() == null || book.getCategory().trim().isEmpty()) {
            errors.add("Danh mục không được để trống.");
        }

        // Publish year
        if (book.getPublishYear() != null) {
            if (book.getPublishYear() < 1000 || book.getPublishYear() > 2100) {
                errors.add("Năm xuất bản phải từ 1000 đến 2100.");
            }
        }

        // Price
        if (book.getPrice() != null && book.getPrice() < 0) {
            errors.add("Giá sách không được âm.");
        }

        // Quantity
        if (book.getQuantity() < 0) {
            errors.add("Số lượng không được âm.");
        }

        // Available <= Quantity
        if (book.getAvailable() < 0) {
            errors.add("Số lượng có sẵn không được âm.");
        }
        if (book.getAvailable() > book.getQuantity()) {
            errors.add("Số lượng có sẵn không được lớn hơn tổng số lượng.");
        }

        // Description length
        if (book.getDescription() != null && book.getDescription().length() > 5000) {
            errors.add("Mô tả không được vượt quá 5000 ký tự.");
        }

        return errors;
    }

    private int parseId(String s) {
        if (s == null || s.trim().isEmpty()) return -1;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; }
    }

    private String trim(String s) {
        return (s != null) ? s.trim() : null;
    }
}
