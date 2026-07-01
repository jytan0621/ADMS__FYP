package com.WEB;

import com.DAO.BeneficiaryDAO;
import com.DAO.ShelterDAO;          // CRITICAL: Ensure this is imported
import com.Model.Beneficiary;
import com.Model.Household;
import com.Model.Shelter;           // CRITICAL: Ensure this is imported
import com.Model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "BeneficiaryServlet", urlPatterns = {
    "/BeneficiaryServlet",
    "/listBeneficiary",
    "/newBeneficiary",
    "/insertBeneficiary",
    "/viewBeneficiary",
    "/searchBeneficiary",
    "/editBeneficiary",
    "/updateBeneficiary",
    "/updateStatus",
    "/deleteBeneficiary",
    "/addHousehold",
    "/insertHousehold",
    "/editHousehold",
    "/updateHousehold",
    "/deleteHousehold",
    "/viewHousehold",  
    "/publicInsertBeneficiary",
    "/publicCheckoutAction",
    "/publicAddHouseholdToSession",
    "/publicRemoveHouseholdFromSession",
    "/addHouseholdToSession",
    "/removeHouseholdFromSession",
    "/insertHouseholdReturnToEdit",
    "/showPublicRegister"
})
public class BeneficiaryServlet extends HttpServlet {
    
    private BeneficiaryDAO beneficiaryDAO;

