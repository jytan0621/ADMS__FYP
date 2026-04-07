<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="com.Model.AidRequestItem" %>
<%@ page import="com.DAO.AidRequestDAO" %> 
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // 2. Retrieve Data
    AidRequest req = (AidRequest) request.getAttribute("request");
    List<AidRequestItem> items = (List<AidRequestItem>) request.getAttribute("items");
    
    if (req == null) { response.sendRedirect("listRequest"); return; }
    if (items == null) items = new ArrayList<>();
    
    // 3. Helper to get Username
    AidRequestDAO dao = new AidRequestDAO();
    Map<String, String> userMap = dao.getAllUserNames(); 
    
    String requesterName = userMap.getOrDefault(req.getRequestedBy(), req.getRequestedBy());
    String approverName = "-";
    if (req.getArApprovedBy() != null) {
        approverName = userMap.getOrDefault(req.getArApprovedBy(), req.getArApprovedBy());
    }

    // 4. Date Formatters
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String dateSubmitted = (req.getArDateSubmitted() != null) ? sdf.format(req.getArDateSubmitted()) : "-";
    String dateApproved = (req.getArApprovedDate() != null) ? sdf.format(req.getArApprovedDate()) : "-";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Request Detail</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 48px; row-gap: 20px; }
        .form-group { display: flex; align-items: center; gap: 16px; }
        .form-label { min-width: 140px; color: #374151; font-size: 16px; font-weight: 600; }
        .form-input { flex: 1; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; outline: none; background-color: #f8fafc; color: #4b5563; }
        
        /* Status Colors */
        .status-approved { color: #166534; font-weight: bold; background-color: #dcfce7; }
        .status-rejected { color: #991b1b; font-weight: bold; background-color: #fee2e2; }
        .status-pending { color: #854d0e; font-weight: bold; background-color: #fef9c3; }

        /* Alerts */
        .msg-box { padding: 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; display: flex; align-items: center; gap: 10px; }
        .msg-success { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .msg-error { background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
        .msg-warning { background-color: #fef9c3; color: #854d0e; border: 1px solid #fde047; }

        .items-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        .table-container { border: 1px solid #9ca3af; border-radius: 4px; overflow: hidden;}
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f1f5f9; padding: 12px 15px; text-align: left; font-weight: bold; color: #374151; border-bottom: 1px solid #cbd5e1; }
        td { padding: 12px 15px; border-bottom: 1px solid #e2e8f0; color: #374151; }

        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 40px; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 600; text-decoration: none; text-align: center; cursor: pointer; border: none; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-approve { background-color: #16a34a; color: white; }
        .btn-reject { background-color: #dc2626; color: white; }
        .btn-edit { background-color: #0b5ea8; color: white; }
        .btn-delete { background-color: #dc2626; color: white; }
    </style>
</head>
<body>

    <header class="fixed-header">
        <div style="display:flex; gap:10px; align-items:center;">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span style="font-size:20px; font-weight:bold;">ADMS</span>
        </div>
        <div><%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %></div>
    </header>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" />
    </div>

    <div class="main-content-scrollable">
        
        <%-- MESSAGES BLOCK --%>
        <% 
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            String warning = request.getParameter("warning");
            
            if (msg != null) { 
        %>
            <div class="msg-box msg-success">
                <i class="fas fa-check-circle"></i> <%= msg %>
            </div>
        <% } %>
        
        <% if (error != null) { %>
            <div class="msg-box msg-error">
                <i class="fas fa-times-circle"></i> <strong>Action Blocked:</strong> <%= error %>
            </div>
        <% } %>

        <%-- YELLOW WARNING FOR THRESHOLD --%>
        <% if (warning != null) { %>
            <div class="msg-box msg-warning">
                <i class="fas fa-bell"></i> <strong><%= warning %></strong>
            </div>
        <% } %>

        <div class="form-card">
            
            <div class="form-header">
                <a href="listRequest" style="color:black;" title="Back to List">
                    <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
                </a>
                <h1 style="margin:0 0 0 15px; font-size: 28px;">Request Detail (#<%= req.getRequestID() %>)</h1>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Requester:</label>
                    <input type="text" class="form-input" value="<%= requesterName %>" readonly>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Submitted Date:</label>
                    <input type="text" class="form-input" value="<%= dateSubmitted %>" readonly>
                </div>

                <div class="form-group">
                    <label class="form-label">Current Status:</label>
                    <%
                        String statusClass = "";
                        if("Approved".equalsIgnoreCase(req.getArStatus())) statusClass = "status-approved";
                        else if("Rejected".equalsIgnoreCase(req.getArStatus())) statusClass = "status-rejected";
                        else statusClass = "status-pending";
                    %>
                    <input type="text" class="form-input <%= statusClass %>" value="<%= req.getArStatus() %>" readonly>
                </div>

                <% if (!"Pending".equalsIgnoreCase(req.getArStatus())) { %>
                    <div class="form-group">
                        <label class="form-label">Processed By:</label>
                        <input type="text" class="form-input" value="<%= approverName %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Processed Date:</label>
                        <input type="text" class="form-input" value="<%= dateApproved %>" readonly>
                    </div>
                <% } %>
                
                <div class="form-group full-width">
                    <label class="form-label">Remark:</label>
                    <input type="text" class="form-input" 
                           value="<%= (req.getArApprovalRemark() != null) ? req.getArApprovalRemark() : "-" %>" readonly>
                </div>
            </div>

            <div class="items-section">
                <h3 style="margin-bottom:15px; font-size:18px; color:#374151;">Requested Items</h3>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 60px; text-align: center;">No.</th>
                                <th>Item Name</th>
                                <th style="width: 100px;">Unit</th>
                                <th style="width: 150px; text-align: center;">Quantity</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if(items.isEmpty()) {
                            %>
                                <tr><td colspan="4" style="text-align:center; padding: 20px; color:#888;">No items found in this request.</td></tr>
                            <%
                                } else {
                                    int count = 1;
                                    for(AidRequestItem item : items) {
                                        String unit = (item.getItemUnit() != null) ? item.getItemUnit() : "-";
                            %>
                                <tr>
                                    <td style="text-align: center;"><%= count++ %></td>
                                    <td><%= (item.getItemName() != null) ? item.getItemName() : item.getItemID() %></td>
                                    <td style="color: #64748b; font-weight:500;"><%= unit %></td>
                                    <td style="text-align: center;"><%= item.getArQuantityRequested() %></td>
                                </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="btn-container">
                <a href="listRequest" class="btn btn-cancel">Back to List</a>

                <% if ("Approval Officer".equalsIgnoreCase(currentUser.getRole()) && "Pending".equalsIgnoreCase(req.getArStatus())) { %>
                    <a href="#" onclick="rejectRequest('<%= req.getRequestID() %>')" class="btn btn-reject">Reject</a>
                    <a href="processRequest?id=<%= req.getRequestID() %>&status=Approved" class="btn btn-approve" onclick="return confirm('Confirm APPROVE this request?')">Approve Request</a>
                <% } %>

                <% if ("Field Officer".equalsIgnoreCase(currentUser.getRole()) && "Pending".equalsIgnoreCase(req.getArStatus())) { %>
                    <a href="editRequest?id=<%= req.getRequestID() %>" class="btn btn-edit">Edit Request</a>
                    <a href="deleteRequest?id=<%= req.getRequestID() %>" class="btn btn-delete" onclick="return confirm('Are you sure you want to delete this request?')">Delete Request</a>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        function rejectRequest(id) {
            let remark = prompt("Please enter a reason for rejection:", "Insufficient Stock");
            if (remark !== null) {
                if(remark.trim() === "") remark = "No reason provided";
                window.location.href = "processRequest?id=" + id + "&status=Rejected&remark=" + encodeURIComponent(remark);
            }
        }
    </script>
</body>
</html>