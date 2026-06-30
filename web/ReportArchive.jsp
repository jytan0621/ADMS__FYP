<%-- 
    Document   : ReportArchive
    Created on : Jun 12, 2026, 4:23:51 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.Model.User, com.Model.Shelter" %>
<%
    User u = (User) session.getAttribute("currentUser");
    // STRICT MANAGER VALIDATION: Block Admins
    if (u == null || !"Manager".equalsIgnoreCase(u.getRole())) { 
        response.sendRedirect("index.jsp?error=UnauthorizedAccess"); 
        return; 
    }
    List<Map<String, Object>> archives = (List<Map<String, Object>>) request.getAttribute("archiveList");
    
    // Maintain Filter State
    String selectedShelter = (String) request.getAttribute("filterShelter");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Disaster Activation Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        
        .page-header { margin-bottom: 24px; }
        .page-header h2 { margin: 0 0 16px 0; color: #1e293b; }
        
        /* Filter Container Styles */
        .filter-container { background: white; padding: 16px 20px; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; }
        .filter-row { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
        .filter-row.bottom { margin-top: 12px; padding-top: 12px; border-top: 1px solid #f1f5f9; }
        .filter-group { display: flex; align-items: center; gap: 8px; }
        .filter-label { font-size: 13px; font-weight: 600; color: #64748b; text-transform: uppercase; }
        .filter-input { padding: 8px 12px; border-radius: 4px; border: 1px solid #cbd5e1; outline: none; font-size: 13px; color: #334155; font-weight: 500; background-color: #f8fafc; }
        .filter-input:focus { border-color: #0b5ea8; background-color: white; }
        
        .action-buttons { display: flex; gap: 10px; margin-left: auto; }
        .btn-filter { background-color: #ea580c; color: white; border: none; padding: 8px 18px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-filter:hover { background-color: #c2410c; }
        .btn-clear { background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 7px 16px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; display: flex; align-items: center; gap: 6px;}
        .btn-clear:hover { background-color: #e2e8f0; }
        
        .btn-export { background-color: #10b981; color: white; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;}
        .btn-print { background-color: #475569; color: white; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;}

        .card { background: white; border-radius: 8px; padding: 24px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-top: 20px;}
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px; background: #f8fafc; color: #64748b; font-size: 12px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        
        @media print {
            @page { size: auto; margin: 20mm 15mm; }
            body, .main-content { background-color: #ffffff; height: auto; overflow: visible; position: static; width: 100%; }
            .fixed-header, .sidebar-container, .page-header { display: none !important; }
            .card { border: none; box-shadow: none; padding: 0; margin: 0 auto; width: 100%; }
            table { width: 100%; margin: 0 auto; }
            th { background-color: #f1f5f9 !important; color: #475569 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="page-header">
            <h2><i class="fas fa-file-archive" style="color:#ea580c; margin-right: 8px;"></i> Disaster Activation Archive</h2>
            
            <form action="reportArchive" method="GET" class="filter-container">
                <div class="filter-row">
                    <div class="filter-group">
                        <span class="filter-label">Filter by Shelter:</span>
                        <select name="filterShelter" class="filter-input">
                            <option value="All" <%= "All".equals(selectedShelter) ? "selected" : "" %>>All Shelters Database</option>
                            <% 
                               List<Shelter> allS = (List<Shelter>) request.getAttribute("allShelters");
                               if(allS != null) {
                                   for(Shelter s : allS) { 
                            %>
                                <option value="<%= s.getShelterID() %>" <%= s.getShelterID().equals(selectedShelter) ? "selected" : "" %>><%= s.getShelterName() %></option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="action-buttons">
                        <button type="button" class="btn-export" onclick="exportCSV()"><i class="fas fa-file-excel"></i> Export CSV</button>
                        <button type="button" class="btn-print" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
                    </div>
                </div>
                
                <div class="filter-row bottom">
                    <div class="filter-group">
                        <span class="filter-label"><i class="far fa-calendar-alt"></i> Activation From:</span>
                        <input type="date" name="startDate" class="filter-input" value="<%= startDate != null ? startDate : "" %>">
                    </div>
                    <div class="filter-group" style="margin-left: 20px;">
                        <span class="filter-label"><i class="far fa-calendar-alt"></i> Deactivation To:</span>
                        <input type="date" name="endDate" class="filter-input" value="<%= endDate != null ? endDate : "" %>">
                    </div>
                    
                    <div class="action-buttons">
                        <a href="reportArchive" class="btn-clear"><i class="fas fa-times"></i> Clear Filter</a>
                        <button type="submit" class="btn-filter"><i class="fas fa-search"></i> Apply Filter</button>
                    </div>
                </div>
            </form>
        </div>

        <div class="card">
            <table id="target-table">
                <thead>
                    <tr>
                        <th>Archive ID</th>
                        <th>Shelter Name</th>
                        <th>Activation Date</th>
                        <th>Deactivation Date</th>
                        <th>Total Operational Days</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(archives != null && !archives.isEmpty()) { 
                        for(Map<String, Object> arc : archives) { %>
                    <tr>
                        <td style="font-weight: bold; color: #0b5ea8;">#<%= arc.get("HistoryID") %></td>
                        <td style="font-weight: 600;"><%= arc.get("ShelterName") %></td>
                        <td><%= arc.get("ActivationDate") %></td>
                        <td><%= arc.get("DeactivationDate") %></td>
                        <td><span style="background: #f1f5f9; padding: 4px 8px; border-radius: 4px; font-weight:bold; color: #ea580c;"><%= arc.get("DaysActive") %> Days</span></td>
                        
                        <td style="text-align: right;">
                            <a href="reportArchiveDetail?sId=<%= arc.get("ShelterID") %>&sName=<%= arc.get("ShelterName") %>&start=<%= arc.get("ActivationDate") %>&end=<%= arc.get("DeactivationDate") %>" 
                               style="background-color: #0b5ea8; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 12px; font-weight: bold;">
                               View Victim List <i class="fas fa-arrow-right" style="margin-left: 5px;"></i>
                            </a>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="6" style="text-align:center; padding: 50px; color: #94a3b8;">
                            <i class="fas fa-folder-open" style="font-size: 24px; margin-bottom: 10px; display: block;"></i>
                            No historical shelter records found matching your filters.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        function exportCSV() {
            const table = document.getElementById("target-table");
            if(!table) return;

            let csv = [];
            const rows = table.querySelectorAll("tr");
            for (let i = 0; i < rows.length; i++) {
                const row = [], cols = rows[i].querySelectorAll("td, th");
                // Don't include the 'Action' column in the CSV export
                const length = i === 0 ? cols.length - 1 : cols.length - 1; 
                for (let j = 0; j < length; j++) {
                    let data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, "").replace(/(\s\s)/gm, " ");
                    data = data.replace(/"/g, '""');
                    row.push('"' + data + '"');
                }
                csv.push(row.join(','));
            }
            const blob = new Blob(['\uFEFF' + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.setAttribute("download", "ADMS_Disaster_Archive_Report_" + new Date().toISOString().slice(0,10) + ".csv");
            document.body.appendChild(link); 
            link.click(); 
            document.body.removeChild(link);
        }
    </script>
</body>
</html>