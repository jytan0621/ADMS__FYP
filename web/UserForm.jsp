<%-- 
    Document   : newUser
    Created on : Jan 4, 2026
    Description: Form to add a new user to the database
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>

<%
    // 1. Security Check (Only Admin can access)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Manager".equals(currentUser.getRole()))) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>ADMS - Add New User</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">

    <style>
        /* --- 1. GLOBAL RESET --- */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }

        /* --- 2. HEADER STYLES --- */
        .fixed-header { 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            height: 60px; 
            z-index: 1001; 
            background-color: #0b5ea8; 
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 0 24px; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
        }

        /* Utility classes */
        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-3 { gap: 12px; }
        .font-bold { font-weight: 700; }
        .text-xl { font-size: 1.25rem; }
        .tracking-tight { letter-spacing: -0.025em; }
        .font-medium { font-weight: 500; }
        .text-sm { font-size: 0.875rem; }
        .bg-white\/10 { background-color: rgba(255, 255, 255, 0.1); padding: 5px 12px; border-radius: 4px; }

        /* --- 3. LAYOUT STRUCTURE --- */
        .sidebar-container { 
            position: fixed; 
            top: 60px; 
            left: 0; 
            bottom: 0; 
            width: 250px; 
            z-index: 40; 
        }

        .main-content-centered { 
            margin-left: 250px; 
            padding-top: 60px; 
            height: 100vh; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            background-color: #f8fafc;
        }

        /* --- 4. FORM CARD STYLES --- */
        .form-card {
            background-color: white;
            width: 100%;
            max-width: 650px;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            max-height: 90vh; 
            overflow-y: auto;
            border: 1px solid #e2e8f0;
        }

        /* Header Flex for Back Arrow */
        .form-header { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            margin-bottom: 25px; 
            border-bottom: 1px solid #eee; 
            padding-bottom: 15px; 
        }

        .form-header h2 {
            margin: 0;
            color: #333;
        }

        /* Back Button Style */
        .back-btn { 
            background: none; 
            border: none; 
            cursor: pointer; 
            color: #000; 
            display: flex; 
            align-items: center; 
            padding: 0; 
            transition: color 0.2s;
        }
        .back-btn:hover { color: #0b5ea8; }

        /* Form Layout Grid */
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
        }

        .form-group {
            flex: 1;
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #555;
            font-size: 14px;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            font-size: 14px;
            transition: all 0.2s;
        }

        .form-group input:focus, .form-group select:focus {
            border-color: #0b5ea8;
            outline: 2px solid #0b5ea8;
            outline-offset: -1px;
        }
        
        /* Readonly inputs (City/State) */
        .input-readonly {
            background-color: #f1f5f9;
            color: #64748b;
            cursor: not-allowed;
        }

        /* Buttons */
        .btn-group {
            margin-top: 30px;
            display: flex;
            justify-content: flex-end;
            gap: 15px;
        }

        .btn {
            padding: 10px 25px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            transition: background 0.2s;
        }

        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-cancel:hover { background-color: #cbd5e1; }

        .btn-save { background-color: #0b5ea8; color: white; }
        .btn-save:hover { background-color: #094b87; }

    </style>
    
    <script>
        function fetchAddress() {
            var pcode = document.getElementById("postcode").value;
            if(pcode.length === 0) return;
            
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState === 4 && this.status === 200) {
                    var response = JSON.parse(this.responseText);
                    if(response.found === true) {
                        // Success: Fill fields
                        document.getElementById("city").value = response.city;
                        document.getElementById("state").value = response.state;
                    } else {
                        // Fail: Clear fields
                        alert("Postcode not found!");
                        document.getElementById("city").value = "";
                        document.getElementById("state").value = "";
                    }
                }
            };
            // Calls PostcodeLookupServlet to get JSON data
            xhttp.open("GET", "PostcodeLookupServlet?postcode=" + pcode, true);
            xhttp.send();
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

    <div class="main-content-centered">
        <div class="form-card">
            
            <div class="form-header">
                <a href="list" class="back-btn" title="Back to User List">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2>Add New User</h2>
            </div>
            
            <form action="insert" method="POST">
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" placeholder="Enter username" required>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="Enter email address" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Role</label>
                        <select name="role" required>
                            <option value="" disabled selected>Select Role</option>
                            <option value="Admin">Admin</option>
                            <option value="Approval Admin">Approval Admin</option>
                            <option value="Field Officer">Field Officer</option>
                            <option value="Logistic Staff">Logistic Staff</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Postcode (Auto-fill)</label>
                        <input type="text" name="postcode" id="postcode" placeholder="e.g. 82000" onblur="fetchAddress()" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>City</label>
                        <input type="text" name="city" id="city" placeholder="Auto-filled" readonly class="input-readonly">
                    </div>
                    
                    <div class="form-group">
                        <label>State</label>
                        <input type="text" name="state" id="state" placeholder="Auto-filled" readonly class="input-readonly">
                    </div>
                </div>

                <div class="btn-group">
                    <a href="list" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Create User</button>
                </div>

            </form>
        </div>
    </div>

</body>
</html>