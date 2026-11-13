package model;

public class LeaveType {
    private int id;
    private String code;
    private String name;
    private String description;
    private int defaultDays;      // Số ngày mặc định được nghỉ trong năm
    private boolean paidLeave;     // Có được hưởng lương không
    private int noticeHours;       // Số giờ phải báo trước khi gửi đơn (0 = không giới hạn)
    // Số giờ phải báo trước riêng cho nhân viên PART_TIME.
    // Part-time báo trước lâu hơn vì ca đã publish cần kịp tìm người cover.
    private int noticeHoursPartTime;
    // true = loại nghỉ được làm đơn TRONG NGÀY, không kiểm tra hạn
    // báo trước (nghỉ ốm, nghỉ tang).
    private boolean sameDayAllowed;

    public LeaveType() {
    }

    public LeaveType(int id, String code, String name) {
        this.id = id;
        this.code = code;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDefaultDays() {
        return defaultDays;
    }

    public void setDefaultDays(int defaultDays) {
        this.defaultDays = defaultDays;
    }

    public boolean isPaidLeave() {
        return paidLeave;
    }

    public void setPaidLeave(boolean paidLeave) {
        this.paidLeave = paidLeave;
    }

    public int getNoticeHours() {
        return noticeHours;
    }

    public void setNoticeHours(int noticeHours) {
        this.noticeHours = noticeHours;
    }

    public int getNoticeHoursPartTime() {
        return noticeHoursPartTime;
    }

    public void setNoticeHoursPartTime(int noticeHoursPartTime) {
        this.noticeHoursPartTime = noticeHoursPartTime;
    }

    public boolean isSameDayAllowed() {
        return sameDayAllowed;
    }

    public void setSameDayAllowed(boolean sameDayAllowed) {
        this.sameDayAllowed = sameDayAllowed;
    }
}
