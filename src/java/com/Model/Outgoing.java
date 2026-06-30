/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

import java.util.Date;
import java.util.List;

public class Outgoing {
    private int distributionID;      // DistributionID (PK)
    private int logisticStaff;       // LogisticStaff (FK to User)
    private Date oDate;              // O_Date
    private String oRemark;          // O_Remark
    private String oStatus;          // O_Status
    private List<OutgoingItem> items;

    public Outgoing() {
    }

    public Outgoing(int distributionID, int logisticStaff, Date oDate, String oRemark, String oStatus, List<OutgoingItem> items) {
        this.distributionID = distributionID;
        this.logisticStaff = logisticStaff;
        this.oDate = oDate;
        this.oRemark = oRemark;
        this.oStatus = oStatus;
        this.items = items;
    }

    public int getDistributionID() {
        return distributionID;
    }

    public void setDistributionID(int distributionID) {
        this.distributionID = distributionID;
    }

    public int getLogisticStaff() {
        return logisticStaff;
    }

    public void setLogisticStaff(int logisticStaff) {
        this.logisticStaff = logisticStaff;
    }

    public Date getoDate() {
        return oDate;
    }

    public void setoDate(Date oDate) {
        this.oDate = oDate;
    }

    public String getoRemark() {
        return oRemark;
    }

    public void setoRemark(String oRemark) {
        this.oRemark = oRemark;
    }

    public String getoStatus() {
        return oStatus;
    }

    public void setoStatus(String oStatus) {
        this.oStatus = oStatus;
    }

    public List<OutgoingItem> getItems() {
        return items;
    }

    public void setItems(List<OutgoingItem> items) {
        this.items = items;
    }
}