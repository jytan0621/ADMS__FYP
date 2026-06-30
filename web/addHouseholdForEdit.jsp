<%-- Document: addHouseholdForEdit.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    // Capture the ID passed from the Edit Form
    String beneficiaryId = request.getParameter("beneficiaryId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Add Household Member</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
        /* Exact styling from your previous forms */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; display: flex; justify-content: center; }
        .form-card { background: white; width: 100%; max-width: 800px; height: fit-content; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; margin-bottom: 50px; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        .page-title { font-size: 24px; font-weight: 700; color: #1f2937; margin: 0; }
        .back-btn { background: none; border: none; cursor: pointer; color: #4b5563; display: flex; align-items: center; padding: 0; }
        .back-btn:hover { color: #0b5ea8; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 30px; row-gap: 20px; }
        .form-group { margin-bottom: 5px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-input { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #fff; transition: border-color 0.2s; }
        .form-input:focus { border-color: #0b5ea8; }
        .btn-save { background-color: #0b5ea8; color: white; width: 100%; padding: 12px; border: none; border-radius: 4px; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 30px; }
        .btn-save:hover { background-color: #094b85; }
    </style>
    
    <script>
        // --- IC Formatting Logic ---
        function formatIC(input) {
            let val = input.value.replace(/\D/g, '');
            
            // Limit to 12 digits
            if (val.length > 12) val = val.substring(0, 12);

            // Add dashes
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
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <div class="main-content-scrollable">
        <div class="form-card">
            <div class="form-header">
                <a href="editBeneficiary?id=<%= beneficiaryId %>" class="back-btn">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Add Household Member</h1>
            </div>
            
            <form action="insertHouseholdReturnToEdit" method="POST">
                <input type="hidden" name="beneficiaryId" value="<%= beneficiaryId %>">
                
                <div class="form-grid">
                    <div class="form-group"><label>Name</label><input type="text" name="hName" class="form-input" required></div>
                    
                    <%-- IC Formatting Applied --%>
                    <div class="form-group">
                        <label>IC Number</label>
                        <input type="text" name="hIC" class="form-input" 
                               placeholder="e.g. 900101-01-1234" maxlength="14" 
                               oninput="formatIC(this)" required>
                    </div>
                    
                    <div class="form-group"><label>Relationship</label><input type="text" name="hRelationship" class="form-input" required></div>
                    <div class="form-group"><label>OKU Status</label>
                        <select name="hOku" class="form-input">
                            <option value="No">No</option><option value="Yes">Yes</option>
                        </select>
                    </div>
                    <div class="form-group"><label>Health History</label><input type="text" name="hHealthHistory" class="form-input"></div>
                    <div class="form-group"><label>Allergic</label><input type="text" name="hAllergic" class="form-input"></div>
                    <div class="form-group"><label>Diet Preference</label><input type="text" name="hDietPreference" class="form-input"></div>
                    
                    <div class="form-group"><label>Status</label>
                        <select name="hStatus" class="form-input">
                            <option value="ADMITTED">Admitted (On-site)</option>
                            <option value="EXTERNAL_SHELTER">External Shelter (Different Center)</option>
                            <option value="PRIVATE_ACCOMMODATION">Private Accommodation</option>
                            <option value="DISCHARGED">Discharged</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn-save">Add Member</button>
            </form>
        </div>
    </div>
</body>
</html>