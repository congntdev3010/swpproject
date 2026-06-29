package com.swp391.model;

import java.io.Serializable;

/**
 * Đối tượng đơn giản đại diện cho 1 sách trong giỏ mượn (session cart).
 * Không lưu vào DB, chỉ tồn tại trong session.
 */
public class BorrowCartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int bookId;
    private String bookTitle;
    private String bookIsbn;
    private String bookCategory;
    private int available; // số bản còn có thể mượn tại thời điểm thêm

    public BorrowCartItem() {}

    public BorrowCartItem(int bookId, String bookTitle, String bookIsbn, String bookCategory, int available) {
        this.bookId = bookId;
        this.bookTitle = bookTitle;
        this.bookIsbn = bookIsbn;
        this.bookCategory = bookCategory;
        this.available = available;
    }

    public int getBookId()                        { return bookId; }
    public void setBookId(int bookId)             { this.bookId = bookId; }

    public String getBookTitle()                  { return bookTitle; }
    public void setBookTitle(String bookTitle)    { this.bookTitle = bookTitle; }

    public String getBookIsbn()                   { return bookIsbn; }
    public void setBookIsbn(String bookIsbn)      { this.bookIsbn = bookIsbn; }

    public String getBookCategory()               { return bookCategory; }
    public void setBookCategory(String v)         { this.bookCategory = v; }

    public int getAvailable()                     { return available; }
    public void setAvailable(int available)       { this.available = available; }

    @Override
    public String toString() {
        return "BorrowCartItem{bookId=" + bookId + ", title='" + bookTitle + "'}";
    }
}
