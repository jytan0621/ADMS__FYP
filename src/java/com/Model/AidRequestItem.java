/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class AidRequestItem {
    private String listID;
    private String requestID;
    private String itemID;
    private String itemUnit;
    private String itemName;
    private int arQuantityRequested;
    
    // Optional: Add itemName here if you want to display "Rice" instead of "I0001" easily later
    // private String itemName; 

    public AidRequestItem() {
    }

    public AidRequestItem(String listID, String requestID, String itemID, String itemUnit, String itemName, int arQuantityRequested) {
        this.listID = listID;
        this.requestID = requestID;
        this.itemID = itemID;
        this.itemUnit = itemUnit;
        this.itemName = itemName;
        this.arQuantityRequested = arQuantityRequested;
    }

    public String getListID() {
        return listID;
    }

    public void setListID(String listID) {
        this.listID = listID;
    }

    public String getRequestID() {
        return requestID;
    }

    public void setRequestID(String requestID) {
        this.requestID = requestID;
    }

    public String getItemID() {
        return itemID;
    }

    public void setItemID(String itemID) {
        this.itemID = itemID;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemUnit() {
        return itemUnit;
    }

    public void setItemUnit(String itemUnit) {
        this.itemUnit = itemUnit;
    }
    
    public int getArQuantityRequested() {
        return arQuantityRequested;
    }

    public void setArQuantityRequested(int arQuantityRequested) {
        this.arQuantityRequested = arQuantityRequested;
    }

    
}