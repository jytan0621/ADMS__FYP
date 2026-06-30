package com.WEB;

import com.DAO.DashboardDAO;
import com.DAO.ShelterDAO;
import com.Model.User;
import java.io.IOException;
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

        String shelterName = dao.getShelterNameByID(user.getAssignedRegion());
        request.setAttribute("shelterName", shelterName);
        
        String role = user.getRole().toLowerCase().trim();

        // 1. Common Stats
        Map<String, Integer> stats = dao.getSystemStats(); 
        request.setAttribute("totalBen", stats.get("totalBeneficiaries"));
        request.setAttribute("pendingReq", stats.get("pendingRequests"));
        request.setAttribute("lowStock", stats.get("lowStockItems"));
        request.setAttribute("activeSheltersCount", stats.get("activeShelters")); 
        
        // UPDATED: Pass the UserID to fetch personalized Broadcast Alerts!
        request.setAttribute("announcements", dao.getLatestAnnouncements(user.getUserID()));

        // 2. Trend Dropdown Filter Logic
        String trendFilter = request.getParameter("trendShelter");
        if(trendFilter == null || trendFilter.isEmpty()) trendFilter = "All";
        request.setAttribute("selectedTrendShelter", trendFilter);

        // 3. Role Specific Logic
        if (role.equals("approval officer")) {
            // Approval Officer Personal Stats
            List<Integer> officerStats = dao.getOfficerPersonalStats(user.getUserID());
            request.setAttribute("myApproved", officerStats.get(0));
            request.setAttribute("myRejected", officerStats.get(1));
            request.setAttribute("globalQueue", officerStats.get(2)); 
            request.setAttribute("myTotalProcessed", officerStats.get(0) + officerStats.get(1));
            
            // Restock Stats
            List<Integer> restock = dao.getRestockStatusCounts();
            request.setAttribute("restockApproved", restock.get(0));
            request.setAttribute("restockPending", restock.get(1));
            request.setAttribute("restockRejected", restock.get(2));

            request.setAttribute("globalPendingList", dao.getGlobalPendingList());
            setInventoryData(request);
            setAllItemsData(request);

        } else if (role.equals("field officer")) {
            setTrendChartData(request, trendFilter); 
            request.setAttribute("allShelters", new ShelterDAO().selectAllShelters());

            Map<String, Integer> statusCounts = dao.getBeneficiaryStatusCounts();
            request.setAttribute("activeBenCount", statusCounts.get("active"));
            request.setAttribute("inactiveBenCount", statusCounts.get("inactive"));
            
            Map<String, Integer> myStats = dao.getUserRequestStats(user.getUserID());
            request.setAttribute("myTotalReq", myStats.get("myTotal"));
            request.setAttribute("myPendingReq", myStats.get("myPending"));
            
            request.setAttribute("myPendingList", dao.getFieldOfficerPendingList(user.getUserID()));
            
        } else if (role.equals("logistic staff")) {
            setInventoryData(request); 
            setAllItemsData(request); 
            
        } else if (role.equals("manager")) {
            // HQ MANAGER DATA
            setTrendChartData(request, trendFilter);
            request.setAttribute("activeSheltersSummary", dao.getActiveSheltersSummary());
            request.setAttribute("allShelters", new ShelterDAO().selectAllShelters());
            
            // Manager sees GLOBAL Stats, not personal stats!
            List<Integer> globalStats = dao.getGlobalApprovalStats();
            request.setAttribute("myApproved", globalStats.get(0));
            request.setAttribute("myRejected", globalStats.get(1));
            request.setAttribute("globalQueue", globalStats.get(2)); 
            request.setAttribute("myTotalProcessed", globalStats.get(0) + globalStats.get(1));
            
            // Restock Charts Data
            List<Integer> restock = dao.getRestockStatusCounts();
            request.setAttribute("restockApproved", restock.get(0));
            request.setAttribute("restockPending", restock.get(1));
            request.setAttribute("restockRejected", restock.get(2));
            
        } else {
            // ADMIN DATA
            setTrendChartData(request, trendFilter);
            request.setAttribute("allShelters", new ShelterDAO().selectAllShelters());
            
            Map<String, Integer> statusCounts = dao.getBeneficiaryStatusCounts();
            request.setAttribute("activeBenCount", statusCounts.get("active"));
            request.setAttribute("inactiveBenCount", statusCounts.get("inactive"));

            request.setAttribute("globalPendingList", dao.getGlobalPendingList());

            setInventoryData(request);
            setAllItemsData(request);
        }

        request.getRequestDispatcher("Dashboard.jsp").forward(request, response);
    }
    
    // --- HELPERS ---
    private void setTrendChartData(HttpServletRequest request, String filterID) {
        Map<String, List<Object>> trendData = dao.getDailyRegistrationTrend(filterID);
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