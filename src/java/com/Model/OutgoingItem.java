/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class OutgoingItem {
    private int distributionItemID;  // DistributionItemID (PK)
    private int distributionID;      // DistributionID (FK)
    private int itemID;              // ItemID (FK)
    private int batchID;             // BatchID (FK)
    private int quantityUsed;        // QuantityUsed

    public OutgoingItem() {
    }

    public OutgoingItem(int distributionItemID, int distributionID, int itemID, int batchID, int quantityUsed) {
        this.distributionItemID = distributionItemID;
        this.distributionID = distributionID;
        this.itemID = itemID;
        this.batchID = batchID;
        this.quantityUsed = quantityUsed;
    }

    public int getDistributionItemID() {
        return distributionItemID;
    }

    public void setDistributionItemID(int distributionItemID) {
        this.distributionItemID = distributionItemID;
    }

    public int getDistributionID() {
        return distributionID;
    }

    public void setDistributionID(int distributionID) {
        this.distributionID = distributionID;
    }

    public int getItemID() {
        return itemID;
    }

    public void setItemID(int itemID) {
        this.itemID = itemID;
    }

    public int getBatchID() {
        return batchID;
    }

    public void setBatchID(int batchID) {
        this.batchID = batchID;
    }

    public int getQuantityUsed() {
        return quantityUsed;
    }

    public void setQuantityUsed(int quantityUsed) {
        this.quantityUsed = quantityUsed;
    }
    
    
}
