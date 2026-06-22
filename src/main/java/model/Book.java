package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

public class Book {
    private int id;
    private String isbn;
    private String title;
    private int categoryId;
    private int subjectId;
    private int publisherId;
    private int publishYear;
    private String description;
    private String coverImage;
    private BigDecimal price;
    private int totalCopies;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private Category category;
    private Subject subject;
    private Publisher publisher;
    private Set<BookAuthor> bookAuthors = new HashSet<>();
    private Set<BookCopy> bookCopies = new HashSet<>();
    private Set<BorrowRecord> borrowRecords = new HashSet<>();
    private Set<ReservationRecord> reservationRecords = new HashSet<>();
    private Set<Fine> fines = new HashSet<>();

    public Book() {}

    public Book(String isbn, String title, int categoryId, BigDecimal price, int totalCopies) {
        this.isbn = isbn;
        this.title = title;
        this.categoryId = categoryId;
        this.price = price;
        this.totalCopies = totalCopies;
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

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public int getPublisherId() {
        return publisherId;
    }

    public void setPublisherId(int publisherId) {
        this.publisherId = publisherId;
    }

    public int getPublishYear() {
        return publishYear;
    }

    public void setPublishYear(int publishYear) {
        this.publishYear = publishYear;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getTotalCopies() {
        return totalCopies;
    }

    public void setTotalCopies(int totalCopies) {
        this.totalCopies = totalCopies;
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

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public Subject getSubject() {
        return subject;
    }

    public void setSubject(Subject subject) {
        this.subject = subject;
    }

    public Publisher getPublisher() {
        return publisher;
    }

    public void setPublisher(Publisher publisher) {
        this.publisher = publisher;
    }

    public Set<BookAuthor> getBookAuthors() {
        return bookAuthors;
    }

    public void setBookAuthors(Set<BookAuthor> bookAuthors) {
        this.bookAuthors = bookAuthors;
    }

    public Set<BookCopy> getBookCopies() {
        return bookCopies;
    }

    public void setBookCopies(Set<BookCopy> bookCopies) {
        this.bookCopies = bookCopies;
    }

    public Set<BorrowRecord> getBorrowRecords() {
        return borrowRecords;
    }

    public void setBorrowRecords(Set<BorrowRecord> borrowRecords) {
        this.borrowRecords = borrowRecords;
    }

    public Set<ReservationRecord> getReservationRecords() {
        return reservationRecords;
    }

    public void setReservationRecords(Set<ReservationRecord> reservationRecords) {
        this.reservationRecords = reservationRecords;
    }

    public Set<Fine> getFines() {
        return fines;
    }

    public void setFines(Set<Fine> fines) {
        this.fines = fines;
    }

    @Override
    public String toString() {
        return "Book{" +
                "id=" + id +
                ", isbn='" + isbn + '\'' +
                ", title='" + title + '\'' +
                ", categoryId=" + categoryId +
                ", subjectId=" + subjectId +
                ", publisherId=" + publisherId +
                ", publishYear=" + publishYear +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", totalCopies=" + totalCopies +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
