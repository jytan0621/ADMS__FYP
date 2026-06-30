<%-- Document: editBeneficiary.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Beneficiary" %>
<%@ page import="com.Model.Household" %>
<%@ page import="com.DAO.BeneficiaryDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    String id = request.getParameter("id");
    BeneficiaryDAO dao = new BeneficiaryDAO();
    Beneficiary b = dao.selectBeneficiaryByID(id);
    
    if (b == null) { response.sendRedirect("listBeneficiary"); return; }
    
    List<Household> hList = dao.selectHouseholdByBeneficiaryID(id);
    if (hList == null) hList = new ArrayList<>();
    
    // Auto-calculate real size
    int realHouseholdSize = 1 + hList.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Edit Beneficiary</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
        /* Exact Styles from Previous Version */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; }
        .page-title { font-size: 32px; font-weight: 400; color: #000; margin: 0; }
        .back-btn { background: none; border: none; cursor: pointer; color: #000; display: flex; align-items: center; padding: 0; }
        
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 48px; row-gap: 20px; }
        .form-group { display: flex; align-items: center; gap: 16px; }
        .form-group.full-width { grid-column: span 2; }
        .form-label { min-width: 140px; color: #000; font-size: 16px; font-weight: 400; }
        .form-input, select { flex: 1; padding: 8px 12px; border: 1px solid #9ca3af; border-radius: 4px; font-size: 14px; outline: none; background-color: #fff; }
        .form-input:focus, select:focus { border-color: #4A7BA7; }
        .form-input[readonly] { background-color: #f3f4f6; cursor: not-allowed; }

        .household-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        .table-label { display: block; margin-bottom: 16px; color: #000; font-size: 16px; font-weight: 600; }
        .table-container { border: 1px solid #9ca3af; border-radius: 4px; overflow: hidden;}
        table { width: 100%; border-collapse: collapse; }
        th { border: 1px solid #9ca3af; padding: 8px 16px; text-align: left; font-weight: bold; color: #000; background-color: white; }
        td { border: 1px solid #9ca3af; padding: 8px 16px; color: #000; vertical-align: middle; }

        .btn-add-row { background: none; border: none; color: #0b5ea8; text-decoration: underline; font-weight: 600; cursor: pointer; font-size: 14px; margin-top: 15px; display: inline-block; }
        .action-link { margin-right: 10px; font-size: 13px; font-weight: 600; text-decoration: none; }
        .edit-link { color: #0b5ea8; }
        .delete-link { color: #dc2626; }
        
        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 40px; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; border: none; text-decoration: none; text-align: center; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-save { background-color: #4A7BA7; color: white; width: 200px; }
    </style>
    
    <script>
        // --- 1. IC Formatting Logic ---
        function formatIC(input) {
            let val = input.value.replace(/\D/g, '');
            if (val.length > 12) val = val.substring(0, 12);
            if (val.length > 8) {
                val = val.substring(0, 6) + '-' + val.substring(6, 8) + '-' + val.substring(8);
            } else if (val.length > 6) {
                val = val.substring(0, 6) + '-' + val.substring(6);
            }
            input.value = val;
        }

        // --- 2. Postcode Lookup ---
        function fetchAddress() {
            var pcode = document.getElementById("postcode").value;
            if(pcode.length === 0) return;
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState === 4 && this.status === 200) {
                    var response = JSON.parse(this.responseText);
                    if(response.found === true) {
                        document.getElementById("city").value = response.city;
                        document.getElementById("state").value = response.state;
                    }
                }
            };
            xhttp.open("GET", "PostcodeLookupServlet?postcode=" + pcode, true);
            xhttp.send();
        }
        
        window.onload = function() { 
            // Ensure address is populated if postcode exists
            fetchAddress(); 
        };
    </script>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <div class="form-header">
                <a href="viewBeneficiary?id=<%= b.getBeneficiaryID() %>" class="back-btn">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Edit Beneficiary Details</h1>
            </div>

            <form action="updateBeneficiary" method="POST">
                <input type="hidden" name="id" value="<%= b.getBeneficiaryID() %>">

                <div class="form-grid">
                    <div class="form-group"><label class="form-label">Name:</label><input type="text" name="B_Name" class="form-input" value="<%= b.getB_Name() %>" required></div>
                    
                    <%-- IC Formatting Applied --%>
                    <div class="form-group">
                        <label class="form-label">IC Number:</label>
                        <input type="text" name="B_ICNumber" class="form-input" 
                               value="<%= b.getB_ICNumber() %>" maxlength="14" 
                               oninput="formatIC(this)" required>
                    </div>
                    
                    <div class="form-group"><label class="form-label">Race:</label>
                        <select name="B_Race" class="form-input">
                            <option value="Malay" <%= "Malay".equalsIgnoreCase(b.getB_Race()) ? "selected" : "" %>>Malay</option>
                            <option value="Chinese" <%= "Chinese".equalsIgnoreCase(b.getB_Race()) ? "selected" : "" %>>Chinese</option>
                            <option value="Indian" <%= "Indian".equalsIgnoreCase(b.getB_Race()) ? "selected" : "" %>>Indian</option>
                            <option value="Others" <%= "Others".equalsIgnoreCase(b.getB_Race()) ? "selected" : "" %>>Others</option>
                        </select>
                    </div>
                    <div class="form-group"><label class="form-label">Religion:</label>
                        <select name="B_Religion" class="form-input">
                            <option value="Islam" <%= "Islam".equalsIgnoreCase(b.getB_Religion()) ? "selected" : "" %>>Islam</option>
                            <option value="Buddhism" <%= "Buddhism".equalsIgnoreCase(b.getB_Religion()) ? "selected" : "" %>>Buddhism</option>
                            <option value="Hinduism" <%= "Hinduism".equalsIgnoreCase(b.getB_Religion()) ? "selected" : "" %>>Hinduism</option>
                            <option value="Christianity" <%= "Christianity".equalsIgnoreCase(b.getB_Religion()) ? "selected" : "" %>>Christianity</option>
                            <option value="Others" <%= "Others".equalsIgnoreCase(b.getB_Religion()) ? "selected" : "" %>>Others</option>
                        </select>
                    </div>
                    <div class="form-group"><label class="form-label">Nationality:</label><input type="text" name="B_Nationality" class="form-input" value="<%= b.getB_Nationality() %>"></div>
                    <div class="form-group"><label class="form-label">Contact:</label><input type="text" name="B_ContactNumber" class="form-input" value="<%= b.getB_ContactNumber() %>"></div>
                    <div class="form-group full-width"><label class="form-label">Street:</label><input type="text" name="Street" class="form-input" value="<%= b.getStreet() %>"></div>
                    
                    <div class="form-group"><label class="form-label">Postcode:</label>
                        <input type="text" name="Postcode" id="postcode" class="form-input" value="<%= b.getPostcode() %>" onblur="fetchAddress()">
                    </div>
                    <div class="form-group"><label class="form-label">City:</label><input type="text" id="city" class="form-input" readonly></div>
                    <div class="form-group"><label class="form-label">State:</label><input type="text" id="state" class="form-input" readonly></div>
                    
                    <div class="form-group"><label class="form-label">OKU Status:</label>
                        <select name="B_OKUStatus" class="form-input">
                            <option value="No" <%= "No".equalsIgnoreCase(b.getB_OKUStatus()) ? "selected" : "" %>>No</option>
                            <option value="Yes" <%= "Yes".equalsIgnoreCase(b.getB_OKUStatus()) ? "selected" : "" %>>Yes</option>
                        </select>
                    </div>
                    <div class="form-group"><label class="form-label">Health History:</label><input type="text" name="B_HealthHistory" class="form-input" value="<%= b.getB_HealthHistory() %>"></div>
                    <div class="form-group"><label class="form-label">Allergic:</label><input type="text" name="B_Allergic" class="form-input" value="<%= b.getB_Allergic() %>"></div>
                    <div class="form-group"><label class="form-label">Diet Pref:</label><input type="text" name="B_DietPreference" class="form-input" value="<%= b.getB_DietPreference() %>"></div>
                    
                    <div class="form-group full-width"><label class="form-label">Admission Status:</label>
                        <select name="B_Status" class="form-input">
                            <option value="Active" <%= "Active".equalsIgnoreCase(b.getB_Status()) ? "selected" : "" %>>Active (Admitted)</option>
                            <option value="Inactive" <%= "Inactive".equalsIgnoreCase(b.getB_Status()) ? "selected" : "" %>>Inactive (Discharged)</option>
                        </select>
                    </div>
                    
                    <%-- Auto-Calculated Size (ReadOnly) --%>
                    <div class="form-group"><label class="form-label">Household size:</label>
                        <input type="number" name="HouseholdSize" class="form-input" 
                               value="<%= realHouseholdSize %>" readonly style="background-color:#f3f4f6; font-weight:bold;">
                    </div>
                </div>

                <div class="household-section">
                    <label class="table-label">Household Member:</label>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">No</th>
                                    <th>Name</th>
                                    <th>IC Number</th>
                                    <th>Relationship</th>
                                    <th>Status</th>
                                    <th style="width: 120px; text-align:center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (hList.isEmpty()) { %>
                                    <tr><td colspan="6" style="text-align: center; color: #9ca3af; padding: 32px;">No household members found.</td></tr>
                                <% } else {
                                    int count = 1;
                                    for (Household h : hList) { %>
                                    <tr>
                                        <td style="text-align:center;"><%= count++ %></td>
                                        <td><%= h.getH_Name() %></td>
                                        <td><%= h.getH_IC() %></td>
                                        <td><%= h.getH_Relationship() %></td>
                                        <td><%= h.getH_Status() %></td>
                                        <td style="text-align:center;">
                                            <a href="editHousehold?householdId=<%= h.getHouseholdID() %>" class="action-link edit-link">Edit</a>
                                            <a href="deleteHousehold?householdId=<%= h.getHouseholdID() %>&beneficiaryId=<%= b.getBeneficiaryID() %>" 
                                               class="action-link delete-link" onclick="return confirm('Delete this member permanently?')">Delete</a>
                                        </td>
                                    </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>

                    <a href="addHouseholdForEdit.jsp?beneficiaryId=<%= b.getBeneficiaryID() %>" class="btn-add-row">
                        + Add Household Member
                    </a>
                </div>

                <div class="btn-container">
                    <a href="viewBeneficiary?id=<%= b.getBeneficiaryID() %>" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>