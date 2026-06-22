<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.User, com.swp391.model.BorrowRecord, com.swp391.model.Fine" %>
<%@ page import="java.util.List, java.math.BigDecimal, java.time.LocalDate" %>
<%
    User logged = (User) session.getAttribute("loggedUser");
    if (logged == null || !logged.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    BorrowRecord record     = (BorrowRecord) request.getAttribute("record");
    Integer overdueDays     = (Integer)      request.getAttribute("overdueDays");
    BigDecimal fineAmount   = (BigDecimal)   request.getAttribute("fineAmount");
    List<Fine> existingFines= (List<Fine>)   request.getAttribute("existingFines");
    String today            = (String)       request.getAttribute("today");
    String errorMsg         = (String)       request.getAttribute("errorMsg");
    String successParam     = request.getParameter("success");
    String errorParam       = request.getParameter("error");

    if (today == null) today = LocalDate.now().toString();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin | Trả Sách</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />
</head>
<body>
<div class="admin-shell">
    <aside class="admin-sidebar">
        <div class="admin-sidebar-brand">
            <div class="brand-icon">A</div>
            <div>
                <div class="brand-title">Admin Panel</div>
                <div class="brand-subtitle"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %> · <%= logged.getRole() %></div>
            </div>
        </div>

        <nav class="admin-nav" aria-label="Admin management menu">
            <a class="admin-nav-item admin-nav-user"
               href="<%= request.getContextPath() %>/admin/users">
                <i class="fa-solid fa-users"></i>
                <span>Quản lý người dùng</span>
            </a>
            <a class="admin-nav-item admin-nav-user"
               href="<%= request.getContextPath() %>/admin/borrow">
                <i class="fa-solid fa-book-bookmark"></i>
                <span>Phiếu mượn</span>
            </a>
            <a class="admin-nav-item admin-nav-user active"
               href="<%= request.getContextPath() %>/admin/return">
                <i class="fa-solid fa-rotate-left"></i>
                <span>Trả sách</span>
            </a>
        </nav>

        <div class="admin-sidebar-footer">
            <div class="admin-sidebar-card admin-sidebar-usercard">
                <div class="admin-sidebar-label">Logged as</div>
                <div class="admin-sidebar-value"><%= logged.getFullName() != null ? logged.getFullName() : logged.getUsername() %></div>
                <div class="admin-sidebar-badge"><%= logged.getRole() %></div>
            </div>
            <a class="btn btn-outline btn-sm admin-sidebar-footer-btn" href="<%= request.getContextPath() %>/home">
                <i class="fa-solid fa-house"></i> Màn hình chính
            </a>
            <a class="btn btn-danger btn-sm admin-sidebar-footer-btn" href="<%= request.getContextPath() %>/logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </div>
    </aside>

    <main class="admin-main">
        <section class="admin-page-header">
            <div>
                <h1><i class="fa-solid fa-rotate-left" style="color: var(--primary);"></i> Trả Sách & Tính Phạt</h1>
                <p>Tra cứu phiếu mượn theo barcode hoặc mã phiếu, sau đó xử lý trả sách.</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/borrow" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-book-bookmark"></i> Xem Phiếu Mượn
                </a>
            </div>
        </section>

        <% if (errorMsg != null) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> <%= errorMsg %></div>
        <% } %>
        <% if ("returned".equals(successParam)) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Trả sách thành công!</div>
        <% } else if ("fineUpdated".equals(successParam)) { %>
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Cập nhật phạt thành công!</div>
        <% } else if ("notActive".equals(errorParam)) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> Phiếu không ở trạng thái có thể trả.</div>
        <% } else if ("returnFail".equals(errorParam)) { %>
        <div class="alert alert-danger"><i class="fa-solid fa-circle-xmark"></i> Trả sách thất bại, vui lòng thử lại.</div>
        <% } %>

        <!-- Search form -->
        <% if (record == null) { %>
        <section class="admin-card">
            <div class="admin-section-head">
                <h2>Tìm kiếm phiếu mượn</h2>
            </div>
            <form method="GET" action="<%= request.getContextPath() %>/admin/return" class="admin-form-grid">
                <input type="hidden" name="action" value="search">
                <div>
                    <label for="barcodeInput">Barcode bản sao</label>
                    <input id="barcodeInput" class="form-control" type="text" name="barcode"
                           placeholder="Quét hoặc nhập barcode bản sao..." />
                </div>
                <div>
                    <label for="recordIdInput">Hoặc mã phiếu mượn (#ID)</label>
                    <input id="recordIdInput" class="form-control" type="number" name="recordId"
                           placeholder="Nhập ID phiếu mượn..." />
                </div>
                <div class="admin-form-actions" style="align-self: flex-end;">
                    <button class="btn btn-primary" type="submit">
                        <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                    </button>
                </div>
            </form>
        </section>
        <% } %>

        <!-- Preview & Return Form -->
        <% if (record != null) { %>
        <section class="admin-card">
            <div class="admin-section-head">
                <h2>Chi tiết Phiếu Mượn #<%= record.getId() %></h2>
                <a href="<%= request.getContextPath() %>/admin/return" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-search"></i> Tìm phiếu khác
                </a>
            </div>

            <!-- Record Info -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; padding: 20px; background: var(--bg-surface); border-radius: var(--radius-md); border: 1px solid var(--border);">
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Người mượn</div>
                    <div style="font-weight: 600;"><%= record.getUser() != null ? record.getUser().getFullName() : "—" %></div>
                    <div style="font-size: 0.8rem; color: var(--text-muted);"><%= record.getUser() != null && record.getUser().getStudentId() != null ? record.getUser().getStudentId() : "" %></div>
                </div>
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Sách</div>
                    <div style="font-weight: 600;"><%= record.getBook() != null ? record.getBook().getTitle() : "—" %></div>
                    <div style="font-size: 0.8rem; color: var(--text-muted);">ISBN: <%= record.getBook() != null && record.getBook().getIsbn() != null ? record.getBook().getIsbn() : "—" %></div>
                </div>
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Barcode bản sao</div>
                    <div style="font-weight: 600; font-family: monospace; font-size: 1rem;"><%= record.getBookCopy() != null ? record.getBookCopy().getBarcode() : "—" %></div>
                </div>
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Ngày mượn</div>
                    <div style="font-weight: 600;"><%= record.getBorrowDate() != null ? record.getBorrowDate() : "—" %></div>
                </div>
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Hạn trả</div>
                    <div style="font-weight: 600; <%= overdueDays != null && overdueDays > 0 ? "color: #dc2626;" : "" %>">
                        <%= record.getDueDate() != null ? record.getDueDate() : "—" %>
                    </div>
                </div>
                <div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;">Trạng thái</div>
                    <span class="badge <%= "OVERDUE".equals(record.getStatus()) ? "badge-danger" : "badge-warning" %>">
                        <%= "OVERDUE".equals(record.getStatus()) ? "Quá hạn" : "Đang mượn" %>
                    </span>
                </div>
            </div>

            <!-- Fine Preview -->
            <% if (overdueDays != null && overdueDays > 0) { %>
            <div style="background: rgba(220, 38, 38, 0.08); border: 1px solid rgba(220, 38, 38, 0.25); border-radius: var(--radius-md); padding: 16px 20px; margin-bottom: 20px;">
                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                    <i class="fa-solid fa-triangle-exclamation" style="color: #dc2626; font-size: 1.1rem;"></i>
                    <strong style="color: #dc2626;">Quá hạn <%= overdueDays %> ngày</strong>
                </div>
                <div style="font-size: 0.9rem; color: var(--text-primary);">
                    Dự kiến phạt: <strong style="color: #dc2626; font-size: 1.05rem;">
                        <%= fineAmount != null ? String.format("%,.0f VNĐ", fineAmount) : "0 VNĐ" %>
                    </strong>
                    (nếu trả hôm nay <%= today %>)
                </div>
            </div>
            <% } else { %>
            <div style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25); border-radius: var(--radius-md); padding: 14px 20px; margin-bottom: 20px;">
                <i class="fa-solid fa-circle-check" style="color: #10b981;"></i>
                <strong style="color: #10b981; margin-left: 6px;">Trả đúng hạn – Không có phạt</strong>
            </div>
            <% } %>

            <!-- Existing fines -->
            <% if (existingFines != null && !existingFines.isEmpty()) { %>
            <div style="margin-bottom: 20px;">
                <h3 style="font-size: 0.9rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); margin-bottom: 10px;">Phạt đã tồn tại</h3>
                <div class="admin-table-wrap">
                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Số tiền</th>
                            <th>Số ngày trễ</th>
                            <th>Loại</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Fine fine : existingFines) { %>
                        <tr>
                            <td>#<%= fine.getId() %></td>
                            <td><strong style="color: #dc2626;"><%= String.format("%,.0f VNĐ", fine.getAmount()) %></strong></td>
                            <td><%= fine.getOverdueDays() %> ngày</td>
                            <td><span class="badge badge-warning"><%= fine.getReason() %></span></td>
                            <td>
                                <% if ("PAID".equals(fine.getStatus())) { %>
                                <span class="badge badge-success">Đã thanh toán</span>
                                <% } else { %>
                                <span class="badge badge-danger">Chưa thanh toán</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (!"PAID".equals(fine.getStatus())) { %>
                                <form method="POST" action="<%= request.getContextPath() %>/admin/return" style="display:inline;">
                                    <input type="hidden" name="action" value="updateFine">
                                    <input type="hidden" name="fineId" value="<%= fine.getId() %>">
                                    <input type="hidden" name="recordId" value="<%= record.getId() %>">
                                    <input type="hidden" name="status" value="PAID">
                                    <input type="hidden" name="paymentMethod" value="CASH">
                                    <button type="submit" class="btn btn-sm btn-success">
                                        <i class="fa-solid fa-check"></i> Đã thanh toán
                                    </button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>

            <!-- Return Form -->
            <% if (!"RETURNED".equals(record.getStatus())) { %>
            <div style="border-top: 1px solid var(--border); padding-top: 20px;">
                <h3 style="font-size: 1rem; font-weight: 700; margin-bottom: 16px;">
                    <i class="fa-solid fa-rotate-left" style="color: var(--primary);"></i> Xác nhận Trả Sách
                </h3>
                <form method="POST" action="<%= request.getContextPath() %>/admin/return" class="admin-form-grid">
                    <input type="hidden" name="action" value="processReturn">
                    <input type="hidden" name="recordId" value="<%= record.getId() %>">
                    <div>
                        <label for="returnDate">Ngày trả thực tế</label>
                        <input id="returnDate" class="form-control" type="date" name="returnDate"
                               value="<%= today %>" required />
                    </div>
                    <div>
                        <label for="returnNote">Ghi chú (tùy chọn)</label>
                        <input id="returnNote" class="form-control" type="text" name="note"
                               placeholder="Tình trạng sách khi trả..." />
                    </div>
                    <% if (overdueDays != null && overdueDays > 0) { %>
                    <div style="grid-column: 1 / -1;">
                        <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                            <input type="checkbox" name="createFine" value="true" checked
                                   style="width: 16px; height: 16px; accent-color: var(--primary);" />
                            <span>Tạo phiếu phạt: <strong style="color: #dc2626;">
                                <%= fineAmount != null ? String.format("%,.0f VNĐ", fineAmount) : "0 VNĐ" %>
                            </strong> (<%= overdueDays %> ngày trễ)</span>
                        </label>
                    </div>
                    <% } %>
                    <div class="admin-form-actions" style="grid-column: 1 / -1; margin-top: 8px;">
                        <button class="btn btn-primary" type="submit">
                            <i class="fa-solid fa-rotate-left"></i> Xác nhận Trả Sách
                        </button>
                        <a href="<%= request.getContextPath() %>/admin/borrow" class="btn btn-outline">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </form>
            </div>
            <% } else { %>
            <div style="border-top: 1px solid var(--border); padding-top: 20px;">
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check"></i> Phiếu này đã được trả vào ngày <strong><%= record.getReturnDate() %></strong>.
                </div>
                <a href="<%= request.getContextPath() %>/admin/return" class="btn btn-outline">
                    <i class="fa-solid fa-search"></i> Tìm phiếu khác
                </a>
            </div>
            <% } %>
        </section>
        <% } %>
    </main>
</div>
</body>
</html>
