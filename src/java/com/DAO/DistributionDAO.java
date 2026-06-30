package com.DAO;

import com.Model.TentTask;
import com.Model.DistributionRule;
import java.sql.*;
import java.util.*;

public class DistributionDAO {

    String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";

    protected Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (ClassNotFoundException e) {
            throw new SQLException(e);
        }
    }

    // Retrieve all distribution rules defined by the Field Officer
    public List<DistributionRule> getAllRules() {
        List<DistributionRule> rules = new ArrayList<>();
        String sql = "SELECT dr.RuleID, dr.ItemID, i.I_Name, dr.QtyPerPerson, dr.DistType " +
                     "FROM distribution_rules dr JOIN inventoryitem i ON dr.ItemID = i.ItemID";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DistributionRule rule = new DistributionRule();
                rule.setRuleID(rs.getString("RuleID"));
                rule.setItemID(rs.getString("ItemID"));
                rule.setItemName(rs.getString("I_Name"));
                rule.setQtyPerPerson(rs.getInt("QtyPerPerson"));
                rule.setDistType(rs.getString("DistType"));
                rules.add(rule);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return rules;
    }

    public boolean addRule(String itemID, int qty, String type) {
        String sql = "INSERT INTO distribution_rules (ItemID, QtyPerPerson, DistType) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, itemID); 
            ps.setInt(2, qty); 
            ps.setString(3, type);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { 
            e.printStackTrace(); 
            return false; 
        }
    }

    public boolean deleteRule(String ruleID) {
        String sql = "DELETE FROM distribution_rules WHERE RuleID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ruleID); 
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { 
            e.printStackTrace(); 
            return false; 
        }
    }

    // Daily Check: Which tents got daily rations today?
    public Set<String> getCompletedDailyTentsToday() {
        Set<String> completed = new HashSet<>();
        String sql = "SELECT DISTINCT dl.TentID FROM distribution_log dl " +
                     "JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                     "WHERE DATE(dl.DistributedDate) = CURRENT_DATE " +
                     "AND dl.EntryType = 'OUTGOING' AND dl.RationType = 'DAILY' " +
                     "AND s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate))";
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                completed.add(rs.getString("TentID").trim());
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return completed;
    }

    // NEW LOGIC: Tracks EXACTLY which one-off items a tent has received
    public Set<String> getCompletedOneOffDeliveries(String shelterID) {
        Set<String> completed = new HashSet<>();
        String sql = "SELECT dl.TentID, dl.I_Name FROM distribution_log dl " +
                     "WHERE dl.ShelterID = ? AND dl.EntryType = 'OUTGOING' AND dl.RationType = 'ONE-OFF'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterID);
            try (ResultSet rs = ps.executeQuery()) {
                while(rs.next()) {
                    completed.add(rs.getString("TentID").trim() + "|" + rs.getString("I_Name").trim());
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return completed;
    }

    // PENDING TASKS
    public Map<String, TentTask> getAutomatedTasks(String shelterID) {
        Map<String, TentTask> taskMap = new LinkedHashMap<>();
        List<DistributionRule> rules = getAllRules();
        if (rules == null || rules.isEmpty()) return taskMap;

        Set<String> completedDailyTents = getCompletedDailyTentsToday();
        Set<String> completedOneOffs = getCompletedOneOffDeliveries(shelterID); // Dynamic Item Check

        String sql = "SELECT b.TentID, SUM(b.HouseholdSize) AS tent_pop " +
                     "FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                     "WHERE b.B_status = 'Active' AND b.ShelterID = ? " +
                     "AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                     "AND b.TentID IS NOT NULL AND b.TentID != '' " +
                     "GROUP BY b.TentID ORDER BY b.TentID ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterID.trim());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String tid = rs.getString("TentID");
                    if (tid != null) tid = tid.trim();
                    
                    int pop = rs.getInt("tent_pop");
                    boolean isDailyDone = completedDailyTents.contains(tid);

                    TentTask task = new TentTask(tid, pop);

                    for (DistributionRule rule : rules) {
                        String type = rule.getDistType().trim().toUpperCase();
                        
                        if ("DAILY".equals(type) && !isDailyDone) {
                            task.addDailyItem(rule.getItemName(), pop * rule.getQtyPerPerson());
                        } 
                        else if (type.contains("ONE") && type.contains("OFF")) {
                            // Check if THIS specific item was delivered to THIS specific tent
                            String checkKey = tid + "|" + rule.getItemName().trim();
                            if (!completedOneOffs.contains(checkKey)) {
                                Map<String, Object> kit = new HashMap<>();
                                kit.put("name", rule.getItemName());
                                kit.put("totalQty", pop * rule.getQtyPerPerson()); 
                                task.getEntryItems().add(kit);
                            }
                        }
                    }
                    
                    if (!task.getDailyItems().isEmpty() || !task.getEntryItems().isEmpty()) {
                        taskMap.put(tid, task);
                    }
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return taskMap;
    }

    // COMPLETED TASKS TODAY
    public Map<String, TentTask> getCompletedTasks(String shelterID) {
        Map<String, TentTask> taskMap = new LinkedHashMap<>();
        List<DistributionRule> rules = getAllRules();
        if (rules == null || rules.isEmpty()) return taskMap; 

        Set<String> completedDailyTents = getCompletedDailyTentsToday();
        Set<String> completedOneOffs = getCompletedOneOffDeliveries(shelterID);

        String sql = "SELECT b.TentID, SUM(b.HouseholdSize) AS tent_pop " +
                     "FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                     "WHERE b.B_status = 'Active' AND b.ShelterID = ? " +
                     "AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                     "AND b.TentID IS NOT NULL AND b.TentID != '' GROUP BY b.TentID ORDER BY b.TentID ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterID.trim());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String tid = rs.getString("TentID");
                    if (tid != null) tid = tid.trim();
                    
                    int pop = rs.getInt("tent_pop");
                    boolean isDailyDone = completedDailyTents.contains(tid);

                    TentTask task = new TentTask(tid, pop);

                    for (DistributionRule rule : rules) {
                        String type = rule.getDistType().trim().toUpperCase();

                        if ("DAILY".equals(type) && isDailyDone) {
                            task.addDailyItem(rule.getItemName(), pop * rule.getQtyPerPerson());
                        } 
                        else if (type.contains("ONE") && type.contains("OFF")) {
                            String checkKey = tid + "|" + rule.getItemName().trim();
                            if (completedOneOffs.contains(checkKey)) {
                                Map<String, Object> kit = new HashMap<>();
                                kit.put("name", rule.getItemName());
                                kit.put("totalQty", pop * rule.getQtyPerPerson()); 
                                task.getEntryItems().add(kit);
                            }
                        }
                    }

                    if (!task.getDailyItems().isEmpty() || !task.getEntryItems().isEmpty()) {
                        taskMap.put(tid, task);
                    }
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return taskMap;
    }

    // FIXED: True balance sync with Inventory Report
    private boolean deductFromFlowAllocation(Connection conn, String shelterID, String itemName, int qtyToDeduct) throws SQLException {
        String checkBalanceSql = 
            "SELECT IFNULL(SUM(CASE WHEN UPPER(TRIM(dl.EntryType)) = 'INCOMING' THEN dl.QuantityDistributed ELSE 0 END), 0) - " +
            "IFNULL(SUM(CASE WHEN UPPER(TRIM(dl.EntryType)) = 'OUTGOING' THEN dl.QuantityDistributed ELSE 0 END), 0) AS CurrentBalance " +
            "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
            "WHERE TRIM(dl.ShelterID) = TRIM(?) AND TRIM(dl.I_Name) = TRIM(?) " +
            "AND s.Status = 'Active'";

        try (PreparedStatement psFetch = conn.prepareStatement(checkBalanceSql)) {
            psFetch.setString(1, shelterID != null ? shelterID.trim() : "");
            psFetch.setString(2, itemName != null ? itemName.trim() : "");

            try (ResultSet rs = psFetch.executeQuery()) {
                if (rs.next()) {
                    int currentBalance = rs.getInt("CurrentBalance");
                    if (currentBalance >= qtyToDeduct) {
                        return true;
                    } 
                }
            }
        }
        return false;
    }

    public boolean logTentDeliveryWithFlow(String tentID, String shelterID, List<Map<String, Object>> itemsToDeduct) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            for (Map<String, Object> item : itemsToDeduct) {
                String name = (String) item.get("name");
                int qty = (Integer) item.get("totalQty");

                boolean hasEnoughStock = deductFromFlowAllocation(conn, shelterID, name, qty);
                if (!hasEnoughStock) {
                    conn.rollback(); 
                    return false;
                }

                String logbookSql = "INSERT INTO distribution_log (ShelterID, TentID, ItemID, I_Name, QuantityDistributed, RationType, EntryType, DistributedDate) VALUES (?, ?, '', ?, ?, 'DAILY', 'OUTGOING', NOW())";
                try (PreparedStatement psLog = conn.prepareStatement(logbookSql)) {
                    psLog.setString(1, shelterID); 
                    psLog.setString(2, tentID); 
                    psLog.setString(3, name); 
                    psLog.setInt(4, qty);
                    psLog.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }
    }
    
    public boolean logOneOffDeliveryWithFlow(String tentID, String shelterID, List<Map<String, Object>> itemsToDeduct) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            for (Map<String, Object> item : itemsToDeduct) {
                String name = (String) item.get("name");
                int qty = (Integer) item.get("totalQty");
                
                boolean hasEnoughStock = deductFromFlowAllocation(conn, shelterID, name, qty);
                if (!hasEnoughStock) {
                    conn.rollback();
                    return false;
                }

                String logbookSql = "INSERT INTO distribution_log (ShelterID, TentID, ItemID, I_Name, QuantityDistributed, RationType, EntryType, DistributedDate) VALUES (?, ?, '', ?, ?, 'ONE-OFF', 'OUTGOING', NOW())";
                try (PreparedStatement psLog =conn.prepareStatement(logbookSql)) {
                    psLog.setString(1, shelterID); 
                    psLog.setString(2, tentID); 
                    psLog.setString(3, name); 
                    psLog.setInt(4, qty);
                    psLog.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }
    }

    public List<Map<String, Object>> getDistributionHistory(String shelterID) {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT dl.LogID, dl.ShelterID, dl.TentID, dl.I_Name, dl.QuantityDistributed, dl.RationType, dl.EntryType, dl.DistributedDate " +
                     "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                     "WHERE dl.ShelterID = ? AND s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                     "ORDER BY dl.DistributedDate DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("logID", rs.getInt("LogID"));
                    row.put("tentID", rs.getString("TentID"));
                    row.put("itemName", rs.getString("I_Name"));
                    row.put("quantity", rs.getInt("QuantityDistributed"));
                    row.put("rationType", rs.getString("RationType"));
                    row.put("entryType", rs.getString("EntryType"));
                    row.put("date", rs.getTimestamp("DistributedDate"));
                    history.add(row);
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return history;
    }

    public List<Map<String, Object>> getDailyItemDistributionReport(String shelterID) {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql;
        
        boolean isGlobal = (shelterID == null || "All Regions".equalsIgnoreCase(shelterID) || shelterID.isEmpty());

        if (isGlobal) {
            sql = "SELECT DATE(dl.DistributedDate) AS DistDate, dl.I_Name, dl.EntryType, SUM(dl.QuantityDistributed) AS TotalQty " +
                  "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                  "WHERE s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                  "GROUP BY DATE(dl.DistributedDate), dl.I_Name, dl.EntryType ORDER BY DistDate DESC, dl.I_Name ASC";
        } else {
            sql = "SELECT DATE(dl.DistributedDate) AS DistDate, dl.I_Name, dl.EntryType, SUM(dl.QuantityDistributed) AS TotalQty " +
                  "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                  "WHERE dl.ShelterID = ? AND s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                  "GROUP BY DATE(dl.DistributedDate), dl.I_Name, dl.EntryType " +
                  "ORDER BY DistDate DESC, dl.I_Name ASC";
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (!isGlobal) {
                ps.setString(1, shelterID); 
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("DistDate"));
                    row.put("itemName", rs.getString("I_Name"));
                    row.put("entryType", rs.getString("EntryType"));
                    row.put("totalQty", rs.getInt("TotalQty"));
                    report.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return report;
    }
    
    public List<Map<String, Object>> getGlobalDistributionHistory() {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT dl.LogID, dl.ShelterID, dl.TentID, dl.I_Name, dl.QuantityDistributed, dl.RationType, dl.EntryType, dl.DistributedDate " +
                     "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                     "WHERE s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                     "ORDER BY dl.DistributedDate DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("logID", rs.getInt("LogID"));
                row.put("shelterID", rs.getString("ShelterID"));
                row.put("tentID", rs.getString("TentID"));
                row.put("itemName", rs.getString("I_Name"));
                row.put("quantity", rs.getInt("QuantityDistributed"));
                row.put("rationType", rs.getString("RationType"));
                row.put("entryType", rs.getString("EntryType"));
                row.put("date", rs.getTimestamp("DistributedDate"));
                history.add(row);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return history;
    }
    
    public List<Map<String, Object>> getFieldOfficerFilteredHistory(String shelterID, String filterType, String filterTime, String startDate, String endDate) {
        List<Map<String, Object>> history = new ArrayList<>();
        
        String dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y-%m-%d')";
        if ("WEEKLY".equalsIgnoreCase(filterTime)) {
            dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y - Week %u')";
        } else if ("MONTHLY".equalsIgnoreCase(filterTime)) {
            dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y-%m')";
        }

        String typeCondition = "";
        if ("INCOMING".equalsIgnoreCase(filterType)) {
            typeCondition = " AND dl.EntryType = 'INCOMING' ";
        } else if ("OUTGOING".equalsIgnoreCase(filterType)) {
            typeCondition = " AND dl.EntryType = 'OUTGOING' ";
        }
        
        String dateRangeCondition = "";
        boolean hasStartDate = (startDate != null && !startDate.trim().isEmpty());
        boolean hasEndDate = (endDate != null && !endDate.trim().isEmpty());
        
        if (hasStartDate) dateRangeCondition += " AND DATE(dl.DistributedDate) >= ? ";
        if (hasEndDate) dateRangeCondition += " AND DATE(dl.DistributedDate) <= ? ";

        String sql = "SELECT " + dateSelect + " AS LogDate, dl.EntryType, dl.I_Name, " +
                     ( "DAILY".equalsIgnoreCase(filterTime) ? "dl.TentID" : "'-' AS TentID" ) + ", " +
                     "SUM(dl.QuantityDistributed) AS TotalQty " +
                     "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                     "WHERE dl.ShelterID = ? AND s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                     typeCondition + dateRangeCondition +
                     "GROUP BY " + dateSelect + ", dl.I_Name, dl.EntryType" + 
                     ("DAILY".equalsIgnoreCase(filterTime) ? ", dl.TentID " : " ") +
                     "ORDER BY LogDate DESC, dl.I_Name ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            ps.setString(paramIndex++, shelterID.trim());
            
            if (hasStartDate) ps.setString(paramIndex++, startDate);
            if (hasEndDate) ps.setString(paramIndex++, endDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("LogDate"));
                    row.put("entryType", rs.getString("EntryType"));
                    row.put("itemName", rs.getString("I_Name"));
                    row.put("tentID", rs.getString("TentID"));
                    row.put("quantity", rs.getInt("TotalQty"));
                    history.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }
    
    public List<Map<String, Object>> getAdminFilteredDistributionReport(String shelterID, String filterType, String filterTime, String startDate, String endDate) {
        List<Map<String, Object>> report = new ArrayList<>();
        
        String dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y-%m-%d')"; 
        if ("WEEKLY".equalsIgnoreCase(filterTime)) {
            dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y - Week %u')";
        } else if ("MONTHLY".equalsIgnoreCase(filterTime)) {
            dateSelect = "DATE_FORMAT(dl.DistributedDate, '%Y-%m')";
        }

        String typeCondition = "";
        if ("INCOMING".equalsIgnoreCase(filterType)) {
            typeCondition = " AND dl.EntryType = 'INCOMING' ";
        } else if ("OUTGOING".equalsIgnoreCase(filterType)) {
            typeCondition = " AND dl.EntryType = 'OUTGOING' ";
        }
        
        String dateRangeCondition = "";
        boolean hasStartDate = (startDate != null && !startDate.trim().isEmpty());
        boolean hasEndDate = (endDate != null && !endDate.trim().isEmpty());
        
        if (hasStartDate) dateRangeCondition += " AND DATE(dl.DistributedDate) >= ? ";
        if (hasEndDate) dateRangeCondition += " AND DATE(dl.DistributedDate) <= ? ";

        boolean isGlobal = (shelterID == null || "All Regions".equalsIgnoreCase(shelterID) || shelterID.isEmpty() || "All".equalsIgnoreCase(shelterID));
        String shelterCondition = isGlobal ? "" : " AND dl.ShelterID = ? ";

        String sql = "SELECT " + dateSelect + " AS DistDate, dl.EntryType, dl.I_Name, SUM(dl.QuantityDistributed) AS TotalQty " +
                     "FROM distribution_log dl JOIN shelter s ON dl.ShelterID = s.ShelterID " +
                     "WHERE s.Status = 'Active' AND (s.ActivationDate IS NULL OR DATE(dl.DistributedDate) >= DATE(s.ActivationDate)) " +
                     shelterCondition + typeCondition + dateRangeCondition +
                     "GROUP BY " + dateSelect + ", dl.I_Name, dl.EntryType " +
                     "ORDER BY DistDate DESC, dl.I_Name ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (!isGlobal) {
                ps.setString(paramIndex++, shelterID.trim());
            }
            if (hasStartDate) ps.setString(paramIndex++, startDate);
            if (hasEndDate) ps.setString(paramIndex++, endDate);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", rs.getString("DistDate"));
                    row.put("entryType", rs.getString("EntryType"));
                    row.put("itemName", rs.getString("I_Name"));
                    row.put("totalQty", rs.getInt("TotalQty"));
                    report.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }
    
    // FIXED: Properly subtracts outgoing distributed items using I_Name Join
    public List<Map<String, Object>> getRemainingAllocationReport(String shelterID) {
        List<Map<String, Object>> report = new ArrayList<>();
        
        String ledgerSql = "SELECT i.ItemID, i.I_Name, dr.DistType, " +
                           "IFNULL(SUM(CASE WHEN dl.EntryType = 'INCOMING' THEN dl.QuantityDistributed ELSE 0 END), 0) AS totalAllocated, " +
                           "IFNULL(SUM(CASE WHEN dl.EntryType = 'OUTGOING' THEN dl.QuantityDistributed ELSE 0 END), 0) AS distributed, " +
                           "(IFNULL(SUM(CASE WHEN dl.EntryType = 'INCOMING' THEN dl.QuantityDistributed ELSE 0 END), 0) - " +
                           " IFNULL(SUM(CASE WHEN dl.EntryType = 'OUTGOING' THEN dl.QuantityDistributed ELSE 0 END), 0)) AS remainingBalance " +
                           "FROM distribution_rules dr " +
                           "JOIN inventoryitem i ON dr.ItemID = i.ItemID " +
                           "LEFT JOIN distribution_log dl ON TRIM(i.I_Name) = TRIM(dl.I_Name) AND dl.ShelterID = ? " + 
                           "WHERE i.ShelterID = ? " + 
                           "GROUP BY i.ItemID, i.I_Name, dr.DistType";
                         
        String popSql = "SELECT b.TentID, SUM(b.HouseholdSize) AS tent_pop " +
                        "FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                        "WHERE b.B_status = 'Active' AND b.ShelterID = ? " +
                        "AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                        "AND b.TentID IS NOT NULL AND b.TentID != '' GROUP BY b.TentID";

        Map<String, Integer> pendingDemands = new HashMap<>();
        List<DistributionRule> rules = getAllRules();
        Set<String> completedDailyTents = getCompletedDailyTentsToday();
        Set<String> completedOneOffs = getCompletedOneOffDeliveries(shelterID); // Use Dynamic Items
                        
        try (Connection conn = getConnection();
             PreparedStatement psLedger = conn.prepareStatement(ledgerSql);
             PreparedStatement psPop = conn.prepareStatement(popSql)) {
            
            psPop.setString(1, shelterID.trim());
            try (ResultSet rsPop = psPop.executeQuery()) {
                while (rsPop.next()) {
                    String tid = rsPop.getString("TentID").trim();
                    int tentPop = rsPop.getInt("tent_pop");
                    boolean isDailyDone = completedDailyTents.contains(tid);
                    
                    for (DistributionRule rule : rules) {
                        String type = rule.getDistType().trim().toUpperCase();
                        String itemID = rule.getItemID();
                        int qty = rule.getQtyPerPerson();
                        
                        int demandForThisTent = 0;
                        if ("DAILY".equals(type) && !isDailyDone) {
                            demandForThisTent = tentPop * qty;
                        } else if (type.contains("ONE") && type.contains("OFF")) {
                            // Check if tent has received THIS item
                            String checkKey = tid + "|" + rule.getItemName().trim();
                            if (!completedOneOffs.contains(checkKey)) {
                                demandForThisTent = tentPop * qty;
                            }
                        }
                        
                        if (demandForThisTent > 0) {
                            pendingDemands.put(itemID, pendingDemands.getOrDefault(itemID, 0) + demandForThisTent);
                        }
                    }
                }
            }
            
            psLedger.setString(1, shelterID.trim());
            psLedger.setString(2, shelterID.trim()); 
            try (ResultSet rsLedger = psLedger.executeQuery()) {
                while (rsLedger.next()) {
                    Map<String, Object> row = new HashMap<>();
                    String itemID = rsLedger.getString("ItemID");
                    int remainingBalance = rsLedger.getInt("remainingBalance");
                    int todayDemand = pendingDemands.getOrDefault(itemID, 0);
                    int shortage = todayDemand - remainingBalance;
                    
                    row.put("itemID", itemID);
                    row.put("itemName", rsLedger.getString("I_Name"));
                    row.put("distType", rsLedger.getString("DistType") != null ? rsLedger.getString("DistType") : "DAILY");
                    row.put("totalAllocated", rsLedger.getInt("totalAllocated"));
                    row.put("distributed", rsLedger.getInt("distributed"));
                    row.put("remainingBalance", remainingBalance);
                    row.put("todayDemand", todayDemand);
                    row.put("shortage", shortage > 0 ? shortage : 0);
                    row.put("isInsufficient", remainingBalance < todayDemand);
                    
                    report.add(row);
                }
            }
            
            for (DistributionRule rule : rules) {
                String itemID = rule.getItemID();
                int todayDemand = pendingDemands.getOrDefault(itemID, 0);
                if (todayDemand > 0) {
                    boolean exists = false;
                    for (Map<String, Object> existingRow : report) {
                        if (itemID.equals(existingRow.get("itemID"))) { exists = true; break; }
                    }
                    if (!exists) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("itemID", itemID);
                        row.put("itemName", rule.getItemName());
                        row.put("distType", rule.getDistType());
                        row.put("totalAllocated", 0);
                        row.put("distributed", 0);
                        row.put("remainingBalance", 0);
                        row.put("todayDemand", todayDemand);
                        row.put("shortage", todayDemand);
                        row.put("isInsufficient", true);
                        report.add(row);
                    }
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }
}