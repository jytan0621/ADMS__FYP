<%-- 
    Document   : distribution.jsp
    Created on : Apr 14, 2026, 2:36:52 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.AidRequest, com.Model.RequestItemDTO, com.Model.User" %>
<%
    User u = (User) session.getAttribute("currentUser");
    if (u == null) { response.sendRedirect("index.jsp"); return; }
    
    // Lists passed from InventoryServlet
    List<AidRequest> approvedRequests = (List<AidRequest>) request.getAttribute("approvedRequests");
    String targetRequestID = (String) request.getAttribute("targetRequestID");
    List<RequestItemDTO> requestItemsList = (List<RequestItemDTO>) request.getAttribute("requestItemsList");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Distribution Center</title>
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
        
        .btn-view { color: #64748b; background: #f1f5f9; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s;}
        .btn-view:hover { color: #0b5ea8; background: #e0f2fe; }
        
        .btn-prep { background: #f97316; color: white; border: none; padding: 6px 14px; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s;}
        .btn-prep:hover { background: #ea580c; }

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
        
        /* Popup Alert Button */
        .btn-alert-ok { color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 14px; width: 100%; transition: 0.2s; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 style="margin:0; color: #1e293b;"><i class="fas fa-dolly-flatbed" style="color:#0b5ea8; margin-right: 8px;"></i> Pending Distributions</h2>
        </div>
        
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 80px;">No.</th>
                        <th><i class="fas fa-user" style="margin-right: 5px;"></i> Requested By</th>
                        <th><i class="far fa-calendar-check" style="margin-right: 5px;"></i> Date Approved</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 1; // Counter initialization
                        if(approvedRequests != null && !approvedRequests.isEmpty()) { 
                            for(AidRequest r : approvedRequests) { 
                    %>
                    <tr>
                        <td><strong style="font-size: 16px; color: #475569;">#<%= count++ %></strong></td>
                        
                        <td style="font-weight: 500;"><%= r.getRequestedBy() %></td>
                        
                        <td style="color: #64748b;"><%= r.getArApprovedDate() %></td>
                        <td style="text-align:right;">
                            <a href="viewRequestItems?requestID=<%= r.getRequestID() %>&source=dist" class="btn-view" title="View Items">
                                <i class="fas fa-eye"></i> View
                            </a>
                            
                            <form action="prepareOrder" method="POST" style="display:inline;" onsubmit="return confirm('Confirm preparation? This will permanently deduct items from the warehouse inventory.');">
                                <input type="hidden" name="requestID" value="<%= r.getRequestID() %>">
                                <button type="submit" class="btn-prep"><i class="fas fa-box-open"></i> Prepare Order</button>
                            </form>
                        </td>
                    </tr>
                    <%      } 
                        } else { 
                    %>
                    <tr>
                        <td colspan="4" style="text-align:center; padding:40px; color:#94a3b8; font-style:italic;">
                            <i class="fas fa-box-open" style="font-size: 24px; display:block; margin-bottom:10px; color:#cbd5e1;"></i>
                            No pending distributions at the moment.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ========================================= --%>
    <%-- MODAL: POP-UP FOR STATUS ALERTS (NEW!)    --%>
    <%-- ========================================= --%>
    <% 
        String msg = request.getParameter("msg");
        String error = request.getParameter("error");
        
        if (msg != null || error != null) { 
            boolean isError = "InsufficientStock".equals(error);
            String title = isError ? "Insufficient Stock!" : "Success!";
            String messageText = isError 
                ? "There is not enough stock in the warehouse to fulfill this request. Please arrange for a restock before proceeding." 
                : "Distribution processed and items deducted from inventory successfully!";
            String iconClass = isError ? "fas fa-exclamation-triangle" : "fas fa-check-circle";
            String colorCode = isError ? "#ef4444" : "#10b981";
    %>
    <div id="statusAlertModal" class="modal-overlay" style="display: flex; z-index: 3000;">
        <div class="modal-card" style="max-width: 400px; text-align: center; padding: 30px;">
            <i class="<%= iconClass %>" style="font-size: 50px; color: <%= colorCode %>; margin-bottom: 15px;"></i>
            <h3 style="margin: 0 0 10px 0; color: #0f172a; font-size: 22px;"><%= title %></h3>
            <p style="color: #475569; margin-bottom: 25px; font-size: 15px; line-height: 1.5;"><%= messageText %></p>
            <button onclick="document.getElementById('statusAlertModal').style.display='none'" class="btn-alert-ok" style="background: <%= colorCode %>;">
                OK, Got it
            </button>
        </div>
    </div>
    <% } %>

    <%-- ========================================= --%>
    <%-- MODAL: POP-UP FOR ITEMS (Distribution View) --%>
    <%-- ========================================= --%>
    <% if (targetRequestID != null && requestItemsList != null) { %>
    <div id="itemsModal" class="modal-overlay" style="display: flex;">
        <div class="modal-card">
            <div class="modal-header">
                <h3><i class="fas fa-list-check" style="color: #0b5ea8;"></i> Items Needed: <%= targetRequestID %></h3>
                <a href="distributionCenter" class="close-btn">&times;</a>
            </div>
            
            <div class="modal-body">
                <div class="table-container">
                    <table style="margin-top:0;">
                        <thead style="background:#e2e8f0;">
                            <tr>
                                <th style="color:#334155; padding-left: 15px;">Item ID</th>
                                <th style="color:#334155;">Item Description</th>
                                <th style="color:#334155; text-align:center;">Qty Requested</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(RequestItemDTO item : requestItemsList) { %>
                            <tr>
                                <td style="padding-left: 15px;"><%= item.getItemID() %></td>
                                <td><strong><%= item.getItemName() %></strong></td>
                                <td style="font-weight:bold; color:#ea580c; font-size:16px; text-align:center;"><%= item.getQuantityRequested() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; display: flex; justify-content: flex-end; gap: 10px; align-items: center;">
                    <a href="distributionCenter" class="btn-view" style="margin:0; background: white;"><i class="fas fa-arrow-left"></i> Back</a>
                    
                    <form action="prepareOrder" method="POST" style="margin:0;" onsubmit="return confirm('Confirm preparation? This will permanently deduct items from the warehouse inventory.');">
                        <input type="hidden" name="requestID" value="<%= targetRequestID %>">
                        <button type="submit" class="btn-prep"><i class="fas fa-box-open"></i> Prepare Order Now</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <% } %>

</body>
</html>