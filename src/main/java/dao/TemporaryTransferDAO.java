package dao;

import context.DBContext;
import model.TemporaryTransfer;
import java.sql.*;
import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.*;

/**
 * All decisions are atomic. Serializes competing transfers using branch row
 * locks, then verifies current schedules and reservations inside the same
 * transaction. A proposal can contain several people; HR approves/rejects the
 * whole proposal.
 */
public class TemporaryTransferDAO {

    public static final String PENDING_MANAGER = "PENDING_MANAGER", PENDING_HR = "PENDING_HR",
            APPROVED = "APPROVED", REJECTED_MANAGER = "REJECTED_MANAGER", REJECTED_HR = "REJECTED_HR";

    private Connection connection() throws SQLException {
        try {
            return DBContext.getConnection();
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể kết nối đến database", e
            );
        }
    }

    private static void require(boolean condition, String message) throws SQLException {
        if (!condition) {
            throw new SQLException(message);
        }
    }

    private static int singleInt(Connection c, String sql, Object... args) throws SQLException {
        try (PreparedStatement p = c.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) {
                p.setObject(i + 1, args[i]);
            }
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? r.getInt(1) : 0;
            }
        }
    }

    private static void lockBranches(Connection c, int a, int b) throws SQLException {
        require(a > 0 && b > 0 && a != b, "Cơ sở nguồn/đích không hợp lệ");
        // Consistent lock order prevents deadlocks when A->B and B->A occur simultaneously.
        int first = Math.min(a, b), second = Math.max(a, b);
        try (PreparedStatement p = c.prepareStatement("SELECT id FROM branches WHERE id IN (?,?) ORDER BY id FOR UPDATE")) {
            p.setInt(1, first);
            p.setInt(2, second);
            try (ResultSet r = p.executeQuery()) {
                int count = 0;
                while (r.next()) {
                    count++;
                }
                require(count == 2, "Cơ sở không tồn tại");
            }
        }
    }

    private static TemporaryTransfer loadForUpdate(Connection c, int id) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT * FROM temporary_transfers WHERE id=? FOR UPDATE")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? map(r) : null;
            }
        }
    }

    private static TemporaryTransfer map(ResultSet r) throws SQLException {
        TemporaryTransfer t = new TemporaryTransfer();
        t.setId(r.getInt("id"));
        t.setRequesterId(r.getInt("requester_id"));
        t.setDestinationStoreId(r.getInt("destination_store_id"));
        t.setSourceStoreId(r.getInt("source_store_id"));
        t.setPositionId(r.getInt("position_id"));
        t.setShiftId(r.getInt("shift_id"));
        t.setWorkDate(r.getDate("work_date"));
        t.setRequiredCount(r.getInt("required_count"));
        int n = r.getInt("requested_count");
        if (!r.wasNull()) {
            t.setRequestedCount(n);
        }
        n = r.getInt("employee_id");
        if (!r.wasNull()) {
            t.setEmployeeId(n);
        }
        n = r.getInt("hr_approved_by");
        if (!r.wasNull()) {
            t.setHrApprovedBy(n);
        }
        t.setReason(r.getString("reason"));
        t.setRejectReason(r.getString("reject_reason"));
        t.setStatus(r.getString("status"));
        t.setCreatedAt(r.getTimestamp("created_at"));
        t.setUpdatedAt(r.getTimestamp("updated_at"));
        t.setManagerApprovedAt(r.getTimestamp("manager_approved_at"));
        t.setHrApprovedAt(r.getTimestamp("hr_approved_at"));
        return t;
    }

    private static int requirement(Connection c, int branch, int position, int shift, Date date) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT required_count FROM shift_requirements WHERE branch_id=? AND position_id=? AND shift_id=? AND work_date=? ORDER BY id DESC LIMIT 1")) {
            p.setInt(1, branch);
            p.setInt(2, position);
            p.setInt(3, shift);
            p.setDate(4, date);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    return r.getInt(1);
                }
            }
        }
        // Mirrors ShiftScheduleDAO.getSmartDefaultRequirement; replace with a shared policy service when possible.
        LocalDate d = date.toLocalDate();
        boolean weekend = d.getDayOfWeek() == DayOfWeek.SATURDAY || d.getDayOfWeek() == DayOfWeek.SUNDAY;
        int count = position == 7 ? (weekend ? 4 : 3) : position == 6 ? (weekend ? 3 : 2) : position == 9 ? 2 : (weekend ? 3 : 2);
        return count + ((shift == 3 || shift == 5) ? 1 : 0);
    }

    private static int scheduled(Connection c, int branch, int position, int shift, Date date) throws SQLException {
        return singleInt(c, "SELECT COUNT(DISTINCT user_id) FROM shift_schedules WHERE branch_id=? AND position_id=? AND shift_id=? AND work_date=?", branch, position, shift, date);
    }

    private static int reserved(Connection c, int branch, int position, int shift, Date date, int exceptTransfer) throws SQLException {
        return singleInt(c, "SELECT COUNT(DISTINCT tte.employee_id) FROM temporary_transfer_employees tte "
                + "JOIN temporary_transfers t ON t.id=tte.transfer_id "
                + "WHERE t.source_store_id=? AND t.position_id=? AND t.shift_id=? AND t.work_date=? "
                + "AND t.status='PENDING_HR' AND tte.status='RESERVED' AND t.id<>?", branch, position, shift, date, exceptTransfer);
    }

    private static boolean hasConflict(Connection c, int employeeId, int shiftId, Date date, int exceptTransfer) throws SQLException {
        // Work time ranges are half-open: [start,end), allowing adjacent shifts.
        String overlap = "a.start_time < b.end_time AND a.end_time > b.start_time";
        int n = singleInt(c, "SELECT COUNT(*) FROM shift_schedules ss JOIN shifts a ON ss.shift_id=a.id "
                + "JOIN shifts b ON b.id=? WHERE ss.user_id=? AND ss.work_date=? AND " + overlap,
                shiftId, employeeId, date);
        if (n > 1) {
            return true; // A source assignment with same shift is allowed, but no other overlap.
        }
        if (n == 1) {
            int matching = singleInt(c, "SELECT COUNT(*) FROM shift_schedules WHERE user_id=? AND work_date=? AND shift_id=?", employeeId, date, shiftId);
            if (matching != 1) {
                return true;
            }
        }
        n = singleInt(c, "SELECT COUNT(*) FROM temporary_transfer_employees e JOIN temporary_transfers t ON t.id=e.transfer_id "
                + "JOIN shifts a ON a.id=t.shift_id JOIN shifts b ON b.id=? "
                + "WHERE e.employee_id=? AND t.work_date=? AND t.status='PENDING_HR' "
                + "AND e.status='RESERVED' AND t.id<>? AND " + overlap,
                shiftId, employeeId, date, exceptTransfer);
        return n > 0;
    }

    public boolean insertTransferProposal(TemporaryTransfer t) {
        if (t == null || t.getRequestedCount() == null || t.getRequestedCount() < 1 || t.getWorkDate() == null
                || t.getSourceStoreId() == t.getDestinationStoreId() || t.getReason() == null || t.getReason().trim().isEmpty()) {
            return false;
        }
        String sql = "INSERT INTO temporary_transfers (requester_id,destination_store_id,source_store_id,position_id,shift_id,work_date,required_count,requested_count,reason,status) VALUES (?,?,?,?,?,?,?,?,?,'PENDING_MANAGER')";
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                lockBranches(c, t.getSourceStoreId(), t.getDestinationStoreId());
                int required = requirement(c, t.getDestinationStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate());
                int assigned = scheduled(c, t.getDestinationStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate());
                int pending = singleInt(c, "SELECT COALESCE(SUM(requested_count),0) FROM temporary_transfers WHERE destination_store_id=? AND position_id=? AND shift_id=? AND work_date=? AND status IN ('PENDING_MANAGER','PENDING_HR')", t.getDestinationStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate());
                require(t.getRequestedCount() <= Math.max(0, required - assigned - pending), "Số lượng yêu cầu vượt quá số nhân viên còn thiếu");
                try (PreparedStatement p = c.prepareStatement(sql)) {
                    p.setInt(1, t.getRequesterId());
                    p.setInt(2, t.getDestinationStoreId());
                    p.setInt(3, t.getSourceStoreId());
                    p.setInt(4, t.getPositionId());
                    p.setInt(5, t.getShiftId());
                    p.setDate(6, t.getWorkDate());
                    p.setInt(7, required);
                    p.setInt(8, t.getRequestedCount());
                    p.setString(9, t.getReason());
                    require(p.executeUpdate() == 1, "Không lưu được đề xuất");
                }
                c.commit();
                return true;
            } catch (Exception e) {
                c.rollback();
                e.printStackTrace();
                return false;
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<TemporaryTransfer> getTransfersByStore(int branchId, boolean isSource) {
        return fetch("WHERE t." + (isSource ? "source_store_id" : "destination_store_id") + "=?", branchId);
    }

    public List<TemporaryTransfer> getPendingHR() {
        return fetch("WHERE t.status='PENDING_HR'");
    }

    private List<TemporaryTransfer> fetch(String condition, Object... args) {
        List<TemporaryTransfer> list = new ArrayList<>();
        String sql = "SELECT t.*, rq.full_name requester_name, bd.name destination_store_name, bs.name source_store_name, p.title position_name,s.name shift_name, em.full_name employee_name "
                + "FROM temporary_transfers t LEFT JOIN employee_profiles rq ON rq.user_id=t.requester_id "
                + "JOIN branches bd ON bd.id=t.destination_store_id JOIN branches bs ON bs.id=t.source_store_id "
                + "JOIN positions p ON p.id=t.position_id JOIN shifts s ON s.id=t.shift_id "
                + "LEFT JOIN employee_profiles em ON em.user_id=t.employee_id " + condition + " ORDER BY t.created_at DESC";
        try (Connection c = connection(); PreparedStatement p = c.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) {
                p.setObject(i + 1, args[i]);
            }
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    TemporaryTransfer t = map(r);
                    t.setRequesterName(r.getString("requester_name"));
                    t.setDestinationStoreName(r.getString("destination_store_name"));
                    t.setSourceStoreName(r.getString("source_store_name"));
                    t.setPositionName(r.getString("position_name"));
                    t.setShiftName(r.getString("shift_name"));
                    t.setEmployeeName(r.getString("employee_name"));
                    list.add(t);
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được đề xuất", e);
        }
        return list;
    }

    public List<Map<String, Object>> getEligibleEmployees(int transferId, int branchId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DISTINCT u.id,ep.full_name,ep.employee_type FROM temporary_transfers t "
                + "JOIN shift_schedules ss ON ss.branch_id=t.source_store_id AND ss.shift_id=t.shift_id AND ss.work_date=t.work_date AND ss.position_id=t.position_id AND ss.status='DRAFT' "
                + "JOIN employee_profiles ep ON ep.user_id=ss.user_id AND ep.home_branch_id=t.source_store_id AND ep.position_id=t.position_id "
                + "JOIN users u ON u.id=ss.user_id AND u.status='ACTIVE' WHERE t.id=? AND t.source_store_id=? AND t.status='PENDING_MANAGER'";
        try (Connection c = connection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, transferId);
            p.setInt(2, branchId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    int id = r.getInt("id");
                    TemporaryTransfer t = load(c, transferId);
                    if (!hasConflict(c, id, t.getShiftId(), t.getWorkDate(), transferId)) {
                        Map<String, Object> m = new HashMap<>();
                        m.put("id", id);
                        m.put("fullName", r.getString("full_name"));
                        m.put("employeeType", r.getString("employee_type"));
                        list.add(m);
                    }
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    private TemporaryTransfer load(Connection c, int id) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT * FROM temporary_transfers WHERE id=?")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? map(r) : null;
            }
        }
    }

    public boolean approveTransfer(int requestId, List<Integer> selected, int managerBranchId) {
        if (selected == null || selected.isEmpty() || new HashSet<>(selected).size() != selected.size()) {
            return false;
        }
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                TemporaryTransfer preliminary = load(c, requestId);
                require(preliminary != null, "Không tìm thấy đề xuất");
                require(preliminary.getSourceStoreId() == managerBranchId, "Sai cơ sở");
                lockBranches(c, preliminary.getSourceStoreId(), preliminary.getDestinationStoreId());
                TemporaryTransfer t = loadForUpdate(c, requestId);
                require(PENDING_MANAGER.equals(t.getStatus()), "Yêu cầu đã được xử lý");
                require(t.getRequestedCount() != null && t.getRequestedCount() > 0 && selected.size() >= 1 && selected.size() <= t.getRequestedCount(), "Chọn từ 1 đến số người được yêu cầu");
                require(scheduled(c, managerBranchId, t.getPositionId(), t.getShiftId(), t.getWorkDate())
                        - reserved(c, managerBranchId, t.getPositionId(), t.getShiftId(), t.getWorkDate(), requestId) - selected.size()
                        >= requirement(c, managerBranchId, t.getPositionId(), t.getShiftId(), t.getWorkDate()), "Cơ sở không dư đủ người");
                for (Integer id : selected) {
                    require(id != null && id > 0, "ID nhân viên không hợp lệ");
                    require(singleInt(c, "SELECT COUNT(*) FROM employee_profiles ep JOIN users u ON u.id=ep.user_id WHERE ep.user_id=? AND ep.home_branch_id=? AND ep.position_id=? AND u.status='ACTIVE'", id, managerBranchId, t.getPositionId()) == 1, "Nhân viên không phù hợp");
                    require(singleInt(c, "SELECT COUNT(*) FROM shift_schedules WHERE user_id=? AND branch_id=? AND position_id=? AND shift_id=? AND work_date=? AND status='DRAFT'", id, managerBranchId, t.getPositionId(), t.getShiftId(), t.getWorkDate()) == 1, "Nhân viên chưa được xếp ca nháp tại cơ sở nguồn");
                    require(!hasConflict(c, id, t.getShiftId(), t.getWorkDate(), requestId), "Nhân viên trùng ca/đang được giữ chỗ");
                }
                try (PreparedStatement p = c.prepareStatement("INSERT INTO temporary_transfer_employees(transfer_id,employee_id,status) VALUES (?,?,'RESERVED')")) {
                    for (int id : selected) {
                        p.setInt(1, requestId);
                        p.setInt(2, id);
                        p.addBatch();
                    }
                    p.executeBatch();
                }
                try (PreparedStatement p = c.prepareStatement("UPDATE temporary_transfers SET status='PENDING_HR',manager_approved_at=NOW(),updated_at=NOW() WHERE id=? AND status='PENDING_MANAGER'")) {
                    p.setInt(1, requestId);
                    require(p.executeUpdate() == 1, "Đề xuất thay đổi");
                }
                c.commit();
                return true;
            } catch (Exception e) {
                c.rollback();
                e.printStackTrace();
                return false;
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean rejectTransfer(int requestId, int managerBranchId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return false;
        }
        try (Connection c = connection(); PreparedStatement p = c.prepareStatement("UPDATE temporary_transfers SET status='REJECTED_MANAGER',reject_reason=?,updated_at=NOW() WHERE id=? AND source_store_id=? AND status='PENDING_MANAGER'")) {
            p.setString(1, reason.trim());
            p.setInt(2, requestId);
            p.setInt(3, managerBranchId);
            return p.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getSelectedEmployees(int transferId) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection c = connection(); PreparedStatement p = c.prepareStatement("SELECT e.employee_id, ep.full_name, e.status FROM temporary_transfer_employees e JOIN employee_profiles ep ON ep.user_id=e.employee_id WHERE e.transfer_id=? ORDER BY e.id")) {
            p.setInt(1, transferId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("employeeId", r.getInt(1));
                    m.put("fullName", r.getString(2));
                    m.put("status", r.getString(3));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    public boolean rejectHR(int id, int hrId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            return false;
        }
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                TemporaryTransfer preliminary = load(c, id);
                require(preliminary != null, "Không tìm thấy");
                lockBranches(c, preliminary.getSourceStoreId(), preliminary.getDestinationStoreId());
                TemporaryTransfer t = loadForUpdate(c, id);
                require(PENDING_HR.equals(t.getStatus()), "Đã xử lý");
                try (PreparedStatement p = c.prepareStatement("UPDATE temporary_transfers SET status='REJECTED_HR',reject_reason=?,hr_approved_by=?,hr_approved_at=NOW() WHERE id=? AND status='PENDING_HR'")) {
                    p.setString(1, reason.trim());
                    p.setInt(2, hrId);
                    p.setInt(3, id);
                    require(p.executeUpdate() == 1, "Không đổi được trạng thái");
                }
                try (PreparedStatement p = c.prepareStatement("UPDATE temporary_transfer_employees SET status='RELEASED' WHERE transfer_id=? AND status='RESERVED'")) {
                    p.setInt(1, id);
                    p.executeUpdate();
                }
                c.commit();
                return true;
            } catch (Exception e) {
                c.rollback();
                e.printStackTrace();
                return false;
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean approveHR(int id, int hrId) {
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                TemporaryTransfer preliminary = load(c, id);
                require(preliminary != null, "Không tìm thấy");
                lockBranches(c, preliminary.getSourceStoreId(), preliminary.getDestinationStoreId());
                TemporaryTransfer t = loadForUpdate(c, id);
                require(PENDING_HR.equals(t.getStatus()), "Đã xử lý");
                List<Integer> people = new ArrayList<>();
                try (PreparedStatement p = c.prepareStatement("SELECT employee_id FROM temporary_transfer_employees WHERE transfer_id=? AND status='RESERVED' FOR UPDATE")) {
                    p.setInt(1, id);
                    try (ResultSet r = p.executeQuery()) {
                        while (r.next()) {
                            people.add(r.getInt(1));
                        }
                    }
                }
                require(t.getRequestedCount() != null && !people.isEmpty() && people.size() <= t.getRequestedCount(), "Danh sách nhân viên đề cử không hợp lệ");
                // Source schedule still exists until HR approves, so subtract selected plus other reservations.
                require(scheduled(c, t.getSourceStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate())
                        - reserved(c, t.getSourceStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate(), id) - people.size()
                        >= requirement(c, t.getSourceStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate()), "Cơ sở nguồn không đủ nhân viên");
                int destAssigned = scheduled(c, t.getDestinationStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate());
                require(destAssigned + people.size() <= requirement(c, t.getDestinationStoreId(), t.getPositionId(), t.getShiftId(), t.getWorkDate()), "Cơ sở đích đã đủ người");
                for (int employee : people) {
                    require(singleInt(c, "SELECT COUNT(*) FROM shift_schedules WHERE branch_id=? AND user_id=? AND position_id=? AND shift_id=? AND work_date=? AND status='DRAFT'", t.getSourceStoreId(), employee, t.getPositionId(), t.getShiftId(), t.getWorkDate()) == 1, "Lịch nguồn đã thay đổi/đã Publish");
                    require(!hasConflict(c, employee, t.getShiftId(), t.getWorkDate(), id), "Nhân viên bị trùng ca");
                }
                // Pre-existing source assignments moved atomically; fail rather than modifying Published schedules.
                try (PreparedStatement p = c.prepareStatement("DELETE FROM shift_schedules WHERE branch_id=? AND user_id=? AND shift_id=? AND work_date=? AND position_id=? AND status='DRAFT'")) {
                    for (int employee : people) {
                        p.setInt(1, t.getSourceStoreId());
                        p.setInt(2, employee);
                        p.setInt(3, t.getShiftId());
                        p.setDate(4, t.getWorkDate());
                        p.setInt(5, t.getPositionId());
                        require(p.executeUpdate() == 1, "Không chuyển được lịch nguồn");
                    }
                }
                try (PreparedStatement p = c.prepareStatement("INSERT INTO shift_schedules(branch_id,user_id,shift_id,work_date,position_id,status,temporary_transfer_id) VALUES(?,?,?,?,?,'DRAFT',?)")) {
                    for (int employee : people) {
                        p.setInt(1, t.getDestinationStoreId());
                        p.setInt(2, employee);
                        p.setInt(3, t.getShiftId());
                        p.setDate(4, t.getWorkDate());
                        p.setInt(5, t.getPositionId());
                        p.setInt(6, id);
                        require(p.executeUpdate() == 1, "Không tạo được lịch cơ sở đích");
                    }
                }
                try (PreparedStatement p = c.prepareStatement("UPDATE temporary_transfer_employees SET status='APPROVED' WHERE transfer_id=? AND status='RESERVED'")) {
                    p.setInt(1, id);
                    require(p.executeUpdate() == people.size(), "Lỗi cập nhật nhân viên");
                }
                try (PreparedStatement p = c.prepareStatement("UPDATE temporary_transfers SET status='APPROVED',hr_approved_by=?,hr_approved_at=NOW(),updated_at=NOW() WHERE id=? AND status='PENDING_HR'")) {
                    p.setInt(1, hrId);
                    p.setInt(2, id);
                    require(p.executeUpdate() == 1, "Lỗi duyệt HR");
                }
                c.commit();
                return true;
            } catch (Exception e) {
                c.rollback();
                e.printStackTrace();
                return false;
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
