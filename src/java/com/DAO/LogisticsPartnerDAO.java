package com.DAO;

import com.Model.Supplier;
import com.Model.Driver;
import com.Model.Ingoing;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LogisticsPartnerDAO {

    private String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    private String jdbcUsername = "root";
    private String jdbcPassword = "admin"; // Empty for XAMPP

    public LogisticsPartnerDAO() {}

    protected Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return connection;
    }

    // =========================================================================
    // 1. INGOING STOCK METHODS (Matches ingoing Table)
    // =========================================================================

    public boolean insertIngoing(Ingoing batch) {
        // BatchID is handled by the MySQL Trigger (B0001)
        String sql = "INSERT INTO ingoing (ItemID, ExpiryDate, ArrivalDate, QuantityReceived, CurrentQuantity, ReceivedBy, DriverID, SupplierID, B_Status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, batch.getItemID());
            
            if (batch.getExpiryDate() != null) {
                ps.setDate(2, new java.sql.Date(batch.getExpiryDate().getTime()));
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            
            ps.setDate(3, new java.sql.Date(batch.getArrivalDate().getTime()));
            ps.setInt(4, batch.getQuantityReceived());
            ps.setInt(5, batch.getCurrentQuantity());
            ps.setString(6, batch.getReceivedBy());
            ps.setString(7, batch.getDriverID());
            ps.setString(8, batch.getSupplierID());
            ps.setString(9, batch.getbStatus());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // FIXED: Added GROUP BY to completely prevent duplicate records from SQL JOINs!
    public List<Ingoing> selectAllIngoing() {
        List<Ingoing> list = new ArrayList<>();
        
        String sql = "SELECT ig.BatchID, ig.ItemID, ig.ExpiryDate, ig.ArrivalDate, " +
                     "ig.QuantityReceived, ig.CurrentQuantity, ig.ReceivedBy, " +
                     "ig.DriverID, ig.SupplierID, ig.B_Status, " +
                     "MAX(i.I_Name) AS ItemName, MAX(s.SupplierName) AS SupplierName " +
                     "FROM ingoing ig " +
                     "LEFT JOIN inventoryitem i ON ig.ItemID = i.ItemID " +
                     "LEFT JOIN supplier s ON ig.SupplierID = s.SupplierID " +
                     "LEFT JOIN userprofile u ON ig.ReceivedBy = u.UserID " +
                     "LEFT JOIN shelter sh ON u.AssignedRegion = sh.ShelterID " +
                     "WHERE (sh.ActivationDate IS NULL OR DATE(ig.ArrivalDate) >= DATE(sh.ActivationDate)) " +
                     "GROUP BY ig.BatchID, ig.ItemID, ig.ExpiryDate, ig.ArrivalDate, " +
                     "ig.QuantityReceived, ig.CurrentQuantity, ig.ReceivedBy, " +
                     "ig.DriverID, ig.SupplierID, ig.B_Status " +
                     "ORDER BY ig.BatchID DESC";
        
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Ingoing batch = new Ingoing();
                batch.setBatchID(rs.getString("BatchID"));
                batch.setItemID(rs.getString("ItemID"));
                
                batch.setItemName(rs.getString("ItemName"));
                batch.setSupplierName(rs.getString("SupplierName"));
                
                batch.setExpiryDate(rs.getDate("ExpiryDate"));
                batch.setArrivalDate(rs.getDate("ArrivalDate"));
                batch.setQuantityReceived(rs.getInt("QuantityReceived"));
                batch.setCurrentQuantity(rs.getInt("CurrentQuantity"));
                batch.setReceivedBy(rs.getString("ReceivedBy"));
                batch.setDriverID(rs.getString("DriverID"));
                batch.setSupplierID(rs.getString("SupplierID"));
                batch.setbStatus(rs.getString("B_Status"));
                list.add(batch);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================================
    // 2. SUPPLIER METHODS
    // =========================================================================

    public boolean insertSupplier(Supplier supplier) {
        String sql = "INSERT INTO supplier (SupplierName, S_CNumber) VALUES (?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supplier.getSupplierName());
            ps.setString(2, supplier.getsCNumber());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Supplier> selectAllSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT * FROM supplier ORDER BY SupplierID ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Supplier s = new Supplier();
                s.setSupplierID(rs.getString("SupplierID"));
                s.setSupplierName(rs.getString("SupplierName"));
                s.setsCNumber(rs.getString("S_CNumber"));
                suppliers.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return suppliers;
    }

    // =========================================================================
    // 3. DRIVER METHODS
    // =========================================================================

    public boolean insertDriver(Driver driver) {
        String sql = "INSERT INTO driver (DriverName, Driver_cnumber, Vehicle) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, driver.getDriverName());
            ps.setString(2, driver.getDriverCnumber());
            ps.setString(3, driver.getVehicle());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Driver> selectAllDrivers() {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT * FROM driver ORDER BY DriverID ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Driver d = new Driver();
                d.setDriverID(rs.getString("DriverID"));
                d.setDriverName(rs.getString("DriverName"));
                d.setDriverCnumber(rs.getString("Driver_cnumber"));
                d.setVehicle(rs.getString("Vehicle"));
                drivers.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return drivers;
    }
    
    // =========================================================================
    // Check if a vehicle plate already exists to prevent duplicates
    // =========================================================================
    public boolean checkVehicleExists(String vehiclePlate) {
        boolean exists = false;
        String sql = "SELECT 1 FROM driver WHERE Vehicle = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setString(1, vehiclePlate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists = true; // We found a match!
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exists;
    }
}