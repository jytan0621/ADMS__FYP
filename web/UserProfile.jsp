<%-- 
    Document   : userProfile
    Created on : Dec 31, 2025, 6:54:27 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>

<%
    // 1. Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("index.jsp"); 
        return;
    }

    // 2. Set Active Menu for Sidebar
    session.setAttribute("activeMenu", "home");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>ADMS - User Profile</title>
    
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

        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-3 { gap: 12px; }
        .font-bold { font-weight: 700; }
        .text-xl { font-size: 1.25rem; }
        .tracking-tight { letter-spacing: -0.025em; }
        .font-medium { font-weight: 500; }
        .text-sm { font-size: 0.875rem; }
        .bg-white\/10 { background-color: rgba(255, 255, 255, 0.1); padding: 5px 12px; border-radius: 4px; }

        /* --- 3. SIDEBAR --- */
        .sidebar-container { 
            position: fixed; 
            top: 60px; 
            left: 0; 
            bottom: 0; 
            width: 250px; 
            z-index: 40; 
        }

        /* --- 4. SCROLLABLE MAIN CONTENT AREA --- */
        .main-content-scrollable { 
            /* Fix position to fill the space next to sidebar & below header */
            position: fixed;
            top: 60px;
            left: 250px;
            right: 0;
            bottom: 0;
            
            /* Enable scrolling if content is taller than screen */
            overflow-y: auto; 
            background-color: #f8fafc;
            
            /* Flexbox setup for safe centering */
            display: flex;
            padding: 20px;
        }

        /* --- 5. PROFILE CARD STYLES --- */
        .profile-card { 
            /* margin: auto works inside flex to CENTER vertically/horizontally 
               AND allows scrolling if screen is too short */
            margin: auto; 
            
            background-color: white; 
            width: 100%; 
            max-width: 500px; 
            padding: 40px; 
            border-radius: 8px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); 
            border: 1px solid #e2e8f0;
            text-align: center; 
        }

        .profile-card h2 { 
            margin-top: 0; 
            color: #333; 
            margin-bottom: 25px; 
            padding-bottom: 15px; 
            border-bottom: 1px solid #eee;
        }

        .avatar-circle {
            width: 100px;
            height: 100px;
            background-color: #e2e8f0;
            color: #0b5ea8;
            border-radius: 50%;
            margin: 0 auto 25px auto;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            font-weight: bold;
            border: 4px solid white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .form-group { margin-bottom: 15px; text-align: left; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #64748b; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        
        .readonly-input { 
            width: 100%; 
            padding: 10px; 
            border: 1px solid #e2e8f0; 
            border-radius: 4px; 
            font-size: 15px; 
            background-color: #f8fafc; 
            color: #334155; 
            font-weight: 500;
            cursor: default;
        }
        .readonly-input:focus { outline: none; border-color: #cbd5e1; }

        .btn-edit {
            display: inline-block;
            margin-top: 20px;
            background-color: #0b5ea8;
            color: white;
            padding: 10px 30px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s;
        }
        .btn-edit:hover { background-color: #094b85; }

    </style>
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
        <div class="profile-card">
            <h2>User Profile</h2>

            <div class="avatar-circle">
                <% if (currentUser.getProfilePicture() != null && !currentUser.getProfilePicture().equals("default-avatar.png")) { %>
                    <img src="uploads/<%= currentUser.getProfilePicture() %>" style="width:100%; height:100%; border-radius:50%; object-fit:cover;">
                <% } else { %>
                    <%= currentUser.getUserName().substring(0, 1).toUpperCase() %>
                <% } %>
            </div>

            <div class="form-group">
                <label>Username</label>
                <input type="text" value="<%= currentUser.getUserName() %>" readonly class="readonly-input">
            </div>

            <div class="form-group">
                <label>Email Address</label>
                <input type="text" value="<%= currentUser.getEmail() %>" readonly class="readonly-input">
            </div>

            <div class="form-group">
                <label>Assigned Region</label>
                <input type="text" value="<%= currentUser.getAssignedRegion() %>" readonly class="readonly-input">
            </div>

            <div class="form-group">
                <label>Role</label>
                <input type="text" value="<%= currentUser.getRole() %>" readonly class="readonly-input">
            </div>

            <div class="form-group">
                <label>Account Created</label>
                <input type="text" value="<%= currentUser.getCreatedAt() %>" readonly class="readonly-input">
            </div>
            
            <a href="EditUserForm.jsp" class="btn-edit">Edit Profile</a>
        </div>
    </div>

</body>
</html>