package model;

import java.sql.Timestamp;

/**
 * Model tương ứng bảng candidates (Lưu thông tin cá nhân ứng viên).
 */
public class Candidate {

    private int id;
    private String fullName;
    private String email;
    private String phone;
    private String identityCard; // CCCD / CMND
    private Timestamp createdAt;

    public Candidate() {
    }

    public Candidate(int id, String fullName, String email, String phone, String identityCard, Timestamp createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.identityCard = identityCard;
        this.createdAt = createdAt;
    }

    // ----- Getters & Setters -----
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getIdentityCard() {
        return identityCard;
    }

    public void setIdentityCard(String identityCard) {
        this.identityCard = identityCard;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}