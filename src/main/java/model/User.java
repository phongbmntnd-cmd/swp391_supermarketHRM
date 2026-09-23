package model;

import java.sql.Timestamp;

public class User {

    private int id;
    private String username;
    private String email;
    private String phone;
    private String status;
    private Timestamp expirationDate;
    private Role role;
    private int homeBranchId;
    private String fullName;
    private boolean isFirstLogin;

    public User() {
    }

    // --- Bổ sung hàm tiện ích để dùng trong LoginServlet & AuthFilter ---
    public int getRoleId() {
        return role != null ? role.getId() : 0;
    }

    public String getRoleName() {
        return role != null ? role.getName() : "";
    }

    // --- Getters và Setters giữ nguyên của bạn ---
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Timestamp expirationDate) {
        this.expirationDate = expirationDate;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public int getHomeBranchId() {
        return homeBranchId;
    }

    public void setHomeBranchId(int homeBranchId) {
        this.homeBranchId = homeBranchId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public boolean isFirstLogin() {
        return isFirstLogin;
    }

    public void setFirstLogin(boolean firstLogin) {
        isFirstLogin = firstLogin;
    }

    public boolean getIsFirstLogin() {
        return isFirstLogin;
    }
}
