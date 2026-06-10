package model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class RenewRecord {
    private int id;
    private int borrowRecordId;
    private int renewCount;
    private LocalDate oldDueDate;
    private LocalDate newDueDate;
    private int renewDays;
    private int createdBy;
    private LocalDateTime createdAt;
    
    private BorrowRecord borrowRecord;
    private User createdByUser;

    public RenewRecord() {}

    public RenewRecord(int borrowRecordId, int renewCount, LocalDate oldDueDate, LocalDate newDueDate, int renewDays, int createdBy) {
        this.borrowRecordId = borrowRecordId;
        this.renewCount = renewCount;
        this.oldDueDate = oldDueDate;
        this.newDueDate = newDueDate;
        this.renewDays = renewDays;
        this.createdBy = createdBy;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getBorrowRecordId() {
        return borrowRecordId;
    }

    public void setBorrowRecordId(int borrowRecordId) {
        this.borrowRecordId = borrowRecordId;
    }

    public int getRenewCount() {
        return renewCount;
    }

    public void setRenewCount(int renewCount) {
        this.renewCount = renewCount;
    }

    public LocalDate getOldDueDate() {
        return oldDueDate;
    }

    public void setOldDueDate(LocalDate oldDueDate) {
        this.oldDueDate = oldDueDate;
    }

    public LocalDate getNewDueDate() {
        return newDueDate;
    }

    public void setNewDueDate(LocalDate newDueDate) {
        this.newDueDate = newDueDate;
    }

    public int getRenewDays() {
        return renewDays;
    }

    public void setRenewDays(int renewDays) {
        this.renewDays = renewDays;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public BorrowRecord getBorrowRecord() {
        return borrowRecord;
    }

    public void setBorrowRecord(BorrowRecord borrowRecord) {
        this.borrowRecord = borrowRecord;
    }

    public User getCreatedByUser() {
        return createdByUser;
    }

    public void setCreatedByUser(User createdByUser) {
        this.createdByUser = createdByUser;
    }

    @Override
    public String toString() {
        return "RenewRecord{" +
                "id=" + id +
                ", borrowRecordId=" + borrowRecordId +
                ", renewCount=" + renewCount +
                ", oldDueDate=" + oldDueDate +
                ", newDueDate=" + newDueDate +
                ", renewDays=" + renewDays +
                ", createdBy=" + createdBy +
                ", createdAt=" + createdAt +
                '}';
    }
}

