/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

/**
 *
 * @author User
 */
public class Shelter {
    private String shelterID;  
    private String shelterName;
    private String state;
    private int postcode;      
    private int capacity;
    private String status;     
    private int currentBene;

    public Shelter() {
    }

    public Shelter(String shelterName, String state, int postcode, int capacity, String status) {
        this.shelterName = shelterName;
        this.state = state;
        this.postcode = postcode;
        this.capacity = capacity;
        this.status = status;
    }

    public Shelter(String shelterID, String shelterName, String state, int postcode, int capacity, String status, int currentBene) {
        this.shelterID = shelterID;
        this.shelterName = shelterName;
        this.state = state;
        this.postcode = postcode;
        this.capacity = capacity;
        this.status = status;
        this.currentBene = currentBene;
    }

    
    
    public String getShelterID() {
        return shelterID;
    }

    public void setShelterID(String shelterID) {
        this.shelterID = shelterID;
    }

    public String getShelterName() {
        return shelterName;
    }

    public void setShelterName(String shelterName) {
        this.shelterName = shelterName;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public int getPostcode() {
        return postcode;
    }

    public void setPostcode(int postcode) {
        this.postcode = postcode;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCurrentBene() {
        return currentBene;
    }

    public void setCurrentBene(int currentBene) {
        this.currentBene = currentBene;
    }
    
    
}
