<%-- Document: InventoryForecast.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    String role = currentUser.getRole().toLowerCase().trim();
    
    String shelterID = (String) session.getAttribute("myShelterID");
    if (shelterID == null || shelterID.trim().isEmpty()) { 
        shelterID = currentUser.getAssignedRegion(); 
    }
    if (shelterID == null || shelterID.trim().isEmpty()) { shelterID = "Not Assigned"; }
    
    List<Map<String, Object>> flowReport = (List<Map<String, Object>>) request.getAttribute("flowReport");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Flow Allocation Panel</title>
    <link rel="stylesheet" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; min-height: 100vh; box-sizing: border-box; background-color: #f8fafc; }
        
        .form-card { background: white; width: 100%; max-width: 1100px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .page-title { font-size: 32px; font-weight: 600; color: #0f172a; margin: 0 0 10px 0; }
        
        .table-container { border: 1px solid #cbd5e1; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-top: 25px;}
        table { width: 100%; border-collapse: collapse; background: white; }
        th { border-bottom: 2px solid #cbd5e1; padding: 14px 16px; text-align: left; font-weight: bold; color: #334155; background-color: #f8fafc; }
        td { border-bottom: 1px solid #e2e8f0; padding: 14px 16px; color: #1e293b; vertical-align: middle; }
        
        .type-badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .badge-daily { background-color: #e0f2fe; color: #0369a1; }
        .badge-kit { background-color: #fef3c7; color: #92400e; }
        
        .status-badge { padding: 4px 10px; border-radius: 4px; font-size: 13px; font-weight: bold; display: inline-block; }
        .status-optimal { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .status-shortage { background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        
        .btn-request { background-color: #f59e0b; color: white; border: none; padding: 8px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; font-size: 12px; display: inline-flex; align-items: center; gap: 6px; }
        .btn-request:hover { background-color: #d97706; }
        .alert-box { background-color: #fff7ed; border: 1px solid #ffedd5; color: #c2410c; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; font-weight: 500; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <h1 class="page-title"><i class="fas fa-history" style="color: #0b5ea8; margin-right: 10px;"></i> Distribution Flow Balance Tracker</h1>
            <p style="color: #64748b; margin: 0 0 25px 0;">
                Monitor total active allocated provisions mapped against today's outstanding remaining distribution requirements.
            </p>

            <div class="alert-box">
                <i class="fas fa-info-circle"></i> <strong>Logistical Status:</strong> Items marked with a shortage error require immediate supply request submissions to Central Logistics before volunteers can complete task distribution runs.
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Aid Item Details</th>
                            <th>Ration Type</th>
                            <th style="text-align: center;">Allocated Balance</th>
                            <th style="text-align: center;">Today's Remaining Demand</th>
                            <th style="text-align: center;">Status Check</th>
                            <th style="text-align: center;">Logistics Action Required</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            if (flowReport != null && !flowReport.isEmpty()) {
                                for (Map<String, Object> row : flowReport) {
                                    String distType = (String) row.get("distType");
                                    boolean isInsufficient = (Boolean) row.get("isInsufficient");
                                    int shortage = (Integer) row.get("shortage");
                        %>
                                    <tr style="<%= isInsufficient ? "background-color: #fffafb;" : "" %>">
                                        <td>
                                            <strong style="font-size: 16px; color:#0f172a;"><%= row.get("itemName") %></strong><br>
                                            <span style="font-size:12px; color:#64748b;">Code: <%= row.get("itemID") %></span>
                                        </td>
                                        <td>
                                            <% if ("DAILY".equals(distType)) { %>
                                                <span class="type-badge badge-daily">Daily Ration</span>
                                            <% } else { %>
                                                <span class="type-badge badge-kit">One-Off Entry Kit</span>
                                            <% } %>
                                        </td>
                                        <td style="text-align: center; font-weight: bold;"><%= row.get("remainingBalance") %></td>
                                        <td style="text-align: center; font-weight: 600; color: #475569;"><%= row.get("todayDemand") %></td>
                                        <td style="text-align: center;">
                                            <% if (!isInsufficient) { %>
                                                <span class="status-badge status-optimal"><i class="fas fa-check-circle"></i> Sufficient Pool</span>
                                            <% } else { %>
                                                <span class="status-badge status-shortage"><i class="fas fa-exclamation-triangle"></i> Shortage: x<%= shortage %></span>
                                            <% } %>
                                        </td>
                                        <td style="text-align: center;">
                                            <% if (isInsufficient) { %>
                                                <a href="requestSupplies.jsp?itemID=<%= row.get("itemID") %>&qty=<%= shortage %>" class="btn-request">
                                                    <i class="fas fa-shipping-fast"></i> Request x<%= shortage %> from Logistics
                                                </a>
                                            <% } else { %>
                                                <span style="color: #166534; font-weight: 600; font-size: 13px;"><i class="fas fa-thumbs-up"></i> Clear to Distribute</span>
                                            <% } %>
                                        </td>
                                    </tr>
                        <% 
                                }
                            } else { 
                        %>
                            <tr>
                                <td colspan="6" style="text-align: center; color: #94a3b8; padding: 40px; font-style: italic;">
                                    No active allocation tracking configurations found.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
        </div>
    </div>

</body>
</html>