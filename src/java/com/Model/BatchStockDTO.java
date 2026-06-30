/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;
import java.util.Date;

public class BatchStockDTO {
    private String batchID;
    private Date arrivalDate;
    private Date expiryDate;
    private int currentQuantity;
    private String supplierID;

    public BatchStockDTO() {
    }

    public BatchStockDTO(String batchID, Date arrivalDate, Date expiryDate, int currentQuantity, String supplierID) {
        this.batchID = batchID;
        this.arrivalDate = arrivalDate;
        this.expiryDate = expiryDate;
        this.currentQuantity = currentQuantity;
        this.supplierID = supplierID;
    }

    public String getBatchID() {
        return batchID;
    }

    public void setBatchID(String batchID) {
        this.batchID = batchID;
    }

    public Date getArrivalDate() {
        return arrivalDate;
    }

    public void setArrivalDate(Date arrivalDate) {
        this.arrivalDate = arrivalDate;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public int getCurrentQuantity() {
        return currentQuantity;
    }

    public void setCurrentQuantity(int currentQuantity) {
        this.currentQuantity = currentQuantity;
    }

    public String getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(String supplierID) {
        this.supplierID = supplierID;
    }    
}
