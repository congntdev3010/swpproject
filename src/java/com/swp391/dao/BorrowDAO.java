package com.swp391.dao;

import com.swp391.model.BorrowRecord;
import java.util.List;

/**
 * DAO interface cho nghiệp vụ mượn sách.
 * Spec: library-rules-spec-v2.md §1
 */
public interface BorrowDAO {

    /** §1.1 Đếm tổng số phiếu đang mượn + đặt trước của user */
    int countActiveBorrowsAndReservations(int userId) throws Exception;

    /** §1.1 Lấy giới hạn mượn tối đa theo hạng của user (mặc định 5 nếu chưa có hạng) */
    int getMaxBorrowLimit(int userId) throws Exception;

    /** §1.4 Kiểm tra điều kiện gia hạn sách */
    boolean canRenew(int borrowRecordId) throws Exception;

    /** Tạo phiếu mượn mới (Librarian/Admin checkout) */
    BorrowRecord createBorrow(BorrowRecord record) throws Exception;

    /** Gia hạn phiếu mượn (tăng dueDate thêm 14 ngày, renewalCount++) */
    boolean renewBorrow(int borrowRecordId, String performedBy) throws Exception;

    /** Trả sách (cập nhật returnDate, status=RETURNED, tăng available_copies) */
    boolean returnBook(int borrowRecordId, String performedBy) throws Exception;

    /** Lấy phiếu mượn theo ID */
    BorrowRecord findById(int id) throws Exception;

    /** Lấy danh sách phiếu đang mượn/quá hạn của user */
    List<BorrowRecord> getActiveBorrowsByUser(int userId) throws Exception;

    /** Lấy toàn bộ lịch sử mượn của user (bao gồm đã trả) */
    List<BorrowRecord> getAllBorrowsByUser(int userId) throws Exception;

    /** Lấy toàn bộ phiếu mượn (Librarian/Admin) với bộ lọc */
    List<BorrowRecord> getAllBorrows(String status, String keyword, int page, int pageSize) throws Exception;

    /** Đếm tổng phiếu mượn cho phân trang */
    int countAllBorrows(String status, String keyword) throws Exception;
}
