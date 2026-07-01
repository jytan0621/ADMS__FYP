package com.DAO;

import com.Model.User;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.WEB.BCrypt;

public class UserDAO {
    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@";
    
    private static final String INSERT_NEW_USER_SQL="INSERT INTO userprofile(UserName, Email, Password, Role, AssignedRegion, CreatedAt, Status, ProfilePicture) VALUES (?, ?, ?, ?, ?, ?, ?, 'default-avatar.png')";
    
    // 【全新 SQL】：同时查询出 ShelterName 和 Location (City, State)
    private static final String SELECT_USER_BY_ID = 
        "SELECT u.*, s.ShelterName, CONCAT(a.City, ', ', a.State) AS Location FROM userprofile u LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID LEFT JOIN address a ON s.Postcode = a.Postcode WHERE u.userID=?";
        
    private static final String SELECT_USERS_BY_REGION_SQL = 
        "SELECT u.*, s.ShelterName, CONCAT(a.City, ', ', a.State) AS Location FROM userprofile u LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID LEFT JOIN address a ON s.Postcode = a.Postcode WHERE u.AssignedRegion = ?";
        
    private static final String SELECT_ALL_USERS_GLOBAL_SQL = 
        "SELECT u.*, s.ShelterName, CONCAT(a.City, ', ', a.State) AS Location FROM userprofile u LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID LEFT JOIN address a ON s.Postcode = a.Postcode";
        
    // 🌟 CHANGED: Removed "AND u.Password = ?" because we need to check the hash in Java now
    private static final String LOGIN_SQL = 
        "SELECT u.*, s.ShelterName, CONCAT(a.City, ', ', a.State) AS Location FROM userprofile u LEFT JOIN shelter s ON u.AssignedRegion = s.ShelterID LEFT JOIN address a ON s.Postcode = a.Postcode WHERE u.Email = ?";
    
    private static final String USER_UPDATE_SQL="update userprofile set UserName=?, Email=?, ProfilePicture=? where userID=?";
    private static final String ADMIN_UPDATE_SQL="update userprofile set Role=?, AssignedRegion=?, Status= ? where userID=?";
    private static final String PASSWORD_UPDATE_SQL="update userprofile set Password=? where userID=?";
    private static final String UPDATE_PASSWORD_BY_EMAIL ="UPDATE userprofile SET Password = ? WHERE Email = ?";

