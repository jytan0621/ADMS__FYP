<%-- Document: publicNewHousehold.jsp (FULL HOUSEHOLD FORM) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>ADMS - Add Family Member</title>
    
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
    
    <style>
        body { margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f1f5f9; }
        
        .public-header { position: sticky; top: 0; background-color: #0b5ea8; color: white; padding: 15px 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); z-index: 50; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .public-header img { height: 28px; }
        .public-header h2 { margin: 0; font-size: 20px; font-weight: 600; letter-spacing: 1px; }

        .main-container { padding: 20px; max-width: 700px; margin: 0 auto; padding-bottom: 60px; }
        .form-card { background: white; padding: 30px 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }
        
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 25px; border-bottom: 2px solid #e2e8f0; padding-bottom: 20px;}
        .page-title { font-size: 22px; color: #0f172a; margin: 0; font-weight: bold;}
        
        .back-btn { background: #f1f5f9; border: none; cursor: pointer; color: #4b5563; display: flex; align-items: center; justify-content: center; padding: 8px; border-radius: 50%; text-decoration: none; width: 35px; height: 35px; transition: 0.2s;}
        .back-btn:hover { background: #e2e8f0; color: #0b5ea8; }

        .form-grid { display: grid; grid-template-columns: 1fr; gap: 15px; } 
        @media (min-width: 600px) { .form-grid { grid-template-columns: 1fr 1fr; gap: 20px; } } 
        
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .full-width { grid-column: 1 / -1; }
        .hidden-field { display: none; }
        
        .form-label { color: #334155; font-size: 14px; font-weight: 600; }
        .form-input, select { width: 100%; box-sizing: border-box; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 15px; outline: none; background: #fff; }
        .form-input:focus { border-color: #0b5ea8; box-shadow: 0 0 0 3px rgba(11,94,168,0.1); }

        .btn-scan { background-color: #10b981; color: white; padding: 12px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 14px; flex-shrink: 0;}
        .btn-action { background-color: #0b5ea8; color: white; width: 100%; padding: 15px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 20px; }
        .btn-close { background-color: #ef4444; color: white; width: 100%; padding: 12px; border: none; border-radius: 8px; cursor: pointer; margin-top: 10px; font-weight: 600; }

        /* Camera Modal Styles */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.95); z-index: 100; align-items: center; justify-content: center; flex-direction: column; }
        .modal-content { background: white; padding: 20px; border-radius: 12px; width: 90%; max-width: 500px; text-align: center; }
        .camera-container { position: relative; width: 100%; margin-bottom: 15px; overflow: hidden; border-radius: 8px; border: 2px solid #e2e8f0; background: #000; }
        #camera-feed { width: 100%; display: block; } 
        .ic-guide { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 85%; aspect-ratio: 1.586 / 1; border: 2px dashed #10b981; box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.65); z-index: 10; pointer-events: none;}
    </style>
</head>
<body>

    <header class="public-header">
        <img src="Image/Logo_ADMS.png" alt="Logo">
        <h2>Disaster Aid Registration</h2>
    </header>

    <div class="main-container">
        <div class="form-card">
            <div class="form-header">
                <a href="publicNewBeneficiary.jsp" class="back-btn">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                </a>
                <div>
                    <h1 class="page-title">Dependent Details</h1>
                    <p style="color: #64748b; font-size: 13px; margin: 5px 0 0 0;">Add a family member staying in the same household.</p>
                </div>
            </div>

            <form action="publicAddHouseholdToSession" method="POST">
                <div class="form-grid">
                    
                    <div class="form-group full-width">
                        <label class="form-label">Full Name (As per Document) <span style="color:red;">*</span></label>
                        <input type="text" name="hName" class="form-input" required placeholder="Enter full name">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Nationality <span style="color:red;">*</span></label>
                        <select id="h-nationality" name="hIsMalaysian" class="form-input" onchange="toggleCountry()" required>
                            <option value="Malaysian">Malaysian</option>
                            <option value="Non-Malaysian">Non-Malaysian</option>
                        </select>
                    </div>

                    <div class="form-group hidden-field" id="h-country-group">
                        <label class="form-label">Specify Country <span style="color:red;">*</span></label>
                        <input type="text" id="h-country" name="hNationality" class="form-input" placeholder="e.g. Indonesia">
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label" id="id-label">MyKad Number <span style="color:red;">*</span></label>
                        <div style="display: flex; gap: 10px;">
                            <input type="text" id="ic-input" name="hIC" class="form-input" required placeholder="Type or Scan" oninput="formatIC(this)">
                            <button type="button" class="btn-scan" onclick="openCameraModal()">📷 Scan</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Relationship to You <span style="color:red;">*</span></label>
                        <input type="text" name="hRelationship" class="form-input" required placeholder="e.g. Daughter, Spouse">
                    </div>

                    <div class="form-group">
                        <label class="form-label">OKU Status <span style="color:red;">*</span></label>
                        <select name="hOku" class="form-input" required>
                            <option value="No">No</option>
                            <option value="Yes">Yes</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label">Health History / Medical Conditions</label>
                        <input type="text" name="hHealthHistory" class="form-input" placeholder="Optional (e.g. Asthma, High Blood Pressure)">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Allergies</label>
                        <input type="text" name="hAllergic" class="form-input" placeholder="Optional (e.g. Seafood)">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Dietary Preferences</label>
                        <input type="text" name="hDietPreference" class="form-input" placeholder="Optional (e.g. Vegetarian)">
                    </div>

                </div>

                <button type="submit" class="btn-action">Add Family Member</button>
            </form>
        </div>
    </div>

    <div id="cameraModal" class="modal-overlay">
        <div class="modal-content">
            <h3 style="margin:0 0 15px 0; color:#0f172a;">Scan ID Document</h3>
            <div class="camera-container">
                <video id="camera-feed" autoplay playsinline></video>
                <div class="ic-guide"></div>
            </div>
            <button class="btn-action" onclick="captureAndScan()">Capture Image</button>
            <button class="btn-close" onclick="closeCameraModal()">Cancel</button>
            <div id="scan-loading" style="display:none; margin-top:15px; color:#0b5ea8; font-weight:bold;">Analyzing document...</div>
        </div>
    </div>

    <script>
        // --- 1. Nationality Toggle Logic ---
        function toggleCountry() {
            const nat = document.getElementById("h-nationality").value;
            const group = document.getElementById("h-country-group");
            const input = document.getElementById("h-country");
            const label = document.getElementById("id-label");
            
            if (nat === "Non-Malaysian") {
                group.classList.remove("hidden-field");
                input.required = true;
                label.innerHTML = 'Passport Number <span style="color:red;">*</span>';
            } else {
                group.classList.add("hidden-field");
                input.required = false;
                label.innerHTML = 'MyKad Number <span style="color:red;">*</span>';
            }
        }

        // --- 2. Camera & OCR Logic ---
        let videoStream;
        function openCameraModal() {
            document.getElementById('cameraModal').style.display = 'flex';
            navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment", width: { ideal: 1920 } } })
                .then(s => { videoStream = s; document.getElementById('camera-feed').srcObject = s; })
                .catch(e => alert("Unable to access camera. Please check permissions."));
        }

        function closeCameraModal() {
            document.getElementById('cameraModal').style.display = 'none';
            if(videoStream) videoStream.getTracks().forEach(t => t.stop());
        }

        async function captureAndScan() {
            const video = document.getElementById('camera-feed');
            const loading = document.getElementById('scan-loading');
            loading.style.display = 'block';

            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth; canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);

            try {
                const worker = await Tesseract.createWorker('eng');
                const { data: { text } } = await worker.recognize(canvas.toDataURL());
                
                // Matches XXXXXX-XX-XXXX or XXXXXXXXXXXX
                let match = text.match(/(\d{6})[-\s]*(\d{2})[-\s]*(\d{4})/);
                if (match) {
                    document.getElementById('ic-input').value = match[1] + "-" + match[2] + "-" + match[3];
                    closeCameraModal();
                } else {
                    alert("ID not detected correctly. Please try again or type it manually.");
                }
                await worker.terminate();
            } catch (err) {
                alert("Scanner Error. Please type the ID manually.");
            }
            loading.style.display = 'none';
        }
        
        function formatIC(input) {
            const nat = document.getElementById("h-nationality").value;
            
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
    </script>
</body>
</html>