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

public class MessageDAO {

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
            e.printStackTrace();
            throw new RuntimeException("Database connection failed");
        }
    }

    // 1. INBOX: Get Recent Chat History
    public List<Map<String, String>> getRecentChats(String myUserID) {
        List<Map<String, String>> recentChats = new ArrayList<>();

        String sql = "SELECT u.UserID, u.UserName, u.Role, m.Content, " +
                     "DATE_FORMAT(m.created_at, '%d %b %H:%i') as Time, " +
                     "(SELECT COUNT(*) FROM message WHERE SenderID = u.UserID AND ReceiverID = ? AND is_read = FALSE) as unreadCount " +
                     "FROM message m " +
                     "JOIN (SELECT CASE WHEN SenderID = ? THEN ReceiverID ELSE SenderID END AS contactID, " +
                     "MAX(created_at) AS max_time " +
                     "FROM message WHERE type = 'DirectMessage' AND (SenderID = ? OR ReceiverID = ?) " +
                     "GROUP BY CASE WHEN SenderID = ? THEN ReceiverID ELSE SenderID END) latest " +
                     "ON ((m.SenderID = ? AND m.ReceiverID = latest.contactID) OR (m.SenderID = latest.contactID AND m.ReceiverID = ?)) " +
                     "AND m.created_at = latest.max_time " +
                     "JOIN userprofile u ON u.UserID = latest.contactID " +
                     "ORDER BY m.created_at DESC";

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, myUserID); ps.setString(2, myUserID); ps.setString(3, myUserID); 
            ps.setString(4, myUserID); ps.setString(5, myUserID); ps.setString(6, myUserID);
            ps.setString(7, myUserID); 

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> chat = new HashMap<>();
                chat.put("id", rs.getString("UserID"));
                chat.put("name", rs.getString("UserName"));
                chat.put("role", rs.getString("Role"));
                chat.put("lastMsg", rs.getString("Content"));
                chat.put("time", rs.getString("Time"));
                chat.put("unreadCount", rs.getString("unreadCount")); 
                recentChats.add(chat);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return recentChats;
    }

    // 2. NEW CHAT: Fetch staff members ONLY in the same shelter
    public List<Map<String, String>> getStaffDirectory(String myUserID, String shelterID) {
        List<Map<String, String>> staffList = new ArrayList<>();
        
        String sql = "SELECT UserID, UserName, Role FROM userprofile " +
                     "WHERE UserID != ? AND AssignedRegion = ? " +
                     "ORDER BY Role, UserName";
        
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, myUserID);
            ps.setString(2, shelterID);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> staff = new HashMap<>();
                staff.put("id", rs.getString("UserID"));
                staff.put("name", rs.getString("UserName"));
                staff.put("role", rs.getString("Role"));
                staffList.add(staff);
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return staffList;
    }

    // 3. LOAD CHAT: Get the full conversation
    public List<Map<String, String>> getConversation(String myUserID, String contactID) {
        List<Map<String, String>> chat = new ArrayList<>();
        String sql = "SELECT SenderID, Content, DATE_FORMAT(created_at, '%h:%i %p') as Time FROM message " +
                     "WHERE type = 'DirectMessage' AND " +
                     "((SenderID = ? AND ReceiverID = ?) OR (SenderID = ? AND ReceiverID = ?)) " +
                     "ORDER BY created_at ASC";
                     
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, myUserID); ps.setString(2, contactID);
            ps.setString(3, contactID); ps.setString(4, myUserID);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> msg = new HashMap<>();
                msg.put("sender", rs.getString("SenderID"));
                msg.put("content", rs.getString("Content"));
                msg.put("time", rs.getString("Time"));
                chat.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return chat;
    }

    // 4. SEND: Save a new message
    public boolean sendMessage(String senderID, String receiverID, String content) {
        String sql = "INSERT INTO message (SenderID, ReceiverID, Content, type, created_at, is_read) VALUES (?, ?, ?, 'DirectMessage', NOW(), FALSE)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, senderID);
            ps.setString(2, receiverID);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // 5. COUNT UNREAD: Get total unread messages (Both Direct Messages AND Alerts)
    public int getUnreadChatCount(String myUserID) {
        int count = 0;
        // UPDATED: Now checks for both DirectMessage and Alert types, factoring in null values
        String sql = "SELECT COUNT(*) FROM message WHERE ReceiverID = ? " +
                     "AND (type = 'DirectMessage' OR type = 'Alert') " +
                     "AND (is_read = FALSE OR is_read IS NULL)";
                     
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, myUserID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return count;
    }

    // 6. MARK AS READ: Clears unread status when opening chat
    public void markChatAsRead(String myUserID, String senderID) {
        String sql = "UPDATE message SET is_read = TRUE WHERE ReceiverID = ? AND SenderID = ? AND type = 'DirectMessage'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, myUserID);
            ps.setString(2, senderID);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}