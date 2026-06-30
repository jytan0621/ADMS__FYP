/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

/**
 *
 * @author User
 */
public class User {
    protected String UserID;
    protected String UserName;
    protected String Email;
    protected String Password; 
    protected String Role; 
    protected String AssignedRegion; 
    protected String CreatedAt;
    protected String Status;
    private String profilePicture;
    private String shelterName;
    private String location;
    
    public User() {
    }

    public User(String UserID, String UserName, String Email, String Password, String Role, String AssignedRegion, String CreatedAt, String Status, String profilePicture, String shelterName) {
        this.UserID = UserID;
        this.UserName = UserName;
        this.Email = Email;
        this.Password = Password;
        this.Role = Role;
        this.AssignedRegion = AssignedRegion;
        this.CreatedAt = CreatedAt;
        this.Status = Status;
        this.profilePicture = profilePicture;
        this.shelterName = shelterName;
    }

    public User(String UserID, String UserName, String Email, String Password, String Role, String AssignedRegion, String shelterName, String CreatedAt, String Status) {
        this.UserID = UserID;
        this.UserName = UserName;
        this.Email = Email;
        this.Password = Password;
        this.Role = Role;
        this.AssignedRegion = AssignedRegion;
        this.shelterName = shelterName;
        this.CreatedAt = CreatedAt;
        this.Status = Status;
    }

    public User(String UserID, String UserName, String Email, String Password, String Role, String AssignedRegion, String CreatedAt, String Status) {
        this.UserID = UserID;
        this.UserName = UserName;
        this.Email = Email;
        this.Password = Password;
        this.Role = Role;
        this.AssignedRegion = AssignedRegion;
        this.CreatedAt = CreatedAt;
        this.Status = Status;
    }
    
    public String getUserID() {
        return UserID;
    }

    public void setUserID(String UserID) {
        this.UserID = UserID;
    }

    public String getUserName() {
        return UserName;
    }

    public void setUserName(String UserName) {
        this.UserName = UserName;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String Email) {
        this.Email = Email;
    }

    public String getPassword() {
        return Password;
    }

    public void setPassword(String Password) {
        this.Password = Password;
    }

    public String getRole() {
        return Role;
    }

    public void setRole(String Role) {
        this.Role = Role;
    }

    public String getAssignedRegion() {
        return AssignedRegion;
    }

    public void setAssignedRegion(String AssignedRegion) {
        this.AssignedRegion = AssignedRegion;
    }

    public String getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(String CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public String getStatus() {
        return Status;
    }

    public void setStatus(String Status) {
        this.Status = Status;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }
    public String getShelterName() {
        return shelterName;
    }

    public void setShelterName(String shelterName) {
        this.shelterName = shelterName;
    }
    
    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}