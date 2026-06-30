<%-- Document: newRequest.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.InventoryItem" %>
<%@ page import="java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    // Retrieve list from Servlet
    List<InventoryItem> inventoryList = (List<InventoryItem>) request.getAttribute("inventoryList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - New Aid Request</title>
    <link rel="stylesheet" href="Sidebar.css">
    
    <style>
        /* [KEEP YOUR CSS STYLES HERE] */
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; column-gap: 48px; row-gap: 20px; }
        .form-input, select { flex: 1; padding: 8px 12px; border: 1px solid #9ca3af; border-radius: 4px; width: 100%;}
        .form-input[readonly] { background-color: #f3f4f6; cursor: not-allowed; }
        .items-section { margin-top: 32px; border-top: 1px solid #e2e8f0; padding-top: 30px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #9ca3af; padding: 8px 16px; text-align: left; }
        .btn-save { background-color: #4A7BA7; color: white; width: 100%; padding: 12px; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; margin-top: 32px; }
        
        /* New Style for Unit Input */
        .unit-input { background-color: #f3f4f6; border: none; width: 100%; color: #64748b; font-weight: bold; }
    </style>

    <script>
        // 1. UPDATE DATA STRUCTURE: Include 'unit'
        const inventoryItems = [
            <% 
            if (inventoryList != null) {
                for(int i=0; i<inventoryList.size(); i++) {
                    InventoryItem item = inventoryList.get(i);
                    // Ensure your InventoryItem model has a getUnit() method. 
                    // If not, replace item.getUnit() with a default string like "Unit"
                    String unit = (item.getUnit() != null) ? item.getUnit() : "-";
            %>
                { id: "<%= item.getItemID() %>", name: "<%= item.getIName() %>", unit: "<%= unit %>" }<%= (i < inventoryList.size()-1) ? "," : "" %>
            <% 
                } 
            }
            %>
        ];
        
        let rowCount = 0;

        function addNewItem() {
            rowCount++;
            let optionsHtml = '<option value="">-- Select Item --</option>';
            inventoryItems.forEach(item => optionsHtml += '<option value="' + item.id + '">' + item.name + '</option>');
            
            const newRow = document.createElement("tr");
            newRow.id = "row_" + rowCount;
            
            // 2. UPDATE ROW HTML: Added Unit Column and onchange event
            newRow.innerHTML = `
                <td style="text-align:center;">` + rowCount + `</td>
                <td>
                    <select name="itemId" class="form-input" onchange="updateUnit(this, 'unit_` + rowCount + `')" required>
                        ` + optionsHtml + `
                    </select>
                </td>
                <td>
                    <input type="text" id="unit_` + rowCount + `" class="form-input unit-input" readonly>
                </td>
                <td>
                    <input type="number" name="quantity" class="form-input" placeholder="Enter Qty" min="1" required>
                </td>
                <td style="text-align:center;">
                    <button type="button" onclick="document.getElementById('row_` + rowCount + `').remove()">Remove</button>
                </td>
            `;
            document.getElementById("requestTableBody").appendChild(newRow);
            document.getElementById("emptyMessage").style.display = "none";
        }

        // 3. NEW FUNCTION: Retrieve Unit based on selection
        function updateUnit(selectElement, unitFieldId) {
            const selectedId = selectElement.value;
            const item = inventoryItems.find(i => i.id === selectedId);
            
            // Find the unit input field for this specific row
            const unitInput = document.getElementById(unitFieldId);
            
            if (item) {
                unitInput.value = item.unit;
            } else {
                unitInput.value = "";
            }
        }
    </script>
</head>
<body>
    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <div class="main-content-scrollable">
        <div class="form-card">
            <h1 class="page-title">New Request</h1>
            
            <form action="insertRequest" method="POST">
                <div class="form-grid">
                    <div style="margin-bottom: 20px;">
                        <label>Requester:</label>
                        <input type="text" class="form-input" value="<%= currentUser.getUserName() %>" readonly>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label>Submitted Date:</label>
                        <% 
                           java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                           String today = sdf.format(new java.util.Date());
                        %>
                        <input type="date" name="submittedDate" value="<%= today %>" class="form-input" readonly>
                    </div>
                    
                    <div style="margin-bottom: 20px;">
                        <label>Status:</label>
                        <input type="text" name="status" value="Draft" class="form-input" readonly>
                    </div>
                </div>

                <div class="items-section">
                    <label>Request Items:</label>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">No</th>
                                    <th>Item</th>
                                    <th style="width: 100px;">Unit</th> <th style="width: 150px;">Quantity</th>
                                    <th style="width: 100px;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="requestTableBody"></tbody>
                        </table>
                        <div id="emptyMessage" style="text-align: center; padding: 20px;">No items added yet.</div>
                    </div>
                    <button type="button" onclick="addNewItem()" style="color:#0b5ea8; background:none; border:none; margin-top:10px; cursor:pointer;">+ Add New Item</button>
                </div>

                <button type="submit" class="btn-save">Save Request</button>
            </form>
        </div>
    </div>
</body>
</html>