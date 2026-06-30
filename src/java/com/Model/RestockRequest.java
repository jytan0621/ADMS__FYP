/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package com.Model;

import java.util.Date;
import java.util.List;

public class RestockRequest {
    private String restockID;           // RestockID (Primary Key)
    private Date rrDateRequest;      // RR_DateRequest
    private String rrApprovedBy;        // RR_ApprovedBy (Foreign Key to User)
    private String rrStatus;         // RR_Status (e.g., Pending, Approved, Rejected)
    private String rrRequestedBy;       // RR_RequestedBy (Foreign Key to User)
    private Date rrApprovalDate;  
    private String supplierID;// RR_ApprovalDate
    
    // 关联属性：一个申请包含多个物品
    private List<RestockItem> items;

    // 1. 无参数构造函数
    public RestockRequest() {}

    // 2. 全参数构造函数

    public RestockRequest(String restockID, Date rrDateRequest, String rrApprovedBy, String rrStatus, String rrRequestedBy, Date rrApprovalDate, String supplierID, List<RestockItem> items) {
        this.restockID = restockID;
        this.rrDateRequest = rrDateRequest;
        this.rrApprovedBy = rrApprovedBy;
        this.rrStatus = rrStatus;
        this.rrRequestedBy = rrRequestedBy;
        this.rrApprovalDate = rrApprovalDate;
        this.supplierID = supplierID;
        this.items = items;
    }

    public String getRestockID() {
        return restockID;
    }

    public void setRestockID(String restockID) {
        this.restockID = restockID;
    }

    public Date getRrDateRequest() {
        return rrDateRequest;
    }

    public void setRrDateRequest(Date rrDateRequest) {
        this.rrDateRequest = rrDateRequest;
    }

    public String getRrApprovedBy() {
        return rrApprovedBy;
    }

    public void setRrApprovedBy(String rrApprovedBy) {
        this.rrApprovedBy = rrApprovedBy;
    }

    public String getRrStatus() {
        return rrStatus;
    }

    public void setRrStatus(String rrStatus) {
        this.rrStatus = rrStatus;
    }

    public String getRrRequestedBy() {
        return rrRequestedBy;
    }

    public void setRrRequestedBy(String rrRequestedBy) {
        this.rrRequestedBy = rrRequestedBy;
    }

    public Date getRrApprovalDate() {
        return rrApprovalDate;
    }

    public void setRrApprovalDate(Date rrApprovalDate) {
        this.rrApprovalDate = rrApprovalDate;
    }

    public List<RestockItem> getItems() {
        return items;
    }

    public void setItems(List<RestockItem> items) {
        this.items = items;
    }

    public String getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(String supplierID) {
        this.supplierID = supplierID;
    }

    
}
