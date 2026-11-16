
package model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class Attendance {

    private int id;
    private int userId;
    private int shiftScheduleId;
    private String fullName;
    private String username;
    private String branchName;
    private String shiftName;
    private Date workDate;
    private Time shiftStart;
    private Time shiftEnd;
    private Timestamp checkIn;
    private Timestamp checkOut;
    private String status;
    private String adjustmentNote;
    private String adjustedBy;
    private Timestamp adjustedAt;

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

    public int getShiftScheduleId() {
        return shiftScheduleId;
    }

    public void setShiftScheduleId(int shiftScheduleId) {
        this.shiftScheduleId = shiftScheduleId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }


    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public String getShiftName() {
        return shiftName;
    }

    public void setShiftName(String shiftName) {
        this.shiftName = shiftName;
    }

    public Date getWorkDate() {
        return workDate;
    }

    public void setWorkDate(Date workDate) {
        this.workDate = workDate;
    }

    public Time getShiftStart() {
        return shiftStart;
    }

    public void setShiftStart(Time shiftStart) {
        this.shiftStart = shiftStart;
    }

    public Time getShiftEnd() {
        return shiftEnd;
    }

    public void setShiftEnd(Time shiftEnd) {
        this.shiftEnd = shiftEnd;
    }

    public Timestamp getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(Timestamp checkIn) {
        this.checkIn = checkIn;
    }

    public Timestamp getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(Timestamp checkOut) {
        this.checkOut = checkOut;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdjustmentNote() {
        return adjustmentNote;
    }

    public void setAdjustmentNote(String adjustmentNote) {
        this.adjustmentNote = adjustmentNote;
    }

    public String getAdjustedBy() {
        return adjustedBy;
    }

    public void setAdjustedBy(String adjustedBy) {
        this.adjustedBy = adjustedBy;
    }

    public Timestamp getAdjustedAt() {
        return adjustedAt;
    }

    public void setAdjustedAt(Timestamp adjustedAt) {
        this.adjustedAt = adjustedAt;
    }

    public boolean isLate() {
        return checkIn != null && shiftStart != null
                && checkIn.toLocalDateTime().toLocalTime().isAfter(shiftStart.toLocalTime());
    }
}

