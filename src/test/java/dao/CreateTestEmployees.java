//package dao;
//
//import context.DBContext;
//
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.Statement;
//
///**
// * Tao 2 NHAN VIEN moi trong cung 1 store (branch 1) de test
// * tinh nang doi ca cho nhau.
// *
// * - Cung vị trí cong tac (position_id) -> duoc phep doi ca nhau
// * - Cung chi nhanh -> cung 1 store
// * - Co lich ca (>= 2 ngay tu hom nay) -> duoc phep tao don doi ca
// *
// * Chay lai nhieu lan duoc: script tu don dep tai khoan cu neu ton tai.
// */
//public class CreateTestEmployees {
//
//    private static final String USER_A = "test_nv_a";
//    private static final String USER_B = "test_nv_b";
//
//    private static final String PASS = "123456";
//
//    private static final int ROLE_EMPLOYEE = 5;
//    private static final int BRANCH_ID = 1;
//    private static final int POSITION_ID = 7;   // NV Ban Hang & Trung Bay
//    private static final int DEPARTMENT_ID = 5; // Ban phan Thu Ngian & Ban Hang
//
//    // Ca Sang 07-12 | Ca Chieu 12-17 | Ca Toi 17-22
//    private static final int SHIFT_MORNING = 1;
//    private static final int SHIFT_AFTERNOON = 2;
//    private static final int SHIFT_EVENING = 3;
//
//    public static void main(String[] args) throws Exception {
//
//        try (Connection c = DBContext.getConnection()) {
//
//            cleanUp(c);
//
//            int idA = createEmployee(c, USER_A, "NV Test An (Part-time)",
//                    "0901110001", "TEST001");
//            int idB = createEmployee(c, USER_B, "NV Test Binh (Part-time)",
//                    "0901110002", "TEST002");
//
//            System.out.println();
//            System.out.println("=== Tai khoan da tao ===");
//            System.out.println("  " + USER_A + " -> user_id=" + idA
//                    + " | password=" + PASS);
//            System.out.println("  " + USER_B + " -> user_id=" + idB
//                    + " | password=" + PASS);
//
//            // ---- Lich ca ----
//            // A: Ca Toi (ngay +7), Ca Sang (ngay +10)
//            // B: Ca Toi (ngay +8), Ca Sang (ngay +11)
//            // => A va B co cap ca o 2 ngay khac nhau -> doi ca duoc.
//            int s1 = insertSchedule(c, idA, SHIFT_EVENING, plus(7));
//            int s2 = insertSchedule(c, idB, SHIFT_EVENING, plus(8));
//            int s3 = insertSchedule(c, idA, SHIFT_MORNING, plus(10));
//            int s4 = insertSchedule(c, idB, SHIFT_MORNING, plus(11));
//
//            System.out.println();
//            System.out.println("=== Lich ca da tao ===");
//            System.out.println("  A: #" + s1 + " Ca Toi   " + plus(7));
//            System.out.println("  B: #" + s2 + " Ca Toi   " + plus(8));
//            System.out.println("  A: #" + s3 + " Ca Sang  " + plus(10));
//            System.out.println("  B: #" + s4 + " Ca Sang  " + plus(11));
//
//            System.out.println();
//            System.out.println("=== Cap ca co the doi cho nhau ===");
//            System.out.println("  A #" + s1 + " <-> B #" + s2
//                    + "   (Ca Toi, 2 ngay khac nhau)");
//            System.out.println("  A #" + s3 + " <-> B #" + s4
//                    + "   (Ca Sang, 2 ngay khac nhau)");
//
//            System.out.println();
//            System.out.println("=== Xac nhan ===");
//            verify(c, idA);
//            verify(c, idB);
//        }
//    }
//
//    // ------------------------------------------------------------------
//    private static void cleanUp(Connection c) throws Exception {
//        try (PreparedStatement ps = c.prepareStatement(
//                "SELECT id FROM users WHERE username IN (?, ?)")) {
//            ps.setString(1, USER_A);
//            ps.setString(2, USER_B);
//
//            try (ResultSet rs = ps.executeQuery()) {
//                while (rs.next()) {
//                    int uid = rs.getInt(1);
//
//                    try (PreparedStatement p2 = c.prepareStatement(
//                            "DELETE FROM shift_change_requests "
//                            + "WHERE requester_id = ? OR target_user_id = ?")) {
//                        p2.setInt(1, uid);
//                        p2.setInt(2, uid);
//                        p2.executeUpdate();
//                    }
//
//                    try (PreparedStatement p3 = c.prepareStatement(
//                            "DELETE FROM shift_schedules WHERE user_id = ?")) {
//                        p3.setInt(1, uid);
//                        p3.executeUpdate();
//                    }
//
//                    try (PreparedStatement p4 = c.prepareStatement(
//                            "DELETE FROM employee_profiles WHERE user_id = ?")) {
//                        p4.setInt(1, uid);
//                        p4.executeUpdate();
//                    }
//
//                    try (PreparedStatement p5 = c.prepareStatement(
//                            "DELETE FROM users WHERE id = ?")) {
//                        p5.setInt(1, uid);
//                        p5.executeUpdate();
//                    }
//
//                    System.out.println("Da xoa tai khoan cu: " + uid);
//                }
//            }
//        }
//    }
//
//    private static int createEmployee(
//            Connection c, String username, String fullName,
//            String phone, String identityCard) throws Exception {
//
//        int userId;
//        boolean autoGen = false;
//
//        try (PreparedStatement ps = c.prepareStatement(
//                "INSERT INTO users "
//                + "(username, password_hash, email, status, "
//                + " role_id, is_first_login, created_at, updated_at) "
//                + "VALUES (?, ?, ?, 'ACTIVE', ?, 0, NOW(), NOW())",
//                Statement.RETURN_GENERATED_KEYS)) {
//
//            ps.setString(1, username);
//            ps.setString(2, PASS);
//            ps.setString(3, username + "@supermarket.com");
//            ps.setInt(4, ROLE_EMPLOYEE);
//            ps.executeUpdate();
//
//            try (ResultSet rs = ps.getGeneratedKeys()) {
//                if (rs.next()) {
//                    userId = rs.getInt(1);
//                } else {
//                    throw new IllegalStateException(
//                            "Khong lay duoc user_id cho " + username);
//                }
//            }
//        }
//
//        try (PreparedStatement ps = c.prepareStatement(
//                "INSERT INTO employee_profiles "
//                + "(user_id, full_name, phone, identity_card, "
//                + " home_branch_id, position_id, department_id, "
//                + " employee_type, shift_type) "
//                + "VALUES (?, ?, ?, ?, ?, ?, ?, 'PART_TIME', 'Sang/Toi')")) {
//
//            ps.setInt(1, userId);
//            ps.setString(2, fullName);
//            ps.setString(3, phone);
//            ps.setString(4, identityCard);
//            ps.setInt(5, BRANCH_ID);
//            ps.setInt(6, POSITION_ID);
//            ps.setInt(7, DEPARTMENT_ID);
//            ps.executeUpdate();
//        }
//
//        return userId;
//    }
//
//    private static int insertSchedule(
//            Connection c, int userId, int shiftId, java.sql.Date date)
//            throws Exception {
//
//        try (PreparedStatement ps = c.prepareStatement(
//                "INSERT INTO shift_schedules "
//                + "(branch_id, user_id, shift_id, position_id, "
//                + " work_date, status) "
//                + "VALUES (?, ?, ?, ?, ?, 'PUBLISHED')",
//                Statement.RETURN_GENERATED_KEYS)) {
//
//            ps.setInt(1, BRANCH_ID);
//            ps.setInt(2, userId);
//            ps.setInt(3, shiftId);
//            ps.setInt(4, POSITION_ID);
//            ps.setDate(5, date);
//            ps.executeUpdate();
//
//            try (ResultSet rs = ps.getGeneratedKeys()) {
//                if (rs.next()) {
//                    return rs.getInt(1);
//                }
//            }
//        }
//        return -1;
//    }
//
//    private static void verify(Connection c, int userId) throws Exception {
//        try (PreparedStatement ps = c.prepareStatement(
//                "SELECT u.username, u.status, u.role_id, "
//                + "ep.full_name, ep.home_branch_id, ep.position_id, "
//                + "ep.employee_type "
//                + "FROM users u "
//                + "JOIN employee_profiles ep ON ep.user_id = u.id "
//                + "WHERE u.id = ?")) {
//
//            ps.setInt(1, userId);
//
//            try (ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    System.out.println("  " + rs.getString(1)
//                            + " | " + rs.getString(2)
//                            + " | role=" + rs.getInt(3)
//                            + " | " + rs.getString(4)
//                            + " | branch=" + rs.getInt(5)
//                            + " | pos=" + rs.getInt(6)
//                            + " | " + rs.getString(7));
//                }
//            }
//        }
//    }
//
//    private static java.sql.Date plus(int days) {
//        return java.sql.Date.valueOf(
//                java.time.LocalDate.now().plusDays(days));
//    }
//}
