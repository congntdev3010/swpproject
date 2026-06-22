<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.*,com.swp391.model.BorrowRecord,java.util.*" %>
<%
    // loggedUser được khai báo trong header.jsp - KHÔNG khai báo lại ở đây
    if (session.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Đặt currentPage nav TRƯỚC khi include header
    request.setAttribute("currentPage", "borrow");
    List<BorrowRecord> records = (List<BorrowRecord>) request.getAttribute("records");
    int total = records != null && request.getAttribute("total") != null ? (Integer) request.getAttribute("total") : 0;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
    int pageNum = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    String statusFilter = (String) request.getAttribute("statusFilter");
    String search = (String) request.getAttribute("search");

    // Success/error message
    String successParam = request.getParameter("success");
    String errorParam   = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<%
    // Lấy lại loggedUser sau khi header.jsp đã khai báo
    User loggedUser = (User) session.getAttribute("loggedUser");
    boolean isLibrarian = loggedUser.isAdminOrLibrarian();
%>

<div class="borrow-page">
    <div class="container">

        <!-- Page Header -->
        <div class="borrow-header">
            <div>
                <h1 class="borrow-title">
                    <i class="fa-solid fa-book-bookmark" style="color: var(--primary); font-size: 1.6rem;"></i>
                    Quản lý Phiếu Mượn
                </h1>
                <p class="borrow-subtitle">
                    <% if (isLibrarian) { %>
                        Xem và xác nhận toàn bộ phiếu mượn trong hệ thống (<%= total %> phiếu)
                    <% } else { %>
                        Danh sách phiếu mượn của bạn (<%= total %> phiếu)
                    <% } %>
                </p>
            </div>
            <div class="borrow-form-actions">
                <% if (!isLibrarian) { %>
                <a href="<%= request.getContextPath() %>/borrow?action=create" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i> Tạo phiếu mượn
                </a>
                <% } %>
                <% if (isLibrarian) { %>
                <a href="<%= request.getContextPath() %>/return-book" class="btn btn-outline">
                    <i class="fa-solid fa-rotate-left"></i> Trả sách
                </a>
                <% } %>
            </div>
        </div>

        <!-- Alert -->
        <% if ("created".equals(successParam)) { %>
        <div class="borrow-alert success"><i class="fa-solid fa-circle-check"></i> Tạo phiếu mượn thành công!</div>
        <% } else if ("cancelled".equals(successParam)) { %>
        <div class="borrow-alert success"><i class="fa-solid fa-circle-check"></i> Đã huỷ phiếu mượn.</div>
        <% } else if ("rejected".equals(successParam)) { %>
        <div class="borrow-alert success"><i class="fa-solid fa-circle-check"></i> Đã từ chối phiếu.</div>
        <% } %>

        <!-- Filter Bar -->
        <form method="GET" action="<%= request.getContextPath() %>/borrow">
            <input type="hidden" name="action" value="list">
            <div class="borrow-filter-bar">
                <div class="form-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="search" class="input-field"
                           placeholder="Tên sách, sinh viên..."
                           value="<%= search != null ? search : "" %>">
                </div>
                <div class="form-group" style="max-width: 180px;">
                    <label>Trạng thái</label>
                    <select name="status" class="select-field">
                        <option value="">-- Tất cả --</option>
                        <option value="PENDING"   <%= "PENDING".equals(statusFilter)   ? "selected" : "" %>>Chờ xác nhận</option>
                        <option value="BORROWING" <%= "BORROWING".equals(statusFilter) ? "selected" : "" %>>Đang mượn</option>
                        <option value="OVERDUE"   <%= "OVERDUE".equals(statusFilter)   ? "selected" : "" %>>Quá hạn</option>
                        <option value="RETURNED"  <%= "RETURNED".equals(statusFilter)  ? "selected" : "" %>>Đã trả</option>
                        <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Đã huỷ</option>
                        <option value="REJECTED"  <%= "REJECTED".equals(statusFilter)  ? "selected" : "" %>>Bị từ chối</option>
                    </select>
                </div>
                <div style="display:flex; align-items:flex-end;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-magnifying-glass"></i> Lọc
                    </button>
                </div>
            </div>
        </form>

        <!-- Table -->
        <div class="borrow-table-wrap">
            <% if (records == null || records.isEmpty()) { %>
            <div class="borrow-empty">
                <div class="borrow-empty-icon">📋</div>
                <h3>Không có phiếu mượn nào</h3>
                <p>
                    <% if (!isLibrarian) { %>
                    Bạn chưa tạo phiếu mượn. Hãy tạo phiếu để mượn sách!
                    <% } else { %>
                    Không tìm thấy phiếu mượn phù hợp với bộ lọc.
                    <% } %>
                </p>
            </div>
            <% } else { %>
            <table class="borrow-table">
                <thead>
                    <tr>
                        <th>#ID</th>
                        <th>Sách</th>
                        <% if (isLibrarian) { %><th>Người mượn</th><% } %>
                        <th>Ngày tạo</th>
                        <th>Hạn trả</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (BorrowRecord br : records) {
                        String statusCss = "status-" + br.getStatus().toLowerCase().replace("_", "-");
                        String statusLabel;
                        switch (br.getStatus()) {
                            case "PENDING":   statusLabel = "Chờ xác nhận"; break;
                            case "BORROWING": statusLabel = "Đang mượn";    break;
                            case "OVERDUE":   statusLabel = "Quá hạn";      break;
                            case "RETURNED":  statusLabel = "Đã trả";       break;
                            case "CANCELLED": statusLabel = "Đã huỷ";       break;
                            case "REJECTED":  statusLabel = "Bị từ chối";   break;
                            default:          statusLabel = br.getStatus();
                        }
                    %>
                    <tr>
                        <td><strong>#<%= br.getId() %></strong></td>
                        <td>
                            <div class="book-info">
                                <div class="title"><%= br.getBook() != null ? br.getBook().getTitle() : "—" %></div>
                                <div class="isbn"><%= br.getBook() != null && br.getBook().getIsbn() != null ? "ISBN: " + br.getBook().getIsbn() : "" %></div>
                            </div>
                        </td>
                        <% if (isLibrarian) { %>
                        <td>
                            <div class="user-info">
                                <div class="name"><%= br.getUser() != null ? br.getUser().getFullName() : "—" %></div>
                                <div class="sid"><%= br.getUser() != null && br.getUser().getStudentId() != null ? br.getUser().getStudentId() : "" %></div>
                            </div>
                        </td>
                        <% } %>
                        <td><%= br.getCreatedAt() != null ? br.getCreatedAt().toLocalDate() : "—" %></td>
                        <td>
                            <% if (br.getDueDate() != null) { %>
                                <span style="<%= java.time.LocalDate.now().isAfter(br.getDueDate()) && "BORROWING".equals(br.getStatus()) ? "color:#dc2626;font-weight:700;" : "" %>">
                                    <%= br.getDueDate() %>
                                </span>
                            <% } else { %>—<% } %>
                        </td>
                        <td>
                            <span class="status-badge <%= statusCss %>"><%= statusLabel %></span>
                        </td>
                        <td>
                            <div class="admin-row-actions">
                                <a href="<%= request.getContextPath() %>/borrow?action=detail&id=<%= br.getId() %>"
                                   class="btn btn-outline btn-sm">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <!-- READER: nút sửa / huỷ khi PENDING -->
                                <% if (!isLibrarian && "PENDING".equals(br.getStatus())) { %>
                                <a href="<%= request.getContextPath() %>/borrow?action=edit&id=<%= br.getId() %>"
                                   class="btn btn-outline btn-sm">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                                <form method="POST" action="<%= request.getContextPath() %>/borrow"
                                      onsubmit="return confirm('Bạn có chắc muốn huỷ phiếu này?')">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="id" value="<%= br.getId() %>">
                                    <button type="submit" class="btn btn-danger btn-sm">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </form>
                                <% } %>
                                <!-- LIBRARIAN: nút xác nhận khi PENDING -->
                                <% if (isLibrarian && "PENDING".equals(br.getStatus())) { %>
                                <a href="<%= request.getContextPath() %>/borrow?action=confirm&id=<%= br.getId() %>"
                                   class="btn btn-primary btn-sm">
                                    <i class="fa-solid fa-check"></i> Xác nhận
                                </a>
                                <% } %>
                                <!-- LIBRARIAN: nút trả sách -->
                                <% if (isLibrarian && ("BORROWING".equals(br.getStatus()) || "OVERDUE".equals(br.getStatus()))) { %>
                                <a href="<%= request.getContextPath() %>/return-book?action=preview&id=<%= br.getId() %>"
                                   class="btn btn-outline btn-sm" style="color: #d97706; border-color: #d97706;">
                                    <i class="fa-solid fa-rotate-left"></i> Trả sách
                                </a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div style="padding: 16px 20px; border-top: 1px solid var(--border);">
                <div class="borrow-paging">
                    <% for (int p = 1; p <= totalPages; p++) {
                        String qStr = "action=list&page=" + p
                            + (statusFilter != null && !statusFilter.isEmpty() ? "&status=" + statusFilter : "")
                            + (search != null && !search.isEmpty() ? "&search=" + search : "");
                    %>
                    <% if (p == pageNum) { %>
                    <span class="active"><%= p %></span>
                    <% } else { %>
                    <a href="<%= request.getContextPath() %>/borrow?<%= qStr %>"><%= p %></a>
                    <% } %>
                    <% } %>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>

    </div>
</div>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
