package com.DAO;

import com.Model.InventoryItem;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    Connection connection = null;
    String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";

    // --- SQL QUERIES ---
    private static final String INSERT_ITEM_SQL = "INSERT INTO InventoryItem (I_Name, Category, Unit, QuantityAvailable, Threshold) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_ITEM_BY_ID = "SELECT * FROM InventoryItem WHERE ItemID = ?";
    private static final String SELECT_ALL_ITEMS = "SELECT * FROM InventoryItem ORDER BY ItemID ASC";
    private static final String UPDATE_ITEM_SQL = "UPDATE InventoryItem SET I_Name = ?, Category = ?, Unit = ?, QuantityAvailable = ?, Threshold = ? WHERE ItemID = ?";
    private static final String DELETE_ITEM_SQL = "DELETE FROM InventoryItem WHERE ItemID = ?";
    private static final String CHECK_STOCK_SQL = "SELECT QuantityAvailable FROM InventoryItem WHERE ItemID = ?";

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
    // 1. CREATE: Insert New Inventory Item
    // =========================================================================
    public void insertInventoryItem(InventoryItem item) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(INSERT_ITEM_SQL)) {
            
            preparedStatement.setString(1, item.getIName());
            preparedStatement.setString(2, item.getCategory());
            preparedStatement.setString(3, item.getUnit());
            preparedStatement.setInt(4, item.getQuantityAvailable());
            preparedStatement.setInt(5, item.getThreshold());

            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            printSQLException(e);
        }
    }

    // =========================================================================
    // 2. READ: Select All Items
    // =========================================================================
    public List<InventoryItem> selectAllItems() {
        List<InventoryItem> items = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_ITEMS)) {
            
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                InventoryItem item = new InventoryItem();
                item.setItemID(rs.getString("ItemID"));
                item.setIName(rs.getString("I_Name"));
                item.setCategory(rs.getString("Category"));
                item.setUnit(rs.getString("Unit"));
                item.setQuantityAvailable(rs.getInt("QuantityAvailable"));
                item.setThreshold(rs.getInt("Threshold"));
                items.add(item);
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return items;
    }

    // =========================================================================
    // 3. READ: Select One Item by ID
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
        } catch (SQLException e) {
            printSQLException(e);
        }
        return item;
    }

    // =========================================================================
    // 4. UPDATE: Edit Item Details
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
    // 5. DELETE: Remove Item
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
    // 6. HELPER: Check Current Stock
    // =========================================================================
    public int getQuantityAvailable(String itemID) {
        int qty = 0;
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(CHECK_STOCK_SQL)) {
            
            ps.setString(1, itemID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                qty = rs.getInt("QuantityAvailable");
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return qty;
    }

    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
            }
        }
    }
}