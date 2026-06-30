<%-- 
    Document   : ReportArchiveDetail
    Created on : Jun 12, 2026, 4:48:58 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null || !"Manager".equalsIgnoreCase(u.getRole())) { 
        response.sendRedirect("index.jsp?error=UnauthorizedAccess"); 
        return; 
    }
    
    List<Map<String, String>> victims = (List<Map<String, String>>) request.getAttribute("victimsList");
    String sName = (String) request.getAttribute("arcShelterName");
    String startDate = (String) request.getAttribute("arcStart");
    String endDate = (String) request.getAttribute("arcEnd");
    int totalVictims = (victims != null) ? victims.size() : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Historical Victim List</title>
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
                content: "Historical Victim Roster";
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
        
        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; background: white; padding: 16px 24px; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        
        .summary-banner { background: linear-gradient(to right, #ea580c, #f97316); color: white; padding: 20px; border-radius: 8px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 6px rgba(ea, 88, 12, 0.2); }
        .summary-stat h3 { margin: 0 0 5px 0; font-size: 14px; text-transform: uppercase; opacity: 0.9; }
        .summary-stat p { margin: 0; font-size: 24px; font-weight: bold; }
        
        .card { background: white; border-radius: 8px; padding: 24px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px; background: #f8fafc; color: #64748b; font-size: 12px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        
        .badge-head { background: #e0f2fe; color: #0369a1; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-member { background: #f1f5f9; color: #475569; padding: 4px 8px; border-radius: 4px; font-size: 11px; }
        
        .btn-back { background-color: #f1f5f9; color: #475569; padding: 8px 16px; border-radius: 4px; font-weight: bold; text-decoration: none; border: 1px solid #cbd5e1; }
        .btn-back:hover { background-color: #e2e8f0; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="toolbar">
            <h2 style="margin:0; color: #1e293b;"><i class="fas fa-list-ol" style="color:#0b5ea8; margin-right: 8px;"></i> Historical Victim Roster</h2>
            <div>
                <button type="button" class="btn-back" style="margin-right:10px;" onclick="window.print()"><i class="fas fa-print"></i> Print Report</button>
                <a href="reportArchive" class="btn-back"><i class="fas fa-arrow-left"></i> Back to Archive</a>
            </div>
        </div>
        
        <div class="summary-banner">
            <div class="summary-stat">
                <h3>Relief Center</h3>
                <p><i class="fas fa-home"></i> <%= sName != null ? sName : "Unknown" %></p>
            </div>
            <div class="summary-stat">
                <h3>Operational Period</h3>
                <p><i class="far fa-calendar-alt"></i> <%= startDate %> to <%= endDate %></p>
            </div>
            <div class="summary-stat">
                <h3>Total Victims Admitted</h3>
                <p><i class="fas fa-users"></i> <%= totalVictims %> People</p>
            </div>
        </div>

        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 50px;">No.</th>
                        <th>Full Name</th>
                        <th>Identification (IC)</th>
                        <th>Family Role</th>
                        <th>Registration Timestamp</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(victims != null && !victims.isEmpty()) { 
                        int count = 1;
                        for(Map<String, String> v : victims) { 
                            boolean isHead = "Head of Family".equals(v.get("Role"));
                    %>
                    <tr>
                        <td style="color: #94a3b8; font-weight: bold;"><%= count++ %></td>
                        <td style="font-weight: <%= isHead ? "bold" : "normal" %>;"><%= v.get("FullName") %></td>
                        <td style="font-family: monospace;"><%= v.get("IC") %></td>
                        <td><span class="<%= isHead ? "badge-head" : "badge-member" %>"><%= v.get("Role") %></span></td>
                        <td style="color: #64748b;"><%= v.get("DateRegistered") %></td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="5" style="text-align:center; padding: 40px; color:#94a3b8;">No victims recorded during this operational period.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>