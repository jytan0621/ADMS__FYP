<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    // 1. Basic Login Verification
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    // 2. Role Verification
    if (!"Field Officer".equalsIgnoreCase(u.getRole())) {
        response.sendRedirect("VolunteerTaskServlet?error=UnauthorizedAccess");
        return;
    }
    List<Map<String, Object>> historyList = (List<Map<String, Object>>) request.getAttribute("historyList");
    
    // Retain filter selection status
    String currentType = (String) request.getAttribute("filterType");
    String currentTime = (String) request.getAttribute("filterTime");
    
    // Retain Date Selections
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Distribution History</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        
        /* NEW CSS: Stack Title and Filter vertically */
        .page-header { margin-bottom: 24px; }
        .page-header h2 { margin: 0 0 16px 0; color: #1e293b; }
        
        /* Filter Container now takes full width under the title */
        .filter-container { background: white; padding: 16px 20px; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; }
        .filter-row { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
        .filter-row.bottom { margin-top: 12px; padding-top: 12px; border-top: 1px solid #f1f5f9; }
        
        .filter-group { display: flex; align-items: center; gap: 8px; }
        .filter-label { font-size: 13px; font-weight: 600; color: #64748b; text-transform: uppercase; }
        .filter-input { padding: 8px 12px; border-radius: 4px; border: 1px solid #cbd5e1; outline: none; font-size: 13px; color: #334155; font-weight: 500; font-family: inherit; background-color: #f8fafc; }
        .filter-input:focus { border-color: #0b5ea8; background-color: white; }
        
        .action-buttons { display: flex; gap: 10px; margin-left: auto; } /* Pushes buttons to the far right */
        .btn-filter { background-color: #0b5ea8; color: white; border: none; padding: 8px 18px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-filter:hover { background-color: #084b86; }
        .btn-clear { background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 7px 16px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; display: flex; align-items: center; gap: 6px;}
        .btn-clear:hover { background-color: #e2e8f0; }

        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-top: 20px;}
        table { width: 100%; border-collapse: collapse; margin-top: 5px; }
        th { text-align: left; padding: 12px; background: #f1f5f9; color: #475569; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }
        .badge-incoming { background: #dcfce7; color: #166534; }
        .badge-outgoing { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        
        <div class="page-header">
            <h2><i class="fas fa-history" style="color:#0b5ea8; margin-right: 8px;"></i> Distribution History Logbook</h2>
            
            <form action="DistributionHistoryServlet" method="GET" class="filter-container">
                <div class="filter-row">
                    <div class="filter-group">
                        <span class="filter-label">Flow Type:</span>
                        <select name="filterType" class="filter-input">
                            <option value="ALL" <%= "ALL".equals(currentType) ? "selected" : "" %>>All Transactions</option>
                            <option value="INCOMING" <%= "INCOMING".equals(currentType) ? "selected" : "" %>>Incoming Stock</option>
                            <option value="OUTGOING" <%= "OUTGOING".equals(currentType) ? "selected" : "" %>>Outgoing Distribution</option>
                        </select>
                    </div>
                    
                    <div class="filter-group" style="margin-left: 20px;">
                        <span class="filter-label">Data Grouping:</span>
                        <select name="filterTime" class="filter-input">
                            <option value="DAILY" <%= "DAILY".equals(currentTime) ? "selected" : "" %>>Daily Records</option>
                            <option value="WEEKLY" <%= "WEEKLY".equals(currentTime) ? "selected" : "" %>>Weekly Summary</option>
                            <option value="MONTHLY" <%= "MONTHLY".equals(currentTime) ? "selected" : "" %>>Monthly Summary</option>
                        </select>
                    </div>
                </div>
                
                <div class="filter-row bottom">
                    <div class="filter-group">
                        <span class="filter-label"><i class="far fa-calendar-alt"></i> From:</span>
                        <input type="date" name="startDate" class="filter-input" value="<%= startDate != null ? startDate : "" %>">
                    </div>
                    <div class="filter-group" style="margin-left: 20px;">
                        <span class="filter-label"><i class="far fa-calendar-alt"></i> To:</span>
                        <input type="date" name="endDate" class="filter-input" value="<%= endDate != null ? endDate : "" %>">
                    </div>
                    
                    <div class="action-buttons">
                        <a href="DistributionHistoryServlet" class="btn-clear"><i class="fas fa-times"></i> Clear</a>
                        <button type="submit" class="btn-filter"><i class="fas fa-search"></i> Apply Filter</button>
                    </div>
                </div>
            </form>
        </div>
        
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th><%= "DAILY".equals(currentTime) ? "Timestamp" : ("WEEKLY".equals(currentTime) ? "Time Period (Week)" : "Time Period (Month)") %></th>
                        <th>Type</th>
                        <th>Item Name</th>
                        <th>Tent ID</th>
                        <th style="text-align:right;">Quantity</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(historyList != null && !historyList.isEmpty()) { 
                        for(Map<String, Object> row : historyList) { %>
                    <tr>
                        <td style="color: #64748b; font-weight: 500;"><%= row.get("date") %></td>
                        <td>
                            <span class="badge <%= "INCOMING".equals(row.get("entryType")) ? "badge-incoming" : "badge-outgoing" %>">
                                <%= row.get("entryType") %>
                            </span>
                        </td>
                        <td style="font-weight: 500;"><%= row.get("itemName") %></td>
                        <td><span style="font-family: monospace; color: #475569;"><%= row.get("tentID") != null && !row.get("tentID").toString().isEmpty() ? row.get("tentID") : "-" %></span></td>
                        <td style="text-align:right; font-weight:bold; color: #0b5ea8;"><%= row.get("quantity") %></td>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="5" style="text-align:center; padding:50px; color:#94a3b8;">
                            <i class="fas fa-search" style="font-size: 24px; margin-bottom: 10px; display: block;"></i>
                            No distribution matches found for your filter parameters.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>