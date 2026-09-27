package model;

import java.sql.Timestamp;

public class EmployeeLock {
    
    private int id;
    private int userId;
    private int lockedBy;
    private Integer unlockedBy; // Nullable - có thể null nếu chưa unlock
    private String reason;
    private Timestamp lockedAt;
    private Timestamp unlockedAt;
    private boolean isActive;
    
    // Thông tin bổ sung (dùng khi hiển thị, không lưu DB)
    private String lockedByName;
    private String unlockedByName;
    private String userName;
    private String username;  // Tài khoản của user bị lock
    private String email;     // Email của user bị lock
    private String phone;     // SĐT của user bị lock
    
    public EmployeeLock() {
    }

    public EmployeeLock(int userId, int lockedBy, String reason) {
        this.userId = userId;
        this.lockedBy = lockedBy;
        this.reason = reason;
        this.isActive = true;
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

    public int getLockedBy() {
        return lockedBy;
    }

    public void setLockedBy(int lockedBy) {
        this.lockedBy = lockedBy;
    }

    public Integer getUnlockedBy() {
        return unlockedBy;
    }

    public void setUnlockedBy(Integer unlockedBy) {
        this.unlockedBy = unlockedBy;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Timestamp getLockedAt() {
        return lockedAt;
    }

    public void setLockedAt(Timestamp lockedAt) {
        this.lockedAt = lockedAt;
    }

    public Timestamp getUnlockedAt() {
        return unlockedAt;
    }

    public void setUnlockedAt(Timestamp unlockedAt) {
        this.unlockedAt = unlockedAt;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public String getLockedByName() {
        return lockedByName;
    }

    public void setLockedByName(String lockedByName) {
        this.lockedByName = lockedByName;
    }

    public String getUnlockedByName() {
        return unlockedByName;
    }

    public void setUnlockedByName(String unlockedByName) {
        this.unlockedByName = unlockedByName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
