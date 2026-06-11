package com.swp391.dao;

import java.sql.PreparedStatement;
import jakarta.resource.cci.ResultSet;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DBContext {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/library_management_swp391"
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASS = ""; // <-- điền password MySQL của bạn

    private static DBContext instance;
    protected Connection connection;

    private DBContext() throws ClassNotFoundException, SQLException {
        Class.forName(DRIVER);
        connection = DriverManager.getConnection(URL, USER, PASS);
    }

    public static DBContext getInstance() throws ClassNotFoundException, SQLException {
        if (instance == null || instance.connection.isClosed()) {
            instance = new DBContext();
        }
        return instance;
    }

    public Connection getConnection() {
        return connection;
    }

    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        try {
            Connection conn = DBContext.getInstance().getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("Ket noi MySQL thanh cong!");
                System.out.println("URL: " + URL);
            }
        } catch (ClassNotFoundException e) {
            System.out.println("Khong tim thay JDBC Driver: " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("Ket noi that bai: " + e.getMessage());
        }
    }
    // 1. Hàm lấy danh sách KỆ dựa theo TẦNG
    public List<String> getShelvesByArea(String area) {
        List<String> list = new ArrayList<>();
        // Câu lệnh SQL lấy các kệ không trùng lặp, bỏ qua giá trị rỗng/null
        String sql = "SELECT DISTINCT shelf FROM book_copy WHERE area = ? AND shelf IS NOT NULL AND shelf != ''"; 
        
        // Khởi tạo kết nối chạy theo cấu trúc DBContext Singleton của bạn
        try {
            Connection conn = DBContext.getInstance().getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, area);
                try (ResultSet rs = (ResultSet) ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(rs.getString("shelf"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Hàm lấy danh sách NGĂN dựa theo TẦNG và KỆ
    public List<String> getSlotsByShelf(String area, String shelf) {
        List<String> list = new ArrayList<>();
        // Câu lệnh SQL lấy các ngăn không trùng lặp, lọc chặt chẽ theo cả area và shelf
        String sql = "SELECT DISTINCT slot FROM book_copy WHERE area = ? AND shelf = ? AND slot IS NOT NULL AND slot != ''"; 
        
        try {
            Connection conn = DBContext.getInstance().getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, area);
                ps.setString(2, shelf);
                try (ResultSet rs = (ResultSet) ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(rs.getString("slot"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
