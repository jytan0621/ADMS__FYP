/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/ResetPasswordServlet"})
public class ResetPasswordServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ResetPasswordServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ResetPasswordServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String newPass = request.getParameter("password");
        String confirmPass = request.getParameter("confirm");

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("emailForReset");

        if (newPass.equals(confirmPass)) {
            
            // 🌟 ENCRYPT THE NEW PASSWORD HERE BEFORE PASSING IT TO DAO 🌟
            String hashedNewPassword = BCrypt.hashpw(newPass, BCrypt.gensalt());

            // Pass the ENCRYPTED password to the DAO
            boolean updateSuccess = userDAO.updatePasswordByEmail(email, hashedNewPassword);

            if (updateSuccess) {
                session.removeAttribute("verificationCode");
                session.removeAttribute("emailForReset");
                response.sendRedirect("index.jsp?reset=success");
            } else {
                response.sendRedirect("resetPassword.jsp?error=fail");
            }

        } else {
            response.sendRedirect("resetPassword.jsp?error=mismatch");
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles resetting forgotten passwords";
    }
}