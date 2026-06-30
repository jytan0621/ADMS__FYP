<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Beneficiary" %>
<%@ page import="com.Model.Household" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%-- IC Formatting Helper --%>
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
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    Beneficiary b = (Beneficiary) request.getAttribute("beneficiary");
    List<Household> hList = (List<Household>) request.getAttribute("householdList");
    if (hList == null) hList = new ArrayList<>();

    int realHouseholdSize = 1 + hList.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - View Beneficiary</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        .page-title { font-size: 32px; font-weight: 400; color: #000; margin: 0; }
        
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 48px; row-gap: 20px; }
        .form-group { display: flex; align-items: center; gap: 16px; }
        .form-label { min-width: 140px; color: #374151; font-size: 16px; font-weight: 600; }
        .form-input { flex: 1; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; outline: none; background-color: #f8fafc; color: #4b5563; }
        .tent-input { font-weight: bold; color: #0b5ea8; border: 1px solid #0b5ea8; background-color: #eff6ff; }

        .household-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        .table-container { border: 1px solid #9ca3af; border-radius: 4px; overflow: hidden;}
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f1f5f9; padding: 12px 15px; text-align: left; font-weight: bold; color: #374151; border-bottom: 1px solid #cbd5e1; }
        td { padding: 12px 15px; border-bottom: 1px solid #e2e8f0; color: #374151; }
        .clickable-row { cursor: pointer; transition: background 0.1s; }
        .clickable-row:hover { background-color: #eff6ff; }

        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 40px; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 600; text-decoration: none; text-align: center; cursor: pointer; border: none; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-edit { background-color: #0b5ea8; color: white; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <div class="form-header">
                <a href="listBeneficiary" style="color:black;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></a>
                <h1 class="page-title">Beneficiary Details</h1>
            </div>

            <div class="form-grid">
                <div class="form-group"><label class="form-label">Name:</label><input type="text" class="form-input" value="<%= b.getB_Name() %>" readonly></div>
                <div class="form-group"><label class="form-label">IC Number:</label><input type="text" class="form-input" value="<%= formatIC(b.getB_ICNumber()) %>" readonly></div>
                
                <div class="form-group"><label class="form-label">Shelter ID:</label><input type="text" class="form-input" value="<%= (b.getShelterID() != null) ? b.getShelterID() : "-" %>" readonly></div>
                <div class="form-group"><label class="form-label">Assigned Tent:</label><input type="text" class="form-input tent-input" value="<%= (b.getTentID() != null) ? b.getTentID() : "-" %>" readonly></div>

                <div class="form-group"><label class="form-label">Race:</label><input type="text" class="form-input" value="<%= b.getB_Race() %>" readonly></div>
                <div class="form-group"><label class="form-label">Religion:</label><input type="text" class="form-input" value="<%= b.getB_Religion() %>" readonly></div>
                
                <div class="form-group"><label class="form-label">Nationality:</label><input type="text" class="form-input" value="<%= b.getB_Nationality() %>" readonly></div>
                <div class="form-group"><label class="form-label">Contact:</label><input type="text" class="form-input" value="<%= b.getB_ContactNumber() %>" readonly></div>
                
                <div class="form-group"><label class="form-label">Street:</label><input type="text" class="form-input" value="<%= b.getStreet() %>" readonly></div>
                <div class="form-group"><label class="form-label">Postcode:</label><input type="text" class="form-input" value="<%= b.getPostcode() %>" readonly></div>
                
                <div class="form-group"><label class="form-label">OKU Status:</label><input type="text" class="form-input" value="<%= b.getB_OKUStatus() %>" readonly></div>
                <div class="form-group"><label class="form-label">Status:</label><input type="text" class="form-input" value="<%= b.getB_Status() %>" readonly></div>
                
                <div class="form-group"><label class="form-label">Health History:</label><input type="text" class="form-input" value="<%= b.getB_HealthHistory() %>" readonly></div>
                <div class="form-group"><label class="form-label">Allergic:</label><input type="text" class="form-input" value="<%= b.getB_Allergic() %>" readonly></div>
                
                <div class="form-group"><label class="form-label">Diet Pref:</label><input type="text" class="form-input" value="<%= b.getB_DietPreference() %>" readonly></div>
                <div class="form-group"><label class="form-label">Household Size:</label><input type="text" class="form-input" value="<%= realHouseholdSize %>" readonly></div>
            </div>

            <div class="household-section">
                <h3 style="margin-bottom:15px; font-size:18px; color:#374151;">Household Members <span style="font-size:14px; font-weight:normal; color:#6b7280;">(Click row to view details)</span></h3>
                
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>IC Number</th>
                                <th>Relationship</th>
                                <th>Tent</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (hList.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align:center; color:#888;">No household members found.</td></tr>
                            <% } else { 
                                for (Household h : hList) { %>
                                <tr class="clickable-row" onclick="window.location='viewHousehold?householdId=<%= h.getHouseholdID() %>'">
                                    <td><%= h.getH_Name() %></td>
                                    <td><%= formatIC(h.getH_IC()) %></td>
                                    <td><%= h.getH_Relationship() %></td>
                                    <td style="font-weight:bold; color:#0b5ea8;"><%= (h.getTentID() != null) ? h.getTentID() : "-" %></td>
                                    <td><%= h.getH_Status() %></td>
                                </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="btn-container">
                <a href="listBeneficiary" class="btn btn-cancel">Back to List</a>
                <a href="editBeneficiary?id=<%= b.getBeneficiaryID() %>" class="btn btn-edit">Edit Details</a>
            </div>

        </div>
    </div>
</body>
</html>