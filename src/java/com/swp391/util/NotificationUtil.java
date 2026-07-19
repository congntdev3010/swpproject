package com.swp391.util;

import com.swp391.dao.NotificationDAO;
import com.swp391.dao.NotificationDAOImpl;

/**
 * Utility class để trigger thông báo tự động từ các module khác.
 * Spec: library-rules-spec-v2.md §3.1
 *
 * 5 loại thông báo tự động:
 *   1. DUE_REMINDER    — Nhắc trả sách
 *   2. BOOK_AVAILABLE  — Sách đặt trước đã khả dụng
 *   3. RESERVATION_CONFIRMED — Thủ thư xác nhận phiếu đặt
 *   4. FINE_ISSUED     — Phát sinh tiền phạt
 *   5. ACCOUNT_LOCKED  — Tài khoản bị khóa
 */
public class NotificationUtil {

    private static final NotificationDAO notifDAO = new NotificationDAOImpl();

    /** §3.1 #1 Nhắc trả sách sắp đến hạn */
    public static void sendDueReminder(int userId, String bookTitle, String dueDate) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "DUE_REMINDER",
                "📅 Nhắc nhở trả sách",
                "Sách \"" + bookTitle + "\" sắp đến hạn trả vào ngày " + dueDate + ". Vui lòng trả đúng hạn để tránh phạt trễ hạn."
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** §3.1 #2 Sách đặt trước đã khả dụng */
    public static void sendBookAvailable(int userId, String bookTitle) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "BOOK_AVAILABLE",
                "📚 Sách đặt trước đã có sẵn",
                "Sách \"" + bookTitle + "\" bạn đặt trước đã có sẵn để đến nhận. Vui lòng đến thư viện trong thời gian sớm nhất."
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** §3.1 #3 Thủ thư xác nhận phiếu đặt trước */
    public static void sendReservationConfirmed(int userId, String bookTitle) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "RESERVATION_CONFIRMED",
                "✅ Phiếu đặt trước đã được xác nhận",
                "Phiếu đặt trước sách \"" + bookTitle + "\" của bạn đã được Thủ thư xác nhận. Sách sẽ được giữ cho bạn."
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** §3.1 #4 Phát sinh tiền phạt */
    public static void sendFineIssued(int userId, String reason, String amount) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "FINE_ISSUED",
                "💸 Thông báo phát sinh tiền phạt",
                "Bạn có một khoản phạt mới: " + reason + " — Số tiền: " + amount + " VND. Vui lòng thanh toán sớm để tránh bị khóa tài khoản."
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** §3.1 #5 Tài khoản bị khóa */
    public static void sendAccountLocked(int userId, String reason) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "ACCOUNT_LOCKED",
                "🔒 Tài khoản của bạn đã bị khóa",
                "Tài khoản của bạn đã bị khóa tạm thời vì: " + reason + ". Vui lòng liên hệ Thủ thư hoặc Admin để được hỗ trợ."
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendSystemMessage(int userId, String title, String message) {
        try {
            notifDAO.sendAutoNotification(
                userId,
                "SYSTEM",
                title,
                message
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
