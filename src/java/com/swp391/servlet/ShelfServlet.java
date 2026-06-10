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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("user") : null;

        // Chỉ LIBRARIAN và ADMIN mới vào được
        if (loggedInUser == null ||
            (!loggedInUser.getRole().equals("LIBRARIAN") && !loggedInUser.getRole().equals("ADMIN"))) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "layout";

        switch (action) {
            case "layout":
                showLayout(request, response);
                break;
            case "search":
                searchByBarcode(request, response);
                break;
            case "editForm":
                showEditForm(request, response);
                break;
            default:
                showLayout(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (loggedInUser == null ||
            (!loggedInUser.getRole().equals("LIBRARIAN") && !loggedInUser.getRole().equals("ADMIN"))) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "updateLocation": {
                int copyId = Integer.parseInt(request.getParameter("copyId"));
                String area  = request.getParameter("area");
                String shelf = request.getParameter("shelf");
                String slot  = request.getParameter("slot");
                copyDAO.updateLocation(copyId, area, shelf, slot);
                response.sendRedirect("shelf?action=layout&success=updated");
                break;
            }
            default:
                response.sendRedirect("shelf");
        }
    }

    // F12: Hiển thị sơ đồ kho — group theo area -> shelf -> slot
    private void showLayout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<BookCopy> allCopies = copyDAO.getAllCopies();

        // Group: area -> shelf -> List<BookCopy>
        Map<String, Map<String, List<BookCopy>>> layout = new LinkedHashMap<>();
        for (BookCopy bc : allCopies) {
            String area  = bc.getArea()  != null ? bc.getArea()  : "Chưa xếp";
            String shelf = bc.getShelf() != null ? bc.getShelf() : "Chưa xếp";
            layout.computeIfAbsent(area, k -> new LinkedHashMap<>())
                  .computeIfAbsent(shelf, k -> new ArrayList<>())
                  .add(bc);
        }

        request.setAttribute("layout", layout);
        request.setAttribute("successMsg", request.getParameter("success"));
        request.getRequestDispatcher("/shelf-layout.jsp").forward(request, response);
    }

    // F12: Tìm kiếm vị trí theo barcode
    private void searchByBarcode(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String barcode = request.getParameter("barcode");
        BookCopy found = null;
        if (barcode != null && !barcode.trim().isEmpty()) {
            found = copyDAO.findByBarcode(barcode.trim());
        }

        request.setAttribute("searchBarcode", barcode);
        request.setAttribute("foundCopy", found);
        // Vẫn load layout để hiển thị cùng trang
        List<BookCopy> allCopies = copyDAO.getAllCopies();
        Map<String, Map<String, List<BookCopy>>> layout = new LinkedHashMap<>();
        for (BookCopy bc : allCopies) {
            String area  = bc.getArea()  != null ? bc.getArea()  : "Chưa xếp";
            String shelf = bc.getShelf() != null ? bc.getShelf() : "Chưa xếp";
            layout.computeIfAbsent(area, k -> new LinkedHashMap<>())
                  .computeIfAbsent(shelf, k -> new ArrayList<>())
                  .add(bc);
        }
        request.setAttribute("layout", layout);
        request.getRequestDispatcher("/shelf-layout.jsp").forward(request, response);
    }

    // F13: Hiển thị form sửa vị trí của 1 bản sao
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Chỉ ADMIN mới sửa được
        HttpSession session = request.getSession(false);
        User loggedInUser = (User) session.getAttribute("user");
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
        request.getRequestDispatcher("/view/shelf-edit.jsp").forward(request, response);
    }
}
