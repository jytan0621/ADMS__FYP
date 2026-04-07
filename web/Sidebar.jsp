<%-- 
    Document   : sidebar
    Created on : Jan 4, 2026
    Author     : User
--%>

<%@ page import="com.Model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");
    String role = "";
    if (user != null) {
        role = user.getRole();
    }
    
    String activeMenu = (String) session.getAttribute("activeMenu");
    if (activeMenu == null) activeMenu = "";
%>

<link rel="stylesheet" type="text/css" href="Sidebar.css">

<div class="sidebar">

    <div class="menu-scroll-area">

        <a class="menu-title" href="MainMenuServlet?menu=home">Home</a>

        <% if ("home".equals(activeMenu)) { %>
        <div class="submenu">
            <a href="DashboardServlet">Dashboard</a>
            <a href="UserProfile.jsp">User Profile</a>
            <% if ("Admin".equals(role) || "Manager".equals(role)) { %>
                <a href="list">User List</a>
            <% } %>
            <a href="ChangePasswordForm.jsp">Change Password</a>
        </div>
        <% } %>

        <%-- ========================================== --%>
        <%-- NEW: MANAGER ROLE MODULES                  --%>
        <%-- ========================================== --%>
        <% if ("Manager".equals(role)) { %>
            <a class="menu-title" href="MainMenuServlet?menu=shelter">Shelter Control</a>
    
            <% if ("shelter".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="listShelters">Manage Shelters</a>
                <a href="addNewShelter.jsp">New Shelter</a>
            </div>
            <% } %>

            <a class="menu-title" href="MainMenuServlet?menu=report">Review Reports</a>
            <% if ("report".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="occupancyReport.jsp">Shelter Capacity</a>
                <a href="floodAnalysis.jsp">Flood Level Impact</a>
            </div>
            <% } %>
        <% } %>
        
        <% if ("Admin".equals(role)) { %>
            <a class="menu-title" href="MainMenuServlet?menu=beneficiary">Beneficiary</a>
            <% if ("beneficiary".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="NewBeneficiary.jsp">New Beneficiary</a>
                <a href="listBeneficiary">Manage List</a>
            </div>
            <% } %>
            <a class="menu-title" href="MainMenuServlet?menu=aid">Aid Request</a>
            <a class="menu-title" href="MainMenuServlet?menu=inventory">Inventory Item</a>
            <% if ("inventory".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="itemList.jsp">Item List</a>
                <a href="ingoing.jsp">Ingoing List</a>
                <a href="outgoing.jsp">Outgoing List</a>
                <a href="restock.jsp">Restock List</a>
                <a href="supplier.jsp">Supplier List</a>
                <a href="driver.jsp">Driver List</a>
            </div>
            <% } %>

            <a class="menu-title" href="MainMenuServlet?menu=report">Report</a>
            <a class="menu-title" href="MainMenuServlet?menu=message">Message</a>
        <% } %>

        <% if ("Approval Officer".equals(role)) { %>
            <a class="menu-title" href="MainMenuServlet?menu=aid">Aid Request</a>
            <a class="menu-title" href="MainMenuServlet?menu=inventory">Inventory</a>
            <% if ("inventory".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="itemList.jsp">Item List</a>
                <a href="ingoing.jsp">Ingoing List</a>
                <a href="restock.jsp">Restock List</a>
            </div>
            <% } %>
            <a class="menu-title" href="MainMenuServlet?menu=message">Message</a>
        <% } %>

        <% if ("Field Officer".equals(role)) { %>
            <a class="menu-title" href="MainMenuServlet?menu=beneficiary">Beneficiary</a>
            <% if ("beneficiary".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="NewBeneficiary.jsp">New Beneficiary</a>
                <a href="listBeneficiary">Manage List</a>
            </div>
            <% } %>
            <a class="menu-title" href="MainMenuServlet?menu=aid">Aid Request</a>
            <% if ("aid".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="newRequest.jsp">New Request</a>
                <a href="listRequest">Manage List</a>
            </div>
            <% } %>
            <a class="menu-title" href="MainMenuServlet?menu=message">Message</a>
        <% } %>

        <% if ("Logistic Staff".equals(role)) { %>
            <a class="menu-title" href="MainMenuServlet?menu=inventory">Inventory Item</a>
            <% if ("inventory".equals(activeMenu)) { %>
            <div class="submenu">
                <a href="itemList.jsp">Item List</a>
                <a href="newItem.jsp">New Item</a>
                <a href="ingoing.jsp">Ingoing List</a>
                <a href="newIngoing.jsp">New Ingoing</a>
                <a href="outgoing.jsp">Outgoing List</a>
                <a href="newOutgoing.jsp">New Outgoing</a>
                <a href="restock.jsp">Restock List</a>
                <a href="newRestock.jsp">New Restock</a>
                <a href="supplier.jsp">Supplier List</a>
                <a href="driver.jsp">Driver List</a>
            </div>
            <% } %>
            <a class="menu-title" href="MainMenuServlet?menu=message">Message</a>
        <% } %>

    </div> <div class="logout-section">
        <a href="LogoutServlet" class="menu-title logout-btn">
            <img src="Image/Logout.svg" class="logout-icon" alt="Logout">
            <span>Logout</span>
        </a>    
    </div>
        
   
</div>