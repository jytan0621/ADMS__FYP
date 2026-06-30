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
        stats.put("activeShelters", 0); 

        try (Connection con = getConnection()) {
            if (con != null) {
                int totalPeople = 0;
                
                // Sum Beneficiaries
                String sqlB = "SELECT COUNT(*) FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE b.B_Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlB); ResultSet rs = ps.executeQuery()){ if(rs.next()) totalPeople += rs.getInt(1); }
                
                // Sum Households
                String sqlH = "SELECT COUNT(*) FROM household h JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE h.H_status IN ('ADMITTED', 'PENDING') AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlH); ResultSet rs = ps.executeQuery()){ if(rs.next()) totalPeople += rs.getInt(1); }
                
                stats.put("totalBeneficiaries", totalPeople);

                // Count Active Shelters
                String sqlShelter = "SELECT COUNT(*) FROM shelter WHERE Status = 'Active'";
                try(PreparedStatement ps = con.prepareStatement(sqlShelter); ResultSet rs = ps.executeQuery()){ if(rs.next()) stats.put("activeShelters", rs.getInt(1)); }

                String sqlReq = "SELECT COUNT(*) FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.AR_Status = 'Pending' AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlReq); ResultSet rs = ps.executeQuery()){ if(rs.next()) stats.put("pendingRequests", rs.getInt(1)); }
                
                try(PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM inventoryitem WHERE QuantityAvailable < 50"); ResultSet rs = ps.executeQuery()){ if(rs.next()) stats.put("lowStockItems", rs.getInt(1)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }
    
    // --- 2. ACTIVE SHELTERS SUMMARY ---
    public List<Map<String, Object>> getActiveSheltersSummary() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.ShelterID, s.ShelterName, s.Capacity, " +
                     "(SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = s.ShelterID AND b.B_Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate))) + " +
                     "(SELECT COUNT(*) FROM household h JOIN beneficiary b2 ON h.BeneficiaryID = b2.BeneficiaryID WHERE b2.ShelterID = s.ShelterID AND h.H_status IN ('ADMITTED', 'PENDING') AND (s.ActivationDate IS NULL OR DATE(b2.DateRegistered) >= DATE(s.ActivationDate))) AS CombinedTotal " +
                     "FROM shelter s WHERE s.Status = 'Active'";
                     
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("shelterID", rs.getString("ShelterID"));
                map.put("shelterName", rs.getString("ShelterName"));
                map.put("capacity", rs.getInt("Capacity"));
                map.put("combinedTotal", rs.getInt("CombinedTotal"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // --- 3. VICTIM REGISTRATION TREND ---
    public Map<String, List<Object>> getDailyRegistrationTrend(String shelterFilterID) {
        Map<String, List<Object>> result = new HashMap<>();
        Map<String, Integer> dateCounts = new TreeMap<>(); 
        
        boolean isGlobal = (shelterFilterID == null || "All".equalsIgnoreCase(shelterFilterID) || shelterFilterID.trim().isEmpty());
        String filterSql = isGlobal ? "" : " AND b.ShelterID = ? ";

        try (Connection con = getConnection()) {
            if (con != null) {
                // Add Beneficiaries
                String sqlBen = "SELECT DATE_FORMAT(b.DateRegistered, '%Y-%m-%d') as d, COUNT(*) FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " + filterSql + " GROUP BY d";
                try(PreparedStatement ps = con.prepareStatement(sqlBen)){
                    if(!isGlobal) ps.setString(1, shelterFilterID);
                    ResultSet rs = ps.executeQuery();
                    while(rs.next()){ String d = rs.getString(1); if(d != null) dateCounts.put(d, dateCounts.getOrDefault(d, 0) + rs.getInt(2)); }
                }
                
                // Add Households
                String sqlHouse = "SELECT DATE_FORMAT(b.DateRegistered, '%Y-%m-%d') as d, COUNT(*) FROM household h JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " + filterSql + " GROUP BY d";
                try(PreparedStatement ps = con.prepareStatement(sqlHouse)){
                    if(!isGlobal) ps.setString(1, shelterFilterID);
                    ResultSet rs = ps.executeQuery();
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

    // --- OTHER METHODS ---
    
    // UPDATED: Now requires userID and filters by 'Alert' to fetch system broadcasts
    public List<String> getLatestAnnouncements(String userID) {
        List<String> messages = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
                String sql = "SELECT Content FROM message WHERE ReceiverID = ? AND type = 'Alert' ORDER BY created_at DESC LIMIT 5";
                try(PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, userID);
                    try(ResultSet rs = ps.executeQuery()) {
                        while(rs.next()) { 
                            messages.add(rs.getString("Content")); 
                        }
                    }
                }
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        if(messages.isEmpty()) messages.add("No new announcements.");
        return messages;
    }

    public List<Integer> getOfficerPersonalStats(String officerID) {
        int app = 0, rej = 0, queue = 0;
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlMyAction = "SELECT ar.AR_Status, COUNT(*) FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.AR_ApprovedBy = ? AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate)) GROUP BY ar.AR_Status";
                try(PreparedStatement ps = con.prepareStatement(sqlMyAction)){
                    ps.setString(1, officerID);
                    ResultSet rs = ps.executeQuery();
                    while(rs.next()){
                        String st = rs.getString(1);
                        if("Approved".equalsIgnoreCase(st) || "Delivered".equalsIgnoreCase(st)) app += rs.getInt(2);
                        if("Rejected".equalsIgnoreCase(st)) rej += rs.getInt(2);
                    }
                }
                String sqlPending = "SELECT COUNT(*) FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.AR_Status = 'Pending' AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlPending); ResultSet rs = ps.executeQuery()){ if(rs.next()) queue = rs.getInt(1); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        List<Integer> list = new ArrayList<>();
        list.add(app); list.add(rej); list.add(queue);
        return list;
    }

    public List<Integer> getGlobalApprovalStats() {
        int app = 0, rej = 0, queue = 0;
        try (Connection con = getConnection()) {
            if (con != null) {
                String sql = "SELECT AR_Status, COUNT(*) FROM aidrequest GROUP BY AR_Status";
                try(PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()){
                    while(rs.next()){
                        String st = rs.getString(1);
                        if("Approved".equalsIgnoreCase(st) || "Delivered".equalsIgnoreCase(st) || "Completed".equalsIgnoreCase(st)) app += rs.getInt(2);
                        else if("Rejected".equalsIgnoreCase(st)) rej += rs.getInt(2);
                        else if("Pending".equalsIgnoreCase(st)) queue += rs.getInt(2);
                    }
                }
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
                String sql = "SELECT RR_Status, COUNT(*) FROM restockrequest GROUP BY RR_Status";
                try(PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()){
                    while(rs.next()){
                        String st = rs.getString(1);
                        if("Completed".equalsIgnoreCase(st) || "Approved".equalsIgnoreCase(st)) app += rs.getInt(2);
                        else if("Pending".equalsIgnoreCase(st)) pen += rs.getInt(2);
                        else if("Rejected".equalsIgnoreCase(st)) rej += rs.getInt(2);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        List<Integer> list = new ArrayList<>();
        list.add(app); list.add(pen); list.add(rej);
        return list;
    }

    public Map<String, Integer> getBeneficiaryStatusCounts() {
        Map<String, Integer> counts = new HashMap<>();
        int active = 0, inactive = 0; 
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlBen = "SELECT b.B_Status, COUNT(*) FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) GROUP BY b.B_Status";
                try(PreparedStatement ps = con.prepareStatement(sqlBen); ResultSet rs = ps.executeQuery()){
                    while (rs.next()) {
                        String s = rs.getString(1);
                        if (s != null && (s.equalsIgnoreCase("Discharged") || s.equalsIgnoreCase("Inactive"))) inactive += rs.getInt(2); else active += rs.getInt(2);
                    }
                }
                String sqlHouse = "SELECT h.H_status, COUNT(*) FROM household h JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID LEFT JOIN shelter s ON b.ShelterID = s.ShelterID WHERE (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) GROUP BY h.H_status";
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

    public Map<String, Integer> getUserRequestStats(String userID) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("myTotal", 0); stats.put("myPending", 0);
        try (Connection con = getConnection()) {
            if (con != null) {
                String sqlTot = "SELECT COUNT(*) FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.RequestedBy = ? AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlTot)){
                    ps.setString(1, userID); ResultSet rs = ps.executeQuery(); if (rs.next()) stats.put("myTotal", rs.getInt(1));
                }
                String sqlPen = "SELECT COUNT(*) FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.RequestedBy = ? AND ar.AR_Status = 'Pending' AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))";
                try(PreparedStatement ps = con.prepareStatement(sqlPen)){
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
                String sql = "SELECT ar.* FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.RequestedBy = ? AND ar.AR_Status = 'Pending' AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate)) ORDER BY ar.AR_DateSubmitted DESC LIMIT 5";
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
                String sql = "SELECT ar.* FROM aidrequest ar LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID WHERE ar.AR_Status = 'Pending' AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate)) ORDER BY ar.AR_DateSubmitted ASC LIMIT 10";
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

    public String getShelterNameByID(String shelterID) {
        if (shelterID == null || shelterID.equals("none")) return "General Area";
        String sql = "SELECT ShelterName FROM shelter WHERE ShelterID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, shelterID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("ShelterName");
        } catch (SQLException e) { e.printStackTrace(); }
        return "Unknown Shelter";
    }
    
    public Map<String, List<Object>> getAllInventoryItems() {
        Map<String, List<Object>> result = new HashMap<>();
        List<Object> names = new ArrayList<>();
        List<Object> quantities = new ArrayList<>();
        try (Connection con = getConnection()) {
            if (con != null) {
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