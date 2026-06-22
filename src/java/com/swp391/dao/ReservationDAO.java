package com.swp391.dao;

import com.swp391.model.ReservationRecord;
import java.util.List;

/**
 * DAO interface cho nghiệp vụ đặt trước sách.
 * Spec: library-rules-spec-v2.md §1.1, §1.3, §4.2
 */
public interface ReservationDAO {

    /** §1.3 User tạo phiếu đặt trước (kiểm tra ngưỡng §1.1 trước khi gọi hàm này) */
    ReservationRecord create(int userId, int bookId) throws Exception;

    /** §4.2 Librarian/Admin xác nhận phiếu → status=READY, trigger notification #3 */
    boolean confirm(int reservationId, String performedBy) throws Exception;

    /** §4.2 Hủy phiếu — User hủy của mình / Librarian hủy bất kỳ */
    boolean cancel(int reservationId, String performedBy) throws Exception;

    /** §1.4 Đếm reservation đang chờ của một cuốn sách (dùng kiểm tra gia hạn) */
    int countPendingReservations(int bookId) throws Exception;

    /** Tìm phiếu đặt trước theo ID */
    ReservationRecord findById(int id) throws Exception;

    /** User xem phiếu đặt trước của mình */
    List<ReservationRecord> getByUser(int userId) throws Exception;

    /** Librarian/Admin xem toàn bộ phiếu đặt trước (với bộ lọc) */
    List<ReservationRecord> getAll(String status, String keyword, int page, int pageSize) throws Exception;

    /** Đếm tổng phiếu đặt trước cho phân trang */
    int countAll(String status, String keyword) throws Exception;
}
