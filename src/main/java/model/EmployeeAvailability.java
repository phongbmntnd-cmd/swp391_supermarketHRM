package model;

public class EmployeeAvailability {
    private int id;
    private int userId;
    private String dayOfWeek;
    private int shiftId;

    public EmployeeAvailability() {}

    public EmployeeAvailability(int id, int userId, String dayOfWeek, int shiftId) {
        this.id = id;
        this.userId = userId;
        this.dayOfWeek = dayOfWeek;
        this.shiftId = shiftId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public int getShiftId() { return shiftId; }
    public void setShiftId(int shiftId) { this.shiftId = shiftId; }
}