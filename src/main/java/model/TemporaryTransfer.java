package model;

import java.sql.Date;
import java.sql.Timestamp;

public class TemporaryTransfer {

    private int id, requesterId, destinationStoreId, sourceStoreId, positionId, shiftId, requiredCount;
    private Integer employeeId, requestedCount, hrApprovedBy;
    private Date workDate;
    private String reason, rejectReason, status, requesterName, destinationStoreName, sourceStoreName,
            positionName, shiftName, employeeName;
    private Timestamp createdAt, updatedAt, managerApprovedAt, hrApprovedAt;

    public int getId() {
        return id;
    }

    public void setId(int v) {
        id = v;
    }

    public int getRequesterId() {
        return requesterId;
    }

    public void setRequesterId(int v) {
        requesterId = v;
    }

    public int getDestinationStoreId() {
        return destinationStoreId;
    }

    public void setDestinationStoreId(int v) {
        destinationStoreId = v;
    }

    public int getSourceStoreId() {
        return sourceStoreId;
    }

    public void setSourceStoreId(int v) {
        sourceStoreId = v;
    }

    public int getPositionId() {
        return positionId;
    }

    public void setPositionId(int v) {
        positionId = v;
    }

    public int getShiftId() {
        return shiftId;
    }

    public void setShiftId(int v) {
        shiftId = v;
    }

    public int getRequiredCount() {
        return requiredCount;
    }

    public void setRequiredCount(int v) {
        requiredCount = v;
    }

    public Integer getRequestedCount() {
        return requestedCount;
    }

    public void setRequestedCount(Integer v) {
        requestedCount = v;
    }

    public Integer getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Integer v) {
        employeeId = v;
    }

    public Integer getHrApprovedBy() {
        return hrApprovedBy;
    }

    public void setHrApprovedBy(Integer v) {
        hrApprovedBy = v;
    }

    public Date getWorkDate() {
        return workDate;
    }

    public void setWorkDate(Date v) {
        workDate = v;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String v) {
        reason = v;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String v) {
        rejectReason = v;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        status = v;
    }

    public String getRequesterName() {
        return requesterName;
    }

    public void setRequesterName(String v) {
        requesterName = v;
    }

    public String getDestinationStoreName() {
        return destinationStoreName;
    }

    public void setDestinationStoreName(String v) {
        destinationStoreName = v;
    }

    public String getSourceStoreName() {
        return sourceStoreName;
    }

    public void setSourceStoreName(String v) {
        sourceStoreName = v;
    }

    public String getPositionName() {
        return positionName;
    }

    public void setPositionName(String v) {
        positionName = v;
    }

    public String getShiftName() {
        return shiftName;
    }

    public void setShiftName(String v) {
        shiftName = v;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String v) {
        employeeName = v;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp v) {
        createdAt = v;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp v) {
        updatedAt = v;
    }

    public Timestamp getManagerApprovedAt() {
        return managerApprovedAt;
    }

    public void setManagerApprovedAt(Timestamp v) {
        managerApprovedAt = v;
    }

    public Timestamp getHrApprovedAt() {
        return hrApprovedAt;
    }

    public void setHrApprovedAt(Timestamp v) {
        hrApprovedAt = v;
    }
}
