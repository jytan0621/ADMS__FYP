<%-- 
    Document   : outgoing
    Created on : Apr 14, 2026, 2:45:07 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.RequestItemDTO, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    // Retrieve the joined history list
    List<RequestItemDTO> outgoing = (List<RequestItemDTO>) request.getAttribute("outgoing");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Outgoing History</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px; background: #fff1f2; color: #991b1b; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #fecaca; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        
        .badge { background: #dcfce7; color: #166534; padding: 4px 12px; border-radius: 20px; font-weight: 700; font-size: 11px; }
        .batch-ref { background:#f1f5f9; padding:2px 6px; border-radius:4px; font-family: monospace; color: #475569; }
        .date-text { color: #64748b; font-weight: 500; font-size: 13px; }

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
        <h2 style="margin-bottom: 20px; color: #0f172a;"><i class="fas fa-history" style="color:#991b1b; margin-right: 8px;"></i> Out Stock History</h2>
        
        <div class="filter-bar">
            <div class="filter-group">
                <label for="itemSearch"><i class="fas fa-search"></i> Search Item</label>
                <input type="text" id="itemSearch" class="filter-input" placeholder="e.g., Mineral Water...">
            </div>
            
            <div class="filter-group">
                <label for="startDate"><i class="far fa-calendar"></i> Date From</label>
                <input type="date" id="startDate" class="filter-input" style="width: 150px;">
            </div>
            
            <div class="filter-group">
                <label for="endDate"><i class="far fa-calendar-check"></i> Date To</label>
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
                        <th style="width: 120px;"><i class="far fa-calendar-alt"></i> Date</th>
                        <th>Dist. ID</th>
                        <th>Item Name</th>
                        <th>Batch Reference</th>
                        <th>Quantity Sent</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; 
                        if(outgoing != null && !outgoing.isEmpty()) { 
                            for(RequestItemDTO o : outgoing) { 
                    %>
                    <tr class="data-row">
                        <td><strong style="color: #475569;"><%= count++ %></strong></td>
                        
                        <td class="date-text"><%= (o.getActionDate() != null) ? o.getActionDate() : "N/A" %></td>
                        
                        <td><strong><%= o.getItemID() %></strong></td>
                        <td style="font-weight: 500;" class="item-name"><%= o.getItemName() %></td>
                        
                        <td><span class="batch-ref"><%= o.getCategory() %></span></td>
                        <td style="color:#dc2626; font-weight:bold; font-size: 15px;">- <%= o.getQuantityRequested() %></td>
                        <td><span class="badge"><i class="fas fa-check-circle" style="margin-right: 4px;"></i>COMPLETE</span></td>
                    </tr>
                    <%      } 
                        } else { 
                    %>
                    <tr id="noDataRow">
                        <td colspan="7" style="text-align:center; padding:40px; color:#94a3b8; font-style:italic;">
                            <i class="fas fa-box-open" style="font-size: 24px; display:block; margin-bottom:10px; color:#cbd5e1;"></i>
                            No outgoing records found in the system.
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
                const rowItemName = row.querySelector('.item-name').innerText.toLowerCase();
                
                let isMatch = true;

                // 1. Check Item Name Match
                if (searchTerm !== "" && !rowItemName.includes(searchTerm)) {
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