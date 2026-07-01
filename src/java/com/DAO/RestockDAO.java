package com.DAO;

import com.Model.RestockRequest;
import com.Model.RestockItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestockDAO {

    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@"; 

    

    public RestockDAO() {}

    protected Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return connection;
    }

    // =========================================================================
    // 1. CREATE: Insert Restock Request and its Item List (Transactional)
    // =========================================================================
    public boolean insertRestockRequest(RestockRequest rr) {
        String sqlRequest = "INSERT INTO restockrequest (RR_RequestedBy, RR_DateRequest, RR_Status, SupplierID) VALUES (?, ?, ?, ?)";
        String sqlGetId = "SELECT RestockID FROM restockrequest WHERE RR_RequestedBy = ? ORDER BY RestockID DESC LIMIT 1";
        String sqlItems = "INSERT INTO restockitemlist (RestockID, ItemID, RR_QuantityRequest) VALUES (?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            try (PreparedStatement psReq = conn.prepareStatement(sqlRequest)) {
                psReq.setString(1, rr.getRrRequestedBy()); 
                psReq.setTimestamp(2, new java.sql.Timestamp(rr.getRrDateRequest().getTime()));
                psReq.setString(3, rr.getRrStatus());
                psReq.setString(4, rr.getSupplierID());
                psReq.executeUpdate();
            }

            String generatedRestockID = "";
            try (PreparedStatement psGetId = conn.prepareStatement(sqlGetId)) {
                psGetId.setString(1, rr.getRrRequestedBy());
                try (ResultSet rs = psGetId.executeQuery()) {
                    if (rs.next()) {
                        generatedRestockID = rs.getString("RestockID"); 
                    }
                }
            }

            if (generatedRestockID.isEmpty()) throw new SQLException("Failed to retrieve auto-generated RestockID.");

            if (rr.getItems() != null) {
                try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                    for (RestockItem item : rr.getItems()) {
                        psItems.setString(1, generatedRestockID);   
                        psItems.setString(2, item.getItemID());     
                        psItems.setInt(3, item.getRrQuantityRequest());
                        psItems.addBatch(); 
                    }
                    psItems.executeBatch();
                }
            }

            conn.commit(); 
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    // =========================================================================
    // 2. READ ALL: Select All Restock Requests (FILTERED BY ACTIVATION DATE)
    // =========================================================================
    public List<RestockRequest> selectAllRestocks() {
        List<RestockRequest> list = new ArrayList<>();
        String sql = "SELECT r.RestockID, r.RR_DateRequest, r.RR_ApprovalDate, r.RR_Status, " +
                     "u1.UserName AS RequesterName, " +
                     "u2.UserName AS ApproverName, " +
                     "s.SupplierName " +
                     "FROM restockrequest r " +
                     "LEFT JOIN userprofile u1 ON r.RR_RequestedBy = u1.UserID " +
                     "LEFT JOIN shelter sh ON u1.AssignedRegion = sh.ShelterID " +
                     "LEFT JOIN userprofile u2 ON r.RR_ApprovedBy = u2.UserID " +
                     "LEFT JOIN supplier s ON r.SupplierID = s.SupplierID " +
                     "WHERE (sh.ActivationDate IS NULL OR DATE(r.RR_DateRequest) >= DATE(sh.ActivationDate)) " +
                     "ORDER BY r.RestockID DESC";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                RestockRequest rr = new RestockRequest();
                rr.setRestockID(rs.getString("RestockID"));          
                rr.setRrDateRequest(rs.getTimestamp("RR_DateRequest"));
                rr.setRrApprovalDate(rs.getTimestamp("RR_ApprovalDate"));
                rr.setRrStatus(rs.getString("RR_Status"));
                
                String requester = rs.getString("RequesterName");
                rr.setRrRequestedBy(requester != null ? requester : "Unknown"); 
                
                String approver = rs.getString("ApproverName");
                rr.setRrApprovedBy(approver != null ? approver : "-");   
                
                String suppName = rs.getString("SupplierName");
                rr.setSupplierID(suppName != null ? suppName : "-");
                
                list.add(rr);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // =========================================================================
    // 3. UPDATE STATUS: Standard Status Updates & Core Inventory Ingestion Loop
    // =========================================================================
    public boolean updateRestockStatus(String restockID, String status, String approvedBy) {
        String updateStatusSql = "UPDATE restockrequest SET RR_Status = ?, RR_ApprovedBy = ?, RR_ApprovalDate = ? WHERE RestockID = ?";
        
        if (!"Completed".equalsIgnoreCase(status)) {
            try (Connection conn = getConnection(); 
                 PreparedStatement ps = conn.prepareStatement(updateStatusSql)) {
                ps.setString(1, status);
                ps.setString(2, approvedBy); 
                ps.setTimestamp(3, new java.sql.Timestamp(System.currentTimeMillis()));
                ps.setString(4, restockID);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }

        String fetchItemsSql = "SELECT ItemID, RR_QuantityRequest FROM restockitemlist WHERE RestockID = ?";
        String fetchSupplierSql = "SELECT SupplierID FROM restockrequest WHERE RestockID = ?";
        
        String insertIngoingSql = "INSERT INTO ingoing (RestockID, ItemID, ExpiryDate, ArrivalDate, " +
                                  "QuantityReceived, CurrentQuantity, B_Status, ReceivedBy, SupplierID) " +
                                  "VALUES (?, ?, ?, CURRENT_DATE, ?, ?, 'Available', ?, ?)";
        
        String updateMasterInventorySql = "UPDATE inventoryitem SET QuantityAvailable = QuantityAvailable + ? WHERE ItemID = ?";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            try (PreparedStatement psStatus = conn.prepareStatement(updateStatusSql)) {
                psStatus.setString(1, status);
                psStatus.setString(2, approvedBy);
                psStatus.setTimestamp(3, new java.sql.Timestamp(System.currentTimeMillis()));
                psStatus.setString(4, restockID);
                psStatus.executeUpdate();
            }

            String supplierID = null;
            try (PreparedStatement psSupp = conn.prepareStatement(fetchSupplierSql)) {
                psSupp.setString(1, restockID);
                try (ResultSet rsSupp = psSupp.executeQuery()) {
                    if (rsSupp.next()) {
                        supplierID = rsSupp.getString("SupplierID");
                    }
                }
            }

            try (PreparedStatement psFetchItems = conn.prepareStatement(fetchItemsSql);
                 PreparedStatement psInsertIngoing = conn.prepareStatement(insertIngoingSql);
                 PreparedStatement psUpdateMaster = conn.prepareStatement(updateMasterInventorySql)) {
                
                psFetchItems.setString(1, restockID);
                try (ResultSet rsItems = psFetchItems.executeQuery()) {
                    while (rsItems.next()) {
                        String itemID = rsItems.getString("ItemID");
                        int quantity = rsItems.getInt("RR_QuantityRequest");

                        psInsertIngoing.setString(1, restockID);
                        psInsertIngoing.setString(2, itemID);
                        psInsertIngoing.setNull(3, java.sql.Types.DATE); 
                        psInsertIngoing.setInt(4, quantity); 
                        psInsertIngoing.setInt(5, quantity); 
                        psInsertIngoing.setString(6, approvedBy); 
                        psInsertIngoing.setString(7, supplierID);
                        psInsertIngoing.executeUpdate();

                        psUpdateMaster.setInt(1, quantity);
                        psUpdateMaster.setString(2, itemID);
                        psUpdateMaster.executeUpdate();
                    }
                }
            }

            conn.commit(); 
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            closeConnection(conn);
        }
    }

    // =========================================================================
    // 4. READ ONE: Select Specific Restock Request by ID
    // =========================================================================
    public RestockRequest selectRestockByID(String restockID) {
        RestockRequest rr = null;
        String sqlRequest = "SELECT * FROM restockrequest WHERE RestockID = ?";
        
        String sqlItems = "SELECT ri.RestockID, ri.ItemID, ri.RR_QuantityRequest, i.I_Name " +
                          "FROM restockitemlist ri " +
                          "JOIN inventoryitem i ON ri.ItemID = i.ItemID " +
                          "WHERE ri.RestockID = ?";

        try (Connection conn = getConnection()) { 
            try (PreparedStatement ps1 = conn.prepareStatement(sqlRequest)) {
                ps1.setString(1, restockID);
                try (ResultSet rs1 = ps1.executeQuery()) {
                    if (rs1.next()) {
                        rr = new RestockRequest();
                        rr.setRestockID(rs1.getString("RestockID"));
                        rr.setRrDateRequest(rs1.getDate("RR_DateRequest"));
                        rr.setRrApprovedBy(rs1.getString("RR_ApprovedBy"));
                        rr.setRrStatus(rs1.getString("RR_Status"));
                        rr.setRrRequestedBy(rs1.getString("RR_RequestedBy"));
                        rr.setRrApprovalDate(rs1.getDate("RR_ApprovalDate"));
                        rr.setSupplierID(rs1.getString("SupplierID")); 
                    }
                }
            }

            if (rr != null) {
                List<RestockItem> itemsList = new ArrayList<>();
                try (PreparedStatement ps2 = conn.prepareStatement(sqlItems)) {
                    ps2.setString(1, restockID);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
                            RestockItem item = new RestockItem();
                            item.setRestockID(rs2.getString("RestockID"));
                            item.setItemID(rs2.getString("ItemID"));
                            item.setItemName(rs2.getString("I_Name")); 
                            item.setRrQuantityRequest(rs2.getInt("RR_QuantityRequest"));
                            itemsList.add(item);
                        }
                    }
                }
                rr.setItems(itemsList); 
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rr;
    }

    // =========================================================================
    // 5. FETCH PENDING: Select All Active Requests (FILTERED BY ACTIVATION DATE)
    // =========================================================================
    public List<RestockRequest> getPendingRestocks() {
        List<RestockRequest> list = new ArrayList<>();
        String sqlReq = "SELECT r.RestockID, r.RR_DateRequest, r.RR_Status, " +
                        "u1.UserName AS RequesterName, " +
                        "s.SupplierName " +
                        "FROM restockrequest r " +
                        "LEFT JOIN userprofile u1 ON r.RR_RequestedBy = u1.UserID " +
                        "LEFT JOIN shelter sh ON u1.AssignedRegion = sh.ShelterID " +
                        "LEFT JOIN supplier s ON r.SupplierID = s.SupplierID " +
                        "WHERE r.RR_Status = 'Pending' " +
                        "AND (sh.ActivationDate IS NULL OR DATE(r.RR_DateRequest) >= DATE(sh.ActivationDate)) " +
                        "ORDER BY r.RR_DateRequest ASC";
        
        String sqlItems = "SELECT ri.ItemID, ri.RR_QuantityRequest, i.I_Name " +
                          "FROM restockitemlist ri " +
                          "JOIN inventoryitem i ON ri.ItemID = i.ItemID " +
                          "WHERE ri.RestockID = ?";

        try (Connection conn = getConnection(); 
             PreparedStatement psReq = conn.prepareStatement(sqlReq);
             ResultSet rsReq = psReq.executeQuery()) {

            while (rsReq.next()) {
                RestockRequest rr = new RestockRequest();
                rr.setRestockID(rsReq.getString("RestockID"));
                rr.setRrDateRequest(rsReq.getTimestamp("RR_DateRequest"));
                rr.setRrStatus(rsReq.getString("RR_Status"));

                String requester = rsReq.getString("RequesterName");
                rr.setRrRequestedBy(requester != null ? requester : "Unknown");
                
                String suppName = rsReq.getString("SupplierName");
                rr.setSupplierID(suppName != null ? suppName : "-");

                List<RestockItem> itemsList = new ArrayList<>();
                try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                    psItems.setString(1, rr.getRestockID());
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        while (rsItems.next()) {
                            RestockItem item = new RestockItem();
                            item.setRestockID(rr.getRestockID());
                            item.setItemID(rsItems.getString("ItemID"));
                            item.setItemName(rsItems.getString("I_Name")); 
                            item.setRrQuantityRequest(rsItems.getInt("RR_QuantityRequest"));
                            itemsList.add(item);
                        }
                    }
                }
                rr.setItems(itemsList);
                list.add(rr);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    // =========================================================================
    // 6. FETCH HISTORY: Select Processed/Archived Records (FILTERED)
    // =========================================================================
    public List<RestockRequest> getHistoryRestocks() {
        List<RestockRequest> list = new ArrayList<>();
        String sqlReq = "SELECT r.RestockID, r.RR_DateRequest, r.RR_ApprovalDate, r.RR_Status, " +
                        "u1.UserName AS RequesterName, u2.UserName AS ApproverName, " +
                        "s.SupplierName " +
                        "FROM restockrequest r " +
                        "LEFT JOIN userprofile u1 ON r.RR_RequestedBy = u1.UserID " +
                        "LEFT JOIN shelter sh ON u1.AssignedRegion = sh.ShelterID " +
                        "LEFT JOIN userprofile u2 ON r.RR_ApprovedBy = u2.UserID " +
                        "LEFT JOIN supplier s ON r.SupplierID = s.SupplierID " +
                        "WHERE r.RR_Status IN ('Approved', 'Rejected', 'Completed') " +
                        "AND (sh.ActivationDate IS NULL OR DATE(r.RR_DateRequest) >= DATE(sh.ActivationDate)) " +
                        "ORDER BY r.RR_ApprovalDate DESC, r.RR_DateRequest DESC";
        
        String sqlItems = "SELECT ri.ItemID, ri.RR_QuantityRequest, i.I_Name " +
                          "FROM restockitemlist ri " +
                          "JOIN inventoryitem i ON ri.ItemID = i.ItemID " +
                          "WHERE ri.RestockID = ?";

        try (Connection conn = getConnection(); 
             PreparedStatement psReq = conn.prepareStatement(sqlReq);
             ResultSet rsReq = psReq.executeQuery()) {

            while (rsReq.next()) {
                RestockRequest rr = new RestockRequest();
                rr.setRestockID(rsReq.getString("RestockID"));
                rr.setRrDateRequest(rsReq.getTimestamp("RR_DateRequest"));
                rr.setRrApprovalDate(rsReq.getTimestamp("RR_ApprovalDate"));
                rr.setRrStatus(rsReq.getString("RR_Status"));

                String requester = rsReq.getString("RequesterName");
                rr.setRrRequestedBy(requester != null ? requester : "Unknown");
                
                String approver = rsReq.getString("ApproverName");
                rr.setRrApprovedBy(approver != null ? approver : "-");

                String suppName = rsReq.getString("SupplierName");
                rr.setSupplierID(suppName != null ? suppName : "-");

                List<RestockItem> itemsList = new ArrayList<>();
                try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                    psItems.setString(1, rr.getRestockID());
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        while (rsItems.next()) {
                            RestockItem item = new RestockItem();
                            item.setRestockID(rr.getRestockID());
                            item.setItemID(rsItems.getString("ItemID"));
                            item.setItemName(rsItems.getString("I_Name")); 
                            item.setRrQuantityRequest(rsItems.getInt("RR_QuantityRequest"));
                            itemsList.add(item);
                        }
                    }
                }
                rr.setItems(itemsList);
                list.add(rr);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return list;
    }
        
    // =========================================================================
    // 7. UPDATE ITEM QUANTITY: Change Request Quantities Manually
    // =========================================================================
    public boolean updateRestockItemQuantity(String restockID, String itemID, int newQty) {
        String sql = "UPDATE restockitemlist SET RR_QuantityRequest = ? WHERE RestockID = ? AND ItemID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQty);
            ps.setString(2, restockID);
            ps.setString(3, itemID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // =========================================================================
    // 8. CLEANUP: Safe Connection Reset Utility
    // =========================================================================
    private void closeConnection(Connection conn) {
        try { 
            if (conn != null) {
                conn.setAutoCommit(true); 
                conn.close(); 
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }
}