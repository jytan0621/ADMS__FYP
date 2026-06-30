<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.Model.User, com.Model.Shelter" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null || (!"Admin".equalsIgnoreCase(u.getRole()) && !"Manager".equalsIgnoreCase(u.getRole()))) { 
        response.sendRedirect("index.jsp?error=UnauthorizedAccess"); return; 
    }
    List<Map<String, Object>> distributions = (List<Map<String, Object>>) request.getAttribute("reportDistribution");
    boolean promptSelect = request.getAttribute("promptSelect") != null && (Boolean) request.getAttribute("promptSelect");
    
    String currentType = (String) request.getAttribute("filterType");
    String currentTime = (String) request.getAttribute("filterTime");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String selectedShelter = (String) request.getAttribute("filterShelter");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Distribution Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* ========================================= */
        /* PRINT STYLES - Only applied during printing */
        /* ========================================= */
        @media print {
            /* Hide Sidebar, Header, Filters, and Toolbars */
            .fixed-header, 
            .sidebar-container, 
            .toolbar, 
            .page-header,
            .filter-container,
            .prompt-box {
                display: none !important;
            }

            body { background-color: white !important; }
            
            .main-content {
                position: static !important;
                margin: 0 !important;
                padding: 0 !important;
                left: 0 !important;
                top: 0 !important;
                overflow: visible !important;
            }

            .card {
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
                margin: 0 !important;
            }

            .card::before {
                content: "Distribution Report";
                display: block;
                font-size: 22px;
                font-weight: bold;
                text-align: center;
                margin-bottom: 20px;
                color: black;
            }

            table { width: 100% !important; }
            tr { page-break-inside: avoid; }
        }
        
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .page-header { margin-bottom: 24px; }
        .filter-container { background: white; padding: 16px 20px; border-radius: 8px; border: 1px solid #e2e8f0; }
        .filter-row { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; margin-bottom: 12px; }
        .filter-group { display: flex; align-items: center; gap: 8px; }
        .filter-label { font-size: 13px; font-weight: 600; color: #64748b; text-transform: uppercase; }
        .filter-input { padding: 8px 12px; border-radius: 4px; border: 1px solid #cbd5e1; font-size: 13px; }
        .action-buttons { display: flex; gap: 10px; margin-left: auto; }
        .btn { border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: bold; cursor: pointer; color: white; }
        .btn-filter { background-color: #0b5ea8; }
        .btn-export { background-color: #10b981; }
        .btn-print { background-color: #475569; }
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; margin-top: 20px;}
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px; background: #f1f5f9; color: #475569; font-size: 13px; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }
        .badge-in { background: #dcfce7; color: #166534; }
        .badge-out { background: #fee2e2; color: #991b1b; }
        .prompt-box { text-align: center; padding: 60px; color: #64748b; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="page-header">
            <h2 style="margin:0 0 16px 0; color: #1e293b;"><i class="fas fa-hand-holding-heart" style="color:#0b5ea8;"></i> Distribution Report</h2>
            <form action="reportDistribution" method="GET" class="filter-container">
                <div class="filter-row">
                    <% if ("Manager".equalsIgnoreCase(u.getRole())) { %>
                    <div class="filter-group">
                        <span class="filter-label">SHELTER:</span>
                        <select name="filterShelter" class="filter-input" required>
                            <option value="" disabled <%= promptSelect ? "selected" : "" %>>-- Select Shelter --</option>
                            <% List<Shelter> allS = (List<Shelter>) request.getAttribute("allShelters");
                               if(allS != null) { for(Shelter s : allS) { %>
                                <option value="<%= s.getShelterID() %>" <%= s.getShelterID().equals(selectedShelter) ? "selected" : "" %>><%= s.getShelterName() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <% } %>
                    <div class="filter-group">
                        <span class="filter-label">Flow:</span>
                        <select name="filterType" class="filter-input">
                            <option value="ALL" <%= "ALL".equals(currentType) ? "selected" : "" %>>All</option>
                            <option value="INCOMING" <%= "INCOMING".equals(currentType) ? "selected" : "" %>>Incoming</option>
                            <option value="OUTGOING" <%= "OUTGOING".equals(currentType) ? "selected" : "" %>>Outgoing</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <span class="filter-label">Group:</span>
                        <select name="filterTime" class="filter-input">
                            <option value="DAILY" <%= "DAILY".equals(currentTime) ? "selected" : "" %>>Daily</option>
                            <option value="WEEKLY" <%= "WEEKLY".equals(currentTime) ? "selected" : "" %>>Weekly</option>
                        </select>
                    </div>
                    <div class="action-buttons">
                        <button type="button" class="btn btn-export" onclick="exportCSV()"><i class="fas fa-file-excel"></i> Export</button>
                        <button type="button" class="btn btn-print" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>
                <div class="filter-row" style="margin-bottom:0; padding-top:12px; border-top:1px solid #f1f5f9;">
                    <div class="filter-group"><span class="filter-label">From:</span><input type="date" name="startDate" class="filter-input" value="<%= startDate != null ? startDate : "" %>"></div>
                    <div class="filter-group"><span class="filter-label">To:</span><input type="date" name="endDate" class="filter-input" value="<%= endDate != null ? endDate : "" %>"></div>
                    <div class="action-buttons"><button type="submit" class="btn btn-filter"><i class="fas fa-search"></i> Apply Filter</button></div>
                </div>
            </form>
        </div>

        <div class="card">
            <% if (promptSelect) { %>
                <div class="prompt-box">
                    <i class="fas fa-hand-pointer" style="font-size: 40px; margin-bottom: 15px; color:#cbd5e1;"></i>
                    <h3>Awaiting Selection</h3>
                    <p>Please select a shelter and apply the filter to view the distribution log.</p>
                </div>
            <% } else { %>
            <table id="target-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No.</th>
                        <th>Date / Period</th>
                        <th>Flow Direction</th>
                        <th>Item Name</th>
                        <th style="text-align:right;">Total Quantity</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                       if(distributions != null && !distributions.isEmpty()) { 
                        int count = 1;
                        for(Map<String, Object> row : distributions) { 
                            String type = row.get("entryType") != null ? row.get("entryType").toString() : "OUTGOING";
                    %>
                    <tr>
                        <td style="font-weight: bold; color: #64748b;"><%= count++ %></td>
                        <td style="font-weight: bold;"><%= row.get("date") %></td>
                        <td><span class="badge <%= "INCOMING".equals(type) ? "badge-in" : "badge-out" %>"><%= type %></span></td>
                        <td style="font-weight: 500;"><%= row.get("itemName") %></td>
                        <td style="text-align:right; font-weight:bold; color:#0b5ea8;"><%= row.get("totalQty") %></td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="5" style="text-align:center; padding:30px;">No records found.</td></tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
</body>
<script>
        function exportCSV() {
            var table = document.getElementById("target-table");
            if (!table) {
                alert("Please select a shelter and load the data before exporting.");
                return;
            }
            var rows = table.querySelectorAll("tr");
            var csv = [];
            for (var i = 0; i < rows.length; i++) {
                var row = [], cols = rows[i].querySelectorAll("td, th");
                for (var j = 0; j < cols.length; j++) {
                    var data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                    data = data.replace(/"/g, '""');
                    row.push('"' + data + '"');
                }
                csv.push(row.join(","));
            }
            var csvString = csv.join("\n");
            var filename = "Distribution_Report.csv";
            var blob = new Blob([csvString], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            if (link.download !== undefined) {
                var url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", filename);
                link.style.visibility = 'hidden';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
</script>
</html>