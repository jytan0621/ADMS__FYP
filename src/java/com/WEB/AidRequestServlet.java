package com.WEB;

import com.DAO.AidRequestDAO;
import com.DAO.InventoryDAO; 
import com.DAO.NotificationDAO; // IMPORT NOTIFICATION DAO
import com.Model.AidRequest;
import com.Model.AidRequestItem;
import com.Model.InventoryItem;
import com.Model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AidRequestServlet", urlPatterns = {
    "/AidRequestServlet",
    "/listRequest",        
    "/newRequest",        
    "/insertRequest",      
    "/viewRequest",        
    "/deleteRequest",      
    "/processRequest",
    "/editRequest",
    "/updateRequest"
})
public class AidRequestServlet extends HttpServlet {

    private AidRequestDAO aidRequestDAO;
    private InventoryDAO inventoryDAO; 

    public void init() {
        aidRequestDAO = new AidRequestDAO();
        inventoryDAO = new InventoryDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();

        try {
            switch (action) {
                case "/newRequest": showNewForm(request, response); break;
                case "/insertRequest": insertRequest(request, response); break;
                case "/viewRequest": viewRequest(request, response); break;
                case "/deleteRequest": deleteRequest(request, response); break;
                case "/processRequest": processApproval(request, response); break;
                case "/editRequest": showEditForm(request, response); break;
                case "/updateRequest": updateRequest(request, response); break;
                default: listRequest(request, response); break;
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

    // --- LIST (UPDATED: Role Based) ---
    private void listRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
        
        session.removeAttribute("tempRequestItems"); 
        
        String statusFilter = request.getParameter("status"); 
        List<AidRequest> listRequest = aidRequestDAO.selectAllRequests(currentUser.getUserID(), currentUser.getRole(), statusFilter);
        Map<String, String> summaryMap = aidRequestDAO.getAllItemSummaries();
        Map<String, String> userMap = aidRequestDAO.getAllUserNames();

        request.setAttribute("listRequest", listRequest);
        request.setAttribute("summaryMap", summaryMap);
        request.setAttribute("userMap", userMap);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("AidRequestList.jsp");
        dispatcher.forward(request, response);
    }

    // --- NEW FORM ---
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        List<InventoryItem> items = inventoryDAO.selectAllItems(currentUser.getAssignedRegion()); 
        request.setAttribute("inventoryList", items);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("newRequest.jsp");
        dispatcher.forward(request, response);
    }

    // --- INSERT ---
    private void insertRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        String[] itemIds = request.getParameterValues("itemId");
        String[] quantities = request.getParameterValues("quantity");

        if (itemIds == null || itemIds.length == 0) {
            response.sendRedirect("newRequest?error=NoItemsSelected");
            return;
        }

        try {
            AidRequest newRequest = new AidRequest();
            newRequest.setRequestedBy(currentUser.getUserID());
            String newRequestID = aidRequestDAO.insertAidRequest(newRequest); 
            newRequest.setShelterID(currentUser.getAssignedRegion());
            

            if(newRequestID != null && !newRequestID.startsWith("SQL_ERROR")) {
                 for (int i = 0; i < itemIds.length; i++) {
                     if (itemIds[i] != null && !itemIds[i].isEmpty() && quantities[i] != null && !quantities[i].isEmpty()) {
                         AidRequestItem item = new AidRequestItem();
                         item.setRequestID(newRequestID);
                         item.setItemID(itemIds[i]);
                         try {
                            item.setArQuantityRequested(Integer.parseInt(quantities[i]));
                            aidRequestDAO.insertRequestItem(item); 
                         } catch (NumberFormatException e) { e.printStackTrace(); }
                     }
                 }
                 
                 NotificationDAO notifDAO = new NotificationDAO();
                 notifDAO.sendToRole("Approval Officer", "New Aid Request [" + newRequestID + "] submitted by " + currentUser.getUserName() + " for Shelter " + currentUser.getAssignedRegion() + ".");
                 
                 response.sendRedirect("listRequest?msg=Success");
            } else {
                 String errorMsg = (newRequestID != null) ? newRequestID : "Database Insert Failed";
                 response.sendRedirect("listRequest?error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
            }
        // 🚨 WE ARE NOW CATCHING THE SERVER CRASH EXCEPTION HERE
        } catch (Exception e) {
            e.printStackTrace(); // Keep it in the logs
            // Extract the message, clean it so it doesn't break the URL, and send to the UI
            String cleanError = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Unknown DB Error";
            response.sendRedirect("listRequest?error=" + java.net.URLEncoder.encode(cleanError, "UTF-8"));
        }
    }

    // --- EDIT FORM ---
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id"); 
        
        AidRequest aidRequest = aidRequestDAO.selectAidRequest(id);
        List<AidRequestItem> dbItems = aidRequestDAO.selectItemsByRequestID(id);
        
        if (aidRequest == null) {
            response.sendRedirect("listRequest?error=NotFound");
            return;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        session.setAttribute("tempRequestItems", dbItems); 
        
        List<InventoryItem> inventoryList = inventoryDAO.selectAllItems(currentUser.getAssignedRegion());
        
        request.setAttribute("inventoryList", inventoryList);
        request.setAttribute("aidRequest", aidRequest);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("EditAidRequest.jsp");
        dispatcher.forward(request, response);
    }

    // --- UPDATE ---
    private void updateRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String requestID = request.getParameter("requestID");
        
        try {
            aidRequestDAO.deleteItemsByRequestID(requestID);
            
            String[] itemIds = request.getParameterValues("itemId");
            String[] quantities = request.getParameterValues("quantity");

            if (itemIds != null) {
                for (int i = 0; i < itemIds.length; i++) {
                     if (itemIds[i] != null && !itemIds[i].isEmpty()) {
                         AidRequestItem item = new AidRequestItem();
                         item.setRequestID(requestID);
                         item.setItemID(itemIds[i]);
                         try {
                            item.setArQuantityRequested(Integer.parseInt(quantities[i]));
                            aidRequestDAO.insertRequestItem(item); 
                         } catch (NumberFormatException e) { e.printStackTrace(); }
                     }
                }
            }
            
            HttpSession session = request.getSession();
            session.removeAttribute("tempRequestItems");
            response.sendRedirect("viewRequest?id=" + requestID + "&msg=UpdatedSuccessfully");
        } catch (Exception e) {
            String cleanError = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\n", " ") : "Unknown DB Error";
            response.sendRedirect("listRequest?error=" + java.net.URLEncoder.encode(cleanError, "UTF-8"));
        }
    }

