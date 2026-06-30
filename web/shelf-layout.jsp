<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Sơ đồ kho thư viện</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <style>
            /* ── Layout blocks ── */
            .area-block   {
                border: 2px solid #0d6efd;
                border-radius: 10px;
                margin-bottom: 28px;
            }
            .area-header  {
                background: #0d6efd;
                color: #fff;
                padding: 10px 18px;
                font-weight: 700;
                border-radius: 8px 8px 0 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .shelf-block  {
                border: 1px solid #dee2e6;
                border-radius: 8px;
                margin: 12px;
            }
            .shelf-header {
                background: #eef2ff;
                padding: 7px 14px;
                font-weight: 600;
                border-radius: 8px 8px 0 0;
                font-size: .92rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .copy-row:hover {
                background: #f8f9fa;
            }
            .highlight    {
                background: #fff3cd !important;
            }

            /* ── Status badges ── */
            .badge-AVAILABLE   {
                background: #198754;
                color: #fff;
            }
            .badge-BORROWED    {
                background: #dc3545;
                color: #fff;
            }
            .badge-RESERVED    {
                background: #ffc107;
                color: #000;
            }
            .badge-MAINTENANCE {
                background: #6c757d;
                color: #fff;
            }
            .badge-LOST        {
                background: #343a40;
                color: #fff;
            }

            /* ── Filter card ── */
            .filter-card {
                border: 1.5px solid #c7d7ff;
                border-radius: 10px;
                background: #f6f8ff;
            }

            /* ── Unplaced warning ── */
            .area-unplaced {
                border-color: #fd7e14;
            }
            .area-unplaced .area-header {
                background: #fd7e14;
            }

            /* ── Move button ── */
            .btn-move {
                font-size: .78rem;
                padding: 2px 10px;
            }

            /* ── Collapse toggle ── */
            .toggle-shelf {
                cursor: pointer;
                user-select: none;
            }
            .toggle-shelf:hover {
                color: #0d6efd;
            }
        </style>
    </head>
    <body class="bg-light">
        <div class="container-fluid py-4" style="max-width: 1400px;">

            <!-- ── Header ── -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-3">
                    <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm">← Quay lại</a>
                    <h4 class="mb-0 fw-bold">📚 Sơ đồ kho thư viện</h4>
                </div>
                <div class="text-muted small">
                    <c:choose>
                        <c:when test="${hasFilter}">
                            Tìm thấy <strong>${totalFiltered}</strong> bản sao phù hợp
                        </c:when>
                        <c:otherwise>
                            Tổng: <strong>${totalFiltered}</strong> bản sao
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- ── Toast thành công ── -->
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
            <div class="filter-card p-3 mb-4 shadow-sm">
                <div class="fw-semibold mb-2">🔍 Lọc theo vị trí</div>
                <form method="get" action="shelf" id="filterForm" class="row g-2 align-items-end">
                    <input type="hidden" name="action" value="filter">

                    <!-- Tầng -->
                    <div class="col-md-3">
                        <label class="form-label form-label-sm mb-1">Tầng</label>
                        <select class="form-select form-select-sm" name="filterArea" id="selArea">
                            <option value="">-- Tất cả tầng --</option>
                            <c:forEach var="a" items="${allAreas}">
                                <option value="${a}" ${filterArea == a ? 'selected' : ''}>${a}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Kệ (tải động qua AJAX) -->
                    <div class="col-md-3">
                        <label class="form-label form-label-sm mb-1">Kệ</label>
                        <select class="form-select form-select-sm" name="filterShelf" id="selShelf">
                            <option value="">-- Tất cả kệ --</option>
                            <%-- Options sẽ được điền bởi JS khi có filterArea;
                                 option được chọn cũng được điền lại bởi JS --%>
                        </select>
                    </div>

                    <!-- Ngăn (tải động qua AJAX) -->
                    <div class="col-md-3">
                        <label class="form-label form-label-sm mb-1">Ngăn</label>
                        <select class="form-select form-select-sm" name="filterSlot" id="selSlot">
                            <option value="">-- Tất cả ngăn --</option>
                        </select>
                    </div>

                    <!-- Nút -->
                    <div class="col-auto">
                        <button type="submit" class="btn btn-primary btn-sm">Lọc</button>
                        <a href="shelf?action=layout" class="btn btn-outline-secondary btn-sm ms-1">Xem tất cả</a>
                    </div>
                </form>

                <!-- Tìm kiếm barcode -->
                <hr class="my-2">
                <form method="get" action="shelf" class="row g-2 align-items-end">
                    <input type="hidden" name="action" value="search">
                    <div class="col-md-4">
                        <label class="form-label form-label-sm mb-1">Tìm theo barcode</label>
                        <input type="text" class="form-control form-control-sm" name="barcode"
                               value="${searchBarcode}" placeholder="Nhập barcode bản sao...">
                    </div>
                    <div class="col-auto">
                        <button type="submit" class="btn btn-secondary btn-sm">Tìm</button>
                    </div>
                </form>

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
            </div>

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
                                            <div class="table-responsive">
                                                <table class="table table-sm mb-0">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>Barcode</th>
                                                            <th>Ngăn</th>
                                                            <th>Tên sách</th>
                                                            <th>Tình trạng</th>
                                                            <th>Trạng thái</th>
                                                            <th style="width:110px"></th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="copy" items="${shelfEntry.value}">
                                                            <tr class="copy-row
                                                                ${not empty foundCopy and foundCopy.id == copy.id ? 'highlight' : ''}">
                                                                <td><code>${copy.barcode}</code></td>
                                                                <td>${copy.slot != null ? copy.slot : '–'}</td>
                                                                <td class="text-truncate" style="max-width:260px"
                                                                    title="${copy.book.title}">
                                                                    ${copy.book.title}
                                                                </td>
                                                                <td>${copy.bookCondition}</td>
                                                                <td>
                                                                    <span class="badge badge-${copy.status} px-2 py-1">
                                                                        ${copy.status}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <%-- LIBRARIAN & ADMIN đều có thể chuyển vị trí --%>
                                                                    <button type="button"
                                                                            class="btn btn-outline-warning btn-move"
                                                                            data-copyid="${copy.id}"
                                                                            data-barcode="${copy.barcode}"
                                                                            data-title="${copy.book.title}"
                                                                            data-area="${copy.area}"
                                                                            data-shelf="${copy.shelf}"
                                                                            data-slot="${copy.slot}"
                                                                            onclick="openMoveModal(this)">
                                                                        ✏️ Chuyển vị trí
                                                                    </button>
                                                                    <%-- ADMIN còn có thêm nút sửa đầy đủ --%>
                                                                    <c:if test="${sessionScope.loggedUser.role == 'ADMIN'}">
                                                                        <a href="shelf?action=editForm&copyId=${copy.id}"
                                                                           class="btn btn-outline-primary btn-move ms-1">
                                                                            Sửa
                                                                        </a>
                                                                    </c:if>
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
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

                                                                                    new bootstrap.Modal(document.getElementById('moveModal')).show();
                                                                                }

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
