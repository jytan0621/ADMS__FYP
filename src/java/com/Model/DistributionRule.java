/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

/**
 *
 * @author User
 */
public class DistributionRule {
    private String ruleID;
    private String itemID;
    private String itemName;
    private int qtyPerPerson;
    private String distType;

    public DistributionRule() {
    }

    public DistributionRule(String ruleID, String itemID, String itemName, int qtyPerPerson, String distType) {
        this.ruleID = ruleID;
        this.itemID = itemID;
        this.itemName = itemName;
        this.qtyPerPerson = qtyPerPerson;
        this.distType = distType;
    }

    public String getRuleID() {
        return ruleID;
    }

    public void setRuleID(String ruleID) {
        this.ruleID = ruleID;
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

    public int getQtyPerPerson() {
        return qtyPerPerson;
    }

    public void setQtyPerPerson(int qtyPerPerson) {
        this.qtyPerPerson = qtyPerPerson;
    }

    public String getDistType() {
        return distType;
    }

    public void setDistType(String distType) {
        this.distType = distType;
    }
    
    

}