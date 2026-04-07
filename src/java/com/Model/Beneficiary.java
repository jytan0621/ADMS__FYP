/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;

/**
 *
 * @author User
 */
public class Beneficiary {
    protected String BeneficiaryID;
    protected String B_Name;
    protected String B_ICNumber;
    protected String B_Race; 
    protected String B_Religion; 
    protected String B_Nationality; 
    protected String B_ContactNumber;
    protected int HouseholdSize;
    protected String Street;
    protected int Postcode;
    protected String B_OKUStatus;
    protected String B_DietPreference;
    protected String B_HealthHistory;
    protected String B_Allergic;
    protected String B_Status;
    protected String RegisteredBy;
    protected String DateRegistered;
    protected String ShelterID; 
    protected String TentID;

    public Beneficiary(String BeneficiaryID, String B_Name, String B_ICNumber, String B_Race, String B_Religion, String B_Nationality, String B_ContactNumber, int HouseholdSize, String Street, int Postcode, String B_OKUStatus, String B_DietPreference, String B_HealthHistory, String B_Allergic, String B_Status, String RegisteredBy, String DateRegistered, String ShelterID, String TentID) {
        this.BeneficiaryID = BeneficiaryID;
        this.B_Name = B_Name;
        this.B_ICNumber = B_ICNumber;
        this.B_Race = B_Race;
        this.B_Religion = B_Religion;
        this.B_Nationality = B_Nationality;
        this.B_ContactNumber = B_ContactNumber;
        this.HouseholdSize = HouseholdSize;
        this.Street = Street;
        this.Postcode = Postcode;
        this.B_OKUStatus = B_OKUStatus;
        this.B_DietPreference = B_DietPreference;
        this.B_HealthHistory = B_HealthHistory;
        this.B_Allergic = B_Allergic;
        this.B_Status = B_Status;
        this.RegisteredBy = RegisteredBy;
        this.DateRegistered = DateRegistered;
        this.ShelterID = ShelterID;
        this.TentID = TentID;
    }

    public Beneficiary(String B_Name, String B_ICNumber, String B_Race, String B_Religion, String B_Nationality, String B_ContactNumber, int HouseholdSize, String Street, int Postcode, String B_OKUStatus, String B_DietPreference, String B_HealthHistory, String B_Allergic, String B_Status, String RegisteredBy, String DateRegistered) {
        this.B_Name = B_Name;
        this.B_ICNumber = B_ICNumber;
        this.B_Race = B_Race;
        this.B_Religion = B_Religion;
        this.B_Nationality = B_Nationality;
        this.B_ContactNumber = B_ContactNumber;
        this.HouseholdSize = HouseholdSize;
        this.Street = Street;
        this.Postcode = Postcode;
        this.B_OKUStatus = B_OKUStatus;
        this.B_DietPreference = B_DietPreference;
        this.B_HealthHistory = B_HealthHistory;
        this.B_Allergic = B_Allergic;
        this.B_Status = B_Status;
        this.RegisteredBy = RegisteredBy;
        this.DateRegistered = DateRegistered;
    }

    public Beneficiary(String B_Name, String B_ICNumber, String B_Race, String B_Religion, String B_Nationality, String B_ContactNumber, int HouseholdSize, String Street, int Postcode, String B_OKUStatus, String B_DietPreference, String B_HealthHistory, String B_Allergic, String B_Status, String RegisteredBy, String DateRegistered, String ShelterID, String TentID) {
        this.B_Name = B_Name;
        this.B_ICNumber = B_ICNumber;
        this.B_Race = B_Race;
        this.B_Religion = B_Religion;
        this.B_Nationality = B_Nationality;
        this.B_ContactNumber = B_ContactNumber;
        this.HouseholdSize = HouseholdSize;
        this.Street = Street;
        this.Postcode = Postcode;
        this.B_OKUStatus = B_OKUStatus;
        this.B_DietPreference = B_DietPreference;
        this.B_HealthHistory = B_HealthHistory;
        this.B_Allergic = B_Allergic;
        this.B_Status = B_Status;
        this.RegisteredBy = RegisteredBy;
        this.DateRegistered = DateRegistered;
        this.ShelterID = ShelterID;
        this.TentID = TentID;
    }

    public Beneficiary() {
    }

    public String getBeneficiaryID() {
        return BeneficiaryID;
    }

    public void setBeneficiaryID(String BeneficiaryID) {
        this.BeneficiaryID = BeneficiaryID;
    }

    public String getB_Name() {
        return B_Name;
    }

    public void setB_Name(String B_Name) {
        this.B_Name = B_Name;
    }

    public String getB_ICNumber() {
        return B_ICNumber;
    }

    public void setB_ICNumber(String B_ICNumber) {
        this.B_ICNumber = B_ICNumber;
    }

    public String getB_Race() {
        return B_Race;
    }

    public void setB_Race(String B_Race) {
        this.B_Race = B_Race;
    }

    public String getB_Religion() {
        return B_Religion;
    }

    public void setB_Religion(String B_Religion) {
        this.B_Religion = B_Religion;
    }

    public String getB_Nationality() {
        return B_Nationality;
    }

    public void setB_Nationality(String B_Nationality) {
        this.B_Nationality = B_Nationality;
    }

    public String getB_ContactNumber() {
        return B_ContactNumber;
    }

    public void setB_ContactNumber(String B_ContactNumber) {
        this.B_ContactNumber = B_ContactNumber;
    }

    public int getHouseholdSize() {
        return HouseholdSize;
    }

    public void setHouseholdSize(int HouseholdSize) {
        this.HouseholdSize = HouseholdSize;
    }

    public String getStreet() {
        return Street;
    }

    public void setStreet(String Street) {
        this.Street = Street;
    }

    public int getPostcode() {
        return Postcode;
    }

    public void setPostcode(int Postcode) {
        this.Postcode = Postcode;
    }

    public String getB_OKUStatus() {
        return B_OKUStatus;
    }

    public void setB_OKUStatus(String B_OKUStatus) {
        this.B_OKUStatus = B_OKUStatus;
    }

    public String getB_DietPreference() {
        return B_DietPreference;
    }

    public void setB_DietPreference(String B_DietPreference) {
        this.B_DietPreference = B_DietPreference;
    }

    public String getB_HealthHistory() {
        return B_HealthHistory;
    }

    public void setB_HealthHistory(String B_HealthHistory) {
        this.B_HealthHistory = B_HealthHistory;
    }

    public String getB_Allergic() {
        return B_Allergic;
    }

    public void setB_Allergic(String B_Allergic) {
        this.B_Allergic = B_Allergic;
    }

    public String getB_Status() {
        return B_Status;
    }

    public void setB_Status(String B_Status) {
        this.B_Status = B_Status;
    }

    public String getRegisteredBy() {
        return RegisteredBy;
    }

    public void setRegisteredBy(String RegisteredBy) {
        this.RegisteredBy = RegisteredBy;
    }

    public String getDateRegistered() {
        return DateRegistered;
    }

    public void setDateRegistered(String DateRegistered) {
        this.DateRegistered = DateRegistered;
    }

    public String getShelterID() {
        return ShelterID;
    }

    public void setShelterID(String ShelterID) {
        this.ShelterID = ShelterID;
    }

    public String getTentID() {
        return TentID;
    }

    public void setTentID(String TentID) {
        this.TentID = TentID;
    }

    
}
