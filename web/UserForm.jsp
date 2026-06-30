<%-- 
    Document   : newUser
    Created on : Jan 4, 2026
    Description: Form to add a new user to the database
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 1. Security Check (Only Admin can access)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Manager".equals(currentUser.getRole()))) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Fetch all Shelters for the Dropdown Menu
    List<Map<String, String>> shelterList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/adms", "root", "admin");
        PreparedStatement ps = conn.prepareStatement("SELECT ShelterID, ShelterName FROM shelter WHERE Status = 'Active'");
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map<String, String> shelter = new HashMap<>();
            shelter.put("id", rs.getString("ShelterID"));
            shelter.put("name", rs.getString("ShelterName"));
            shelterList.add(shelter);
        }
        rs.close(); ps.close(); conn.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>ADMS - Add New User</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">

    <style>
        body { margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-3 { gap: 12px; }
        .font-bold { font-weight: 700; }
        .text-xl { font-size: 1.25rem; }
        .tracking-tight { letter-spacing: -0.025em; }
        .font-medium { font-weight: 500; }
        .text-sm { font-size: 0.875rem; }
        .bg-white\/10 { background-color: rgba(255, 255, 255, 0.1); padding: 5px 12px; border-radius: 4px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-centered { margin-left: 250px; padding-top: 60px; height: 100vh; display: flex; justify-content: center; align-items: center; background-color: #f8fafc; }
        .form-card { background-color: white; width: 100%; max-width: 650px; padding: 40px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); max-height: 90vh; overflow-y: auto; border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 25px; border-bottom: 1px solid #eee; padding-bottom: 15px; }
        .form-header h2 { margin: 0; color: #333; }
        .back-btn { background: none; border: none; cursor: pointer; color: #000; display: flex; align-items: center; padding: 0; transition: color 0.2s; }
        .back-btn:hover { color: #0b5ea8; }
        .form-row { display: flex; gap: 20px; margin-bottom: 15px; }
        .form-group { flex: 1; margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; transition: all 0.2s; }
        .form-group input:focus, .form-group select:focus { border-color: #0b5ea8; outline: 2px solid #0b5ea8; outline-offset: -1px; }
        .btn-group { margin-top: 30px; display: flex; justify-content: flex-end; gap: 15px; }
        .btn { padding: 10px 25px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; font-size: 14px; transition: background 0.2s; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-cancel:hover { background-color: #cbd5e1; }
        .btn-save { background-color: #0b5ea8; color: white; }
        .btn-save:hover { background-color: #094b87; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-centered">
        <div class="form-card">
            
            <div class="form-header">
                <a href="list" class="back-btn" title="Back to User List">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2>Add New User</h2>
            </div>
            
            <form action="insert" method="POST">
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" placeholder="Enter username" required>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="Enter email address" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Role</label>
                        <select name="role" required>
                            <option value="" disabled selected>Select Role</option>
                            <option value="Admin">Admin</option>
                            <option value="Manager">Manager</option>
                            <option value="Approval Admin">Approval Admin</option>
                            <option value="Field Officer">Field Officer</option>
                            <option value="Logistic Staff">Logistic Staff</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Assigned Shelter</label>
                        <select name="assignedRegion" required>
                            <option value="" disabled selected>Select a Shelter</option>
                            <option value="All Regions">All Regions (HQ / Global)</option>
                            <% for(Map<String, String> shelter : shelterList) { %>
                                <option value="<%= shelter.get("id") %>">
                                    <%= shelter.get("name") %> (<%= shelter.get("id") %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="btn-group">
                    <a href="list" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Create User</button>
                </div>

            </form>
        </div>
    </div>

</body>
</html>