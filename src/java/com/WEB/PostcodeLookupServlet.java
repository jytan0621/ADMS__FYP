/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.BeneficiaryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PostcodeLookupServlet", urlPatterns = {"/PostcodeLookupServlet"})
public class PostcodeLookupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String postcode = request.getParameter("postcode");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            BeneficiaryDAO dao = new BeneficiaryDAO();
            String[] location = dao.getCityStateByPostcode(postcode);
            
            if (location != null) {
                // Return JSON: {"found": true, "city": "Johor Bahru", "state": "Johor"}
                out.print("{\"found\": true, \"city\": \"" + location[0] + "\", \"state\": \"" + location[1] + "\"}");
            } else {
                // Return JSON: {"found": false}
                out.print("{\"found\": false}");
            }
        }
    }
}