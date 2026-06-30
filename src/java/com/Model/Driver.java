/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class Driver {
    private String driverID;            // DriverID (PK)
    private String driverName;       // DriverName
    private String driverCnumber;    // Driver_cnumber
    private String vehicle;          // Vehicle

    public Driver(String driverID, String driverName, String driverCnumber, String vehicle) {
        this.driverID = driverID;
        this.driverName = driverName;
        this.driverCnumber = driverCnumber;
        this.vehicle = vehicle;
    }

    public Driver() {
    }

    public String getDriverID() {
        return driverID;
    }

    public void setDriverID(String driverID) {
        this.driverID = driverID;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverCnumber() {
        return driverCnumber;
    }

    public void setDriverCnumber(String driverCnumber) {
        this.driverCnumber = driverCnumber;
    }

    public String getVehicle() {
        return vehicle;
    }

    public void setVehicle(String vehicle) {
        this.vehicle = vehicle;
    }

    
}
