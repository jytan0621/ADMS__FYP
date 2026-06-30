<%-- 
    Document   : EditUserForm.jsp
    Created on : Jan 4, 2026
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
    
    // 2. Determine which user we are editing
    // If 'user' attribute is set (from Servlet), use it. Otherwise, fallback to currentUser (Self-Edit)
    User userToEdit = (User) request.getAttribute("user");
    if (userToEdit == null) {
        userToEdit = currentUser;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Edit Profile</title>
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

        /* --- 3. LAYOUT --- */
        .sidebar-container {
            position: fixed;
            top: 60px;
            left: 0;
            bottom: 0;
            width: 250px; 
            z-index: 1000;
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
            max-width: 600px; 
            padding: 40px; 
            border-radius: 8px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); 
            border: 1px solid #e2e8f0;
        }
        
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
            font-size: 24px;
        }

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
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; font-size: 14px; }
        .form-group input[type="text"], 
        .form-group input[type="email"] { 
            width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; 
        }
        .form-group input:focus { border-color: #0b5ea8; outline: 2px solid #0b5ea8; }
        
        /* File Input Styling */
        .file-input {
            width: 100%;
            padding: 8px;
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            font-size: 14px;
        }

        .readonly-input { background-color: #f0f2f5; color: #6c757d; cursor: not-allowed; border: 1px solid #ced4da; }
        
        .btn-group { margin-top: 30px; display: flex; justify-content: flex-end; gap: 15px; }
        .btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; text-decoration: none; font-size: 14px; }
        .btn-cancel { background-color: #e2e6ea; color: #495057; }
        .btn-save { background-color: #0b5ea8; color: white; }
    </style>
</head>
<body>

    <div class="sidebar-container">
        <jsp:include page="Sidebar.jsp" />
    </div>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-centered">
        <div class="form-card">
            
            <div class="form-header">
                <a href="UserProfile.jsp" class="back-btn" title="Back to Profile">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                </a>
                <h2>Edit My Profile</h2>
            </div>
            
            <%-- IMPORTANT: enctype="multipart/form-data" is required for file uploads --%>
            <form action="userupdate" method="POST" enctype="multipart/form-data">
                
                <input type="hidden" name="userId" value="<%= userToEdit.getUserID() %>">
                <%-- Hidden field to keep the old picture if the user doesn't upload a new one --%>
                <input type="hidden" name="existingPic" value="<%= (userToEdit.getProfilePicture() != null) ? userToEdit.getProfilePicture() : "default-avatar.png" %>">

                <div class="form-group">
                    <label>Profile Picture</label>
                    <input type="file" name="profilePic" accept="image/*" class="file-input">
                    <small style="color: #64748b; display: block; margin-top: 5px;">
                        Leave blank to keep current picture. Max size: 10MB.
                    </small>
                </div>

                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" value="<%= userToEdit.getUserName() %>" required>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" value="<%= userToEdit.getEmail() %>" required>
                </div>

                <div class="form-group">
                    <label>Role</label>
                    <input type="text" value="<%= userToEdit.getRole() %>" readonly class="readonly-input">
                </div>

                <div class="form-group">
                    <label>Assigned Region</label>
                    <input type="text" value="<%= userToEdit.getAssignedRegion() %>" readonly class="readonly-input">
                </div>

                <div class="btn-group">
                    <a href="UserProfile.jsp" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>