<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.BorrowRecord, com.swp391.model.User, java.util.List, java.time.LocalDate" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<BorrowRecord> activeBorrows = (List<BorrowRecord>) request.getAttribute("activeBorrows");
    List<BorrowRecord> borrowHistory = (List<BorrowRecord>) request.getAttribute("borrowHistory");
    int activeCount = request.getAttribute("activeCount") != null ? (int) request.getAttribute("activeCount") : 0;
    int maxLimit = request.getAttribute("maxLimit") != null ? (int) request.getAttribute("maxLimit") : 5;
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="page-hero" style="background:linear-gradient(135deg,#0f2027 0%,#203a43 50%,#2c5364 100%);padding:3rem 0 2rem;">
    <div class="container">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#667eea,#764ba2);display:flex;align-items:center;justify-content:center;font-size:1.4rem;">📚</div>
            <div>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:700;margin:0;">Sách đang mượn</h1>
                <p style="color:rgba(255,255,255,0.6);margin:0;font-size:0.9rem;">Theo dõi tình trạng mượn & gia hạn sách của bạn</p>
            </div>
        </div>
    </div>
</div>

<div class="container" style="padding:2rem 1rem;">

    <% if ("renewed".equals(successMsg)) { %>
    <div style="background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-check"></i> Gia hạn thành công! Hạn trả đã được gia hạn thêm 14 ngày.
    </div>
    <% } else if ("cannot_renew".equals(errorMsg)) { %>
    <div style="background:#fff3cd;border:1px solid #ffc107;color:#856404;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <strong>Không thể gia hạn:</strong> Không còn bản sao khả dụng hoặc đang có người đặt trước cuốn sách này (§1.4).
    </div>
    <% } else if (errorMsg != null) { %>
    <div style="background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:0.8rem 1.2rem;border-radius:8px;margin-bottom:1.5rem;">
        <i class="fa-solid fa-circle-xmark"></i> Có lỗi xảy ra. Vui lòng thử lại.
    </div>
    <% } %>

    <!-- Quota Card -->
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1rem;margin-bottom:2rem;">
        <div style="background:#fff;border-radius:12px;padding:1.2rem;box-shadow:0 2px 12px rgba(0,0,0,0.06);border-left:4px solid <%= activeCount >= maxLimit ? "#e94560" : "#28a745" %>;">
            <div style="font-size:0.85rem;color:#888;margin-bottom:0.3rem;">Đang mượn / Giới hạn</div>
            <div style="font-size:2rem;font-weight:800;color:<%= activeCount >= maxLimit ? "#e94560" : "#1a1a2e" %>;">
                <%= activeCount %> / <%= maxLimit %>
            </div>
            <% if (activeCount >= maxLimit) { %>
            <div style="font-size:0.78rem;color:#e94560;font-weight:600;margin-top:0.3rem;">⚠️ Đã đạt giới hạn</div>
            <% } else { %>
            <div style="font-size:0.78rem;color:#28a745;margin-top:0.3rem;">Còn <%= maxLimit - activeCount %> lượt</div>
            <% } %>
        </div>
        <div style="background:#fff;border-radius:12px;padding:1.2rem;box-shadow:0 2px 12px rgba(0,0,0,0.06);border-left:4px solid #17a2b8;">
            <div style="font-size:0.85rem;color:#888;margin-bottom:0.3rem;">Sắp đến hạn (7 ngày)</div>
            <div style="font-size:2rem;font-weight:800;color:#1a1a2e;">
                <%
                    long soonCount = 0;
                    if (activeBorrows != null) {
                        for (BorrowRecord br : activeBorrows) {
                            if (br.getDueDate() != null && !br.getDueDate().isBefore(LocalDate.now())
                                && br.getDueDate().isBefore(LocalDate.now().plusDays(8))) soonCount++;
                        }
                    }
                %>
                <%= soonCount %>
            </div>
            <div style="font-size:0.78rem;color:#555;margin-top:0.3rem;">cuốn cần trả sớm</div>
        </div>
    </div>

    <!-- Active Borrows -->
    <h2 style="font-size:1.1rem;font-weight:700;margin-bottom:1rem;color:#1a1a2e;">
        <i class="fa-solid fa-book-open" style="color:#667eea;"></i> Đang mượn
    </h2>
    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;margin-bottom:2rem;">
        <% if (activeBorrows == null || activeBorrows.isEmpty()) { %>
        <div style="padding:3rem;text-align:center;color:#aaa;">
            <i class="fa-solid fa-book" style="font-size:2rem;margin-bottom:0.5rem;display:block;"></i>
            Bạn chưa mượn cuốn sách nào.
        </div>
        <% } else { %>
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:#f8f9fa;">
                <tr>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Sách</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Ngày mượn</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Hạn trả</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Gia hạn</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Trạng thái</th>
                    <th style="padding:0.9rem 1rem;text-align:center;font-size:0.85rem;color:#666;font-weight:600;">Gia hạn</th>
                </tr>
            </thead>
            <tbody>
            <% for (BorrowRecord b : activeBorrows) {
                boolean isOverdue = b.getDueDate() != null && b.getDueDate().isBefore(LocalDate.now());
                boolean isSoon = !isOverdue && b.getDueDate() != null && b.getDueDate().isBefore(LocalDate.now().plusDays(8));
            %>
            <tr style="border-bottom:1px solid #f5f5f5;" onmouseover="this.style.background='#fafafa'" onmouseout="this.style.background=''">
                <td style="padding:0.9rem 1rem;font-weight:600;color:#1a1a2e;">
                    <%= b.getBook() != null ? b.getBook().getTitle() : "N/A" %>
                    <% if (b.getBookCopy() != null) { %>
                    <div style="font-size:0.75rem;color:#aaa;font-family:monospace;">Barcode: <%= b.getBookCopy().getBarcode() %></div>
                    <% } %>
                </td>
                <td style="padding:0.9rem 1rem;color:#666;"><%= b.getBorrowDate() %></td>
                <td style="padding:0.9rem 1rem;font-weight:<%= isOverdue ? "700" : "400" %>;color:<%= isOverdue ? "#e94560" : isSoon ? "#f0a500" : "#555" %>;">
                    <%= b.getDueDate() %>
                    <% if (isOverdue) { %><div style="font-size:0.75rem;color:#e94560;">⚠️ Quá hạn!</div>
                    <% } else if (isSoon) { %><div style="font-size:0.75rem;color:#f0a500;">🔔 Sắp đến hạn</div><% } %>
                </td>
                <td style="padding:0.9rem 1rem;color:#666;"><%= b.getRenewalCount() %> lần</td>
                <td style="padding:0.9rem 1rem;">
                    <span style="padding:0.2rem 0.6rem;border-radius:20px;font-size:0.78rem;font-weight:600;
                        background:<%= isOverdue ? "#fdecea" : "#e3f2fd" %>;
                        color:<%= isOverdue ? "#c62828" : "#1565c0" %>;">
                        <%= isOverdue ? "Quá hạn" : "Đang mượn" %>
                    </span>
                </td>
                <td style="padding:0.9rem 1rem;text-align:center;">
                    <form method="post" action="<%= request.getContextPath() %>/borrow/renew">
                        <input type="hidden" name="borrowId" value="<%= b.getId() %>">
                        <button type="submit"
                                style="padding:0.35rem 0.9rem;background:linear-gradient(135deg,#17a2b8,#138496);border:none;color:#fff;border-radius:6px;cursor:pointer;font-size:0.82rem;font-weight:600;">
                            <i class="fa-solid fa-arrows-rotate"></i> Gia hạn
                        </button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <!-- Borrow History -->
    <h2 style="font-size:1.1rem;font-weight:700;margin-bottom:1rem;color:#1a1a2e;">
        <i class="fa-solid fa-clock-rotate-left" style="color:#aaa;"></i> Lịch sử mượn
    </h2>
    <div style="background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
        <% if (borrowHistory == null || borrowHistory.isEmpty()) { %>
        <div style="padding:3rem;text-align:center;color:#aaa;">Chưa có lịch sử mượn.</div>
        <% } else { %>
        <table style="width:100%;border-collapse:collapse;">
            <thead style="background:#f8f9fa;">
                <tr>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Sách</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Ngày mượn</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Ngày trả</th>
                    <th style="padding:0.9rem 1rem;text-align:left;font-size:0.85rem;color:#666;font-weight:600;">Trạng thái</th>
                </tr>
            </thead>
            <tbody>
            <% for (BorrowRecord b : borrowHistory) {
                if (!"RETURNED".equals(b.getStatus())) continue; // chỉ hiện đã trả
            %>
            <tr style="border-bottom:1px solid #f5f5f5;">
                <td style="padding:0.8rem 1rem;color:#555;"><%= b.getBook() != null ? b.getBook().getTitle() : "N/A" %></td>
                <td style="padding:0.8rem 1rem;color:#888;font-size:0.9rem;"><%= b.getBorrowDate() %></td>
                <td style="padding:0.8rem 1rem;color:#888;font-size:0.9rem;"><%= b.getReturnDate() != null ? b.getReturnDate() : "-" %></td>
                <td style="padding:0.8rem 1rem;">
                    <span style="padding:0.2rem 0.6rem;border-radius:20px;font-size:0.78rem;background:#e8f5e9;color:#2e7d32;font-weight:600;">Đã trả</span>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
