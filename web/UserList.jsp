<%-- 
    Document   : userList
    Created on : Jan 4, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.DAO.UserDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // 1. Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // 2. Set Active Menu
    session.setAttribute("activeMenu", "home");

    // 3. Fetch Data
    List<User> userList = (List<User>) request.getAttribute("listUser");
    
    if (userList == null) { userList = new ArrayList<>(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - User List</title>
    
    <link rel="stylesheet" type="text/css" href="Sidebar.css">

    <style>
        /* --- 1. GLOBAL RESET --- */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }

        /* --- 2. HEADER STYLES (Matches EditAdminForm) --- */
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

        /* Utility classes for Header */
        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-3 { gap: 12px; }
        .font-bold { font-weight: 700; }
        .text-xl { font-size: 1.25rem; }
        .tracking-tight { letter-spacing: -0.025em; }
        .font-medium { font-weight: 500; }
        .text-sm { font-size: 0.875rem; }
        .bg-white\/10 { background-color: rgba(255, 255, 255, 0.1); padding: 5px 12px; border-radius: 4px; }

        /* --- 3. LAYOUT STRUCTURE --- */
        .sidebar-container { 
            position: fixed; 
            top: 60px; 
            left: 0; 
            bottom: 0; 
            width: 250px; /* Adjust based on your sidebar width */
            z-index: 40; 
        }

        .main-content-view { 
            position: fixed;
            top: 60px;        /* Below Header */
            left: 250px;      /* Right of Sidebar */
            right: 0; 
            bottom: 0;
            overflow-y: auto; /* Allow scrolling for long tables */
            padding: 30px;
            background-color: #f8fafc;
        }

        /* --- 4. PAGE HEADER & BUTTONS --- */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        .page-header h2 { margin: 0; color: #1e293b; font-size: 24px; }

        .btn-add {
            background-color: #10b981; /* Green */
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            transition: background 0.2s;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .btn-add:hover { background-color: #059669; }

        /* --- 5. TABLE STYLES --- */
        .table-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
            overflow: hidden; /* Rounds the corners of the table */
        }

        .user-table { width: 100%; border-collapse: collapse; }
        
        .user-table th {
            background-color: #f1f5f9;
            color: #475569;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid #e2e8f0;
        }

        .user-table td {
            padding: 15px;
            border-bottom: 1px solid #e2e8f0;
            color: #334155;
            font-size: 14px;
        }
        
        .user-table tr:last-child td { border-bottom: none; }
        .user-table tr:hover { background-color: #f8fafc; }

        /* --- 6. BADGES & ACTIONS --- */
        .status { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .status-active { background-color: #dcfce7; color: #166534; }
        .status-inactive { background-color: #fee2e2; color: #991b1b; }

        .action-link { text-decoration: none; margin-right: 12px; font-weight: 600; font-size: 13px; transition: color 0.2s; }
        .edit-link { color: #0b5ea8; }
        .edit-link:hover { text-decoration: underline; }
        .deactivate-link { color: #ef4444; }
        .activate-link { color: #10b981; }

    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <div class="main-content-view">
        
        <div class="page-header">
            <h2>User List</h2>
            <%-- FIXED: Route to the servlet "new", not the JSP directly! --%>
            <a href="new" class="btn-add">+ Add New User</a>
        </div>

        <div class="table-card">
            <table class="user-table">
                <thead>
                    <tr>
                        <th>No.</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Region</th>
                        <th>Shelter Name</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                       // FIXED: Declared the count variable so the page doesn't crash!
                       int count = 1;
                       
                       if (userList.isEmpty()) { 
                    %>
                        <tr><td colspan="9" style="text-align:center; padding: 30px; color: #94a3b8;">No users found in the database.</td></tr>
                    <% 
                       } else {
                           for(User u : userList) { 
                               boolean isActive = "Active".equalsIgnoreCase(u.getStatus());
                    %>
                        <tr>
                            <%-- FIXED: Removed the extra ">" symbol --%>
                            <td style="font-weight:bold; color:#64748b;"><%= count++ %></td>
                            <td style="font-weight:600;"><%= u.getUserName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getRole() %></td>
                            <td><%= u.getLocation() %></td>
                            <td><%= u.getShelterName() %></td>
                            
                            <td>
                                <span class="status <%= isActive ? "status-active" : "status-inactive" %>">
                                    <%= u.getStatus() %>
                                </span>
                            </td>
                            
                            <td style="color:#64748b; font-size:13px;"><%= u.getCreatedAt() %></td>
                            
                            <td>
                                <%-- FIXED: Route to the servlet "editadmin", not the JSP directly! --%>
                                <a href="editadmin?id=<%= u.getUserID() %>" class="action-link edit-link">Edit</a>

                                <% if (isActive) { %>
                                    <a href="UpdateStatusServlet?id=<%= u.getUserID() %>&newStatus=Inactive" 
                                       class="action-link deactivate-link"
                                       onclick="return confirm('Disable this user account?')">
                                       Deactivate
                                    </a>
                                <% } else { %>
                                    <a href="UpdateStatusServlet?id=<%= u.getUserID() %>&newStatus=Active" 
                                       class="action-link activate-link"
                                       onclick="return confirm('Re-activate this user account?')">
                                       Activate
                                    </a>
                                <% } %>
                            </td>
                        </tr>
                    <% 
                           } 
                       } 
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>