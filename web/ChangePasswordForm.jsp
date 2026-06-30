<%-- 
    Document   : changePassword
    Created on : Jan 4, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>

<%
    // 1. Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Set Active Menu for Sidebar
    session.setAttribute("activeMenu", "home");
    
    // 3. Handle Feedback Messages
    String msg = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>ADMS - Change Password</title>
    
    <link rel="stylesheet" type="text/css" href="Sidebar.css">

    <style>
        /* --- 1. GLOBAL RESET --- */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }

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

        /* --- 4. PASSWORD CARD STYLES --- */
        .password-card {
            background-color: #ffffff;
            width: 100%;
            max-width: 450px; 
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border: 1px solid #e2e8f0;
        }

        /* [NEW] Header Flex for Back Arrow */
        .form-header { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            margin-bottom: 10px; 
            border-bottom: 1px solid #eee; 
            padding-bottom: 15px; 
        }

        .password-card h2 {
            margin: 0;
            color: #333;
            /* Removed text-align: center to align with arrow */
        }

        /* [NEW] Back Button Style */
        .back-btn { 
            background: none; 
            border: none; 
            cursor: pointer; 
            color: #333; 
            display: flex; 
            align-items: center; 
            padding: 0; 
            transition: color 0.2s;
        }
        .back-btn:hover { color: #0b5ea8; }

        .subtitle {
            /* text-align: center; Removed to align left */
            color: #64748b;
            font-size: 14px;
            margin-bottom: 30px;
            margin-top: 10px;
        }

        /* Form Groups */
        .form-group { margin-bottom: 20px; }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #475569;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 14px;
            transition: all 0.2s;
        }

        .form-group input:focus {
            border-color: #0b5ea8;
            outline: 2px solid #0b5ea8;
            outline-offset: -1px;
        }

        /* Buttons */
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: background 0.2s;
        }

        .btn-save { background-color: #0b5ea8; color: white; }
        .btn-save:hover { background-color: #084a83; }

        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-cancel:hover { background-color: #cbd5e1; }

        /* Alerts */
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            font-size: 14px;
            text-align: center;
            font-weight: 500;
        }
        .alert-success { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    </style>
</head>
<body>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <div class="main-content-centered">
        
        <div class="password-card">
            
            <div class="form-header">
                <a href="UserProfile.jsp" class="back-btn" title="Back to Profile">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2>Change Password</h2>
            </div>

            <div class="subtitle">Please enter your new password details below</div>

            <% if (msg != null) { %>
                <div class="alert alert-success"><%= msg %></div>
            <% } %>
            
            <% if (error != null) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>

            <form action="ChangePasswordServlet" method="POST">
                
                <div class="form-group">
                    <label for="oldPass">Current Password</label>
                    <input type="password" id="oldPass" name="oldPassword" required placeholder="Enter current password">
                </div>

                <div class="form-group">
                    <label for="newPass">New Password</label>
                    <input type="password" id="newPass" name="newPassword" required placeholder="Enter new password">
                </div>

                <div class="form-group">
                    <label for="confirmPass">Confirm New Password</label>
                    <input type="password" id="confirmPass" name="confirmPassword" required placeholder="Re-enter new password">
                </div>

                <div class="btn-group">
                    <a href="UserProfile.jsp" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Update Password</button>
                </div>

            </form>
        </div>

    </div>

</body>
</html>