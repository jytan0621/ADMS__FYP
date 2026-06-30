package com.WEB;

import com.DAO.BeneficiaryDAO;
import com.DAO.DistributionDAO;
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

@WebServlet(name = "ReportController", urlPatterns = {
    "/reportBeneficiary", 
    "/reportInventory", 
    "/reportDistribution",
    "/reportArchive", 
    "/reportArchiveDetail",
    "/adminReports"
})
public class ReportController extends HttpServlet {

    private BeneficiaryDAO beneficiaryDAO = new BeneficiaryDAO();
    private DistributionDAO distDAO = new DistributionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("index.jsp"); return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String role = currentUser.getRole();
        
        if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp?error=UnauthorizedAccess"); return;
        }

        String path = request.getServletPath();
        
        // --- SHARED FILTER LOGIC FOR THE 3 REPORTS ---
        String filterShelter = null;
        boolean promptSelect = false;
        
        if ("Manager".equalsIgnoreCase(role)) {
            filterShelter = request.getParameter("filterShelter");
            request.setAttribute("allShelters", new ShelterDAO().selectAllShelters());
            request.setAttribute("filterShelter", filterShelter);
            
            // If Manager hasn't submitted the form yet, prompt them to choose
            if (filterShelter == null || filterShelter.trim().isEmpty() || "null".equals(filterShelter)) {
                promptSelect = true;
            }
        } else {
            // Admin automatically gets their assigned shelter
            filterShelter = currentUser.getAssignedRegion();
        }
        
        request.setAttribute("promptSelect", promptSelect);

        switch (path) {
            case "/adminReports":
                request.getRequestDispatcher("ReportDashboard.jsp").forward(request, response);
                break;

            case "/reportBeneficiary":
                if (!promptSelect) {
                    List<com.Model.Beneficiary> allActive = beneficiaryDAO.selectActiveBeneficiaries();
                    List<com.Model.Beneficiary> filteredList = new java.util.ArrayList<>();
                    
                    for (com.Model.Beneficiary b : allActive) {
                        if (filterShelter.equals(b.getShelterID())) {
                            List<com.Model.Household> allMembers = beneficiaryDAO.selectHouseholdByBeneficiaryID(b.getBeneficiaryID());
                            List<com.Model.Household> activeMembers = new java.util.ArrayList<>();
                            for (com.Model.Household h : allMembers) {
                                if ("ADMITTED".equalsIgnoreCase(h.getH_Status())) { activeMembers.add(h); }
                            }
                            request.setAttribute("household_" + b.getBeneficiaryID(), activeMembers);
                            filteredList.add(b);
                        }
                    }
                    request.setAttribute("reportBeneficiaries", filteredList);
                }
                request.getRequestDispatcher("ReportBeneficiary.jsp").forward(request, response);
                break;

            case "/reportInventory":
                if (!promptSelect) {
                    // Uses DistributionDAO to get SHELTER-SPECIFIC allocation balance
                    List<Map<String, Object>> allocation = distDAO.getRemainingAllocationReport(filterShelter);
                    request.setAttribute("reportInventory", allocation);
                }
                request.getRequestDispatcher("ReportInventory.jsp").forward(request, response);
                break;

            case "/reportDistribution":
                String filterType = request.getParameter("filterType");
                String filterTime = request.getParameter("filterTime");
                String startDate = request.getParameter("startDate");
                String endDate = request.getParameter("endDate");
                
                if (filterType == null) filterType = "ALL";
                if (filterTime == null) filterTime = "DAILY";
                
                if (!promptSelect) {
                    List<Map<String, Object>> records = distDAO.getAdminFilteredDistributionReport(filterShelter, filterType, filterTime, startDate, endDate);
                    request.setAttribute("reportDistribution", records);
                }
                
                request.setAttribute("filterType", filterType);
                request.setAttribute("filterTime", filterTime);
                request.setAttribute("startDate", startDate);
                request.setAttribute("endDate", endDate);
                
                request.getRequestDispatcher("ReportDistribution.jsp").forward(request, response);
                break;
                
            case "/reportArchive":
                if (!"Manager".equalsIgnoreCase(role)) {
                    response.sendRedirect("index.jsp?error=UnauthorizedAccess"); return;
                }
                
                String filterArcShelter = request.getParameter("filterShelter");
                if (filterArcShelter == null) filterArcShelter = "All";
                
                request.setAttribute("allShelters", new ShelterDAO().selectAllShelters());
                request.setAttribute("filterShelter", filterArcShelter);
                request.setAttribute("startDate", request.getParameter("startDate"));
                request.setAttribute("endDate", request.getParameter("endDate"));
                
                request.setAttribute("archiveList", new ShelterDAO().getHistoricalArchive(filterArcShelter, request.getParameter("startDate"), request.getParameter("endDate")));
                request.getRequestDispatcher("ReportArchive.jsp").forward(request, response);
                break;

            case "/reportArchiveDetail":
                if (!"Manager".equalsIgnoreCase(role)) {
                    response.sendRedirect("index.jsp?error=UnauthorizedAccess"); return;
                }
                request.setAttribute("victimsList", new ShelterDAO().getHistoricalVictimsList(request.getParameter("sId"), request.getParameter("start"), request.getParameter("end")));
                request.setAttribute("arcShelterName", request.getParameter("sName"));
                request.setAttribute("arcStart", request.getParameter("start"));
                request.setAttribute("arcEnd", request.getParameter("end"));
                request.getRequestDispatcher("ReportArchiveDetail.jsp").forward(request, response);
                break;
                
            default:
                response.sendRedirect("index.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}