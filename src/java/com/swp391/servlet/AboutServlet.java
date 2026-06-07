package com.swp391.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

/**
 * AboutServlet – xử lý trang giới thiệu thư viện.
 * URL: /about
 */
@WebServlet(name = "AboutServlet", urlPatterns = {"/about", "/About"})
public class AboutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "about");
        request.setAttribute("pageTitle", "Giới thiệu – FPT Library");
        request.setAttribute("pageDesc",
            "Tìm hiểu về thư viện FPT University: lịch sử, sứ mệnh, giá trị cốt lõi và thông tin liên hệ.");
        request.getRequestDispatcher("/about.jsp").forward(request, response);
    }
}
