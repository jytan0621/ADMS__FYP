<%-- 
    Document   : EditAdminForm
    Created on : Jan 6, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.DAO.UserDAO" %>

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
    
    // Variables to hold split region data
    String currentCity = "";
    String currentState = "";
    
    if (idToEdit != null) {
        UserDAO dao = new UserDAO();
        userToEdit = dao.selectUser(idToEdit);
        
        // 3. Logic to split "State - City" back into separate fields for display
        if(userToEdit != null && userToEdit.getAssignedRegion() != null) {
            String region = userToEdit.getAssignedRegion();
            if(region.contains(" - ")) {
                String[] parts = region.split(" - ");
                if(parts.length >= 2) {
                    currentState = parts[0]; // State is first
                    currentCity = parts[1];  // City is second
                }
            } else {
                // Handle legacy data that might not have the " - " format
                if(!"General".equals(region)) currentCity = region; 
            }
        }
    }
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
        /* --- 1. GLOBAL RESET & FONTS --- */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }

        /* --- 2. HEADER STYLES --- */
        .fixed-header { 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            height: 60px; 
            z-index: 50; 
            background-color: #0b5ea8; 
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 0 24px; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
        }

        /* --- 3. LAYOUT GRID --- */
        .sidebar-container { 
            position: fixed; 
            top: 60px; 
            left: 0; 
            bottom: 0; 
            width: 240px; 
            z-index: 40; 
        }

        /* --- 4. CENTERED CONTENT FIX --- */
        .main-content-centered {
            margin-left: 250px; 
            padding: 80px 40px 40px 40px;     
            background-color: #f8fafc;
        }

        /* --- 5. FORM CARD STYLES --- */
        .form-card { 
            background: white; 
            width: 100%; 
            max-width: 600px; 
            margin: auto;
            padding: 40px; 
            border-radius: 8px; 
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
        }

        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: border-color 0.2s; }
        .form-group input:focus, .form-group select:focus { border-color: #0b5ea8; ring: 2px solid #0b5ea8; }
        
        /* Locked Input Style */
        .readonly-input { background-color: #f1f5f9; color: #64748b; cursor: not-allowed; border: 1px solid #e2e8f0; }
        
        .btn { padding: 10px 24px; border-radius: 6px; font-weight: 600; font-size: 14px; transition: all 0.2s; cursor: pointer; border: none; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; text-decoration: none; display: inline-block; }
        .btn-cancel:hover { background-color: #cbd5e1; }
        .btn-save { background-color: #0b5ea8; color: white; }
        .btn-save:hover { background-color: #094b85; }

        /* Back Button Style */
        .back-btn { 
            background: none; 
            border: none; 
            cursor: pointer; 
            color: #333; 
            display: flex; 
            align-items: center; 
            padding: 0; 
            transition: color 0.2s;
        }
        .back-btn:hover { color: #0b5ea8; }
    </style>
    
    <script>
        function fetchAddress() {
            var pcode = document.getElementById("postcode").value;
            if(pcode.length === 0) return;
            
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState === 4 && this.status === 200) {
                    var response = JSON.parse(this.responseText);
                    if(response.found === true) {
                        document.getElementById("city").value = response.city;
                        document.getElementById("state").value = response.state;
                    } else {
                        alert("Postcode not found!");
                        document.getElementById("city").value = "";
                        document.getElementById("state").value = "";
                    }
                }
            };
            xhttp.open("GET", "PostcodeLookupServlet?postcode=" + pcode, true);
            xhttp.send();
        }
    </script>
</head>
<body>

    <header class="fixed-header">
        <div class="flex items-center gap-3">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span class="text-xl font-bold tracking-tight">ADMS</span>
        </div>
        <div class="font-medium text-sm bg-white/10 px-3 py-1 rounded">
            <%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %>
        </div>
    </header>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" />
    </div>

    <div class="main-content-centered">
        
        <div class="form-card">
            
            <div class="flex items-center gap-4 mb-6 border-b pb-4">
                <a href="list" class="back-btn" title="Back to User List">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2 class="text-2xl font-bold text-gray-800 m-0">Edit Admin Profile</h2>
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
                        <select name="role">
                            <option value="Admin" <%= "Admin".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Admin</option>
                            <option value="Field Officer" <%= "Field Officer".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Field Officer</option>
                            <option value="Logistic Staff" <%= "Logistic Staff".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Logistic Staff</option>
                            <option value="Approval Admin" <%= "Approval Admin".equalsIgnoreCase(userToEdit.getRole()) ? "selected" : "" %>>Approval Admin</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Status</label>
                        <select name="status">
                            <option value="Active" <%= "Active".equalsIgnoreCase(userToEdit.getStatus()) ? "selected" : "" %>>Active</option>
                            <option value="Inactive" <%= "Inactive".equalsIgnoreCase(userToEdit.getStatus()) ? "selected" : "" %>>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div class="form-group">
                        <label>Postcode (Update Location)</label>
                        <input type="text" name="postcode" id="postcode" placeholder="Enter to update" onblur="fetchAddress()">
                    </div>
                    
                    <div class="form-group">
                        <label>State</label>
                        <input type="text" name="state" id="state" value="<%= currentState %>" readonly class="readonly-input">
                    </div>
                </div>
                
                <div class="form-group mb-8">
                    <label>City</label>
                    <input type="text" name="city" id="city" value="<%= currentCity %>" readonly class="readonly-input">
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