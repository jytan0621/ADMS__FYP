<%@page import="com.DAO.InventoryDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="com.Model.Shelter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
    String role = user.getRole().toLowerCase().trim();
    String userRegion = user.getAssignedRegion();

    Integer totalBen = (Integer) request.getAttribute("totalBen"); if(totalBen==null) totalBen=0;
    Integer pendingReq = (Integer) request.getAttribute("pendingReq"); if(pendingReq==null) pendingReq=0;
    Integer lowStock = (Integer) request.getAttribute("lowStock"); if(lowStock==null) lowStock=0;
    Integer activeSheltersCount = (Integer) request.getAttribute("activeSheltersCount"); if(activeSheltersCount==null) activeSheltersCount=0;

    Integer myApp = (Integer) request.getAttribute("myApproved"); if(myApp==null) myApp=0;
    Integer myRej = (Integer) request.getAttribute("myRejected"); if(myRej==null) myRej=0;
    Integer queue = (Integer) request.getAttribute("globalQueue"); if(queue==null) queue=0;
    Integer processed = (Integer) request.getAttribute("myTotalProcessed"); if(processed==null) processed=0;
    Integer restockApp = (Integer) request.getAttribute("restockApproved"); if(restockApp==null) restockApp=0;
    Integer restockPen = (Integer) request.getAttribute("restockPending"); if(restockPen==null) restockPen=0;
    Integer restockRej = (Integer) request.getAttribute("restockRejected"); if(restockRej==null) restockRej=0;

    Integer myTotalReq = (Integer) request.getAttribute("myTotalReq"); if(myTotalReq==null) myTotalReq=0;
    Integer myPendingReq = (Integer) request.getAttribute("myPendingReq"); if(myPendingReq==null) myPendingReq=0;
    
    List<AidRequest> myPendingList = (List<AidRequest>) request.getAttribute("myPendingList"); if(myPendingList==null) myPendingList=new ArrayList<>();
    List<AidRequest> globalPendingList = (List<AidRequest>) request.getAttribute("globalPendingList"); if(globalPendingList==null) globalPendingList=new ArrayList<>();
    
    Integer activeBen = (Integer) request.getAttribute("activeBenCount"); if(activeBen==null) activeBen=0;
    Integer inactiveBen = (Integer) request.getAttribute("inactiveBenCount"); if(inactiveBen==null) inactiveBen=0;
    
    List<String> messages = (List<String>) request.getAttribute("announcements"); if(messages==null) messages=new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; overflow-y: auto; }
        .main-content-area { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; background-color: #f8fafc; }
        
        .dashboard-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 30px; }
        .dashboard-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 30px; }
        
        .card { background: white; border-radius: 8px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; display: flex; flex-direction: column; }
        .summary-card { padding: 20px; border-left: 5px solid #4A7BA7; }
        .summary-card.warning { border-left-color: #f59e0b; }
        .summary-card.alert { border-left-color: #ef4444; }
        .summary-card.success { border-left-color: #10b981; }
        .summary-card.purple { border-left-color: #8b5cf6; }
        
        .summary-label { font-size: 12px; font-weight: 700; color: #9ca3af; text-transform: uppercase; }
        .summary-value { font-size: 30px; font-weight: 700; color: #1f2937; margin-top: 5px; }
        
        a.card-link { text-decoration: none; color: inherit; display: block; height: 100%; transition: transform 0.2s; }
        a.card-link:hover { transform: translateY(-3px); }

        .chart-container { height: 250px; position: relative; width: 100%; }
        .chart-title { font-size: 16px; font-weight: 700; color: #1f2937; margin-bottom: 15px; }
        
        .msg-list { display: flex; flex-direction: column; gap: 15px; overflow-y: auto; max-height: 200px; }
        .msg-item { background: white; padding: 12px; border-radius: 6px; border: 1px solid #f3f4f6; }
        .msg-text { font-size: 14px; margin: 0; }
        .btn-add { background-color: #10b981; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
            
    <main class="main-content-area">
        <div style="max-width: 1280px; margin: 0 auto;">
             
             <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:30px;">
                 <div>
                     <h2 style="font-size:24px; font-weight:bold; margin:0; color:#1f2937;">Dashboard Overview</h2>
                     <p style="color:#6b7280; font-size:14px; margin:5px 0 0 0;">Welcome back, here is your <%= role %> summary.</p>
                 </div>
                 <% if (!"approval officer".equals(role) && !"admin".equals(role) && !"manager".equals(role)) { %>
                    <a href="newRequest" class="btn-add"><i class="fas fa-plus"></i> New Request</a>
                 <% } %>
             </div>

             <div style="margin-bottom: 30px;">
                 <div class="card" style="background: linear-gradient(120deg, #2563eb 0%, #06b6d4 100%); color: white; border: none; border-radius: 16px; padding: 30px 40px; display: flex; flex-direction: row; justify-content: space-between; align-items: center;">
                     <div>
                         <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 5px;">
                            <i class="fas fa-map-marker-alt"></i> 
                            <span style="font-weight: 500; text-transform: uppercase;"><%= request.getAttribute("shelterName") %></span>
                        </div>
                        <h2 style="margin: 0; font-size: 32px; font-weight: 700;">Cloudy</h2>
                         <p style="margin: 5px 0 0 0; opacity: 0.8; font-size: 14px;">Today's Forecast</p>
                     </div>
                     <i class="fas fa-cloud-sun" style="font-size: 80px; opacity: 0.9;"></i>
                     <div style="text-align: right;">
                         <h1 style="margin: 0; font-size: 64px; font-weight: 700; line-height: 1;">29°</h1>
                         <div style="margin-top: 10px; background: rgba(255,255,255,0.2); padding: 8px 16px; border-radius: 20px;"><i class="fas fa-tint"></i> 70% Humidity</div>
                     </div>
                 </div>
             </div>

             <%-- ========================== APPROVAL OFFICER ========================== --%>
             <% if(role.equals("approval officer")) { %>
                <div class="dashboard-grid-3">
                    <a href="listRequest?status=Pending" class="card-link">
                        <div class="card summary-card warning">
                            <div class="summary-label">Pending Queue (Click)</div>
                            <div class="summary-value"><%= queue %></div>
                        </div>
                    </a>
                    <div class="card summary-card alert"><div class="summary-label">Restock Needed</div><div class="summary-value"><%= restockPen %></div></div>
                    <div class="card summary-card"><div class="summary-label">Total Reviewed By Me</div><div class="summary-value"><%= processed %></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card"><h3 class="chart-title">My Performance</h3><div class="chart-container"><canvas id="officerChart"></canvas></div></div>
                    <div class="card"><h3 class="chart-title">Restock Requests</h3><div class="chart-container"><canvas id="restockChart"></canvas></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card">
                        <h3 class="chart-title">Current Stock Levels (All Items)</h3>
                        <div class="chart-container"><canvas id="allItemsChart"></canvas></div>
                    </div>
                    <div class="card announcement-card">
                        <h3 class="chart-title"><i class="fas fa-bullhorn" style="color:#4A7BA7;"></i> Announcements</h3>
                        <div class="msg-list">
                             <% for(String msg : messages) { %>
                             <div class="msg-item"><p class="msg-text"><%= msg %></p></div>
                             <% } %>
                        </div>
                    </div>
                </div>

             <%-- ========================== LOGISTIC STAFF ========================== --%>
             <% } else if(role.equals("logistic staff")) { %>
                <div class="dashboard-grid-3">
                    <div class="card summary-card alert"><div class="summary-label">Critical Low Stock</div><div class="summary-value"><%= lowStock %></div></div>
                    <div class="card summary-card"><div class="summary-label">Incoming Items</div><div class="summary-value">8</div></div>
                    
                    <a href="distributionCenter" class="card-link">
                        <div class="card summary-card warning">
                            <div class="summary-label">Pending Distribution</div>
                            <div class="summary-value"><% int logisticPendingDist = new InventoryDAO().getApprovedRequests().size(); %></div>
                        </div>
                    </a>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card"><h3 class="chart-title">Inventory by Category</h3><div class="chart-container"><canvas id="inventoryChart"></canvas></div></div>
                    <div class="card"><h3 class="chart-title">Current Stock Levels (All Items)</h3><div class="chart-container"><canvas id="allItemsChart"></canvas></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card announcement-card" style="grid-column: span 2;">
                        <h3 class="chart-title"><i class="fas fa-bullhorn" style="color:#4A7BA7;"></i> Announcements</h3>
                        <div class="msg-list">
                             <% for(String msg : messages) { %>
                             <div class="msg-item"><p class="msg-text"><%= msg %></p></div>
                             <% } %>
                        </div>
                    </div>
                </div>

             <%-- ========================== HQ MANAGER ========================== --%>
             <% } else if(role.equals("manager")) { %>
                <div class="dashboard-grid-2">
                    <div class="card summary-card purple"><div class="summary-label">Total Admitted Evacuees</div><div class="summary-value"><%= totalBen %></div></div>
                    <div class="card summary-card success"><div class="summary-label">Total Active Shelters</div><div class="summary-value"><%= activeSheltersCount %></div></div>
                </div>

                <div class="dashboard-grid-2">
                    <div class="card">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                            <h3 class="chart-title" style="margin:0;">Victim Registration Trend</h3>
                            <% String selectedTrend = (String) request.getAttribute("selectedTrendShelter"); %>
                            <form id="trendFormMan" method="GET" action="DashboardServlet">
                                <select name="trendShelter" onchange="document.getElementById('trendFormMan').submit()" style="padding: 5px; border-radius: 4px; border: 1px solid #ccc; font-size: 12px; cursor: pointer;">
                                    <option value="All" <%= "All".equals(selectedTrend) ? "selected" : "" %>>Global (All Shelters)</option>
                                    <% 
                                       List<Shelter> allS = (List<Shelter>) request.getAttribute("allShelters");
                                       if(allS != null) {
                                           for(Shelter s : allS) { 
                                               if("Active".equalsIgnoreCase(s.getStatus())) { 
                                    %>
                                        <option value="<%= s.getShelterID() %>" <%= s.getShelterID().equals(selectedTrend) ? "selected" : "" %>><%= s.getShelterName() %></option>
                                    <% } } } %>
                                </select>
                            </form>
                        </div>
                        <div class="chart-container"><canvas id="trendChart"></canvas></div>
                    </div>

                    <div class="card">
                        <h3 class="chart-title"><i class="fas fa-home" style="color:#0b5ea8;"></i> Current Active Relief Centers</h3>
                        <div style="overflow-y: auto; max-height: 250px;">
                            <table class="user-table" style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                                <thead>
                                    <tr style="border-bottom: 2px solid #e2e8f0;">
                                        <th style="padding: 10px; text-align: left; font-size: 12px; color: #6b7280; position: sticky; top: 0; background: white;">Shelter Name</th>
                                        <th style="padding: 10px; text-align: center; font-size: 12px; color: #6b7280; position: sticky; top: 0; background: white;">Admitted Victims</th>
                                        <th style="padding: 10px; text-align: center; font-size: 12px; color: #6b7280; position: sticky; top: 0; background: white;">Capacity Used</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                       List<Map<String, Object>> activeSum = (List<Map<String, Object>>) request.getAttribute("activeSheltersSummary");
                                       if(activeSum != null && !activeSum.isEmpty()) {
                                           for(Map<String, Object> map : activeSum) { 
                                               int combined = (Integer) map.get("combinedTotal");
                                               int cap = (Integer) map.get("capacity");
                                    %>
                                    <tr style="border-bottom: 1px solid #f3f4f6;">
                                        <td style="padding: 12px; font-weight: 600;"><%= map.get("shelterName") %></td>
                                        <td style="padding: 12px; text-align: center;"><%= combined %></td>
                                        <td style="padding: 12px; text-align: center;">
                                            <% int p = (cap > 0) ? (combined * 100 / cap) : 0; %>
                                            <div style="background: #e2e8f0; height: 8px; border-radius: 4px; width: 100px; display: inline-block;">
                                                <div style="background: <%= p > 90 ? "#ef4444" : "#10b981" %>; height: 100%; width: <%= Math.min(p, 100) %>%; border-radius: 4px;"></div>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } } else { %>
                                        <tr><td colspan="3" style="text-align:center; padding:20px; color:#94a3b8;">No active shelters currently.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

             <%-- ========================== FIELD OFFICER ========================== --%>
             <% } else if(role.equals("field officer")) { %>
                <div class="dashboard-grid-3">
                    <div class="card summary-card success"><div class="summary-label">My Requests</div><div class="summary-value"><%= myTotalReq %></div></div>
                    <a href="listRequest?status=Pending" class="card-link"><div class="card summary-card warning"><div class="summary-label">Pending Requests</div><div class="summary-value"><%= myPendingReq %></div></div></a>
                    <div class="card summary-card"><div class="summary-label">Total Admitted</div><div class="summary-value"><%= totalBen %></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                            <h3 class="chart-title" style="margin:0;">Victim Registration Trend</h3>
                        </div>
                        <div class="chart-container"><canvas id="trendChart"></canvas></div>
                    </div>
                    <div class="card"><h3 class="chart-title">Beneficiary Status Overview</h3><div class="chart-container"><canvas id="statusChart"></canvas></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card announcement-card">
                        <h3 class="chart-title"><i class="fas fa-clock" style="color:#f59e0b;"></i> My Pending Requests</h3>
                        <div class="msg-list" style="max-height:200px; overflow-y:auto;">
                            <% for(AidRequest req : myPendingList) { %>
                            <div class="msg-item"><p class="msg-text"><strong>ID:</strong> <%= req.getRequestID() %> <span style="color:#666;">(Pending)</span></p><div class="msg-time"><%= req.getArDateSubmitted() %></div></div>
                            <% } %>
                        </div>
                    </div>
                    <div class="card announcement-card">
                        <h3 class="chart-title"><i class="fas fa-bullhorn" style="color:#4A7BA7;"></i> Announcements</h3>
                        <div class="msg-list">
                             <% for(String msg : messages) { %>
                             <div class="msg-item"><p class="msg-text"><%= msg %></p></div>
                             <% } %>
                        </div>
                    </div>
                </div>

             <%-- ========================== ADMIN ========================== --%>
             <% } else { %>
                <div class="dashboard-grid-3">
                    <div class="card summary-card"><div class="summary-label">Total Admitted Evacuees</div><div class="summary-value"><%= totalBen %></div></div>
                    <a href="listRequest?status=Pending" class="card-link"><div class="card summary-card warning"><div class="summary-label">Pending Requests</div><div class="summary-value"><%= pendingReq %></div></div></a>
                    <div class="card summary-card alert"><div class="summary-label">Low Stock Alerts</div><div class="summary-value"><%= lowStock %></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                            <h3 class="chart-title" style="margin:0;">Victim Registration Trend</h3>
                            <% String selectedTrend = (String) request.getAttribute("selectedTrendShelter"); %>
                            <form id="trendFormAdmin" method="GET" action="DashboardServlet">
                                <select name="trendShelter" onchange="document.getElementById('trendFormAdmin').submit()" style="padding: 5px; border-radius: 4px; border: 1px solid #ccc; font-size: 12px; cursor: pointer;">
                                    <option value="All" <%= "All".equals(selectedTrend) ? "selected" : "" %>>Global (All Shelters)</option>
                                    <% 
                                       List<Shelter> allS = (List<Shelter>) request.getAttribute("allShelters");
                                       if(allS != null) {
                                           for(Shelter s : allS) { 
                                               if("Active".equalsIgnoreCase(s.getStatus())) { 
                                    %>
                                        <option value="<%= s.getShelterID() %>" <%= s.getShelterID().equals(selectedTrend) ? "selected" : "" %>><%= s.getShelterName() %></option>
                                    <% } } } %>
                                </select>
                            </form>
                        </div>
                        <div class="chart-container"><canvas id="trendChart"></canvas></div>
                    </div>
                    <div class="card"><h3 class="chart-title">Beneficiary Status Overview</h3><div class="chart-container"><canvas id="statusChart"></canvas></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card">
                        <h3 class="chart-title">Current Stock Levels (All Items)</h3>
                        <div class="chart-container"><canvas id="allItemsChart"></canvas></div>
                    </div>
                    <div class="card announcement-card">
                        <h3 class="chart-title"><i class="fas fa-bullhorn" style="color:#4A7BA7;"></i> Announcements</h3>
                        <div class="msg-list">
                             <% for(String msg : messages) { %>
                             <div class="msg-item"><p class="msg-text"><%= msg %></p></div>
                             <% } %>
                        </div>
                    </div>
                </div>
             <% } %>

        </div>
    </main>

    <script>
        Chart.defaults.font.family = "'Segoe UI', sans-serif";
        const userRole = "<%= role %>";

        // =========================================
        // 1. APPROVAL OFFICER CHARTS
        // =========================================
        <% if (role.equals("approval officer")) { %>
            
            // --- My Performance Chart ---
            var myAppCount = <%= myApp %>;
            var myRejCount = <%= myRej %>;
            
            var offLabels = ['Approved', 'Rejected'];
            var offData = [myAppCount, myRejCount];
            var offColors = ['#10b981', '#ef4444'];

            // Fallback if there is 0 data
            if (myAppCount === 0 && myRejCount === 0) {
                offLabels = ['No Reviews Yet'];
                offData = [1];
                offColors = ['#e2e8f0']; // Light gray placeholder
            }

            if(document.getElementById('officerChart')) {
                new Chart(document.getElementById('officerChart'), {
                    type: 'doughnut',
                    data: { labels: offLabels, datasets: [{ data: offData, backgroundColor: offColors, borderWidth:0 }] },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }
            
            // --- Restock Requests Chart ---
            var rApp = <%= restockApp %>;
            var rPen = <%= restockPen %>;
            var rRej = <%= restockRej %>;
            
            var resLabels = ['Approved / Completed', 'Pending', 'Rejected'];
            var resData = [rApp, rPen, rRej];
            var resColors = ['#10b981', '#f59e0b', '#ef4444'];

            // Fallback if there is 0 data
            if (rApp === 0 && rPen === 0 && rRej === 0) {
                resLabels = ['No Restocks Yet'];
                resData = [1];
                resColors = ['#e2e8f0']; // Light gray placeholder
            }

            if(document.getElementById('restockChart')) {
                new Chart(document.getElementById('restockChart'), {
                    type: 'doughnut',
                    data: { labels: resLabels, datasets: [{ data: resData, backgroundColor: resColors, borderWidth:0 }] },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }
        <% } %>

        // =========================================
        // 2. INVENTORY CHART (Admin, Approval, Logistic)
        // =========================================
        <% 
           List<Object> invLab = (List<Object>) request.getAttribute("invLabelsList");
           if (invLab != null && !invLab.isEmpty()) { 
               List<Object> invDat = (List<Object>) request.getAttribute("invDataList");
        %>
            var catLabels = [<% for(int i=0; i<invLab.size(); i++) { %>"<%= invLab.get(i) %>"<%= (i < invLab.size()-1) ? "," : "" %><% } %>];
            var catData = [<% for(int i=0; i<invDat.size(); i++) { %><%= invDat.get(i) %><%= (i < invDat.size()-1) ? "," : "" %><% } %>];

            if(document.getElementById('inventoryChart')) {
                new Chart(document.getElementById('inventoryChart'), {
                    type: 'bar',
                    data: { labels: catLabels, datasets: [{ label: 'Stock', data: catData, backgroundColor: '#4A7BA7' }] },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }
        <% } %>

        // =========================================
        // 3. ALL ITEMS CHART
        // =========================================
        <% 
           List<Object> allNames = (List<Object>) request.getAttribute("allItemsNames");
           if (allNames != null && !allNames.isEmpty()) { 
               List<Object> allQty = (List<Object>) request.getAttribute("allItemsQty");
        %>
            var allItemLabels = [<% for(int i=0; i<allNames.size(); i++) { %>"<%= allNames.get(i) %>"<%= (i < allNames.size()-1) ? "," : "" %><% } %>];
            var allItemData = [<% for(int i=0; i<allQty.size(); i++) { %><%= allQty.get(i) %><%= (i < allQty.size()-1) ? "," : "" %><% } %>];

            if(document.getElementById('allItemsChart')) {
                new Chart(document.getElementById('allItemsChart'), {
                    type: 'bar',
                    data: { labels: allItemLabels, datasets: [{ label: 'Qty', data: allItemData, backgroundColor: '#f59e0b' }] },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }
        <% } %>

        // =========================================
        // 4. TREND GRAPH (Admin, Field, Manager)
        // =========================================
        <% if (role.equals("admin") || role.equals("field officer") || role.equals("manager")) { 
               List<Object> tLab = (List<Object>) request.getAttribute("trendLabelsList");
               List<Object> tDat = (List<Object>) request.getAttribute("trendDataList");
               if(tLab != null && !tLab.isEmpty()) {
        %>
            var trendLabels = [<% for(int i=0; i<tLab.size(); i++) { %>"<%= tLab.get(i) %>"<%= (i < tLab.size()-1) ? "," : "" %><% } %>];
            var trendData = [<% for(int i=0; i<tDat.size(); i++) { %><%= tDat.get(i) %><%= (i < tDat.size()-1) ? "," : "" %><% } %>];

            if(document.getElementById('trendChart')) {
                new Chart(document.getElementById('trendChart'), {
                    type: 'line',
                    data: { 
                        labels: trendLabels, 
                        datasets: [{ 
                            label: 'Victims (Bene + Household)', 
                            data: trendData, 
                            borderColor: '#2563eb', 
                            backgroundColor: 'rgba(37, 99, 235, 0.1)', 
                            tension: 0.3, 
                            fill: true,
                            pointRadius: 5, 
                            pointHoverRadius: 7
                        }] 
                    },
                    options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
                });
            }
        <% } %>
        <% } %>
        
        // =========================================
        // 5. STATUS PIE CHART (Admin, Field only)
        // =========================================
        <% if (role.equals("admin") || role.equals("field officer")) { %>
            var activeCount = <%= activeBen %>;
            var inactiveCount = <%= inactiveBen %>;
            
            var pieLabels = ['Active', 'Inactive'];
            var pieData = [activeCount, inactiveCount];
            var pieColors = ['#10b981', '#94a3b8'];

            if (activeCount === 0 && inactiveCount === 0) {
                pieLabels = ['No Data Yet'];
                pieData = [1];
                pieColors = ['#e2e8f0'];
            }

            if(document.getElementById('statusChart')) {
                new Chart(document.getElementById('statusChart'), {
                    type: 'pie',
                    data: { labels: pieLabels, datasets: [{ data: pieData, backgroundColor: pieColors, borderWidth: 1 }] },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }
        <% } %>
    </script>
</body>
</html>