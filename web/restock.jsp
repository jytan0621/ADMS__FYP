<%-- 
    Document   : restock.jsp
    Created on : Apr 14, 2026, 4:55:32 PM
    Author     : User
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.RestockRequest, com.Model.RestockItem, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    List<RestockRequest> restockList = (List<RestockRequest>) request.getAttribute("restockList");
    
    // Check if we are trying to view a specific restock's details
    RestockRequest targetRestock = (RestockRequest) request.getAttribute("targetRestock");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Restock Requests</title>
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

        /* Status Badges */
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; }
        .status-pending { background: #fef3c7; color: #92400e; }
        .status-approved { background: #dcfce7; color: #166534; }
        .status-rejected { background: #fee2e2; color: #991b1b; }
        .status-completed { background: #e0f2fe; color: #0369a1; }
        
        .btn-new { background: #0b5ea8; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; transition: background 0.2s; }
        .btn-new:hover { background: #094b86; }
        
        /* Action Buttons */
        .btn-receive { background: #10b981; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 12px; font-weight: bold; display: inline-block; transition: background 0.2s; }
        .btn-receive:hover { background: #059669; }
        .btn-view { color: #64748b; background: #f1f5f9; padding: 6px 10px; border-radius: 4px; text-decoration: none; font-size: 13px; transition: 0.2s; margin-right: 8px;}
        .btn-view:hover { color: #0b5ea8; background: #e0f2fe; }

        /* Modal Styles */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.6); z-index: 2000; align-items: center; justify-content: center; backdrop-filter: blur(2px); }
        .modal-card { background: white; width: 100%; max-width: 600px; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); overflow: hidden; animation: slideDown 0.3s ease-out; }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; }
        .modal-header h3 { margin: 0; font-size: 18px; color: #0f172a; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1; text-decoration: none;}
        .close-btn:hover { color: #ef4444; }
        .modal-body { padding: 24px; max-height: 60vh; overflow-y: auto; }
        .table-container { border: 1px solid #cbd5e1; border-radius: 8px; overflow: hidden; }
        @keyframes slideDown { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px;">
            <h2 style="margin:0; color: #0f172a;"><i class="fas fa-clipboard-list" style="color:#0b5ea8; margin-right: 8px;"></i> Restock Request History</h2>
            <a href="newRestock" class="btn-new"><i class="fas fa-plus"></i> New Request</a>
        </div>

        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">No.</th> 
                        <th><i class="fas fa-user" style="margin-right: 5px;"></i> Requested By</th>
                        <th><i class="far fa-calendar-alt" style="margin-right: 5px;"></i> Date Requested</th>
                        <th><i class="fas fa-building" style="margin-right: 5px;"></i> Supplier</th>
                        <th><i class="fas fa-user-check" style="margin-right: 5px;"></i> Approved By</th>
                        <th>Status</th>
                        <th>Action</th> 
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; 
                        if(restockList != null && !restockList.isEmpty()) { 
                            for(RestockRequest rr : restockList) { 
                                String statusClass = "status-pending";
                                String currentStatus = rr.getRrStatus();
                                
                                if("Approved".equalsIgnoreCase(currentStatus)) statusClass = "status-approved";
                                else if("Rejected".equalsIgnoreCase(currentStatus)) statusClass = "status-rejected";
                                else if("Completed".equalsIgnoreCase(currentStatus)) statusClass = "status-completed";
                    %>
                    <tr>
                        <td><strong style="font-size: 16px; color: #475569;"><%= count++ %></strong></td>
                        
                        <td style="font-weight: 500;"><%= rr.getRrRequestedBy() %></td>
                        <td style="color: #64748b;"><%= rr.getRrDateRequest() %></td>
                        <td><%= (rr.getSupplierID() != null) ? rr.getSupplierID() : "-" %></td>
                        <td><%= (rr.getRrApprovedBy() != null) ? rr.getRrApprovedBy() : "-" %></td>
                        
                        <td><span class="badge <%= statusClass %>"><%= currentStatus %></span></td>
                        <td>
                            <a href="viewRestockItems?id=<%= rr.getRestockID() %>" class="btn-view" title="View Items">
                                <i class="fas fa-eye"></i>
                            </a>

                            <% if("Approved".equalsIgnoreCase(currentStatus)) { %>
                                <a href="receiveRestock?id=<%= rr.getRestockID() %>" class="btn-receive">
                                    <i class="fas fa-box-open"></i> Receive
                                </a>
                            <% } else if("Completed".equalsIgnoreCase(currentStatus)) { %>
                                <span style="color: #10b981; font-weight: 600; font-size: 13px;">
                                    <i class="fas fa-check-double"></i> Done
                                </span>
                            <% } else if("Rejected".equalsIgnoreCase(currentStatus)) { %>
                                <span style="color: #dc2626; font-weight: 600; font-size: 13px;">
                                    <i class="fas fa-times"></i> Cancelled
                                </span>
                            <% } else { %>
                                <span style="color: #f59e0b; font-size: 13px; font-style: italic;">
                                    <i class="fas fa-hourglass-half"></i> Pending
                                </span>
                            <% } %>
                        </td>
                    </tr>
                    <%  } 
                       } else { %>
                    <tr>
                        <td colspan="7" style="text-align:center; padding:40px; color:#94a3b8; font-style:italic;">
                            <i class="fas fa-history" style="font-size: 24px; display:block; margin-bottom:10px; color:#cbd5e1;"></i>
                            No restock requests found.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ========================================= --%>
    <%-- MODAL: POP-UP FOR RESTOCK ITEMS DETAILS   --%>
    <%-- ========================================= --%>
    <% if (targetRestock != null && targetRestock.getItems() != null) { %>
    <div id="itemsModal" class="modal-overlay" style="display: flex;">
        <div class="modal-card">
            <div class="modal-header">
                <h3><i class="fas fa-box" style="color: #0b5ea8;"></i> Items for <%= targetRestock.getRestockID() %></h3>
                <a href="listRestock" class="close-btn">&times;</a>
            </div>
            
            <div class="modal-body">
                <div style="margin-bottom: 15px; color: #475569; font-size: 14px;">
                    <strong>Status:</strong> <span style="color: #0b5ea8;"><%= targetRestock.getRrStatus() %></span><br>
                    <strong>Supplier:</strong> <%= (targetRestock.getSupplierID() != null) ? targetRestock.getSupplierID() : "-" %>
                </div>

                <div class="table-container">
                    <table style="margin-top:0;">
                        <thead style="background:#e2e8f0;">
                            <tr>
                                <th style="color:#334155; padding-left: 15px;">Item ID</th>
                                <th style="color:#334155;">Item Name</th>
                                <th style="color:#334155; text-align:center;">Qty Requested</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(RestockItem item : targetRestock.getItems()) { %>
                            <tr>
                                <td style="padding-left: 15px;"><%= item.getItemID() %></td>
                                <td><strong><%= (item.getItemName() != null) ? item.getItemName() : "Unknown Item" %></strong></td>
                                <td style="font-weight:bold; color:#ea580c; font-size:16px; text-align:center;"><%= item.getRrQuantityRequest() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; text-align: right;">
                    <a href="listRestock" class="btn-new" style="background: #64748b;"><i class="fas fa-times"></i> Close</a>
                </div>
            </div>
        </div>
    </div>
    <% } %>

</body>
</html>