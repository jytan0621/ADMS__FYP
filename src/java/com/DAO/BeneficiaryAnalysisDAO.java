package com.DAO;

import java.sql.*;
import java.util.*;

public class BeneficiaryAnalysisDAO {

    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@";

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) { 
            throw new RuntimeException("DB Failed"); 
        }
    }

    // --- FETCH ALL INDIVIDUALS (Head + Family) ---
    // UPGRADED: Includes ActivationDate filtering AND optional Shelter-specific filtering
    public List<Map<String, String>> getAllIndividuals(String shelterID) {
        List<Map<String, String>> people = new ArrayList<>();
        
        // 1. Sanitize the input to safely pass to the PreparedStatement
        String safeShelterID = (shelterID == null || shelterID.trim().isEmpty()) ? "All Regions" : shelterID.trim();
        
        // 2. 100% STATIC SQL: Zero string concatenation. 
        // We use (? = 'All Regions' OR b.ShelterID = ?) to handle global vs specific logic securely inside the PreparedStatement.
        String sqlB = "SELECT b.B_ICNumber AS IC, b.B_OKUStatus AS OKU, b.B_status AS Status, b.DateRegistered " +
                      "FROM beneficiary b " +
                      "LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                      "WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                      "AND (? = 'All Regions' OR b.ShelterID = ?)";
        
        String sqlH = "SELECT h.H_ICNumber AS IC, h.H_OKUStatus AS OKU, h.H_status AS Status, b.DateRegistered " +
                      "FROM household h " +
                      "JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID " +
                      "LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                      "WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                      "AND (? = 'All Regions' OR b.ShelterID = ?)";

        try (Connection conn = getConnection()) {
            
            // Get Heads
            try (PreparedStatement ps = conn.prepareStatement(sqlB)) {
                // Bind the safeShelterID to both '?' placeholders
                ps.setString(1, safeShelterID);
                ps.setString(2, safeShelterID);
                
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
                // Bind the safeShelterID to both '?' placeholders
                ps.setString(1, safeShelterID);
                ps.setString(2, safeShelterID);
                
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