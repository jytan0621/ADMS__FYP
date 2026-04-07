<%-- Document: EditHouseholdForm.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Household" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    Household h = (Household) request.getAttribute("household");
    if(h == null) { response.sendRedirect("listBeneficiary"); return; }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Edit Household Member</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
        /* Exact Styles from Previous Version */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; display: flex; justify-content: center; }
        .form-card { background: white; width: 100%; max-width: 800px; height: fit-content; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; margin-bottom: 50px; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        .page-title { font-size: 24px; font-weight: 700; color: #1f2937; margin: 0; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 30px; row-gap: 20px; }
        .form-group { margin-bottom: 5px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-input, select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #fff; transition: border-color 0.2s; }
        .form-input:focus, select:focus { border-color: #0b5ea8; }
        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 30px; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; border: none; text-decoration: none; text-align: center; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-save { background-color: #0b5ea8; color: white; }
    </style>
    
    <script>
        // IC Formatting Logic
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
    </script>
</head>
<body>

    <header class="fixed-header">
        <div class="flex items-center gap-3">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span class="text-xl font-bold tracking-tight">ADMS</span>
        </div>
        <div class="font-medium text-sm bg-white/10 px-3 py-1 rounded">
            <%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %>
        </div>
    </header>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" />
    </div>

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <div class="form-header">
                <a href="viewHousehold?householdId=<%= h.getHouseholdID() %>" style="color:black;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Edit Household Member</h1>
            </div>

            <form action="updateHousehold" method="POST">
                <input type="hidden" name="householdId" value="<%= h.getHouseholdID() %>">
                <input type="hidden" name="beneficiaryId" value="<%= h.getBeneficiaryID() %>">

                <div class="form-grid">
                    <div class="form-group"><label>Name</label><input type="text" name="name" class="form-input" value="<%= h.getH_Name() %>" required></div>
                    
                    <%-- IC Formatting Applied --%>
                    <div class="form-group">
                        <label>IC Number</label>
                        <input type="text" name="icNumber" class="form-input" 
                               value="<%= h.getH_IC() %>" maxlength="14" 
                               oninput="formatIC(this)" required>
                    </div>
                    
                    <div class="form-group"><label>Relationship</label><input type="text" name="relationship" class="form-input" value="<%= h.getH_Relationship() %>" required></div>
                    <div class="form-group"><label>OKU Status</label>
                        <select name="okuStatus">
                            <option value="No" <%= "No".equalsIgnoreCase(h.getH_OKUStatus()) ? "selected" : "" %>>No</option>
                            <option value="Yes" <%= "Yes".equalsIgnoreCase(h.getH_OKUStatus()) ? "selected" : "" %>>Yes</option>
                        </select>
                    </div>
                    
                    <div class="form-group"><label>Health History</label><input type="text" name="healthHistory" class="form-input" value="<%= (h.getH_HealthHistory()!=null)?h.getH_HealthHistory():"" %>"></div>
                    <div class="form-group"><label>Allergic</label><input type="text" name="allergic" class="form-input" value="<%= (h.getH_Allergic()!=null)?h.getH_Allergic():"" %>"></div>
                    
                    <div class="form-group"><label>Diet Preference</label><input type="text" name="dietPreference" class="form-input" value="<%= (h.getH_DietPreference()!=null)?h.getH_DietPreference():"" %>"></div>
                    
                    <div class="form-group"><label>Status</label>
                        <select name="status">
                            <option value="ADMITTED" <%= "ADMITTED".equalsIgnoreCase(h.getH_Status()) ? "selected" : "" %>>Admitted (On-site)</option>
                            <option value="EXTERNAL_SHELTER" <%= "EXTERNAL_SHELTER".equalsIgnoreCase(h.getH_Status()) ? "selected" : "" %>>External Shelter (Different Center)</option>
                            <option value="PRIVATE_ACCOMMODATION" <%= "PRIVATE_ACCOMMODATION".equalsIgnoreCase(h.getH_Status()) ? "selected" : "" %>>Private Accommodation</option>
                            <option value="DISCHARGED" <%= "DISCHARGED".equalsIgnoreCase(h.getH_Status()) ? "selected" : "" %>>Discharged</option>
                        </select>
                    </div>
                </div>

                <div class="btn-container">
                    <a href="viewHousehold?householdId=<%= h.getHouseholdID() %>" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

</body>
</html>