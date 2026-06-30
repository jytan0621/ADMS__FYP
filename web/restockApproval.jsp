<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.Model.RestockRequest, com.Model.RestockItem, com.Model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    String role = currentUser.getRole().trim().toLowerCase();
    if (!"approval officer".equals(role) && !"admin".equals(role)) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
    
    List<RestockRequest> pendingList = (List<RestockRequest>) request.getAttribute("pendingRestocks");
    List<RestockRequest> historyList = (List<RestockRequest>) request.getAttribute("historyRestocks"); 
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Restock Approvals</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* 1. LAYOUT RESET */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        
        /* 2. MAIN CONTENT AREA (The scrollable part) */
        .main-content { 
            position: absolute; top: 60px; left: 250px; right: 0; bottom: 0; 
            overflow-y: auto; padding: 32px; box-sizing: border-box; 
        }
        
        .card { background: white; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 50px; }

        /* 3. TABLE STYLING (The Anti-Sinking Fix) */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; table-layout: auto; }
        th { text-align: left; padding: 12px; background: #f1f5f9; color: #475569; font-size: 12px; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 16px 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }

        /* 4. BADGES (Standardized with restock.jsp) */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; white-space: nowrap; }
        .status-pending { background: #fef3c7; color: #92400e; }
        .status-approved { background: #dcfce7; color: #166534; }
        .status-rejected { background: #fee2e2; color: #991b1b; }
        .status-completed { background: #e0f2fe; color: #0369a1; }
        
        .item-list { margin: 0; padding-left: 18px; color: #475569; font-size: 13px; list-style-type: disc; }
        
        /* 5. TABS */
        .tab-container { border-bottom: 2px solid #e2e8f0; margin-bottom: 25px; display: flex; gap: 30px; }
        .tab-btn { background: none; border: none; padding: 10px 5px; font-size: 15px; font-weight: 600; color: #64748b; cursor: pointer; border-bottom: 3px solid transparent; transition: 0.2s; outline: none; }
        .tab-btn.active { color: #0b5ea8; border-bottom-color: #0b5ea8; }
        .tab-content { display: none; width: 100%; }
        .tab-content.active { display: block; }

        /* 6. MODALS (Fixed Position - Highest Z-Index) */
        .modal-overlay { 
            display: none; position: fixed; 
            top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(15, 23, 42, 0.6); z-index: 9999; 
            align-items: center; justify-content: center; backdrop-filter: blur(2px);
        }
        .modal-card { background: white; width: 90%; max-width: 500px; border-radius: 12px; overflow: hidden; box-shadow: 0 20px 25px rgba(0,0,0,0.3); }
        .modal-header { padding: 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .modal-body { padding: 20px; max-height: 400px; overflow-y: auto; }
        .modal-footer { padding: 15px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: right; }
        .btn-approve { background: #10b981; color: white; border: none; padding: 8px 16px; border-radius: 4px; font-weight: bold; cursor: pointer; }
        .btn-reject { background: #ef4444; color: white; border: none; padding: 8px 16px; border-radius: 4px; font-weight: bold; cursor: pointer; }
        .form-control { width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content">
        <h2 style="margin-top:0; margin-bottom: 24px; color: #0f172a;"><i class="fas fa-clipboard-check" style="color:#0b5ea8; margin-right:10px;"></i> Restock Approvals</h2>

        <div class="card">
            <div class="tab-container">
                <button id="tabBtnPending" class="tab-btn active" onclick="switchTab(this, 'tab-pending')"><i class="fas fa-inbox"></i> Pending Action</button>
                <button id="tabBtnHistory" class="tab-btn" onclick="switchTab(this, 'tab-history')"><i class="fas fa-history"></i> Approval History</button>
            </div>

            <div id="tab-pending" class="tab-content active">
                <table>
                    <thead>
                        <tr>
                            <th>No.</th> <th>Date Requested</th> <th>Supplier</th> <th>Items</th> <th>Status</th> <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        int count = 1; 
                        if(pendingList != null && !pendingList.isEmpty()) { 
                            for(RestockRequest rr : pendingList) { 
                        %>
                        <tr>
                            <td><strong>#<%= count++ %></strong><br><small style="color:#94a3b8">by <%= rr.getRrRequestedBy() %></small></td>
                            <td><%= rr.getRrDateRequest() %></td>
                            <td><strong><%= (rr.getSupplierID() != null) ? rr.getSupplierID() : "N/A" %></strong></td>
                            <td>
                                <ul class="item-list">
                                    <% if (rr.getItems() != null) { for(RestockItem item : rr.getItems()) { %>
                                        <li><%= item.getItemName() %> - Qty: <%= item.getRrQuantityRequest() %></li>
                                    <% } } %>
                                </ul>
                            </td>
                            <td><span class="badge status-pending">PENDING</span></td>
                            <td style="text-align: right; white-space: nowrap;">
                                <button type="button" class="btn-approve" style="padding:6px 12px;" onclick="document.getElementById('appModal_<%= rr.getRestockID() %>').style.display='flex'">Approve</button>
                                <button type="button" class="btn-reject" style="padding:6px 12px;" onclick="document.getElementById('rejModal_<%= rr.getRestockID() %>').style.display='flex'">Reject</button>
                            </td>
                        </tr>
                        <% } } else { %>
                            <tr><td colspan="6" style="text-align:center; padding:40px; color:#94a3b8;">No pending requests found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div id="tab-history" class="tab-content">
                <table>
                    <thead>
                        <tr>
                            <th>No.</th> <th>Date Requested</th> <th>Supplier</th> <th>Requested Items</th> <th>Action Date</th> <th>Final Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        int hCount = 1; 
                        if(historyList != null && !historyList.isEmpty()) { 
                            for(RestockRequest hr : historyList) { 
                                String status = hr.getRrStatus();
                                String badgeClass = "status-pending";
                                if("Approved".equalsIgnoreCase(status)) badgeClass = "status-approved";
                                else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "status-rejected";
                                else if ("Completed".equalsIgnoreCase(status)) badgeClass = "status-completed";
                        %>
                        <tr>
                            <td><strong><%= hCount++ %></strong></td>
                            <td><%= hr.getRrDateRequest() %></td>
                            <td><strong><%= (hr.getSupplierID() != null) ? hr.getSupplierID() : "-" %></strong></td>
                            <td>
                                <ul class="item-list">
                                    <% if (hr.getItems() != null) { for(RestockItem item : hr.getItems()) { %>
                                        <li><%= item.getItemName() %> (Qty: <%= item.getRrQuantityRequest() %>)</li>
                                    <% } } %>
                                </ul>
                            </td>
                            <td><%= (hr.getRrApprovalDate() != null) ? hr.getRrApprovalDate() : "-" %></td>
                            <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                        </tr>
                        <% } } else { %>
                            <tr><td colspan="6" style="text-align:center; padding:40px; color:#94a3b8;">No history found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <% if(pendingList != null) { for(RestockRequest rr : pendingList) { %>
        <div id="appModal_<%= rr.getRestockID() %>" class="modal-overlay">
            <div class="modal-card">
                <div class="modal-header"><h3>Edit Quantities: <%= rr.getRestockID() %></h3></div>
                <form action="processRestockApproval" method="POST">
                    <div class="modal-body">
                        <input type="hidden" name="restockID" value="<%= rr.getRestockID() %>">
                        <input type="hidden" name="actionType" value="Approve">
                        <table style="width:100%">
                            <% if (rr.getItems() != null) { for(RestockItem rItem : rr.getItems()) { %>
                            <tr>
                                <td style="padding:10px 0;"><b><%= rItem.getItemName() %></b><input type="hidden" name="itemID[]" value="<%= rItem.getItemID() %>"></td>
                                <td style="width:120px;"><input type="number" name="approvedQty[]" class="form-control" value="<%= rItem.getRrQuantityRequest() %>" min="0"></td>
                            </tr>
                            <% } } %>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" onclick="document.getElementById('appModal_<%= rr.getRestockID() %>').style.display='none'" style="border:none; background:none; cursor:pointer; font-weight:600; color:#64748b; margin-right:15px;">Cancel</button>
                        <button type="submit" class="btn-approve">Confirm Approval</button>
                    </div>
                </form>
            </div>
        </div>

        <div id="rejModal_<%= rr.getRestockID() %>" class="modal-overlay">
            <div class="modal-card">
                <div class="modal-header"><h3>Rejection Reason</h3></div>
                <form action="processRestockApproval" method="POST">
                    <div class="modal-body">
                        <input type="hidden" name="restockID" value="<%= rr.getRestockID() %>">
                        <input type="hidden" name="actionType" value="Reject">
                        <textarea name="rejectReason" class="form-control" rows="4" placeholder="Why is this being rejected?" required></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" onclick="document.getElementById('rejModal_<%= rr.getRestockID() %>').style.display='none'" style="border:none; background:none; cursor:pointer; font-weight:600; color:#64748b; margin-right:15px;">Cancel</button>
                        <button type="submit" class="btn-reject">Confirm Reject</button>
                    </div>
                </form>
            </div>
        </div>
    <% } } %>

    <script>
        function switchTab(buttonElement, tabId) {
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            buttonElement.classList.add('active'); 
            sessionStorage.setItem('activeApprovalTab', tabId);
        }

        document.addEventListener('DOMContentLoaded', function() {
            const savedTab = sessionStorage.getItem('activeApprovalTab');
            if (savedTab) {
                const buttons = document.querySelectorAll('.tab-btn');
                for (let btn of buttons) {
                    if (btn.getAttribute('onclick').includes(savedTab)) {
                        btn.click();
                        break;
                    }
                }
            }
        });
    </script>
</body>
</html>