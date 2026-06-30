<%-- 
    Document   : Chat
    Created on : Jun 12, 2026, 2:37:52 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    List<Map<String, String>> recentChats = (List<Map<String, String>>) request.getAttribute("recentChats");
    List<Map<String, String>> staffList = (List<Map<String, String>>) request.getAttribute("staffList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Internal Communication</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="Sidebar.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f0f2f5; height: 100vh; overflow: hidden; }
        .main-content-area { position: fixed; top: 60px; left: 250px; right: 0; bottom: 0; padding: 20px; }
        .fixed-header { position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1001; background-color: #0b5ea8; color: white; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        
        .chat-container { display: flex; height: 100%; background: #fff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #e2e8f0; }
        
        /* Left Side: Contact Lists */
        .chat-sidebar { width: 340px; background: #ffffff; border-right: 1px solid #e2e8f0; display: flex; flex-direction: column; }
        .chat-sidebar-header { padding: 15px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;}
        .chat-sidebar-header h3 { margin: 0; font-size: 16px; color: #1e293b; }
        
        .btn-new-chat { background: #0b5ea8; color: white; border: none; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: bold; }
        .btn-back { background: transparent; color: #64748b; border: none; cursor: pointer; font-size: 14px; display: flex; align-items: center; gap: 5px; padding: 0; }
        
        .contact-list { overflow-y: auto; flex: 1; display: none; } 
        .contact-list.active-view { display: block; } 
        
        .contact-item { display: flex; align-items: center; padding: 15px 20px; border-bottom: 1px solid #f1f5f9; cursor: pointer; transition: background 0.2s; }
        .contact-item:hover, .contact-item.active { background: #f1f5f9; }
        .contact-avatar { width: 45px; height: 45px; border-radius: 50%; background: #0b5ea8; color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; margin-right: 15px; flex-shrink: 0; text-transform: uppercase;}
        .contact-info { flex: 1; overflow: hidden; }
        .contact-name { margin: 0; font-weight: 600; color: #1e293b; font-size: 15px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        
        .contact-preview { margin: 3px 0 0 0; font-size: 13px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .contact-time { font-size: 11px; color: #94a3b8; }
        
        /* Right Side: Chat Window */
        .chat-main { flex: 1; display: flex; flex-direction: column; background: #e5ddd5; position: relative; }
        .chat-main::before { content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0; background-image: url('https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png'); opacity: 0.06; z-index: 0; }
        .chat-header { padding: 15px 25px; background: #ffffff; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; z-index: 1; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .chat-header h3 { margin: 0; font-size: 18px; color: #1e293b; }
        
        .chat-messages { flex: 1; padding: 25px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; z-index: 1; }
        .msg-bubble { max-width: 65%; padding: 10px 15px; border-radius: 8px; font-size: 14px; line-height: 1.4; position: relative; box-shadow: 0 1px 2px rgba(0,0,0,0.1); word-wrap: break-word; }
        .msg-received { background: #ffffff; align-self: flex-start; border-top-left-radius: 0; }
        .msg-sent { background: #dcf8c6; align-self: flex-end; border-top-right-radius: 0; }
        .msg-time { display: block; font-size: 10px; color: #64748b; text-align: right; margin-top: 5px; }
        
        /* Input Area */
        .chat-input-area { padding: 15px 20px; background: #f0f2f5; display: flex; align-items: center; gap: 15px; z-index: 1; }
        .chat-input { flex: 1; padding: 12px 20px; border: none; border-radius: 24px; font-size: 15px; outline: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .btn-send { background: #0b5ea8; color: white; border: none; width: 45px; height: 45px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; transition: background 0.2s; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .btn-send:disabled { background: #94a3b8; cursor: not-allowed; }
    </style>
</head>
<body>

    <div class="sidebar-container"><jsp:include page="Sidebar.jsp" /></div>
    <jsp:include page="Headbar.jsp" />

    <main class="main-content-area">
        <div class="chat-container">
            
            <div class="chat-sidebar">
                
                <div id="inboxView" class="contact-list active-view">
                    
                    <div class="chat-sidebar-header">
                        <h3><i class="far fa-comments"></i> Recent Chats</h3>
                        <div style="display:flex; gap:8px;">
                            <% if ("Admin".equalsIgnoreCase(currentUser.getRole()) || "Manager".equalsIgnoreCase(currentUser.getRole())) { %>
                                <button class="btn-new-chat" style="background:#f97316;" onclick="document.getElementById('broadcastModal').style.display='flex'" title="Broadcast Announcement">
                                    <i class="fas fa-bullhorn"></i>
                                </button>
                            <% } %>
                            <button class="btn-new-chat" onclick="toggleView('directory')"><i class="fas fa-plus"></i> New Chat</button>
                        </div>
                    </div>
                    
                    <% if (recentChats != null && !recentChats.isEmpty()) { 
                        for (Map<String, String> chat : recentChats) { 
                            int unread = Integer.parseInt(chat.getOrDefault("unreadCount", "0"));
                    %>
                        <div class="contact-item" onclick="loadChat(this, '<%= chat.get("id") %>', '<%= chat.get("name").replace("'", "\\'") %>')">
                            
                            <% if ("SYSTEM".equals(chat.get("id"))) { %>
                                <div class="contact-avatar" style="background: #f97316;"><i class="fas fa-bell"></i></div>
                            <% } else { %>
                                <div class="contact-avatar"><%= chat.get("name").substring(0, 1) %></div>
                            <% } %>

                            <div class="contact-info">
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <p class="contact-name"><%= chat.get("name") %></p>
                                    <span class="contact-time"><%= chat.get("time") %></span>
                                </div>
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <p class="contact-preview"><%= chat.get("lastMsg") %></p>
                                    <% if (unread > 0) { %>
                                        <span class="badge-count" style="background: red; color: white; border-radius: 12px; padding: 2px 8px; font-size: 11px; font-weight: bold;"><%= unread %></span>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <%  } 
                    } else { %>
                        <div style="padding: 30px; text-align: center; color: #94a3b8; font-size: 14px;">
                            <i class="far fa-comment-dots" style="font-size: 30px; margin-bottom:10px;"></i><br>
                            No recent chats.<br>Start a new conversation!
                        </div>
                    <% } %>
                </div>

                <div id="directoryView" class="contact-list">
                    <div class="chat-sidebar-header" style="background:#0b5ea8; color:white;">
                        <button class="btn-back" style="color:white;" onclick="toggleView('inbox')"><i class="fas fa-arrow-left"></i></button>
                        <h3 style="color:white; flex:1; text-align:center;">Select Contact</h3>
                    </div>
                    
                    <% if (staffList != null && !staffList.isEmpty()) { 
                        for (Map<String, String> staff : staffList) { %>
                        <div class="contact-item" onclick="loadChat(this, '<%= staff.get("id") %>', '<%= staff.get("name").replace("'", "\\'") %>')">
                            <div class="contact-avatar"><%= staff.get("name").substring(0, 1) %></div>
                            <div class="contact-info">
                                <p class="contact-name"><%= staff.get("name") %></p>
                                <p class="contact-preview"><%= staff.get("role") %></p>
                            </div>
                        </div>
                    <%  } } else { %>
                        <div style="padding: 30px; text-align: center; color: #94a3b8; font-size: 14px;">
                            No other staff found in this shelter.
                        </div>
                    <% } %>
                </div>

            </div>

            <div class="chat-main">
                <div class="chat-header">
                    <div class="contact-avatar" style="width:40px; height:40px; margin-right:15px; display:none;" id="activeAvatar"></div>
                    <h3 id="activeChatName" style="color: #94a3b8;">Select a conversation</h3>
                </div>
                
                <div class="chat-messages" id="chatBox">
                    </div>

                <form class="chat-input-area" onsubmit="sendMessage(event)">
                    <input type="hidden" id="activeContactID" name="receiverID">
                    <input type="text" id="msgInput" class="chat-input" placeholder="Type a message..." required autocomplete="off" disabled>
                    <button type="submit" id="sendBtn" class="btn-send" disabled><i class="fas fa-paper-plane"></i></button>
                </form>
            </div>
            
        </div>
    </main>

    <%-- ========================================= --%>
    <%-- MODAL: ADMIN BROADCAST ANNOUNCEMENT       --%>
    <%-- ========================================= --%>
    <div id="broadcastModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(15,23,42,0.7); z-index:2000; align-items:center; justify-content:center; backdrop-filter:blur(3px);">
        <div style="background:white; width:100%; max-width:500px; border-radius:12px; overflow:hidden; box-shadow:0 20px 25px -5px rgba(0,0,0,0.2);">
            <div style="padding:20px 24px; background:#f97316; color:white; display:flex; justify-content:space-between; align-items:center;">
                <h3 style="margin:0; font-size:18px;"><i class="fas fa-bullhorn"></i> Broadcast Announcement</h3>
                <button onclick="document.getElementById('broadcastModal').style.display='none'" style="background:none; border:none; color:white; font-size:24px; cursor:pointer;">&times;</button>
            </div>
            
            <form action="broadcastMessage" method="POST" style="padding:24px;">
                <div style="margin-bottom:20px;">
                    <label style="display:block; font-weight:bold; color:#1e293b; margin-bottom:8px;">Target Audience:</label>
                    <select name="targetShelter" style="width:100%; padding:10px; border-radius:6px; border:1px solid #cbd5e1; outline:none;" required>
                        <% if ("Admin".equalsIgnoreCase(currentUser.getRole())) { %>
                            <option value="ALL_SHELTERS">🚨 ALL SHELTERS (Global Alert)</option>
                            <option value="SH0001">SK Gong Badak (SH0001)</option>
                            <option value="SH0002">UMT (SH0002)</option>
                            <option value="SH0003">UMT (SH0003)</option>
                            <option value="SH0004">Sk Sri Gading (SH0004)</option>
                            <option value="SH0005">Unisza (SH0005)</option>
                        <% } else { %>
                            <option value="<%= currentUser.getAssignedRegion() %>">My Shelter (<%= currentUser.getAssignedRegion() %>)</option>
                        <% } %>
                    </select>
                </div>
                
                <div style="margin-bottom:20px;">
                    <label style="display:block; font-weight:bold; color:#1e293b; margin-bottom:8px;">Announcement Message:</label>
                    <textarea name="content" rows="4" style="width:100%; padding:12px; border-radius:6px; border:1px solid #cbd5e1; outline:none; resize:none; font-family:inherit;" placeholder="Type your emergency alert or announcement here..." required></textarea>
                </div>
                
                <button type="submit" style="width:100%; padding:14px; background:#f97316; color:white; border:none; border-radius:8px; font-weight:bold; font-size:16px; cursor:pointer;">
                    Send Broadcast Now
                </button>
            </form>
        </div>
    </div>

    <script>
        let currentContact = null;
        let refreshTimer = null;

        function toggleView(view) {
            if (view === 'directory') {
                document.getElementById('inboxView').classList.remove('active-view');
                document.getElementById('directoryView').classList.add('active-view');
            } else {
                document.getElementById('directoryView').classList.remove('active-view');
                document.getElementById('inboxView').classList.add('active-view');
            }
        }

        // FIXED: Added element parameter to safely apply .active and clear unread badges instantly
        function loadChat(element, userId, userName) {
            currentContact = userId;
            document.getElementById('activeContactID').value = userId;
            
            document.getElementById('activeChatName').innerText = userName;
            document.getElementById('activeChatName').style.color = '#1e293b';
            
            if (userId === 'SYSTEM') {
                document.getElementById('activeAvatar').innerHTML = '<i class="fas fa-bell"></i>';
                document.getElementById('activeAvatar').style.background = '#f97316';
                document.getElementById('msgInput').disabled = true;
                document.getElementById('msgInput').placeholder = "You cannot reply to system notifications.";
                document.getElementById('sendBtn').disabled = true;
            } else {
                document.getElementById('activeAvatar').innerText = userName.charAt(0);
                document.getElementById('activeAvatar').style.background = '#0b5ea8';
                document.getElementById('msgInput').disabled = false;
                document.getElementById('msgInput').placeholder = "Type a message...";
                document.getElementById('sendBtn').disabled = false;
            }
            
            document.getElementById('activeAvatar').style.display = 'flex';
            toggleView('inbox');
            
            // Manage active highlighting safely
            document.querySelectorAll('.contact-item').forEach(item => item.classList.remove('active'));
            if(element) {
                element.classList.add('active');
                
                // UX ENHANCEMENT: Immediately clear the unread red badge element upon clicking
                let badge = element.querySelector('.badge-count');
                if(badge) badge.remove();
            }
            
            fetchMessages();
            if (refreshTimer) clearInterval(refreshTimer);
            refreshTimer = setInterval(fetchMessages, 3000); 
        }

        function fetchMessages() {
            if (!currentContact) return;
            
            fetch('fetchMessages?contactID=' + currentContact)
                .then(response => response.text())
                .then(html => {
                    let chatBox = document.getElementById('chatBox');
                    let isAtBottom = chatBox.scrollHeight - chatBox.scrollTop <= chatBox.clientHeight + 50;
                    
                    chatBox.innerHTML = html;
                    if (isAtBottom) chatBox.scrollTop = chatBox.scrollHeight;
                });
        }

        function sendMessage(e) {
            e.preventDefault();
            let input = document.getElementById('msgInput');
            let content = input.value;
            let receiverID = document.getElementById('activeContactID').value;
            
            if(!content.trim() || !receiverID) return;

            let chatBox = document.getElementById('chatBox');
            chatBox.innerHTML += `<div class="msg-bubble msg-sent">\${content.replace(/</g, "&lt;")}<span class="msg-time">Sending...</span></div>`;
            chatBox.scrollTop = chatBox.scrollHeight;
            input.value = '';

            fetch('sendMessage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'receiverID=' + encodeURIComponent(receiverID) + '&content=' + encodeURIComponent(content)
            }).then(() => {
                fetchMessages(); 
            });
        }
    </script>
</body>
</html>