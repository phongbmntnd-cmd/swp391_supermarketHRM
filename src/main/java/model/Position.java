package model;

public class Position {
    private int id;
    private String title;
    private int departmentId;

    public Position() {}

    public Position(int id, String title, int departmentId) {
        this.id = id;
        this.title = title;
        this.departmentId = departmentId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }
}