/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

import com.Model.Shelter;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ShelterDAO {
    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@";

    protected Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (ClassNotFoundException e) { throw new SQLException(e); }
    }

    public void insertShelter(Shelter shelter) throws SQLException {
        String sql = "INSERT INTO shelter (ShelterName, State, Postcode, Capacity, Status, ActivationDate) VALUES (?, ?, ?, ?, ?, CURRENT_DATE)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelter.getShelterName());
            ps.setString(2, shelter.getState());
            ps.setInt(3, shelter.getPostcode());
            ps.setInt(4, shelter.getCapacity());
            ps.setString(5, "Active");
            ps.executeUpdate();
        }
    }

    public List<Shelter> selectAllShelters() {
        List<Shelter> shelters = new ArrayList<>();
        String sql = "SELECT s.*, (SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = s.ShelterID AND b.B_Status = 'Active') AS currentBene FROM shelter s";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                shelters.add(new Shelter(
                    rs.getString("ShelterID"), rs.getString("ShelterName"),
                    rs.getString("State"), rs.getInt("Postcode"),
                    rs.getInt("Capacity"), rs.getString("Status"),
                    rs.getInt("currentBene"),
                    rs.getDate("ActivationDate")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return shelters;
    }

    public boolean updateShelter(Shelter s) throws SQLException {
        String sql = "UPDATE shelter SET ShelterName=?, State=?, Postcode=?, Capacity=? WHERE ShelterID=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getShelterName());
            ps.setString(2, s.getState());
            ps.setInt(3, s.getPostcode());
            ps.setInt(4, s.getCapacity());
            ps.setString(5, s.getShelterID());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(String id, String status) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Start transaction

            if ("Active".equalsIgnoreCase(status)) {
                String sql = "UPDATE shelter SET Status = ?, ActivationDate = CURRENT_DATE WHERE ShelterID = ?";
                try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setString(2, id);
                    int rows = ps.executeUpdate();
                    
                    // --- NOTIFICATION TRIGGER: Shelter Activated ---
                    if (rows > 0) {
                        Shelter s = selectShelter(id);
                        String sName = (s != null) ? s.getShelterName() : id;
                        new NotificationDAO().sendToRoles(
                            java.util.Arrays.asList("Admin", "Manager", "Field Officer", "Approval Officer", "Logistic Staff"), 
                            "ALERT: Relief Center [" + sName + "] has been officially ACTIVATED."
                        );
                    }
                }
            } else {
                String fetchDate = "SELECT ActivationDate FROM shelter WHERE ShelterID = ?";
                java.sql.Date currentActivation = null;
                try(PreparedStatement psFetch = conn.prepareStatement(fetchDate)) {
                    psFetch.setString(1, id);
                    ResultSet rs = psFetch.executeQuery();
                    if(rs.next()) currentActivation = rs.getDate("ActivationDate");
                }

                if (currentActivation != null) {
                    String archiveSql = "INSERT INTO shelter_history (ShelterID, ActivationDate, DeactivationDate) VALUES (?, ?, CURRENT_DATE)";
                    try(PreparedStatement psArch = conn.prepareStatement(archiveSql)) {
                        psArch.setString(1, id);
                        psArch.setDate(2, currentActivation);
                        psArch.executeUpdate();
                    }
                }

                String updateSql = "UPDATE shelter SET Status = ? WHERE ShelterID = ?";
                try(PreparedStatement psUp = conn.prepareStatement(updateSql)) {
                    psUp.setString(1, status);
                    psUp.setString(2, id);
                    psUp.executeUpdate();
                }
            }
            
            conn.commit();
            return true;
            
        } catch(SQLException e) {
            if(conn != null) { try { conn.rollback(); } catch(SQLException ex){} }
            e.printStackTrace();
            return false;
        } finally {
            if(conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch(SQLException e){} }
        }
    }
    
    public Shelter selectShelter(String id) {
        Shelter shelter = null;
        String sql = "SELECT s.*, (SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = s.ShelterID AND b.B_Status = 'Active') AS currentBene " +
                     "FROM shelter s WHERE s.ShelterID = ?";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                shelter = new Shelter(
                    rs.getString("ShelterID"), rs.getString("ShelterName"),
                    rs.getString("State"), rs.getInt("Postcode"), 
                    rs.getInt("Capacity"), rs.getString("Status"),
                    rs.getInt("currentBene"), rs.getDate("ActivationDate")
                );
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return shelter;
    }

    // =================================================================================
    // FILTERED ARCHIVE METHOD
    // =================================================================================
    public List<Map<String, Object>> getHistoricalArchive(String shelterID, String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT h.HistoryID, h.ShelterID, s.ShelterName, h.ActivationDate, h.DeactivationDate, " +
            "DATEDIFF(h.DeactivationDate, h.ActivationDate) as DaysActive " +
            "FROM shelter_history h " +
            "JOIN shelter s ON h.ShelterID = s.ShelterID WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (shelterID != null && !shelterID.trim().isEmpty() && !"All".equalsIgnoreCase(shelterID)) {
            sql.append(" AND h.ShelterID = ? ");
            params.add(shelterID);
        }
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND h.ActivationDate >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND h.DeactivationDate <= ? ");
            params.add(endDate);
        }

        sql.append(" ORDER BY h.DeactivationDate DESC");
                     
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("HistoryID", rs.getInt("HistoryID"));
                    map.put("ShelterID", rs.getString("ShelterID"));
                    map.put("ShelterName", rs.getString("ShelterName"));
                    map.put("ActivationDate", rs.getDate("ActivationDate"));
                    map.put("DeactivationDate", rs.getDate("DeactivationDate"));
                    map.put("DaysActive", rs.getInt("DaysActive"));
                    list.add(map);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // =================================================================================
    // DRILL-DOWN: HISTORICAL VICTIMS LIST
    // =================================================================================
    public List<Map<String, String>> getHistoricalVictimsList(String shelterId, String startDate, String endDate) {
        List<Map<String, String>> victims = new ArrayList<>();
        
        String sql = 
            "SELECT B_Name AS FullName, B_ICNumber AS IC, 'Head of Family' AS Role, DateRegistered " +
            "FROM beneficiary WHERE ShelterID = ? AND DATE(DateRegistered) >= ? AND DATE(DateRegistered) <= ? " +
            "UNION " +
            "SELECT h.H_Name AS FullName, h.H_IC AS IC, h.H_Relationship AS Role, b.DateRegistered " +
            "FROM household h JOIN beneficiary b ON h.BeneficiaryID = b.BeneficiaryID " +
            "WHERE b.ShelterID = ? AND DATE(b.DateRegistered) >= ? AND DATE(b.DateRegistered) <= ? " +
            "ORDER BY DateRegistered ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterId);
            ps.setString(2, startDate);
            ps.setString(3, endDate);
            
            ps.setString(4, shelterId);
            ps.setString(5, startDate);
            ps.setString(6, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> map = new HashMap<>();
                    map.put("FullName", rs.getString("FullName"));
                    map.put("IC", rs.getString("IC"));
                    map.put("Role", rs.getString("Role"));
                    map.put("DateRegistered", rs.getString("DateRegistered"));
                    victims.add(map);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return victims;
    }
}