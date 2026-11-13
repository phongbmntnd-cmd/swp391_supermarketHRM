/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Date;
import java.sql.Timestamp;
import java.math.BigDecimal;

public class Violation {

    private int id;
    private int userId;
    private int branchId;
    private String employeeName;
    private String branchName;
    private String title;
    private String category;
    private String description;
    private String evidenceUrl;
    private Date violationDate;
    private Timestamp recordedAt;
    private String status;
    private String reporterName;
    private String reviewerName;
    private String reviewNote;
    private String disciplinaryAction;
    private Timestamp reviewedAt;
    private BigDecimal deductionAmount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getBranchId() { return branchId; }
    public void setBranchId(int branchId) { this.branchId = branchId; }
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getCategoryLabel() {
        if ("ATTENDANCE".equals(category)) {
            return "Attendance Violation";
        }
        if ("WORKPLACE_CONDUCT".equals(category)) {
            return "Workplace Conduct";
        }
        if ("WORK_PERFORMANCE".equals(category)) {
            return "Work Performance";
        }
        if ("OPERATIONAL".equals(category)) {
            return "Operational Violation";
        }
        return "Dữ liệu lịch sử";
    }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getEvidenceUrl() { return evidenceUrl; }
    public void setEvidenceUrl(String evidenceUrl) { this.evidenceUrl = evidenceUrl; }
    public Date getViolationDate() { return violationDate; }
    public void setViolationDate(Date violationDate) { this.violationDate = violationDate; }
    public Timestamp getRecordedAt() { return recordedAt; }
    public void setRecordedAt(Timestamp recordedAt) { this.recordedAt = recordedAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }
    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }
    public String getReviewNote() { return reviewNote; }
    public void setReviewNote(String reviewNote) { this.reviewNote = reviewNote; }
    public String getDisciplinaryAction() { return disciplinaryAction; }
    public void setDisciplinaryAction(String disciplinaryAction) { this.disciplinaryAction = disciplinaryAction; }
    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }
    public BigDecimal getDeductionAmount() { return deductionAmount; }
    public void setDeductionAmount(BigDecimal deductionAmount) { this.deductionAmount = deductionAmount; }
}
