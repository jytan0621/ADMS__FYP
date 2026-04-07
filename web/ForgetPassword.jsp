<%-- 
    Document   : ForgetPassword
    Created on : Dec 31, 2025, 8:08:39 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ADMS | Forgot Password</title>

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

        .forgot-box {
            width: 420px;
            background-color: #ffffff;
            padding: 40px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            border-radius: 4px;
        }

        .forgot-box h1 {
            font-size: 30px;
            margin-bottom: 5px;
        }

        .forgot-box h2 {
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

        input[type="email"] {
            width: 100%;
            padding: 12px;
            font-size: 15px;
            border: 1px solid #aaa;
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

    <div class="forgot-box">

        <h1>ADMS</h1>
        <h2>Aid Distribution Management System</h2>

        <p class="description">
            Please enter your registered email address.  
            A verification code will be sent to your email.
        </p>

        <form action="ForgetPasswordServlet" method="post">

            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="example@email.com" required>
            </div>

            <button type="submit" class="send-btn">
                Send Verification Code
            </button>

            <a href="index.jsp" class="back-link">
                Back to Login
            </a>

            <%
    if ("notfound".equals(request.getParameter("error"))) {
%>
    <p style="color:red;">Email not found</p>
<%
    }
%>
            
        </form>

    </div>

</body>
</html>