    @Override
    public void init() {
        beneficiaryDAO = new BeneficiaryDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet BeneficiaryServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet BeneficiaryServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();

        try {
            switch (action) {
                case "/newBeneficiary":
                    showNewForm(request, response);
                    break;
                case "/insertBeneficiary":
                    insertBeneficiary(request, response);
                    break;
                case "/viewBeneficiary":
                    viewBeneficiary(request, response);
                    break;
                case "/searchBeneficiary":
                    searchBeneficiary(request, response);
                    break;
                case "/editBeneficiary":
                    showEditForm(request, response);
                    break;
                case "/updateBeneficiary":
                    updateBeneficiary(request, response);
                    break;
                case "/updateStatus": 
                    updateBeneficiaryStatus(request, response); 
                    break;    
                case "/deleteBeneficiary": 
                    deleteBeneficiary(request, response);
                    break; 
                 case "/publicInsertBeneficiary":
                    publicInsertBeneficiary(request, response);
                    break;
                case "/publicCheckoutAction":
                    publicCheckoutAction(request, response);
                    break;
                case "/addHousehold":
                    showNewHouseholdForm(request, response);
                    break;
                case "/insertHousehold":
                    insertHousehold(request, response);
                    break;
                case "/editHousehold":
                    showEditHouseholdForm(request, response);
                    break;
                case "/viewHousehold":
                    viewHousehold(request, response);
                    break;
                case "/updateHousehold":
                    updateHousehold(request, response);
                    break;
                case "/deleteHousehold":
                    deleteHousehold(request, response);
                    break;
                case "/publicAddHouseholdToSession":
                    publicAddHouseholdToSession(request, response);
                    break;    
                case "/addHouseholdToSession":
                    addHouseholdToSession(request, response);
                    break;
                case "/removeHouseholdFromSession":
                    removeHouseholdFromSession(request, response);
                    break;
                case "/insertHouseholdReturnToEdit":
                    insertHouseholdReturnToEdit(request, response);
                    break;
               case "/publicRemoveHouseholdFromSession":
                    publicRemoveHouseholdFromSession(request, response);
                    break;
                case "/showPublicRegister":
                    showPublicNewBeneficiary(request, response);
                    break;
                default:
                    listBeneficiary(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ================= REGISTRATION (STAFF & PUBLIC) =================

    private void insertBeneficiary(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Since the database now stores the ShelterID directly in AssignedRegion!
        String shelterID = currentUser.getAssignedRegion(); 

        if (shelterID == null || shelterID.trim().isEmpty()) {
            response.sendRedirect("newBeneficiary?error=NoShelterFoundForRegion");
            return;
        }
        
        processRegistration(request, response, shelterID, "Staff");
    }
    
    private void publicInsertBeneficiary(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        // UPDATED: Now receives the ShelterID directly from the dropdown list
        String shelterID = request.getParameter("ShelterID");

        if (shelterID == null || shelterID.trim().isEmpty()) { 
            response.sendRedirect("publicNewBeneficiary.jsp?error=InvalidShelterSelection"); 
            return; 
        }

        processRegistration(request, response, shelterID, "Public");
    }

    private void processRegistration(HttpServletRequest request, HttpServletResponse response, String shelterID, String type) throws SQLException, IOException {
        String icNumber = request.getParameter("B_ICNumber");
        HttpSession session = request.getSession();
        List<Household> tempM = (List<Household>) session.getAttribute("tempHouseholdList");
        int totalSize = 1 + (tempM != null ? tempM.size() : 0);

        if (beneficiaryDAO.isICAlreadyActive(icNumber)) {
            response.sendRedirect(type.equals("Staff") ? "newBeneficiary?error=AlreadyRegistered" : "publicNewBeneficiary.jsp?error=AlreadyRegistered");
            return; 
        }

        int tentsNeeded = (int) Math.ceil(totalSize / 4.0);
        List<String> assignedTents = beneficiaryDAO.getAvailableTents(shelterID, tentsNeeded);
        if (assignedTents.size() < tentsNeeded) {
            response.sendRedirect(type.equals("Staff") ? "newBeneficiary?error=ShelterFull" : "publicNewBeneficiary.jsp?error=ShelterFull");
            return;
        }

        Beneficiary existing = beneficiaryDAO.selectBeneficiaryByIC(icNumber);
        String status = type.equals("Staff") ? request.getParameter("B_Status") : ("Approved".equalsIgnoreCase(request.getParameter("registration_status")) ? "Active" : "Pending");

        if (existing != null && "Inactive".equalsIgnoreCase(existing.getB_Status())) {
            existing.setB_Status(status); 
            existing.setTentID(assignedTents.get(0));
            existing.setShelterID(shelterID); 
            existing.setHouseholdSize(totalSize);
            beneficiaryDAO.updateBeneficiary(existing);
            beneficiaryDAO.incrementTentOccupancy(assignedTents.get(0));
            
            if (tempM != null) {
                for (int i = 0; i < tempM.size(); i++) {
                    Household m = tempM.get(i); 
                    String tid = assignedTents.get((i + 1) / 4);
                    m.setBeneficiaryID(existing.getBeneficiaryID()); 
                    m.setTentID(tid); 
                    m.setH_Status(type.equals("Staff") ? "ADMITTED" : "PENDING");
                    beneficiaryDAO.insertHouseholdMember(m); 
                    beneficiaryDAO.incrementTentOccupancy(tid);
                }
            }
        } else {
            Beneficiary b = new Beneficiary();
            b.setB_Name(request.getParameter("B_Name")); 
            b.setB_ICNumber(icNumber);
            b.setB_Race(request.getParameter("B_Race")); 
            b.setB_Religion(request.getParameter("B_Religion"));
            
            String isMalaysian = request.getParameter("B_IsMalaysian");
            String country = request.getParameter("B_Nationality");
            b.setB_Nationality("Malaysian".equals(isMalaysian) ? "Malaysian" : country);
            
            b.setB_ContactNumber(request.getParameter("B_ContactNumber"));
            b.setHouseholdSize(totalSize); 
            b.setStreet(request.getParameter("Street"));
            
            try { b.setPostcode(Integer.parseInt(request.getParameter("Postcode"))); } catch(Exception e) { b.setPostcode(0); }
            
            b.setB_OKUStatus(request.getParameter("B_OKUStatus")); 
            b.setB_DietPreference(request.getParameter("B_DietPreference"));
            b.setB_HealthHistory(request.getParameter("B_HealthHistory")); 
            b.setB_Allergic(request.getParameter("B_Allergic")); 
            b.setB_Status(status);
            b.setRegisteredBy(type.equals("Staff") ? ((User)session.getAttribute("currentUser")).getUserID() : "U0008");
            b.setShelterID(shelterID); 
            b.setTentID(assignedTents.get(0));

            beneficiaryDAO.insertBeneficiary(b);
            beneficiaryDAO.incrementTentOccupancy(assignedTents.get(0));
            
            Beneficiary saved = beneficiaryDAO.selectBeneficiaryByIC(icNumber);
            if (tempM != null) {
                for (int i = 0; i < tempM.size(); i++) {
                    Household m = tempM.get(i); 
                    String tid = assignedTents.get((i + 1) / 4);
                    m.setBeneficiaryID(saved.getBeneficiaryID()); 
                    m.setTentID(tid);
                    m.setH_Status(type.equals("Staff") ? "ADMITTED" : "PENDING");
                    beneficiaryDAO.insertHouseholdMember(m); 
                    beneficiaryDAO.incrementTentOccupancy(tid);
                }
            }
        }
        session.removeAttribute("tempHouseholdList");
        response.sendRedirect(type.equals("Staff") ? "listBeneficiary" : "registrationSuccess.jsp");
    }

    private void updateBeneficiaryStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String id = request.getParameter("id");
        String newStatus = request.getParameter("status");

        if ("Inactive".equalsIgnoreCase(newStatus)) {
            beneficiaryDAO.checkoutFamily(id);
        } else if ("Active".equalsIgnoreCase(newStatus)) {
            Beneficiary b = beneficiaryDAO.selectBeneficiaryByID(id);
            List<Household> members = beneficiaryDAO.selectHouseholdByBeneficiaryID(id);
            int total = 1 + members.size();
            int needed = (int) Math.ceil(total / 4.0);
            List<String> tents = beneficiaryDAO.getAvailableTents(b.getShelterID(), needed);

            if (tents.size() >= needed) {
                b.setB_Status("Active"); 
                b.setTentID(tents.get(0));
                beneficiaryDAO.updateBeneficiary(b);
                beneficiaryDAO.incrementTentOccupancy(tents.get(0));
                for (int i = 0; i < members.size(); i++) {
                    Household m = members.get(i); 
                    String tid = tents.get((i + 1) / 4);
                    m.setH_Status("ADMITTED"); 
                    m.setTentID(tid);
                    beneficiaryDAO.updateHouseholdMember(m);
                    beneficiaryDAO.incrementTentOccupancy(tid);
                }
            } else {
                response.sendRedirect("listBeneficiary?error=NoTentsAvailable");
                return;
            }
        } else {
            beneficiaryDAO.updateBeneficiaryStatus(id, newStatus);
        }

        String referrer = request.getHeader("referer"); 
        if(referrer != null && referrer.contains("viewBeneficiary")) {
             response.sendRedirect("viewBeneficiary?id=" + id);
        } else {
             response.sendRedirect("listBeneficiary");
        }
    }

    // =========================================================================
    //                            BENEFICIARY METHODS
    // =========================================================================

    private void listBeneficiary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        session.removeAttribute("tempHouseholdList");

        List<Beneficiary> listBeneficiary;
        
        String statusFilter = request.getParameter("statusFilter");

        if (statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter)) {
            listBeneficiary = beneficiaryDAO.selectBeneficiariesByStatus(statusFilter);
        } else {
            listBeneficiary = beneficiaryDAO.selectAllBeneficiaries();
        }

        request.setAttribute("listBeneficiary", listBeneficiary);
        RequestDispatcher dispatcher = request.getRequestDispatcher("BeneficiaryList.jsp");
        dispatcher.forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("NewBeneficiary.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String id = request.getParameter("id");
        Beneficiary existingBeneficiary = beneficiaryDAO.selectBeneficiaryByID(id);
        List<Household> householdList = beneficiaryDAO.selectHouseholdByBeneficiaryID(id);

        request.setAttribute("beneficiary", existingBeneficiary);
        request.setAttribute("householdList", householdList);

        RequestDispatcher dispatcher = request.getRequestDispatcher("EditBeneficiaryForm.jsp");
        dispatcher.forward(request, response);
    }

    private void updateBeneficiary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String id = request.getParameter("id");
        String name = request.getParameter("B_Name");
        String icNumber = request.getParameter("B_ICNumber");
        String race = request.getParameter("B_Race");
        String religion = request.getParameter("B_Religion");
        String nationality = request.getParameter("B_Nationality");
        String contactNumber = request.getParameter("B_ContactNumber");
        
        int householdSize = Integer.parseInt(request.getParameter("HouseholdSize")); 
        
        String street = request.getParameter("Street");
        int postcode = Integer.parseInt(request.getParameter("Postcode"));
        
        String okuStatus = request.getParameter("B_OKUStatus");
        String dietPreference = request.getParameter("B_DietPreference");
        String healthHistory = request.getParameter("B_HealthHistory");
        String allergic = request.getParameter("B_Allergic");
        String status = request.getParameter("B_Status");
        
        String shelterID = request.getParameter("ShelterID");
        String tentID = request.getParameter("TentID");

        Beneficiary beneficiary = new Beneficiary();
        beneficiary.setBeneficiaryID(id);
        beneficiary.setB_Name(name);
        beneficiary.setB_ICNumber(icNumber);
        beneficiary.setB_Race(race);
        beneficiary.setB_Religion(religion);
        beneficiary.setB_Nationality(nationality);
        beneficiary.setB_ContactNumber(contactNumber);
        beneficiary.setHouseholdSize(householdSize);
        beneficiary.setStreet(street);
        beneficiary.setPostcode(postcode);
        beneficiary.setB_OKUStatus(okuStatus);
        beneficiary.setB_DietPreference(dietPreference);
        beneficiary.setB_HealthHistory(healthHistory);
        beneficiary.setB_Allergic(allergic);
        beneficiary.setB_Status(status);
        beneficiary.setShelterID(shelterID);
        beneficiary.setTentID(tentID);

        beneficiaryDAO.updateBeneficiary(beneficiary);
        response.sendRedirect("listBeneficiary");
    }

    private void searchBeneficiary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String inputIC = request.getParameter("searchIC");
        String cleanIC = "";

        if(inputIC != null) {
            cleanIC = inputIC.replace("-", "").replace(" ", "").trim();
        }
        
        Beneficiary result = beneficiaryDAO.searchByIC(cleanIC);
        List<Beneficiary> searchResults = new ArrayList<>();
        
        if (result != null) {
            searchResults.add(result);
            request.setAttribute("listBeneficiary", searchResults);
            RequestDispatcher dispatcher = request.getRequestDispatcher("BeneficiaryList.jsp");
            dispatcher.forward(request, response);
        } else {
            String msg = "No record found for IC: " + inputIC;
            response.sendRedirect("listBeneficiary?error=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        }
    }
    
    private void viewBeneficiary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        Beneficiary beneficiary = beneficiaryDAO.selectBeneficiaryByID(id);
        List<Household> householdList = beneficiaryDAO.selectHouseholdByBeneficiaryID(id);
        
        request.setAttribute("beneficiary", beneficiary);
        request.setAttribute("householdList", householdList);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("ViewBeneficiary.jsp");
        dispatcher.forward(request, response);
    }

    private void deleteBeneficiary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        if(id != null) {
            beneficiaryDAO.deleteBeneficiary(id);
        }
        response.sendRedirect("listBeneficiary");
    }

