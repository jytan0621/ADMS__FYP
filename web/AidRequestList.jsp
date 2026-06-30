<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    session.setAttribute("activeMenu", "aid");

    List<AidRequest> listRequest = (List<AidRequest>) request.getAttribute("listRequest");
    if (listRequest == null) listRequest = new ArrayList<>();
    
    // Retrieve Maps for Name Lookup
    Map<String, String> summaryMap = (Map<String, String>) request.getAttribute("summaryMap");
    if (summaryMap == null) summaryMap = new HashMap<>();

    Map<String, String> userMap = (Map<String, String>) request.getAttribute("userMap");
    if (userMap == null) userMap = new HashMap<>();
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    // [LOGIC UPDATE] Determine if "Requested By" column should be shown
    // Admin AND Approval Officer need to see this. Field Officers do not.
    boolean showRequesterColumn = "Admin".equalsIgnoreCase(currentUser.getRole()) || 
                                  "Approval Officer".equalsIgnoreCase(currentUser.getRole());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Aid Request List</title>
    
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-view { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 30px; background-color: #f8fafc; }
        
        .table-card { background: white; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .data-table { width: 100%; border-collapse: collapse; background: white; }
        .data-table th { background-color: #f1f5f9; padding: 15px; text-align: left; color: #475569; font-weight: 600; text-transform: uppercase; font-size: 12px; border-bottom: 2px solid #e2e8f0; vertical-align: middle;}
        .data-table td { padding: 15px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #334155; vertical-align: middle; }
        .data-table tr:hover { background-color: #f8fafc; transition: background 0.15s ease; }

        /* [STATUS COLORS] */
        .status { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; }
        .status-approved { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; } 
        .status-rejected { background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; } 
        .status-pending  { background-color: #fef9c3; color: #854d0e; border: 1px solid #fde047; } 
        .status-draft    { background-color: #e2e8f0; color: #475569; border: 1px solid #cbd5e1; }

        .btn-add { background-color: #10b981; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; float: right; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 5px;}
        .btn-add:hover { background-color: #059669; }

        .action-link { text-decoration: none; margin-right: 15px; font-weight: 600; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; }
        .view-link { color: #2563eb; }
        .view-link:hover { text-decoration: underline; }
        
        .search-wrapper { display: flex; }
        .search-input { padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px 0 0 6px; outline: none; width: 220px; }
        .search-btn { padding: 8px 12px; border: 1px solid #cbd5e1; background: #e2e8f0; border-radius: 0 6px 6px 0; color: #475569; font-weight: 600; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-view">
        <div style="margin-bottom: 20px; overflow: hidden; display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin:0; color:#1e293b;">
                <%= showRequesterColumn ? "All Aid Requests" : "My Aid Requests" %>
            </h2>
            <div style="display:flex; gap:10px;">
                <div class="search-wrapper">
                    <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search Name, Item..." class="search-input">
                    <div class="search-btn"><i class="fas fa-search"></i></div>
                </div>
                
                <%-- BUTTON LOGIC: Hide for 'Approval Officer' AND 'Admin' --%>
                <% if (!"Approval Officer".equalsIgnoreCase(currentUser.getRole()) 
                       && !"Admin".equalsIgnoreCase(currentUser.getRole())) { %>
                    <a href="newRequest" class="btn-add"><i class="fas fa-plus"></i> New Request</a>
                <% } %>
            </div>
        </div>
        
        <% 
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            if (msg != null) { 
        %>
            <div style="padding: 12px; background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
                <i class="fas fa-check-circle"></i> <%= msg %>
            </div>
        <% } if (error != null) { %>
            <div style="padding: 12px; background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>

        <div class="table-card">
            <table class="data-table" id="requestTable">
                <thead>
                    <tr>
                        <th style="width: 50px; text-align: center;">No.</th>
                        <th style="width: 110px;">Date Submitted</th>
                        <th>Item Requested (Summary)</th>
                        
                        <%-- [LOGIC]: Only show for Admin/Approval Officer --%>
                        <% if(showRequesterColumn) { %>
                            <th style="width: 150px;">Requested By</th>
                        <% } %>
                        
                        <th style="width: 100px; text-align:center;">Status</th>
                        
                        <th style="width: 130px;">Processed By</th>
                        <th style="width: 110px;">Processed Date</th>
                        
                        <th style="text-align: center; width: 100px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        if (listRequest.isEmpty()) { 
                    %>
                        <tr>
                            <%-- Adjust colspan based on column visibility --%>
                            <td colspan="<%= showRequesterColumn ? 8 : 7 %>" style="text-align:center; padding: 40px; color: #94a3b8;">
                                <p style="margin:0; font-size:16px; font-weight:500;">No aid requests found.</p>
                            </td>
                        </tr>
                    <% 
                        } else {
                            int count = 1;
                            for (AidRequest req : listRequest) {
                                // 1. Determine Status Color
                                String statusClass = "status-pending";
                                if ("Approved".equalsIgnoreCase(req.getArStatus())) statusClass = "status-approved";
                                else if ("Rejected".equalsIgnoreCase(req.getArStatus())) statusClass = "status-rejected";
                                else if ("Draft".equalsIgnoreCase(req.getArStatus())) statusClass = "status-draft";
                                
                                // 2. Format Dates
                                String dateSubStr = (req.getArDateSubmitted() != null) ? sdf.format(req.getArDateSubmitted()) : "-";
                                String dateApprStr = (req.getArApprovedDate() != null) ? sdf.format(req.getArApprovedDate()) : "-";
                                
                                // 3. Get Item Summary
                                String items = summaryMap.get(req.getRequestID());
                                if (items == null || items.isEmpty()) items = "No items specified";

                                // 4. Get Usernames
                                String requesterName = userMap.getOrDefault(req.getRequestedBy(), req.getRequestedBy());
                                String approverName = "-";
                                if (req.getArApprovedBy() != null) {
                                    approverName = userMap.getOrDefault(req.getArApprovedBy(), req.getArApprovedBy());
                                }
                    %>
                        <tr>
                            <td style="color:#64748b; text-align: center;"><%= count++ %></td>
                            
                            <td style="font-family: monospace; font-size: 13px;"><%= dateSubStr %></td>
                            
                            <td>
                                <div style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 250px; color: #334155;">
                                    <%= items %>
                                </div>
                            </td>

                            <%-- [LOGIC]: Display Requester Name --%>
                            <% if(showRequesterColumn) { %>
                                <td style="font-weight:bold; color: #1e293b;"><%= requesterName %></td>
                            <% } %>

                            <td style="text-align: center;">
                                <span class="status <%= statusClass %>"><%= req.getArStatus() %></span>
                            </td>
                            
                            <td style="font-size: 13px; color: #475569;">
                                <%= approverName %>
                            </td>
                            
                            <td style="font-family: monospace; font-size: 13px;">
                                <%= dateApprStr %>
                            </td>
                            
                            <td style="text-align: center;">
                                <a href="viewRequest?id=<%= req.getRequestID() %>" class="action-link view-link" title="View Details">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            </td>
                        </tr>
                    <% 
                            } 
                        } 
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function filterTable() {
            var input, filter, table, tr, td, i;
            input = document.getElementById("searchInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("requestTable");
            tr = table.getElementsByTagName("tr");

            // Pass the Java boolean to JS
            var hasReqCol = <%= showRequesterColumn %>;

            for (i = 1; i < tr.length; i++) {
                var tdDate = tr[i].getElementsByTagName("td")[1];
                var tdItem = tr[i].getElementsByTagName("td")[2];
                // Adjust index: If Req col exists, it's index 3. Else Status is index 3.
                var tdReq  = hasReqCol ? tr[i].getElementsByTagName("td")[3] : null;
                var tdStat = hasReqCol ? tr[i].getElementsByTagName("td")[4] : tr[i].getElementsByTagName("td")[3];
                
                if (tdItem || tdStat) {
                    var txtDate = tdDate ? (tdDate.textContent || tdDate.innerText) : "";
                    var txtItem = tdItem ? (tdItem.textContent || tdItem.innerText) : "";
                    var txtReq  = tdReq ? (tdReq.textContent || tdReq.innerText) : "";
                    var txtStat = tdStat ? (tdStat.textContent || tdStat.innerText) : "";
                    
                    if (txtItem.toUpperCase().indexOf(filter) > -1 || 
                        txtStat.toUpperCase().indexOf(filter) > -1 || 
                        txtReq.toUpperCase().indexOf(filter) > -1 ||
                        txtDate.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
    </script>
</body>
</html>