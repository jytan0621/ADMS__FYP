/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.MessageDAO;
import com.Model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "MessageServlet", urlPatterns = {"/Chat", "/fetchMessages", "/sendMessage", "/checkMessages", "/broadcastMessage"})
public class MessageServlet extends HttpServlet {

    private MessageDAO msgDAO = new MessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) { 
            if ("/checkMessages".equals(request.getServletPath())) { response.getWriter().write("0"); }
            return; 
        }
        
        String path = request.getServletPath();

        // 1. Initial Page Load
        if ("/Chat".equals(path)) {
            List<Map<String, String>> recentChats = msgDAO.getRecentChats(currentUser.getUserID());
            
            // PIN SYSTEM CHAT AT TOP
            Map<String, String> sysChat = new com.DAO.NotificationDAO().getSystemChatPreview(currentUser.getUserID());
            recentChats.add(0, sysChat);
            
            request.setAttribute("recentChats", recentChats);
            
            // Fetch directory restricted to current shelter
            request.setAttribute("staffList", msgDAO.getStaffDirectory(currentUser.getUserID(), currentUser.getAssignedRegion()));
            
            request.getRequestDispatcher("Chat.jsp").forward(request, response);
        } 
        
        // 2. AJAX Request to get messages
        else if ("/fetchMessages".equals(path)) {
            String contactID = request.getParameter("contactID");
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            
            // IF IT'S THE SYSTEM CHAT, LOAD ALERTS
            if ("SYSTEM".equals(contactID)) {
                
                // CLEAR THE RED BADGE
                new com.DAO.NotificationDAO().markAlertsAsRead(currentUser.getUserID());
                
                List<Map<String, String>> sysHistory = new com.DAO.NotificationDAO().getSystemConversation(currentUser.getUserID());
                
                if (sysHistory.isEmpty()) {
                    out.println("<div style='text-align:center; padding:20px; color:#94a3b8; font-style:italic;'>No notifications in the past 14 days.</div>");
                }
                for (Map<String, String> msg : sysHistory) {
                    out.println("<div class='msg-bubble msg-received' style='border-left: 4px solid #f97316; max-width: 80%;'>");
                    out.println("<strong style='color:#f97316;'><i class='fas fa-bell'></i> System Alert</strong><br>");
                    out.println("<div style='margin-top:5px;'>" + msg.get("content").replace("<", "&lt;") + "</div>");
                    out.println("<span class='msg-time'>" + msg.get("time") + "</span>");
                    out.println("</div>");
                }
            } 
            // STANDARD DIRECT MESSAGES
            else {
                msgDAO.markChatAsRead(currentUser.getUserID(), contactID);
                List<Map<String, String>> chatHistory = msgDAO.getConversation(currentUser.getUserID(), contactID);
                
                for (Map<String, String> msg : chatHistory) {
                    boolean isMe = msg.get("sender").equals(currentUser.getUserID());
                    String bubbleClass = isMe ? "msg-sent" : "msg-received";
                    out.println("<div class='msg-bubble " + bubbleClass + "'>");
                    out.println(msg.get("content").replace("<", "&lt;"));
                    out.println("<span class='msg-time'>" + msg.get("time") + "</span>");
                    out.println("</div>");
                }
            }
        }
        
        // 3. AJAX Background Check for Unread Badges
        else if ("/checkMessages".equals(path)) {
            int unreadCount = msgDAO.getUnreadChatCount(currentUser.getUserID());
            response.setContentType("text/plain");
            response.getWriter().write(String.valueOf(unreadCount));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return;
        
        if ("/sendMessage".equals(request.getServletPath())) {
            String receiverID = request.getParameter("receiverID");
            String content = request.getParameter("content");
            
            if (receiverID != null && content != null && !content.trim().isEmpty()) {
                msgDAO.sendMessage(currentUser.getUserID(), receiverID, content);
            }
        }
        
        else if ("/broadcastMessage".equals(request.getServletPath())) {
            // Security Check: Only Admin or Manager can broadcast
            if (!"Admin".equalsIgnoreCase(currentUser.getRole()) && !"Manager".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect("Chat?error=Unauthorized");
                return;
            }

            String targetShelter = request.getParameter("targetShelter");
            String content = request.getParameter("content");

            if (targetShelter != null && content != null && !content.trim().isEmpty()) {
                com.DAO.NotificationDAO notifDAO = new com.DAO.NotificationDAO();
                
                String formattedMessage = "📢 **OFFICIAL ANNOUNCEMENT:**<br>" + content;
                
                if ("ALL_SHELTERS".equals(targetShelter) && "Admin".equalsIgnoreCase(currentUser.getRole())) {
                    notifDAO.sendToRole("Manager", formattedMessage);
                    notifDAO.sendToRole("Field Officer", formattedMessage);
                    notifDAO.sendToRole("Approval Officer", formattedMessage);
                    notifDAO.sendToRole("Volunteer", formattedMessage);
                } else {
                    notifDAO.sendToShelterStaff(targetShelter, formattedMessage);
                }
                
                response.sendRedirect("Chat?success=BroadcastSent");
            } else {
                response.sendRedirect("Chat?error=EmptyMessage");
            }
        }
    }
}