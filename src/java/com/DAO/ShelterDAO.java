/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

import com.Model.Shelter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShelterDAO {
    private String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    private String jdbcUsername = "root";
    private String jdbcPassword = "admin";

    protected Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
        } catch (ClassNotFoundException e) { throw new SQLException(e); }
    }

    public void insertShelter(Shelter shelter) throws SQLException {
        String sql = "INSERT INTO shelter (ShelterName, State, Postcode, Capacity, Status) VALUES (?, ?, ?, ?, ?)";
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
        // Logic: Calculate occupancy based on Active status in beneficiary table
        String sql = "SELECT s.*, (SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = s.ShelterID AND b.B_Status = 'Active') AS currentBene FROM shelter s";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                shelters.add(new Shelter(
                    rs.getString("ShelterID"), rs.getString("ShelterName"),
                    rs.getString("State"), rs.getInt("Postcode"),
                    rs.getInt("Capacity"), rs.getString("Status"),
                    rs.getInt("currentBene")
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
        String sql = "UPDATE shelter SET Status = ? WHERE ShelterID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    public Shelter selectShelter(String id) {
        Shelter shelter = null;
        // Query to get shelter details and calculate occupancy
        String sql = "SELECT s.*, (SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = s.ShelterID AND b.B_Status = 'Active') AS currentBene " +
                     "FROM shelter s WHERE s.ShelterID = ?";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                shelter = new Shelter(
                    rs.getString("ShelterID"),
                    rs.getString("ShelterName"),
                    rs.getString("State"),
                    rs.getInt("Postcode"), // int(11) from address table
                    rs.getInt("Capacity"),
                    rs.getString("Status"),
                    rs.getInt("currentBene")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return shelter;
    }
}