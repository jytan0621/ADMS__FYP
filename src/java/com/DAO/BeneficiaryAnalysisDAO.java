/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

import java.sql.*;
import java.util.*;

public class BeneficiaryAnalysisDAO {

    String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) { throw new RuntimeException("DB Failed"); }
    }

    // --- FETCH ALL INDIVIDUALS (Head + Family) ---
    // UPGRADED: Includes ActivationDate filtering AND optional Shelter-specific filtering
    public List<Map<String, String>> getAllIndividuals(String shelterID) {
        List<Map<String, String>> people = new ArrayList<>();
        
        boolean isGlobal = (shelterID == null || "All Regions".equalsIgnoreCase(shelterID) || shelterID.trim().isEmpty());
        String shelterCondition = isGlobal ? "" : " AND b.ShelterID = ? ";
        
        // 1. Beneficiaries (Head of House)
        String sqlB = "SELECT b.B_ICNumber AS IC, b.B_OKUStatus AS OKU, b.B_status AS Status, b.DateRegistered " +
                      "FROM beneficiary b " +
                      "LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                      "WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate))" + shelterCondition;
        
        // 2. Household Members (Linked by BeneficiaryID)
        String sqlH = "SELECT h.H_ICNumber AS IC, h.H_OKUStatus AS OKU, h.H_status AS Status, b.DateRegistered " +
                      "FROM household h " +
                      "JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID " +
                      "LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                      "WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate))" + shelterCondition;

        try (Connection conn = getConnection()) {
            
            // Get Heads
            try (PreparedStatement ps = conn.prepareStatement(sqlB)) {
                if (!isGlobal) ps.setString(1, shelterID.trim());
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new HashMap<>();
                        row.put("IC", rs.getString("IC"));
                        row.put("OKU", rs.getString("OKU"));
                        String st = rs.getString("Status");
                        // Map 'Active'/'Inactive' to Admitted/Discharged
                        row.put("Status", "Inactive".equalsIgnoreCase(st) ? "Discharged" : "Admitted");
                        row.put("Date", rs.getString("DateRegistered"));
                        people.add(row);
                    }
                }
            }
            
            // Get Family Members
            try (PreparedStatement ps = conn.prepareStatement(sqlH)) {
                if (!isGlobal) ps.setString(1, shelterID.trim());
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new HashMap<>();
                        row.put("IC", rs.getString("IC"));
                        row.put("OKU", rs.getString("OKU"));
                        row.put("Status", rs.getString("Status")); 
                        row.put("Date", rs.getString("DateRegistered"));
                        people.add(row);
                    }
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        
        return people;
    }
    
    // OVERLOADED METHOD: If you call it without a ShelterID, it defaults to Global (All Regions)
    public List<Map<String, String>> getAllIndividuals() {
        return getAllIndividuals("All Regions");
    }
}