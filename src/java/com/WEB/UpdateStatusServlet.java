/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
/*
 * Document   : UpdateStatusServlet
 * Description: Safely toggles user status between Active/Inactive
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

@WebServlet(name = "UpdateStatusServlet", urlPatterns = {"/UpdateStatusServlet"})
public class UpdateStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. Get Parameters from the Link
            String userId = request.getParameter("id");
            String newStatus = request.getParameter("newStatus");

            // 2. Initialize DAO
            UserDAO userDAO = new UserDAO();

            // 3. CRITICAL STEP: Fetch existing user details first!
            // We do this because adminUpdate() overwrites Role and Region too.
            // We want to keep the existing Role/Region and only change Status.
            User existingUser = userDAO.selectUser(userId);

            if (existingUser != null) {
                // 4. Update ONLY the status in the object
                existingUser.setStatus(newStatus);

                // 5. Commit changes to Database
                userDAO.adminUpdate(existingUser);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 6. Redirect back to User List to see the change
        response.sendRedirect("userList.jsp");
    }
}