    // --- VIEW ---
    private void viewRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String id = request.getParameter("id");
        AidRequest req = aidRequestDAO.selectAidRequest(id);
        List<AidRequestItem> items = aidRequestDAO.selectItemsByRequestID(id);
        request.setAttribute("request", req);
        request.setAttribute("items", items); 
        RequestDispatcher dispatcher = request.getRequestDispatcher("ViewAidRequest.jsp");
        dispatcher.forward(request, response);
    }
    
    // --- DELETE ---
    private void deleteRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String id = request.getParameter("id");
        aidRequestDAO.deleteAidRequest(id); 
        response.sendRedirect("listRequest");
    }
    
    // =========================================================================
    // [UPDATED] PROCESS APPROVAL WITH STOCK & THRESHOLD VALIDATION
    // =========================================================================
    private void processApproval(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        String requestId = request.getParameter("id");
        String status = request.getParameter("status"); 
        String remark = request.getParameter("remark");

        StringBuilder warningMsg = new StringBuilder();
        boolean hasThresholdWarning = false;

        if ("Approved".equalsIgnoreCase(status)) {
            List<AidRequestItem> items = aidRequestDAO.selectItemsByRequestID(requestId);
            
            for (AidRequestItem reqItem : items) {
                InventoryItem stockItem = inventoryDAO.selectItemByID(reqItem.getItemID());
                int reservedQty = aidRequestDAO.getReservedStock(reqItem.getItemID());
                
                if (stockItem != null) {
                    int requested = reqItem.getArQuantityRequested();
                    int physicalStock = stockItem.getQuantityAvailable();
                    int threshold = stockItem.getThreshold();
                    
                    int effectiveStock = physicalStock - reservedQty; 
                    
                    if (requested > effectiveStock) {
                        String errorMsg = "Insufficient Stock for " + stockItem.getIName() + 
                                          ". (Physical: " + physicalStock + ", Reserved: " + reservedQty + 
                                          ", Available: " + effectiveStock + "). Please Edit Request.";
                        
                        response.sendRedirect("viewRequest?id=" + requestId + "&error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
                        return; 
                    }

                    int futureRemaining = effectiveStock - requested;
                    if (futureRemaining < threshold) {
                        if (warningMsg.length() > 0) warningMsg.append(", ");
                        warningMsg.append(stockItem.getIName() + " (Will drop to: " + futureRemaining + ")");
                        hasThresholdWarning = true;
                    }
                }
            }
        }

        aidRequestDAO.processApproval(requestId, status, currentUser.getUserID(), remark);
        
        NotificationDAO notifDAO = new NotificationDAO();
        AidRequest originalReq = aidRequestDAO.selectAidRequest(requestId);
        
        if (originalReq != null) {
            String originalRequesterID = originalReq.getRequestedBy();
            
            if ("Approved".equalsIgnoreCase(status)) {
                notifDAO.sendToUser(originalRequesterID, "Your Aid Request [" + requestId + "] has been APPROVED.");
                notifDAO.sendToRole("Logistic Staff", "Aid Request [" + requestId + "] approved. Ready for packing.");
            } else if ("Rejected".equalsIgnoreCase(status)) {
                String rejectReason = (remark != null && !remark.isEmpty()) ? " Reason: " + remark : "";
                notifDAO.sendToUser(originalRequesterID, "Your Aid Request [" + requestId + "] was REJECTED." + rejectReason);
            }
        }
        
        String redirectUrl = "viewRequest?id=" + requestId + "&msg=" + status + "Successfully";
        
        if (hasThresholdWarning) {
            String warn = "System Notification: Stock for [" + warningMsg.toString() + "] is below threshold!";
            redirectUrl += "&warning=" + java.net.URLEncoder.encode(warn, "UTF-8");
        }
        
        response.sendRedirect(redirectUrl);
    }
}