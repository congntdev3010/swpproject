package model;

import java.time.LocalDateTime;

public class ReservationRecord {
    private int id;
    private int userId;
    private int bookId;
    private String status; // PENDING, READY, CLAIMED, CANCELLED
    private int queuePosition;
    private LocalDateTime requestDate;
    private LocalDateTime expiryDate;
    private LocalDateTime readyNotificationSentAt;
    private LocalDateTime readyExpiryDate;
    private LocalDateTime claimedDate;
    private String cancelledReason;
    private LocalDateTime cancelledAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private User user;
    private Book book;

    public ReservationRecord() {}

    public ReservationRecord(int userId, int bookId, String status, int queuePosition) {
        this.userId = userId;
        this.bookId = bookId;
        this.status = status;
        this.queuePosition = queuePosition;
        this.requestDate = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getQueuePosition() {
        return queuePosition;
    }

    public void setQueuePosition(int queuePosition) {
        this.queuePosition = queuePosition;
    }

    public LocalDateTime getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDateTime requestDate) {
        this.requestDate = requestDate;
    }

    public LocalDateTime getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDateTime expiryDate) {
        this.expiryDate = expiryDate;
    }

    public LocalDateTime getReadyNotificationSentAt() {
        return readyNotificationSentAt;
    }

    public void setReadyNotificationSentAt(LocalDateTime readyNotificationSentAt) {
        this.readyNotificationSentAt = readyNotificationSentAt;
    }

    public LocalDateTime getReadyExpiryDate() {
        return readyExpiryDate;
    }

    public void setReadyExpiryDate(LocalDateTime readyExpiryDate) {
        this.readyExpiryDate = readyExpiryDate;
    }

    public LocalDateTime getClaimedDate() {
        return claimedDate;
    }

    public void setClaimedDate(LocalDateTime claimedDate) {
        this.claimedDate = claimedDate;
    }

    public String getCancelledReason() {
        return cancelledReason;
    }

    public void setCancelledReason(String cancelledReason) {
        this.cancelledReason = cancelledReason;
    }

    public LocalDateTime getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(LocalDateTime cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Book getBook() {
        return book;
    }

    public void setBook(Book book) {
        this.book = book;
    }

    @Override
    public String toString() {
        return "ReservationRecord{" +
                "id=" + id +
                ", userId=" + userId +
                ", bookId=" + bookId +
                ", status='" + status + '\'' +
                ", queuePosition=" + queuePosition +
                ", requestDate=" + requestDate +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}

