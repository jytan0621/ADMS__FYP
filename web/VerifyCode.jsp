<%-- 
    Document   : VerifyCode
    Created on : Jan 11, 2026
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Retrieve the email stored in the session by ForgotPasswordServlet
    String userEmail = (String) session.getAttribute("emailForReset");

    // Safety check: If session expired or email is missing, show a generic text
    if (userEmail == null) {
        userEmail = "your email address"; 
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ADMS | Verify Code</title>

    <style>
        * { box-sizing: border-box; font-family: "Times New Roman", serif; }
        body { margin: 0; height: 100vh; background-color: #f7f6e9; display: flex; align-items: center; justify-content: center; }
        
        .forgot-box { width: 420px; background-color: #ffffff; padding: 40px; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.15); border-radius: 4px; }
        .forgot-box h1 { font-size: 30px; margin-bottom: 5px; }
        .forgot-box h2 { font-size: 17px; font-weight: normal; margin-top: 0; }

        .description { margin-top: 20px; font-size: 15px; color: #333; line-height: 1.5; }
        
        /* Highlight the email address */
        .email-display { 
            font-weight: bold; 
            color: #5572b4; 
            display: block; 
            margin-top: 5px; 
        }

        .form-group { margin-top: 30px; text-align: left; }
        label { display: block; margin-bottom: 8px; font-size: 16px; }
        input[type="text"] { width: 100%; padding: 12px; font-size: 15px; border: 1px solid #aaa; text-align: center; letter-spacing: 2px; }

        .send-btn { margin-top: 25px; width: 100%; padding: 12px; background-color: #5572b4; color: white; border: none; font-size: 16px; cursor: pointer; }
        .send-btn:hover { background-color: #445fa0; }

        .error-msg { color: red; margin-top: 15px; font-size: 14px; }
        .success-msg { color: green; margin-top: 15px; font-size: 14px; }

        .link-container { display: flex; justify-content: space-between; margin-top: 20px; }
        .secondary-link { font-size: 14px; color: #5572b4; text-decoration: none; font-weight: 500; cursor: pointer; }
        .secondary-link:hover { text-decoration: underline; color: #334d85; }
    </style>
</head>

<body>

    <div class="forgot-box">

        <h1>ADMS</h1>
        <h2>Aid Distribution Management System</h2>

        <p class="description">
            Please enter the verification code sent to:
            <span class="email-display"><%= userEmail %></span>
        </p>

        <form action="VerifyCodeServlet" method="post">

            <div class="form-group">
                <label>Verification Code</label>
                <input type="text" name="code" placeholder="Enter Code" required>
            </div>

            <button type="submit" class="send-btn">
                Verify
            </button>
            
            <%-- Error/Success Messages --%>
            <%
                String error = request.getParameter("error");
                String msg = request.getParameter("msg");

                if ("invalidcode".equals(error)) {
            %>
                <p class="error-msg">Invalid code. Please try again.</p>
            <%
                }
                if ("sessionexpired".equals(error)) {
            %>
                 <p class="error-msg">Session expired. Please request a new code.</p>
            <%
                }
                if ("resentsuccess".equals(msg)) {
            %>
                 <p class="success-msg">New code sent to <%= userEmail %>!</p>
            <%
                }
            %>

            <div class="link-container">
                <a href="ForgetPassword.jsp" class="secondary-link">
                    &larr; Change Email
                </a>
                <a href="ForgotPasswordServlet?action=resend" class="secondary-link">
                    Resend Code
                </a>
            </div>

        </form>

    </div>

</body>
</html>