package com.DAO;

import com.Model.User;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    
    // UPDATED SQL: Added ProfilePicture to SELECT and UPDATE
    private static final String INSERT_NEW_USER_SQL="INSERT INTO userprofile(UserName, Email, Password, Role, AssignedRegion, CreatedAt, Status, ProfilePicture) VALUES (?, ?, ?, ?, ?, ?, ?, 'default-avatar.png')";
    private static final String SELECT_USER_BY_ID="select * from userprofile where userID=?";
    private static final String SELECT_USERS_BY_REGION_SQL = "SELECT * FROM userprofile WHERE AssignedRegion = ?";
    private static final String SELECT_ALL_USERS_GLOBAL_SQL = "SELECT * FROM userprofile";
    // UPDATED: Now updates ProfilePicture
    private static final String USER_UPDATE_SQL="update userprofile set UserName=?, Email=?, ProfilePicture=? where userID=?";
    
    private static final String ADMIN_UPDATE_SQL="update userprofile set Role=?, AssignedRegion=?, Status= ? where userID=?";
    private static final String PASSWORD_UPDATE_SQL="update userprofile set Password=? where userID=?";
    private static final String LOGIN_SQL ="SELECT * FROM userprofile WHERE Email = ? AND Password = ?";
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
                 String CreatedAt = rs.getString("CreatedAt");
                 String Status = rs.getString("Status");
                 
                 // NEW: Retrieve Picture
                 String ProfilePicture = rs.getString("ProfilePicture");
                 if(ProfilePicture == null) ProfilePicture = "default-avatar.png";

                 user = new User(UserID, UserName, Email, Password, Role, AssignedRegion, CreatedAt, Status);
                 user.setProfilePicture(ProfilePicture);
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
                String createdAt = rs.getString("CreatedAt");
                String status = rs.getString("Status");
                
                // NEW: Retrieve Picture
                String pic = rs.getString("ProfilePicture");
                if(pic == null) pic = "default-avatar.png";

                User u = new User(userID, userName, email, password, role, region, createdAt, status);
                u.setProfilePicture(pic);
                users.add(u);
            }
        } catch (SQLException e) { printSQLException(e); }
        return users;
    }
    
    // UPDATED: Updates Profile Picture
    public boolean userUpdate(User user) throws SQLException{
        boolean rowUpdated;
        try (Connection connection = getConnection();
                PreparedStatement statement=connection.prepareStatement(USER_UPDATE_SQL);){
            statement.setString(1,user.getUserName());
            statement.setString(2,user.getEmail());
            statement.setString(3,user.getProfilePicture()); // Save the filename
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
    
    public User login(String email, String password) {
        User user = null;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(LOGIN_SQL)) {
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String userID = rs.getString("UserID");
                String userName = rs.getString("UserName");
                String role = rs.getString("Role");
                String assignedRegion = rs.getString("AssignedRegion");
                String createdAt = rs.getString("CreatedAt");
                String status = rs.getString("Status");
                
                // NEW: Get picture on login
                String pic = rs.getString("ProfilePicture");
                if(pic == null) pic = "default-avatar.png";

                user = new User(userID, userName, email, password, role, assignedRegion, createdAt, status);
                user.setProfilePicture(pic);
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
                String createdAt = rs.getString("CreatedAt");
                String status = rs.getString("Status");
                String pic = rs.getString("ProfilePicture");
                if(pic == null) pic = "default-avatar.png";

                User u = new User(userID, userName, email, password, role, region, createdAt, status);
                u.setProfilePicture(pic);
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