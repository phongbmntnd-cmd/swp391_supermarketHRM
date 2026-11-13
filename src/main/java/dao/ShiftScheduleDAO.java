package dao;

import context.DBContext;
import java.sql.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ShiftScheduleDAO {

    // 1. Lấy danh sách khóa các ca đã được phân công trong cơ sở để đồng bộ tích xanh
    // Lưu ý: chỉ lấy trong khoảng tuần đang xem. Trước đây lấy toàn bộ lịch của
    // cơ sở nên khi xem lại tuần cũ, các ca đã xếp ở tuần khác vẫn tồn tại trong
    // danh sách -> gây hiển thị sai trạng thái tích xanh.
    public List<String> getAssignedKeysByBranchId(int branchId) {
        return getAssignedKeysByBranchId(branchId, null, null);
    }

    public List<String> getAssignedKeysByBranchId(int branchId, String startDate, String endDate) {
        List<String> assignedList = new ArrayList<>();
        String sql;
        if (startDate != null && endDate != null) {
            sql = "SELECT user_id, shift_id, work_date FROM shift_schedules "
                    + "WHERE branch_id = ? AND work_date BETWEEN ? AND ?";
        } else {
            sql = "SELECT user_id, shift_id, work_date FROM shift_schedules WHERE branch_id = ?";
        }
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            if (startDate != null && endDate != null) {
                st.setDate(2, Date.valueOf(startDate));
                st.setDate(3, Date.valueOf(endDate));
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int dbUserId = rs.getInt("user_id");
                    int dbShiftId = rs.getInt("shift_id");
                    String dbDate = rs.getString("work_date");
                    String key = dbUserId + "_" + dbShiftId + "_" + dbDate;
                    assignedList.add(key);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return assignedList;
    }

    // 2. Kiểm tra xem ca trực đã tồn tại trong database chưa
    // Lưu ý: bỏ qua dòng đang 'ON_LEAVE' (nhân viên đã nghỉ phép được
    // duyệt). Dòng này phải được giữ nguyên để hệ thống còn biết
    // ca đó đã được chuyển cho nghỉ - không được xoá khi SM bấm lại.
    public boolean checkScheduleExists(int branchId, int userId, int shiftId, String workDate) {
        String sql = "SELECT id FROM shift_schedules WHERE branch_id = ? AND user_id = ? AND shift_id = ? AND work_date = ? AND status <> 'ON_LEAVE'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2b. Kiểm tra ca đang 'ON_LEAVE' (nhân viên đã nghỉ phép được duyệt).
    // Ca này KHÔNG được xoá và cũng KHÔNG được xếp thêm ca khác
    // cùng ngày cho nhân viên đó.
    public boolean checkOnLeaveSchedule(int branchId, int userId, int shiftId, String workDate) {
        String sql = "SELECT id FROM shift_schedules WHERE branch_id = ? AND user_id = ? AND shift_id = ? AND work_date = ? AND status = 'ON_LEAVE'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Thêm mới phân công ca (Lưu nháp - Draft)
    public void insertSchedule(int branchId, int userId, int shiftId, String workDate, int positionId) {
        String sql = "INSERT INTO shift_schedules (branch_id, user_id, shift_id, work_date, position_id, status) VALUES (?, ?, ?, ?, ?, 'DRAFT')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            st.setInt(5, positionId);
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Xóa phân công ca (Hủy chọn)
    public void deleteSchedule(int branchId, int userId, int shiftId, String workDate) {
        String sql = "DELETE FROM shift_schedules WHERE branch_id = ? AND user_id = ? AND shift_id = ? AND work_date = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. Công bố toàn bộ lịch nháp của chi nhánh sang trạng thái Published
    public void publishSchedules(int branchId, String startDate, String endDate) {
        String sql = "UPDATE shift_schedules SET status = 'PUBLISHED' WHERE branch_id = ? AND status = 'DRAFT' AND work_date BETWEEN ? AND ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(startDate));
            st.setDate(3, Date.valueOf(endDate));
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. Đếm tổng số ca trực trong ngày hôm nay theo chi nhánh
    public int countTodaySchedulesByBranch(int branchId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM shift_schedules WHERE branch_id = ? AND work_date = CURDATE()";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 7. Lấy danh sách toàn bộ thông tin ca trực hôm nay của nhân viên
    public List<String> getTodayShiftsForEmployee(int userId) {
        List<String> shiftList = new ArrayList<>();
        String sql = "SELECT s.name, s.start_time, s.end_time FROM shift_schedules ss "
                + "JOIN shifts s ON ss.shift_id = s.id "
                + "WHERE ss.user_id = ? AND ss.work_date = CURDATE() AND ss.status = 'PUBLISHED'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String shiftName = rs.getString("name");
                    Time startTime = rs.getTime("start_time");
                    Time endTime = rs.getTime("end_time");
                    String shiftInfo = shiftName + " (" + (startTime != null ? startTime.toString().substring(0, 5) : "") + " - " + (endTime != null ? endTime.toString().substring(0, 5) : "") + ")";
                    shiftList.add(shiftInfo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return shiftList;
    }

    // [ĐÃ SỬA] 7.1. Lấy danh sách nhân viên Full-time theo chi nhánh (có kèm shiftType để lọc ca cố định)
    public List<Map<String, Object>> getFullTimeEmployeesByBranch(int branchId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ep.user_id, ep.full_name, p.id as position_id, p.title as position_title, ep.shift_type "
                + "FROM employee_profiles ep "
                + "JOIN positions p ON ep.position_id = p.id "
                + "WHERE ep.home_branch_id = ? AND ep.employee_type = 'FULL_TIME'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> emp = new HashMap<>();
                    emp.put("userId", rs.getInt("user_id"));
                    emp.put("fullName", rs.getString("full_name"));
                    emp.put("positionId", rs.getInt("position_id"));
                    emp.put("positionTitle", rs.getString("position_title"));
                    emp.put("shiftType", rs.getString("shift_type")); // Bổ sung dòng này để truyền shiftType ra giao diện
                    list.add(emp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 8. Lấy định mức nhân sự trong tuần theo ngày (Chỉ lấy các cột cần thiết)
    public Map<String, Map<String, Object>> getWeeklyRequirementsMap(int branchId, String startDate, String endDate) {
        Map<String, Map<String, Object>> map = new HashMap<>();
        String sql = "SELECT work_date, position_id, shift_id, required_count FROM shift_requirements WHERE branch_id = ? AND work_date BETWEEN ? AND ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(startDate));
            st.setDate(3, Date.valueOf(endDate));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String workDateStr = rs.getString("work_date");
                    int posId = rs.getInt("position_id");
                    int shiftId = rs.getInt("shift_id");
                    String key = workDateStr + "_" + posId + "_" + shiftId;

                    Map<String, Object> details = new HashMap<>();
                    details.put("requiredCount", rs.getInt("required_count"));
                    map.put(key, details);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // 9. Lấy số lượng nhân viên thực tế đã được xếp trong tuần (Key: workDate_positionId_shiftId)
    public Map<String, Integer> getWeeklyAssignedCountMap(int branchId, String startDate, String endDate) {
        Map<String, Integer> map = new HashMap<>();
        // Loại 'ON_LEAVE': nhân viên đã nghỉ phép được duyệt thì ca đó không còn
        // là ca đang làm việc, không được tính vào "đã xếp" (nếu tính vào, ô lịch
        // báo đủ người trong khi nhân viên thực tế không có ca nào trong tuần).
        String sql = "SELECT ss.work_date, ss.shift_id, ep.position_id, COUNT(ss.user_id) as assigned_count "
                + "FROM shift_schedules ss "
                + "JOIN employee_profiles ep ON ss.user_id = ep.user_id "
                + "WHERE ss.branch_id = ? AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.status <> 'ON_LEAVE' "
                + "GROUP BY ss.work_date, ss.shift_id, ep.position_id";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(startDate));
            st.setDate(3, Date.valueOf(endDate));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String key = rs.getString("work_date") + "_" + rs.getInt("position_id") + "_" + rs.getInt("shift_id");
                    map.put(key, rs.getInt("assigned_count"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // 10. Cập nhật hoặc thêm mới định mức theo ngày
    public void updateShiftRequirementByDate(int branchId, int positionId, int shiftId, String workDate, int requiredCount) {
        String checkSql = "SELECT id FROM shift_requirements WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ?";
        String updateSql = "UPDATE shift_requirements SET required_count = ? WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ?";
        String insertSql = "INSERT INTO shift_requirements (branch_id, position_id, shift_id, required_count, work_date) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection()) {
            boolean exists = false;
            try (PreparedStatement pst = conn.prepareStatement(checkSql)) {
                pst.setInt(1, branchId);
                pst.setInt(2, positionId);
                pst.setInt(3, shiftId);
                pst.setDate(4, Date.valueOf(workDate));
                try (ResultSet rs = pst.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                try (PreparedStatement pst = conn.prepareStatement(updateSql)) {
                    pst.setInt(1, requiredCount);
                    pst.setInt(2, branchId);
                    pst.setInt(3, positionId);
                    pst.setInt(4, shiftId);
                    pst.setDate(5, Date.valueOf(workDate));
                    pst.executeUpdate();
                }
            } else {
                try (PreparedStatement pst = conn.prepareStatement(insertSql)) {
                    pst.setInt(1, branchId);
                    pst.setInt(2, positionId);
                    pst.setInt(3, shiftId);
                    pst.setInt(4, requiredCount);
                    pst.setDate(5, Date.valueOf(workDate));
                    pst.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 11. Hàm gợi ý định mức thông minh theo thực tế (Vị trí + Cuối tuần + Ca tối)
    public int getSmartDefaultRequirement(String workDateStr, int positionId, int shiftId) {
        int defaultCount = 2;
        try {
            LocalDate date = LocalDate.parse(workDateStr);
            DayOfWeek dow = date.getDayOfWeek();
            boolean isWeekend = (dow == DayOfWeek.SATURDAY || dow == DayOfWeek.SUNDAY);

            if (positionId == 7) { // Bán hàng & Trưng bày
                defaultCount = isWeekend ? 4 : 3;
            } else if (positionId == 6) { // Thu ngân
                defaultCount = isWeekend ? 3 : 2;
            } else if (positionId == 9) { // Bảo vệ
                defaultCount = 2;
            } else {
                defaultCount = isWeekend ? 3 : 2;
            }

            if (shiftId == 3 || shiftId == 5) { // Ca tối
                defaultCount += 1;
            }
        } catch (Exception e) {
            defaultCount = 3;
        }
        return defaultCount;
    }

    // 12. Kiểm tra xem lịch trong tuần (từ startDate đến endDate) của chi nhánh đã được publish chưa
    public boolean isWeekPublished(int branchId, String startDate, String endDate) {
        String sql = "SELECT id FROM shift_schedules WHERE branch_id = ? AND work_date BETWEEN ? AND ? AND status = 'PUBLISHED' LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(startDate));
            st.setDate(3, Date.valueOf(endDate));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    /** Only approved borrowed staff, indexed by date_position_shift for JSP. */
    public Map<String,List<Map<String,Object>>> getBorrowedAssignments(int branchId,String startDate,String endDate){
        Map<String,List<Map<String,Object>>> result=new HashMap<>();
        String sql="SELECT ss.work_date,ss.position_id,ss.shift_id,ep.full_name,b.name AS source_branch_name " +
          "FROM shift_schedules ss JOIN temporary_transfers t ON t.id=ss.temporary_transfer_id AND t.status='APPROVED' " +
          "JOIN employee_profiles ep ON ep.user_id=ss.user_id JOIN branches b ON b.id=t.source_store_id " +
          "WHERE ss.branch_id=? AND ss.work_date BETWEEN ? AND ?";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setInt(1,branchId);ps.setDate(2,Date.valueOf(startDate));ps.setDate(3,Date.valueOf(endDate));
            try(ResultSet rs=ps.executeQuery()){while(rs.next()){
                String key=rs.getDate("work_date")+"_"+rs.getInt("position_id")+"_"+rs.getInt("shift_id");
                Map<String,Object> v=new HashMap<>();v.put("fullName",rs.getString("full_name"));
                v.put("sourceBranchName",rs.getString("source_branch_name"));
                result.computeIfAbsent(key,k->new ArrayList<>()).add(v);
            }}
        }catch(Exception e){throw new IllegalStateException(e);}return result;
    }

    // Prevent managers from removing a borrowed shift or reserved source employee.
    public boolean isLockedForTransfer(int branchId,int userId,int shiftId,String workDate){
        String sql="SELECT COUNT(*) FROM temporary_transfer_employees e JOIN temporary_transfers t ON t.id=e.transfer_id " +
          "WHERE e.employee_id=? AND t.work_date=? AND t.shift_id=? AND t.source_store_id=? " +
          "AND t.status='PENDING_HR' AND e.status='RESERVED'";
        String approved="SELECT COUNT(*) FROM shift_schedules WHERE branch_id=? AND user_id=? AND shift_id=? AND work_date=? AND temporary_transfer_id IS NOT NULL";
        try(Connection c=DBContext.getConnection()){
            try(PreparedStatement p=c.prepareStatement(sql)){
                p.setInt(1,userId);p.setDate(2,Date.valueOf(workDate));p.setInt(3,shiftId);p.setInt(4,branchId);
                try(ResultSet rs=p.executeQuery()){if(rs.next()&&rs.getInt(1)>0)return true;}
            }
            try(PreparedStatement p=c.prepareStatement(approved)){
                p.setInt(1,branchId);p.setInt(2,userId);p.setInt(3,shiftId);p.setDate(4,Date.valueOf(workDate));
                try(ResultSet rs=p.executeQuery()){return rs.next()&&rs.getInt(1)>0;}
            }
        }catch(Exception e){throw new IllegalStateException("Không kiểm tra được khoá điều chuyển",e);}
    }
    // 3b. Nhân viên đang có đơn nghỉ phép ĐÃ DUYỆT trong ngày này không?
    // Dùng để chặn Store Manager xếp nhân viên đang nghỉ vào ca.
    // Chặn theo cả ngày (không chỉ ca bị nghỉ) để an toàn: nhân viên
    // đã xin nghỉ cả ngày thì không nên bị xếp vào bất kỳ ca nào.
    public boolean isOnApprovedLeave(int userId, String workDate) {
        String sql = "SELECT COUNT(*) FROM leave_requests lr "
                + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                + "WHERE lr.user_id = ? AND lr.status = 'APPROVED' "
                + "AND lr.start_date <= ? AND lr.end_date >= ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, userId);
            st.setDate(2, Date.valueOf(workDate));
            st.setDate(3, Date.valueOf(workDate));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không kiểm tra được đơn nghỉ phép", e);
        }
    }

    // Protect against manual assignment of another person's shift or overlapping schedules.
    public boolean canAssign(int branchId,int userId,int positionId,int shiftId,String workDate){
        String sql="SELECT COUNT(*) FROM employee_profiles ep JOIN users u ON u.id=ep.user_id " +
          "WHERE ep.user_id=? AND ep.home_branch_id=? AND ep.position_id=? AND u.status='ACTIVE'";
        String conflict="SELECT COUNT(*) FROM shift_schedules ss JOIN shifts a ON a.id=ss.shift_id " +
          "JOIN shifts b ON b.id=? WHERE ss.user_id=? AND ss.work_date=? " +
          "AND a.start_time < b.end_time AND a.end_time > b.start_time";
        String held="SELECT COUNT(*) FROM temporary_transfer_employees e JOIN temporary_transfers t ON t.id=e.transfer_id " +
          "JOIN shifts a ON a.id=t.shift_id JOIN shifts b ON b.id=? " +
          "WHERE e.employee_id=? AND t.work_date=? AND t.status='PENDING_HR' AND e.status='RESERVED' " +
          "AND a.start_time < b.end_time AND a.end_time > b.start_time";
        try(Connection c=DBContext.getConnection()){
            try(PreparedStatement p=c.prepareStatement(sql)){
                p.setInt(1,userId);p.setInt(2,branchId);p.setInt(3,positionId);
                try(ResultSet rs=p.executeQuery()){if(!rs.next()||rs.getInt(1)!=1)return false;}
            }
            // Nhân viên đang nghỉ phép (đơn đã duyệt) -> không được xếp ca.
            if (isOnApprovedLeave(userId, workDate)) {
                return false;
            }
            for(String q:new String[]{conflict,held})try(PreparedStatement p=c.prepareStatement(q)){
                p.setInt(1,shiftId);p.setInt(2,userId);p.setDate(3,Date.valueOf(workDate));
                try(ResultSet rs=p.executeQuery()){if(rs.next()&&rs.getInt(1)>0)return false;}
            }
            return true;
        }catch(Exception e){throw new IllegalStateException("Không kiểm tra được xung đột",e);}
    }

    /**
     * Nhân viên có đăng ký lịch rảnh cho đúng (ngày trong tuần, ca, vị trí) không?
     *
     * <p>Quy tắc nghiệp vụ: Store Manager chỉ được xếp nhân viên vào ca mà
     * nhân viên đó <b>đã đăng ký lịch rảnh</b> cho ca đó vào đúng ngày đó.
     * Ví dụ: hôm nay ca 1 có a, b, c đăng ký rảnh thì Store được chọn
     * đúng a/b/c vào ca đó.
     *
     * <p>Mốc tuần được suy ra từ ngày làm việc (thứ Hai của tuần đó), khớp với
     * {@code week_start_date} mà nhân viên dùng khi đăng ký lịch rảnh.
     *
     * @return true nếu nhân viên đã đăng ký rảnh đúng ca + đúng ngày + đúng vị trí
     */
    public boolean hasRegisteredAvailability(int branchId, int userId, int positionId,
                                             int shiftId, String workDate) {
        String sql = "SELECT COUNT(*) FROM employee_availabilities ea "
                + "JOIN employee_profiles ep ON ea.user_id = ep.user_id "
                + "WHERE ea.user_id = ? AND ep.home_branch_id = ? AND ep.position_id = ? "
                + "AND ea.shift_id = ? AND ea.day_of_week = ? AND ea.week_start_date = ?";

        LocalDate date = LocalDate.parse(workDate);
        String dayName = date.getDayOfWeek().name();
        String weekStart = date
                .with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY))
                .toString();

        try (Connection c = DBContext.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setInt(2, branchId);
            p.setInt(3, positionId);
            p.setInt(4, shiftId);
            p.setString(5, dayName);
            p.setString(6, weekStart);
            try (ResultSet rs = p.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không kiểm tra được lịch rảnh đã đăng ký", e);
        }
    }

    /**
     * Nhân viên đã đăng ký tham gia ca bổ sung (đăng ký vào ca trống) chưa?
     * Loại đăng ký này cũng là sự đồng ý của nhân viên nên được phép xếp.
     *
     * @return true nếu nhân viên đã đăng ký ứng tuyển vào đúng ca + đúng ngày này
     */
    public boolean hasSupplementaryApplication(int branchId, int userId, int positionId,
                                               int shiftId, String workDate) {
        String sql = "SELECT COUNT(*) FROM supplementary_shift_opportunities o "
                + "JOIN supplementary_shift_applications a ON a.opportunity_id = o.id "
                + "WHERE o.branch_id = ? AND o.position_id = ? AND o.shift_id = ? "
                + "AND o.work_date = ? AND a.user_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, branchId);
            p.setInt(2, positionId);
            p.setInt(3, shiftId);
            p.setDate(4, Date.valueOf(workDate));
            p.setInt(5, userId);
            try (ResultSet rs = p.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không kiểm tra được đăng ký ca bổ sung", e);
        }
    }

    /**
     * Nhân viên Full-time không phải đăng ký lịch rảnh (họ có lịch cố định).
     *
     * @return true nếu nhân viên thuộc loại FULL_TIME
     */
    public boolean isFullTime(int branchId, int userId) {
        String sql = "SELECT COUNT(*) FROM employee_profiles ep "
                + "JOIN users u ON u.id = ep.user_id "
                + "WHERE ep.user_id = ? AND ep.home_branch_id = ? "
                + "AND ep.employee_type = 'FULL_TIME' AND u.status = 'ACTIVE'";
        try (Connection c = DBContext.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setInt(2, branchId);
            try (ResultSet rs = p.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không kiểm tra được loại nhân viên", e);
        }
    }

    /**
     * Lấy danh sách nhân viên đã được xếp ca trong tuần, kèm tên và trạng thái.
     * Dùng để lưới xếp lịch hiển thị đúng lịch thật (nhân viên nhìn thấy
     * trong trang "Lịch làm việc" của mình).
     *
     * @return key = {@code workDate_positionId_shiftId} -> danh sách ca đã xếp của ô đó
     */
    public Map<String, List<Map<String, Object>>> getAssignedStaffMap(int branchId, String startDate, String endDate) {
        Map<String, List<Map<String, Object>>> result = new HashMap<>();
        // Loại các ca được MƯỢN từ cơ sở khác (temporary_transfer_id khác NULL):
        // những ca đó đã được hiển thị riêng bằng khối "borrowedAssignments" trong JSP,
        // nếu giữ lại sẽ bị hiển thị trùng 2 lần.
        String sql = "SELECT ss.user_id, ss.shift_id, ss.work_date, ss.position_id, ss.status, ep.full_name "
                + "FROM shift_schedules ss "
                + "JOIN employee_profiles ep ON ss.user_id = ep.user_id "
                + "WHERE ss.branch_id = ? AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.temporary_transfer_id IS NULL "
                + "ORDER BY ss.work_date, ss.shift_id, ep.full_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setDate(2, Date.valueOf(startDate));
            st.setDate(3, Date.valueOf(endDate));
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String key = rs.getString("work_date") + "_"
                            + rs.getInt("position_id") + "_"
                            + rs.getInt("shift_id");
                    Map<String, Object> row = new HashMap<>();
                    row.put("userId", rs.getInt("user_id"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("status", rs.getString("status"));
                    result.computeIfAbsent(key, k -> new ArrayList<>()).add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

}