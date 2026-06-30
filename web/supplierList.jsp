<%-- 
    Document   : supplierList
    Created on : Apr 14, 2026, 5:03:37 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.Supplier, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    List<Supplier> supplierList = (List<Supplier>) request.getAttribute("supplierList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Supplier List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 25px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { text-align: left; padding: 12px; background: #f1f5f9; color: #475569; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; }
        tr:hover { background-color: #f8fafc; }
        .btn-add { background: #0b5ea8; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: 0.2s;}
        .btn-add:hover { background: #094b86; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px;">
            <h2 style="margin:0; color: #0f172a;"><i class="fas fa-building" style="color:#0b5ea8; margin-right: 8px;"></i> Supplier Directory</h2>
            <a href="newSupplier" class="btn-add"><i class="fas fa-plus"></i> Add New Supplier</a>
        </div>
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">No.</th> <th>Company Name</th>
                        <th>Contact Number</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; // Initialize the counter
                        if(supplierList != null && !supplierList.isEmpty()) { 
                            for(Supplier s : supplierList) { 
                    %>
                    <tr>
                        <td><strong style="font-size: 16px; color: #475569;"><%= count++ %></strong></td>
                        <td style="font-weight: 600;"><%= s.getSupplierName() %></td>
                        <td><%= s.getsCNumber() %></td>
                    </tr>
                    <%      } 
                        } else { 
                    %>
                    <tr><td colspan="3" style="text-align:center; padding:30px; color:#94a3b8; font-style: italic;">No suppliers found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>