/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;
import java.util.Date;

public class StockTransactionDTO {
    private String transactionDate;
    private String type; // "IN" or "OUT"
    private String referenceID; // BatchID or DistributionID
    private String itemName;
    private int quantity;
    private String personInCharge;

    public StockTransactionDTO() {
    }

    public StockTransactionDTO(String transactionDate, String type, String referenceID, String itemName, int quantity, String personInCharge) {
        this.transactionDate = transactionDate;
        this.type = type;
        this.referenceID = referenceID;
        this.itemName = itemName;
        this.quantity = quantity;
        this.personInCharge = personInCharge;
    }

    public String getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(String transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReferenceID() {
        return referenceID;
    }

    public void setReferenceID(String referenceID) {
        this.referenceID = referenceID;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getPersonInCharge() {
        return personInCharge;
    }

    public void setPersonInCharge(String personInCharge) {
        this.personInCharge = personInCharge;
    }

    
    
    }