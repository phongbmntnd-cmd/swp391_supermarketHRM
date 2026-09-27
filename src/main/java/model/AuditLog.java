package model;

import java.sql.Timestamp;

public class AuditLog {
    
    public static final String ACTION_EMERGENCY_LOCK = "EMERGENCY_LOCK";
    public static final String ACTION_EMERGENCY_UNLOCK = "EMERGENCY_UNLOCK";
    
    private int id;
    private String action;
    private int actorId;
    private int targetUserId;
    private String description;
    private Timestamp createdAt;
    
    // Thông tin bổ sung (không lưu DB, dùng khi hiển thị)
    private String actorName;
    private String targetUserName;
    
    public AuditLog() {
    }
    
    public AuditLog(String action, int actorId, int targetUserId, String description) {
        this.action = action;
        this.actorId = actorId;
        this.targetUserId = targetUserId;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public int getActorId() {
        return actorId;
    }

    public void setActorId(int actorId) {
        this.actorId = actorId;
    }

    public int getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(int targetUserId) {
        this.targetUserId = targetUserId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getActorName() {
        return actorName;
    }

    public void setActorName(String actorName) {
        this.actorName = actorName;
    }

    public String getTargetUserName() {
        return targetUserName;
    }

    public void setTargetUserName(String targetUserName) {
        this.targetUserName = targetUserName;
    }
}
