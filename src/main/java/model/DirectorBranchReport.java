/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

public class DirectorBranchReport {

    private final int branchId;
    private final String branchCode;
    private final String branchName;
    private final String branchStatus;
    private final int employeeCount;
    private final int scheduledShifts;
    private final int recordedAttendances;
    private final int validAttendances;
    private final int adjustedAttendances;
    private final int invalidAttendances;
    private final int pendingAttendances;
    private final int payrollPayslips;
    private final BigDecimal finalizedPayroll;
    private final int violationCount;
    private final int pendingViolations;
    private final int approvedViolations;

    public DirectorBranchReport(int branchId, String branchCode, String branchName, String branchStatus,
            int employeeCount, int scheduledShifts, int recordedAttendances, int validAttendances,
            int adjustedAttendances, int invalidAttendances, int pendingAttendances, int payrollPayslips,
            BigDecimal finalizedPayroll, int violationCount, int pendingViolations, int approvedViolations) {
        this.branchId = branchId;
        this.branchCode = branchCode;
        this.branchName = branchName;
        this.branchStatus = branchStatus;
        this.employeeCount = employeeCount;
        this.scheduledShifts = scheduledShifts;
        this.recordedAttendances = recordedAttendances;
        this.validAttendances = validAttendances;
        this.adjustedAttendances = adjustedAttendances;
        this.invalidAttendances = invalidAttendances;
        this.pendingAttendances = pendingAttendances;
        this.payrollPayslips = payrollPayslips;
        this.finalizedPayroll = finalizedPayroll;
        this.violationCount = violationCount;
        this.pendingViolations = pendingViolations;
        this.approvedViolations = approvedViolations;
    }

    public int getBranchId() {
        return branchId;
    }

    public String getBranchCode() {
        return branchCode;
    }

    public String getBranchName() {
        return branchName;
    }

    public String getBranchStatus() {
        return branchStatus;
    }

    public int getEmployeeCount() {
        return employeeCount;
    }

    public int getScheduledShifts() {
        return scheduledShifts;
    }

    public int getRecordedAttendances() {
        return recordedAttendances;
    }

    public int getValidAttendances() {
        return validAttendances;
    }

    public int getAdjustedAttendances() {
        return adjustedAttendances;
    }

    public int getInvalidAttendances() {
        return invalidAttendances;
    }

    public int getPendingAttendances() {
        return pendingAttendances;
    }

    public int getPayrollPayslips() {
        return payrollPayslips;
    }

    public BigDecimal getFinalizedPayroll() {
        return finalizedPayroll;
    }

    public int getViolationCount() {
        return violationCount;
    }

    public int getPendingViolations() {
        return pendingViolations;
    }

    public int getApprovedViolations() {
        return approvedViolations;
    }
}

