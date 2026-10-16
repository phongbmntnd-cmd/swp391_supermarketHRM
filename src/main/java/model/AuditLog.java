package model;

import java.sql.Timestamp;

public class AuditLog {

    // Action constants
    public static final String ACTION_EMERGENCY_LOCK     = "EMERGENCY_LOCK";
    public static final String ACTION_EMERGENCY_UNLOCK   = "EMERGENCY_UNLOCK";
    public static final String ACTION_RESET_PASSWORD     = "RESET_PASSWORD";
    public static final String ACTION_CREATE_USER        = "CREATE_USER";
    public static final String ACTION_UPDATE_USER        = "UPDATE_USER";
    public static final String ACTION_LOGIN              = "LOGIN";
    public static final String ACTION_LOGOUT             = "LOGOUT";
    public static final String ACTION_LOGIN_FAILED       = "LOGIN_FAILED";
    public static final String ACTION_CREATE_DEPARTMENT  = "CREATE_DEPARTMENT";
    public static final String ACTION_UPDATE_DEPARTMENT  = "UPDATE_DEPARTMENT";
    public static final String ACTION_DELETE_DEPARTMENT  = "DELETE_DEPARTMENT";
    public static final String ACTION_CREATE_POSITION    = "CREATE_POSITION";
    public static final String ACTION_UPDATE_POSITION    = "UPDATE_POSITION";
    public static final String ACTION_DELETE_POSITION    = "DELETE_POSITION";
    public static final String ACTION_CREATE_ROLE        = "CREATE_ROLE";
    public static final String ACTION_UPDATE_ROLE        = "UPDATE_ROLE";
    public static final String ACTION_DELETE_ROLE        = "DELETE_ROLE";

    private int id;
    private String action;
    private Integer actorId;          // người thực hiện (có thể null với login failed)
    private Integer targetUserId;     // user bị tác động (có thể null)
    private String description;       // mô tả chi tiết
    private String ipAddress;
    private Timestamp createdAt;

    // Thông tin bổ sung để hiển thị (join từ các bảng khác)
    private String actorName;
    private String actorUsername;
    private String targetUserName;
    private String targetUsername;
    private String actorRoleName;
    private String targetRoleName;
    private String actorBranchName;
    private String targetBranchName;

    public AuditLog() {}

    public AuditLog(String action, Integer actorId, Integer targetUserId, String description, String ipAddress) {
        this.action = action;
        this.actorId = actorId;
        this.targetUserId = targetUserId;
        this.description = description;
        this.ipAddress = ipAddress;
    }

    // ---- Getters / Setters ----
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public Integer getActorId() { return actorId; }
    public void setActorId(Integer actorId) { this.actorId = actorId; }

    public Integer getTargetUserId() { return targetUserId; }
    public void setTargetUserId(Integer targetUserId) { this.targetUserId = targetUserId; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }

    public String getActorUsername() { return actorUsername; }
    public void setActorUsername(String actorUsername) { this.actorUsername = actorUsername; }

    public String getTargetUserName() { return targetUserName; }
    public void setTargetUserName(String targetUserName) { this.targetUserName = targetUserName; }

    public String getTargetUsername() { return targetUsername; }
    public void setTargetUsername(String targetUsername) { this.targetUsername = targetUsername; }

    public String getActorRoleName() { return actorRoleName; }
    public void setActorRoleName(String actorRoleName) { this.actorRoleName = actorRoleName; }

    public String getTargetRoleName() { return targetRoleName; }
    public void setTargetRoleName(String targetRoleName) { this.targetRoleName = targetRoleName; }

    public String getActorBranchName() { return actorBranchName; }
    public void setActorBranchName(String actorBranchName) { this.actorBranchName = actorBranchName; }

    public String getTargetBranchName() { return targetBranchName; }
    public void setTargetBranchName(String targetBranchName) { this.targetBranchName = targetBranchName; }
}
