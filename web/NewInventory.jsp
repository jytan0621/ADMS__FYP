<%-- 
    Document   : NewInventory
    Created on : Apr 14, 2026, 2:29:33 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<% User u = (User) session.getAttribute("currentUser"); %>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - New Item</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; max-width: 600px; margin: 0 auto; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-top: 5px; box-sizing: border-box; }
        .form-control:focus { outline: none; border-color: #0b5ea8; box-shadow: 0 0 0 2px rgba(11, 94, 168, 0.2); }
        label { font-weight: 600; color: #475569; font-size: 13px; text-transform: uppercase; }
        .btn-main { background:#0b5ea8; color:white; padding:12px; border-radius:6px; border:none; font-weight:600; width:100%; cursor:pointer; margin-top:15px; transition: 0.2s;}
        .btn-main:hover { background: #094b86; }
        
        /* Disabled Input Styling */
        .input-disabled { background-color: #f1f5f9; color: #94a3b8; cursor: not-allowed; border-color: #e2e8f0; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <div class="main-content">
        <div class="card">
            <h2 style="margin-top:0; color: #1e293b;"><i class="fas fa-box" style="color:#0b5ea8; margin-right: 10px;"></i>Register New Item</h2>
            <hr style="border:0; border-top:1px solid #e2e8f0; margin:20px 0;">
            <form action="insertInventory" method="POST">
                <div style="margin-bottom:15px;">
                    <label>Item Name</label>
                    <input type="text" name="iName" class="form-control" required>
                </div>
                
                <div style="margin-bottom:15px;">
                    <label>Category</label>
                    <input type="text" name="category" class="form-control" required>
                </div>
                
                <div style="margin-bottom:15px;">
                    <label>Unit</label>
                    <input type="text" name="unit" class="form-control" placeholder="e.g., Box, KG, Bottle">
                </div>
                
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px; margin-bottom: 10px;">
                    <div>
                        <label>Initial Quantity</label>
                        <input type="number" name="quantityAvailable" class="form-control input-disabled" value="0" readonly title="Stock must be added via Ingoing records">
                        <small style="color: #64748b; font-size: 11px; display: block; margin-top: 4px;">* Stock is added via Ingoing</small>
                    </div>
                    <div>
                        <label>Low Threshold</label>
                        <input type="number" name="threshold" class="form-control" value="10">
                    </div>
                </div>
                
                <button type="submit" class="btn-main"><i class="fas fa-save"></i> Save Item</button>
            </form>
        </div>
    </div>
</body>
</html>