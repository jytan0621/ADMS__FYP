package com.WEB;

import com.DAO.DistributionDAO;
import com.DAO.InventoryDAO;
import com.Model.DistributionRule;
import com.Model.InventoryItem;
import com.Model.TentTask;
import com.Model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DistributionControllerServlet", urlPatterns = {
    "/confirmOneOffDelivery", 
    "/confirmTentDelivery", 
    "/deleteRule", 
    "/AddRuleServlet", 
    "/DistributionRulesServlet", 
    "/SetVolunteerShelterServlet", 
    "/VolunteerTaskServlet",
    "/InventoryForecastServlet",
    "/DistributionHistoryServlet",
    "/AdminDailyReport"
})
public class DistributionControllerServlet extends HttpServlet {

    private DistributionDAO distDao = new DistributionDAO();
    private InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);

        boolean isGuestRoute = "/SetVolunteerShelterServlet".equals(path);
        if (!isGuestRoute && (session == null || session.getAttribute("currentUser") == null)) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String myShelterID = (session != null) ? (String) session.getAttribute("myShelterID") : null;
        if (myShelterID == null && session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            myShelterID = user.getAssignedRegion();
        }

        if ("/VolunteerTaskServlet".equals(path)) {
            if (session.getAttribute("myShelterID") == null) {
                response.sendRedirect("index.jsp?error=NoShelterSession");
                return;
            }
            
            Map<String, TentTask> dailyTasks = distDao.getAutomatedTasks(myShelterID);
            Map<String, TentTask> completedTasks = distDao.getCompletedTasks(myShelterID);
            Set<String> completedDaily = distDao.getCompletedDailyTentsToday();

            request.setAttribute("dailyTasks", dailyTasks);
            request.setAttribute("completedTasks", completedTasks);
            request.setAttribute("completedDaily", completedDaily);
            
            request.getRequestDispatcher("volunteerTasks.jsp").forward(request, response);
        } 
        else if ("/DistributionRulesServlet".equals(path)) {
            List<DistributionRule> currentRules = distDao.getAllRules();
            request.setAttribute("currentRules", currentRules);

            try {
                List<InventoryItem> items = inventoryDAO.selectAllItems(myShelterID); 
                request.setAttribute("inventoryItems", items);
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            request.getRequestDispatcher("setAidRules.jsp").forward(request, response);
        } 
        else if ("/SetVolunteerShelterServlet".equals(path)) {
            response.sendRedirect("selectShelter.jsp");
        } 
        else if ("/InventoryForecastServlet".equals(path)) {
            User user = (User) session.getAttribute("currentUser");
            if (!"Field Officer".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("VolunteerTaskServlet?error=UnauthorizedAccess");
                return;
            }
            if (myShelterID == null || myShelterID.trim().isEmpty()) {
                response.sendRedirect("index.jsp?error=NoShelterBound");
                return;
            }

            List<Map<String, Object>> flowReport = distDao.getRemainingAllocationReport(myShelterID);
            request.setAttribute("flowReport", flowReport);
            request.getRequestDispatcher("InventoryForecast.jsp").forward(request, response);
        }
        else if ("/DistributionHistoryServlet".equals(path)) {
            if (myShelterID == null || myShelterID.trim().isEmpty()) {
                response.sendRedirect("index.jsp?error=NoShelterBound");
                return;
            }
            
            String filterType = request.getParameter("filterType");
            String filterTime = request.getParameter("filterTime");
            
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            if (filterType == null) filterType = "ALL";
            if (filterTime == null) filterTime = "DAILY";
            
            List<Map<String, Object>> historyList = distDao.getFieldOfficerFilteredHistory(myShelterID, filterType, filterTime, startDate, endDate);
            
            request.setAttribute("filterType", filterType);
            request.setAttribute("filterTime", filterTime);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("historyList", historyList);

            request.getRequestDispatcher("DistributionHistory.jsp").forward(request, response);
        }
        
        else if ("/AdminDailyReport".equals(path)) {
            User user = (User) session.getAttribute("currentUser");
            if (!"Admin".equalsIgnoreCase(user.getRole()) && !"Manager".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("index.jsp?error=UnauthorizedAccess");
                return;
            }
            
            String targetShelter = (myShelterID != null && !myShelterID.trim().isEmpty()) ? myShelterID : "All Regions";
            
            List<Map<String, Object>> dailyReport = distDao.getDailyItemDistributionReport(targetShelter);
            request.setAttribute("dailyReport", dailyReport);
            
            request.getRequestDispatcher("AdminDailyReport.jsp").forward(request, response);
        }
        else {
            doGet(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        
        boolean isGuestRoute = "/SetVolunteerShelterServlet".equals(path);
        if (!isGuestRoute && (session == null || session.getAttribute("currentUser") == null)) {
            response.sendRedirect("index.jsp");
            return;
        }

        String myShelterID = (session != null) ? (String) session.getAttribute("myShelterID") : null;
        if (myShelterID == null && session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            myShelterID = user.getAssignedRegion();
        }
        String tentID = request.getParameter("tentID");

        if ("/confirmOneOffDelivery".equals(path) || "/confirmTentDelivery".equals(path)) {
            if (tentID != null && !tentID.trim().isEmpty()) {
                Map<String, TentTask> dailyTasks = distDao.getAutomatedTasks(myShelterID);
                TentTask currentTentTask = dailyTasks.get(tentID);
                
                if (currentTentTask != null) {
                    boolean success;
                    if ("/confirmTentDelivery".equals(path)) {
                        success = distDao.logTentDeliveryWithFlow(tentID, myShelterID, currentTentTask.getDailyItems());
                    } else {
                        success = distDao.logOneOffDeliveryWithFlow(tentID, myShelterID, currentTentTask.getEntryItems());
                    }
                    
                    if (success) {
                        response.sendRedirect("VolunteerTaskServlet?success=true");
                    } else {
                        response.sendRedirect("VolunteerTaskServlet?error=InsufficientFlowStock");
                    }
                } else {
                    response.sendRedirect("VolunteerTaskServlet?error=missingData");
                }
            } else {
                response.sendRedirect("VolunteerTaskServlet?error=missingData");
            }
        }
        else if ("/AddRuleServlet".equals(path)) {
            String[] itemIDs = request.getParameterValues("itemID[]");
            String[] qtys = request.getParameterValues("qty[]");
            String[] distTypes = request.getParameterValues("distType[]");
            
            if (itemIDs != null && qtys != null && distTypes != null) {
                boolean allSuccess = true;
                for (int i = 0; i < itemIDs.length; i++) {
                    if (!distDao.addRule(itemIDs[i], Integer.parseInt(qtys[i]), distTypes[i])) {
                        allSuccess = false;
                    }
                }
                
                if (allSuccess) {
                    response.sendRedirect("DistributionRulesServlet?success=true");
                } else {
                    response.sendRedirect("DistributionRulesServlet?error=true");
                }
            } else {
                response.sendRedirect("DistributionRulesServlet?error=MissingFormArrays");
            }
        }
        else if ("/deleteRule".equals(path)) {
            String ruleID = request.getParameter("ruleID");
            
            if (ruleID != null && !ruleID.trim().isEmpty()) {
                if (distDao.deleteRule(ruleID)) {
                    response.sendRedirect("DistributionRulesServlet?deleted=true");
                } else {
                    response.sendRedirect("DistributionRulesServlet?error=DeleteFailed");
                }
            } else {
                response.sendRedirect("DistributionRulesServlet?error=MissingID");
            }
        }
        else if ("/SetVolunteerShelterServlet".equals(path)) {
            String shelterID = request.getParameter("shelterID");
            
            if (shelterID != null && !shelterID.trim().isEmpty()) {
                session = request.getSession(true); 
                session.setAttribute("myShelterID", shelterID);
                
                if (session.getAttribute("currentUser") == null) {
                    session.setAttribute("currentUser", new User("U0012", "Guest Volunteer", "volunteer@adms.com", 
                            "none", "Volunteer", shelterID, "", "Active"));
                }
                response.sendRedirect("VolunteerTaskServlet");
            } else {
                response.sendRedirect("selectShelter.jsp?error=PleaseSelectShelter");
            }
        }
    }
}