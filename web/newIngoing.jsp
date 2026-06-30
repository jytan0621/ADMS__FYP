<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User, com.Model.InventoryItem, com.Model.Supplier, com.Model.Driver, com.Model.RestockRequest, java.util.List" %>
<% 
    // 1. Session Check
    User u = (User) session.getAttribute("currentUser"); 
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    // 2. Retrieve dropdown lists passed from InventoryServlet
    List<InventoryItem> items = (List<InventoryItem>) request.getAttribute("itemList"); 
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("supplierList");
    List<Driver> drivers = (List<Driver>) request.getAttribute("driverList");
    
    // 3. NEW: Check for prefilled data from an Approved Restock
    RestockRequest prefilled = (RestockRequest) request.getAttribute("prefilledRestock");
    String preItemID = "";
    String preSupplierID = "";
    int preQty = 0;
    
    if (prefilled != null && prefilled.getItems() != null && !prefilled.getItems().isEmpty()) {
        preItemID = prefilled.getItems().get(0).getItemID();
        preQty = prefilled.getItems().get(0).getRrQuantityRequest();
        preSupplierID = prefilled.getSupplierID(); // Requires getSupplierID() in RestockRequest.java
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Record Ingoing Stock</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; max-width: 700px; margin: 0 auto; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        
        .form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-top: 5px; box-sizing: border-box; font-size: 14px; }
        .form-control:focus { outline: none; border-color: #0b5ea8; box-shadow: 0 0 0 2px rgba(11, 94, 168, 0.2); }
        label { font-weight: 600; color: #475569; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .btn-main { background:#10b981; color:white; padding:12px; border-radius:6px; border:none; font-weight:bold; width:100%; cursor:pointer; margin-top:10px; font-size: 15px; transition: background 0.2s; }
        .btn-main:hover { background: #059669; }
        .info-banner { background: #e0f2fe; color: #0369a1; padding: 12px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #bae6fd; font-size: 14px; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="card">
            <h2 style="margin-top:0; color: #1e293b;"><i class="fas fa-truck-loading" style="color:#0b5ea8; margin-right:10px;"></i> Record Stock Arrival</h2>
            <p style="color: #64748b; font-size: 14px; margin-bottom: 25px;">Enter details for the newly arrived batch of items.</p>
            <hr style="border:0; border-top:1px solid #e2e8f0; margin-bottom:25px;">
            
            <form action="insertIngoing" method="POST">
                
                <% if(prefilled != null) { %>
                    <div class="info-banner">
                        <i class="fas fa-info-circle"></i> Fulfilling Approved Restock Request: <b><%= prefilled.getRestockID() %></b>
                        <input type="hidden" name="restockID" value="<%= prefilled.getRestockID() %>">
                    </div>
                <% } %>

                <div class="grid-2">
                    <div>
                        <label>Item Selection</label>
                        <select name="itemID" class="form-control" required>
                            <option value="">-- Select Item --</option>
                            <% if(items != null && !items.isEmpty()) { 
                                for(InventoryItem item : items) { %>
                                    <option value="<%= item.getItemID() %>" <%= item.getItemID().equals(preItemID) ? "selected" : "" %>>
                                        <%= item.getItemID() %> - <%= item.getIName() %>
                                    </option>
                            <%  } 
                               } else { %>
                                    <option value="">Error: Items not loaded</option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label>Quantity Received (Editable)</label>
                        <input type="number" name="qtyReceived" class="form-control" placeholder="e.g., 500" min="1" 
                               value="<%= (preQty > 0) ? preQty : "" %>" required>
                    </div>
                </div>

                <div class="grid-2">
                    <div>
                        <label>Arrival Date</label>
                        <input type="date" name="arrivalDate" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()) %>" required>
                    </div>
                    <div>
                        <label>Expiry Date</label>
                        <input type="date" name="expiryDate" class="form-control">
                        <small style="color: #94a3b8; font-size: 11px;">Leave blank if not applicable</small>
                    </div>
                </div>

                <div class="grid-2">
                    <div>
                        <label>Supplier</label>
                        <select name="supplierID" class="form-control">
                            <option value="">-- Select Supplier --</option>
                            <% if(suppliers != null) { 
                                for(Supplier s : suppliers) { %>
                                    <option value="<%= s.getSupplierID() %>" <%= s.getSupplierID().equals(preSupplierID) ? "selected" : "" %>>
                                        <%= s.getSupplierName() %>
                                    </option>
                            <% } } %>
                        </select>
                    </div>
                    <div>
                        <label>Driver / Transporter</label>
                        <select name="driverID" class="form-control">
                            <option value="">-- Select Driver --</option>
                            <% if(drivers != null) { 
                                for(Driver d : drivers) { %>
                                    <option value="<%= d.getDriverID() %>"><%= d.getDriverName() %> (<%= d.getVehicle() %>)</option>
                            <% } } %>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn-main"><i class="fas fa-save"></i> Submit Ingoing Record</button>
            </form>
        </div>
    </div>
</body>
</html>