/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

import com.Model.AidRequest;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class DashboardDAO {

    private final String URL = "jdbc:mysql://localhost:3306/adms"; 
    private final String USER = "root";
    private final String PASSWORD = "admin"; 

    private Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return con;
    }

    // --- 1. SYSTEM STATS ---
    public Map<String, Integer> getSystemStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("totalBeneficiaries", 0);
        stats.put("pendingRequests", 0);
        stats.put("lowStockItems", 0);

        try (Connection con = getConnection()) {
            if (con != null) {
                int totalPeople = 0;
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM beneficiary"); ResultSet rs = ps.executeQuery()){ if(rs.next()) totalPeople += rs.getInt(1); }
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM household"); ResultSet rs = ps.executeQuery()){ if(rs.next()) totalPeople += rs.getInt(1); }
                stats.put("totalBeneficiaries", totalPeople);

                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM aidrequest WHERE AR_Status = 'Pending'"); ResultSet rs = ps.executeQuery()){ if(rs.next()) stats.put("pendingRequests", rs.getInt(1)); }
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM inventoryitem WHERE QuantityAvailable < 50"); ResultSet rs = ps.executeQuery()){ if(rs.next()) stats.put("lowStockItems", rs.getInt(1)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }
    
    // --- 2. ANNOUNCEMENTS ---
    public List<String> getLatestAnnouncements() {
        List<String> messages = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                try(PreparedStatement ps = con.prepareStatement("SELECT content FROM message WHERE type = 'Announcement' ORDER BY created_at DESC LIMIT 3"); ResultSet rs = ps.executeQuery()){
                    while(rs.next()) { messages.add(rs.getString("content")); }
                }
            }
        } catch (Exception e) { }
        if(messages.isEmpty()) messages.add("No new announcements.");
        return messages;
    }

    // --- 3. APPROVAL OFFICER STATS ---
    public List<Integer> getOfficerPersonalStats(String officerID) {
        int app = 0, rej = 0, queue = 0;
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlMyAction = "SELECT AR_Status, COUNT(*) FROM aidrequest WHERE AR_ApprovedBy = ? GROUP BY AR_Status";
                try(PreparedStatement ps = con.prepareStatement(sqlMyAction)){
                    ps.setString(1, officerID);
                    ResultSet rs = ps.executeQuery();
                    while(rs.next()){
                        String s = rs.getString(1);
                        if("Approved".equalsIgnoreCase(s)) app = rs.getInt(2);
                        if("Rejected".equalsIgnoreCase(s)) rej = rs.getInt(2);
                    }
                }
                String sqlPending = "SELECT COUNT(*) FROM aidrequest WHERE AR_Status = 'Pending'";
                try(PreparedStatement ps = con.prepareStatement(sqlPending); ResultSet rs = ps.executeQuery()){ if(rs.next()) queue = rs.getInt(1); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        List<Integer> list = new ArrayList<>();
        list.add(app); list.add(rej); list.add(queue);
        return list;
    }
    
    public List<Integer> getRestockStatusCounts() {
        int app = 0, pen = 0, rej = 0;
        try (Connection con = getConnection()) {
            if (con != null) {
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM inventoryitem WHERE QuantityAvailable < 50"); ResultSet rs = ps.executeQuery()){ if (rs.next()) pen = rs.getInt(1); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        List<Integer> list = new ArrayList<>();
        list.add(app); list.add(pen); list.add(rej);
        return list;
    }

    // --- 4. BENEFICIARY STATUS ---
    public Map<String, Integer> getBeneficiaryStatusCounts() {
        Map<String, Integer> counts = new HashMap<>();
        int active = 0, inactive = 0; 
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlBen = "SELECT B_Status, COUNT(*) FROM beneficiary GROUP BY B_Status";
                try(PreparedStatement ps = con.prepareStatement(sqlBen); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) {
                        String s = rs.getString(1);
                        if (s != null && (s.equalsIgnoreCase("Discharged") || s.equalsIgnoreCase("Inactive"))) inactive += rs.getInt(2); else active += rs.getInt(2);
                    }
                }
                String sqlHouse = "SELECT H_status, COUNT(*) FROM household GROUP BY H_status";
                try(PreparedStatement ps = con.prepareStatement(sqlHouse); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) {
                        String s = rs.getString(1);
                        if (s != null && (s.equalsIgnoreCase("Discharged") || s.equalsIgnoreCase("Inactive"))) inactive += rs.getInt(2); else active += rs.getInt(2);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        counts.put("active", active); counts.put("inactive", inactive);
        return counts;
    }

    // --- 5. DAILY REGISTRATION TREND ---
    public Map<String, List<Object>> getDailyRegistrationTrend() {
        Map<String, List<Object>> result = new HashMap<>();
        Map<String, Integer> dateCounts = new TreeMap<>(); 
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlBen = "SELECT DATE_FORMAT(DateRegistered, '%Y-%m-%d') as d, COUNT(*) FROM beneficiary GROUP BY d";
                try(PreparedStatement ps = con.prepareStatement(sqlBen); ResultSet rs = ps.executeQuery()){
                    while(rs.next()){ String d = rs.getString(1); if(d != null) dateCounts.put(d, dateCounts.getOrDefault(d, 0) + rs.getInt(2)); }
                }
                String sqlHouse = "SELECT DATE_FORMAT(b.DateRegistered, '%Y-%m-%d') as d, COUNT(*) FROM household h JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID GROUP BY d";
                try(PreparedStatement ps = con.prepareStatement(sqlHouse); ResultSet rs = ps.executeQuery()){
                    while(rs.next()){ String d = rs.getString(1); if(d != null) dateCounts.put(d, dateCounts.getOrDefault(d, 0) + rs.getInt(2)); }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        List<Object> labels = new ArrayList<>();
        List<Object> data = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : dateCounts.entrySet()) {
            labels.add(entry.getKey()); data.add(entry.getValue());
        }
        result.put("labels", labels); result.put("data", data);
        return result;
    }
    
    // --- 6. FIELD OFFICER SPECIFIC ---
    public Map<String, Integer> getUserRequestStats(String userID) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("myTotal", 0); stats.put("myPending", 0);
        try (Connection con = getConnection()) {
            if (con != null) {
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM aidrequest WHERE RequestedBy = ?")){
                    ps.setString(1, userID); ResultSet rs = ps.executeQuery(); if (rs.next()) stats.put("myTotal", rs.getInt(1));
                }
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM aidrequest WHERE RequestedBy = ? AND AR_Status = 'Pending'")){
                    ps.setString(1, userID); ResultSet rs = ps.executeQuery(); if (rs.next()) stats.put("myPending", rs.getInt(1));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }

    public List<AidRequest> getFieldOfficerPendingList(String userID) {
        List<AidRequest> list = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                String sql = "SELECT * FROM aidrequest WHERE RequestedBy = ? AND AR_Status = 'Pending' ORDER BY AR_DateSubmitted DESC LIMIT 5";
                try(PreparedStatement ps = con.prepareStatement(sql)){
                    ps.setString(1, userID); ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        AidRequest req = new AidRequest();
                        req.setRequestID(rs.getString("RequestID"));
                        req.setArDateSubmitted(rs.getDate("AR_DateSubmitted"));
                        req.setArStatus(rs.getString("AR_Status"));
                        list.add(req);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<AidRequest> getGlobalPendingList() {
        List<AidRequest> list = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                String sql = "SELECT * FROM aidrequest WHERE AR_Status = 'Pending' ORDER BY AR_DateSubmitted ASC LIMIT 10";
                try(PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) {
                        AidRequest req = new AidRequest();
                        req.setRequestID(rs.getString("RequestID"));
                        req.setArDateSubmitted(rs.getDate("AR_DateSubmitted"));
                        req.setArStatus(rs.getString("AR_Status"));
                        list.add(req);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    // --- 7. INVENTORY CHARTS ---
    public Map<String, List<Object>> getInventoryLevels() {
        Map<String, List<Object>> result = new HashMap<>();
        List<Object> labels = new ArrayList<>();
        List<Object> data = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                try(PreparedStatement ps = con.prepareStatement("SELECT Category, SUM(QuantityAvailable) as total FROM inventoryitem GROUP BY Category"); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) { labels.add(rs.getString("Category")); data.add(rs.getInt("total")); }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        result.put("labels", labels); result.put("data", data);
        return result;
    }

    public Map<String, List<Object>> getAllInventoryItems() {
        Map<String, List<Object>> result = new HashMap<>();
        List<Object> names = new ArrayList<>();
        List<Object> quantities = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                // Fetch ALL items (Removed LIMIT 5)
                String sql = "SELECT I_Name, QuantityAvailable FROM inventoryitem ORDER BY QuantityAvailable DESC";
                try(PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) { names.add(rs.getString("I_Name")); quantities.add(rs.getInt("QuantityAvailable")); }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        result.put("names", names); result.put("quantities", quantities);
        return result;
    }
}