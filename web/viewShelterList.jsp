<%-- 
    Document   : viewShelterList
    Created on : Apr 7, 2026, 11:06:59 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Shelter, com.Model.User, java.util.List, java.util.ArrayList" %>
<%
    // 1. Security Check: Only Admin and Manager can view
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Manager".equals(currentUser.getRole()))) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // 2. Set Active Menu for Sidebar
    session.setAttribute("activeMenu", "shelter");

    // 3. Fetch Shelter List from Servlet
    List<Shelter> shelterList = (List<Shelter>) request.getAttribute("listShelter");
    if (shelterList == null) { shelterList = new ArrayList<>(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>ADMS - Shelter List</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* Shared Styles from userList.jsp */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-view { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 30px; background-color: #f8fafc; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .btn-add { background-color: #10b981; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; }
        .table-card { background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; overflow: hidden; }
        .user-table { width: 100%; border-collapse: collapse; }
        .user-table th { background-color: #f1f5f9; color: #475569; font-weight: 600; text-transform: uppercase; font-size: 11px; padding: 15px; text-align: left; border-bottom: 2px solid #e2e8f0; }
        .user-table td { padding: 15px; border-bottom: 1px solid #e2e8f0; color: #334155; font-size: 14px; }
        .status { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .status-active { background-color: #dcfce7; color: #166534; }
        .status-inactive { background-color: #fee2e2; color: #991b1b; }
        .action-link { text-decoration: none; margin-right: 12px; font-weight: 600; font-size: 13px; }
    </style>
</head>
<body>

    <header class="fixed-header">
        <div style="display:flex; align-items:center; gap:12px;">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span style="font-size: 20px; font-weight: bold;">ADMS</span>
        </div>
        <div class="font-medium text-sm bg-white/10 px-3 py-1 rounded">
            <%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %>
        </div>
    </header>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>

    <div class="main-content-view">
        <div class="page-header">
            <h2>Shelter Management</h2>
            <a href="addNewShelter.jsp" class="btn-add">+ Create New Shelter</a>
        </div>

        <div class="table-card">
            <table class="user-table">
                <thead>
                    <tr>
                        <th>Shelter ID</th>
                        <th>Shelter Name</th>
                        <th>Postcode</th>
                        <th>Occupancy (Bene/Cap)</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (shelterList.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding: 30px; color: #94a3b8;">No shelters found.</td></tr>
                    <% } else {
                        for(Shelter s : shelterList) { 
                            boolean isActive = "Active".equalsIgnoreCase(s.getStatus());
                            boolean isFull = s.getCurrentBene() >= s.getCapacity();
                    %>
                        <tr>
                            <td style="font-weight:bold; color:#0b5ea8;"><%= s.getShelterID() %></td>
                            <td style="font-weight:600;"><%= s.getShelterName() %></td>
                            <td><%= s.getPostcode() %></td>
                            <td>
                                <span style="font-weight:bold; color: <%= isFull ? "#ef4444" : "#334155" %>;">
                                    <%= s.getCurrentBene() %> 
                                </span>
                                <span style="color:#94a3b8;">/ <%= s.getCapacity() %> Pax</span>
                                <% if(isFull) { %><br><small style="color:#ef4444; font-weight:bold;">SHELTER FULL</small><% } %>
                            </td>
                            <td>
                                <span class="status <%= isActive ? "status-active" : "status-inactive" %>">
                                    <%= s.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <a href="editShelter?id=<%= s.getShelterID() %>" class="action-link" style="color:#0b5ea8;">Edit</a>
                                <a href="updateShelterStatus?id=<%= s.getShelterID() %>&newStatus=<%= isActive ? "Inactive" : "Active" %>" 
                                   class="action-link" style="color: <%= isActive ? "#ef4444" : "#10b981" %>;"
                                   onclick="return confirm('Change shelter status?')">
                                   <%= isActive ? "Deactivate" : "Activate" %>
                                </a>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>