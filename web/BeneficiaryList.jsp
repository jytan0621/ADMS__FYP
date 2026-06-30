<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Beneficiary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%-- 1. DEFINE FORMATTING HELPER METHOD --%>
<%! 
    public String formatIC(String ic) {
        if (ic == null) return "";
        String clean = ic.replaceAll("[^0-9]", "");
        if (clean.length() == 12) {
            return clean.substring(0, 6) + "-" + clean.substring(6, 8) + "-" + clean.substring(8);
        }
        return ic;
    }
%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    session.setAttribute("activeMenu", "beneficiary");

    List<Beneficiary> listBeneficiary = (List<Beneficiary>) request.getAttribute("listBeneficiary");
    if (listBeneficiary == null) {
        listBeneficiary = new ArrayList<>(); 
    }

    String currentStatusFilter = request.getParameter("statusFilter");
    if(currentStatusFilter == null) currentStatusFilter = "All";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Beneficiary List</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* [Standard Resets & Layout] */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-view { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 30px; background-color: #f8fafc; }
        
        /* [Table Styling] */
        .table-card { background: white; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .data-table { width: 100%; border-collapse: collapse; background: white; }
        .data-table th { background-color: #f1f5f9; padding: 15px; text-align: left; color: #475569; font-weight: 600; text-transform: uppercase; font-size: 12px; border-bottom: 2px solid #e2e8f0; }
        .data-table td { padding: 15px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #334155; vertical-align: middle; }
        .data-table tr:hover { background-color: #f8fafc; transition: background 0.15s ease; }

        /* [Status Badges] */
        .status { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .status-active { background-color: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-inactive { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }

        .tent-badge { font-weight: bold; color: #0b5ea8; background-color: #eff6ff; padding: 4px 8px; border-radius: 4px; border: 1px solid #dbeafe; font-size: 12px; }

        /* [Buttons & Forms] */
        .btn-add { background-color: #10b981; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; }
        .btn-add:hover { background-color: #059669; }
        
        .action-link { text-decoration: none; margin-right: 10px; font-weight: 600; font-size: 13px; }
        .edit-link { color: #0b5ea8; }
        .delete-link { color: #dc2626; }
        
        .detail-link { color: #0f172a; text-decoration: none; font-weight: 600; font-size: 15px; }
        .detail-link:hover { color: #0b5ea8; text-decoration: underline; }

        .btn-toggle { padding: 5px 10px; border-radius: 4px; color: white; text-decoration: none; font-size: 12px; font-weight: bold; margin-right: 10px; display: inline-block;}
        
        .filter-group { display: flex; gap: 10px; align-items: center; }
        .filter-select { padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; outline: none; font-size: 14px; color: #334155; }
        .search-input { padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px 0 0 6px; outline: none; }
        .search-btn { padding: 8px 12px; border: 1px solid #cbd5e1; background: #e2e8f0; border-radius: 0 6px 6px 0; cursor: pointer; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <div class="main-content-view">
        
        <div style="margin-bottom: 20px; overflow: hidden; display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin:0; color:#1e293b;">Beneficiary List</h2>
            
            <div class="filter-group">
                <form action="listBeneficiary" method="get">
                    <select name="statusFilter" class="filter-select" onchange="this.form.submit()">
                        <option value="All" <%= "All".equals(currentStatusFilter) ? "selected" : "" %>>All Status</option>
                        <option value="Active" <%= "Active".equals(currentStatusFilter) ? "selected" : "" %>>Active</option>
                        <option value="Inactive" <%= "Inactive".equals(currentStatusFilter) ? "selected" : "" %>>Inactive</option>
                    </select>
                </form>

                <form action="searchBeneficiary" method="get" style="display:flex;">
                    <input type="text" name="searchIC" class="search-input" placeholder="Search by IC..." required>
                    <button type="submit" class="search-btn">Search</button>
                </form>

                <a href="newBeneficiary" class="btn-add">+ Add New</a>
            </div>
        </div>

        <% 
            String errorMsg = request.getParameter("error");
            if (errorMsg != null) {
        %>
            <div style="padding: 10px; background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; border-radius: 6px; margin-bottom: 15px;">
                <%= errorMsg %>
            </div>
        <% } %>

        <div class="table-card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px; text-align:center;">No.</th>
                        <th>Name</th>
                        <th>IC Number</th>
                        <th>Contact</th>
                        <th style="text-align:center;">Pax</th>
                        <th style="text-align:center;">Tent</th>
                        <th>Status</th>
                        <th style="width: 220px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        if (listBeneficiary.isEmpty()) { 
                    %>
                        <tr>
                            <td colspan="8" style="text-align:center; padding: 40px; color: #94a3b8;">
                                <p style="margin:0; font-size:16px; font-weight:500;">No beneficiaries found.</p>
                            </td>
                        </tr>
                    <% 
                        } else {
                            int count = 1;
                            for (Beneficiary b : listBeneficiary) {
                                String statusClass = "Active".equalsIgnoreCase(b.getB_Status()) ? "status-active" : "status-inactive";
                    %>
                    <tr>
                        <td style="text-align:center; font-weight:bold; color:#64748b;">
                            <%= count++ %>
                        </td>

                        <td>
                            <a href="viewBeneficiary?id=<%= b.getBeneficiaryID() %>" class="detail-link" title="View Details">
                                <%= b.getB_Name() %>
                            </a>
                        </td>

                        <td>
                            <span style="font-family: monospace; font-size: 13px; color: #475569;">
                                <%= formatIC(b.getB_ICNumber()) %>
                            </span>
                        </td>

                        <td><%= b.getB_ContactNumber() %></td>
                        <td style="text-align:center;"><%= b.getHouseholdSize() %></td>
                        
                        <td style="text-align:center;">
                            <span class="tent-badge"><%= (b.getTentID() != null) ? b.getTentID() : "-" %></span>
                        </td>

                        <td>
                            <span class="status <%= statusClass %>"><%= b.getB_Status() %></span>
                        </td>
                        
                        <td>
                            <a href="editBeneficiary?id=<%= b.getBeneficiaryID() %>" class="action-link edit-link">Edit</a>
                            
                            <% 
                                String currentStatus = b.getB_Status();
                                String nextStatus = "Active"; 
                                String btnText = "Activate";
                                String btnStyle = "background-color: #16a34a;"; 

                                if (currentStatus != null && "Active".equalsIgnoreCase(currentStatus)) {
                                    nextStatus = "Inactive";
                                    btnText = "Deactivate";
                                    btnStyle = "background-color: #dc2626;"; 
                                }
                            %>
                            <a href="updateStatus?id=<%= b.getBeneficiaryID() %>&status=<%= nextStatus %>" 
                               class="btn-toggle" style="<%= btnStyle %>"
                               onclick="return confirm('Change status to <%= nextStatus %>?')">
                                <%= btnText %>
                            </a>

                            <a href="deleteBeneficiary?id=<%= b.getBeneficiaryID() %>" 
                               class="action-link delete-link"
                               onclick="return confirm('Are you sure you want to delete this record?')">Delete</a>
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
</body>
</html>