/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

public class Supplier {
    private String supplierID;          // SupplierID (PK)
    private String supplierName;     // SupplierName
    private String sCNumber;         // S_CNumber (Contact Number)

    public Supplier() {
    }

    public Supplier(String supplierID, String supplierName, String sCNumber) {
        this.supplierID = supplierID;
        this.supplierName = supplierName;
        this.sCNumber = sCNumber;
    }

    public String getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(String supplierID) {
        this.supplierID = supplierID;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getsCNumber() {
        return sCNumber;
    }

    public void setsCNumber(String sCNumber) {
        this.sCNumber = sCNumber;
    }

   
}