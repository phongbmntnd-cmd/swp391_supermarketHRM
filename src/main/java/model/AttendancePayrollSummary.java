/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class AttendancePayrollSummary {

    private int userId;
    private String username;
    private String fullName;
    private String branchName;
    private int approvedShiftCount;
    private long totalMinutes;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public int getApprovedShiftCount() {
        return approvedShiftCount;
    }

    public void setApprovedShiftCount(int approvedShiftCount) {
        this.approvedShiftCount = approvedShiftCount;
    }

    public long getTotalMinutes() {
        return totalMinutes;
    }

    public void setTotalMinutes(long totalMinutes) {
        this.totalMinutes = totalMinutes;
    }

    public double getTotalHours() {
        return totalMinutes / 60.0;
    }
}

