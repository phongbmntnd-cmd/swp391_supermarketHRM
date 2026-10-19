package model;

import java.sql.Timestamp;
import java.sql.Date;

/**
 * Khung chứa dữ liệu.
 * @author phong
 */
public class TemporaryTransfer {
    private int id;
    private int requesterId;
    private int destinationStoreId;
    private int sourceStoreId;
    private int positionId;
    private int shiftId;
    private Date workDate;
    private int requiredCount;
    private Integer employeeId; // Dùng Integer để có thể nhận giá trị null
    private String reason;
    private String rejectReason;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Các trường bổ sung để hiển thị Tên (JOIN từ các bảng khác sang cho giao diện)
    private String requesterName;
    private String destinationStoreName;
    private String sourceStoreName;
    private String positionName;
    private String shiftName;
    private String employeeName;

    public TemporaryTransfer() {
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getRequesterId() { return requesterId; }
    public void setRequesterId(int requesterId) { this.requesterId = requesterId; }

    public int getDestinationStoreId() { return destinationStoreId; }
    public void setDestinationStoreId(int destinationStoreId) { this.destinationStoreId = destinationStoreId; }

    public int getSourceStoreId() { return sourceStoreId; }
    public void setSourceStoreId(int sourceStoreId) { this.sourceStoreId = sourceStoreId; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getShiftId() { return shiftId; }
    public void setShiftId(int shiftId) { this.shiftId = shiftId; }

    public Date getWorkDate() { return workDate; }
    public void setWorkDate(Date workDate) { this.workDate = workDate; }

    public int getRequiredCount() { return requiredCount; }
    public void setRequiredCount(int requiredCount) { this.requiredCount = requiredCount; }

    public Integer getEmployeeId() { return employeeId; }
    public void setEmployeeId(Integer employeeId) { this.employeeId = employeeId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Getters and Setters cho các trường hiển thị tên
    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getDestinationStoreName() { return destinationStoreName; }
    public void setDestinationStoreName(String destinationStoreName) { this.destinationStoreName = destinationStoreName; }

    public String getSourceStoreName() { return sourceStoreName; }
    public void setSourceStoreName(String sourceStoreName) { this.sourceStoreName = sourceStoreName; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
}