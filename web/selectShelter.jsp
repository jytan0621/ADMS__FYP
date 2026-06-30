<%-- 
    Document   : selectShelter
    Created on : May 14, 2026
    Author     : User
--%>

<%@page import="java.util.List"%>
<%@page import="com.Model.Shelter"%>
<%@page import="com.DAO.ShelterDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ADMS | Volunteer Check-In</title>

    <style>
        * {
            box-sizing: border-box;
            font-family: "Times New Roman", serif;
        }

        body {
            margin: 0;
            height: 100vh;
            background-color: #f7f6e9;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .shelter-box {
            width: 420px;
            background-color: #ffffff;
            padding: 40px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            border-radius: 4px;
        }

        .shelter-box h1 {
            font-size: 30px;
            margin-bottom: 5px;
            margin-top: 0;
        }

        .shelter-box h2 {
            font-size: 17px;
            font-weight: normal;
            margin-top: 0;
        }

        .description {
            margin-top: 20px;
            font-size: 15px;
            color: #333;
        }

        .form-group {
            margin-top: 30px;
            text-align: left;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 16px;
        }

        /* Styled to exactly match the input box from ForgetPassword */
        select {
            width: 100%;
            padding: 12px;
            font-size: 15px;
            border: 1px solid #aaa;
            background-color: #fff;
            cursor: pointer;
        }

        .send-btn {
            margin-top: 25px;
            width: 100%;
            padding: 12px;
            background-color: #5572b4;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }

        .send-btn:hover {
            background-color: #445fa0;
        }

        .back-link {
            display: block;
            margin-top: 15px;
            font-size: 14px;
            color: #5572b4;
            text-decoration: none;
        }

        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

    <div class="shelter-box">

        <h1>ADMS</h1>
        <h2>Aid Distribution Management System</h2>

        <p class="description">
            <b>Volunteer Check-In</b><br><br>
            Please select the shelter you are distributing aid at today.
        </p>

        <form action="SetVolunteerShelterServlet" method="POST">

            <div class="form-group">
                <label>Select Shelter *</label>
                <select name="shelterID" required>
                    <option value="" disabled selected>-- Choose a Shelter --</option>
                    <%
                        // Automatically fetch all shelters from your database
                        ShelterDAO sDao = new ShelterDAO();
                        List<Shelter> shelters = sDao.selectAllShelters();
                        for (Shelter s : shelters) {
                    %>
                        <option value="<%= s.getShelterID() %>">
                            <%= s.getShelterID() %> - <%= s.getShelterName() %>
                        </option>
                    <%
                        }
                    %>
                </select>
            </div>

            <button type="submit" class="send-btn">
                Enter Task Dashboard
            </button>

            <a href="index.jsp" class="back-link">
                Back to Login
            </a>

            <%
                if (request.getParameter("error") != null) {
            %>
                <p style="color:red; margin-top: 15px;">Please select a valid shelter to continue.</p>
            <%
                }
            %>

        </form>

    </div>

</body>
</html>