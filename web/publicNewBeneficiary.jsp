<%-- Document: publicNewBeneficiary.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.Household, java.util.*" %>

<%
    // 1. KILL BROWSER CACHING (Forces the server to recalculate household size every time)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setHeader("Pragma", "no-cache"); 
    response.setDateHeader("Expires", 0); 

    // 2. Get Household List from the session
    List<Household> householdList = (List<Household>) session.getAttribute("tempHouseholdList");
    if (householdList == null) householdList = new ArrayList<>();
    
    // 3. AUTO-CALCULATE SIZE: 1 (Main Applicant) + List Size
    int householdSize = 1 + householdList.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>ADMS - Beneficiary Registration</title>
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
    <style>
        body { margin: 0; font-family: 'Segoe UI', Tahoma, sans-serif; background-color: #f1f5f9; }
        .public-header { position: sticky; top: 0; background-color: #0b5ea8; color: white; padding: 15px 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); z-index: 50; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .public-header img { height: 28px; }
        .public-header h2 { margin: 0; font-size: 20px; font-weight: 600; }
        .main-container { padding: 20px; max-width: 800px; margin: 0 auto; padding-bottom: 60px; }
        .form-card { background: white; padding: 30px 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }
        .form-header { text-align: center; margin-bottom: 25px; border-bottom: 2px solid #e2e8f0; padding-bottom: 20px;}
        .page-title { font-size: 24px; color: #0f172a; margin: 0 0 10px 0; font-weight: bold;}
        .page-subtitle { color: #64748b; font-size: 14px; margin: 0; }
        .form-grid { display: grid; grid-template-columns: 1fr; gap: 15px; } 
        @media (min-width: 600px) { .form-grid { grid-template-columns: 1fr 1fr; gap: 20px; } } 
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .full-width { grid-column: 1 / -1; }
        .hidden-field { display: none; }
        .form-label { color: #334155; font-size: 14px; font-weight: 600; }
        .form-input, select { width: 100%; box-sizing: border-box; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; outline: none; }
        .form-input[readonly] { background-color: #f8fafc; color: #475569; font-weight: 600; cursor: not-allowed; }
        
        /* Table UI */
        .household-section { margin-top: 30px; border-top: 2px dashed #e2e8f0; padding-top: 25px; }
        .table-container { width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; min-width: 500px; }
        th { background: #f8fafc; padding: 12px; text-align: left; font-size: 13px; color: #64748b; border-bottom: 1px solid #e2e8f0; }
        td { padding: 12px; font-size: 14px; border-bottom: 1px solid #f1f5f9; }
        .btn-delete { color: #dc2626; text-decoration: none; font-weight: 600; background: #fee2e2; padding: 6px 12px; border-radius: 6px; font-size: 13px; transition: 0.2s; }
        .btn-delete:hover { background: #fca5a5; }
        .btn-add-row { display: inline-block; margin-top: 15px; color: #0b5ea8; font-weight: 600; text-decoration: none; padding: 10px 16px; background: #e0f2fe; border-radius: 8px; border: 1px solid #bae6fd; }

        .btn-scan { background-color: #10b981; color: white; padding: 12px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
        .btn-action { background-color: #0b5ea8; color: white; width: 100%; padding: 15px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; }
        
        /* Camera Modal */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.9); z-index: 100; align-items: center; justify-content: center; flex-direction: column; }
        .modal-content { background: white; padding: 20px; border-radius: 12px; width: 90%; max-width: 500px; text-align: center; }
        .camera-container { position: relative; width: 100%; border-radius: 8px; background: #000; overflow: hidden; }
        #camera-feed { width: 100%; display: block; }
        .ic-guide { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 80%; aspect-ratio: 1.58; border: 2px dashed #10b981; box-shadow: 0 0 0 9999px rgba(0,0,0,0.5); }
        
        .alert-box { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; text-align: center; }
        .alert-error { background-color: #fee2e2; color: #dc2626; border: 1px solid #fecaca; }
    </style>
</head>
<body>

    <header class="public-header">
        <img src="Image/Logo_ADMS.png" alt="Logo">
        <h2>Beneficiary Registration</h2>
    </header>

    <div class="main-container">
        <div class="form-card">
            
            <% 
                String error = request.getParameter("error");
                if ("AlreadyRegistered".equals(error)) {
            %>
                <div class="alert-box alert-error">
                    ⚠️ This IC Number is already registered and currently active in our system. 
                </div>
            <% } else if ("InvalidShelterPostcode".equals(error) || "InvalidPostcodeFormat".equals(error)) { %>
                <div class="alert-box alert-error">
                    ⚠️ Invalid Shelter Postcode. We could not find a shelter matching that postcode. 
                </div>
            <% } else if ("ShelterFull".equals(error)) { %>
                <div class="alert-box alert-error">
                    ⚠️ This shelter is currently at full capacity. No tents available.
                </div>
            <% } %>
            
            <div class="form-header">
                <h1 class="page-title">Disaster Aid Registration</h1>
                <p class="page-subtitle">Submit your details to receive an assigned tent and supplies.</p>
            </div>

            <form id="publicBeneForm" action="publicInsertBeneficiary" method="POST">
                
                <div class="form-grid" style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 25px;">
                    <div class="form-group full-width">
                        <label class="form-label" style="color: #0b5ea8; font-size: 16px;">📍 Current Shelter Location</label>
                        <p style="margin: 0 0 10px 0; font-size: 13px; color: #64748b;">Please enter the postcode of the shelter you are currently staying at (Ask a volunteer if unsure).</p>
                        <input type="number" name="ShelterPostcode" class="form-input" required placeholder="e.g., 21030" style="border-color: #0b5ea8; border-width: 2px;">
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-group full-width">
                        <label class="form-label">Full Name <span style="color:red;">*</span></label>
                        <input type="text" name="B_Name" class="form-input" required placeholder="Name as per ID">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Nationality <span style="color:red;">*</span></label>
                        <select id="nationality" name="B_IsMalaysian" class="form-input" onchange="updateFlow()" required>
                            <option value="Malaysian">Malaysian</option>
                            <option value="Non-Malaysian">Non-Malaysian</option>
                        </select>
                    </div>

                    <div class="form-group hidden-field" id="country-group">
                        <label class="form-label">Specify Country <span style="color:red;">*</span></label>
                        <input type="text" id="country-input" name="B_Nationality" class="form-input" placeholder="e.g. Indonesia">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Do you have the physical document? <span style="color:red;">*</span></label>
                        <select id="hasDoc" name="hasDoc" class="form-input" onchange="updateFlow()" required>
                            <option value="yes">Yes (Scan Required)</option>
                            <option value="no">No (Manual Entry)</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label" id="id-label">IC Number <span style="color:red;">*</span></label>
                        <div style="display: flex; gap: 10px;">
                            <input type="text" id="ic-input" name="B_ICNumber" class="form-input" 
                                   required readonly placeholder="Please click Scan">

                            <button type="button" id="scan-btn" class="btn-scan" onclick="openCameraModal()">📷 Scan Document</button>
                        </div>
                        <small id="input-hint" style="color: #64748b; margin-top: 4px;">Click the green button to scan your ID.</small>
                    </div>

                    <input type="hidden" name="registration_status" id="reg-status" value="Approved">

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
                        <label class="form-label">Home Street Address <span style="color:red;">*</span></label>
                        <input type="text" name="Street" class="form-input" required placeholder="Where do you normally live?">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Home Postcode <span style="color:red;">*</span></label>
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
                        <input type="number" name="HouseholdSize" class="form-input" value="<%= householdSize %>" readonly style="background-color:#f3f4f6; font-weight:bold;">
                    </div>
                    
                </div>

                <div class="household-section">
                    <label class="form-label" style="font-size: 18px;">Family Members Present</label>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>ID Number</th>
                                    <th>Relationship</th>
                                    <th style="text-align:center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (householdList.isEmpty()) { %>
                                    <tr><td colspan="4" style="text-align:center; color:#94a3b8; padding:30px;">No family members added.</td></tr>
                                <% } else {
                                    for (int i = 0; i < householdList.size(); i++) { 
                                        Household h = householdList.get(i);
                                %>
                                    <tr>
                                        <td><strong><%= h.getH_Name() %></strong></td>
                                        <td><%= h.getH_IC() %></td>
                                        <td><%= h.getH_Relationship() %></td>
                                        <td style="text-align:center;">
                                            <a href="publicRemoveHouseholdFromSession?index=<%= i %>" class="btn-delete">Remove</a>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                    <a href="publicNewHousehold.jsp" class="btn-add-row">+ Add Family Member</a>
                </div>

                <button type="submit" class="btn-action" style="margin-top: 40px;">Submit Registration</button>
            </form>
        </div>
    </div>

    <div id="cameraModal" class="modal-overlay">
        <div class="modal-content">
            <h3>Scan ID Document</h3>
            <div class="camera-container">
                <video id="camera-feed" autoplay playsinline></video>
                <div class="ic-guide"></div>
            </div>
            <button class="btn-action" onclick="captureAndScan()">Capture Image</button>
            <button class="btn-delete" style="width:100%; margin-top:10px; padding:12px;" onclick="closeCameraModal()">Cancel</button>
            <div id="scan-loading" style="display:none; margin-top:15px; color:#0b5ea8; font-weight:bold;">Processing OCR...</div>
        </div>
    </div>

    <script>
        // ==========================================
        // BULLETPROOF PERSISTENCE (localStorage)
        // ==========================================
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('publicBeneForm');
            if (!form) return;

            // 1. RESTORE DATA
            const savedData = localStorage.getItem('ADMS_Public_Draft');
            if (savedData) {
                const data = JSON.parse(savedData);
                form.querySelectorAll('input, select').forEach(input => {
                    if (input.name && input.name !== 'HouseholdSize' && data[input.name]) {
                        input.value = data[input.name];
                    }
                });
            }
            updateFlow();

            // 2. AUTO-SAVE
            form.addEventListener('input', function() {
                const data = {};
                form.querySelectorAll('input, select').forEach(input => {
                    if (input.name && input.name !== 'HouseholdSize') {
                        data[input.name] = input.value;
                    }
                });
                localStorage.setItem('ADMS_Public_Draft', JSON.stringify(data));
            });

            // 3. CLEAR ONLY ON SUCCESSFUL SUBMIT
            form.addEventListener('submit', function() {
                localStorage.removeItem('ADMS_Public_Draft');
            });
        });

        // UI LOGIC
        function updateFlow() {
            const nat = document.getElementById("nationality").value;
            const hasDoc = document.getElementById("hasDoc").value;
            const icInput = document.getElementById("ic-input");
            const scanBtn = document.getElementById("scan-btn");
            const regStatus = document.getElementById("reg-status");
            const inputHint = document.getElementById("input-hint");
            const idLabel = document.getElementById("id-label");
            const countryGroup = document.getElementById("country-group");

            // 1. Handle Nationality Labels
            countryGroup.style.display = (nat === "Non-Malaysian") ? "flex" : "none";
            idLabel.innerText = (nat === "Malaysian") ? "IC Number *" : "Passport Number *";

            // 2. Handle Document Restriction Logic
            if (hasDoc === "yes") {
                icInput.readOnly = true;
                icInput.style.backgroundColor = "#f8fafc";
                icInput.placeholder = "Click Scan to fill";
                scanBtn.style.display = "block";
                regStatus.value = "Approved"; 
                inputHint.innerText = "Identity verification required via scan.";
            } else {
                icInput.readOnly = false;
                icInput.style.backgroundColor = "#ffffff";
                icInput.placeholder = (nat === "Malaysian") ? "YYMMDD-PB-###G" : "Enter Passport No";
                scanBtn.style.display = "none";
                regStatus.value = "Pending"; 
                inputHint.innerText = "Enter details manually. Staff verification needed.";
                icInput.oninput = function() { formatIC(this); };
            }
        }

        // POSTCODE LOOKUP
        function fetchAddress() {
            const pcode = document.getElementById("postcode").value;
            if(!pcode) return;
            fetch("PostcodeLookupServlet?postcode=" + pcode)
                .then(res => res.json())
                .then(d => {
                    if(d.found) {
                        document.getElementById("city").value = d.city;
                        document.getElementById("state").value = d.state;
                        const data = JSON.parse(localStorage.getItem('ADMS_Public_Draft') || '{}');
                        data['City'] = d.city;
                        data['State'] = d.state;
                        localStorage.setItem('ADMS_Public_Draft', JSON.stringify(data));
                    }
                });
        }

        // SCANNER LOGIC
        let stream;
        function openCameraModal() {
            document.getElementById('cameraModal').style.display = 'flex';
            navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } })
                .then(s => { stream = s; document.getElementById('camera-feed').srcObject = s; });
        }
        function closeCameraModal() {
            document.getElementById('cameraModal').style.display = 'none';
            if(stream) stream.getTracks().forEach(t => t.stop());
        }
        async function captureAndScan() {
            const video = document.getElementById('camera-feed');
            const loading = document.getElementById('scan-loading');
            loading.style.display = 'block';
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth; canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);
            const worker = await Tesseract.createWorker('eng');
            const { data: { text } } = await worker.recognize(canvas.toDataURL());
            let match = text.match(/(\d{6})[-\s]*(\d{2})[-\s]*(\d{4})/);
            if (match) {
                document.getElementById('ic-input').value = match[1] + "-" + match[2] + "-" + match[3];
                closeCameraModal();
            } else { alert("ID not detected. Ensure good lighting."); }
            await worker.terminate();
            loading.style.display = 'none';
        }
        function formatIC(input) {
            const nat = document.getElementById("nationality").value;
            if (nat === "Non-Malaysian") {
                input.value = input.value.toUpperCase();
                return; 
            }
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
</body>
</html>