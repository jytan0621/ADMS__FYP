/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

import java.util.Date;

public class Ingoing {
    private String batchID;             // BatchID (PK)
    private String itemID;              // ItemID (FK)
    private Date expiryDate;         // Expiry Date
    private Date arrivalDate;        // ArrivalDate
    private int quantityReceived;    // QuantityReceived
    private String supplierID;          // SupplierID (FK)
    private String driverID;            // DriverID (FK)
    private String receivedBy;          // ReceivedBy (FK to User)
    private int currentQuantity;     // CurrentQuantity
    private String bStatus; 
    private String restockID;// B_Status (e.g., Available, Expired)
    private String itemName;
    private String supplierName;

    public Ingoing(String batchID, String itemID, Date expiryDate, Date arrivalDate, int quantityReceived, String supplierID, String driverID, String receivedBy, int currentQuantity, String bStatus, String restockID, String itemName, String supplierName) {
        this.batchID = batchID;
        this.itemID = itemID;
        this.expiryDate = expiryDate;
        this.arrivalDate = arrivalDate;
        this.quantityReceived = quantityReceived;
        this.supplierID = supplierID;
        this.driverID = driverID;
        this.receivedBy = receivedBy;
        this.currentQuantity = currentQuantity;
        this.bStatus = bStatus;
        this.restockID = restockID;
        this.itemName = itemName;
        this.supplierName = supplierName;
    }
    
      

    public Ingoing() {
    }

    public String getBatchID() {
        return batchID;
    }

    public void setBatchID(String batchID) {
        this.batchID = batchID;
    }

    public String getItemID() {
        return itemID;
    }

    public void setItemID(String itemID) {
        this.itemID = itemID;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Date getArrivalDate() {
        return arrivalDate;
    }

    public void setArrivalDate(Date arrivalDate) {
        this.arrivalDate = arrivalDate;
    }

    public int getQuantityReceived() {
        return quantityReceived;
    }

    public void setQuantityReceived(int quantityReceived) {
        this.quantityReceived = quantityReceived;
    }

    public String getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(String supplierID) {
        this.supplierID = supplierID;
    }

    public String getDriverID() {
        return driverID;
    }

    public void setDriverID(String driverID) {
        this.driverID = driverID;
    }

    public String getReceivedBy() {
        return receivedBy;
    }

    public void setReceivedBy(String receivedBy) {
        this.receivedBy = receivedBy;
    }

    public int getCurrentQuantity() {
        return currentQuantity;
    }

    public void setCurrentQuantity(int currentQuantity) {
        this.currentQuantity = currentQuantity;
    }

    public String getbStatus() {
        return bStatus;
    }

    public void setbStatus(String bStatus) {
        this.bStatus = bStatus;
    }

    public String getRestockID() {
        return restockID;
    }

    public void setRestockID(String restockID) {
        this.restockID = restockID;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }
    
    
    
}