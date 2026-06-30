/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class RestockItem {
    private String rListID;             // R_ListID (Primary Key)
    private String restockID;           // RestockID (Foreign Key)
    private String itemID;              // ItemID (Foreign Key to Inventory Item)
    private int rrQuantityRequest;   // RR_QuantityRequest

    private String itemName;

    public RestockItem() {}

    public RestockItem(String rListID, String restockID, String itemID, int rrQuantityRequest, String itemName) {
        this.rListID = rListID;
        this.restockID = restockID;
        this.itemID = itemID;
        this.rrQuantityRequest = rrQuantityRequest;
        this.itemName = itemName;
    }

    public String getrListID() {
        return rListID;
    }

    public void setrListID(String rListID) {
        this.rListID = rListID;
    }

    public String getRestockID() {
        return restockID;
    }

    public void setRestockID(String restockID) {
        this.restockID = restockID;
    }

    public String getItemID() {
        return itemID;
    }

    public void setItemID(String itemID) {
        this.itemID = itemID;
    }

    

    public int getRrQuantityRequest() {
        return rrQuantityRequest;
    }

    public void setRrQuantityRequest(int rrQuantityRequest) {
        this.rrQuantityRequest = rrQuantityRequest;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }
}
