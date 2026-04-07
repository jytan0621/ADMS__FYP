<%-- Document: checkoutSuccess.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Checkout Successful</title>
    <style>
        body { 
            margin: 0; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background-color: #f1f5f9; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
        }
        .success-card { 
            background: white; 
            padding: 40px; 
            border-radius: 16px; 
            width: 90%; 
            max-width: 450px; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.05); 
            text-align: center; 
        }
        .icon-circle {
            width: 80px;
            height: 80px;
            background-color: #dcfce7;
            color: #16a34a;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px auto;
            font-size: 40px;
        }
        h1 { color: #0f172a; margin: 0 0 10px 0; font-size: 24px; }
        p { color: #64748b; line-height: 1.6; margin-bottom: 25px; }
        
        .instruction-box {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 15px;
            text-align: left;
            margin-bottom: 30px;
        }
        .instruction-box h3 { 
            font-size: 14px; 
            color: #475569; 
            margin: 0 0 8px 0; 
            text-transform: uppercase; 
            letter-spacing: 0.5px;
        }
        .instruction-item {
            display: flex;
            gap: 10px;
            font-size: 14px;
            color: #1e293b;
            margin-bottom: 5px;
        }

        .btn-home { 
            display: inline-block;
            background-color: #0b5ea8; 
            color: white; 
            padding: 14px 28px; 
            border-radius: 8px; 
            text-decoration: none;
            font-weight: bold; 
            transition: 0.2s;
        }
        .btn-home:hover { background-color: #084a85; transform: translateY(-1px); }
    </style>
</head>
<body>

    <div class="success-card">
        <div class="icon-circle">✓</div>
        
        <h1>Checkout Complete</h1>
        <p>Your departure has been successfully recorded in the ADMS system. You and your family members are now marked as discharged.</p>

        <div class="instruction-box">
            <h3>Final Reminders:</h3>
            <div class="instruction-item">
                <span>📍</span> <span>Please ensure your assigned tent is cleared of all personal trash.</span>
            </div>
            <div class="instruction-item">
                <span>📦</span> <span>Return any borrowed supplies (blankets, fans, or medical tools) to the staff counter.</span>
            </div>
            <div class="instruction-item">
                <span>🚗</span> <span>Safe travels to your next destination.</span>
            </div>
        </div>

        <a href="publicHome.jsp" class="btn-home">Return to Home</a>
        
        <div style="margin-top: 20px; font-size: 12px; color: #94a3b8;">
            Automated Disaster Management System (ADMS)
        </div>
    </div>

</body>
</html>