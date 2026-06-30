<%-- 
    Document   : newDriver
    Created on : Apr 14, 2026, 5:22:15 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - New Driver</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        
        .card { background: white; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; max-width: 500px; margin: 40px auto 0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .form-control { width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 20px; margin-top: 8px; box-sizing: border-box; font-size: 14px; transition: 0.2s; color: #1e293b; background-color: #f8fafc; }
        .form-control:focus { outline: none; border-color: #0b5ea8; background-color: #ffffff; box-shadow: 0 0 0 3px rgba(11, 94, 168, 0.1); }
        label { font-weight: 600; color: #475569; font-size: 13px; display: block; }
        
        .btn-submit { background:#10b981; color:white; padding:12px; border-radius:6px; border:none; font-weight:bold; cursor:pointer; font-size: 15px; width: 100%; transition: 0.2s; display: inline-flex; justify-content: center; align-items: center; gap: 8px;}
        .btn-submit:hover { background: #059669; }
        .btn-cancel { background: white; color: #64748b; border: 1px solid #cbd5e1; padding: 12px; border-radius: 6px; font-weight: 600; text-decoration: none; display: block; text-align: center; margin-top: 10px; transition: 0.2s;}
        .btn-cancel:hover { background: #f1f5f9; color: #475569; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="card">
            <h3 style="margin-top:0; color: #0f172a; border-bottom: 2px solid #f1f5f9; padding-bottom: 15px; margin-bottom: 25px;">
                <i class="fas fa-id-card" style="color:#0b5ea8; margin-right:10px;"></i> Register New Driver
            </h3>
            
            <%-- NEW: ERROR BANNER FOR DUPLICATE VEHICLE --%>
            <% if("DuplicateVehicle".equals(request.getParameter("error"))) { %>
                <div style="background-color: #fee2e2; color: #991b1b; padding: 12px; border-radius: 6px; margin-bottom: 20px; font-weight: 600; border: 1px solid #fecaca; font-size: 14px;">
                    <i class="fas fa-exclamation-circle"></i> Registration Failed: That vehicle plate is already registered to another driver!
                </div>
            <% } %>
            
            <form action="insertDriver" method="POST">
                <label>Full Name</label>
                <input type="text" name="driverName" class="form-control" required placeholder="e.g. Ahmad bin Ali">
                
                <label>Contact Number</label>
                <input type="text" name="driverCnumber" class="form-control" required placeholder="e.g. 017-8889999">
                
                <label>Vehicle Plate / Info</label>
                <input type="text" name="vehicle" class="form-control" required placeholder="e.g. VBS 2024 (Lorry)">
                
                <div style="margin-top: 10px;">
                    <button type="submit" class="btn-submit"><i class="fas fa-save"></i> Register Driver</button>
                    <a href="listDriver" class="btn-cancel">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>