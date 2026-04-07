<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ADMS | Reset Password</title>

    <style>
        /* --- RESET & BASIC STYLES --- */
        * {
            box-sizing: border-box;
            font-family: "Times New Roman", serif;
        }

        body {
            margin: 0;
            height: 100vh;
            background-color: #f7f6e9; /* Light beige background */
            display: flex;
            align-items: center;  /* Vertically center */
            justify-content: center; /* Horizontally center */
        }

        /* --- MAIN CONTAINER --- */
        .forgot-box {
            width: 420px;
            background-color: #ffffff;
            padding: 40px;
            text-align: center; /* This centers the titles/text inside the box */
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            border-radius: 4px;
        }

        /* --- HEADINGS --- */
        .forgot-box h1 {
            font-size: 30px;
            margin-bottom: 5px;
            color: #000;
        }

        .forgot-box h2 {
            font-size: 17px;
            font-weight: normal;
            margin-top: 0;
            margin-bottom: 20px;
            color: #555;
        }

        .page-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #333;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            display: inline-block;
            width: 100%;
        }

        /* --- FORM ELEMENTS --- */
        .form-group {
            margin-top: 20px;
            text-align: left; /* Labels and inputs align left */
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 16px;
            color: #333;
        }

        input[type="password"] {
            width: 100%;
            padding: 12px;
            font-size: 15px;
            border: 1px solid #aaa;
            border-radius: 2px;
        }

        input[type="password"]:focus {
            border-color: #5572b4;
            outline: none;
        }

        /* --- BUTTONS --- */
        .send-btn {
            margin-top: 25px;
            width: 100%;
            padding: 12px;
            background-color: #5572b4;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
            border-radius: 2px;
            transition: background 0.3s;
        }

        .send-btn:hover {
            background-color: #445fa0;
        }

        /* --- ALERTS --- */
        .error-msg {
            background-color: #ffe6e6;
            color: #d8000c;
            border: 1px solid #d8000c;
            padding: 10px;
            margin-top: 20px;
            font-size: 14px;
            border-radius: 3px;
        }

        .success-msg {
            color: green;
            margin-top: 15px;
            font-size: 14px;
        }
    </style>
</head>
<body>

    <div class="forgot-box">

        <h1>ADMS</h1>
        <h2>Aid Distribution Management System</h2>
        
        <div class="page-title">Reset Password</div>

        <form action="ResetPasswordServlet" method="post" onsubmit="return validateForm()">
            
            <div class="form-group">
                <label for="pass">New Password</label>
                <input type="password" id="pass" name="password" placeholder="Enter new password" required>
            </div>

            <div class="form-group">
                <label for="confirm">Confirm Password</label>
                <input type="password" id="confirm" name="confirm" placeholder="Confirm new password" required>
            </div>

            <button type="submit" class="send-btn">Change Password</button>

            <% 
                String error = request.getParameter("error");
                if ("mismatch".equals(error)) { 
            %>
                <div class="error-msg">Passwords do not match.</div>
            <% 
                } else if ("fail".equals(error)) { 
            %>
                <div class="error-msg">Password update failed. Please try again.</div>
            <% 
                } 
            %>
        </form>
    </div>

    <script>
        function validateForm() {
            var p1 = document.getElementById("pass").value;
            var p2 = document.getElementById("confirm").value;
            if (p1 !== p2) {
                alert("Passwords do not match!");
                return false;
            }
            return true;
        }
    </script>

</body>
</html>