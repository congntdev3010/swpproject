package com.swp391.servlet;

import com.swp391.dao.BookCopyDAO;
import com.swp391.model.BookCopy;
import com.swp391.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest; 
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;

@WebServlet("/shelf")
public class ShelfServlet extends HttpServlet {

    private final BookCopyDAO copyDAO = new BookCopyDAO();

    /* ============================================================
     *  GET
     * ============================================================ */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedInUser == null ||
            (!loggedInUser.getRole().equals("LIBRARIAN") && !loggedInUser.getRole().equals("ADMIN"))) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "layout";

        switch (action) {
            case "layout":
                showLayout(request, response, null, null, null);
                break;
            case "filter":
                handleFilter(request, response);
                break;
            case "search":
                searchByBarcode(request, response);
                break;
            case "editForm":
                showEditForm(request, response);
                break;
            // AJAX: trả về danh sách kệ theo tầng
            case "getShelves":
                getShelvesByArea(request, response);
                break;
            // AJAX: trả về danh sách ngăn theo tầng + kệ
            case "getSlots":
                getSlotsByAreaAndShelf(request, response);
                break;
            default:
                showLayout(request, response, null, null, null);
        }
    }

    /* ============================================================
     *  POST
     * ============================================================ */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedInUser == null ||
            (!loggedInUser.getRole().equals("LIBRARIAN") && !loggedInUser.getRole().equals("ADMIN"))) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            // ADMIN: sửa vị trí (từ shelf-edit.jsp)
            case "updateLocation": {
                if (!loggedInUser.getRole().equals("ADMIN")) {
                    response.sendRedirect("shelf");
                    return;
                }
                int copyId = Integer.parseInt(request.getParameter("copyId"));
                String area  = request.getParameter("area");
                String shelf = request.getParameter("shelf");
                String slot  = request.getParameter("slot");
                copyDAO.updateLocation(copyId, area, shelf, slot);
                response.sendRedirect("shelf?action=layout&success=updated");
                break;
            }
            // LIBRARIAN + ADMIN: chuyển vị trí từng bản sao (modal trong layout)
            case "moveLocation": {
                int copyId = Integer.parseInt(request.getParameter("copyId"));
                String area  = trimOrNull(request.getParameter("area"));
                String shelf = trimOrNull(request.getParameter("shelf"));
                String slot  = trimOrNull(request.getParameter("slot"));

                copyDAO.updateLocation(copyId, area, shelf, slot);

                // Giữ nguyên filter params khi redirect
                String filterArea  = request.getParameter("filterArea");
                String filterShelf = request.getParameter("filterShelf");
                String filterSlot  = request.getParameter("filterSlot");

                StringBuilder redirect = new StringBuilder("shelf?action=filter&success=moved");
                if (filterArea  != null && !filterArea.isEmpty())  redirect.append("&filterArea=").append(filterArea);
                if (filterShelf != null && !filterShelf.isEmpty()) redirect.append("&filterShelf=").append(filterShelf);
                if (filterSlot  != null && !filterSlot.isEmpty())  redirect.append("&filterSlot=").append(filterSlot);

                response.sendRedirect(redirect.toString());
                break;
            }
            default:
                response.sendRedirect("shelf");
        }
    }

    /* ============================================================
     *  Hiển thị layout — nhận filter params (có thể null)
     * ============================================================ */
    private void showLayout(HttpServletRequest request, HttpServletResponse response,
                            String filterArea, String filterShelf, String filterSlot)
            throws ServletException, IOException {

        List<BookCopy> copies;

        boolean hasFilter = (filterArea != null && !filterArea.isEmpty())
                         || (filterShelf != null && !filterShelf.isEmpty())
                         || (filterSlot  != null && !filterSlot.isEmpty());

        if (hasFilter) {
            copies = copyDAO.getCopiesFiltered(filterArea, filterShelf, filterSlot);
        } else {
            copies = copyDAO.getAllCopies();
        }

        int totalCopies = copies.size();
        
        // Paginaton logic
        int page = 1;
        int pageSize = 20; // Set to 20 copies per page
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {}
        }
        
        int totalPages = (int) Math.ceil((double) totalCopies / pageSize);
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalCopies);
        
        List<BookCopy> paginatedCopies = new ArrayList<>();
        if (start < totalCopies) {
            paginatedCopies = copies.subList(start, end);
        }

        // Group: area -> shelf -> List<BookCopy>
        Map<String, Map<String, List<BookCopy>>> layout = new LinkedHashMap<>();
        for (BookCopy bc : paginatedCopies) {
            String area  = bc.getArea()  != null ? bc.getArea()  : "Chưa xếp";
            String shelf = bc.getShelf() != null ? bc.getShelf() : "Chưa xếp";
            layout.computeIfAbsent(area,  k -> new LinkedHashMap<>())
                  .computeIfAbsent(shelf, k -> new ArrayList<>())
                  .add(bc);
        }

        // Dữ liệu cho filter dropdowns
        List<String> allAreas = copyDAO.getDistinctAreas();

        request.setAttribute("layout", layout);
        request.setAttribute("allAreas", allAreas);
        request.setAttribute("filterArea",  filterArea);
        request.setAttribute("filterShelf", filterShelf);
        request.setAttribute("filterSlot",  filterSlot);
        request.setAttribute("totalFiltered", totalCopies);
        request.setAttribute("hasFilter", hasFilter);
        request.setAttribute("successMsg", request.getParameter("success"));
        
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/shelf-layout.jsp").forward(request, response);
    }

    /* ============================================================
     *  Filter theo tầng / kệ / ngăn
     * ============================================================ */
    private void handleFilter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String filterArea  = trimOrNull(request.getParameter("filterArea"));
        String filterShelf = trimOrNull(request.getParameter("filterShelf"));
        String filterSlot  = trimOrNull(request.getParameter("filterSlot"));

        showLayout(request, response, filterArea, filterShelf, filterSlot);
    }

    /* ============================================================
     *  Tìm kiếm theo barcode
     * ============================================================ */
    private void searchByBarcode(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String barcode = request.getParameter("barcode");
        BookCopy found = null;
        if (barcode != null && !barcode.trim().isEmpty()) {
            found = copyDAO.findByBarcode(barcode.trim());
        }

        request.setAttribute("searchBarcode", barcode);
        request.setAttribute("foundCopy", found);

        showLayout(request, response, null, null, null);
    }

    /* ============================================================
     *  Form sửa vị trí (ADMIN only)
     * ============================================================ */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (User) session.getAttribute("loggedUser");
        if (!loggedInUser.getRole().equals("ADMIN")) {
            response.sendRedirect("shelf");
            return;
        }

        String copyIdParam = request.getParameter("copyId");
        if (copyIdParam == null) {
            response.sendRedirect("shelf");
            return;
        }

        List<BookCopy> allCopies = copyDAO.getAllCopies();
        BookCopy target = null;
        for (BookCopy bc : allCopies) {
            if (bc.getId() == Integer.parseInt(copyIdParam)) {
                target = bc;
                break;
            }
        }

        List<String> areas = copyDAO.getDistinctAreas();
        request.setAttribute("editCopy", target);
        request.setAttribute("areas", areas);
        request.getRequestDispatcher("/shelf-edit.jsp").forward(request, response);
    }

    /* ============================================================
     *  AJAX — lấy danh sách kệ theo tầng
     * ============================================================ */
    private void getShelvesByArea(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String area = request.getParameter("area");
        List<String> shelves = copyDAO.getDistinctShelvesByArea(area);

        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < shelves.size(); i++) {
            json.append("\"").append(shelves.get(i)).append("\"");
            if (i < shelves.size() - 1) json.append(",");
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    /* ============================================================
     *  AJAX — lấy danh sách ngăn theo tầng + kệ
     * ============================================================ */
    private void getSlotsByAreaAndShelf(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String area  = request.getParameter("area");
        String shelf = request.getParameter("shelf");
        List<String> slots = copyDAO.getDistinctSlotsByAreaAndShelf(area, shelf);

        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < slots.size(); i++) {
            json.append("\"").append(slots.get(i)).append("\"");
            if (i < slots.size() - 1) json.append(",");
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    /* ============================================================
     *  Helper
     * ============================================================ */
    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}