package com.DAO;

import com.Model.AidRequest;
import com.Model.AidRequestItem;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AidRequestDAO {

    Connection connection = null;
    String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";

    // =========================================================================
    //                                SQL QUERIES
    // =========================================================================
    
    private static final String INSERT_REQUEST_SQL = "INSERT INTO aidrequest (RequestedBy, AR_Status, AR_DateSubmitted) VALUES (?, ?, ?)";
    private static final String INSERT_ITEM_SQL = "INSERT INTO aidrequestitem (RequestID, ItemID, AR_QuantityRequested) VALUES (?, ?, ?)";
    
    private static final String SELECT_ITEMS_BY_REQUEST_ID = 
        "SELECT list.*, inv.I_Name, inv.Unit " +
        "FROM aidrequestitem list " +
        "JOIN inventoryitem inv ON list.ItemID = inv.ItemID " +
        "WHERE list.RequestID = ?";
    
    private static final String SELECT_ITEM_SUMMARIES = "SELECT list.RequestID, GROUP_CONCAT(DISTINCT inv.I_Name SEPARATOR ', ') AS ItemSummary FROM aidrequestitem list JOIN inventoryitem inv ON list.ItemID = inv.ItemID GROUP BY list.RequestID";
    private static final String SELECT_ALL_USERS = "SELECT UserID, UserName FROM userprofile";
    private static final String DELETE_REQUEST_SQL = "DELETE FROM aidrequest WHERE RequestID = ? AND AR_Status = 'Pending'";
    private static final String DELETE_ITEMS_BY_REQUEST_ID = "DELETE FROM aidrequestitem WHERE RequestID = ?";
    private static final String APPROVE_REJECT_SQL = "UPDATE aidrequest SET AR_Status = ?, AR_ApprovedBy = ?, AR_ApprovedDate = ?, AR_ApprovalRemark = ? WHERE RequestID = ?";

    // FIXED: Only counts reserved stock for the CURRENT disaster cycle to prevent "ghost" reservations from past years!
    private static final String GET_RESERVED_STOCK = 
        "SELECT SUM(ari.AR_QuantityRequested) AS TotalReserved " +
        "FROM aidrequestitem ari " +
        "JOIN aidrequest ar ON ari.RequestID = ar.RequestID " +
        "LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID " +
        "LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID " +
        "WHERE ari.ItemID = ? AND ar.AR_Status = 'Approved' " +
        "AND (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))";

    public AidRequestDAO() {}

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database connection failed");
        }
    }

    // --- METHOD: Used by DashboardServlet to count global statistics ---
    public int countRequestsByStatus(String status) {
        int count = 0;
        String sql = "SELECT COUNT(*) AS total FROM aidrequest WHERE AR_Status = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) { count = rs.getInt("total"); }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }

    public int getReservedStock(String itemID) {
        int reserved = 0;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(GET_RESERVED_STOCK)) {
            ps.setString(1, itemID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                reserved = rs.getInt("TotalReserved");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return reserved;
    }

    public Map<String, String> getAllItemSummaries() {
        Map<String, String> summaries = new HashMap<>();
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(SELECT_ITEM_SUMMARIES);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                summaries.put(rs.getString("RequestID"), rs.getString("ItemSummary"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return summaries;
    }

    public Map<String, String> getAllUserNames() {
        Map<String, String> userMap = new HashMap<>();
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(SELECT_ALL_USERS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                userMap.put(rs.getString("UserID"), rs.getString("UserName"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return userMap;
    }

    public String insertAidRequest(AidRequest request) throws SQLException {
        String generatedID = null;
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(INSERT_REQUEST_SQL)) {
            ps.setString(1, request.getRequestedBy()); 
            ps.setString(2, "Pending"); 
            ps.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.executeUpdate();
        } catch (SQLException e) { printSQLException(e); return null; }

        String fetchIdSQL = "SELECT RequestID FROM aidrequest WHERE RequestedBy = ? ORDER BY RequestID DESC LIMIT 1";
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(fetchIdSQL)) {
            ps.setString(1, request.getRequestedBy());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) generatedID = rs.getString("RequestID");
            }
        } catch (SQLException e) { printSQLException(e); }
        return generatedID; 
    }

    public void insertRequestItem(AidRequestItem item) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(INSERT_ITEM_SQL)) {
            ps.setString(1, item.getRequestID()); 
            ps.setString(2, item.getItemID());    
            ps.setInt(3, item.getArQuantityRequested());
            ps.executeUpdate();
        } catch (SQLException e) { printSQLException(e); }
    }

    public List<AidRequestItem> selectItemsByRequestID(String requestID) {
        List<AidRequestItem> items = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(SELECT_ITEMS_BY_REQUEST_ID)) {
            ps.setString(1, requestID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AidRequestItem item = new AidRequestItem();
                item.setListID(rs.getString("ListID"));
                item.setRequestID(rs.getString("RequestID"));
                item.setItemID(rs.getString("ItemID"));
                item.setArQuantityRequested(rs.getInt("AR_QuantityRequested"));
                item.setItemName(rs.getString("I_Name"));
                item.setItemUnit(rs.getString("Unit")); 
                items.add(item);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return items;
    }

    public AidRequest selectAidRequest(String requestID) {
        AidRequest request = null;
        String sql = "SELECT * FROM aidrequest WHERE RequestID = ?"; 
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, requestID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                request = new AidRequest();
                request.setRequestID(rs.getString("RequestID"));
                request.setRequestedBy(rs.getString("RequestedBy"));
                request.setArStatus(rs.getString("AR_Status"));
                request.setArDateSubmitted(rs.getTimestamp("AR_DateSubmitted"));
                try { request.setArApprovedBy(rs.getString("AR_ApprovedBy")); } catch (Exception e) {}
                try { request.setArApprovedDate(rs.getTimestamp("AR_ApprovedDate")); } catch (Exception e) {}
                try { request.setArApprovalRemark(rs.getString("AR_ApprovalRemark")); } catch (Exception e) {}
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return request;
    }
    
    public List<AidRequest> selectAllRequests(String userID, String role, String statusFilter) {
        List<AidRequest> requests = new ArrayList<>();
        
        // 1. Base Query with the Activation Date filter built-in
        StringBuilder sql = new StringBuilder(
            "SELECT ar.* FROM aidrequest ar " +
            "LEFT JOIN userprofile u ON ar.RequestedBy = u.UserID " +
            "LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID " +
            "WHERE (s.ActivationDate IS NULL OR DATE(ar.AR_DateSubmitted) >= DATE(s.ActivationDate))"
        );
        
        List<Object> parameters = new ArrayList<>();

        // 2. Role Restriction
        boolean isAdminOrApprover = "Admin".equalsIgnoreCase(role) || "Approval Officer".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role);
        
        if (!isAdminOrApprover) {
            sql.append(" AND ar.RequestedBy = ?");
            parameters.add(userID);
        }

        // 3. Status Filtering
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !statusFilter.equals("All")) {
            sql.append(" AND ar.AR_Status = ?");
            parameters.add(statusFilter);
        }

        // 4. Ordering
        sql.append(" ORDER BY ar.AR_DateSubmitted DESC");

        // 5. Execution
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AidRequest request = new AidRequest();
                request.setRequestID(rs.getString("RequestID"));
                request.setRequestedBy(rs.getString("RequestedBy"));
                request.setArStatus(rs.getString("AR_Status"));
                request.setArDateSubmitted(rs.getTimestamp("AR_DateSubmitted"));

                try { request.setArApprovedBy(rs.getString("AR_ApprovedBy")); } catch (Exception e) {}
                try { request.setArApprovedDate(rs.getTimestamp("AR_ApprovedDate")); } catch (Exception e) {}
                try { request.setArApprovalRemark(rs.getString("AR_ApprovalRemark")); } catch (Exception e) {}

                requests.add(request);
            }
        } catch (SQLException e) {
            e.printStackTrace(); 
        }
        return requests;
    }

    public boolean deleteAidRequest(String requestID) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(DELETE_REQUEST_SQL)) {
            ps.setString(1, requestID);
            return ps.executeUpdate() > 0;
        }
    }

    public void deleteItemsByRequestID(String requestID) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(DELETE_ITEMS_BY_REQUEST_ID)) {
            ps.setString(1, requestID);
            ps.executeUpdate();
        }
    }
    
    public boolean processApproval(String requestID, String status, String adminID, String remark) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(APPROVE_REJECT_SQL)) {
            ps.setString(1, status); 
            ps.setString(2, adminID); 
            ps.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
            ps.setString(4, remark); 
            ps.setString(5, requestID);
            return ps.executeUpdate() > 0;
        }
    }

    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
            }
        }
    }
}