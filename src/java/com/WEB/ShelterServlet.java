/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.ShelterDAO;
import com.Model.Shelter;
import com.Model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ShelterServlet", urlPatterns = {
    "/listShelters", 
    "/insertShelter", 
    "/editShelter", 
    "/updateShelter", 
    "/updateShelterStatus"
})
public class ShelterServlet extends HttpServlet {
    private ShelterDAO shelterDAO;

    public void init() {
        shelterDAO = new ShelterDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. SECURITY CHECK: Only Admin or Manager allowed
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Manager".equals(currentUser.getRole()))) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getServletPath();

        try {
            switch (action) {
                case "/insertShelter":
                    insertShelter(request, response);
                    break;
                case "/editShelter":
                    showEditForm(request, response);
                    break;
                case "/updateShelter":
                    updateShelter(request, response);
                    break;
                case "/updateShelterStatus":
                    updateStatus(request, response);
                    break;
                default:
                    listShelters(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    // --- LOGIC METHODS ---

    private void listShelters(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<Shelter> listShelter = shelterDAO.selectAllShelters();
        request.setAttribute("listShelter", listShelter);
        request.getRequestDispatcher("viewShelterList.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String id = request.getParameter("id");
        Shelter existingShelter = shelterDAO.selectShelter(id);
        request.setAttribute("shelter", existingShelter);
        request.getRequestDispatcher("UpdateShelter.jsp").forward(request, response);
    }

    private void insertShelter(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String name = request.getParameter("name");
        String state = request.getParameter("state");
        // Convert Postcode to int to match address table
        int postcode = Integer.parseInt(request.getParameter("postcode"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));

        // ShelterID is null here because the DB Trigger handles SH0001
        Shelter newShelter = new Shelter(name, state, postcode, capacity, "Active");
        shelterDAO.insertShelter(newShelter);
        response.sendRedirect("listShelters");
    }

    private void updateShelter(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String state = request.getParameter("state");
        int postcode = Integer.parseInt(request.getParameter("postcode"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));

        Shelter shelter = new Shelter(id, name, state, postcode, capacity, null, 0);
        shelterDAO.updateShelter(shelter);
        response.sendRedirect("listShelters");
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String id = request.getParameter("id");
        String newStatus = request.getParameter("newStatus");
        shelterDAO.updateStatus(id, newStatus);
        response.sendRedirect("listShelters");
    }
}