package com.swp391.dao;

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
}
