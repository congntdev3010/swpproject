<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.*,com.swp391.model.BorrowRecord,java.util.*,java.time.LocalDate" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "borrow");

    BorrowRecord record  = (BorrowRecord) request.getAttribute("record");
    Book preselectedBook = (Book) request.getAttribute("preselectedBook");
    boolean editMode     = Boolean.TRUE.equals(request.getAttribute("editMode"));
    boolean librarianMode = Boolean.TRUE.equals(request.getAttribute("librarianMode"));
    List<BookCopy> availableCopies = (List<BookCopy>) request.getAttribute("availableCopies");

    boolean isView   = (record != null && !editMode && !librarianMode);
    boolean isCreate = (record == null);
    boolean isReader = loggedUser.isReader();
    boolean isLib    = loggedUser.isAdminOrLibrarian();

    String successParam = request.getParameter("success");
    String errorParam   = request.getParameter("error");
    String pageMode = isCreate ? "create" : (librarianMode ? "confirm" : (editMode ? "edit" : "detail"));
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<div class="borrow-page">
    <div class="container">

        <!-- Breadcrumb -->
        <div style="margin-bottom: 20px; font-size: 0.85rem; color: var(--text-muted);">
            <a href="<%= request.getContextPath() %>/borrow?action=list" style="color: var(--primary); text-decoration: none;">
                <i class="fa-solid fa-arrow-left"></i> Danh sách phiếu mượn
            </a>
            <span style="margin: 0 8px;">›</span>
            <span>
                <% if (isCreate)       { %>Tạo phiếu mượn
                <% } else if (librarianMode) { %>Xác nhận phiếu #<%= record.getId() %>
                <% } else if (editMode) { %>Chỉnh sửa phiếu #<%= record.getId() %>
                <% } else { %>Chi tiết phiếu #<%= record != null ? record.getId() : "" %>
                <% } %>
            </span>
        </div>

        <!-- Alerts -->
        <% if ("confirmed".equals(successParam)) { %>
        <div class="borrow-alert success"><i class="fa-solid fa-circle-check"></i> Đã xác nhận phiếu mượn thành công!</div>
        <% } else if ("updated".equals(successParam)) { %>
        <div class="borrow-alert success"><i class="fa-solid fa-circle-check"></i> Cập nhật ghi chú thành công!</div>
        <% } else if ("dateOrder".equals(errorParam)) { %>
        <div class="borrow-alert error"><i class="fa-solid fa-circle-exclamation"></i> Ngày hạn trả phải sau ngày mượn!</div>
        <% } else if ("missingFields".equals(errorParam)) { %>
        <div class="borrow-alert error"><i class="fa-solid fa-circle-exclamation"></i> Vui lòng điền đầy đủ thông tin!</div>
        <% } %>

        <div style="max-width: 800px; margin: 0 auto;">

            <!-- ============================================================
                 CREATE FORM – READER tạo phiếu mới
                 ============================================================ -->
            <% if (isCreate) { %>
            <div class="borrow-form-card">
                <h2><i class="fa-solid fa-plus-circle"></i> Tạo Phiếu Mượn Sách</h2>
                <form method="POST" action="<%= request.getContextPath() %>/borrow" id="createBorrowForm">
                    <input type="hidden" name="action" value="create">
                    <div class="borrow-form-grid">
                        <div class="borrow-field span-2">
                            <label>Mã sách (Book ID) <span style="color:#dc2626">*</span></label>
                            <input type="number" name="bookId" id="bookIdInput"
                                   value="<%= preselectedBook != null ? preselectedBook.getId() : "" %>"
                                   placeholder="Nhập ID sách muốn mượn"
                                   required min="1">
                            <% if (preselectedBook != null) { %>
                            <div style="margin-top: 8px; padding: 10px 14px; background: rgba(244,121,32,0.07);
                                        border: 1px solid rgba(244,121,32,0.2); border-radius: 8px; font-size: 0.88rem;">
                                <i class="fa-solid fa-book" style="color: var(--primary);"></i>
                                <strong><%= preselectedBook.getTitle() %></strong>
                                <% if (preselectedBook.getIsbn() != null) { %>
                                &nbsp;·&nbsp; ISBN: <%= preselectedBook.getIsbn() %>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <div class="borrow-field span-2">
                            <label>Ghi chú của bạn</label>
                            <textarea name="note" placeholder="Ghi chú thêm (tuỳ chọn)..."></textarea>
                        </div>
                    </div>

                    <div class="borrow-form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBorrowBtn">
                            <i class="fa-solid fa-paper-plane"></i> Gửi phiếu mượn
                        </button>
                        <a href="<%= request.getContextPath() %>/borrow?action=list" class="btn btn-outline">
                            Huỷ
                        </a>
                    </div>
                </form>

                <div style="margin-top: 20px; padding: 14px 18px; background: var(--bg-surface);
                            border: 1px solid var(--border); border-radius: 10px; font-size: 0.85rem; color: var(--text-muted);">
                    <i class="fa-solid fa-circle-info" style="color: var(--primary);"></i>
                    Sau khi gửi, thủ thư sẽ xem xét và xác nhận phiếu mượn. Bạn sẽ nhận thông báo khi phiếu được duyệt.
                </div>
            </div>
            <% } %>

            <!-- ============================================================
                 DETAIL / EDIT VIEW
                 ============================================================ -->
            <% if (record != null) {
                String statusCss = "status-" + record.getStatus().toLowerCase().replace("_", "-");
                String statusLabel;
                switch (record.getStatus()) {
                    case "PENDING":   statusLabel = "Chờ xác nhận"; break;
                    case "BORROWING": statusLabel = "Đang mượn";    break;
                    case "OVERDUE":   statusLabel = "Quá hạn";      break;
                    case "RETURNED":  statusLabel = "Đã trả";       break;
                    case "CANCELLED": statusLabel = "Đã huỷ";       break;
                    case "REJECTED":  statusLabel = "Bị từ chối";   break;
                    default:          statusLabel = record.getStatus();
                }
            %>
            <!-- Info Cards -->
            <div class="detail-info-grid">
                <div class="detail-info-item">
                    <div class="label">Mã phiếu</div>
                    <div class="value">#<%= record.getId() %></div>
                </div>
                <div class="detail-info-item">
                    <div class="label">Trạng thái</div>
                    <div class="value"><span class="status-badge <%= statusCss %>"><%= statusLabel %></span></div>
                </div>
                <div class="detail-info-item">
                    <div class="label">Ngày tạo</div>
                    <div class="value"><%= record.getCreatedAt() != null ? record.getCreatedAt().toLocalDate() : "—" %></div>
                </div>
                <div class="detail-info-item">
                    <div class="label">Sách</div>
                    <div class="value"><%= record.getBook() != null ? record.getBook().getTitle() : "—" %></div>
                </div>
                <div class="detail-info-item">
                    <div class="label">Ngày bắt đầu mượn</div>
                    <div class="value"><%= record.getBorrowDate() != null ? record.getBorrowDate() : "Chưa xác nhận" %></div>
                </div>
                <div class="detail-info-item">
                    <div class="label">Hạn trả</div>
                    <div class="value">
                        <% if (record.getDueDate() != null) { %>
                            <span style="<%= LocalDate.now().isAfter(record.getDueDate()) && "BORROWING".equals(record.getStatus()) ? "color:#dc2626;font-weight:700;" : "" %>">
                                <%= record.getDueDate() %>
                            </span>
                        <% } else { %>Chưa xác nhận<% } %>
                    </div>
                </div>
                <% if (record.getBookCopy() != null) { %>
                <div class="detail-info-item">
                    <div class="label">Barcode bản sao</div>
                    <div class="value" style="font-family: monospace;"><%= record.getBookCopy().getBarcode() %></div>
                </div>
                <% } %>
                <% if (record.getReturnDate() != null) { %>
                <div class="detail-info-item">
                    <div class="label">Ngày trả thực tế</div>
                    <div class="value"><%= record.getReturnDate() %></div>
                </div>
                <% } %>
                <% if (isLib && record.getUser() != null) { %>
                <div class="detail-info-item">
                    <div class="label">Người mượn</div>
                    <div class="value"><%= record.getUser().getFullName() %><br><small style="color:var(--text-muted)"><%= record.getUser().getStudentId() != null ? record.getUser().getStudentId() : "" %></small></div>
                </div>
                <% } %>
            </div>

            <!-- Note from user -->
            <% if (record.getNote() != null && !record.getNote().trim().isEmpty()) { %>
            <div class="borrow-form-card" style="padding: 18px 22px; margin-bottom: 16px;">
                <div style="font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); margin-bottom: 8px;">
                    Ghi chú của người mượn
                </div>
                <p style="font-size: 0.92rem; color: var(--text-primary); margin: 0; white-space: pre-wrap;"><%= record.getNote() %></p>
            </div>
            <% } %>

            <!-- Librarian note -->
            <% if (record.getLibrarianNote() != null && !record.getLibrarianNote().trim().isEmpty()) { %>
            <div class="librarian-section">
                <div class="librarian-section-header">
                    <i class="fa-solid fa-stamp"></i> Ghi chú xác thực của Thủ thư
                </div>
                <p style="margin: 0; font-size: 0.92rem; white-space: pre-wrap;"><%= record.getLibrarianNote() %></p>
            </div>
            <% } %>

            <!-- ---- EDIT MODE (READER sửa ghi chú) ---- -->
            <% if (editMode && !librarianMode) { %>
            <div class="borrow-form-card">
                <h2><i class="fa-solid fa-pen"></i> Chỉnh sửa Ghi chú</h2>
                <form method="POST" action="<%= request.getContextPath() %>/borrow">
                    <input type="hidden" name="action" value="updateNote">
                    <input type="hidden" name="id" value="<%= record.getId() %>">
                    <div class="borrow-field">
                        <label>Ghi chú</label>
                        <textarea name="note" rows="4"><%= record.getNote() != null ? record.getNote() : "" %></textarea>
                    </div>
                    <div class="borrow-form-actions">
                        <button type="submit" class="btn btn-primary">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu ghi chú
                        </button>
                        <a href="<%= request.getContextPath() %>/borrow?action=detail&id=<%= record.getId() %>" class="btn btn-outline">Huỷ</a>
                    </div>
                </form>
            </div>
            <% } %>

            <!-- ---- LIBRARIAN CONFIRM FORM ---- -->
            <% if (librarianMode && "PENDING".equals(record.getStatus())) { %>
            <div class="librarian-section">
                <div class="librarian-section-header">
                    <i class="fa-solid fa-stamp"></i> Xác nhận Phiếu Mượn
                </div>

                <form method="POST" action="<%= request.getContextPath() %>/borrow" id="confirmForm">
                    <input type="hidden" name="action" value="librarianConfirm">
                    <input type="hidden" name="recordId" value="<%= record.getId() %>">

                    <div class="borrow-form-grid">
                        <div class="borrow-field">
                            <label>Bản sao (Barcode) <span style="color:#dc2626">*</span></label>
                            <select name="copyId" id="copyIdSelect" required>
                                <option value="">-- Chọn bản sao --</option>
                                <% if (availableCopies != null && !availableCopies.isEmpty()) {
                                    for (BookCopy bc : availableCopies) { %>
                                <option value="<%= bc.getId() %>">
                                    <%= bc.getBarcode() %> — <%= bc.getBookCondition() %>
                                    <% if (bc.getArea() != null) { %>(Khu: <%= bc.getArea() %><% if (bc.getShelf() != null) { %> / Kệ: <%= bc.getShelf() %><% } %>)<% } %>
                                </option>
                                <%  }
                                } else { %>
                                <option value="" disabled>⚠ Không có bản sao nào khả dụng</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="borrow-field">
                            <label>Ngày bắt đầu mượn <span style="color:#dc2626">*</span></label>
                            <input type="date" name="borrowDate" id="borrowDateInput"
                                   value="<%= LocalDate.now() %>" required>
                        </div>
                        <div class="borrow-field">
                            <label>Ngày hạn trả <span style="color:#dc2626">*</span></label>
                            <input type="date" name="dueDate" id="dueDateInput"
                                   value="<%= LocalDate.now().plusDays(14) %>" required>
                            <small style="color: var(--text-muted); font-size: 0.75rem; margin-top: 4px; display: block;">
                                Mặc định: 14 ngày. Tự điều chỉnh số ngày.
                            </small>
                        </div>
                        <div class="borrow-field">
                            <label>Số ngày cho mượn</label>
                            <input type="number" id="loanDaysInput" min="1" max="90" value="14"
                                   placeholder="Nhập số ngày"
                                   style="border-color: rgba(244,121,32,0.3);">
                        </div>
                        <div class="borrow-field span-2">
                            <label>Ghi chú xác thực</label>
                            <textarea name="librarianNote" rows="3"
                                      placeholder="Nhập ghi chú xác thực phiếu..."></textarea>
                        </div>
                    </div>

                    <div class="borrow-form-actions">
                        <button type="submit" class="btn btn-primary" id="confirmBtn"
                                <%= availableCopies == null || availableCopies.isEmpty() ? "disabled" : "" %>>
                            <i class="fa-solid fa-check-circle"></i> Xác nhận phiếu
                        </button>

                        <!-- Nút từ chối -->
                        <button type="button" class="btn btn-danger"
                                onclick="document.getElementById('rejectForm').submit();">
                            <i class="fa-solid fa-xmark-circle"></i> Từ chối
                        </button>
                        <a href="<%= request.getContextPath() %>/borrow?action=list" class="btn btn-outline">Quay lại</a>
                    </div>
                </form>

                <!-- Hidden reject form -->
                <form method="POST" action="<%= request.getContextPath() %>/borrow" id="rejectForm">
                    <input type="hidden" name="action" value="librarianReject">
                    <input type="hidden" name="recordId" value="<%= record.getId() %>">
                    <input type="hidden" name="librarianNote" id="rejectNote" value="">
                </form>
            </div>
            <% } %>

            <!-- Detail action buttons (view mode) -->
            <% if (isView) { %>
            <div class="borrow-form-actions">
                <% if (isReader && "PENDING".equals(record.getStatus())) { %>
                <a href="<%= request.getContextPath() %>/borrow?action=edit&id=<%= record.getId() %>"
                   class="btn btn-outline"><i class="fa-solid fa-pen"></i> Sửa ghi chú</a>
                <form method="POST" action="<%= request.getContextPath() %>/borrow"
                      onsubmit="return confirm('Bạn có chắc muốn huỷ phiếu này?')">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="id" value="<%= record.getId() %>">
                    <button type="submit" class="btn btn-danger">
                        <i class="fa-solid fa-xmark"></i> Huỷ phiếu
                    </button>
                </form>
                <% } %>
                <% if (isLib && "PENDING".equals(record.getStatus())) { %>
                <a href="<%= request.getContextPath() %>/borrow?action=confirm&id=<%= record.getId() %>"
                   class="btn btn-primary"><i class="fa-solid fa-check"></i> Xác nhận phiếu</a>
                <% } %>
                <% if (isLib && ("BORROWING".equals(record.getStatus()) || "OVERDUE".equals(record.getStatus()))) { %>
                <a href="<%= request.getContextPath() %>/return-book?action=preview&id=<%= record.getId() %>"
                   class="btn btn-primary"><i class="fa-solid fa-rotate-left"></i> Xử lý trả sách</a>
                <% } %>
                <a href="<%= request.getContextPath() %>/borrow?action=list" class="btn btn-outline">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                </a>
            </div>
            <% } %>

            <% } // end record != null %>

        </div><!-- end max-width -->
    </div><!-- end container -->
</div>

<script>
// Tự động tính due date khi nhập số ngày mượn
document.addEventListener('DOMContentLoaded', function() {
    var loanInput    = document.getElementById('loanDaysInput');
    var borrowInput  = document.getElementById('borrowDateInput');
    var dueInput     = document.getElementById('dueDateInput');

    function recalcDue() {
        var bDate = borrowInput ? borrowInput.value : null;
        var days  = loanInput  ? parseInt(loanInput.value) : 14;
        if (bDate && !isNaN(days) && days > 0) {
            var d = new Date(bDate);
            d.setDate(d.getDate() + days);
            var yyyy = d.getFullYear();
            var mm = String(d.getMonth() + 1).padStart(2, '0');
            var dd = String(d.getDate()).padStart(2, '0');
            if (dueInput) dueInput.value = yyyy + '-' + mm + '-' + dd;
        }
    }

    if (loanInput)   loanInput.addEventListener('input', recalcDue);
    if (borrowInput) borrowInput.addEventListener('change', recalcDue);

    // Reject confirmation
    var rejectBtn = document.querySelector('[onclick*="rejectForm"]');
    if (rejectBtn) {
        rejectBtn.onclick = function() {
            var note = prompt('Lý do từ chối phiếu:');
            if (note !== null) {
                document.getElementById('rejectNote').value = note;
                document.getElementById('rejectForm').submit();
            }
        };
    }
});
</script>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>
