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
import java.io.IOException;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
/**
 *
 * @author User
 */
@WebServlet(name = "ForgetPasswordServlet", urlPatterns = {"/ForgetPasswordServlet"})
public class ForgetPasswordServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ForgetPasswordServlet</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ForgetPasswordServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        // Check if email exists
        if (!userDAO.isEmailRegistered(email)) {
            response.sendRedirect("forgotPassword.jsp?error=notfound");
            return; 
        } else {
            // 1. Generate Code
            int verificationCode = 100000 + new Random().nextInt(900000);

            // 2. Save to Session (So we can verify it later)
            HttpSession session = request.getSession();
            session.setAttribute("verificationCode", verificationCode);
            session.setAttribute("emailForReset", email);

            // 3. SEND EMAIL (The missing part)
            String subject = "ADMS - Password Reset Code";
            String content = "Your verification code is: " + verificationCode + "\n\nIf you did not request this, please ignore this email.";

            try {
                // Call the class we created in Step 2
                // Ensure you import com.Utility.EmailUtility at the top!
                com.Utility.EmailUtility.sendEmail(email, subject, content);
                
                // 4. Redirect ONLY if email sent successfully
                response.sendRedirect("VerifyCode.jsp");
                
            } catch (Exception e) {
                e.printStackTrace();
                // If email fails, stay on page and show error
                response.sendRedirect("ForgetPassword.jsp?error=emailsendingfailed");
            }
        }
    }

    

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
