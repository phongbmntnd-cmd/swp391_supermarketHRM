package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model tương ứng bảng recruitment_proposals.
 * Store Manager tạo đề xuất tuyển dụng ứng viên cụ thể -> HR Manager phê duyệt / từ chối.
 */
public class RecruitmentProposal {

    private int id;
    
    // ----- LIÊN KẾT ỨNG VIÊN -----
    private int candidateId;        // Khóa ngoại trỏ tới candidates.id
    private Candidate candidate;    // Đối tượng Candidate dùng khi JOIN dữ liệu

    // ----- THÔNG TIN VỊ TRÍ & CHI NHÁNH ĐỀ XUẤT -----
    private int branchId;
    private String branchName;      // JOIN branches
    private int positionId;
    private String positionTitle;   // JOIN positions
    private Integer departmentId;   // Phòng ban đề xuất (Có thể NULL)
    private String employmentType;  // FULL_TIME, PART_TIME, CASUAL
    private String shiftType;       // Ca làm việc
    private Date expirationDate;    // Ngày hết hạn đề xuất / thử việc
    private int quantity;           // Số lượng (mặc định = 1)
    private Date targetDate;
    private String reason;          // Lý do đề xuất

    // ----- TRẠNG THÁI & LUỒNG PHÊ DUYỆT -----
    private String status;          // PENDING, APPROVED, REJECTED
    private int createdBy;
    private String createdByName;   // JOIN users / employee_profiles
    private Integer approvedBy;     // Trống khi chưa duyệt
    private String approvedByName;  // JOIN users / employee_profiles
    private String hrNote;          // Lý do từ chối hoặc ghi chú từ HR

    private Timestamp createdAt;
    private Timestamp updatedAt;

    public RecruitmentProposal() {
    }

    // ----- Getters & Setters -----
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCandidateId() {
        return candidateId;
    }

    public void setCandidateId(int candidateId) {
        this.candidateId = candidateId;
    }

    public Candidate getCandidate() {
        return candidate;
    }

    public void setCandidate(Candidate candidate) {
        this.candidate = candidate;
    }

    public int getBranchId() {
        return branchId;
    }

    public void setBranchId(int branchId) {
        this.branchId = branchId;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public int getPositionId() {
        return positionId;
    }

    public void setPositionId(int positionId) {
        this.positionId = positionId;
    }

    public String getPositionTitle() {
        return positionTitle;
    }

    public void setPositionTitle(String positionTitle) {
        this.positionTitle = positionTitle;
    }

    public Integer getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }

    public String getEmploymentType() {
        return employmentType;
    }

    public void setEmploymentType(String employmentType) {
        this.employmentType = employmentType;
    }

    public String getShiftType() {
        return shiftType;
    }

    public void setShiftType(String shiftType) {
        this.shiftType = shiftType;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Date getTargetDate() {
        return targetDate;
    }

    public void setTargetDate(Date targetDate) {
        this.targetDate = targetDate;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public String getApprovedByName() {
        return approvedByName;
    }

    public void setApprovedByName(String approvedByName) {
        this.approvedByName = approvedByName;
    }

    public String getHrNote() {
        return hrNote;
    }

    public void setHrNote(String hrNote) {
        this.hrNote = hrNote;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // ----- Tiện ích hiển thị cho JSP -----
    public boolean isPending() {
        return "PENDING".equals(status);
    }

    public boolean isApproved() {
        return "APPROVED".equals(status);
    }

    public boolean isRejected() {
        return "REJECTED".equals(status);
    }
}