/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
/*
 * Document   : ChangePasswordServlet
 * Description: Handles password update logic using the specific UserDAO methods
 */

package com.WEB;

import com.Model.User;
import com.DAO.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/ChangePasswordServlet"})
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get current session and user
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Safety check: Redirect if session expired
        if (currentUser == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Get form data
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 3. Validation: Check if New Password and Confirm Password match
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New Password and Confirm Password do not match!");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }

        // 4. Database Operations
        UserDAO userDAO = new UserDAO();
        
        try {
            // STEP A: Verify the Old Password
            User verifiedUser = userDAO.login(currentUser.getEmail(), oldPassword);
            
            if (verifiedUser != null) {
                // Old password is correct!
                
                // 🌟 STEP B: ENCRYPT THE NEW PASSWORD HERE 🌟
                String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
                
                // Update the object in memory with the ENCRYPTED password
                currentUser.setPassword(hashedNewPassword); 
                
                // Call the DAO
                boolean isUpdated = userDAO.passwordUpdate(currentUser);
                
                if (isUpdated) {
                    session.setAttribute("currentUser", currentUser);
                    request.setAttribute("message", "Password changed successfully!");
                } else {
                    request.setAttribute("error", "Database error. Failed to update password.");
                }
                
            } else {
                request.setAttribute("error", "The Current Password you entered is incorrect.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
        }

        // 5. Return to the page
        request.getRequestDispatcher("ChangePasswordForm.jsp").forward(request, response);
    }
}