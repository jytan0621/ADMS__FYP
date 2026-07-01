<%-- 
    Document   : publicSelectAction
    Created on : Jul 1, 2026, 9:34:51 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Beneficiary Portal</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {
            box-sizing: border-box;
        }

        html, body {
            height: 100%;
            margin: 0;
        }

        body { 
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; 
            background-color: #f1f5f9; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            color: #334155;
        }

        .card { 
            background: white; 
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.01); 
            text-align: center; 
            width: 100%;
            max-width: 400px; 
            border-top: 5px solid #0b5ea8; 
        }

        .card h2 {
            margin-top: 0;
            margin-bottom: 24px;
            color: #0f172a;
            font-size: 24px;
            font-weight: 700;
            letter-spacing: -0.025em;
        }

        .btn-action { 
            display: block; 
            width: 100%; 
            padding: 14px 20px; 
            margin-bottom: 16px; 
            background-color: #0b5ea8; 
            color: white; 
            text-decoration: none; 
            border-radius: 8px; 
            font-size: 16px;
            font-weight: 600; 
            transition: all 0.2s ease-in-out;
            box-shadow: 0 4px 6px -1px rgba(11, 94, 168, 0.2);
        }

        .btn-action:hover {
            background-color: #094b86;
            transform: translateY(-2px); 
            box-shadow: 0 10px 15px -3px rgba(11, 94, 168, 0.3);
        }

        .btn-danger {
            background-color: #ef4444;
            box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.2);
        }

        .btn-danger:hover {
            background-color: #dc2626;
            box-shadow: 0 10px 15px -3px rgba(239, 68, 68, 0.3);
        }

        .btn-back-container {
            margin-top: 15px;
        }

        .btn-back { 
            color: #64748b; 
            text-decoration: none; 
            font-size: 14px; 
            font-weight: 500;
            transition: color 0.2s ease;
        }

        .btn-back:hover {
            color: #0f172a;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Please Select Action</h2>
        
        <a href="${pageContext.request.contextPath}/showPublicRegister" class="btn-action">
            New Registration
        </a>
        
        <a href="${pageContext.request.contextPath}/publicCheckout.jsp" class="btn-action btn-danger">
            Checkout (Discharge)
        </a>
        
        <div class="btn-back-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">← Back to Login</a>
        </div>
    </div>
</body>
</html>