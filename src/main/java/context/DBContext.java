/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package context;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * File quản lý việc kết nối từ Java tới MySQL Server.
 *
 * @author phong
 */
public class DBContext {

    // Khai báo 4 thông số kết nối
    private static final String SERVER_NAME = "localhost";
    private static final String PORT_NUMBER = "3306";
    private static final String DB_NAME = "swp391_supermarket";
    private static final String USER_NAME = "root";
    private static final String PASSWORD = "Phong22042004@";

    public static Connection getConnection() throws Exception {
        // 1. Nạp Driver kết nối MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 2. Tạo chuỗi Connection URL
        // Ví dụ chuỗi URL kết nối chuẩn:
        String url = "jdbc:mysql://localhost:3306/swp391_supermarket?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true";

        // 3. Mở kết nối tới MySQL Database
        return DriverManager.getConnection(url, USER_NAME, PASSWORD);
    }

    // Hàm main dùng để TEST kết nối trực tiếp
    public static void main(String[] args) {
        try {
            Connection conn = DBContext.getConnection();
            if (conn != null) {
                System.out.println("-> KẾT NỐI DATABASE THÀNH CÔNG!");
            }
        } catch (Exception e) {
            System.out.println("-> KẾT NỐI THẤT BẠI: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
