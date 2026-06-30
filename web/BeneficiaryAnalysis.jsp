<%-- 
    Document   : BeneficiaryAnalysis
    Created on : Jan 19, 2026, 1:04:13 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Population Analysis</title>
    <link rel="stylesheet" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f1f5f9; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content { margin-left: 250px; padding: 90px 30px 30px 30px; }

        .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .kpi-card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-left: 5px solid; }
        .kpi-card h4 { margin: 0; font-size: 13px; color: #64748b; text-transform: uppercase; }
        .kpi-card h1 { margin: 5px 0 0 0; font-size: 28px; color: #1e293b; }
        
        .b-blue { border-color: #3b82f6; } 
        .b-green { border-color: #10b981; } 
        .b-purple { border-color: #8b5cf6; } 
        .b-orange { border-color: #f59e0b; } 

        .chart-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
        .chart-box { background: white; padding: 24px; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .box-header { font-size: 16px; font-weight: 700; color: #334155; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 10px; }
        .canvas-container { position: relative; height: 300px; width: 100%; }
        .full-width { grid-column: span 2; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <h2 style="color:#1e293b; margin-bottom:25px;">Center Population Analysis</h2>

        <div class="kpi-grid">
            <div class="kpi-card b-blue"><h4>Currently Admitted</h4><h1><%= request.getAttribute("cActive") %></h1></div>
            <div class="kpi-card b-green"><h4>Total Discharged</h4><h1><%= request.getAttribute("cDischarged") %></h1></div>
            <div class="kpi-card b-purple"><h4>OKU Individuals</h4><h1><%= request.getAttribute("cOKU") %></h1></div>
            <div class="kpi-card b-orange"><h4>Seniors (60+)</h4><h1><%= request.getAttribute("cSenior") %></h1></div>
        </div>

        <div class="chart-row">
            <div class="chart-box">
                <div class="box-header">Age Demographics (Male vs Female)</div>
                <div class="canvas-container">
                    <canvas id="ageChart"></canvas>
                </div>
            </div>
            <div class="chart-box">
                <div class="box-header">Overall Gender Ratio</div>
                <div class="canvas-container" style="height:250px; width:250px; margin:0 auto;">
                    <canvas id="genderChart"></canvas>
                </div>
            </div>
        </div>

        <div class="chart-row">
            <div class="chart-box full-width">
                <div class="box-header">Daily Admission Flow (Total Persons)</div>
                <div class="canvas-container">
                    <canvas id="flowChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <input type="hidden" id="maleAgeData" value="<%= request.getAttribute("maleAgeData") %>">
    <input type="hidden" id="femaleAgeData" value="<%= request.getAttribute("femaleAgeData") %>">
    <input type="hidden" id="genderTotalData" value="<%= request.getAttribute("genderTotalData") %>">
    <input type="hidden" id="dateLabels" value='<%= request.getAttribute("datesLabels") %>'>
    <input type="hidden" id="admitValues" value="<%= request.getAttribute("admissionValues") %>">

    <script>
        Chart.defaults.font.family = "'Segoe UI', sans-serif";

        // --- 1. REFINED AGE CHART (Grouped Bar) ---
        new Chart(document.getElementById('ageChart'), {
            type: 'bar',
            data: {
                labels: ['Baby (0-2)', 'Child (3-12)', 'Adult (13-59)', 'Senior (60+)'],
                datasets: [
                    {
                        label: 'Male',
                        data: JSON.parse(document.getElementById('maleAgeData').value),
                        backgroundColor: '#3b82f6', // Blue
                        borderRadius: 4
                    },
                    {
                        label: 'Female',
                        data: JSON.parse(document.getElementById('femaleAgeData').value),
                        backgroundColor: '#ec4899', // Pink
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: { 
                    y: { beginAtZero: true, grid: { borderDash: [5, 5] } }, 
                    x: { grid: { display: false } } 
                },
                plugins: { legend: { position: 'top' } }
            }
        });

        // --- 2. GENDER CHART ---
        new Chart(document.getElementById('genderChart'), {
            type: 'doughnut',
            data: {
                labels: ['Male', 'Female'],
                datasets: [{
                    data: JSON.parse(document.getElementById('genderTotalData').value),
                    backgroundColor: ['#3b82f6', '#ec4899'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom' } },
                cutout: '60%'
            }
        });

        // --- 3. FLOW CHART ---
        new Chart(document.getElementById('flowChart'), {
            type: 'line',
            data: {
                labels: JSON.parse(document.getElementById('dateLabels').value),
                datasets: [{
                    label: 'New Admissions',
                    data: JSON.parse(document.getElementById('admitValues').value),
                    borderColor: '#2563eb',
                    backgroundColor: 'rgba(37, 99, 235, 0.1)',
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#2563eb'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: { y: { beginAtZero: true, suggestedMax: 5 } }
            }
        });
    </script>
</body>
</html>