<%-- 
    Document   : driverList
    Created on : Apr 14, 2026, 5:07:34 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.Driver, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    List<Driver> driverList = (List<Driver>) request.getAttribute("driverList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Driver List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* Reuse same styles from supplierList.jsp */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { text-align: left; padding: 12px; background: #fff7ed; color: #9a3412; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        .btn-add { background: #0b5ea8; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: 0.2s; }
        .btn-add:hover { background: #094b86; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px;">
            <h2 style="margin:0; color: #0f172a;">Authorized Drivers</h2>
            <a href="newDriver" class="btn-add"><i class="fas fa-plus"></i> Add New Driver</a>
        </div>
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">No.</th> <th>Name</th>
                        <th>Phone Number</th>
                        <th>Vehicle Plate</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; // Initialize the counter
                        if(driverList != null && !driverList.isEmpty()) { 
                            for(Driver d : driverList) { 
                    %>
                    <tr>
                        <td><strong style="font-size: 16px; color: #475569;"><%= count++ %></strong></td>
                        <td style="font-weight: 600;"><%= d.getDriverName() %></td>
                        <td><%= d.getDriverCnumber() %></td>
                        <td><span style="background:#e0f2fe; color:#0369a1; padding:3px 8px; border-radius:4px; font-weight:600; font-family: monospace;"><%= d.getVehicle() %></span></td>
                    </tr>
                    <%      } 
                        } else { 
                    %>
                    <tr>
                        <td colspan="4" style="text-align:center; padding:30px; color:#94a3b8; font-style: italic;">No drivers found.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>