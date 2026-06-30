<%-- 
    Document   : ReportDashboard
    Created on : May 26, 2026, 9:25:31 PM
    Author     : User
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    // Updated Role Validation
    if (u == null || (!"Admin".equalsIgnoreCase(u.getRole()) && !"Manager".equalsIgnoreCase(u.getRole()))) { 
        response.sendRedirect("index.jsp?error=UnauthorizedAccess"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Reporting Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 40px; }
        
        .dashboard-header { margin-bottom: 30px; }
        .dashboard-header h2 { margin: 0 0 8px 0; color: #1e293b; font-size: 24px; }
        .dashboard-header p { margin: 0; color: #64748b; font-size: 15px; }

        .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 24px; }
        
        .report-card {
            background: white; border-radius: 10px; padding: 24px; border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); text-decoration: none; color: inherit;
            display: flex; flex-direction: column; align-items: flex-start;
            transition: all 0.3s ease; position: relative; overflow: hidden;
        }

        .report-card::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
            background-color: #0b5ea8; transform: scaleX(0); transition: transform 0.3s ease; transform-origin: left;
        }

        .report-card:hover { transform: translateY(-5px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); border-color: #cbd5e1; }
        .report-card:hover::before { transform: scaleX(1); }

        .icon-box { width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 22px; margin-bottom: 16px; }

        .icon-blue { background: #e0f2fe; color: #0284c7; }
        .icon-green { background: #dcfce7; color: #16a34a; }
        .icon-purple { background: #f3e8ff; color: #9333ea; }
        .icon-orange { background: #ffedd5; color: #ea580c; } /* New color for archive */

        .report-card h3 { margin: 0 0 8px 0; color: #0f172a; font-size: 18px; }
        .report-card p { margin: 0; color: #64748b; font-size: 14px; line-height: 1.5; flex-grow: 1; }
        
        .card-footer { margin-top: 20px; display: flex; align-items: center; color: #0b5ea8; font-weight: 600; font-size: 14px; }
        .card-footer i { margin-left: 6px; transition: transform 0.2s; }
        .report-card:hover .card-footer i { transform: translateX(4px); }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div class="dashboard-header">
            <h2>Executive Reporting Dashboard</h2>
            <p>Select a module below to generate, view, print, or export system data.</p>
        </div>

        <div class="report-grid">
            <a href="reportBeneficiary" class="report-card">
                <div class="icon-box icon-blue"><i class="fas fa-users"></i></div>
                <h3>Beneficiary Registry</h3>
                <p>View the active directory of shelter victims, including household head relationships and demographic details.</p>
                <div class="card-footer">Generate Report <i class="fas fa-arrow-right"></i></div>
            </a>

            <a href="reportInventory" class="report-card">
                <div class="icon-box icon-green"><i class="fas fa-boxes-stacked"></i></div>
                <h3>Stock Inventory Valuation</h3>
                <p>Check real-time stock levels, available assets, and item unit factors across the supply chain.</p>
                <div class="card-footer">Generate Report <i class="fas fa-arrow-right"></i></div>
            </a>

            <a href="reportDistribution" class="report-card">
                <div class="icon-box icon-purple"><i class="fas fa-hand-holding-heart"></i></div>
                <h3>Distribution Exchange Log</h3>
                <p>Audit historical material flow records, including dispatch timestamps, target tents, and quantities.</p>
                <div class="card-footer">Generate Report <i class="fas fa-arrow-right"></i></div>
            </a>

            <% if ("Manager".equalsIgnoreCase(u.getRole())) { %>
            <a href="reportArchive" class="report-card">
                <div class="icon-box icon-orange"><i class="fas fa-file-archive"></i></div>
                <h3>Disaster Activation Archive</h3>
                <p>Review historical logs of previous shelter activations, closure dates, and total operational days.</p>
                <div class="card-footer">Generate Report <i class="fas fa-arrow-right"></i></div>
            </a>
            <% } %>
            
        </div>
    </div>
</body>

</html>