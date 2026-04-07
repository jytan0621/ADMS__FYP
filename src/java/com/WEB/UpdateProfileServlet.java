/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.UserDAO;
import com.Model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "UpdateProfileServlet", urlPatterns = {"/UpdateProfileServlet"})
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get Data
        String userId = request.getParameter("userId");
        String username = request.getParameter("username");
        String email = request.getParameter("email");

        // 2. Create User Object
        User user = new User();
        user.setUserID(userId);
        user.setUserName(username);
        user.setEmail(email);

        // 3. Call DAO (userUpdate)
        UserDAO dao = new UserDAO();
        try {
            boolean success = dao.userUpdate(user);
            
            if (success) {
                // Update the session so the new name shows up immediately in the sidebar
                HttpSession session = request.getSession();
                // We need to re-fetch full user data to keep Role/Region info in session
                User updatedUser = dao.selectUser(userId);
                session.setAttribute("currentUser", updatedUser);
                
                response.sendRedirect("UserProfile.jsp?msg=Success");
            } else {
                response.sendRedirect("EditUserProfile.jsp?error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}