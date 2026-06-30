<%-- 
    Document   : addNewShelter
    Created on : Apr 7, 2026, 11:13:35 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%
    // 1. Security Check: Only Admin and Manager can access
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Manager".equals(currentUser.getRole()))) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Add Shelter</title>
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        /* --- 1. GLOBAL RESET --- */
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }

        /* --- 2. FIXED HEADER (RESTORED) --- */
        .fixed-header { 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            height: 60px; 
            z-index: 50; 
            background-color: #0b5ea8; 
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 0 24px; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
        }

        /* Utility classes for Header info pill */
        .font-medium { font-weight: 500; }
        .text-sm { font-size: 0.875rem; }
        .bg-white-10 { background-color: rgba(255, 255, 255, 0.1); border-radius: 4px; padding: 4px 12px; }

        /* --- 3. LAYOUT STRUCTURE --- */
        .sidebar-container { 
            position: fixed; 
            top: 60px; 
            left: 0; 
            bottom: 0; 
            width: 250px; 
            z-index: 40; 
        }

        .main-content-scrollable { 
            position: fixed; 
            top: 60px; 
            left: 250px; 
            right: 0; 
            bottom: 0; 
            overflow-y: auto; 
            display: flex; 
            padding: 40px 20px; 
        }

        /* --- 4. FORM CARD STYLES --- */
        .profile-card { 
            margin: auto; 
            background: white; 
            width: 100%; 
            max-width: 500px; 
            padding: 40px; 
            border-radius: 8px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); 
            border: 1px solid #e2e8f0; 
        }

        .form-group { margin-bottom: 20px; }
        .form-group label { 
            display: block; 
            margin-bottom: 8px; 
            font-weight: 600; 
            color: #64748b; 
            font-size: 12px; 
            text-transform: uppercase; 
            letter-spacing: 0.025em;
        }

        .form-input { 
            width: 100%; 
            padding: 12px; 
            border: 1px solid #e2e8f0; 
            border-radius: 6px; 
            font-size: 15px; 
            transition: border-color 0.2s;
        }

        .form-input:focus { outline: none; border-color: #0b5ea8; border-width: 2px; }

        .btn-submit { 
            display: block; 
            width: 100%; 
            background-color: #10b981; 
            color: white; 
            padding: 14px; 
            border-radius: 6px; 
            font-weight: 700; 
            border: none; 
            cursor: pointer; 
            margin-top: 10px; 
            transition: background 0.2s;
        }

        .btn-submit:hover { background-color: #059669; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="profile-card">
            <h2 style="text-align:center; margin-top:0; color:#1e293b; font-size: 24px;">Register New Shelter</h2>
            <p style="text-align:center; color:#64748b; font-size: 14px; margin-bottom: 30px;">
                Enter details to initialize a new flood relief center.
            </p>

            <form action="insertShelter" method="POST">
                <div class="form-group">
                    <label>Shelter Name</label>
                    <input type="text" name="name" class="form-input" required placeholder="e.g. SK Gong Badak">
                </div>

                <div class="form-group">
                    <label>State</label>
                    <select name="state" class="form-input" required>
                        <option value="" disabled selected>Select State</option>
                        <option value="Terengganu">Terengganu</option>
                        <option value="Kelantan">Kelantan</option>
                        <option value="Pahang">Pahang</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Postcode</label>
                    <input type="number" name="postcode" class="form-input" required placeholder="e.g. 21030">
                </div>

                <div class="form-group">
                    <label>Total Capacity (Pax)</label>
                    <input type="number" name="capacity" class="form-input" required placeholder="Maximum capacity">
                </div>

                <button type="submit" class="btn-submit">Initialize Shelter</button>
                <a href="listShelters" style="display:block; text-align:center; margin-top:15px; color:#64748b; text-decoration:none; font-size:13px;">Cancel and Return</a>
            </form>
        </div>
    </div>

</body>
</html>