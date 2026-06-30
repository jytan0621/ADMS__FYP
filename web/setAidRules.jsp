<%-- Document: setDistributionRules.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="com.Model.DistributionRule" %>
<%@ page import="com.Model.InventoryItem" %>

<%
    // Security check: Must be logged in AND must be a Field Officer
    User currentUser = (User) session.getAttribute("currentUser");
    
    if (currentUser == null) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
    
    // Check if the user role is NOT Field Officer
    if (!"Field Officer".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("dashboard.jsp?error=UnauthorizedAccess"); 
        return; 
    }
    
    // Retrieve data passed from the Master Controller
    List<DistributionRule> currentRules = (List<DistributionRule>) request.getAttribute("currentRules");
    List<InventoryItem> items = (List<InventoryItem>) request.getAttribute("inventoryItems");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Set Aid Rations</title>
    <link rel="stylesheet" href="Sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f8fafc; height: 100vh; overflow: hidden; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 50; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .sidebar-container { position: fixed; top: 60px; left: 0; bottom: 0; width: 250px; z-index: 40; }
        .main-content-scrollable { margin-left: 250px; padding: 90px 40px 60px 40px; height: 100vh; overflow-y: auto; background-color: #f8fafc; }
        
        .form-card { background: white; width: 100%; max-width: 1024px; margin: 0 auto; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; }
        .form-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; }
        .page-title { font-size: 32px; font-weight: 400; color: #000; margin: 0; }
        
        /* Table Styles for Current Rules */
        .table-container { border: 1px solid #cbd5e1; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 40px;}
        table { width: 100%; border-collapse: collapse; background: white; }
        th { border-bottom: 2px solid #cbd5e1; padding: 12px 16px; text-align: left; font-weight: bold; color: #334155; background-color: #f8fafc; }
        td { border-bottom: 1px solid #e2e8f0; padding: 12px 16px; color: #1e293b; vertical-align: middle; }
        
        /* Form Grid Styles */
        .section-title { font-size: 20px; font-weight: bold; color: #0f172a; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #f1f5f9; }
        .rule-row { display: grid; grid-template-columns: 2fr 1fr 1fr auto; gap: 15px; padding: 15px; border: 1px solid #e2e8f0; border-radius: 8px; background: #f8fafc; margin-bottom: 15px; align-items: end; }
        .form-label { color: #000; font-size: 14px; font-weight: 600; display: block; margin-bottom: 8px; }
        .form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; background-color: #fff; transition: 0.2s; box-sizing: border-box; }
        .form-input:focus { border-color: #0b5ea8; box-shadow: 0 0 0 3px rgba(11,94,168,0.1); }
        
        /* Buttons */
        .btn-add { color: #0b5ea8; background: #e0f2fe; border: 1px dashed #0ea5e9; padding: 12px; width: 100%; cursor: pointer; margin-top: 10px; border-radius: 6px; font-weight: bold; font-size: 15px; transition: 0.2s; }
        .btn-add:hover { background: #bae6fd; }
        .btn-remove { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; padding: 10px 15px; border-radius: 6px; cursor: pointer; height: 40px; font-weight: bold; transition: 0.2s; }
        .btn-remove:hover { background: #fca5a5; }
        .btn-save { background-color: #0b5ea8; color: white; width: 100%; padding: 15px; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin-top: 32px; font-weight: bold; transition: 0.2s; }
        .btn-save:hover { background-color: #094b86; }

        .btn-delete-rule { background: #ef4444; color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-weight: bold; transition: 0.2s; }
        .btn-delete-rule:hover { background: #dc2626; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <% 
                String success = request.getParameter("success");
                String deleted = request.getParameter("deleted");
                String error = request.getParameter("error");
                
                if ("true".equals(success)) { 
            %>
                <div style="background-color: #dcfce7; color: #166534; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #bbf7d0; text-align: center;">
                    <i class="fas fa-check-circle"></i> New Distribution Rule(s) added successfully!
                </div>
            <% } else if ("true".equals(deleted)) { %>
                <div style="background-color: #fee2e2; color: #991b1b; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #fecaca; text-align: center;">
                    <i class="fas fa-trash-alt"></i> Rule deleted successfully from active list.
                </div>
            <% } else if (error != null) { %>
                <div style="background-color: #fffbeb; color: #b45309; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #fde68a; text-align: center;">
                    <i class="fas fa-exclamation-triangle"></i> Action Failed. System error code: <%= error %>
                </div>
            <% } %>

            <div class="form-header">
                <h1 class="page-title"><i class="fas fa-calculator" style="color: #0b5ea8; margin-right: 10px;"></i> Define Aid Rations</h1>
            </div>
            
            <p style="color: #64748b; margin-bottom: 30px;">
                Configure the standard quantities per person. These settings automatically generate distribution tasks for volunteers based on active tent populations.
            </p>

            <h3 class="section-title">Current Active Rules</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Rule ID</th>
                            <th>Item Name</th>
                            <th style="text-align: center;">Qty / Person</th>
                            <th>Ration Type</th>
                            <th style="text-align: center;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (currentRules != null && !currentRules.isEmpty()) { 
                            for (DistributionRule rule : currentRules) { 
                        %>
                            <tr>
                                <td style="color: #64748b; font-weight: 600;"><%= rule.getRuleID() %></td>
                                <td><strong><%= rule.getItemName() %></strong></td>
                                <td style="text-align: center; font-size: 16px; font-weight: bold;"><%= rule.getQtyPerPerson() %></td>
                                <td>
                                    <% if ("DAILY".equals(rule.getDistType().trim().toUpperCase())) { %>
                                        <span style="background: #dcfce7; color: #166534; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;">Daily Ration</span>
                                    <% } else { %>
                                        <span style="background: #ffedd5; color: #c2410c; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;">One-Off Entry</span>
                                    <% } %>
                                </td>
                                <td style="text-align: center;">
                                    <form action="deleteRule" method="POST" style="margin: 0; display: inline;">
                                        <input type="hidden" name="ruleID" value="<%= rule.getRuleID() %>">
                                        <button type="submit" class="btn-delete-rule" onclick="return confirm('Are you sure you want to permanently delete Rule <%= rule.getRuleID() %>? This will change the metrics for all active tents.');">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <%  } 
                        } else { %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: #94a3b8; padding: 30px; font-style: italic;">
                                    No distribution rules have been configured yet.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <h3 class="section-title">Configure New Rules</h3>
            <div style="background-color: #e0f2fe; color: #0369a1; padding: 12px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #bae6fd; font-size: 14px;">
                <i class="fas fa-info-circle"></i> <strong>Note:</strong> Items added below will append directly to your list above. Existing active rules are fully preserved.
            </div>

            <form action="AddRuleServlet" method="POST">
                <div id="rule-container">
                    <div class="rule-row">
                        <div>
                            <label class="form-label">Item Name</label>
                            <select name="itemID[]" class="form-input" required>
                                <option value="" disabled selected>Select an Inventory Item</option>
                                <% 
                                    if (items != null) {
                                        for (InventoryItem item : items) { 
                                %>
                                    <option value="<%= item.getItemID() %>"><%= item.getIName() %> (<%= item.getCategory() %>)</option>
                                <% 
                                        }
                                    } 
                                %>
                            </select>
                        </div>
                        <div>
                            <label class="form-label">Qty / Person</label>
                            <input type="number" name="qty[]" value="1" min="1" class="form-input" required>
                        </div>
                        <div>
                            <label class="form-label">Ration Type</label>
                            <select name="distType[]" class="form-input" required>
                                <option value="DAILY">Daily Ration</option>
                                <option value="ONE_OFF">One-Off (Entry)</option>
                            </select>
                        </div>
                        <div>
                            <button type="button" class="btn-remove" onclick="removeRule(this)" title="Remove Item"><i class="fas fa-trash"></i></button>
                        </div>
                    </div>
                </div>

                <button type="button" class="btn-add" onclick="addRule()">
                    <i class="fas fa-plus-circle"></i> Add Another Item Rule
                </button>
                
                <button type="submit" class="btn-save">
                    <i class="fas fa-save"></i> Save & Apppend Rules
                </button>
            </form>
            
        </div>
    </div>

    <script>
        function addRule() {
            const container = document.getElementById('rule-container');
            const firstRow = container.firstElementChild;
            const newRow = firstRow.cloneNode(true);
            
            // Reset the values of the cloned row
            newRow.querySelector('select[name="itemID[]"]').selectedIndex = 0;
            newRow.querySelector('input[type="number"]').value = 1;
            newRow.querySelector('select[name="distType[]"]').selectedIndex = 0;
            
            container.appendChild(newRow);
        }

        function removeRule(button) {
            const container = document.getElementById('rule-container');
            if (container.children.length > 1) {
                button.closest('.rule-row').remove();
            } else {
                alert("You must have at least one rule row.");
            }
        }
    </script>
</body>
</html>