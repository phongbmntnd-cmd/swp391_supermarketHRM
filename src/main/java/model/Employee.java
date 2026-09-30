package model;

/**
 * Model tổng hợp dùng cho màn hình "Quản lý Hồ sơ Nhân sự":
 * gộp thông tin tài khoản (users) + hồ sơ (employee_profiles) + tên chi nhánh/phòng ban/vị trí.
 */
public class Employee {

    private int userId;
    private String username;
    private String email;
    private String userStatus;      // ACTIVE, INACTIVE, EMERGENCY_LOCKED

    private String fullName;
    private String phone;
    private String identityCard;

    private int homeBranchId;
    private String branchName;

    private int positionId;
    private String positionTitle;

    private int departmentId;
    private String departmentName;

    private String employeeType;    // FULL_TIME, PART_TIME, SEASONAL

    private int roleId;
    private String roleName;

    public Employee() {
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUserStatus() { return userStatus; }
    public void setUserStatus(String userStatus) { this.userStatus = userStatus; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getIdentityCard() { return identityCard; }
    public void setIdentityCard(String identityCard) { this.identityCard = identityCard; }

    public int getHomeBranchId() { return homeBranchId; }
    public void setHomeBranchId(int homeBranchId) { this.homeBranchId = homeBranchId; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public String getPositionTitle() { return positionTitle; }
    public void setPositionTitle(String positionTitle) { this.positionTitle = positionTitle; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getEmployeeType() { return employeeType; }
    public void setEmployeeType(String employeeType) { this.employeeType = employeeType; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }
}
