<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    com.swp391.model.User loggedUser = (com.swp391.model.User) session.getAttribute("loggedUser");
    if (loggedUser == null || !loggedUser.isAdminOrLibrarian()) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("activePage", "shelf");
    request.setAttribute("pageTitle", "Sơ đồ kho thư viện");
%>
<%@ include file="/WEB-INF/jsp/header.jsp" %>
<style>
  /* ── Polyfill for removed Bootstrap ── */
  .container, .container-fluid { width: 100%; max-width: 1200px; margin: 0 auto; padding: 0 15px; box-sizing: border-box; }
  .row { display: flex; flex-wrap: wrap; margin-left: -10px; margin-right: -10px; }
  .col-md-3, .col-md-4, .col-auto { padding: 0 10px; box-sizing: border-box; }
  .col-md-3 { width: 25%; }
  .col-md-4 { width: 33.333333%; }
  .col-auto { width: auto; }
  @media (max-width: 768px) { .col-md-3, .col-md-4 { width: 100%; } }
  .d-flex { display: flex; }
  .justify-content-between { justify-content: space-between; }
  .justify-content-center { justify-content: center; }
  .align-items-center { align-items: center; }
  .align-items-end { align-items: flex-end; }
  .gap-2 { gap: 0.5rem; }
  .gap-3 { gap: 1rem; }
  .mb-0 { margin-bottom: 0; }
  .mb-1 { margin-bottom: 0.25rem; }
  .mb-2 { margin-bottom: 0.5rem; }
  .mb-3 { margin-bottom: 1rem; }
  .mb-4 { margin-bottom: 1.5rem; }
  .mt-1 { margin-top: 0.25rem; }
  .mt-2 { margin-top: 0.5rem; }
  .mt-4 { margin-top: 1.5rem; }
  .py-4 { padding-top: 1.5rem; padding-bottom: 1.5rem; }
  .px-2 { padding-left: 0.5rem; padding-right: 0.5rem; }
  .py-1 { padding-top: 0.25rem; padding-bottom: 0.25rem; }
  .p-3 { padding: 1rem; }
  .ms-1 { margin-left: 0.25rem; }
  .fw-bold { font-weight: 700; }
  .fw-semibold { font-weight: 600; }
  .text-white { color: #fff; }
  .text-muted { color: #6c757d; }
  .text-danger { color: #dc3545; }
  .text-primary { color: #0d6efd; }
  .text-truncate { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .small { font-size: 0.875em; }
  .bg-light { background-color: #f8f9fa; }
  .w-100 { width: 100%; }
  .opacity-75 { opacity: 0.75; }
  .rounded { border-radius: 0.375rem; }
  .shadow-sm { box-shadow: 0 .125rem .25rem rgba(0,0,0,.075); }

  /* ── Tables ── */
  .table { width: 100%; border-collapse: collapse; margin-bottom: 1rem; }
  .table th, .table td { padding: 0.5rem; vertical-align: middle; border-bottom: 1px solid #dee2e6; text-align: left; }
  .table-borderless th, .table-borderless td { border-bottom: none; }
  
  /* ── Forms ── */
  .form-label { margin-bottom: 0.5rem; display: inline-block; font-weight: 500;}
  .form-select, .form-control { display: block; width: 100%; padding: 0.375rem 2.25rem 0.375rem 0.75rem; font-size: 1rem; font-weight: 400; line-height: 1.5; color: #212529; background-color: #fff; border: 1px solid #ced4da; border-radius: 0.25rem; box-sizing: border-box; }
  .form-control-sm, .form-select-sm { padding-top: 0.25rem; padding-bottom: 0.25rem; font-size: 0.875rem; border-radius: 0.2rem; }
  
  /* ── Alerts ── */
  .alert { position: relative; padding: 1rem 1rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; }
  .alert-success { color: #0f5132; background-color: #d1e7dd; border-color: #badbcc; }
  .alert-dismissible { padding-right: 3rem; }
  .alert-dismissible .btn-close { position: absolute; top: 0; right: 0; z-index: 2; padding: 1.25rem 1rem; }
  .fade { transition: opacity .15s linear; }
  
  /* ── Custom Modal ── */
  .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1050; overflow-x: hidden; overflow-y: auto; }
  .modal.show { display: flex; align-items: center; justify-content: center; }
  .modal-dialog { width: 500px; max-width: 90%; background: #fff; border-radius: 8px; position: relative; margin: 1.75rem auto; pointer-events: auto; }
  .modal-content { display: flex; flex-direction: column; width: 100%; background-color: #fff; background-clip: padding-box; border: 1px solid rgba(0,0,0,.2); border-radius: .3rem; outline: 0; }
  .modal-header { display: flex; align-items: center; justify-content: space-between; padding: 1rem 1rem; border-bottom: 1px solid #dee2e6; border-top-left-radius: calc(.3rem - 1px); border-top-right-radius: calc(.3rem - 1px); }
  .modal-title { margin-bottom: 0; line-height: 1.5; margin-top: 0; }
  .modal-body { position: relative; flex: 1 1 auto; padding: 1rem; }
  .modal-footer { display: flex; flex-wrap: wrap; align-items: center; justify-content: flex-end; padding: .75rem; border-top: 1px solid #dee2e6; border-bottom-right-radius: calc(.3rem - 1px); border-bottom-left-radius: calc(.3rem - 1px); gap: .5rem; }
  .btn-close { box-sizing: content-box; width: 1em; height: 1em; padding: .25em .25em; color: #000; border: 0; border-radius: .25rem; opacity: .5; background: transparent; cursor: pointer; font-size: 1.5rem; line-height: 1; }
  .btn-close::before { content: "×"; }
  .btn-close:hover { color: #000; text-decoration: none; opacity: .75; }

  /* ── Layout blocks ── */
  .area-block   { border: 2px solid var(--primary); border-radius: 10px; margin-bottom: 28px; }
  .area-header  { background: var(--primary); color: #fff; padding: 10px 18px; font-weight: 700; border-radius: 8px 8px 0 0; display: flex; justify-content: space-between; align-items: center; }
  .shelf-block  { border: 1px solid #dee2e6; border-radius: 8px; margin: 12px; }
  .shelf-header { background: #eef2ff; padding: 7px 14px; font-weight: 600; border-radius: 8px 8px 0 0; font-size: .92rem; display: flex; justify-content: space-between; align-items: center; }
  .copy-row:hover { background: #f8f9fa; }
  .highlight    { background: #fff3cd !important; }
  .badge { display: inline-block; padding: 0.35em 0.65em; font-size: 0.75em; font-weight: 700; line-height: 1; color: #fff; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: 0.25rem; }
  .badge-AVAILABLE   { background: #198754; color: #fff; }
  .badge-BORROWED    { background: #dc3545; color: #fff; }
  .badge-RESERVED    { background: #ffc107; color: #000; }
  .badge-MAINTENANCE { background: #6c757d; color: #fff; }
  .badge-LOST        { background: #343a40; color: #fff; }
  .filter-card { border: 1.5px solid #c7d7ff; border-radius: 10px; background: #f6f8ff; }
  .area-unplaced { border-color: #fd7e14; }
  .area-unplaced .area-header { background: #fd7e14; }
  .btn-move { font-size: .78rem; padding: 2px 10px; }
  .toggle-shelf { cursor: pointer; user-select: none; }
  .toggle-shelf:hover { color: var(--primary); }
</style>

<div class="books-page-header">
    <div class="container">
        <div class="books-page-header-inner">
            <div>
                <div class="hero-eyebrow" style="margin-bottom:10px;">
                    <i class="fa-solid fa-layer-group"></i> Kệ sách
                </div>
                <h1 class="books-page-title">Sơ đồ kho thư viện</h1>
                <p class="books-page-subtitle">Quản lý vị trí các bản sao sách trên kệ trong thư viện</p>
            </div>
            <div class="books-page-stats">
                <div class="bps-item">
                    <span class="bps-num">${totalFiltered}</span>
                    <span class="bps-lbl">
                        <c:choose>
                            <c:when test="${hasFilter}">Tìm thấy</c:when>
                            <c:otherwise>Tổng kho</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container py-4">
            <c:if test="${successMsg == 'updated' or successMsg == 'moved'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-1"></i>
                    Cập nhật vị trí thành công.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- ════════════════════════════════════════════════
                 BỘ LỌC CASCADE: Tầng → Kệ → Ngăn
            ════════════════════════════════════════════════ -->
            <!-- ════════════════════════════════════════════════
                 BỘ LỌC VÀ TÌM KIẾM
            ════════════════════════════════════════════════ -->
            <div style="background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; margin-bottom: 30px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <div style="display: flex; flex-wrap: wrap; gap: 24px;">
                    
                    <!-- Lọc theo vị trí -->
                    <div style="flex: 2; min-width: 300px;">
                        <div style="font-weight: 600; color: #111827; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-filter" style="color: var(--primary);"></i> Lọc theo vị trí
                        </div>
                        <form method="get" action="shelf" id="filterForm" style="display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="action" value="filter">
                            <div style="flex: 1; min-width: 120px;">
                                <label style="display: block; font-size: 13px; font-weight: 500; color: #4b5563; margin-bottom: 6px;">Tầng</label>
                                <select name="filterArea" id="selArea" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; color: #111827; background-color: #f9fafb;">
                                    <option value="">-- Tất cả tầng --</option>
                                    <c:forEach var="a" items="${allAreas}">
                                        <option value="${a}" ${filterArea == a ? 'selected' : ''}>${a}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div style="flex: 1; min-width: 120px;">
                                <label style="display: block; font-size: 13px; font-weight: 500; color: #4b5563; margin-bottom: 6px;">Kệ</label>
                                <select name="filterShelf" id="selShelf" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; color: #111827; background-color: #f9fafb;">
                                    <option value="">-- Tất cả kệ --</option>
                                </select>
                            </div>
                            <div style="flex: 1; min-width: 120px;">
                                <label style="display: block; font-size: 13px; font-weight: 500; color: #4b5563; margin-bottom: 6px;">Ngăn</label>
                                <select name="filterSlot" id="selSlot" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; color: #111827; background-color: #f9fafb;">
                                    <option value="">-- Tất cả ngăn --</option>
                                </select>
                            </div>
                            <div style="display: flex; gap: 8px;">
                                <button type="submit" style="background: linear-gradient(135deg,var(--primary),var(--primary-dark)); color: white; border: none; padding: 8px 16px; border-radius: 6px; font-weight: 500; font-size: 14px; cursor: pointer; transition: background 0.2s;">
                                    Lọc
                                </button>
                                <a href="shelf?action=layout" style="background: white; color: #4b5563; border: 1px solid #d1d5db; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-weight: 500; font-size: 14px; transition: background 0.2s;">
                                    Xóa lọc
                                </a>
                            </div>
                        </form>
                    </div>

                    <!-- Tìm kiếm barcode -->
                    <div style="flex: 1; min-width: 250px; border-left: 1px dashed #d1d5db; padding-left: 24px;">
                        <div style="font-weight: 600; color: #111827; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                            <i class="fa-solid fa-barcode" style="color: var(--primary);"></i> Tìm theo Barcode
                        </div>
                        <form method="get" action="shelf" style="display: flex; gap: 8px; align-items: stretch;">
                            <input type="hidden" name="action" value="search">
                            <div style="flex: 1;">
                                <input type="text" name="barcode" value="${searchBarcode}" placeholder="Nhập mã barcode..." required 
                                       style="width: 100%; height: 100%; box-sizing: border-box; margin: 0; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; color: #111827; background-color: #f9fafb;">
                            </div>
                            <button type="submit" style="margin: 0; box-sizing: border-box; background: linear-gradient(135deg,var(--primary),var(--primary-dark)); color: white; border: none; padding: 0 16px; border-radius: 6px; font-weight: 500; font-size: 14px; cursor: pointer; transition: background 0.2s; display: flex; align-items: center; justify-content: center; gap: 6px;">
                                <i class="fa-solid fa-magnifying-glass"></i> Tìm
                            </button>
                        </form>
                    </div>

                </div>
            </div>

                <!-- Kết quả tìm barcode -->
                <c:if test="${searchBarcode != null}">
                    <div class="mt-2">
                        <c:choose>
                            <c:when test="${foundCopy != null}">
                                <div class="alert alert-success py-2 mb-0">
                                    Tìm thấy: <strong>${foundCopy.barcode}</strong> —
                                    Sách: <strong>${foundCopy.book.title}</strong> —
                                    Vị trí: <strong>${foundCopy.area != null ? foundCopy.area : 'Chưa xếp'} /
                                        ${foundCopy.shelf != null ? foundCopy.shelf : '–'} /
                                        ${foundCopy.slot  != null ? foundCopy.slot  : '–'}</strong> —
                                    Trạng thái: <strong>${foundCopy.status}</strong>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-warning py-2 mb-0">
                                    Không tìm thấy barcode "<strong>${searchBarcode}</strong>".
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

            <!-- ════════════════════════════════════════════════
                 SƠ ĐỒ KHO
            ════════════════════════════════════════════════ -->
            <c:choose>
                <c:when test="${empty layout}">
                    <div class="text-center text-muted py-5">
                        <div class="fs-4">📭</div>
                        Không có bản sao nào phù hợp với bộ lọc.
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="areaEntry" items="${layout}">
                        <div class="area-block shadow-sm ${areaEntry.key == 'Chưa xếp' ? 'area-unplaced' : ''}">
                            <div class="area-header">
                                <span>
                                    ${areaEntry.key == 'Chưa xếp' ? '⚠️' : '🏢'} ${areaEntry.key}
                                </span>
                                <span class="badge bg-white text-dark fw-normal fs-6 ms-2">
                                    <c:set var="areaCount" value="0"/>
                                    <c:forEach var="shelfEntry" items="${areaEntry.value}">
                                        <c:set var="areaCount" value="${areaCount + shelfEntry.value.size()}"/>
                                    </c:forEach>
                                    ${areaCount} bản sao
                                </span>
                            </div>

                            <div class="p-2">
                                <c:forEach var="shelfEntry" items="${areaEntry.value}">
                                    <div class="shelf-block mb-2">
                                        <div class="shelf-header">
                                            <span class="toggle-shelf"
                                                  onclick="toggleShelf(this)"
                                                  data-target="shelf-${areaEntry.key}-${shelfEntry.key}">
                                                ▾ Kệ: <strong>${shelfEntry.key}</strong>
                                            </span>
                                            <span class="text-muted small">
                                                ${shelfEntry.value.size()} bản sao
                                            </span>
                                        </div>

                                        <div id="shelf-${areaEntry.key}-${shelfEntry.key}">
                                            <div class="data-table-wrap" style="overflow-x: auto;">
                                                <table class="data-table" style="width: 100%; min-width: 1100px; table-layout: auto;">
                                                    <thead>
                                                        <tr>
                                                            <th style="text-align:left; width: 120px; white-space: nowrap;">Barcode</th>
                                                            <th style="text-align:left; width: 100px; white-space: nowrap;">Ngăn</th>
                                                            <th style="text-align:left; min-width: 320px; white-space: nowrap;">Tên sách</th>
                                                            <th style="text-align:left; width: 120px; white-space: nowrap;">Tình trạng</th>
                                                            <th style="text-align:left; width: 120px; white-space: nowrap;">Trạng thái</th>
                                                            <th style="text-align:center; width: 180px; min-width: 180px; white-space: nowrap;">Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="copy" items="${shelfEntry.value}">
                                                            <tr class="copy-row
                                                                ${not empty foundCopy and foundCopy.id == copy.id ? 'highlight' : ''}">
                                                                <td><code>${copy.barcode}</code></td>
                                                                <td>${copy.slot != null ? copy.slot : '–'}</td>
                                                                <td class="text-truncate" style="max-width:350px"
                                                                    title="${copy.book.title}">
                                                                    ${copy.book.title}
                                                                </td>
                                                                <td>${copy.bookCondition}</td>
                                                                <td>
                                                                    <span class="badge badge-${copy.status} px-2 py-1">
                                                                        ${copy.status}
                                                                    </span>
                                                                </td>
                                                                <td style="text-align: center; white-space: nowrap;">
                                                                    <div style="display: flex; gap: 8px; justify-content: center; align-items: center; flex-wrap: nowrap;">
                                                                        <%-- LIBRARIAN & ADMIN đều có thể chuyển vị trí --%>
                                                                        <button type="button"
                                                                                data-copyid="${copy.id}"
                                                                                data-barcode="${copy.barcode}"
                                                                                data-title="${copy.book.title}"
                                                                                data-area="${copy.area}"
                                                                                data-shelf="${copy.shelf}"
                                                                                data-slot="${copy.slot}"
                                                                                onclick="openMoveModal(this)"
                                                                                style="border: 1px solid #d1d5db; padding: 6px 12px; border-radius: 6px; text-decoration: none; color: #d97706; font-weight: 500; background: white; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                                                                            <i class="fa-solid fa-arrows-up-down-left-right"></i> Chuyển
                                                                        </button>
                                                                        <%-- ADMIN còn có thêm nút sửa đầy đủ --%>
                                                                        <c:if test="${sessionScope.loggedUser.role == 'ADMIN'}">
                                                                            <a href="shelf?action=editForm&copyId=${copy.id}"
                                                                               style="border: 1px solid #d1d5db; padding: 6px 12px; border-radius: 6px; text-decoration: none; color: var(--primary); font-weight: 500; background: white; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
                                                                                <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                                            </a>
                                                                        </c:if>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div><%-- end shelf collapse div --%>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>

        <!-- ===== PAGINATION ===== -->
        <c:if test="${totalPages > 1}">
            <div style="padding: 16px 24px; display: flex; justify-content: center;">
                <nav aria-label="Page navigation" class="pagination" style="display: inline-flex; gap: 6px; list-style: none; padding: 0; margin: 0;">
                    <c:set var="queryParams" value="&filterArea=${filterArea}&filterShelf=${filterShelf}&filterSlot=${filterSlot}" />
                    
                    <a class="page-link" href="shelf?action=layout${queryParams}&page=${currentPage - 1}" 
                       style="padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; text-decoration: none; color: #374151; font-weight: 500; background: white; ${currentPage == 1 ? 'pointer-events: none; opacity: 0.5;' : ''}">
                        <i class="fa-solid fa-angle-left"></i> Trước
                    </a>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                            <a class="page-link" href="shelf?action=layout${queryParams}&page=${i}" 
                               style="padding: 8px 14px; border: 1px solid ${i == currentPage ? 'var(--primary)' : '#d1d5db'}; border-radius: 6px; text-decoration: none; font-weight: 500; ${i == currentPage ? 'background: var(--primary); color: white;' : 'background: white; color: #374151;'}">
                                ${i}
                            </a>
                        </c:if>
                    </c:forEach>

                    <a class="page-link" href="shelf?action=layout${queryParams}&page=${currentPage + 1}" 
                       style="padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; text-decoration: none; color: #374151; font-weight: 500; background: white; ${currentPage == totalPages ? 'pointer-events: none; opacity: 0.5;' : ''}">
                        Sau <i class="fa-solid fa-angle-right"></i>
                    </a>
                </nav>
            </div>
        </c:if>

    </div><%-- end container --%>

        <!-- ════════════════════════════════════════════════
             MODAL: Chuyển vị trí bản sao (LIBRARIAN + ADMIN)
        ════════════════════════════════════════════════ -->
        <div class="modal fade" id="moveModal" tabindex="-1" aria-labelledby="moveModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="moveModalLabel">✏️ Chuyển vị trí bản sao</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <form method="post" action="shelf">
                        <input type="hidden" name="action" value="moveLocation">
                        <input type="hidden" name="copyId" id="moveCopyId">
                        <!-- Giữ lại filter hiện tại khi redirect về -->
                        <input type="hidden" name="filterArea"  value="${filterArea}">
                        <input type="hidden" name="filterShelf" value="${filterShelf}">
                        <input type="hidden" name="filterSlot"  value="${filterSlot}">

                        <div class="modal-body">
                            <!-- Thông tin bản sao -->
                            <div class="bg-light rounded p-3 mb-3">
                                <div class="small text-muted mb-1">Bản sao</div>
                                <div><code id="moveBarcode"></code></div>
                                <div class="text-truncate fw-semibold" id="moveBookTitle"></div>
                                <div class="small mt-1">
                                    Vị trí hiện tại:
                                    <span class="text-primary" id="moveCurrentLoc"></span>
                                </div>
                            </div>

                            <!-- Vị trí mới -->
                            <div class="mb-3">
                                <label class="form-label">
                                    Tầng mới <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="area" id="moveSelArea" required>
                                    <option value="">-- Chọn tầng --</option>
                                    <c:forEach var="a" items="${allAreas}">
                                        <c:if test="${a != 'Chưa xếp'}">
                                            <option value="${a}">${a}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">
                                    Kệ mới <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="shelf" id="moveSelShelf" required>
                                    <option value="">-- Chọn tầng trước --</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Ngăn mới</label>
                                <select class="form-select" name="slot" id="moveSelSlot">
                                    <option value="">-- Chọn kệ trước --</option>
                                </select>
                                <div class="form-text">Ngăn có thể để trống nếu chưa xác định.</div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-warning">💾 Lưu vị trí mới</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- ════════════════════════════════════════════════
             SCRIPTS
        ════════════════════════════════════════════════ -->

        <script>
                                                                                /* ── Collapse kệ ── */
                                                                                function toggleShelf(el) {
                                                                                    const targetId = el.dataset.target;
                                                                                    const target = document.getElementById(targetId);
                                                                                    if (!target)
                                                                                        return;
                                                                                    const isHidden = target.style.display === 'none';
                                                                                    target.style.display = isHidden ? '' : 'none';
                                                                                    el.textContent = el.textContent.replace(isHidden ? '▸' : '▾', isHidden ? '▾' : '▸');
                                                                                }

                                                                                /* ════════════════════════════════════════════════
                                                                                 CASCADE FILTER: Tầng → Kệ → Ngăn
                                                                                 ════════════════════════════════════════════════ */
                                                                                const selArea = document.getElementById('selArea');
                                                                                const selShelf = document.getElementById('selShelf');
                                                                                const selSlot = document.getElementById('selSlot');

                                                                                // Giá trị filter đang active (từ server)
                                                                                const activeArea = '${filterArea}';
                                                                                const activeShelf = '${filterShelf}';
                                                                                const activeSlot = '${filterSlot}';

                                                                                /** Xóa và disable một select, chỉ giữ lại option đầu */
                                                                                function resetSelect(sel, placeholder) {
                                                                                    sel.innerHTML = `<option value="">${placeholder}</option>`;
                                                                                    sel.disabled = true;
                                                                                }

                                                                                /** Tải danh sách kệ theo tầng đã chọn */
                                                                                function loadShelves(area, selectedShelf) {
                                                                                    resetSelect(selShelf, '-- Tất cả kệ --');
                                                                                    resetSelect(selSlot, '-- Tất cả ngăn --');
                                                                                    if (!area) {
                                                                                        selShelf.disabled = false;
                                                                                        return;
                                                                                    }

                                                                                    fetch('shelf?action=getShelves&area=' + encodeURIComponent(area))
                                                                                            .then(r => r.json())
                                                                                            .then(shelves => {
                                                                                                selShelf.disabled = false;
                                                                                                shelves.forEach(s => {
                                                                                                    const opt = new Option(s, s);
                                                                                                    if (s === selectedShelf)
                                                                                                        opt.selected = true;
                                                                                                    selShelf.appendChild(opt);
                                                                                                });
                                                                                                // Nếu có shelf đang chọn → load tiếp slot
                                                                                                if (selectedShelf)
                                                                                                    loadSlots(area, selectedShelf, activeSlot);
                                                                                            });
                                                                                }

                                                                                /** Tải danh sách ngăn theo tầng + kệ */
                                                                                function loadSlots(area, shelf, selectedSlot) {
                                                                                    resetSelect(selSlot, '-- Tất cả ngăn --');
                                                                                    if (!shelf) {
                                                                                        selSlot.disabled = false;
                                                                                        return;
                                                                                    }

                                                                                    fetch('shelf?action=getSlots&area=' + encodeURIComponent(area) + '&shelf=' + encodeURIComponent(shelf))
                                                                                            .then(r => r.json())
                                                                                            .then(slots => {
                                                                                                selSlot.disabled = false;
                                                                                                slots.forEach(s => {
                                                                                                    const opt = new Option(s, s);
                                                                                                    if (s === selectedSlot)
                                                                                                        opt.selected = true;
                                                                                                    selSlot.appendChild(opt);
                                                                                                });
                                                                                            });
                                                                                }

                                                                                // Sự kiện thay đổi dropdown filter
                                                                                selArea.addEventListener('change', () => {
                                                                                    loadShelves(selArea.value, '');
                                                                                });
                                                                                selShelf.addEventListener('change', () => {
                                                                                    loadSlots(selArea.value, selShelf.value, '');
                                                                                });

                                                                                // Khởi tạo: điền lại giá trị filter đang active khi trang load
                                                                                (function initFilter() {
                                                                                    selShelf.disabled = true;
                                                                                    selSlot.disabled = true;
                                                                                    if (activeArea)
                                                                                        loadShelves(activeArea, activeShelf);
                                                                                })();


                                                                                /* ════════════════════════════════════════════════
                                                                                 MODAL CHUYỂN VỊ TRÍ
                                                                                 ════════════════════════════════════════════════ */
                                                                                const moveSelArea = document.getElementById('moveSelArea');
                                                                                const moveSelShelf = document.getElementById('moveSelShelf');
                                                                                const moveSelSlot = document.getElementById('moveSelSlot');

                                                                                function openMoveModal(btn) {
                                                                                    const copyId = btn.dataset.copyid;
                                                                                    const barcode = btn.dataset.barcode;
                                                                                    const title = btn.dataset.title;
                                                                                    const curArea = btn.dataset.area || '';
                                                                                    const curShelf = btn.dataset.shelf || '';
                                                                                    const curSlot = btn.dataset.slot || '';

                                                                                    document.getElementById('moveCopyId').value = copyId;
                                                                                    document.getElementById('moveBarcode').textContent = barcode;
                                                                                    document.getElementById('moveBookTitle').textContent = title;

                                                                                    const locParts = [curArea || 'Chưa xếp', curShelf || '–', curSlot || '–'];
                                                                                    document.getElementById('moveCurrentLoc').textContent = locParts.join(' / ');

                                                                                    resetMoveShelf('-- Chọn tầng trước --');
                                                                                    resetMoveSlot('-- Chọn kệ trước --');

                                                                                    if (curArea) {
                                                                                        moveSelArea.value = curArea;
                                                                                        loadMoveShelves(curArea, curShelf, curSlot);
                                                                                    } else {
                                                                                        moveSelArea.value = '';
                                                                                    }

                                                                                    document.getElementById('moveModal').classList.add('show');
                                                                                }

                                                                                // Vanilla JS modal close handlers
                                                                                document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(btn => {
                                                                                    btn.addEventListener('click', function() {
                                                                                        const modal = this.closest('.modal');
                                                                                        if (modal) modal.classList.remove('show');
                                                                                    });
                                                                                });

                                                                                function resetMoveShelf(placeholder) {
                                                                                    moveSelShelf.innerHTML = `<option value="">${placeholder}</option>`;
                                                                                    moveSelShelf.disabled = true;
                                                                                }
                                                                                function resetMoveSlot(placeholder) {
                                                                                    moveSelSlot.innerHTML = `<option value="">${placeholder}</option>`;
                                                                                    moveSelSlot.disabled = true;
                                                                                }

                                                                                function loadMoveShelves(area, selectedShelf, selectedSlot) {
                                                                                    resetMoveShelf('-- Đang tải... --');
                                                                                    resetMoveSlot('-- Chọn kệ trước --');
                                                                                    if (!area) {
                                                                                        moveSelShelf.disabled = false;
                                                                                        return;
                                                                                    }

                                                                                    fetch('shelf?action=getShelves&area=' + encodeURIComponent(area))
                                                                                            .then(r => r.json())
                                                                                            .then(shelves => {
                                                                                                moveSelShelf.innerHTML = '<option value="">-- Chọn kệ --</option>';
                                                                                                moveSelShelf.disabled = false;
                                                                                                shelves.forEach(s => {
                                                                                                    const opt = new Option(s, s);
                                                                                                    if (s === selectedShelf)
                                                                                                        opt.selected = true;
                                                                                                    moveSelShelf.appendChild(opt);
                                                                                                });
                                                                                                if (selectedShelf)
                                                                                                    loadMoveSlots(area, selectedShelf, selectedSlot);
                                                                                            });
                                                                                }

                                                                                function loadMoveSlots(area, shelf, selectedSlot) {
                                                                                    resetMoveSlot('-- Đang tải... --');
                                                                                    if (!shelf) {
                                                                                        moveSelSlot.disabled = false;
                                                                                        return;
                                                                                    }

                                                                                    fetch('shelf?action=getSlots&area=' + encodeURIComponent(area) + '&shelf=' + encodeURIComponent(shelf))
                                                                                            .then(r => r.json())
                                                                                            .then(slots => {
                                                                                                moveSelSlot.innerHTML = '<option value="">-- Chọn ngăn (tuỳ chọn) --</option>';
                                                                                                moveSelSlot.disabled = false;
                                                                                                slots.forEach(s => {
                                                                                                    const opt = new Option(s, s);
                                                                                                    if (s === selectedSlot)
                                                                                                        opt.selected = true;
                                                                                                    moveSelSlot.appendChild(opt);
                                                                                                });
                                                                                            });
                                                                                }

                                                                                // Cascade trong modal
                                                                                moveSelArea.addEventListener('change', () => {
                                                                                    loadMoveShelves(moveSelArea.value, '', '');
                                                                                });
                                                                                moveSelShelf.addEventListener('change', () => {
                                                                                    loadMoveSlots(moveSelArea.value, moveSelShelf.value, '');
                                                                                });
        </script>
    </body>
</html>
