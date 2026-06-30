<%-- 
    Document   : listInventory
    Created on : Apr 14, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.InventoryItem, com.Model.User, com.Model.BatchStockDTO" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    // FETCH THE ROLE to use for security checks
    String role = u.getRole().toLowerCase().trim();
    
    List<InventoryItem> items = (List<InventoryItem>) request.getAttribute("items");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Item List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top:15px; }
        th { text-align: left; padding: 12px; background: #f1f5f9; color: #475569; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #cbd5e1; }
        td { padding: 14px 12px; border-bottom: 1px solid #e2e8f0; font-size: 14px; vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }
        .btn-main { background:#0b5ea8; color:white; padding:10px 20px; border-radius:6px; text-decoration:none; font-weight:600; display:inline-block; transition: 0.2s;}
        .btn-main:hover { background: #094b86; }

        /* Action Buttons */
        .btn-action { display: inline-flex; align-items: center; gap: 5px; padding: 6px 12px; border-radius: 4px; font-size: 13px; font-weight: 600; text-decoration: none; transition: 0.2s; margin-left: 5px; }
        .btn-edit { background: #f1f5f9; color: #0ea5e9; border: 1px solid #cbd5e1; }
        .btn-edit:hover { background: #e0f2fe; border-color: #7dd3fc; }
        .btn-restock { background: #fff7ed; color: #d97706; border: 1px solid #fde68a; }
        .btn-restock:hover { background: #fef3c7; border-color: #fcd34d; }

        /* Modal Styles */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.6); z-index: 2000; align-items: center; justify-content: center; backdrop-filter: blur(2px); }
        .modal-card { background: white; width: 100%; max-width: 600px; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); overflow: hidden; animation: slideDown 0.3s ease-out; }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; }
        .modal-header h3 { margin: 0; font-size: 18px; color: #0f172a; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1; text-decoration: none;}
        .close-btn:hover { color: #ef4444; }
        .modal-body { padding: 24px; max-height: 60vh; overflow-y: auto; }
        .badge { background:#dcfce7; color:#166534; padding:4px 10px; border-radius:4px; font-weight:bold; font-size:13px; }
        @keyframes slideDown { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 style="margin:0; color: #1e293b;"><i class="fas fa-boxes" style="color:#0b5ea8; margin-right: 8px;"></i> Available Inventory List</h2>
            
            <%-- ROLE CHECK: Hide Add New Item button for Approval Officers --%>
            <% if (!"approval officer".equals(role)) { %>
                <a href="newInventory" class="btn-main"><i class="fas fa-plus"></i> Add New Item</a>
            <% } %>
        </div>
        
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 60px;">No.</th>
                        <th>Description</th>
                        <th>Category</th>
                        <th>Quantity</th>
                        <th>Status</th>
                        
                        <%-- ROLE CHECK: Hide Action Header for Approval Officers --%>
                        <% if (!"approval officer".equals(role)) { %>
                            <th style="text-align: right;">Action</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; // INITIALIZE COUNTER
                        if(items != null && !items.isEmpty()) { 
                            for(InventoryItem i : items) { 
                    %>
                    <tr>
                        <td><strong style="color: #475569;"><%= count++ %></strong></td>
                        <td>
                            <a href="listInventory?viewBatchID=<%= i.getItemID() %>" style="color: #0b5ea8; text-decoration: underline; font-weight: 600; cursor: pointer;">
                                <%= i.getIName() %>
                            </a>
                        </td>
                        <td><%= i.getCategory() %></td>
                        <td style="font-weight:bold; color:#0b5ea8;"><%= i.getQuantityAvailable() %> <%= i.getUnit() %></td>
                        <td>
                            <%= (i.getQuantityAvailable() <= i.getThreshold()) ? 
                                "<span style='color:#dc2626; font-weight:bold; background:#fee2e2; padding:4px 8px; border-radius:4px;'><i class='fas fa-exclamation-triangle'></i> Low Stock</span>" : 
                                "<span style='color:#166534; font-weight:bold; background:#dcfce7; padding:4px 8px; border-radius:4px;'><i class='fas fa-check'></i> Adequate</span>" %>
                        </td>
                        
                        <%-- ROLE CHECK: Hide Edit/Restock Buttons for Approval Officers --%>
                        <% if (!"approval officer".equals(role)) { %>
                        <td style="text-align: right; white-space: nowrap;">
                            <a href="newRestock" class="btn-action btn-restock" title="Request Restock">
                                <i class="fas fa-truck-loading"></i> Restock
                            </a>
                            <a href="editInventory?id=<%= i.getItemID() %>" class="btn-action btn-edit" title="Edit Item Details">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                        </td>
                        <% } %>
                        
                    </tr>
                    <%      } 
                        } else { 
                    %>
                        <tr>
                            <%-- Dynamically set colspan based on role to keep table borders clean --%>
                            <td colspan="<%= ("approval officer".equals(role)) ? 5 : 6 %>" style="text-align:center; padding: 20px; color: #94a3b8;">
                                No items in inventory.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ========================================= --%>
    <%-- MODAL: INVENTORY BATCH BREAKDOWN --%>
    <%-- ========================================= --%>
    <% 
        String targetBatchID = (String) request.getAttribute("targetBatchItemID");
        List<BatchStockDTO> batchList = (List<BatchStockDTO>) request.getAttribute("batchList");
        
        if (targetBatchID != null && batchList != null) { 
    %>
    <div id="batchModal" class="modal-overlay" style="display: flex;">
        <div class="modal-card">
            <div class="modal-header">
                <h3><i class="fas fa-layer-group" style="color: #0b5ea8;"></i> Batch Breakdown: <%= targetBatchID %></h3>
                <a href="listInventory" class="close-btn">&times;</a>
            </div>
            <div class="modal-body">
                <table style="margin-top: 0;">
                    <thead>
                        <tr>
                            <th style="width: 50px;">No.</th>
                            <th>Batch ID</th>
                            <th>Arrival Date</th>
                            <th>Expiry Date</th>
                            <th>Supplier</th>
                            <th style="text-align:right;">Current Qty</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(batchList.isEmpty()) { %>
                            <tr><td colspan="6" style="text-align:center; padding:20px; color:#94a3b8;">No active batches in stock.</td></tr>
                        <% } else {
                            int batchCount = 1; // INITIALIZE MODAL COUNTER
                            for(BatchStockDTO b : batchList) { 
                        %>
                        <tr>
                            <td><strong style="color: #475569;"><%= batchCount++ %></strong></td>
                            <td><strong><%= b.getBatchID() %></strong></td>
                            <td><%= b.getArrivalDate() %></td>
                            <td>
                                <% if (b.getExpiryDate() != null) { %>
                                    <span style="color: #dc2626; font-weight:600;"><%= b.getExpiryDate() %></span>
                                <% } else { %> <span style="color:#94a3b8;">N/A</span> <% } %>
                            </td>
                            <td><%= (b.getSupplierID() != null) ? b.getSupplierID() : "-" %></td>
                            <td style="text-align:right;">
                                <span class="badge"><%= b.getCurrentQuantity() %></span>
                            </td>
                        </tr>
                        <% }} %>
                    </tbody>
                </table>
                
                <div style="margin-top: 20px; text-align: right;">
                    <a href="listInventory" style="background: white; color: #0b5ea8; border: 1px solid #0b5ea8; padding: 8px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none;">Close</a>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</body>
</html>