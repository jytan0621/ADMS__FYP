<%-- 
    Document   : newRestock
    Created on : Apr 14, 2026, 2:50:24 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User, com.Model.InventoryItem, java.util.List" %>
<% 
    User u = (User) session.getAttribute("currentUser"); 
    List<InventoryItem> items = (List<InventoryItem>) request.getAttribute("availableItems");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ADMS - Request Restock</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 1000; background-color: #343a40; }
        .main-content { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; overflow-y: auto; padding: 32px; }
        .card { background: white; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; max-width: 800px; margin: 0 auto; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-top: 5px; box-sizing: border-box; }
        label { font-weight: 600; color: #475569; font-size: 13px; text-transform: uppercase; }
        .item-row { display: grid; grid-template-columns: 2fr 1fr 0.5fr; gap: 15px; margin-bottom: 10px; align-items: center; }
        .btn-submit { background-color: #f59e0b; color: white; padding: 12px; border: none; border-radius: 6px; font-weight: bold; width: 100%; cursor: pointer; margin-top:20px; }
    </style>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    
    <div class="main-content">
        <div class="card">
            <h2 style="margin-top:0;">Create Restock Request</h2>
            <hr style="border:0; border-top:1px solid #eee; margin:20px 0;">
            <form action="submitRestock" method="POST">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div><label>Request Date</label><input type="date" name="rrDateRequest" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()) %>" required></div>
                    <div><label>Status</label><input type="text" name="rrStatus" class="form-control" value="Pending" readonly></div>
                </div>
                
                <div style="margin-top: 20px;">
                    <label style="color:#0b5ea8; display:block; margin-bottom:10px;">Items to Restock</label>
                    <div id="restock-items-container">
                        <div class="item-row">
                            <select name="itemID[]" class="form-control" required>
                                <option value="">-- Select Item --</option>
                                <% if(items != null) for(InventoryItem item : items) { %>
                                    <option value="<%= item.getItemID() %>"><%= item.getIName() %></option>
                                <% } %>
                            </select>
                            <input type="number" name="quantity[]" class="form-control" placeholder="Qty" min="1" required>
                            <span></span>
                        </div>
                    </div>
                    <button type="button" onclick="addRow()" style="background:#f1f5f9; border:1px dashed #cbd5e1; padding:10px; width:100%; border-radius:6px; color:#475569; cursor:pointer; margin-top:10px;">
                        <i class="fas fa-plus"></i> Add Item
                    </button>
                </div>
                <button type="submit" class="btn-submit">Submit Request</button>
            </form>
        </div>
    </div>

    <script>
        function addRow() {
            const container = document.getElementById('restock-items-container');
            const row = document.createElement('div');
            row.className = 'item-row';
            row.innerHTML = `
                <select name="itemID[]" class="form-control" required>
                    <option value="">-- Select Item --</option>
                    <% if(items != null) for(InventoryItem item : items) { %><option value="<%= item.getItemID() %>"><%= item.getIName() %></option><% } %>
                </select>
                <input type="number" name="quantity[]" class="form-control" placeholder="Qty" min="1" required>
                <button type="button" onclick="this.parentElement.remove()" style="background:none; border:none; color:#ef4444; cursor:pointer;"><i class="fas fa-trash"></i></button>
            `;
            container.appendChild(row);
        }
    </script>
</body>
</html>