<%-- Document: newBeneficiary.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.Household" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Security check for Staff
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    // Get Household List from Session (Wizard Style)
    List<Household> householdList = (List<Household>) session.getAttribute("tempHouseholdList");
    if (householdList == null) householdList = new ArrayList<>();
    
    // AUTO-CALCULATE SIZE: 1 (Beneficiary) + List Size
    int householdSize = 1 + householdList.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Register New Beneficiary</title>
    <link rel="stylesheet" href="Sidebar.css">
    <style>
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
        .form-label { min-width: 140px; color: #000; font-size: 16px; font-weight: 600; }
        .form-input, select { flex: 1; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #fff; transition: 0.2s; }
        .form-input:focus, select:focus { border-color: #0b5ea8; box-shadow: 0 0 0 3px rgba(11,94,168,0.1); }
        .form-input[readonly] { background-color: #f1f5f9; cursor: not-allowed; font-weight: bold; color: #475569; }
        
        /* Table Styles */
        .household-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        .table-label { display: block; margin-bottom: 16px; color: #0f172a; font-size: 18px; font-weight: bold; }
        .table-container { border: 1px solid #cbd5e1; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05);}
        table { width: 100%; border-collapse: collapse; background: white; }
        th { border-bottom: 2px solid #cbd5e1; padding: 12px 16px; text-align: left; font-weight: bold; color: #334155; background-color: #f8fafc; }
        td { border-bottom: 1px solid #e2e8f0; padding: 12px 16px; color: #1e293b; vertical-align: middle; }
        .btn-add-row { display: inline-block; background-color: #e0f2fe; color: #0284c7; padding: 10px 16px; border-radius: 6px; font-weight: 600; text-decoration: none; margin-top: 15px; border: 1px solid #bae6fd; transition: 0.2s; }
        .btn-add-row:hover { background-color: #bae6fd; color: #0369a1; }
        .btn-delete { color: #dc2626; text-decoration: none; font-weight: 600; background: #fee2e2; padding: 6px 12px; border-radius: 4px; font-size: 13px; transition: 0.2s; }
        .btn-delete:hover { background: #fca5a5; }
        .btn-save { background-color: #0b5ea8; color: white; width: 100%; padding: 15px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin-top: 32px; font-weight: bold; transition: 0.2s; }
        .btn-save:hover { background-color: #094b86; }
        
        .debug-error { background-color: #fee2e2; border: 1px solid #ef4444; color: #b91c1c; padding: 12px; margin-bottom: 20px; border-radius: 6px; font-weight: 500; }
    </style>
    
    <script>
        // --- 1. Dynamic UI Logic ---
        function updateFlow() {
            const nat = document.getElementById("nationality").value;
            const countryGroup = document.getElementById("country-group");
            const countryInput = document.getElementById("country-input");
            const idLabel = document.getElementById("id-label");
            const icInput = document.getElementById("ic-input");

            if (nat === "Non-Malaysian") {
                countryGroup.style.display = "flex";
                countryInput.required = true;
                idLabel.innerText = "Passport No:";
                icInput.placeholder = "Enter Passport Number";
                icInput.maxLength = 20; // Allow longer passports
            } else {
                countryGroup.style.display = "none";
                countryInput.required = false;
                idLabel.innerText = "IC Number:";
                icInput.placeholder = "e.g. 900101-01-1234";
                icInput.maxLength = 14;
                formatIC(icInput); // Re-apply dashes instantly if switching back
            }
        }

        // --- 2. Smart IC / Passport Formatting ---
        function formatIC(input) {
            const nat = document.getElementById("nationality").value;
            
            if (nat === "Non-Malaysian") {
                // Free typing for passports, just auto-capitalize
                input.value = input.value.toUpperCase();
                return; 
            }
            
            // Malaysian IC Formatting
            let val = input.value.replace(/\D/g, ''); // Strip non-numbers
            if (val.length > 12) val = val.substring(0, 12); // Max 12 numbers

            if (val.length > 8) {
                val = val.substring(0, 6) + '-' + val.substring(6, 8) + '-' + val.substring(8);
            } else if (val.length > 6) {
                val = val.substring(0, 6) + '-' + val.substring(6);
            }
            input.value = val;
        }

        // --- 3. Postcode Lookup ---
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
                    } else {
                        alert("Postcode not found!");
                    }
                }
            };
            xhttp.open("GET", "PostcodeLookupServlet?postcode=" + pcode, true);
            xhttp.send();
        }
    </script>
</head>
<body>

    <header class="fixed-header">
        <div style="display: flex; align-items: center; gap: 12px;">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span style="font-size: 20px; font-weight: bold; letter-spacing: 0.5px;">ADMS</span>
        </div>
        <div style="font-weight: 500; font-size: 14px; background: rgba(255,255,255,0.1); padding: 4px 12px; border-radius: 4px;">
            <%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %>
        </div>
    </header>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" />
    </div>

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <% 
                String error = request.getParameter("error");
                if ("AlreadyRegistered".equals(error)) {
            %>
                <div style="background-color: #fee2e2; color: #dc2626; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #fecaca; text-align: center;">
                    ⚠️ This IC Number is already registered and currently active in our system. 
                </div>
            <% } %>

            <div class="form-header">
                <a href="listBeneficiary" class="back-btn">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <h1 class="page-title">Register New Beneficiary</h1>
            </div>
            
            <form id="staffBeneForm" action="insertBeneficiary" method="POST">
                <div class="form-grid">
                    
                    <div class="form-group full-width">
                        <label class="form-label">Full Name <span style="color:red;">*</span></label>
                        <input type="text" name="B_Name" class="form-input" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Nationality <span style="color:red;">*</span></label>
                        <select id="nationality" name="B_IsMalaysian" class="form-input" onchange="updateFlow()" required>
                            <option value="Malaysian">Malaysian</option>
                            <option value="Non-Malaysian">Non-Malaysian</option>
                        </select>
                    </div>

                    <div class="form-group" id="country-group" style="display:none;">
                        <label class="form-label">Specify Country <span style="color:red;">*</span></label>
                        <input type="text" id="country-input" name="B_Nationality" class="form-input" placeholder="e.g. Indonesia">
                    </div>

                    <div class="form-group">
                        <label class="form-label" id="id-label">IC Number <span style="color:red;">*</span></label>
                        <input type="text" id="ic-input" name="B_ICNumber" class="form-input" placeholder="e.g. 900101-01-1234" oninput="formatIC(this)" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Admission Status <span style="color:red;">*</span></label>
                        <select name="B_Status" class="form-input">
                            <option value="Active">Active (Admitted)</option>
                            <option value="Inactive">Inactive (Discharged)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Contact No <span style="color:red;">*</span></label>
                        <input type="text" name="B_ContactNumber" class="form-input" placeholder="01X-XXXXXXX" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Race <span style="color:red;">*</span></label>
                        <select name="B_Race" class="form-input" required>
                            <option value="Malay">Malay</option>
                            <option value="Chinese">Chinese</option>
                            <option value="Indian">Indian</option>
                            <option value="Others">Others</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Religion <span style="color:red;">*</span></label>
                        <select name="B_Religion" class="form-input" required>
                            <option value="Islam">Islam</option>
                            <option value="Buddhism">Buddhism</option>
                            <option value="Hinduism">Hinduism</option>
                            <option value="Christianity">Christianity</option>
                            <option value="Others">Others</option>
                        </select>
                    </div>
                    
                    <div class="form-group full-width">
                        <label class="form-label">Street Address <span style="color:red;">*</span></label>
                        <input type="text" name="Street" class="form-input" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Postcode <span style="color:red;">*</span></label>
                        <input type="number" name="Postcode" id="postcode" class="form-input" onblur="fetchAddress()" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">City</label>
                        <input type="text" id="city" name="City" class="form-input" readonly>
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label">State</label>
                        <input type="text" id="state" name="State" class="form-input" readonly>
                    </div>

                    <div class="form-group">
                        <label class="form-label">OKU Status <span style="color:red;">*</span></label>
                        <select name="B_OKUStatus" class="form-input" required>
                            <option value="No">No</option>
                            <option value="Yes">Yes</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Household Size:</label>
                        <input type="number" name="HouseholdSize" class="form-input" value="<%= householdSize %>" readonly="" style="background-color:#f3f4f6; font-weight:bold;">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Health History</label>
                        <input type="text" name="B_HealthHistory" class="form-input" placeholder="e.g. Asthma">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Allergies</label>
                        <input type="text" name="B_Allergic" class="form-input" placeholder="e.g. Seafood">
                    </div>
                    <div class="form-group full-width">
                        <label class="form-label">Diet Preferences</label>
                        <input type="text" name="B_DietPreference" class="form-input" placeholder="e.g. Vegetarian">
                    </div>
                </div>

                <div class="household-section">
                    <label class="table-label">Family Members / Dependents</label>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align:center;">No</th>
                                    <th>Name</th>
                                    <th>ID Number</th>
                                    <th>Relationship</th>
                                    <th style="width: 100px; text-align:center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (householdList.isEmpty()) { %>
                                    <tr><td colspan="6" style="text-align: center; color: #64748b; padding: 40px; font-style: italic;">No dependents added yet. Click below to add.</td></tr>
                                <% } else {
                                    int count = 1;
                                    for (Household h : householdList) { %>
                                    <tr>
                                        <td style="text-align:center; font-weight:bold; color:#64748b;"><%= count++ %></td>
                                        <td style="font-weight:600;"><%= h.getH_Name() %></td>
                                        <td><%= h.getH_IC() %></td>
                                        <td><%= h.getH_Relationship() %></td>
                                        <td style="text-align:center;">
                                            <a href="removeHouseholdFromSession?index=<%= count-2 %>" class="btn-delete">Remove</a>
                                        </td>
                                    </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                    <a href="NewHousehold.jsp" class="btn-add-row">+ Add Household Member</a>
                </div>

                <button type="submit" class="btn-save">Save Beneficiary Record</button>
            </form>
        </div>
    </div>

    <script>
        // ==========================================
    // SMART SAVE SCRIPT (FIXED AUTO-COUNT)
    // ==========================================
    document.addEventListener('DOMContentLoaded', function() {
        updateFlow(); 

        const form = document.getElementById('staffBeneForm');
        if (!form) return;

        // 1. FRESH LOAD DETECTION
        // 1. FRESH LOAD DETECTION
        const referrer = document.referrer.toLowerCase();
        
        // Only wipe the memory if arriving from the dashboard, sidebar, or list page.
        // Keep the memory if returning from a household page, or if the page simply reloads (like when removing a member).
        const isFromSameFlow = referrer.includes('household') || referrer.includes('newbeneficiary') || referrer.includes('victimregistration');
        
        if (referrer && !isFromSameFlow) {
            sessionStorage.removeItem('ADMS_StaffBeneBackup');
        }

        // 2. RESTORE DATA
        try {
            const savedData = sessionStorage.getItem('ADMS_StaffBeneBackup');
            if (savedData) {
                const data = JSON.parse(savedData);
                const allInputs = form.querySelectorAll('input, select');
                
                allInputs.forEach(function(input) {
                    // MAGIC FIX: Explicitly skip the HouseholdSize box so the server math isn't overwritten
                    if (input.name && input.name !== 'HouseholdSize' && data[input.name] !== undefined) {
                        input.value = data[input.name];
                    }
                });
                
                updateFlow(); 
            }
        } catch (e) { console.error("Auto-save restore failed:", e); }

        // 3. SAVE FUNCTION
        function saveFormState() {
            const data = {};
            const allInputs = form.querySelectorAll('input, select');
            allInputs.forEach(function(input) {
                // MAGIC FIX: Do not save the Household Size to memory either
                if (input.name && input.name !== 'HouseholdSize') {
                    data[input.name] = input.value;
                }
            });
            sessionStorage.setItem('ADMS_StaffBeneBackup', JSON.stringify(data));
        }

        // 4. ONLY SAVE WHEN CLICKING SPECIFIC HOUSEHOLD BUTTONS
        const addBtn = document.querySelector('.btn-add-row');
        if (addBtn) addBtn.addEventListener('click', saveFormState);

        const deleteBtns = document.querySelectorAll('.btn-delete');
        deleteBtns.forEach(btn => btn.addEventListener('click', saveFormState));

        // 5. CLEAR MEMORY WHEN FINISHED OR CANCELLED
        form.addEventListener('submit', function() {
            sessionStorage.removeItem('ADMS_StaffBeneBackup');
        });

        const backBtn = document.querySelector('.back-btn');
        if (backBtn) {
            backBtn.addEventListener('click', function() {
                sessionStorage.removeItem('ADMS_StaffBeneBackup');
            });
        }
    });
    </script>

</body>
</html>