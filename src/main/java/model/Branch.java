package model;

import java.sql.Timestamp;

public class Branch {
    private int id;
    private String code;
    private String name;
    private String address;
    private String status;
    private int storeManagerId;
    private Timestamp createdAt;

    public Branch() {}

    public Branch(int id, String code, String name, String address, String status, int storeManagerId, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.address = address;
        this.status = status;
        this.storeManagerId = storeManagerId;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getStoreManagerId() {
        return storeManagerId;
    }

    public void setStoreManagerId(int storeManagerId) {
        this.storeManagerId = storeManagerId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    
}