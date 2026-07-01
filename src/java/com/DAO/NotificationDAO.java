/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotificationDAO {

    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@"; 

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) { 
            throw new RuntimeException("DB Failed"); 
        }
    }

    // 1. Send to a specific User
    public void sendToUser(String receiverID, String content) {
        String sql = "INSERT INTO message (SenderID, ReceiverID, Content, created_at, type, is_read) VALUES ('SYSTEM', ?, ?, NOW(), 'Alert', FALSE)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, receiverID);
            ps.setString(2, content);
            int rows = ps.executeUpdate();
            System.out.println("DEBUG: Notification sent to " + receiverID + ". Rows affected: " + rows);
        } catch (SQLException e) { 
            System.out.println("DEBUG ERROR: Notification failed to send!");
            e.printStackTrace(); 
        }
    }

    // 2. Send to an entire Role
    public void sendToRole(String role, String content) {
        String sql = "INSERT INTO message (SenderID, ReceiverID, Content, created_at, type, is_read) SELECT 'SYSTEM', UserID, ?, NOW(), 'Alert', FALSE FROM userprofile WHERE Role = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, content);
            ps.setString(2, role);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // 3. Send to multiple Roles
    public void sendToRoles(List<String> roles, String content) {
        for (String role : roles) { sendToRole(role, content); }
    }

    // 4. Send to all staff assigned to a specific Shelter
    public void sendToShelterStaff(String shelterID, String content) {
        String sql = "INSERT INTO message (SenderID, ReceiverID, Content, created_at, type, is_read) SELECT 'SYSTEM', UserID, ?, NOW(), 'Alert', FALSE FROM userprofile WHERE AssignedRegion = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, content);
            ps.setString(2, shelterID);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // 5. Fetch Notifications for the Bell Icon
    public List<Map<String, String>> getMyNotifications(String userID) {
        List<Map<String, String>> notifications = new ArrayList<>();
        String sql = "SELECT Content, DATE_FORMAT(created_at, '%d %b %H:%i') as Time FROM message WHERE ReceiverID = ? AND type = 'Alert' ORDER BY created_at DESC LIMIT 5";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> msg = new HashMap<>();
                msg.put("content", rs.getString("Content"));
                msg.put("time", rs.getString("Time"));
                notifications.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return notifications;
    }
    
    // 6. Count Total Unread/Recent
    public int getNotificationCount(String userID) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM message WHERE ReceiverID = ? AND type = 'Alert' AND (is_read = FALSE OR is_read IS NULL)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }

    // Marks system alerts as read
    public void markAlertsAsRead(String userID) {
        String sql = "UPDATE message SET is_read = TRUE WHERE ReceiverID = ? AND type = 'Alert'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // 7. Get Alerts for Chat Window (Auto-clears older than 14 days)
    public List<Map<String, String>> getSystemConversation(String userID) {
        List<Map<String, String>> chat = new ArrayList<>();
        String sql = "SELECT Content, DATE_FORMAT(created_at, '%d %b %H:%i') as Time FROM message " +
                     "WHERE ReceiverID = ? AND type = 'Alert' AND created_at >= NOW() - INTERVAL 14 DAY " +
                     "ORDER BY created_at ASC";
                     
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> msg = new HashMap<>();
                msg.put("content", rs.getString("Content"));
                msg.put("time", rs.getString("Time"));
                chat.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return chat;
    }

    // 8. Generate the Pinned Inbox Preview
    public Map<String, String> getSystemChatPreview(String userID) {
        Map<String, String> preview = new HashMap<>();
        preview.put("id", "SYSTEM");
        preview.put("name", "System Notifications");
        preview.put("role", "Automated Alerts");
        preview.put("lastMsg", "No recent notifications.");
        preview.put("time", "");
        preview.put("unreadCount", String.valueOf(getNotificationCount(userID)));

        String sql = "SELECT Content, DATE_FORMAT(created_at, '%d %b %H:%i') as Time FROM message " +
                     "WHERE ReceiverID = ? AND type = 'Alert' " +
                     "ORDER BY created_at DESC LIMIT 1";
                     
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                preview.put("lastMsg", rs.getString("Content"));
                preview.put("time", rs.getString("Time"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return preview;
    }
}