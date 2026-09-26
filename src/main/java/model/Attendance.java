/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author nguyn
 */

import java.sql.Date;
import java.sql.Time;

public class Attendance {
    private int id;
    private int userId;
    private String fullName;
    private String username;
    private Date date;
    private Time checkIn;
    private Time checkOut;
    private String status;

    // Constructors, Getters và Setters
    public Attendance() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }

    public Time getCheckIn() { return checkIn; }
    public void setCheckIn(Time checkIn) { this.checkIn = checkIn; }

    public Time getCheckOut() { return checkOut; }
    public void setCheckOut(Time checkOut) { this.checkOut = checkOut; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}