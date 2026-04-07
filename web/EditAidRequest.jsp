<%-- Document: EditAidRequest.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.AidRequest" %>
<%@ page import="com.Model.AidRequestItem" %>
<%@ page import="com.Model.InventoryItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    // Retrieve Data sent by Servlet
    AidRequest aidRequest = (AidRequest) request.getAttribute("aidRequest");
    List<InventoryItem> inventoryList = (List<InventoryItem>) request.getAttribute("inventoryList");
    
    // Items from Session
    List<AidRequestItem> currentItems = (List<AidRequestItem>) session.getAttribute("tempRequestItems");
    if (currentItems == null) currentItems = new ArrayList<>();

    // Safety Checks
    if (aidRequest == null) { response.sendRedirect("listRequest"); return; }
    if (!"Pending".equalsIgnoreCase(aidRequest.getArStatus())) {
        response.sendRedirect("viewRequest?id=" + aidRequest.getRequestID());
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Edit Request</title>
    <link rel="stylesheet" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        /* Same Styles as NewRequest */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
        .page-title { font-size: 32px; font-weight: 400; color: #000; margin: 0; }
        .back-btn { text-decoration: none; color: #000; display: flex; align-items: center; }
        
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 48px; row-gap: 20px; }
        .form-group { display: flex; align-items: center; gap: 16px; }
        .form-label { min-width: 140px; color: #000; font-size: 16px; font-weight: 600; }
        .form-input { flex: 1; padding: 8px 12px; border: 1px solid #9ca3af; border-radius: 4px; font-size: 14px; background-color: #fff; }
        .form-input[readonly] { background-color: #f3f4f6; cursor: not-allowed; border: 1px solid #cbd5e1; }
        
        .status-pending { color: #854d0e; font-weight: bold; background-color: #fef9c3; border: 1px solid #fde047; }

        .items-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        .table-container { border: 1px solid #9ca3af; border-radius: 4px; overflow: hidden;}
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f1f5f9; border: 1px solid #9ca3af; padding: 10px 16px; text-align: left; font-weight: bold; }
        td { border: 1px solid #9ca3af; padding: 10px 16px; vertical-align: middle; }
        
        .btn-add-row { color: #0b5ea8; text-decoration: none; background: none; border: none; cursor: pointer; margin-top: 15px; display: inline-flex; align-items: center; gap: 5px; font-weight: 600; }
        .btn-add-row:hover { text-decoration: underline; }
        .btn-delete { color: #dc2626; text-decoration: underline; background: none; border: none; cursor: pointer; font-size: 14px; }
        .btn-container { display: flex; justify-content: flex-end; gap: 15px; margin-top: 40px; }
        .btn { padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 600; text-decoration: none; text-align: center; cursor: pointer; border: none; }
        .btn-cancel { background-color: #e2e8f0; color: #475569; }
        .btn-save { background-color: #0b5ea8; color: white; }
        
        .unit-input { background-color: #f3f4f6; border: none; width: 100%; color: #64748b; font-weight: bold; }
    </style>

    <script>
        let rowCount = <%= currentItems.size() %>;
        
        // Populate Inventory Array with Units
        const inventoryItems = [
            <% 
            if (inventoryList != null) {
                for(int i=0; i<inventoryList.size(); i++) {
                    InventoryItem item = inventoryList.get(i);
                    String unit = (item.getUnit() != null) ? item.getUnit() : "-";
            %>
                { id: "<%= item.getItemID() %>", name: "<%= item.getIName() %>", unit: "<%= unit %>" }<%= (i < inventoryList.size()-1) ? "," : "" %>
            <% 
                } 
            }
            %>
        ];

        function addNewItem() {
            rowCount++;
            const tableBody = document.getElementById("requestTableBody");
            
            let optionsHtml = '<option value="">-- Select --</option>';
            inventoryItems.forEach(item => optionsHtml += '<option value="' + item.id + '">' + item.name + '</option>');

            const newRow = document.createElement("tr");
            newRow.id = "row_new_" + rowCount;
            newRow.innerHTML = `
                <td style="text-align:center; color:#64748b;">New</td>
                <td>
                    <select name="itemId" class="form-input" onchange="updateUnit(this, 'unit_new_` + rowCount + `')" required>
                        ` + optionsHtml + `
                    </select>
                </td>
                <td>
                    <input type="text" id="unit_new_` + rowCount + `" class="form-input unit-input" readonly>
                </td>
                <td><input type="number" name="quantity" class="form-input" placeholder="Qty" min="1" required></td>
                <td style="text-align:center;"><button type="button" class="btn-delete" onclick="removeRow('row_new_` + rowCount + `')">Remove</button></td>
            `;
            tableBody.appendChild(newRow);
            document.getElementById("emptyMessage").style.display = "none";
        }

        // Helper to update unit
        function updateUnit(selectElement, unitFieldId) {
            const selectedId = selectElement.value;
            const item = inventoryItems.find(i => i.id === selectedId);
            const unitInput = document.getElementById(unitFieldId);
            
            if (item) {
                unitInput.value = item.unit;
            } else {
                unitInput.value = "";
            }
        }

        function removeRow(rowId) {
            const row = document.getElementById(rowId);
            if(row) row.remove();
            if(document.getElementById("requestTableBody").children.length === 0) {
                 document.getElementById("emptyMessage").style.display = "block";
            }
        }
    </script>
</head>
<body>
    <header class="fixed-header">
        <div style="display: flex; gap: 10px; align-items: center;">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;"> 
            <span style="font-size:20px; font-weight:bold;">ADMS</span>
        </div>
        <div><%= currentUser.getUserName() %> | <%= currentUser.getRole().toUpperCase() %></div>
    </header>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>

    <div class="main-content-scrollable">
        <div class="form-card">
            <div class="form-header">
                <a href="listRequest" class="back-btn" title="Cancel Editing">
                    <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
                </a>
                <h1 class="page-title" style="margin-left: 15px;">Edit Request #<%= aidRequest.getRequestID() %></h1>
            </div>

            <form action="updateRequest" method="POST">
                <input type="hidden" name="requestID" value="<%= aidRequest.getRequestID() %>">

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Requester:</label>
                        <input type="text" value="<%= aidRequest.getRequestedBy() %>" class="form-input" readonly>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Date Submitted:</label>
                        <input type="text" value="<%= aidRequest.getArDateSubmitted() %>" class="form-input" readonly>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Current Status:</label>
                        <input type="text" value="<%= aidRequest.getArStatus() %>" class="form-input status-pending" readonly>
                    </div>
                </div>

                <div class="items-section">
                    <h3 style="margin-bottom:15px; font-size:18px; color:#374151;">Requested Items</h3>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align:center;">No</th>
                                    <th>Item</th>
                                    <th style="width: 100px;">Unit</th>
                                    <th style="width: 150px;">Quantity</th>
                                    <th style="width: 100px; text-align:center;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="requestTableBody">
                                <% 
                                int displayCount = 0;
                                if(currentItems != null && !currentItems.isEmpty()) {
                                    for(AidRequestItem item : currentItems) {
                                        displayCount++;
                                        // Try to find Unit from Inventory List logic
                                        String currentUnit = "-";
                                        if (inventoryList != null) {
                                            for(InventoryItem inv : inventoryList) {
                                                if(inv.getItemID().equals(item.getItemID())) {
                                                    currentUnit = (inv.getUnit() != null) ? inv.getUnit() : "-";
                                                    break;
                                                }
                                            }
                                        }
                                %>
                                <tr id="row_old_<%= displayCount %>">
                                    <td style="text-align:center;"><%= displayCount %></td>
                                    <td>
                                        <select name="itemId" class="form-input" onchange="updateUnit(this, 'unit_old_<%= displayCount %>')" required>
                                            <option value="">-- Select --</option>
                                            <% for(InventoryItem inv : inventoryList) { 
                                               String selected = (inv.getItemID().equals(item.getItemID())) ? "selected" : "";
                                            %>
                                            <option value="<%= inv.getItemID() %>" <%= selected %>><%= inv.getIName() %></option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td>
                                        <input type="text" id="unit_old_<%= displayCount %>" class="form-input unit-input" value="<%= currentUnit %>" readonly>
                                    </td>
                                    <td><input type="number" name="quantity" value="<%= item.getArQuantityRequested() %>" class="form-input" min="1" required></td>
                                    <td style="text-align:center;"><button type="button" class="btn-delete" onclick="removeRow('row_old_<%= displayCount %>')">Remove</button></td>
                                </tr>
                                <% } 
                                } %>
                            </tbody>
                        </table>
                        
                        <div id="emptyMessage" style="text-align: center; color: #9ca3af; padding: 32px; display: <%= (displayCount == 0) ? "block" : "none" %>;">
                            No items in list.
                        </div>
                    </div>
                    
                    <button type="button" class="btn-add-row" onclick="addNewItem()">
                        <i class="fas fa-plus"></i> Add New Item
                    </button>
                </div>
                
                <div class="btn-container">
                    <a href="viewRequest?id=<%= aidRequest.getRequestID() %>" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-save" onclick="return confirm('Update this request?');">Update Request</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>