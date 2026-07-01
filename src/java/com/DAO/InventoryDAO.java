package com.DAO;

import com.Model.AidRequest;
import com.Model.BatchStockDTO;
import com.Model.InventoryItem;
import com.Model.RequestItemDTO;
import com.Model.RestockItem;
import com.Model.RestockRequest;
import com.Model.StockTransactionDTO;
import com.Model.TentTask;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement; 
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class InventoryDAO {

    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@"; 

    // --- SQL QUERIES ---
    private static final String INSERT_ITEM_SQL = "INSERT INTO inventoryitem (ItemID, I_Name, Category, Unit, QuantityAvailable, Threshold) VALUES (?, ?, ?, ?, ?, ?)";
    private static final String SELECT_ITEM_BY_ID = "SELECT * FROM inventoryitem WHERE ItemID = ?";
    private static final String SELECT_ALL_ITEMS = "SELECT * FROM inventoryitem ORDER BY ItemID ASC";
    private static final String UPDATE_ITEM_SQL = "UPDATE inventoryitem SET I_Name = ?, Category = ?, Unit = ?, QuantityAvailable = ?, Threshold = ? WHERE ItemID = ?";
    private static final String DELETE_ITEM_SQL = "DELETE FROM inventoryitem WHERE ItemID = ?";
    private static final String CHECK_STOCK_SQL = "SELECT QuantityAvailable FROM inventoryitem WHERE ItemID = ?";

    public InventoryDAO() {}

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database connection failed");
        }
    }

    // =========================================================================
    // 1. CREATE (Updated to include ShelterID)
    // =========================================================================
    public void insertInventoryItem(InventoryItem item, String shelterID) throws SQLException {
        String sql = "INSERT INTO inventoryitem (ItemID, I_Name, Category, Unit, QuantityAvailable, Threshold, ShelterID) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            
            ps.setString(1, item.getItemID()); 
            ps.setString(2, item.getIName());
            ps.setString(3, item.getCategory());
            ps.setString(4, item.getUnit());
            ps.setInt(5, item.getQuantityAvailable());
            ps.setInt(6, item.getThreshold());
            ps.setString(7, shelterID); // New column
            ps.executeUpdate();
        } catch (SQLException e) { printSQLException(e); }
    }

    // =========================================================================
    // 2. READ ALL (Filtered by Shelter)
    // =========================================================================
    public List<InventoryItem> selectAllItems(String shelterID) {
        List<InventoryItem> items = new ArrayList<>();
        String sql = "SELECT * FROM inventoryitem WHERE ShelterID = ? ORDER BY ItemID ASC";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, shelterID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InventoryItem item = new InventoryItem();
                item.setItemID(rs.getString("ItemID"));
                item.setIName(rs.getString("I_Name"));
                item.setCategory(rs.getString("Category"));
                item.setUnit(rs.getString("Unit"));
                item.setQuantityAvailable(rs.getInt("QuantityAvailable"));
                item.setThreshold(rs.getInt("Threshold"));
                // item.setShelterID(rs.getString("ShelterID")); // Uncomment if you have this in your Model
                items.add(item);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return items;
    }

    // =========================================================================
    // 3. READ ONE
    // =========================================================================
    public InventoryItem selectItemByID(String itemID) {
        InventoryItem item = null;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ITEM_BY_ID)) {
            
            preparedStatement.setString(1, itemID);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                item = new InventoryItem();
                item.setItemID(rs.getString("ItemID"));
                item.setIName(rs.getString("I_Name"));
                item.setCategory(rs.getString("Category"));
                item.setUnit(rs.getString("Unit"));
                item.setQuantityAvailable(rs.getInt("QuantityAvailable"));
                item.setThreshold(rs.getInt("Threshold"));
            }
        } catch (SQLException e) { printSQLException(e); }
        return item;
    }

    // =========================================================================
    // 4. UPDATE
    // =========================================================================
    public boolean updateInventoryItem(InventoryItem item) throws SQLException {
        boolean rowUpdated;
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(UPDATE_ITEM_SQL)) {
            
            statement.setString(1, item.getIName());
            statement.setString(2, item.getCategory());
            statement.setString(3, item.getUnit());
            statement.setInt(4, item.getQuantityAvailable());
            statement.setInt(5, item.getThreshold());
            statement.setString(6, item.getItemID());
            rowUpdated = statement.executeUpdate() > 0;
        }
        return rowUpdated;
    }

    // =========================================================================
    // 5. DELETE
    // =========================================================================
    public boolean deleteInventoryItem(String itemID) throws SQLException {
        boolean rowDeleted;
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(DELETE_ITEM_SQL)) {
            
            statement.setString(1, itemID);
            rowDeleted = statement.executeUpdate() > 0;
        }
        return rowDeleted;
    }

    // =========================================================================
    // 6. Fetch Approved Aid Requests for Distribution (FILTERED)
    // =========================================================================
    public List<com.Model.AidRequest> getApprovedRequests() {
        List<com.Model.AidRequest> list = new ArrayList<>();
        
        String sql = "SELECT a.RequestID, a.AR_DateSubmitted, a.AR_ApprovedDate, a.AR_Status, " +
                     "u.UserName AS RequesterName " +
                     "FROM aidrequest a " +
                     "LEFT JOIN userprofile u ON a.RequestedBy = u.UserID " +
                     "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
                     "WHERE a.AR_Status = 'Approved' " +
                     "AND (sh.ActivationDate IS NULL OR DATE(a.AR_DateSubmitted) >= DATE(sh.ActivationDate)) " +
                     "ORDER BY a.AR_ApprovedDate DESC";
                     
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                com.Model.AidRequest ar = new com.Model.AidRequest();
                ar.setRequestID(rs.getString("RequestID"));
                
                String requester = rs.getString("RequesterName");
                ar.setRequestedBy(requester != null ? requester : "Unknown");
                
                ar.setArDateSubmitted(rs.getTimestamp("AR_DateSubmitted")); 
                ar.setArApprovedDate(rs.getTimestamp("AR_ApprovedDate"));
                ar.setArStatus(rs.getString("AR_Status"));
                list.add(ar);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================================
    // 7. Fetch specific items inside an Aid Request
    // =========================================================================
    public List<RequestItemDTO> getItemsForRequest(String requestID) {
        List<RequestItemDTO> itemList = new ArrayList<>();
        
        String sql = "SELECT ri.ItemID, i.I_Name, i.Category, ri.AR_QuantityRequested " +
                     "FROM aidrequestitem ri " +
                     "JOIN inventoryitem i ON ri.ItemID = i.ItemID " +
                     "WHERE ri.RequestID = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, requestID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RequestItemDTO dto = new RequestItemDTO();
                dto.setItemID(rs.getString("ItemID"));
                dto.setItemName(rs.getString("I_Name"));
                dto.setCategory(rs.getString("Category"));
                dto.setQuantityRequested(rs.getInt("AR_QuantityRequested"));
                dto.setQuantityApproved(rs.getInt("AR_QuantityRequested")); 
                itemList.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return itemList;
    }

    // =========================================================================
    // 8. LOGISTICS: Process the Aid Request
    // =========================================================================
    public boolean prepareAidForDistribution(String requestID, String staffID) {
        Connection conn = null;
        PreparedStatement psItems = null, psCheck = null, psUpdateStock = null, psUpdateReq = null;
        ResultSet rsItems = null, rsCheck = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            // --- A. CREATE THE MASTER OUTGOING RECORD ---
            String insertMaster = "INSERT INTO outgoing (LogisticStaff, O_Date, O_Remark, O_Status) VALUES (?, CURRENT_DATE, ?, 'Complete')";
            String uniqueRemark = "Aid Request " + requestID;

            try (PreparedStatement psMaster = conn.prepareStatement(insertMaster)) {
                psMaster.setString(1, staffID);
                psMaster.setString(2, uniqueRemark); 
                psMaster.executeUpdate();
            }
            
            String distID = "";
            String fetchIdSql = "SELECT DistributionID FROM outgoing WHERE O_Remark = ?";
            try (PreparedStatement psFetchId = conn.prepareStatement(fetchIdSql)) {
                psFetchId.setString(1, uniqueRemark);
                try (ResultSet rsId = psFetchId.executeQuery()) {
                    if (rsId.next()) {
                        distID = rsId.getString("DistributionID");
                    }
                }
            }

            if (distID == null || distID.isEmpty()) {
                conn.rollback(); 
                return false;
            }

            // --- B. PREPARE STATEMENTS FOR ITEMS ---
            String getItemsSql = "SELECT ItemID, AR_QuantityRequested FROM aidrequestitem WHERE RequestID = ?";
            psItems = conn.prepareStatement(getItemsSql);
            psItems.setString(1, requestID);
            rsItems = psItems.executeQuery();

            String checkStockSql = "SELECT QuantityAvailable FROM inventoryitem WHERE ItemID = ?";
            psCheck = conn.prepareStatement(checkStockSql);

            String updateStockSql = "UPDATE inventoryitem SET QuantityAvailable = QuantityAvailable - ? WHERE ItemID = ?";
            psUpdateStock = conn.prepareStatement(updateStockSql);
            
            String insertDetail = "INSERT INTO outgoinglist (DistributionID, ItemID, BatchID, QuantityUsed) VALUES (?, ?, ?, ?)";
            PreparedStatement psDetail = conn.prepareStatement(insertDetail);

            boolean hasItems = false;

            while (rsItems.next()) {
                hasItems = true;
                String itemID = rsItems.getString("ItemID");
                int qtyToDeduct = rsItems.getInt("AR_QuantityRequested");

                // 1. Check Master Stock
                psCheck.setString(1, itemID);
                rsCheck = psCheck.executeQuery();
                if (rsCheck.next()) {
                    if (rsCheck.getInt("QuantityAvailable") < qtyToDeduct) {
                        conn.rollback(); return false; 
                    }
                } else {
                    conn.rollback(); return false;
                }
                rsCheck.close();

                // 2. Deduct from Master Inventory table
                psUpdateStock.setInt(1, qtyToDeduct);
                psUpdateStock.setString(2, itemID);
                psUpdateStock.executeUpdate();
                
                // 3. FIFO Batch Deduction & Detail Log
                String fetchBatchesSql = "SELECT BatchID, CurrentQuantity FROM ingoing WHERE ItemID = ? AND CurrentQuantity > 0 ORDER BY ArrivalDate ASC";
                String updateBatchSql = "UPDATE ingoing SET CurrentQuantity = CurrentQuantity - ? WHERE BatchID = ?";
                
                try (PreparedStatement psFetchBatches = conn.prepareStatement(fetchBatchesSql);
                     PreparedStatement psUpdateBatch = conn.prepareStatement(updateBatchSql)) {
                    
                    psFetchBatches.setString(1, itemID);
                    ResultSet rsBatches = psFetchBatches.executeQuery();
                    int remainingToDeduct = qtyToDeduct;
                    
                    while (rsBatches.next() && remainingToDeduct > 0) {
                        String batchID = rsBatches.getString("BatchID");
                        int batchQty = rsBatches.getInt("CurrentQuantity");
                        int deductAmount = Math.min(remainingToDeduct, batchQty);
                        
                        // Update batch stock
                        psUpdateBatch.setInt(1, deductAmount);
                        psUpdateBatch.setString(2, batchID);
                        psUpdateBatch.executeUpdate();
                        
                        // SAVE TO OUTGOINGLIST
                        psDetail.setString(1, distID);
                        psDetail.setString(2, itemID);
                        psDetail.setString(3, batchID);
                        psDetail.setInt(4, deductAmount);
                        psDetail.addBatch(); 
                        
                        remainingToDeduct -= deductAmount;
                    }
                }
                psDetail.executeBatch(); 
                checkAndNotifyLowStock(itemID);
            }

            if (!hasItems) { conn.rollback(); return false; }
            psDetail.close();

            // --- C. MARK THE AID REQUEST AS DELIVERED ---
            String updateReqSql = "UPDATE aidrequest SET AR_Status = 'Delivered' WHERE RequestID = ?";
            psUpdateReq = conn.prepareStatement(updateReqSql);
            psUpdateReq.setString(1, requestID);
            psUpdateReq.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try { if (rsItems != null) rsItems.close(); } catch (SQLException e) {}
            try { if (rsCheck != null) rsCheck.close(); } catch (SQLException e) {}
            try { if (psItems != null) psItems.close(); } catch (SQLException e) {}
            try { if (psCheck != null) psCheck.close(); } catch (SQLException e) {}
            try { if (psUpdateStock != null) psUpdateStock.close(); } catch (SQLException e) {}
            try { if (psUpdateReq != null) psUpdateReq.close(); } catch (SQLException e) {}
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) {}
        }
    }

    // =========================================================================
    // 9. LOGISTICS: Master-Detail Batch Distribution 
    // =========================================================================
    public boolean processDistribution(String staffID, String itemID, String batchID, int qty, String remark) {
        String insertMaster = "INSERT INTO outgoing (LogisticStaff, O_Date, O_Remark, O_Status) VALUES (?, CURRENT_DATE, ?, 'Complete')";
        String insertDetail = "INSERT INTO outgoinglist (DistributionID, ItemID, BatchID, QuantityUsed) VALUES (?, ?, ?, ?)";
        String checkInventorySql = "SELECT QuantityAvailable FROM inventoryitem WHERE ItemID = ?";
        String updateInventory = "UPDATE inventoryitem SET QuantityAvailable = QuantityAvailable - ? WHERE ItemID = ?";
        String fetchIdSql = "SELECT DistributionID FROM outgoing WHERE LogisticStaff = ? AND O_Remark = ? ORDER BY DistributionID DESC LIMIT 1";
        
        String fetchBatchesSql = "SELECT BatchID, CurrentQuantity FROM ingoing WHERE ItemID = ? AND CurrentQuantity > 0 ORDER BY ArrivalDate ASC";
        String updateBatchSql = "UPDATE ingoing SET CurrentQuantity = CurrentQuantity - ? WHERE BatchID = ?";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 

            try (PreparedStatement psCheck = conn.prepareStatement(checkInventorySql)) {
                psCheck.setString(1, itemID);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        if (rsCheck.getInt("QuantityAvailable") < qty) {
                            conn.rollback();
                            return false; 
                        }
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement psMaster = conn.prepareStatement(insertMaster)) {
                psMaster.setString(1, staffID);
                psMaster.setString(2, remark);
                psMaster.executeUpdate();
            }
            
            String distID = "";
            try (PreparedStatement psFetchId = conn.prepareStatement(fetchIdSql)) {
                psFetchId.setString(1, staffID);
                psFetchId.setString(2, remark);
                try (ResultSet rsId = psFetchId.executeQuery()) {
                    if (rsId.next()) {
                        distID = rsId.getString("DistributionID");
                    }
                }
            }

            if (distID == null || distID.isEmpty()) {
                conn.rollback();
                return false;
            }

            int remainingToDeduct = qty;
            try (PreparedStatement psFetchBatches = conn.prepareStatement(fetchBatchesSql);
                 PreparedStatement psUpdateBatch = conn.prepareStatement(updateBatchSql);
                 PreparedStatement psDetail = conn.prepareStatement(insertDetail)) {
                
                psFetchBatches.setString(1, itemID);
                try (ResultSet rsBatches = psFetchBatches.executeQuery()) {
                    while (rsBatches.next() && remainingToDeduct > 0) {
                        String currentBatchID = rsBatches.getString("BatchID");
                        int batchQty = rsBatches.getInt("CurrentQuantity");
                        int deductAmount = Math.min(remainingToDeduct, batchQty);
                        
                        psUpdateBatch.setInt(1, deductAmount);
                        psUpdateBatch.setString(2, currentBatchID);
                        psUpdateBatch.executeUpdate();
                        
                        psDetail.setString(1, distID);
                        psDetail.setString(2, itemID);
                        psDetail.setString(3, currentBatchID);
                        psDetail.setInt(4, deductAmount);
                        psDetail.addBatch();
                        
                        remainingToDeduct -= deductAmount;
                    }
                }
                
                if (remainingToDeduct > 0) {
                    conn.rollback();
                    return false;
                }
                
                psDetail.executeBatch(); 
            }

            try (PreparedStatement psInv = conn.prepareStatement(updateInventory)) {
                psInv.setInt(1, qty);
                psInv.setString(2, itemID);
                psInv.executeUpdate();
            }

            checkAndNotifyLowStock(itemID);
            conn.commit(); 
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
            }
        }
    }

    // =========================================================================
    // 10. Fetch Outgoing Records (FILTERED)
    // =========================================================================
    public List<RequestItemDTO> getOutgoingRecords() {
        List<RequestItemDTO> list = new ArrayList<>();

        String sql = 
            "SELECT o.DistributionID AS RefID, i.I_Name AS ItemName, l.BatchID AS BatchRef, " +
            "       l.QuantityUsed AS Qty, o.O_Date AS ActionDate " +
            "FROM outgoing o " +
            "JOIN outgoinglist l ON o.DistributionID = l.DistributionID " +
            "JOIN inventoryitem i ON l.ItemID = i.ItemID " +
            "LEFT JOIN userprofile u ON o.LogisticStaff = u.UserID " +
            "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
            "WHERE (sh.ActivationDate IS NULL OR DATE(o.O_Date) >= DATE(sh.ActivationDate)) " +

            "UNION ALL " +

            "SELECT ar.RequestID AS RefID, i.I_Name AS ItemName, 'AID-REQUEST' AS BatchRef, " +
            "       ari.AR_QuantityRequested AS Qty, DATE(ar.AR_DateSubmitted) AS ActionDate " +
            "FROM aidrequest ar " +
            "JOIN aidrequestitem ari ON ar.RequestID = ari.RequestID " +
            "JOIN inventoryitem i ON ari.ItemID = i.ItemID " +
            "LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID " +
            "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
            "WHERE ar.AR_Status IN ('Delivered', 'Completed') " +
            "AND ar.RequestID NOT IN (SELECT SUBSTRING(O_Remark, 13) FROM outgoing WHERE O_Remark LIKE 'Aid Request%') " + 
            "AND (sh.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(sh.ActivationDate)) " +

            "ORDER BY ActionDate DESC, RefID DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RequestItemDTO dto = new RequestItemDTO();
                dto.setItemID(rs.getString("RefID"));      
                dto.setItemName(rs.getString("ItemName")); 
                dto.setCategory(rs.getString("BatchRef")); 
                dto.setQuantityRequested(rs.getInt("Qty"));
                dto.setActionDate(rs.getString("ActionDate")); 

                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // =========================================================================
    // 11. Add Stock to Master Inventory
    // =========================================================================
    public boolean addStockQuantity(String itemID, int quantityToAdd) {
        String sql = "UPDATE inventoryitem SET QuantityAvailable = QuantityAvailable + ? WHERE ItemID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityToAdd);
            ps.setString(2, itemID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // =========================================================================
    // Fetch Combined In/Out Stock History (FILTERED)
    // =========================================================================
    public List<StockTransactionDTO> getStockMovementHistory() {
        List<StockTransactionDTO> history = new ArrayList<>();
        
        String sql = 
            // 1. INGOING DATA
            "SELECT DATE_FORMAT(ig.ArrivalDate, '%Y-%m-%d') AS TDate, 'IN' AS Type, " +
            "ig.BatchID AS RefID, i.I_Name AS Item, ig.QuantityReceived AS Qty, ig.ReceivedBy AS PIC " +
            "FROM ingoing ig JOIN inventoryitem i ON ig.ItemID = i.ItemID " +
            "LEFT JOIN userprofile u ON ig.ReceivedBy = u.UserID " +
            "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
            "WHERE (sh.ActivationDate IS NULL OR DATE(ig.ArrivalDate) >= DATE(sh.ActivationDate)) " +
            
            "UNION ALL " +
            
            // 2. OUTGOING DATA 
            "SELECT DATE_FORMAT(o.O_Date, '%Y-%m-%d') AS TDate, 'OUT' AS Type, " +
            "o.DistributionID AS RefID, i.I_Name AS Item, l.QuantityUsed AS Qty, u.UserName AS PIC " +
            "FROM outgoing o " +
            "JOIN outgoinglist l ON o.DistributionID = l.DistributionID " +
            "JOIN inventoryitem i ON l.ItemID = i.ItemID " +
            "JOIN userprofile u ON o.LogisticStaff = u.UserID " +
            "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
            "WHERE (sh.ActivationDate IS NULL OR DATE(o.O_Date) >= DATE(sh.ActivationDate)) " +
            
            "UNION ALL " +
            
            // 3. LEGACY AID REQUEST DATA
            "SELECT DATE_FORMAT(ar.AR_DateSubmitted, '%Y-%m-%d') AS TDate, 'OUT' AS Type, " +
            "ar.RequestID AS RefID, i.I_Name AS Item, ari.AR_QuantityRequested AS Qty, u.UserName AS PIC " +
            "FROM aidrequest ar " +
            "JOIN aidrequestitem ari ON ar.RequestID = ari.RequestID " +
            "JOIN inventoryitem i ON ari.ItemID = i.ItemID " +
            "JOIN userprofile u ON ar.RequestedBy = u.UserID " +
            "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
            "WHERE ar.AR_Status IN ('Delivered', 'Completed') " +
            "AND ar.RequestID NOT IN (SELECT SUBSTRING(O_Remark, 13) FROM outgoing WHERE O_Remark LIKE 'Aid Request%') " +
            "AND (sh.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(sh.ActivationDate)) " +
            
            "ORDER BY TDate DESC, RefID DESC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                StockTransactionDTO t = new StockTransactionDTO();
                t.setTransactionDate(rs.getString("TDate"));
                t.setType(rs.getString("Type"));
                t.setReferenceID(rs.getString("RefID")); 
                t.setItemName(rs.getString("Item"));
                t.setQuantity(rs.getInt("Qty"));
                t.setPersonInCharge(rs.getString("PIC"));
                history.add(t);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return history;
    }

    // =========================================================================
    // AUTOMATED SYSTEM ALERTS
    // =========================================================================
    public void checkAndNotifyLowStock(String itemID) {
        String checkSql = "SELECT I_Name, QuantityAvailable, Threshold FROM inventoryitem WHERE ItemID = ?";
        
        String notifySql = "INSERT INTO message (SenderID, ReceiverID, Content, TimeStamp) " +
                           "SELECT 'SYSTEM', UserID, ?, CURRENT_DATE " +
                           "FROM userprofile WHERE Role IN ('Admin', 'Approval Officer')";

        try (Connection conn = getConnection();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            
            psCheck.setString(1, itemID);
            ResultSet rs = psCheck.executeQuery();
            
            if (rs.next()) {
                String itemName = rs.getString("I_Name");
                int currentQty = rs.getInt("QuantityAvailable");
                int threshold = rs.getInt("Threshold");
                
                if (currentQty <= threshold) {
                    String alertMsg = "URGENT: " + itemName + " (" + itemID + ") has dropped to " + 
                                      currentQty + " units! Please review and create a Restock Request.";
                    
                    try (PreparedStatement psNotify = conn.prepareStatement(notifySql)) {
                        psNotify.setString(1, alertMsg);
                        psNotify.executeUpdate();
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // =========================================================================
    // Fetch Active Batches for a specific Item 
    // =========================================================================
    public List<BatchStockDTO> getItemBatches(String itemID) {
        List<BatchStockDTO> list = new ArrayList<>();
        String sql = "SELECT BatchID, ArrivalDate, ExpiryDate, CurrentQuantity, SupplierID " +
                     "FROM ingoing WHERE ItemID = ? AND CurrentQuantity > 0 ORDER BY ArrivalDate ASC";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BatchStockDTO b = new BatchStockDTO();
                    b.setBatchID(rs.getString("BatchID"));
                    b.setArrivalDate(rs.getDate("ArrivalDate"));
                    b.setExpiryDate(rs.getDate("ExpiryDate"));
                    b.setCurrentQuantity(rs.getInt("CurrentQuantity"));
                    b.setSupplierID(rs.getString("SupplierID"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public Map<String, TentTask> getCombinedDistributionTasks() {
        Map<String, TentTask> taskMap = new LinkedHashMap<>();

        String sql = "SELECT b.TentID, COUNT(b.BeneficiaryID) as population, dr.ItemID, i.I_Name, dr.QtyPerPerson, dr.DistType " +
                     "FROM beneficiary b " +
                     "JOIN distribution_rules dr ON b.ShelterID = dr.ShelterID " + 
                     "JOIN inventoryitem i ON dr.ItemID = i.ItemID " +
                     "WHERE b.B_status = 'Active' " +
                     "GROUP BY b.TentID, dr.ItemID";
        return taskMap;
    }
    
    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) { e.printStackTrace(System.err); }
        }
    }
}