package model;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

public class BookLocation {
    private int id;
    private String area;
    private String shelf;
    private String slot;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private Set<BookCopy> bookCopies = new HashSet<>();

    public BookLocation() {}

    public BookLocation(String area, String shelf, String slot, String description) {
        this.area = area;
        this.shelf = shelf;
        this.slot = slot;
        this.description = description;
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

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getShelf() {
        return shelf;
    }

    public void setShelf(String shelf) {
        this.shelf = shelf;
    }

    public String getSlot() {
        return slot;
    }

    public void setSlot(String slot) {
        this.slot = slot;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public Set<BookCopy> getBookCopies() {
        return bookCopies;
    }

    public void setBookCopies(Set<BookCopy> bookCopies) {
        this.bookCopies = bookCopies;
    }

    @Override
    public String toString() {
        return "BookLocation{" +
                "id=" + id +
                ", area='" + area + '\'' +
                ", shelf='" + shelf + '\'' +
                ", slot='" + slot + '\'' +
                ", description='" + description + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}

