<%-- Document: LogisticsMain.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="com.Model.InventoryItem" %>
<%@ page import="com.Model.RequestItemDTO" %>
<%@ page import="com.Model.StockTransactionDTO" %>
<%@ page import="com.Model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
    String role = user.getRole().toLowerCase().trim();

    // Fetch lists from Servlet
    List<AidRequest> approvedRequests = (List<AidRequest>) request.getAttribute("approvedRequests");
    List<InventoryItem> listInventory = (List<InventoryItem>) request.getAttribute("listInventory");
    List<StockTransactionDTO> stockHistory = (List<StockTransactionDTO>) request.getAttribute("stockHistory");

    // Calculate Summary Data
    int pendingDistCount = (approvedRequests != null) ? approvedRequests.size() : 0;
    int restockReqCount = 0;

    // Prepare Chart Data
    StringBuilder chartLabels = new StringBuilder();
    StringBuilder chartData = new StringBuilder();

    if (listInventory != null && !listInventory.isEmpty()) {
        for (int i = 0; i < listInventory.size(); i++) {
            InventoryItem item = listInventory.get(i);
            if (item.getQuantityAvailable() <= item.getThreshold()) { restockReqCount++; }
            
            chartLabels.append("\"").append(item.getIName()).append("\"");
            chartData.append(item.getQuantityAvailable());
            if (i < listInventory.size() - 1) {
                chartLabels.append(", ");
                chartData.append(", ");
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Logistics Command Center</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; overflow-y: auto; }
        .main-content-area { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; background-color: #f8fafc; }
        
        .card { background: white; border-radius: 8px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; display: flex; flex-direction: column; }
        .summary-card { padding: 20px; border-left: 5px solid #4A7BA7; cursor: pointer; transition: transform 0.2s; height: 100%; justify-content: center;}
        .summary-card:hover { transform: translateY(-3px); }
        .summary-card.warning { border-left-color: #f59e0b; }
        .summary-card.alert { border-left-color: #ef4444; }
        
        .summary-label { font-size: 12px; font-weight: 700; color: #9ca3af; text-transform: uppercase; }
        .summary-value { font-size: 36px; font-weight: 700; color: #1f2937; margin-top: 5px; }

        .tab-container { border-bottom: 2px solid #e2e8f0; margin-bottom: 25px; display: flex; gap: 30px; }
        .tab-btn { background: none; border: none; padding: 10px 5px; font-size: 16px; font-weight: 600; color: #64748b; cursor: pointer; border-bottom: 3px solid transparent; transition: 0.2s; outline: none; }
        .tab-btn:hover { color: #0b5ea8; }
        .tab-btn.active { color: #0b5ea8; border-bottom-color: #0b5ea8; }
        .tab-content { display: none; animation: fadeIn 0.3s ease; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        .table-container { border: 1px solid #cbd5e1; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; background: white; text-align: left; }
        th { border-bottom: 2px solid #cbd5e1; padding: 14px 16px; font-weight: bold; color: #334155; background-color: #f8fafc; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px; }
        td { border-bottom: 1px solid #e2e8f0; padding: 14px 16px; color: #1e293b; vertical-align: middle; font-size: 14px; }
        tr:hover { background-color: #f8fafc; }
        
        .badge { background: #e0f2fe; color: #0284c7; padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: bold; display: inline-block; }
        .badge-in { background: #dcfce7; color: #166534; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: bold;}
        .badge-out { background: #fee2e2; color: #dc2626; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: bold;}
        
        .btn-prepare { background-color: #f97316; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; font-size: 14px; }
        .btn-prepare:hover { background-color: #ea580c; }
        .btn-add { background-color: #0b5ea8; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; transition: 0.2s; display: inline-block; margin-bottom: 15px;}
        .btn-add:hover { background-color: #094b86; }
        
        .btn-action { display: inline-flex; align-items: center; gap: 5px; padding: 6px 12px; border-radius: 4px; font-size: 13px; font-weight: 600; text-decoration: none; transition: 0.2s; margin-left: 5px; }
        .btn-edit { background: #f1f5f9; color: #0ea5e9; border: 1px solid #cbd5e1; }
        .btn-edit:hover { background: #e0f2fe; border-color: #7dd3fc; }
        .btn-restock { background: #fff7ed; color: #d97706; border: 1px solid #fde68a; }
        .btn-restock:hover { background: #fef3c7; border-color: #fcd34d; }
        
        .btn-outline { background: white; color: #0b5ea8; border: 1px solid #0b5ea8; padding: 8px 12px; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; font-size: 13px; margin-right: 8px; transition: 0.2s;}
        .btn-outline:hover { background: #f1f5f9; }
        
        .stock-low { color: #dc2626; font-weight: bold; background: #fee2e2; padding: 4px 8px; border-radius: 4px; font-size: 13px; }
        .stock-good { color: #166534; font-weight: bold; background: #dcfce7; padding: 4px 8px; border-radius: 4px; font-size: 13px; }
        .empty-state { text-align: center; padding: 50px 20px; color: #94a3b8; }
        .chart-container { height: 200px; width: 100%; }

        /* Modal Styles */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.6); z-index: 2000; align-items: center; justify-content: center; backdrop-filter: blur(2px); }
        .modal-card { background: white; width: 100%; max-width: 600px; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); overflow: hidden; animation: slideDown 0.3s ease-out; }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; }
        .modal-header h3 { margin: 0; font-size: 18px; color: #0f172a; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1; text-decoration: none;}
        .close-btn:hover { color: #ef4444; }
        .modal-body { padding: 24px; max-height: 60vh; overflow-y: auto; }
        @keyframes slideDown { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <main class="main-content-area">
        <div style="max-width: 1280px; margin: 0 auto;">
             
             <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:20px;">
                 <div>
                     <h2 style="font-size:24px; font-weight:bold; margin:0; color:#1f2937;">Logistics Command Center</h2>
                     <p style="color:#6b7280; font-size:14px; margin:5px 0 0 0;">Manage distribution operations and monitor your shelter's physical stock.</p>
                 </div>
             </div>

             <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px; margin-bottom: 30px;">
                 <div style="display: flex; flex-direction: column; gap: 24px;">
                     <div class="card summary-card warning" onclick="document.getElementById('tabBtnOrders').click();">
                         <div class="summary-label">Pending Distribution (Click)</div>
                         <div class="summary-value"><%= pendingDistCount %></div>
                     </div>
                     <div class="card summary-card alert" onclick="document.getElementById('tabBtnInventory').click();">
                         <div class="summary-label">Restock Alerts / Low Stock</div>
                         <div class="summary-value"><%= restockReqCount %></div>
                     </div>
                 </div>
                 <div class="card">
                     <h3 style="margin-top:0; font-size: 14px; color: #64748b; text-transform: uppercase;">Inventory Quantity Overview</h3>
                     <div class="chart-container">
                         <canvas id="inventoryChart"></canvas>
                     </div>
                 </div>
             </div>

             <div class="card" style="padding: 30px;">
                
                <div class="tab-container">
                    <button id="tabBtnOrders" class="tab-btn active" onclick="switchTab(this, 'tab-orders')"><i class="fas fa-box-open"></i> Pending Preparations</button>
                    <button id="tabBtnInventory" class="tab-btn" onclick="switchTab(this, 'tab-inventory')"><i class="fas fa-clipboard-list"></i> Shelter Inventory</button>
                    <button id="tabBtnHistory" class="tab-btn" onclick="switchTab(this, 'tab-history')"><i class="fas fa-exchange-alt"></i> Stock Movement</button>
                </div>

                <div id="tab-orders" class="tab-content active">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Request ID</th>
                                    <th>Requested By</th>
                                    <th>Date Submitted</th>
                                    <th>Status</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (approvedRequests == null || approvedRequests.isEmpty()) { %>
                                    <tr>
                                        <td colspan="5">
                                            <div class="empty-state">
                                                <i class="fas fa-check-double" style="font-size:40px; margin-bottom:10px; color:#cbd5e1;"></i>
                                                <h3 style="margin-bottom: 5px; color:#64748b;">No Pending Preparations</h3>
                                                <p style="margin: 0;">All approved requests have been prepared.</p>
                                            </div>
                                        </td>
                                    </tr>
                                <% } else {
                                        for (AidRequest req : approvedRequests) { %>
                                    <tr>
                                        <td><strong><%= req.getRequestID() %></strong></td>
                                        <td><%= req.getRequestedBy() %></td>
                                        <td><%= req.getArDateSubmitted() %></td>
                                        <td><span class="badge"><%= req.getArStatus() %></span></td>
                                        <td style="text-align: right; display: flex; justify-content: flex-end; align-items: center;">
                                            <a href="viewRequestItems?requestID=<%= req.getRequestID() %>" class="btn-outline"><i class="fas fa-eye"></i> View</a>
                                            
                                            <%-- ROLE CHECK: Only Logistic Staff can see the Prepare Order button --%>
                                            <% if ("logistic staff".equals(role)) { %>
                                            <form action="prepareOrder" method="POST" onsubmit="return confirm('Confirm physical items for this request have been gathered from the store?');" style="margin:0;">
                                                <input type="hidden" name="requestID" value="<%= req.getRequestID() %>">
                                                <button type="submit" class="btn-prepare"><i class="fas fa-truck-loading"></i> Prepare Order</button>
                                            </form>
                                            <% } %>
                                            
                                        </td>
                                    </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div id="tab-inventory" class="tab-content">
                    
                    <%-- ROLE CHECK: Hide the Add New Item button for Approval Officers --%>
                    <% if (!"approval officer".equals(role)) { %>
                    <div style="text-align: right;">
                        <a href="newInventory" class="btn-add"><i class="fas fa-plus"></i> Add New Item</a>
                    </div>
                    <% } %>
                    
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Item ID</th>
                                    <th>Item Name</th>
                                    <th>Category</th>
                                    <th>Available Stock</th>
                                    
                                    <%-- ROLE CHECK: Hide Action Header for Approval Officers --%>
                                    <% if (!"approval officer".equals(role)) { %>
                                    <th style="text-align: right;">Actions</th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    if (listInventory != null && !listInventory.isEmpty()) {
                                        for (InventoryItem item : listInventory) { 
                                            boolean isLowStock = item.getQuantityAvailable() <= item.getThreshold();
                                %>
                                    <tr>
                                        <td><strong><%= item.getItemID() %></strong></td>
                                        
                                        <td style="font-weight:600;">
                                            <a href="viewItemBatches?itemID=<%= item.getItemID() %>" style="color: #0b5ea8; text-decoration: underline; cursor: pointer;">
                                                <%= item.getIName() %>
                                            </a>
                                        </td>
                                        
                                        <td><%= item.getCategory() %></td>
                                        <td>
                                            <% if (isLowStock) { %>
                                                <span class="stock-low" title="Threshold: <%= item.getThreshold() %>"><i class="fas fa-exclamation-triangle"></i> <%= item.getQuantityAvailable() %> <%= item.getUnit() %></span>
                                            <% } else { %>
                                                <span class="stock-good"><%= item.getQuantityAvailable() %> <%= item.getUnit() %></span>
                                            <% } %>
                                        </td>
                                        
                                        <%-- ROLE CHECK: Hide Edit/Restock Buttons for Approval Officers --%>
                                        <% if (!"approval officer".equals(role)) { %>
                                        <td style="text-align: right; white-space: nowrap;">
                                            <a href="newRestock" class="btn-action btn-restock" title="Request Restock">
                                                <i class="fas fa-truck-loading"></i> Restock
                                            </a>
                                            <a href="editInventory?id=<%= item.getItemID() %>" class="btn-action btn-edit" title="Edit Item Details">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                        </td>
                                        <% } %>
                                        
                                    </tr>
                                <% }} else { %>
                                    <tr>
                                        <%-- Dynamically change column span based on role --%>
                                        <td colspan="<%= ("approval officer".equals(role)) ? 4 : 5 %>" class="empty-state">
                                            No inventory items found.
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div id="tab-history" class="tab-content">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Movement</th>
                                    <th>Reference ID</th>
                                    <th>Item Name</th>
                                    <th style="text-align: right;">Qty Changed</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (stockHistory == null || stockHistory.isEmpty()) { %>
                                    <tr><td colspan="5" class="empty-state">No stock movements recorded yet.</td></tr>
                                <% } else {
                                        for (StockTransactionDTO t : stockHistory) { 
                                            boolean isIn = "IN".equals(t.getType());
                                %>
                                    <tr>
                                        <td><%= t.getTransactionDate() %></td>
                                        <td>
                                            <% if(isIn) { %> <span class="badge-in"><i class="fas fa-arrow-down"></i> IN</span> 
                                            <% } else { %> <span class="badge-out"><i class="fas fa-arrow-up"></i> OUT</span> <% } %>
                                        </td>
                                        <td><code style="background:#f1f5f9; padding:2px 6px; border-radius:4px; color:#475569;"><%= t.getReferenceID() %></code></td>
                                        <td style="font-weight: 600;"><%= t.getItemName() %></td>
                                        <td style="text-align: right; font-weight:bold; color: <%= isIn ? "#166534" : "#dc2626" %>;">
                                            <%= isIn ? "+" : "-" %> <%= t.getQuantity() %>
                                        </td>
                                    </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                </div>

             </div> 
        </div>
    </main>

    <%-- ========================================= --%>
    <%-- MODAL 1: STATUS ALERTS (THE NEW POPUP!)   --%>
    <%-- ========================================= --%>
    <% 
        String popupMsg = request.getParameter("msg");
        String popupError = request.getParameter("error");
        
        if (popupMsg != null || popupError != null) { 
            boolean isError = "InsufficientStock".equals(popupError);
            String title = isError ? "Insufficient Stock!" : "Success!";
            String messageText = isError 
                ? "There is not enough stock in the warehouse to fulfill this request. Please arrange for a restock before proceeding." 
                : "Items successfully deducted from inventory. Ready for volunteers!";
            String iconClass = isError ? "fas fa-exclamation-triangle" : "fas fa-check-circle";
            String colorCode = isError ? "#ef4444" : "#10b981";
    %>
    <style>
        .modal-overlay-alert { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.6); z-index: 3000; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(2px); }
        .modal-card-alert { background: white; max-width: 400px; width: 100%; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); padding: 30px; text-align: center; animation: slideDownAlert 0.3s ease-out; }
        .btn-alert-ok { color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 14px; width: 100%; transition: 0.2s; margin-top: 15px;}
        .btn-alert-ok:hover { opacity: 0.9; }
        @keyframes slideDownAlert { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
    <div id="statusAlertModal" class="modal-overlay-alert">
        <div class="modal-card-alert">
            <i class="<%= iconClass %>" style="font-size: 50px; color: <%= colorCode %>; margin-bottom: 15px;"></i>
            <h3 style="margin: 0 0 10px 0; color: #0f172a; font-size: 22px;"><%= title %></h3>
            <p style="color: #475569; margin-bottom: 25px; font-size: 15px; line-height: 1.5;"><%= messageText %></p>
            <button onclick="document.getElementById('statusAlertModal').style.display='none'" class="btn-alert-ok" style="background: <%= colorCode %>;">
                OK, Got it
            </button>
        </div>
    </div>
    <% } %>

    <%-- ========================================= --%>
    <%-- MODAL 2: AID REQUEST ITEMS BREAKDOWN      --%>
    <%-- ========================================= --%>
    <% 
        String targetReqID = (String) request.getAttribute("targetRequestID");
        List<RequestItemDTO> itemsList = (List<RequestItemDTO>) request.getAttribute("requestItemsList");
        
        if (targetReqID != null && itemsList != null) { 
    %>
    <div id="itemsModal" class="modal-overlay" style="display: flex;">
        <div class="modal-card">
            <div class="modal-header">
                <h3><i class="fas fa-box" style="color: #0b5ea8;"></i> Items for Request: <%= targetReqID %></h3>
                <a href="logisticsDashboard" class="close-btn" onclick="sessionStorage.setItem('activeLogisticsTab', 'tab-orders');">&times;</a>
            </div>
            <div class="modal-body">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Item Name</th>
                                <th>Category</th>
                                <th style="text-align:center;">Qty Requested</th>
                                <th style="text-align:center;">Qty Approved</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(RequestItemDTO i : itemsList) { %>
                            <tr>
                                <td style="font-weight: 600;"><%= i.getItemName() %></td>
                                <td><%= i.getCategory() %></td>
                                <td style="text-align:center;"><%= i.getQuantityRequested() %></td>
                                <td style="text-align:center;">
                                    <span class="badge" style="background:#dcfce7; color:#166534;"><%= i.getQuantityApproved() %></span>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; text-align: right;">
                    <a href="logisticsDashboard" style="color: #64748b; text-decoration: none; margin-right: 15px; font-weight: 600;" onclick="sessionStorage.setItem('activeLogisticsTab', 'tab-orders');">Cancel</a>
                    
                    <%-- ROLE CHECK: Only Logistic Staff can see the Prepare Order Now button in the Modal --%>
                    <% if ("logistic staff".equals(role)) { %>
                    <form action="prepareOrder" method="POST" onsubmit="return confirm('Confirm items have been gathered?');" style="display:inline-block;">
                        <input type="hidden" name="requestID" value="<%= targetReqID %>">
                        <button type="submit" class="btn-prepare"><i class="fas fa-check-circle"></i> Prepare Order Now</button>
                    </form>
                    <% } %>
                    
                </div>
            </div>
        </div>
    </div>
    <% } %>

    <%-- ========================================= --%>
    <%-- MODAL 3: INVENTORY BATCH BREAKDOWN        --%>
    <%-- ========================================= --%>
    <% 
        String targetBatchID = (String) request.getAttribute("targetBatchItemID");
        List<com.Model.BatchStockDTO> batchList = (List<com.Model.BatchStockDTO>) request.getAttribute("batchList");
        
        if (targetBatchID != null && batchList != null) { 
    %>
    <div id="batchModal" class="modal-overlay" style="display: flex;">
        <div class="modal-card">
            <div class="modal-header">
                <h3><i class="fas fa-boxes" style="color: #0b5ea8;"></i> Batch Breakdown for Item: <%= targetBatchID %></h3>
                <a href="logisticsDashboard" class="close-btn" onclick="sessionStorage.setItem('activeLogisticsTab', 'tab-inventory');">&times;</a>
            </div>
            <div class="modal-body">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Batch ID</th>
                                <th>Arrival Date</th>
                                <th>Expiry Date</th>
                                <th>Supplier</th>
                                <th style="text-align:right;">Current Qty</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(batchList.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align:center; padding:20px; color:#94a3b8;">No active batches in stock.</td></tr>
                            <% } else {
                                for(com.Model.BatchStockDTO b : batchList) { 
                            %>
                            <tr>
                                <td><strong><%= b.getBatchID() %></strong></td>
                                <td><%= b.getArrivalDate() %></td>
                                <td>
                                    <% if (b.getExpiryDate() != null) { %>
                                        <span style="color: #dc2626; font-weight:600;"><%= b.getExpiryDate() %></span>
                                    <% } else { %> <span style="color:#94a3b8;">N/A</span> <% } %>
                                </td>
                                <td><%= (b.getSupplierID() != null) ? b.getSupplierID() : "-" %></td>
                                <td style="text-align:right;">
                                    <span class="badge" style="background:#dcfce7; color:#166534; font-size:14px;"><%= b.getCurrentQuantity() %></span>
                                </td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; text-align: right;">
                    <a href="logisticsDashboard" class="btn-outline" onclick="sessionStorage.setItem('activeLogisticsTab', 'tab-inventory');">Close</a>
                </div>
            </div>
        </div>
    </div>
    <% } %>

    <script>
        // Render Chart.js
        Chart.defaults.font.family = "'Segoe UI', sans-serif";
        const ctx = document.getElementById('inventoryChart');
        if(ctx) {
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: [<%= chartLabels.toString() %>],
                    datasets: [{
                        label: 'Quantity Available',
                        data: [<%= chartData.toString() %>],
                        backgroundColor: '#4A7BA7',
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: '#f1f5f9' } },
                        x: { grid: { display: false }, ticks: { maxRotation: 45, minRotation: 45 } }
                    }
                }
            });
        }

        // Tab Logic
        function switchTab(buttonElement, tabId) {
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            buttonElement.classList.add('active'); 
            sessionStorage.setItem('activeLogisticsTab', tabId);
        }

        document.addEventListener('DOMContentLoaded', function() {
            const savedTab = sessionStorage.getItem('activeLogisticsTab');
            if (savedTab) {
                const buttons = document.querySelectorAll('.tab-btn');
                for (let btn of buttons) {
                    if (btn.getAttribute('onclick').includes(savedTab)) {
                        btn.click();
                        break;
                    }
                }
            }
        });
    </script>
</body>
</html>