    public UserDAO(){}
    
    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database connection failed");
        }
    }

    public void insertUser(User user) throws SQLException{
        try(Connection connection= getConnection();
                PreparedStatement preparedStatement =connection.prepareStatement (INSERT_NEW_USER_SQL)){
            preparedStatement.setString(1,user.getUserName());
            preparedStatement.setString(2,user.getEmail());
            preparedStatement.setString(3,user.getPassword());
            preparedStatement.setString(4,user.getRole());
            preparedStatement.setString(5,user.getAssignedRegion());
            preparedStatement.setString(6,user.getCreatedAt());
            preparedStatement.setString(7,user.getStatus());
            preparedStatement.executeUpdate();
        } catch(SQLException e){ printSQLException(e); }
    }
    
    public User selectUser(String UserID){
        User user=null;
         try(Connection connection= getConnection();
                PreparedStatement preparedStatement =connection.prepareStatement (SELECT_USER_BY_ID)){
            preparedStatement.setString(1, UserID);
             ResultSet rs = preparedStatement.executeQuery();
             
             while (rs.next()){
                 String UserName = rs.getString("UserName");
                 String Email = rs.getString("Email");
                 String Password = rs.getString("Password");
                 String Role = rs.getString("Role");
                 String AssignedRegion = rs.getString("AssignedRegion"); 
                 String ShelterName = rs.getString("ShelterName"); 
                 String Location = rs.getString("Location");       
                 String CreatedAt = rs.getString("CreatedAt");
                 String Status = rs.getString("Status");
                 
                 String ProfilePicture = rs.getString("ProfilePicture");
                 if(ProfilePicture == null) ProfilePicture = "default-avatar.png";
                 
                 user = new User(UserID, UserName, Email, Password, Role, AssignedRegion, CreatedAt, Status);
                 user.setProfilePicture(ProfilePicture);
                 user.setShelterName(ShelterName != null ? ShelterName : "-");
                 user.setLocation(Location != null ? Location : AssignedRegion); 
             }
         }catch (SQLException e){ printSQLException(e); }
         return user;
    }
    
    public List<User> selectAllUser(String assignedRegion) {
        List<User> users = new ArrayList<>(); 
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_USERS_BY_REGION_SQL)) {
            preparedStatement.setString(1, assignedRegion);
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                String userID = rs.getString("UserID");
                String userName = rs.getString("UserName");
                String email = rs.getString("Email");
                String password = rs.getString("Password");
                String role = rs.getString("Role");
                String region = rs.getString("AssignedRegion");
                String shelterName = rs.getString("ShelterName");
                String location = rs.getString("Location");
                String createdAt = rs.getString("CreatedAt");
                String status = rs.getString("Status");
                
                String pic = rs.getString("ProfilePicture");
                if(pic == null) pic = "default-avatar.png";

                User u = new User(userID, userName, email, password, role, region, createdAt, status);
                u.setProfilePicture(pic);
                u.setShelterName(shelterName != null ? shelterName : "-");
                u.setLocation(location != null ? location : region);
                users.add(u);
            }
        } catch (SQLException e) { printSQLException(e); }
        return users;
    }
    
    public boolean userUpdate(User user) throws SQLException{
        boolean rowUpdated;
        try (Connection connection = getConnection();
                PreparedStatement statement=connection.prepareStatement(USER_UPDATE_SQL);){
            statement.setString(1,user.getUserName());
            statement.setString(2,user.getEmail());
            statement.setString(3,user.getProfilePicture()); 
            statement.setString(4,user.getUserID());
            rowUpdated = statement.executeUpdate()>0;
        }
        return rowUpdated;
    }
    
    public boolean adminUpdate(User user) throws SQLException{
        boolean rowUpdated;
        try (Connection connection = getConnection();
                PreparedStatement statement=connection.prepareStatement(ADMIN_UPDATE_SQL);){
            statement.setString(1,user.getRole());
            statement.setString(2,user.getAssignedRegion()); 
            statement.setString(3,user.getStatus());
            statement.setString(4,user.getUserID());
            rowUpdated = statement.executeUpdate()>0;
        }
        return rowUpdated;
    }
    
    public boolean passwordUpdate(User user) throws SQLException{
        boolean rowUpdated;
        try (Connection connection = getConnection();
                PreparedStatement statement=connection.prepareStatement(PASSWORD_UPDATE_SQL);){
            statement.setString(1,user.getPassword());
            statement.setString(2,user.getUserID());
            rowUpdated = statement.executeUpdate()>0;
        }
        return rowUpdated;
    }
    
    // 🌟 UPDATED LOGIN METHOD: Fixes the PHP and Plain Text password crashes
    public User login(String email, String plainPassword) {
        User user = null;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(LOGIN_SQL)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String dbHashedPassword = rs.getString("Password");
                
                // 🌟 FIX 1: Convert PHP $2y$ prefix to Java $2a$ prefix
                if (dbHashedPassword != null && dbHashedPassword.startsWith("$2y$")) {
                    dbHashedPassword = "$2a$" + dbHashedPassword.substring(4);
                }
                
                boolean passwordsMatch = false;
                
                // 🌟 FIX 2: Catch Invalid salt errors so the server doesn't crash
                try {
                    passwordsMatch = BCrypt.checkpw(plainPassword, dbHashedPassword);
                } catch (IllegalArgumentException e) {
                    System.out.println("Skipped login: Invalid password hash in DB for user " + email);
                    passwordsMatch = false;
                }
                
                if (passwordsMatch) {
                    String userID = rs.getString("UserID");
                    String userName = rs.getString("UserName");
                    String role = rs.getString("Role");
                    String assignedRegion = rs.getString("AssignedRegion");
                    String shelterName = rs.getString("ShelterName");
                    String location = rs.getString("Location");
                    String createdAt = rs.getString("CreatedAt");
                    String status = rs.getString("Status");
                    
                    String pic = rs.getString("ProfilePicture");
                    if(pic == null) pic = "default-avatar.png";

                    user = new User(userID, userName, email, dbHashedPassword, role, assignedRegion, createdAt, status);
                    user.setProfilePicture(pic);
                    user.setShelterName(shelterName != null ? shelterName : "-");
                    user.setLocation(location != null ? location : assignedRegion);
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return user;
    }
    
    public boolean isEmailRegistered(String email) {
        boolean exists = false;
        String sql = "SELECT UserID FROM userprofile WHERE Email = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) exists = true;
            }
        } catch (SQLException e) { printSQLException(e); }
        return exists;
    }
    
    public boolean updatePasswordByEmail(String email, String newPassword) {
        boolean updated = false;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_PASSWORD_BY_EMAIL)) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            updated = ps.executeUpdate() > 0;
        } catch (SQLException e) { printSQLException(e); }
        return updated;
    }

    public List<User> selectAllUsersGlobal() {
        List<User> users = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_USERS_GLOBAL_SQL)) {
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                String userID = rs.getString("UserID");
                String userName = rs.getString("UserName");
                String email = rs.getString("Email");
                String password = rs.getString("Password");
                String role = rs.getString("Role");
                String region = rs.getString("AssignedRegion");
                String shelterName = rs.getString("ShelterName"); 
                String location = rs.getString("Location"); 
                String createdAt = rs.getString("CreatedAt");
                String status = rs.getString("Status");
                
                String pic = rs.getString("ProfilePicture");
                if(pic == null) pic = "default-avatar.png";

                User u = new User(userID, userName, email, password, role, region, createdAt, status);
                u.setProfilePicture(pic);
                u.setShelterName(shelterName != null ? shelterName : "-"); 
                u.setLocation(location != null ? location : region);
                users.add(u);
            }
        } catch (SQLException e) { printSQLException(e); }
        return users;
    }
    
    private void printSQLException(SQLException ex){
        for (Throwable e:ex){
            if (e instanceof SQLException){
                e.printStackTrace(System.err);
            }
        }
    }
}