/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

/**
 *
 * @author User
 */
public class Household {
    protected String HouseholdID;
    protected String BeneficiaryID;
    protected String H_Name;
    protected String H_Nationality; 
    protected String H_IC;
    protected String H_Relationship; 
    protected String H_OKUStatus;
    protected String H_DietPreference;
    protected String H_HealthHistory;
    protected String H_Allergic;
    protected String H_Status;
    protected String TentID;

    public Household(String HouseholdID, String BeneficiaryID, String H_Name, String H_Nationality, String H_IC, String H_Relationship, String H_OKUStatus, String H_DietPreference, String H_HealthHistory, String H_Allergic, String H_Status) {
        this.HouseholdID = HouseholdID;
        this.BeneficiaryID = BeneficiaryID;
        this.H_Name = H_Name;
        this.H_Nationality = H_Nationality;
        this.H_IC = H_IC;
        this.H_Relationship = H_Relationship;
        this.H_OKUStatus = H_OKUStatus;
        this.H_DietPreference = H_DietPreference;
        this.H_HealthHistory = H_HealthHistory;
        this.H_Allergic = H_Allergic;
        this.H_Status = H_Status;
    }

    public Household(String HouseholdID, String BeneficiaryID, String H_Name, String H_Nationality, String H_IC, String H_Relationship, String H_OKUStatus, String H_DietPreference, String H_HealthHistory, String H_Allergic, String H_Status, String TentID) {
        this.HouseholdID = HouseholdID;
        this.BeneficiaryID = BeneficiaryID;
        this.H_Name = H_Name;
        this.H_Nationality = H_Nationality;
        this.H_IC = H_IC;
        this.H_Relationship = H_Relationship;
        this.H_OKUStatus = H_OKUStatus;
        this.H_DietPreference = H_DietPreference;
        this.H_HealthHistory = H_HealthHistory;
        this.H_Allergic = H_Allergic;
        this.H_Status = H_Status;
        this.TentID = TentID;
    }
    
    public Household() {}

    public String getHouseholdID() {
        return HouseholdID;
    }

    public void setHouseholdID(String HouseholdID) {
        this.HouseholdID = HouseholdID;
    }

    public String getBeneficiaryID() {
        return BeneficiaryID;
    }

    public void setBeneficiaryID(String BeneficiaryID) {
        this.BeneficiaryID = BeneficiaryID;
    }

    public String getH_Name() {
        return H_Name;
    }

    public void setH_Name(String H_Name) {
        this.H_Name = H_Name;
    }

    public String getH_Nationality() {
        return H_Nationality;
    }

    public void setH_Nationality(String H_Nationality) {
        this.H_Nationality = H_Nationality;
    }

    public String getTentID() {
        return TentID;
    }

    public void setTentID(String TentID) {
        this.TentID = TentID;
    }
    
    public String getH_IC() {
        return H_IC;
    }

    public void setH_IC(String H_IC) {
        this.H_IC = H_IC;
    }

    public String getH_Relationship() {
        return H_Relationship;
    }

    public void setH_Relationship(String H_Relationship) {
        this.H_Relationship = H_Relationship;
    }

    public String getH_OKUStatus() {
        return H_OKUStatus;
    }

    public void setH_OKUStatus(String H_OKUStatus) {
        this.H_OKUStatus = H_OKUStatus;
    }

    public String getH_DietPreference() {
        return H_DietPreference;
    }

    public void setH_DietPreference(String H_DietPreference) {
        this.H_DietPreference = H_DietPreference;
    }

    public String getH_HealthHistory() {
        return H_HealthHistory;
    }

    public void setH_HealthHistory(String H_HealthHistory) {
        this.H_HealthHistory = H_HealthHistory;
    }

    public String getH_Allergic() {
        return H_Allergic;
    }

    public void setH_Allergic(String H_Allergic) {
        this.H_Allergic = H_Allergic;
    }

    public String getH_Status() {
        return H_Status;
    }

    public void setH_Status(String H_Status) {
        this.H_Status = H_Status;
    }
    
    
}
