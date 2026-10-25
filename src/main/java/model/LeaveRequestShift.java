package model;

import java.sql.Date;

/**
 * Chi tiết ca làm việc bị ảnh hưởng bởi một đơn nghỉ phép.
 *
 * Đây là phần "C" của mô hình "C trên nền B": mỗi đơn nghỉ phép đều
 * gắn với danh sách ca cụ thể, nhờ vậy:
 *   - Nhân viên part-time nghỉ đúng các ca họ đã được xếp.
 *   - Khi duyệt, các ca đó được chuyển sang ON_LEAVE và đưa vào
 *     open_shifts để tìm người cover.
 *   - Thời lượng ca (hours) được snapshot tại thời điểm tạo đơn để
 *     lịch sử không bị thay đổi khi ca được sửa về sau.
 */
public class LeaveRequestShift {

    private int id;
    private int leaveRequestId;
    private Date workDate;
    private int shiftId;
    private String shiftName;
    private double hours;

    // Thông tin bổ sung khi join (không lưu DB)
    private String startTime;
    private String endTime;
    private int positionId;

    public LeaveRequestShift() {
    }

    public LeaveRequestShift(
            int leaveRequestId,
            Date workDate,
            int shiftId,
            String shiftName,
            double hours) {
        this.leaveRequestId = leaveRequestId;
        this.workDate = workDate;
        this.shiftId = shiftId;
        this.shiftName = shiftName;
        this.hours = hours;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLeaveRequestId() {
        return leaveRequestId;
    }

    public void setLeaveRequestId(int leaveRequestId) {
        this.leaveRequestId = leaveRequestId;
    }

    public Date getWorkDate() {
        return workDate;
    }

    public void setWorkDate(Date workDate) {
        this.workDate = workDate;
    }

    public int getShiftId() {
        return shiftId;
    }

    public void setShiftId(int shiftId) {
        this.shiftId = shiftId;
    }

    public String getShiftName() {
        return shiftName;
    }

    public void setShiftName(String shiftName) {
        this.shiftName = shiftName;
    }

    public double getHours() {
        return hours;
    }

    public void setHours(double hours) {
        this.hours = hours;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public int getPositionId() {
        return positionId;
    }

    public void setPositionId(int positionId) {
        this.positionId = positionId;
    }
}
