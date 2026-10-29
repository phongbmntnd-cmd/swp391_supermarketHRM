package model;

import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Model cho bảng {@code attendances} - bản ghi chấm công.
 *
 * <h3>Ánh xạ schema</h3>
 * <pre>
 *   attendances.id              -> id
 *   attendances.user_id         -> userId
 *   employee_profiles.full_name -> fullName
 *   users.username             -> username
 *   attendances.shift_schedule_id -> shiftScheduleId
 *   attendances.check_in        -> checkIn   (datetime)
 *   attendances.check_out       -> checkOut  (datetime)
 *   attendances.method          -> method    (WIFI | DYNAMIC_QR)
 *   attendances.status          -> status    (VALID | INVALID | ADJUSTED)
 * </pre>
 *
 * <p>Thời gian check-in/out dùng {@link LocalDateTime} vì cột trong DB
 * là {@code datetime}. Trường {@code date} giữ lại ngày làm việc
 * (phục vụ việc lọc/nhóm theo ngày) và được suy ra từ {@code check_in}.
 */
public class Attendance {

    private int id;
    private int userId;
    private String fullName;
    private String username;
    private int shiftScheduleId;
    private LocalDateTime checkIn;
    private LocalDateTime checkOut;
    private String method;
    private String status;

    /** Ngày làm việc (suy ra từ check_in). */
    private Date date;

    public Attendance() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public int getShiftScheduleId() {
        return shiftScheduleId;
    }

    public void setShiftScheduleId(int shiftScheduleId) {
        this.shiftScheduleId = shiftScheduleId;
    }

    public LocalDateTime getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(LocalDateTime checkIn) {
        this.checkIn = checkIn;
        // Đồng bộ ngày làm việc theo check-in để tiện khi hiển thị.
        if (checkIn != null) {
            this.date = Date.valueOf(checkIn.toLocalDate());
        }
    }

    public LocalDateTime getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(LocalDateTime checkOut) {
        this.checkOut = checkOut;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    /**
     * Số giờ làm việc thực tế (check-out - check-in).
     *
     * @return số giờ, 0 nếu thiếu mốc check-in hoặc check-out
     */
    public double getWorkedHours() {
        if (checkIn == null || checkOut == null) {
            return 0d;
        }
        long minutes = java.time.Duration
                .between(checkIn, checkOut).toMinutes();
        return minutes / 60.0;
    }

    /**
     * Số giờ làm việc đã làm tròn 2 chữ số thập phân (để hiển thị).
     *
     * <p>Ví dụ 4.916666666666667 -&gt; "4.92", 10.0 -&gt; "10".
     */
    public String getWorkedHoursText() {
        if (checkIn == null || checkOut == null) {
            return "";
        }
        double h = getWorkedHours();
        if (h == Math.floor(h)) {
            return String.valueOf((long) h);
        }
        return String.valueOf(Math.round(h * 100.0) / 100.0);
    }

    /**
     * Giờ check-in dạng "HH:mm" (rỗng nếu chưa check-in).
     */
    public String getCheckInText() {
        return formatTime(checkIn);
    }

    /**
     * Giờ check-out dạng "HH:mm" (rỗng nếu chưa check-out).
     */
    public String getCheckOutText() {
        return formatTime(checkOut);
    }

    /**
     * Định dạng LocalDateTime thành "HH:mm".
     */
    private String formatTime(LocalDateTime dt) {
        if (dt == null) {
            return "";
        }
        String hh = dt.getHour() < 10
                ? "0" + dt.getHour()
                : String.valueOf(dt.getHour());
        String mm = dt.getMinute() < 10
                ? "0" + dt.getMinute()
                : String.valueOf(dt.getMinute());
        return hh + ":" + mm;
    }

    /**
     * Ngày làm việc dạng "dd/MM/yyyy" (rỗng nếu không có).
     */
    public String getDateText() {
        if (date == null) {
            return "";
        }
        LocalDate d = date.toLocalDate();
        String dd = d.getDayOfMonth() < 10
                ? "0" + d.getDayOfMonth()
                : String.valueOf(d.getDayOfMonth());
        String mm = d.getMonthValue() < 10
                ? "0" + d.getMonthValue()
                : String.valueOf(d.getMonthValue());
        return dd + "/" + mm + "/" + d.getYear();
    }

    /**
     * Ca có đủ cả check-in và check-out không (tức là bản ghi hợp lệ).
     */
    public boolean isComplete() {
        return checkIn != null && checkOut != null;
    }
}
