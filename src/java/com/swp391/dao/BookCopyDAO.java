package com.swp391.dao;

import com.swp391.model.Book;
import com.swp391.model.BookCopy;
import java.sql.*;
import java.util.*;

public class BookCopyDAO {

    private Connection getConn() throws ClassNotFoundException, SQLException {
        return DBContext.getInstance().getConnection();
    }

    // Lấy danh sách bản sao theo book_id
    public List<BookCopy> getCopiesByBookId(int bookId) {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.book_id = ? ORDER BY bc.barcode";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy toàn bộ bản sao (cho F12 - sơ đồ kho)
    // Group by area -> shelf -> slot sẽ xử lý ở tầng JSP/Controller
    public List<BookCopy> getAllCopies() {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "ORDER BY bc.area, bc.shelf, bc.slot, bc.barcode";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tìm bản sao theo barcode (dùng cho F12 - tìm kiếm vị trí)
    public BookCopy findByBarcode(String barcode) {
        String sql = "SELECT bc.*, b.title, b.isbn FROM book_copies bc "
                + "JOIN books b ON bc.book_id = b.id "
                + "WHERE bc.barcode = ?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, barcode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy danh sách khu vực phân biệt (distinct areas)
    public List<String> getDistinctAreas() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT area FROM book_copies WHERE area IS NOT NULL ORDER BY area";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("area"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật vị trí bản sao (F13)
    public boolean updateLocation(int copyId, String area, String shelf, String slot) {
        String sql = "UPDATE book_copies SET area=?, shelf=?, slot=? WHERE id=?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, area);
            ps.setString(2, shelf);
            ps.setString(3, slot);
            ps.setInt(4, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Thêm bản sao mới
    public boolean addCopy(int bookId, String barcode, String area, String shelf, String slot) {
        String sql = "INSERT INTO book_copies (book_id, barcode, book_condition, status, area, shelf, slot) "
                + "VALUES (?, ?, 'GOOD', 'AVAILABLE', ?, ?, ?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setString(2, barcode);
            ps.setString(3, area);
            ps.setString(4, shelf);
            ps.setString(5, slot);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa bản sao (chỉ khi status = AVAILABLE)
    public boolean deleteCopy(int copyId) {
        String sql = "DELETE FROM book_copies WHERE id=? AND status='AVAILABLE'";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Map ResultSet → BookCopy
    private BookCopy mapRow(ResultSet rs) throws SQLException {
        BookCopy bc = new BookCopy();
        bc.setId(rs.getInt("id"));
        bc.setBookId(rs.getInt("book_id"));
        bc.setBarcode(rs.getString("barcode"));
        bc.setBookCondition(rs.getString("book_condition"));
        bc.setStatus(rs.getString("status"));
        bc.setNote(rs.getString("note"));
        bc.setArea(rs.getString("area"));
        bc.setShelf(rs.getString("shelf"));
        bc.setSlot(rs.getString("slot"));

        // Gán thông tin book vào object Book
        Book book = new Book();
        book.setId(rs.getInt("book_id"));
        book.setTitle(rs.getString("title"));
        book.setIsbn(rs.getString("isbn"));
        bc.setBook(book);

        return bc;
    }
}
