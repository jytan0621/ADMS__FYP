/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

import java.util.Date;

public class AidRequest {
    private String requestID;
    private String requestedBy;
    private String arStatus;
    private Date arDateSubmitted;
    private String arApprovedBy;
    private Date arApprovedDate;
    private String arApprovalRemark;

    // 1. Empty Constructor
    public AidRequest() {
    }

    public AidRequest(String requestID, String requestedBy, String arStatus, Date arDateSubmitted, String arApprovedBy, Date arApprovedDate, String arApprovalRemark) {
        this.requestID = requestID;
        this.requestedBy = requestedBy;
        this.arStatus = arStatus;
        this.arDateSubmitted = arDateSubmitted;
        this.arApprovedBy = arApprovedBy;
        this.arApprovedDate = arApprovedDate;
        this.arApprovalRemark = arApprovalRemark;
    }

    public String getRequestID() {
        return requestID;
    }

    public void setRequestID(String requestID) {
        this.requestID = requestID;
    }

    public String getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(String requestedBy) {
        this.requestedBy = requestedBy;
    }

    public String getArStatus() {
        return arStatus;
    }

    public void setArStatus(String arStatus) {
        this.arStatus = arStatus;
    }

    public Date getArDateSubmitted() {
        return arDateSubmitted;
    }

    public void setArDateSubmitted(Date arDateSubmitted) {
        this.arDateSubmitted = arDateSubmitted;
    }

    public String getArApprovedBy() {
        return arApprovedBy;
    }

    public void setArApprovedBy(String arApprovedBy) {
        this.arApprovedBy = arApprovedBy;
    }

    public Date getArApprovedDate() {
        return arApprovedDate;
    }

    public void setArApprovedDate(Date arApprovedDate) {
        this.arApprovedDate = arApprovedDate;
    }

    public String getArApprovalRemark() {
        return arApprovalRemark;
    }

    public void setArApprovalRemark(String arApprovalRemark) {
        this.arApprovalRemark = arApprovalRemark;
    }

    
}