<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
    String role = user.getRole().toLowerCase().trim();
    String userRegion = user.getAssignedRegion();

    // Data
    Integer totalBen = (Integer) request.getAttribute("totalBen"); if(totalBen==null) totalBen=0;
    Integer pendingReq = (Integer) request.getAttribute("pendingReq"); if(pendingReq==null) pendingReq=0;
    Integer lowStock = (Integer) request.getAttribute("lowStock"); if(lowStock==null) lowStock=0;

    // Approval
    Integer myApp = (Integer) request.getAttribute("myApproved"); if(myApp==null) myApp=0;
    Integer myRej = (Integer) request.getAttribute("myRejected"); if(myRej==null) myRej=0;
    Integer queue = (Integer) request.getAttribute("globalQueue"); if(queue==null) queue=0;
    Integer processed = (Integer) request.getAttribute("myTotalProcessed"); if(processed==null) processed=0;
    Integer restockApp = (Integer) request.getAttribute("restockApproved"); if(restockApp==null) restockApp=0;
    Integer restockPen = (Integer) request.getAttribute("restockPending"); if(restockPen==null) restockPen=0;
    Integer restockRej = (Integer) request.getAttribute("restockRejected"); if(restockRej==null) restockRej=0;

    // Field
    Integer myTotalReq = (Integer) request.getAttribute("myTotalReq"); if(myTotalReq==null) myTotalReq=0;
    Integer myPendingReq = (Integer) request.getAttribute("myPendingReq"); if(myPendingReq==null) myPendingReq=0;
    
    // Lists
    List<AidRequest> myPendingList = (List<AidRequest>) request.getAttribute("myPendingList"); if(myPendingList==null) myPendingList=new ArrayList<>();
    List<AidRequest> globalPendingList = (List<AidRequest>) request.getAttribute("globalPendingList"); if(globalPendingList==null) globalPendingList=new ArrayList<>();
    
    // Status
    Integer activeBen = (Integer) request.getAttribute("activeBenCount"); if(activeBen==null) activeBen=0;
    Integer inactiveBen = (Integer) request.getAttribute("inactiveBenCount"); if(inactiveBen==null) inactiveBen=0;
    
    // Announcements (For Everyone)
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

    <header class="fixed-header">
        <div><img src="Image/Logo_ADMS.png" style="height:24px;"> <span style="font-weight:700; font-size:1.2rem;">ADMS</span></div>
        <div style="background:rgba(255,255,255,0.1); padding:5px 12px; border-radius:4px;"><%= user.getUserName() %> | <%= role.toUpperCase() %></div>
    </header>

    <main class="main-content-area">
        <div style="max-width: 1280px; margin: 0 auto;">
             
             <%-- TITLE --%>
             <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:30px;">
                 <div>
                     <h2 style="font-size:24px; font-weight:bold; margin:0; color:#1f2937;">Dashboard Overview</h2>
                     <p style="color:#6b7280; font-size:14px; margin:5px 0 0 0;">Welcome back, here is your <%= role %> summary.</p>
                 </div>
                 <% if (!"approval officer".equals(role) && !"admin".equals(role)) { %>
                    <a href="newRequest" class="btn-add"><i class="fas fa-plus"></i> New Request</a>
                 <% } %>
             </div>

             <%-- WEATHER --%>
             <div style="margin-bottom: 30px;">
                 <div class="card" style="background: linear-gradient(120deg, #2563eb 0%, #06b6d4 100%); color: white; border: none; border-radius: 16px; padding: 30px 40px; display: flex; flex-direction: row; justify-content: space-between; align-items: center;">
                     <div>
                         <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 5px;"><i class="fas fa-map-marker-alt"></i> <span style="font-weight: 500; text-transform: uppercase;"><%= userRegion %></span></div>
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

             <%-- CONTENT BY ROLE --%>
             
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
                    <div class="card summary-card"><div class="summary-label">Total Stock Items</div><div class="summary-value">450</div></div>
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

             <%-- ========================== FIELD OFFICER ========================== --%>
             <% } else if(role.equals("field officer")) { %>
                <div class="dashboard-grid-3">
                    <div class="card summary-card success"><div class="summary-label">My Requests</div><div class="summary-value"><%= myTotalReq %></div></div>
                    
                    <a href="listRequest?status=Pending" class="card-link">
                        <div class="card summary-card warning">
                            <div class="summary-label">Pending Requests (Click)</div>
                            <div class="summary-value"><%= myPendingReq %></div>
                        </div>
                    </a>

                    <div class="card summary-card"><div class="summary-label">Total Registered</div><div class="summary-value"><%= totalBen %></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card"><h3 class="chart-title">Daily Registration Trend</h3><div class="chart-container"><canvas id="trendChart"></canvas></div></div>
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
                    <div class="card summary-card"><div class="summary-label">Total Beneficiaries</div><div class="summary-value"><%= totalBen %></div></div>
                    
                    <a href="listRequest?status=Pending" class="card-link">
                        <div class="card summary-card warning">
                            <div class="summary-label">Pending Requests (Click)</div>
                            <div class="summary-value"><%= pendingReq %></div>
                        </div>
                    </a>

                    <div class="card summary-card alert"><div class="summary-label">Low Stock Alerts</div><div class="summary-value"><%= lowStock %></div></div>
                </div>
                <div class="dashboard-grid-2">
                    <div class="card"><h3 class="chart-title">Daily Registration Trend</h3><div class="chart-container"><canvas id="trendChart"></canvas></div></div>
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
            new Chart(document.getElementById('officerChart'), {
                type: 'doughnut',
                data: { labels: ['Approved', 'Rejected'], datasets: [{ data: [<%= myApp %>, <%= myRej %>], backgroundColor: ['#10b981', '#ef4444'], borderWidth:0 }] },
                options: { responsive: true, maintainAspectRatio: false }
            });
            new Chart(document.getElementById('restockChart'), {
                type: 'doughnut',
                data: { labels: ['Approved', 'Pending', 'Rejected'], datasets: [{ data: [<%= restockApp %>, <%= restockPen %>, <%= restockRej %>], backgroundColor: ['#10b981', '#f59e0b', '#ef4444'], borderWidth:0 }] },
                options: { responsive: true, maintainAspectRatio: false }
            });
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
        // 3. ALL ITEMS CHART (Replaces Top 5)
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
        // 4. TREND & STATUS (Admin, Field)
        // =========================================
        <% if (role.equals("admin") || role.equals("field officer")) { 
               List<Object> tLab = (List<Object>) request.getAttribute("trendLabelsList");
               List<Object> tDat = (List<Object>) request.getAttribute("trendDataList");
               if(tLab != null) {
        %>
            var trendLabels = [<% for(int i=0; i<tLab.size(); i++) { %>"<%= tLab.get(i) %>"<%= (i < tLab.size()-1) ? "," : "" %><% } %>];
            var trendData = [<% for(int i=0; i<tDat.size(); i++) { %><%= tDat.get(i) %><%= (i < tDat.size()-1) ? "," : "" %><% } %>];

            new Chart(document.getElementById('trendChart'), {
                type: 'line',
                data: { labels: trendLabels, datasets: [{ label: 'Registrations', data: trendData, borderColor: '#2563eb', backgroundColor: 'rgba(37, 99, 235, 0.1)', tension: 0.3, fill: true }] },
                options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true } } }
            });
        <% } %>

            new Chart(document.getElementById('statusChart'), {
                type: 'pie',
                data: { labels: ['Active', 'Inactive'], datasets: [{ data: [<%= activeBen %>, <%= inactiveBen %>], backgroundColor: ['#10b981', '#94a3b8'], borderWidth: 1 }] },
                options: { responsive: true, maintainAspectRatio: false }
            });
        <% } %>
    </script>
</body>
</html>