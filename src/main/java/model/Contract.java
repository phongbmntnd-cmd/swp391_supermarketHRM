package model;

import java.sql.Date;

/**
 * Model tương ứng bảng contracts (hợp đồng lao động).
 */
public class Contract {

    private int id;
    private int userId;
    private String contractType;   // Ví dụ: Hợp đồng thử việc, Hợp đồng chính thức...
    private Date startDate;
    private Date endDate;
    private String status;         // ACTIVE, EXPIRED, TERMINATED

    public Contract() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContractType() { return contractType; }
    public void setContractType(String contractType) { this.contractType = contractType; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
