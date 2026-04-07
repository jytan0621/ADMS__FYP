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

/**
 *
 * @author User
 */
@WebServlet(name = "MainMenu", urlPatterns = {"/MainMenuServlet"})
public class MainMenuServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String menu = request.getParameter("menu");
        request.getSession().setAttribute("activeMenu", menu);

        switch (menu) {
            case "home":
                response.sendRedirect("DashboardServlet");
                break;
            case "beneficiary":
                response.sendRedirect("BeneficiaryAnalysis");
                break;
            case "inventory":
                response.sendRedirect("inventoryMain.jsp");
                break;
            case "aid":
                response.sendRedirect("listRequest");
                break;
            case "report":
                response.sendRedirect("report.jsp");
                break;
            case "message":
                response.sendRedirect("inbox.jsp");
                break;
            case "shelter":
                response.sendRedirect("listShelters");
                break;
            // ==========================================

            default:
                response.sendRedirect("dashboard.jsp");
                break;
            
        }
    }
}
