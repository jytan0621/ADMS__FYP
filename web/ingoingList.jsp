<%-- 
    Document   : ingoingList
    Created on : Apr 14, 2026, 5:37:13 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.Ingoing, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    // FETCH THE ROLE to use for security checks
    String role = u.getRole().toLowerCase().trim();
    
    List<Ingoing> ingoingList = (List<Ingoing>) request.getAttribute("ingoingList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Ingoing Inventory</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { text-align: left; padding: 12px; background: #f0fdf4; color: #166534; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #bbf7d0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }

        /* Batch Status Badges */
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; }
        .status-available { background: #dcfce7; color: #166534; }
        .status-low { background: #fee2e2; color: #991b1b; }
        
        .btn-new { background: #0b5ea8; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; }
        .btn-new:hover { background: #094b86; }

        /* Filter Bar Styles */
        .filter-bar { display: flex; gap: 15px; align-items: center; background: #f1f5f9; padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #e2e8f0; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; }
        .filter-input { padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; width: 200px; color: #1e293b; }
        .filter-input:focus { border-color: #0b5ea8; box-shadow: 0 0 0 2px rgba(11,94,168,0.2); }
        .btn-filter { background: #0b5ea8; color: white; border: none; padding: 9px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: 0.2s; margin-top: 20px; }
        .btn-filter:hover { background: #094b86; }
        .btn-reset { background: #e2e8f0; color: #475569; border: none; padding: 9px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: 0.2s; margin-top: 20px; }
        .btn-reset:hover { background: #cbd5e1; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 style="margin:0; color: #0f172a;"><i class="fas fa-truck-loading" style="color:#166534; margin-right: 8px;"></i> In Stock History</h2>
            
            <%-- ROLE CHECK: Only Logistic Staff can see this button --%>
            <% if ("logistic staff".equals(role)) { %>
                <a href="newIngoing" class="btn-new"><i class="fas fa-plus"></i> Receive New Stock</a>
            <% } %>
            
        </div>

        <div class="filter-bar">
            <div class="filter-group">
                <label for="itemSearch"><i class="fas fa-search"></i> Search Item/Batch</label>
                <input type="text" id="itemSearch" class="filter-input" placeholder="e.g., Mineral Water or B0001...">
            </div>
            
            <div class="filter-group">
                <label for="startDate"><i class="far fa-calendar"></i> Arrival From</label>
                <input type="date" id="startDate" class="filter-input" style="width: 150px;">
            </div>
            
            <div class="filter-group">
                <label for="endDate"><i class="far fa-calendar-check"></i> Arrival To</label>
                <input type="date" id="endDate" class="filter-input" style="width: 150px;">
            </div>
            
            <button onclick="applyFilter()" class="btn-filter"><i class="fas fa-filter"></i> Filter</button>
            <button onclick="resetFilter()" class="btn-reset"><i class="fas fa-redo"></i> Reset</button>
        </div>

        <div class="card">
            <table id="historyTable">
                <thead>
                    <tr>
                        <th style="width: 60px;">No.</th> 
                        <th><i class="fas fa-box" style="margin-right: 4px;"></i> Batch ID</th>
                        <th><i class="fas fa-cube" style="margin-right: 4px;"></i> Item Name</th>
                        <th><i class="far fa-calendar-alt" style="margin-right: 4px;"></i> Arrival Date</th>
                        <th><i class="far fa-calendar-times" style="margin-right: 4px;"></i> Expiry Date</th>
                        <th><i class="fas fa-sort-amount-up" style="margin-right: 4px;"></i> Qty Received</th>
                        <th>Status</th>
                        <th><i class="fas fa-building" style="margin-right: 4px;"></i> Supplier Name</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; // Initialize the counter
                        if(ingoingList != null && !ingoingList.isEmpty()) { 
                            for(Ingoing b : ingoingList) { 
                                String statusClass = "status-available";
                                if(b.getCurrentQuantity() <= 10) statusClass = "status-low";
                    %>
                    <tr class="data-row">
                        <td><strong style="color: #475569;"><%= count++ %></strong></td>
                        
                        <td class="searchable-text"><strong><%= b.getBatchID() %></strong></td>
                        
                        <td class="searchable-text" style="font-weight: 500;"><%= (b.getItemName() != null) ? b.getItemName() : b.getItemID() %></td>
                        
                        <td class="date-text" style="color: #64748b;"><%= b.getArrivalDate() %></td>
                        <td><%= (b.getExpiryDate() != null) ? b.getExpiryDate() : "N/A" %></td>
                        <td style="color:#166534; font-weight:bold; font-size: 15px;">+ <%= b.getQuantityReceived() %></td>
                        <td><span class="badge <%= statusClass %>"><%= b.getbStatus() %></span></td>
                        
                        <td><%= (b.getSupplierName() != null) ? b.getSupplierName() : "-" %></td>
                    </tr>
                    <%      } 
                        } else { 
                    %>
                    <tr id="noDataRow">
                        <td colspan="8" style="text-align:center; padding:40px; color:#94a3b8; font-style:italic;">
                            <i class="fas fa-truck-loading" style="font-size: 24px; display:block; margin-bottom:10px; color:#cbd5e1;"></i>
                            No ingoing records found in the system.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function applyFilter() {
            // Get user input values
            const searchTerm = document.getElementById('itemSearch').value.toLowerCase();
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            
            // Get all data rows in the table
            const rows = document.querySelectorAll('#historyTable tbody tr.data-row');
            
            rows.forEach(row => {
                // Extract data from the row
                const rowDateText = row.querySelector('.date-text').innerText.trim();
                
                // Combine Batch ID and Item Name text for a better search
                const searchableText = Array.from(row.querySelectorAll('.searchable-text'))
                                            .map(td => td.innerText.toLowerCase())
                                            .join(' ');
                
                let isMatch = true;

                // 1. Check Item/Batch Match
                if (searchTerm !== "" && !searchableText.includes(searchTerm)) {
                    isMatch = false;
                }
                
                // 2. Check Start Date Match (Row Date >= Start Date)
                if (isMatch && startDate !== "" && rowDateText !== "N/A") {
                    if (new Date(rowDateText) < new Date(startDate)) {
                        isMatch = false;
                    }
                }
                
                // 3. Check End Date Match (Row Date <= End Date)
                if (isMatch && endDate !== "" && rowDateText !== "N/A") {
                    if (new Date(rowDateText) > new Date(endDate)) {
                        isMatch = false;
                    }
                }

                // Show or Hide the row based on the result
                row.style.display = isMatch ? '' : 'none';
            });
        }

        function resetFilter() {
            // Clear inputs
            document.getElementById('itemSearch').value = '';
            document.getElementById('startDate').value = '';
            document.getElementById('endDate').value = '';
            
            // Show all rows
            const rows = document.querySelectorAll('#historyTable tbody tr.data-row');
            rows.forEach(row => {
                row.style.display = '';
            });
        }
    </script>
</body>
</html>