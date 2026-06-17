package com.swp391.dao;

import com.swp391.model.Author;
import com.swp391.model.Book;
import java.util.List;

/**
 * Interface BookDAO theo schema bảng books thực tế.
 */
public interface BookDAO {

    /**
     * Lấy danh sách N sách mới nhất (theo created_at DESC) dùng cho Homepage.
     */
    List<Book> getNewestBooks(int limit) throws Exception;

    /**
     * Tìm kiếm & lọc sách có phân trang và sắp xếp.
     *
     * @param keyword         từ khóa tìm kiếm theo title (LIKE), null/empty = bỏ qua
     * @param categoryFilter  tên danh mục lọc, null/empty = bỏ qua
     * @param sortField       cột sắp xếp: "title", "publish_year", "available", "price" — mặc định "title"
     * @param sortOrder       "ASC" hoặc "DESC"
     * @param page            trang hiện tại (bắt đầu từ 1)
     * @param pageSize        số bản ghi mỗi trang
     */
    List<Book> searchBooks(String keyword, String categoryFilter,
                           String sortField, String sortOrder,
                           int page, int pageSize) throws Exception;

    /**
     * Đếm tổng số bản ghi thỏa điều kiện tìm kiếm (dùng cho phân trang).
     */
    int countBooks(String keyword, String categoryFilter) throws Exception;

    /**
     * Lấy danh sách tên category duy nhất trong bảng books.
     */
    List<String> getAllCategories() throws Exception;

    /**
     * Tìm sách theo id.
     */
    Book findById(int id) throws Exception;

    /**
     * Thêm sách mới.
     * @return id sách mới sinh, hoặc -1 nếu thất bại
     */
    int createBook(Book book) throws Exception;

    /**
     * Cập nhật thông tin sách.
     */
    boolean updateBook(Book book) throws Exception;

    /**
     * Xóa mềm sách theo id.
     * Ném {@link IllegalStateException} nếu còn bản sao vật lý active.
     *
     * @param id        id sách cần xóa
     * @param deletedBy username của người thực hiện xóa
     */
    boolean deleteBook(int id, String deletedBy) throws Exception;

    /**
     * Kiểm tra ISBN có trùng lặp không.
     */
    boolean isIsbnExists(String isbn) throws Exception;

    /**
     * Kiểm tra ISBN có trùng với sách khác không (dùng khi sửa sách).
     */
    boolean isIsbnExistsExcluding(String isbn, int excludeId) throws Exception;

    /**
     * Kiểm tra sách có chứa bản sao vật lý không.
     */
    boolean hasPhysicalCopies(int bookId) throws Exception;

    /**
     * Kiểm tra sách có lượt mượn/đặt chỗ nào đang hoạt động không.
     */
    boolean hasActiveBorrowsOrReservations(int bookId) throws Exception;

    /**
     * Lấy danh sách tác giả của sách theo ID.
     */
    List<Author> getAuthorsByBookId(int bookId) throws Exception;

    /**
     * Lấy danh sách ID tác giả của sách theo ID.
     */
    List<Integer> getAuthorIdsByBookId(int bookId) throws Exception;

    /**
     * Thiết lập danh sách tác giả cho sách.
     */
    void setBookAuthors(int bookId, List<Integer> authorIds) throws Exception;
}
