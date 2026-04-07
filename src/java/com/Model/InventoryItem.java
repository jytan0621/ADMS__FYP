/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class InventoryItem {
    private String itemID;
    private String IName;
    private String category;
    private String unit;
    private int quantityAvailable;
    private int threshold;

    // 1. Empty Constructor
    public InventoryItem() {
    }

    public InventoryItem(String itemID, String IName, String category, String unit, int quantityAvailable, int threshold) {
        this.itemID = itemID;
        this.IName = IName;
        this.category = category;
        this.unit = unit;
        this.quantityAvailable = quantityAvailable;
        this.threshold = threshold;
    }

    public String getItemID() {
        return itemID;
    }

    public void setItemID(String itemID) {
        this.itemID = itemID;
    }

    public String getIName() {
        return IName;
    }

    public void setIName(String IName) {
        this.IName = IName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getQuantityAvailable() {
        return quantityAvailable;
    }

    public void setQuantityAvailable(int quantityAvailable) {
        this.quantityAvailable = quantityAvailable;
    }

    public int getThreshold() {
        return threshold;
    }

    public void setThreshold(int threshold) {
        this.threshold = threshold;
    }

    

    
}