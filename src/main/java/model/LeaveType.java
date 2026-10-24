package model;

public class LeaveType {
    private int id;
    private String code;
    private String name;
    private String description;
    private int defaultDays;      // Số ngày mặc định được nghỉ trong năm
    private boolean paidLeave;     // Có được hưởng lương không
    private int noticeHours;       // Số giờ phải báo trước khi gửi đơn (0 = không giới hạn)

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
}
