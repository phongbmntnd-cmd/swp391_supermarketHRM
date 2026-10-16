package model;

public class EmployeeAvailability {

    private int id;
    private int userId;
    private String weekStartDate;
    private String dayOfWeek;
    private int shiftId;

    public EmployeeAvailability() {
    }

    public EmployeeAvailability(int id, int userId, String dayOfWeek, String weekStartDate, int shiftId) {
        this.id = id;
        this.userId = userId;
        this.dayOfWeek = dayOfWeek;
        this.weekStartDate = weekStartDate;
        this.shiftId = shiftId;
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

    public String getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(String dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public int getShiftId() {
        return shiftId;
    }

    public void setShiftId(int shiftId) {
        this.shiftId = shiftId;
    }

    public String getWeekStartDate() {
        return weekStartDate;
    }

    public void setWeekStartDate(String weekStartDate) {
        this.weekStartDate = weekStartDate;
    }

}
