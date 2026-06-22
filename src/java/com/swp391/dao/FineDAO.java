package com.swp391.dao;

import com.swp391.model.Fine;
import java.math.BigDecimal;
import java.util.List;

/**
 * DAO interface cho nghiệp vụ phạt.
 * Spec: library-rules-spec-v2.md §2
 */
public interface FineDAO {

    /**
     * §2.1 Tính overdue fine cho một phiếu mượn.
     * Trả về số tiền phạt (đã áp trần 30% giá sách).
     * Nếu vượt trần, tự động chuyển book_copy sang DAMAGED (§2.2).
     */
    BigDecimal calculateOverdueFine(int borrowRecordId) throws Exception;

    /** §2.3 Librarian tạo phiếu phạt hư hỏng (70% giá gốc) */
    Fine applyDamageFine(int borrowRecordId, String performedBy) throws Exception;

    /** §2.3 Librarian tạo phiếu phạt mất sách (100% giá gốc) */
    Fine applyLostFine(int borrowRecordId, String performedBy) throws Exception;

    /** Librarian tạo phiếu phạt thủ công (chung — bao gồm OVERDUE/DAMAGE/LOST) */
    Fine createFine(Fine fine) throws Exception;

    /** §4.2 Admin miễn giảm phạt (toàn quyền) */
    boolean waiveFine(int fineId, String adminUsername, String note) throws Exception;

    /** Librarian ghi nhận thanh toán */
    boolean markPaid(int fineId, String paymentMethod, String note) throws Exception;

    /** Lấy phiếu phạt theo ID */
    Fine findById(int id) throws Exception;

    /** User/Librarian/Admin xem phạt theo user */
    List<Fine> getFinesByUser(int userId) throws Exception;

    /** Librarian/Admin xem toàn bộ phiếu phạt (với bộ lọc) */
    List<Fine> getAllFines(String status, String keyword, int page, int pageSize) throws Exception;

    /** Đếm tổng phiếu phạt cho phân trang */
    int countAllFines(String status, String keyword) throws Exception;
}
