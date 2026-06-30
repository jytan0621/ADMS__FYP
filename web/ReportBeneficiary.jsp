<%-- 
    Document   : ReportBeneficiary
    Created on : May 26, 2026, 9:16:25 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.User, com.Model.Beneficiary, com.Model.Household, com.Model.Shelter" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null || (!"Admin".equalsIgnoreCase(u.getRole()) && !"Manager".equalsIgnoreCase(u.getRole()))) { 
        response.sendRedirect("index.jsp?error=UnauthorizedAccess"); return; 
    }
    List<Beneficiary> beneficiaries = (List<Beneficiary>) request.getAttribute("reportBeneficiaries");
    boolean promptSelect = request.getAttribute("promptSelect") != null && (Boolean) request.getAttribute("promptSelect");
    String selectedShelter = (String) request.getAttribute("filterShelter");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Active Beneficiary Registry</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* ========================================= */
        /* PRINT STYLES - Only applied during printing */
        /* ========================================= */
        @media print {
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
                content: "Active Beneficiary Registry Report";
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
        .toolbar { margin-bottom: 24px; }
        .filter-container { background: white; padding: 16px 20px; border-radius: 8px; border: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .filter-group { display: flex; align-items: center; gap: 8px; }
        .filter-input { padding: 8px 12px; border-radius: 4px; border: 1px solid #cbd5e1; outline: none; font-size: 13px; font-weight: 500; }
        .btn-action { padding: 8px 18px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 13px; text-decoration: none; color: white;}
        .btn-filter { background-color: #0b5ea8; }
        .btn-export { background-color: #10b981; }
        .btn-print { background-color: #475569; }
        .card { background: white; border-radius: 8px; padding: 24px; border: 1px solid #e2e8f0; margin-top:20px; }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px; background: #f8fafc; color: #64748b; font-size: 12px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        .badge-head { background: #e0f2fe; color: #0369a1; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-member { background: #f1f5f9; color: #475569; padding: 4px 8px; border-radius: 4px; font-size: 11px; }
        .prompt-box { text-align: center; padding: 60px; color: #64748b; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="toolbar">
            <h2 style="margin:0 0 16px 0; color: #1e293b;"><i class="fas fa-users" style="color:#0b5ea8;"></i> Beneficiary Registry</h2>
            <form action="reportBeneficiary" method="GET" class="filter-container">
                <% if ("Manager".equalsIgnoreCase(u.getRole())) { %>
                <div class="filter-group">
                    <span style="font-size:13px; font-weight:bold; color:#64748b;">TARGET SHELTER:</span>
                    <select name="filterShelter" class="filter-input" required>
                        <option value="" disabled <%= promptSelect ? "selected" : "" %>>-- Choose a Relief Center --</option>
                        <% List<Shelter> allS = (List<Shelter>) request.getAttribute("allShelters");
                           if(allS != null) { for(Shelter s : allS) { %>
                            <option value="<%= s.getShelterID() %>" <%= s.getShelterID().equals(selectedShelter) ? "selected" : "" %>><%= s.getShelterName() %></option>
                        <% } } %>
                    </select>
                    <button type="submit" class="btn-action btn-filter"><i class="fas fa-search"></i> Load Data</button>
                </div>
                <% } else { %>
                    <div style="font-weight:bold; color:#0b5ea8;">Shelter Region: <%= u.getAssignedRegion() %></div>
                <% } %>
                <div style="display:flex; gap:10px;">
                    <button type="button" class="btn-action btn-export" onclick="exportCSV()"><i class="fas fa-file-excel"></i> Export</button>
                    <button type="button" class="btn-action btn-print" onclick="window.print()"><i class="fas fa-print"></i> Print</button>
                </div>
            </form>
        </div>

        <div class="card">
            <% if (promptSelect) { %>
                <div class="prompt-box">
                    <i class="fas fa-hand-pointer" style="font-size: 40px; margin-bottom: 15px; color:#cbd5e1;"></i>
                    <h3>Awaiting Selection</h3>
                    <p>Please select a shelter from the dropdown above to generate the registry.</p>
                </div>
            <% } else { %>
            <table id="target-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No.</th>
                        <th>Full Name</th>
                        <th>IC Number</th>
                        <th>Relationship</th>
                        <th>Contact</th>
                        <th>Tent ID</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(beneficiaries != null && !beneficiaries.isEmpty()) { 
                        int count = 1;
                        for(Beneficiary b : beneficiaries) { 
                            List<Household> dependents = (List<Household>) request.getAttribute("household_" + b.getBeneficiaryID());
                    %>
                    <tr style="border-top: 2px solid #e2e8f0;">
                        <td style="font-weight: bold; color: #0b5ea8;"><%= count++ %></td>
                        <td style="font-weight: 600;"><%= b.getB_Name() %></td>
                        <td><%= b.getB_ICNumber() %></td>
                        <td><span class="badge-head">Head of Family</span></td>
                        <td><%= b.getB_ContactNumber() %></td>
                        <td style="font-family: monospace; font-weight: bold;"><%= b.getTentID() %></td>
                    </tr>
                    <% if(dependents != null && !dependents.isEmpty()) { for(Household h : dependents) { %>
                    <tr style="background-color: #f8fafc;">
                        <td style="color: #94a3b8; text-align: right;"><i class="fas fa-level-up-alt fa-rotate-90"></i></td>
                        <td style="color: #475569; padding-left: 20px;"><%= h.getH_Name() %></td>
                        <td style="color: #475569;"><%= h.getH_IC() %></td>
                        <td><span class="badge-member"><%= h.getH_Relationship() %></span></td>
                        <td style="color: #94a3b8;">Shared Contact</td>
                        <td style="font-family: monospace; color: #475569;"><%= h.getTentID() != null ? h.getTentID() : b.getTentID() %></td>
                    </tr>
                    <% } } } } else { %>
                    <tr><td colspan="6" style="text-align:center; padding:30px;">No active family records found for this shelter.</td></tr>
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
            var filename = "Beneficiary_Registry_Report.csv";
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