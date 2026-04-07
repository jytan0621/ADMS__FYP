/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.UserDAO;
import com.Model.User;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AddUserServlet", urlPatterns = {"/AddUserServlet"})
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. Retrieve Form Data
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String region = request.getParameter("region");

            // 2. Prepare Auto-Generated Data
            String status = "Active"; // Default status for new users
            
            // Get Current Date and Time
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String createdAt = dtf.format(LocalDateTime.now());

            // 3. Create User Object
            User newUser = new User();
            newUser.setUserName(username);
            newUser.setEmail(email);
            newUser.setPassword(password);
            newUser.setRole(role);
            newUser.setAssignedRegion(region);
            newUser.setCreatedAt(createdAt);
            newUser.setStatus(status);

            // 4. Insert into Database using DAO
            UserDAO dao = new UserDAO();
            
            // Optional: Check if email exists before inserting
            if (dao.isEmailRegistered(email)) {
                // If email exists, redirect back with error
                response.sendRedirect("UserForm.jsp?error=EmailAlreadyExists");
                return;
            }

            // Call the insert method you provided in UserDAO
            dao.insertUser(newUser);

            // 5. Redirect to User List upon success
            response.sendRedirect("UserList.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            // Redirect back with generic error
            response.sendRedirect("UserForm.jsp?error=DatabaseError");
        }
    }
}