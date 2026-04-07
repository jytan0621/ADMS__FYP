/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.DashboardDAO;
import com.Model.AidRequest;
import com.Model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/DashboardServlet"})
public class DashboardServlet extends HttpServlet {

    private DashboardDAO dao = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser"); 
        if (user == null) { response.sendRedirect("index.jsp"); return; }

        String role = user.getRole().toLowerCase().trim();

        // 1. Common Stats
        Map<String, Integer> stats = dao.getSystemStats(); 
        request.setAttribute("totalBen", stats.get("totalBeneficiaries"));
        request.setAttribute("pendingReq", stats.get("pendingRequests"));
        request.setAttribute("lowStock", stats.get("lowStockItems"));
        
        // 2. Announcements (For ALL Roles)
        request.setAttribute("announcements", dao.getLatestAnnouncements());

        // 3. Role Specific Logic
        if (role.equals("approval officer")) {
            // Approval Data
            List<Integer> officerStats = dao.getOfficerPersonalStats(user.getUserID());
            request.setAttribute("myApproved", officerStats.get(0));
            request.setAttribute("myRejected", officerStats.get(1));
            request.setAttribute("globalQueue", officerStats.get(2)); 
            request.setAttribute("myTotalProcessed", officerStats.get(0) + officerStats.get(1));
            
            List<Integer> restock = dao.getRestockStatusCounts();
            request.setAttribute("restockApproved", restock.get(0));
            request.setAttribute("restockPending", restock.get(1));
            request.setAttribute("restockRejected", restock.get(2));

            // Global Queue List
            request.setAttribute("globalPendingList", dao.getGlobalPendingList());

            // Inventory
            setInventoryData(request);
            setAllItemsData(request);

        } else if (role.equals("field officer")) {
            // Field Data
            setTrendChartData(request); 

            Map<String, Integer> statusCounts = dao.getBeneficiaryStatusCounts();
            request.setAttribute("activeBenCount", statusCounts.get("active"));
            request.setAttribute("inactiveBenCount", statusCounts.get("inactive"));
            
            Map<String, Integer> myStats = dao.getUserRequestStats(user.getUserID());
            request.setAttribute("myTotalReq", myStats.get("myTotal"));
            request.setAttribute("myPendingReq", myStats.get("myPending"));
            
            request.setAttribute("myPendingList", dao.getFieldOfficerPendingList(user.getUserID()));
            
        } else if (role.equals("logistic staff")) {
            // Logistic Data
            setInventoryData(request); 
            setAllItemsData(request); 
            
        } else {
            // Admin Data
            setTrendChartData(request);
            
            Map<String, Integer> statusCounts = dao.getBeneficiaryStatusCounts();
            request.setAttribute("activeBenCount", statusCounts.get("active"));
            request.setAttribute("inactiveBenCount", statusCounts.get("inactive"));

            request.setAttribute("globalPendingList", dao.getGlobalPendingList());

            setInventoryData(request);
            setAllItemsData(request);
        }

        request.getRequestDispatcher("Dashboard.jsp").forward(request, response);
    }
    
    // --- HELPERS (No JSON) ---

    private void setTrendChartData(HttpServletRequest request) {
        Map<String, List<Object>> trendData = dao.getDailyRegistrationTrend();
        request.setAttribute("trendLabelsList", trendData.get("labels"));
        request.setAttribute("trendDataList", trendData.get("data"));
    }

    private void setInventoryData(HttpServletRequest request) {
        Map<String, List<Object>> invData = dao.getInventoryLevels();
        request.setAttribute("invLabelsList", invData.get("labels"));
        request.setAttribute("invDataList", invData.get("data"));
    }

    private void setAllItemsData(HttpServletRequest request) {
        Map<String, List<Object>> allItems = dao.getAllInventoryItems();
        request.setAttribute("allItemsNames", allItems.get("names"));
        request.setAttribute("allItemsQty", allItems.get("quantities"));
    }
}