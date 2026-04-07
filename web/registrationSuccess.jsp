<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Success</title>
        <script>
            // Wipe the sticky-data draft so the next user starts fresh
            localStorage.removeItem('ADMS_Public_Draft');
        </script>
    </head>
    <body style="text-align:center; padding-top:100px; font-family:sans-serif;">
        <h1>Registration Submitted!</h1>
        <p>Thank you. Your details have been recorded.</p>
        <a href="publicNewBeneficiary.jsp">Back to Form</a>
    </body>
</html>