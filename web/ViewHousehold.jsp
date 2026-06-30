<%-- Document: ViewHousehold.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Household" %>

<%-- IC Formatting Helper --%>
<%! 
    public String formatIC(String ic, String nationality) {
        if (ic == null || ic.trim().isEmpty()) return "-";
        // If not Malaysian, return the passport number exactly as it is without dashes
        if (nationality != null && !nationality.equalsIgnoreCase("Malaysian")) {
            return ic;
        }
        
        // If Malaysian, format with dashes (xxxxxx-xx-xxxx)
        String clean = ic.replaceAll("[^0-9]", "");
        if (clean.length() == 12) {
            return clean.substring(0, 6) + "-" + clean.substring(6, 8) + "-" + clean.substring(8);
        }
        return ic;
    }
%>

<%
    // Session Access Control
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    // Retrieve Household Object from Servlet
    Household h = (Household) request.getAttribute("household");
    if (h == null) {
        out.println("Error: Household data not found.");
        return;
    }
    
    // Safety checks for null values
    String nationality = (h.getH_Nationality() != null) ? h.getH_Nationality() : "Malaysian";
    String idLabel = nationality.equalsIgnoreCase("Malaysian") ? "IC Number" : "Passport Number";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - View Household Member</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; display: flex; justify-content: center; }
        
        .form-card { background: white; width: 100%; max-width: 800px; height: fit-content; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; margin-bottom: 50px; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        .page-title { font-size: 24px; font-weight: 700; color: #1f2937; margin: 0; }
        
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 30px; row-gap: 20px; }
        .form-group { margin-bottom: 5px; }
        .form-group.full-width { grid-column: span 2; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-input { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #f8fafc; color: #4b5563; font-weight: 500; box-sizing: border-box;}
        
        /* Highlight for Tent Assignment */
        .tent-field { font-weight: bold; color: #0b5ea8; border: 1px solid #0b5ea8; background-color: #eff6ff; }

        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e2e8f0; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 14px; font-weight: 600; text-decoration: none; text-align: center; border: none; cursor: pointer; transition: 0.2s;}
        .btn-cancel { background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-cancel:hover { background-color: #e2e8f0; }
        .btn-edit { background-color: #0b5ea8; color: white; }
        .btn-edit:hover { background-color: #094b86; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <div class="form-header">
                <a href="viewBeneficiary?id=<%= h.getBeneficiaryID() %>" style="color:#4b5563; transition: 0.2s;" onmouseover="this.style.color='#0b5ea8'" onmouseout="this.style.color='#4b5563'">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Household Member Details</h1>
            </div>
            
            <div class="form-grid">
                
                <div class="form-group full-width">
                    <label>Full Name</label>
                    <input type="text" class="form-input" value="<%= h.getH_Name() %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Relationship</label>
                    <input type="text" class="form-input" value="<%= h.getH_Relationship() %>" readonly>
                </div>

                <div class="form-group">
                    <label>Assigned Tent</label>
                    <input type="text" class="form-input tent-field" value="<%= (h.getTentID() != null) ? h.getTentID() : "Not Assigned" %>" readonly>
                </div>

                <div class="form-group">
                    <label>Nationality</label>
                    <input type="text" class="form-input" value="<%= nationality %>" readonly>
                </div>
                
                <div class="form-group">
                    <label><%= idLabel %></label>
                    <input type="text" class="form-input" value="<%= formatIC(h.getH_IC(), nationality) %>" readonly>
                </div>

                <div class="form-group">
                    <label>OKU Status</label>
                    <input type="text" class="form-input" value="<%= h.getH_OKUStatus() %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Current Status</label>
                    <input type="text" class="form-input" value="<%= h.getH_Status() %>" readonly>
                </div>

                <div class="form-group full-width">
                    <label>Health History</label>
                    <input type="text" class="form-input" value="<%= (h.getH_HealthHistory() != null && !h.getH_HealthHistory().isEmpty()) ? h.getH_HealthHistory() : "-" %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Allergies</label>
                    <input type="text" class="form-input" value="<%= (h.getH_Allergic() != null && !h.getH_Allergic().isEmpty()) ? h.getH_Allergic() : "-" %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Diet Preference</label>
                    <input type="text" class="form-input" value="<%= (h.getH_DietPreference() != null && !h.getH_DietPreference().isEmpty()) ? h.getH_DietPreference() : "-" %>" readonly>
                </div>
                
            </div>

            <div class="btn-container">
                <a href="viewBeneficiary?id=<%= h.getBeneficiaryID() %>" class="btn btn-cancel">Back to Family Profile</a>
                <a href="editHousehold?householdId=<%= h.getHouseholdID() %>" class="btn btn-edit">Edit Member Details</a>
            </div>

        </div>
    </div>

</body>
</html>