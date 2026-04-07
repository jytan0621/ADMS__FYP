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

@WebServlet(name = "UpdateAdminServlet", urlPatterns = {"/UpdateAdminServlet"})
public class UpdateAdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get Data
        String userId = request.getParameter("userId");
        String role = request.getParameter("role");
        String region = request.getParameter("region");
        String status = request.getParameter("status");

        // 2. Create User Object
        User user = new User();
        user.setUserID(userId);
        user.setRole(role);
        user.setAssignedRegion(region);
        user.setStatus(status);

        // 3. Call DAO (adminUpdate)
        UserDAO dao = new UserDAO();
        try {
            boolean success = dao.adminUpdate(user);
            
            if (success) {
                response.sendRedirect("UserList.jsp");
            } else {
                response.sendRedirect("EditAdminForm.jsp?id=" + userId + "&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}