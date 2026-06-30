<%-- 
    Document   : Headbar
    Created on : Jun 12, 2026, 1:25:54 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.DAO.NotificationDAO" %>
<%@ page import="com.DAO.MessageDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    // Fetch user securely inside the header
    User headerUser = (User) session.getAttribute("currentUser");
    if (headerUser != null) {
        // System Notifications (Alerts)
        NotificationDAO notifDAO = new NotificationDAO();
        int notifCount = notifDAO.getNotificationCount(headerUser.getUserID());
        List<Map<String, String>> myNotifs = notifDAO.getMyNotifications(headerUser.getUserID());
        
        // Internal Staff Messages (Chats)
        int floatingUnreadCount = new MessageDAO().getUnreadChatCount(headerUser.getUserID());
%>

<header class="fixed-header">
    <div>
        <img src="Image/Logo_ADMS.png" style="height:24px;"> 
        <span style="font-weight:700; font-size: 20px;">ADMS</span>
    </div>

    <div style="display: flex; align-items: center; gap: 20px;">
        
        <div style="position: relative;">
            <div id="bellIcon" style="cursor: pointer; position: relative;" onclick="toggleNotifDropdown()">
                <i class="fas fa-bell" style="font-size: 18px; color: white;"></i>
                <% if(notifCount > 0) { %>
                    <span style="position: absolute; top: -5px; right: -8px; background: red; color: white; border-radius: 50%; padding: 2px 6px; font-size: 10px; font-weight: bold;"><%= notifCount %></span>
                <% } %>
            </div>

            <div id="notifDropdown" style="display: none; position: absolute; right: 0; top: 35px; width: 320px; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border-radius: 8px; border: 1px solid #e2e8f0; z-index: 2000; overflow: hidden; color: #1e293b;">
                <div style="background: #f8fafc; padding: 12px 15px; font-weight: bold; border-bottom: 1px solid #e2e8f0; font-size: 14px;">
                    Recent Notifications
                </div>
                <div style="max-height: 300px; overflow-y: auto;">
                    <% if(myNotifs != null && !myNotifs.isEmpty()) {
                           for(Map<String, String> n : myNotifs) { %>
                        <div style="padding: 12px 15px; border-bottom: 1px solid #f1f5f9; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='#f8fafc'" onmouseout="this.style.backgroundColor='white'">
                            <p style="margin: 0; font-size: 13px; color: #334155; line-height: 1.4;"><%= n.get("content") %></p>
                            <span style="font-size: 11px; color: #94a3b8; margin-top: 6px; display: block;">
                                <i class="far fa-clock"></i> <%= n.get("time") %>
                            </span>
                        </div>
                    <% } } else { %>
                        <div style="padding: 20px; text-align: center; color: #94a3b8; font-size: 13px;">
                            <i class="fas fa-check-circle" style="font-size: 24px; margin-bottom: 10px; opacity: 0.5; display:block;"></i>
                            You're all caught up!
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div style="background:rgba(255,255,255,0.1); padding:5px 12px; border-radius:4px; color: white;">
            <%= headerUser.getUserName() %> | <%= headerUser.getRole().toUpperCase() %>
        </div>
    </div>
</header>

<style>
    .floating-chat-btn {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 60px;
        height: 60px;
        background-color: #0b5ea8;
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        z-index: 9999;
        text-decoration: none;
        transition: transform 0.2s, background-color 0.2s;
    }
    
    .floating-chat-btn:hover {
        transform: scale(1.1);
        background-color: #094b86;
        color: white;
    }
    
    .floating-chat-badge {
        position: absolute;
        top: -4px;
        right: -4px;
        background-color: #ef4444; 
        color: white;
        font-size: 13px;
        font-weight: bold;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        border: 2px solid white;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }

    @keyframes pulse-red {
        0% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
        70% { box-shadow: 0 0 0 15px rgba(239, 68, 68, 0); }
        100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
    }
    
    .has-new-messages {
        animation: pulse-red 2s infinite;
        background-color: #ef4444; 
    }
</style>

<a href="Chat" class="floating-chat-btn <%= (floatingUnreadCount > 0) ? "has-new-messages" : "" %>" id="floatingChatBtn">
    <i class="far fa-comment-dots"></i>
    <div class="floating-chat-badge" id="chatBadge" style="<%= (floatingUnreadCount > 0) ? "display:flex;" : "display:none;" %>">
        <%= floatingUnreadCount %>
    </div>
</a>

<script>
    function toggleNotifDropdown() {
        var dropdown = document.getElementById("notifDropdown");
        dropdown.style.display = dropdown.style.display === "none" ? "block" : "none";
    }

    window.onclick = function(event) {
        if (!event.target.closest('#bellIcon') && !event.target.closest('#notifDropdown')) {
            var dropdown = document.getElementById("notifDropdown");
            if (dropdown) {
                dropdown.style.display = "none";
            }
        }
    }

    // Live background polling for unread direct messages
    let currentUnread = <%= floatingUnreadCount %>;

    setInterval(() => {
        fetch('checkMessages') 
            .then(response => response.text())
            .then(data => {
                let newCount = parseInt(data.trim());
                
                if (!isNaN(newCount) && newCount !== currentUnread) {
                    currentUnread = newCount;
                    let badge = document.getElementById('chatBadge');
                    let btn = document.getElementById('floatingChatBtn');
                    
                    if (currentUnread > 0) {
                        badge.innerText = currentUnread;
                        badge.style.display = 'flex';
                        btn.classList.add('has-new-messages');
                    } else {
                        badge.style.display = 'none';
                        btn.classList.remove('has-new-messages');
                    }
                }
            }).catch(e => console.log("Silent error checking messages"));
    }, 5000);
</script>

<% } %>