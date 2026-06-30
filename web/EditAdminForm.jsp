<%-- 
    Document   : EditAdminForm
    Created on : Jan 6, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.DAO.UserDAO" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // 1. Session Check (Security)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"Admin".equals(currentUser.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Fetch Data to Edit
    String idToEdit = request.getParameter("id");
    User userToEdit = null;
    
    if (idToEdit != null) {
        UserDAO dao = new UserDAO();
        userToEdit = dao.selectUser(idToEdit);
    }

    // 3. Fetch all Shelters for the Dropdown Menu
    List<Map<String, String>> shelterList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/adms", "root", "admin");
        PreparedStatement ps = conn.prepareStatement("SELECT ShelterID, ShelterName FROM shelter");
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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Edit Admin</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="Sidebar.css">

    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 240px; z-index: 40; }
        .main-content-centered { margin-left: 250px; padding: 80px 40px 40px 40px; background-color: #f8fafc; }
        .form-card { background: white; width: 100%; max-width: 600px; margin: auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); border: 1px solid #e2e8f0; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: border-color 0.2s; }
        .form-group input:focus, .form-group select:focus { border-color: #0b5ea8; }
        .readonly-input { background-color: #f1f5f9; color: #64748b; cursor: not-allowed; border: 1px solid #e2e8f0; }
        .btn { padding: 10px 24px; border-radius: 6px; font-weight: 600; font-size: 14px; transition: all 0.2s; cursor: pointer; border: none; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; text-decoration: none; display: inline-block; }
        .btn-cancel:hover { background-color: #cbd5e1; }
        .btn-save { background-color: #0b5ea8; color: white; }
        .btn-save:hover { background-color: #094b85; }
        .back-btn { background: none; border: none; cursor: pointer; color: #333; display: flex; align-items: center; padding: 0; transition: color 0.2s; }
        .back-btn:hover { color: #0b5ea8; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-centered">
        
        <div class="form-card">
            
            <div class="flex items-center gap-4 mb-6 border-b pb-4">
                <a href="list" class="back-btn" title="Back to User List">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2 class="text-2xl font-bold text-gray-800 m-0">Edit User Profile</h2>
            </div>
            
            <% if (userToEdit != null) { %>
            <form action="adminupdate" method="POST">
                <input type="hidden" name="userId" value="<%= userToEdit.getUserID() %>">

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" value="<%= userToEdit.getUserName() %>" readonly class="readonly-input">
                    </div>
                    
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" value="<%= userToEdit.getEmail() %>" readonly class="readonly-input">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div class="form-group">
                        <label>Role</label>
                        <select name="role" required>
                            <option value="Admin" <%= "Admin".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Admin</option>
                            <option value="Field Officer" <%= "Field Officer".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Field Officer</option>
                            <option value="Logistic Staff" <%= "Logistic Staff".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Logistic Staff</option>
                            <option value="Approval Admin" <%= "Approval Admin".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Approval Admin</option>
                            <option value="Manager" <%= "Manager".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Manager</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" required>
                            <option value="Active" <%= "Active".equalsIgnoreCase(userToEdit.getStatus()) ? "selected" : "" %>>Active</option>
                            <option value="Inactive" <%= "Inactive".equalsIgnoreCase(userToEdit.getStatus()) ? "selected" : "" %>>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="form-group mb-8">
                    <label>Assigned Shelter</label>
                    <select name="assignedRegion" required>
                        <option value="" disabled>Select a Shelter</option>
                        <option value="All Regions" <%= "All Regions".equalsIgnoreCase(userToEdit.getAssignedRegion()) ? "selected" : "" %>>All Regions (HQ / Global)</option>
                        <% for(Map<String, String> shelter : shelterList) { 
                               boolean isSelected = shelter.get("id").equals(userToEdit.getAssignedRegion());
                        %>
                            <option value="<%= shelter.get("id") %>" <%= isSelected ? "selected" : "" %>>
                                <%= shelter.get("name") %> (<%= shelter.get("id") %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="flex justify-end gap-3">
                    <a href="list" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Save Changes</button>
                </div>
            </form>
            <% } else { %>
                <div class="text-center text-red-500 font-bold py-10">
                    User not found.
                </div>
                <div class="flex justify-center">
                    <a href="list" class="btn btn-cancel">Back to List</a>
                </div>
            <% } %>
        </div>
        
    </div>

</body>
</html>