    // =========================================================================
    //                            DATABASE HOUSEHOLD METHODS
    // =========================================================================

    private void showNewHouseholdForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String beneficiaryId = request.getParameter("beneficiaryId");
        request.setAttribute("beneficiaryId", beneficiaryId);
        RequestDispatcher dispatcher = request.getRequestDispatcher("HouseholdForm.jsp");
        dispatcher.forward(request, response);
    }

    private void insertHousehold(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        // Logic handled by insertHouseholdReturnToEdit usually
    }

    private void showEditHouseholdForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String householdId = request.getParameter("householdId");
        Household existingHousehold = beneficiaryDAO.selectHouseholdByID(householdId);
        request.setAttribute("household", existingHousehold);
        RequestDispatcher dispatcher = request.getRequestDispatcher("EditHouseholdForm.jsp");
        dispatcher.forward(request, response);
    }

    private void updateHousehold(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String householdId = request.getParameter("householdId");
        String beneficiaryId = request.getParameter("beneficiaryId"); 
        
        String name = request.getParameter("name");
        String icNumber = request.getParameter("icNumber");
        String relationship = request.getParameter("relationship");
        String okuStatus = request.getParameter("okuStatus");
        String healthHistory = request.getParameter("healthHistory");
        String allergic = request.getParameter("allergic");
        String dietPreference = request.getParameter("dietPreference");
        String status = request.getParameter("status");
        String tentID = request.getParameter("TentID");

        Household household = new Household();
        household.setHouseholdID(householdId);
        household.setH_Name(name);
        household.setH_IC(icNumber);
        household.setH_Relationship(relationship);
        household.setH_OKUStatus(okuStatus);
        household.setH_HealthHistory(healthHistory);
        household.setH_Allergic(allergic);
        household.setH_DietPreference(dietPreference);
        household.setH_Status(status);
        household.setTentID(tentID);

        beneficiaryDAO.updateHouseholdMember(household);
        response.sendRedirect("viewBeneficiary?id=" + beneficiaryId);
    }

    private void deleteHousehold(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String householdId = request.getParameter("householdId");
        String beneficiaryId = request.getParameter("beneficiaryId"); 
        
        beneficiaryDAO.deleteHouseholdMember(householdId);
        
        List<Household> remainingList = beneficiaryDAO.selectHouseholdByBeneficiaryID(beneficiaryId);
        Beneficiary b = beneficiaryDAO.selectBeneficiaryByID(beneficiaryId);
        int newSize = 1 + remainingList.size();
        b.setHouseholdSize(newSize);
        beneficiaryDAO.updateBeneficiary(b);
        
        String referer = request.getHeader("referer");
        if (referer != null && referer.contains("editBeneficiary")) {
            response.sendRedirect("editBeneficiary?id=" + beneficiaryId);
        } else {
            response.sendRedirect("viewBeneficiary?id=" + beneficiaryId);
        }
    }
    
    private void viewHousehold(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
            String householdId = request.getParameter("householdId");
            Household h = beneficiaryDAO.selectHouseholdByID(householdId);
            request.setAttribute("household", h);
            RequestDispatcher dispatcher = request.getRequestDispatcher("ViewHousehold.jsp");
            dispatcher.forward(request, response);
    }

    // =========================================================================
    //                  SESSION HOUSEHOLD METHODS
    // =========================================================================

    private void addHouseholdToSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("hName");
        String ic = request.getParameter("hIC");
        String rel = request.getParameter("hRelationship");
        String oku = request.getParameter("hOku");
        String health = request.getParameter("hHealthHistory");
        String allergic = request.getParameter("hAllergic");
        String diet = request.getParameter("hDietPreference");
        String status = request.getParameter("hStatus");

        Household member = new Household();
        member.setH_Name(name);
        member.setH_IC(ic);
        member.setH_Relationship(rel);
        member.setH_OKUStatus(oku);
        member.setH_HealthHistory(health);
        member.setH_Allergic(allergic);
        member.setH_DietPreference(diet);
        member.setH_Status(status);

        HttpSession session = request.getSession();
        List<Household> tempHouseholdList = (List<Household>) session.getAttribute("tempHouseholdList");

        if (tempHouseholdList == null) {
            tempHouseholdList = new ArrayList<>();
        }

        tempHouseholdList.add(member);
        session.setAttribute("tempHouseholdList", tempHouseholdList);
        response.sendRedirect("NewBeneficiary.jsp");
    }

    private void removeHouseholdFromSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String indexStr = request.getParameter("index");
        if(indexStr != null) {
            int index = Integer.parseInt(indexStr);
            HttpSession session = request.getSession();
            List<Household> tempHouseholdList = (List<Household>) session.getAttribute("tempHouseholdList");

            if (tempHouseholdList != null && index >= 0 && index < tempHouseholdList.size()) {
                tempHouseholdList.remove(index);
                session.setAttribute("tempHouseholdList", tempHouseholdList);
            }
        }
        response.sendRedirect("NewBeneficiary.jsp");
    }

    private void insertHouseholdReturnToEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String beneficiaryId = request.getParameter("beneficiaryId"); 
        String name = request.getParameter("hName");
        String ic = request.getParameter("hIC");
        String rel = request.getParameter("hRelationship");
        String oku = request.getParameter("hOku");
        String health = request.getParameter("hHealthHistory");
        String allergic = request.getParameter("hAllergic");
        String diet = request.getParameter("hDietPreference");
        String status = request.getParameter("hStatus");
        String tentID = request.getParameter("TentID");

        Household h = new Household();
        h.setBeneficiaryID(beneficiaryId);
        h.setH_Name(name);
        h.setH_IC(ic);
        h.setH_Relationship(rel);
        h.setH_OKUStatus(oku);
        h.setH_HealthHistory(health);
        h.setH_Allergic(allergic);
        h.setH_DietPreference(diet);
        h.setH_Status(status);
        h.setTentID(tentID);

        beneficiaryDAO.insertHouseholdMember(h);
        
        List<Household> list = beneficiaryDAO.selectHouseholdByBeneficiaryID(beneficiaryId);
        Beneficiary b = beneficiaryDAO.selectBeneficiaryByID(beneficiaryId);
        b.setHouseholdSize(1 + list.size());
        beneficiaryDAO.updateBeneficiary(b);

        response.sendRedirect("editBeneficiary?id=" + beneficiaryId);
    }
    
    // =========================================================================
    //                               PUBLIC / SELF REGISTRATION METHODS
    // =========================================================================

    private void publicAddHouseholdToSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Household member = new Household();
        member.setH_Name(request.getParameter("hName"));
        member.setH_IC(request.getParameter("hIC"));
        member.setH_Relationship(request.getParameter("hRelationship"));
        
        String isMalaysian = request.getParameter("hIsMalaysian");
        String country = request.getParameter("hNationality");
        member.setH_Nationality("Malaysian".equals(isMalaysian) ? "Malaysian" : country);
        member.setH_OKUStatus(request.getParameter("hOku"));
        member.setH_HealthHistory(request.getParameter("hHealthHistory"));
        member.setH_Allergic(request.getParameter("hAllergic"));
        member.setH_DietPreference(request.getParameter("hDietPreference"));

        HttpSession session = request.getSession();
        List<Household> list = (List<Household>) session.getAttribute("tempHouseholdList");
        if (list == null) list = new ArrayList<>();
        
        list.add(member);
        session.setAttribute("tempHouseholdList", list);
        
        response.sendRedirect("publicNewBeneficiary.jsp");
    }

    private void publicRemoveHouseholdFromSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String indexStr = request.getParameter("index");
        if(indexStr != null) {
            int index = Integer.parseInt(indexStr);
            HttpSession session = request.getSession();
            List<Household> list = (List<Household>) session.getAttribute("tempHouseholdList");
            if (list != null && index >= 0 && index < list.size()) {
                list.remove(index);
                session.setAttribute("tempHouseholdList", list);
            }
        }
        response.sendRedirect("publicNewBeneficiary.jsp");
    }
    
    private void publicCheckoutAction(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException {
    
            String inputIC = request.getParameter("checkoutIC");
            if (inputIC == null || inputIC.isEmpty()) {
                response.sendRedirect("publicCheckout.jsp?error=Invalid+IC");
                return;
            }

            String cleanIC = inputIC.replace("-", "").trim();
            Beneficiary victim = beneficiaryDAO.searchByIC(cleanIC);

            if (victim != null) {
                if ("Active".equalsIgnoreCase(victim.getB_Status())) {
                    boolean success = beneficiaryDAO.checkoutFamily(victim.getBeneficiaryID());

                    if (success) {
                        response.sendRedirect("checkoutSuccess.jsp");
                    } else {
                        response.sendRedirect("publicCheckout.jsp?error=System+Update+Error");
                    }
                } else {
                    response.sendRedirect("publicCheckout.jsp?error=Victim+is+already+discharged");
                }
            } else {
                response.sendRedirect("publicCheckout.jsp?error=No+record+found+for+this+IC");
            }
        }

    private void showPublicNewBeneficiary(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
        ShelterDAO shelterDAO = new ShelterDAO();
        List<Shelter> allShelters = shelterDAO.selectAllShelters();
        List<Shelter> activeShelters = new ArrayList<>();

        if (allShelters != null) {
            for(Shelter s : allShelters) {
                if("Active".equalsIgnoreCase(s.getStatus())) {
                    activeShelters.add(s);
                }
            }
        }

        System.out.println("DEBUG: Found " + activeShelters.size() + " active shelters.");
        // ----------------

        request.setAttribute("activeShelters", activeShelters);
        request.getRequestDispatcher("publicNewBeneficiary.jsp").forward(request, response);
    }
    
    @Override
    public String getServletInfo() {
        return "Beneficiary Servlet handling CRUD operations and complex registration/checkout flows";
    }
}