<%-- Document: publicCheckout.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMS - Victim Checkout</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f1f5f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .checkout-card { background: white; padding: 40px; border-radius: 12px; width: 100%; max-width: 450px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); text-align: center; }
        .form-input { width: 100%; padding: 15px; margin: 20px 0; border: 2px solid #e2e8f0; border-radius: 8px; font-size: 18px; box-sizing: border-box; text-align: center; letter-spacing: 1px; }
        .btn-checkout { background-color: #0b5ea8; color: white; padding: 16px; border: none; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; }
        .btn-checkout:hover { background-color: #084a85; }
        .error-msg { color: #dc2626; background: #fee2e2; padding: 10px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; }
    </style>
</head>
<body>
    <div class="checkout-card">
        <img src="Image/Logo_ADMS.png" alt="Logo" style="height: 40px; margin-bottom: 10px;">
        <h2 style="margin: 10px 0;">Self Checkout</h2>
        <p style="color: #64748b;">Please enter your IC number to finalize your departure from the shelter.</p>

        <% if(request.getParameter("error") != null) { %>
            <div class="error-msg">⚠️ <%= request.getParameter("error") %></div>
        <% } %>

        <form action="publicCheckoutAction" method="POST">
            <input type="text" id="ic-input" name="checkoutIC" class="form-input" 
                   required placeholder="XXXXXX-XX-XXXX" oninput="formatIC(this)">
            
            <button type="submit" class="btn-checkout">Confirm & Checkout</button>
        </form>
        
        <p style="font-size: 12px; color: #94a3b8; margin-top: 20px;">By clicking confirm, you and your registered dependents will be marked as discharged.</p>
    </div>

    <script>
        function formatIC(input) {
            let val = input.value.replace(/\D/g, ''); 
            if (val.length > 12) val = val.substring(0, 12);
            if (val.length > 8) {
                val = val.substring(0, 6) + '-' + val.substring(6, 8) + '-' + val.substring(8);
            } else if (val.length > 6) {
                val = val.substring(0, 6) + '-' + val.substring(6);
            }
            input.value = val;
        }
    </script>
</body>
</html>