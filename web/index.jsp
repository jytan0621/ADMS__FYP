<!DOCTYPE html>
<!--
Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Html.html to edit this template
-->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ADMS | Login</title>

    <style>
        * {
            box-sizing: border-box;
            font-family: "Times New Roman", serif;
        }

        body {
            margin: 0;
            height: 100vh;
            display: flex;
        }

        /* Left image section */
        .left-panel {
            width: 50%;
            background-image: url("Image/Floodimage.png"); /* change path */
            background-size: cover;
            background-position: center;
        }

        /* Right login panel */
        .right-panel {
            width: 50%;
            background-color: #f7f6e9;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-box {
            width: 400px;
            text-align: center;
        }

        .login-box h1 {
            margin-bottom: 5px;
            font-size: 32px;
        }

        .login-box h2 {
            margin-top: 0;
            font-size: 18px;
            font-weight: normal;
        }

        .form-group {
            text-align: left;
            margin-top: 20px;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-size: 16px;
        }

        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            font-size: 15px;
            border: 1px solid #aaa;
        }

        .login-btn {
            margin-top: 25px;
            width: 100%;
            padding: 12px;
            background-color: #5572b4;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }

        .login-btn:hover {
            background-color: #445fa0;
        }

        .forgot {
            margin-top: 12px;
            display: block;
            font-size: 14px;
            color: #5572b4;
            text-decoration: none;
        }

        .forgot:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

    <!-- LEFT IMAGE -->
    <div class="left-panel"></div>

    <!-- RIGHT LOGIN -->
    <div class="right-panel">
        <div class="login-box">

            <h1>ADMS</h1>
            <h2>Aid Distribution Management System</h2>

            <form action="LoginServlet" method="post">

                <div class="form-group">
                    <label>Email Address:</label>
                    <input type="email" name="Email" required>
                </div>

                <div class="form-group">
                    <label>Password:</label>
                    <input type="password" name="Password" required>
                </div>

                <button type="submit" class="login-btn">Login</button>

                <a href="ForgetPassword.jsp" class="forgot">Forget Password?</a>

                <%
    if ("invalid".equals(request.getParameter("error"))) {
%>
    <p style="color:red;">Invalid email or password</p>
<%
    }
%>

<%
    if ("success".equals(request.getParameter("reset"))) {
%>
    <p style="color:green;">Password reset successful. Please login.</p>
<%
    }
%>
                
            </form>

        </div>
    </div>

</body>
</html>
