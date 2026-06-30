<%-- Document: addHousehold.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Add Household Member</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
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
        .form-group.full-width { grid-column: span 2; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #fff; transition: border-color 0.2s; box-sizing: border-box; }
        .form-group input:focus, .form-group select:focus { border-color: #0b5ea8; }
        .btn-save { background-color: #0b5ea8; color: white; width: 100%; padding: 12px; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 30px; transition: 0.2s; }
        .btn-save:hover { background-color: #094b85; }
    </style>
    
    <script>
        // --- 1. Dynamic Flow for Nationality ---
        function updateFlow() {
            const nat = document.getElementById("h-nationality").value;
            const countryGroup = document.getElementById("country-group");
            const countryInput = document.getElementById("country-input");
            const idLabel = document.getElementById("id-label");
            const icInput = document.getElementById("ic-input");

            if (nat === "Non-Malaysian") {
                countryGroup.style.display = "block";
                countryInput.required = true;
                idLabel.innerText = "Passport Number *";
                icInput.placeholder = "Enter Passport Number";
                icInput.maxLength = 20; // Passports can be longer
            } else {
                countryGroup.style.display = "none";
                countryInput.required = false;
                idLabel.innerText = "IC Number *";
                icInput.placeholder = "e.g. 901212-11-5566";
                icInput.maxLength = 14;
                formatIC(icInput); // Instantly fix formatting if switched back
            }
        }

        // --- 2. Smart IC / Passport Formatting ---
        function formatIC(input) {
            const nat = document.getElementById("h-nationality").value;
            
            if (nat === "Non-Malaysian") {
                // Free typing for passports, auto-capitalize
                input.value = input.value.toUpperCase();
                return;
            }
            
            // Force dashes for Malaysian IC
            let val = input.value.replace(/\D/g, ''); // Remove non-digits
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
<body onload="updateFlow()">
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    
    <div class="main-content-scrollable">
        <div class="form-card">
            <div class="form-header">
                <a href="NewBeneficiary.jsp" class="back-btn">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Add Household Member</h1>
            </div>
            
            <form action="addHouseholdToSession" method="POST">
                <div class="form-grid">
                    
                    <div class="form-group full-width">
                        <label>Full Name <span style="color:red;">*</span></label>
                        <input type="text" name="hName" required placeholder="Full Name">
                    </div>
                    
                    <div class="form-group">
                        <label>Nationality <span style="color:red;">*</span></label>
                        <select id="h-nationality" name="hIsMalaysian" onchange="updateFlow()" required>
                            <option value="Malaysian">Malaysian</option>
                            <option value="Non-Malaysian">Non-Malaysian</option>
                        </select>
                    </div>

                    <div class="form-group" id="country-group" style="display:none;">
                        <label>Specify Country <span style="color:red;">*</span></label>
                        <input type="text" id="country-input" name="hNationality" placeholder="e.g. Indonesia">
                    </div>

                    <div class="form-group full-width">
                        <label id="id-label">IC Number <span style="color:red;">*</span></label>
                        <input type="text" id="ic-input" name="hIC" required 
                               placeholder="e.g. 901212-11-5566" 
                               oninput="formatIC(this)">
                    </div>
                    
                    <div class="form-group">
                        <label>Relationship <span style="color:red;">*</span></label>
                        <input type="text" name="hRelationship" required placeholder="e.g. Spouse, Son">
                    </div>

                    <div class="form-group">
                        <label>OKU Status <span style="color:red;">*</span></label>
                        <select name="hOku" required>
                            <option value="No">No</option>
                            <option value="Yes">Yes</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Status <span style="color:red;">*</span></label>
                        <select name="hStatus" required>
                            <option value="ADMITTED">Admitted (On-site)</option>
                            <option value="EXTERNAL_SHELTER">External Shelter (Different Center)</option>
                            <option value="PRIVATE_ACCOMMODATION">Private Accommodation</option>
                            <option value="DISCHARGED">Discharged</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label>Health History</label>
                        <input type="text" name="hHealthHistory" placeholder="Optional (e.g. Asthma)">
                    </div>
                    
                    <div class="form-group">
                        <label>Allergies</label>
                        <input type="text" name="hAllergic" placeholder="Optional (e.g. Seafood)">
                    </div>
                    
                    <div class="form-group">
                        <label>Diet Preference</label>
                        <input type="text" name="hDietPreference" placeholder="Optional (e.g. Vegetarian)">
                    </div>

                </div>
                <button type="submit" class="btn-save">Add Member</button>
            </form>
        </div>
    </div>
</body>
</html>