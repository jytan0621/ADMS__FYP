/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author User
 */
@WebServlet(name = "VerifyCodeServlet", urlPatterns = {"/VerifyCodeServlet"})
public class VerifyCodeServlet extends HttpServlet {

    // Helper method for standard requests (not strictly needed if logic is in doGet/doPost)
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        // We usually don't print HTML here because we redirect to JSPs
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If someone tries to access this Servlet directly via URL, redirect them back
        response.sendRedirect("VerifyCode.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codeEntered = request.getParameter("code");
        HttpSession session = request.getSession();
        
        // 1. Retrieve the code stored in Session (set by ForgotPasswordServlet)
        Object storedCodeObj = session.getAttribute("verificationCode");

        // 2. Safety Check: If session expired or code is missing
        if (storedCodeObj == null) {
            // Redirect back to start because the session is lost
            response.sendRedirect("ForgetPassword.jsp?error=sessionexpired");
            return;
        }

        int storedCode = (int) storedCodeObj;

        // 3. Compare Codes
        try {
            // Check if input matches stored code
            if (Integer.parseInt(codeEntered) == storedCode) {
                // Success!
                response.sendRedirect("ResetPassword.jsp");
            } else {
                // Wrong Code
                response.sendRedirect("VerifyCode.jsp?error=invalidcode");
            }
        } catch (NumberFormatException e) {
            // User typed text instead of numbers
            response.sendRedirect("VerifyCode.jsp?error=invalidcode");
        }
    }

    @Override
    public String getServletInfo() {
        return "Verifies the OTP code entered by the user";
    }
}