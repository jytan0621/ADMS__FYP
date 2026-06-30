package com.WEB;

import com.DAO.*;
import com.Model.*;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "InventoryServlet", urlPatterns = {
    "/listInventory", "/newInventory", "/insertInventory", "/editInventory", "/updateInventory", "/deleteInventory",
    "/logisticsDashboard", "/prepareOrder", "/viewRequestItems", "/distributionCenter", "/listOutgoing",
    "/newRestock", "/submitRestock", "/listRestock", "/receiveRestock",
    "/listSupplier", "/newSupplier", "/insertSupplier",
    "/listDriver", "/newDriver", "/insertDriver",
    "/listIngoing", "/newIngoing", "/insertIngoing",
    "/restockApprovals", "/processRestockApproval", "/viewItemBatches","/viewRestockItems"
})
public class InventoryServlet extends HttpServlet {

    private InventoryDAO inventoryDAO;
    private RestockDAO restockDAO;
    private LogisticsPartnerDAO lpDAO;
    private NotificationDAO notifDAO;

    @Override
    public void init() {
        inventoryDAO = new InventoryDAO();
        restockDAO = new RestockDAO();
        lpDAO = new LogisticsPartnerDAO();
        notifDAO = new NotificationDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        try {
            switch (action) {
                case "/insertSupplier":
                    insertSupplier(request, response);
                    break;
                case "/insertDriver":
                    insertDriver(request, response);
                    break;
                case "/insertIngoing":
                    insertIngoing(request, response);
                    break;
                case "/processRestockApproval": 
                    processRestockApproval(request, response);
                    break;
                default:
                    doGet(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();

        try {
            switch (action) {
                // --- Restock Approvals (Approval Officer View) ---
                case "/restockApprovals": 
                    request.setAttribute("pendingRestocks", restockDAO.getPendingRestocks());
                    request.setAttribute("historyRestocks", restockDAO.getHistoryRestocks()); 
                    request.getRequestDispatcher("restockApproval.jsp").forward(request, response);
                    break;

                // --- Ingoing Inventory ---
                case "/listIngoing":
                    listIngoing(request, response);
                    break;
                case "/newIngoing":
                    showIngoingForm(request, response);
                    break;
                case "/receiveRestock":
                    showReceiveRestockForm(request, response);
                    break;

                // --- Partner Management ---
                case "/listSupplier":
                    listSuppliers(request, response);
                    break;
                case "/newSupplier":
                    request.getRequestDispatcher("newSupplier.jsp").forward(request, response);
                    break;
                case "/listDriver":
                    listDrivers(request, response);
                    break;
                case "/newDriver":
                    request.getRequestDispatcher("newDriver.jsp").forward(request, response);
                    break;

                // --- Inventory CRUD ---
                case "/newInventory":
                    showNewForm(request, response);
                    break;
                case "/insertInventory":
                    insertInventory(request, response);
                    break;
                case "/editInventory":
                    showEditForm(request, response);
                    break;
                case "/updateInventory":
                    updateInventory(request, response);
                    break;
                case "/deleteInventory":
                    deleteInventory(request, response);
                    break;
                case "/viewItemBatches":
                    viewItemBatches(request, response);
                    break;

                // --- Logistics & Distribution ---
                case "/logisticsDashboard":
                    showLogisticsDashboard(request, response);
                    break;
                case "/prepareOrder":
                    prepareOrder(request, response);
                    break;
                case "/distributionCenter":
                    showDistributionCenter(request, response);
                    break;
                case "/viewRequestItems":
                    viewRequestItems(request, response);
                    break;
                case "/listOutgoing":
                    request.setAttribute("outgoing", inventoryDAO.getOutgoingRecords());
                    request.getRequestDispatcher("outgoing.jsp").forward(request, response);
                    break;

                // --- Restock Management ---
                case "/newRestock":
                    showRestockForm(request, response);
                    break;
                case "/submitRestock":
                    submitRestock(request, response);
                    break;
                case "/listRestock":
                    listRestock(request, response);
                    break;
                case "/viewRestockItems":
                    viewRestockItems(request, response);
                    break;
                case "/listInventory":
                default:
                    listInventoryItems(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void processRestockApproval(HttpServletRequest request, HttpServletResponse response) 
        throws IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String restockID = request.getParameter("restockID");
        String actionType = request.getParameter("actionType"); 

        if ("Approve".equals(actionType)) {
            String[] itemIDs = request.getParameterValues("itemID[]");
            String[] approvedQts = request.getParameterValues("approvedQty[]");

            if (itemIDs != null && approvedQts != null) {
                for (int i = 0; i < itemIDs.length; i++) {
                    int newQty = Integer.parseInt(approvedQts[i]);
                    restockDAO.updateRestockItemQuantity(restockID, itemIDs[i], newQty);
                }
            }
            restockDAO.updateRestockStatus(restockID, "Approved", currentUser.getUserID());
            
            // ==========================================
            // TRIGGER 3: Notify Restock Requester safely
            // ==========================================
            RestockRequest req = restockDAO.selectRestockByID(restockID);
            if (req != null && req.getRrRequestedBy() != null) {
                notifDAO.sendToUser(req.getRrRequestedBy(), "Restock Request [" + restockID + "] has been Approved. Awaiting delivery.");
            } else {
                System.out.println("DEBUG ERROR: Could not find original requester for Restock " + restockID);
            }
            
        } else if ("Reject".equals(actionType)) {
            restockDAO.updateRestockStatus(restockID, "Rejected", currentUser.getUserID());
        }

        response.sendRedirect("restockApprovals");
    }

    // =========================================================================
    // INGOING & RESTOCK RECEIVING LOGIC
    // =========================================================================
    private void listIngoing(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        List<Ingoing> ingoingList = lpDAO.selectAllIngoing(); 
        request.setAttribute("ingoingList", ingoingList);
        request.getRequestDispatcher("ingoingList.jsp").forward(request, response);
    }

    private void showIngoingForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        List<InventoryItem> fullItemList = inventoryDAO.selectAllItems(myShelterID); 
        request.setAttribute("itemList", fullItemList); 
        request.setAttribute("supplierList", lpDAO.selectAllSuppliers());
        request.setAttribute("driverList", lpDAO.selectAllDrivers());
        request.getRequestDispatcher("newIngoing.jsp").forward(request, response);
    }

    private void showReceiveRestockForm(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException, ServletException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        String restockID = request.getParameter("id");
        RestockRequest rr = restockDAO.selectRestockByID(restockID);
        
        request.setAttribute("prefilledRestock", rr);
        request.setAttribute("itemList", inventoryDAO.selectAllItems(myShelterID));
        request.setAttribute("supplierList", lpDAO.selectAllSuppliers());
        request.setAttribute("driverList", lpDAO.selectAllDrivers());
        request.getRequestDispatcher("newIngoing.jsp").forward(request, response);
    }

    private void insertIngoing(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        Ingoing batch = new Ingoing();
        batch.setItemID(request.getParameter("itemID"));
        
        String restockID = request.getParameter("restockID");
        if (restockID != null && !restockID.isEmpty()) {
            batch.setRestockID(restockID); 
        }
        
        int qty = Integer.parseInt(request.getParameter("qtyReceived"));
        batch.setQuantityReceived(qty);
        batch.setCurrentQuantity(qty);
        batch.setArrivalDate(new java.util.Date());
        batch.setReceivedBy(currentUser.getUserID());
        batch.setDriverID(request.getParameter("driverID"));
        batch.setSupplierID(request.getParameter("supplierID"));
        batch.setbStatus("Available");

        try {
            String expiryStr = request.getParameter("expiryDate");
            if (expiryStr != null && !expiryStr.isEmpty()) {
                batch.setExpiryDate(new SimpleDateFormat("yyyy-MM-dd").parse(expiryStr));
            }
        } catch (Exception e) { e.printStackTrace(); }

        lpDAO.insertIngoing(batch);
        inventoryDAO.addStockQuantity(batch.getItemID(), qty);
        
        if (restockID != null && !restockID.isEmpty()) {
            restockDAO.updateRestockStatus(restockID, "Completed", currentUser.getUserID());
            
            // ==========================================
            // TRIGGER 4: Delivery Arrived
            // ==========================================
            notifDAO.sendToRole("Logistic Staff", "Incoming delivery batch [" + batch.getBatchID() + "] has arrived.");
        }

        response.sendRedirect("listIngoing");
    }

    // =========================================================================
    // SUPPLIER & DRIVER LOGIC
    // =========================================================================
    private void listSuppliers(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        List<Supplier> supplierList = lpDAO.selectAllSuppliers();
        request.setAttribute("supplierList", supplierList);
        request.getRequestDispatcher("supplierList.jsp").forward(request, response);
    }

    private void insertSupplier(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        Supplier s = new Supplier();
        s.setSupplierName(request.getParameter("supplierName"));
        s.setsCNumber(request.getParameter("sCNumber"));
        lpDAO.insertSupplier(s);
        response.sendRedirect("listSupplier");
    }

    private void listDrivers(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        List<Driver> driverList = lpDAO.selectAllDrivers();
        request.setAttribute("driverList", driverList);
        request.getRequestDispatcher("driverList.jsp").forward(request, response);
    }

    private void insertDriver(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String vehicle = request.getParameter("vehicle");

        if (lpDAO.checkVehicleExists(vehicle)) {
            response.sendRedirect("newDriver?error=DuplicateVehicle");
            return; 
        }
        
        Driver d = new Driver();
        d.setDriverName(request.getParameter("driverName"));
        d.setDriverCnumber(request.getParameter("driverCnumber"));
        d.setVehicle(vehicle);
        lpDAO.insertDriver(d);
        response.sendRedirect("listDriver");
    }

    // =========================================================================
    // CORE INVENTORY
    // =========================================================================
    private void listInventoryItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();
        
        String viewBatchID = request.getParameter("viewBatchID");
        if (viewBatchID != null) {
            request.setAttribute("targetBatchItemID", viewBatchID);
            request.setAttribute("batchList", inventoryDAO.getItemBatches(viewBatchID));
        }

        request.setAttribute("items", inventoryDAO.selectAllItems(myShelterID));
        request.getRequestDispatcher("itemList.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("NewInventory.jsp").forward(request, response);
    }

    private void insertInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        InventoryItem item = new InventoryItem();
        item.setItemID(request.getParameter("itemID"));
        item.setIName(request.getParameter("iName"));
        item.setCategory(request.getParameter("category"));
        item.setUnit(request.getParameter("unit"));
        item.setQuantityAvailable(Integer.parseInt(request.getParameter("quantityAvailable")));
        item.setThreshold(Integer.parseInt(request.getParameter("threshold")));
        
        inventoryDAO.insertInventoryItem(item, myShelterID);
        response.sendRedirect("listInventory");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        InventoryItem existingItem = inventoryDAO.selectItemByID(id);
        request.setAttribute("item", existingItem);
        request.getRequestDispatcher("EditInventoryForm.jsp").forward(request, response);
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        InventoryItem item = new InventoryItem(
            request.getParameter("id"), request.getParameter("iName"), request.getParameter("category"),
            request.getParameter("unit"), Integer.parseInt(request.getParameter("quantityAvailable")),
            Integer.parseInt(request.getParameter("threshold"))
        );
        inventoryDAO.updateInventoryItem(item);
        response.sendRedirect("listInventory");
    }

    private void deleteInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        inventoryDAO.deleteInventoryItem(request.getParameter("id"));
        response.sendRedirect("listInventory");
    }

    // =========================================================================
    // LOGISTICS & OUTGOING DASHBOARD
    // =========================================================================
    private void showDistributionCenter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        request.setAttribute("approvedRequests", inventoryDAO.getApprovedRequests());
        request.setAttribute("listInventory", inventoryDAO.selectAllItems(myShelterID));
        request.getRequestDispatcher("distribution.jsp").forward(request, response);
    }

    private void showLogisticsDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        request.setAttribute("approvedRequests", inventoryDAO.getApprovedRequests());
        request.setAttribute("listInventory", inventoryDAO.selectAllItems(myShelterID));
        request.setAttribute("stockHistory", inventoryDAO.getStockMovementHistory());
        
        request.getRequestDispatcher("LogisticMain.jsp").forward(request, response);
    }

    private void viewRequestItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();
        
        String targetID = request.getParameter("requestID");
        String source = request.getParameter("source"); 
        
        request.setAttribute("approvedRequests", inventoryDAO.getApprovedRequests());
        request.setAttribute("listInventory", inventoryDAO.selectAllItems(myShelterID));
        request.setAttribute("targetRequestID", targetID);
        request.setAttribute("requestItemsList", inventoryDAO.getItemsForRequest(targetID));
        
        if ("dist".equals(source)) {
            request.getRequestDispatcher("distribution.jsp").forward(request, response);
        } else {
            request.setAttribute("stockHistory", inventoryDAO.getStockMovementHistory());
            request.getRequestDispatcher("LogisticMain.jsp").forward(request, response);
        }
    }

    private void prepareOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
    
        HttpSession session = request.getSession();
        com.Model.User currentUser = (com.Model.User) session.getAttribute("currentUser");
        
        String requestID = request.getParameter("requestID");
        
        boolean success = inventoryDAO.prepareAidForDistribution(requestID, currentUser.getUserID());
        
        if (success) {
            // ==========================================
            // TRIGGER 5: Order Dispatched
            // ==========================================
            AidRequest req = new AidRequestDAO().selectAidRequest(requestID);
            if (req != null && req.getRequestedBy() != null) {
                notifDAO.sendToUser(req.getRequestedBy(), "Aid Request [" + requestID + "] has been packed and dispatched by Logistics.");
            }
            response.sendRedirect("logisticsDashboard?msg=OrderProcessed");
        } else {
            response.sendRedirect("logisticsDashboard?error=InsufficientStock");
        }
    }

    // =========================================================================
    // RESTOCK CREATION
    // =========================================================================
    private void showRestockForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        request.setAttribute("availableItems", inventoryDAO.selectAllItems(myShelterID));
        request.setAttribute("supplierList", lpDAO.selectAllSuppliers());
        request.getRequestDispatcher("newRestock.jsp").forward(request, response);
    }

    private void submitRestock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        
        RestockRequest rr = new RestockRequest();
        rr.setRrDateRequest(new java.util.Date());
        rr.setRrStatus("Pending");
        rr.setRrRequestedBy(user.getUserID());
        rr.setSupplierID(request.getParameter("supplierID")); 

        String[] itemIDs = request.getParameterValues("itemID[]");
        String[] quantities = request.getParameterValues("quantity[]");
        List<RestockItem> itemsList = new ArrayList<>();
        
        if (itemIDs != null) {
            for (int i = 0; i < itemIDs.length; i++) {
                if (!itemIDs[i].isEmpty()) {
                    RestockItem ri = new RestockItem();
                    ri.setItemID(itemIDs[i]);
                    ri.setRrQuantityRequest(Integer.parseInt(quantities[i]));
                    itemsList.add(ri);
                }
            }
        }
        rr.setItems(itemsList);
        restockDAO.insertRestockRequest(rr);
        
        // ==========================================
        // TRIGGER 6: Request Sent to Approver
        // ==========================================
        if (!"Admin".equalsIgnoreCase(user.getRole()) && !"Approval Officer".equalsIgnoreCase(user.getRole())) {
            notifDAO.sendToRole("Approval Officer", "New Restock Request submitted by " + user.getUserName() + ".");
        }
        response.sendRedirect("listRestock");
    }

    private void viewItemBatches(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        String myShelterID = currentUser.getAssignedRegion();

        String itemID = request.getParameter("itemID");
        
        request.setAttribute("approvedRequests", inventoryDAO.getApprovedRequests());
        request.setAttribute("listInventory", inventoryDAO.selectAllItems(myShelterID));
        request.setAttribute("stockHistory", inventoryDAO.getStockMovementHistory());
        
        request.setAttribute("targetBatchItemID", itemID);
        request.setAttribute("batchList", inventoryDAO.getItemBatches(itemID));
        
        request.getRequestDispatcher("LogisticMain.jsp").forward(request, response);
    }
    
    private void listRestock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("restockList", restockDAO.selectAllRestocks());
        request.getRequestDispatcher("restock.jsp").forward(request, response);
    }
    
    private void viewRestockItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String restockID = request.getParameter("id");
        
        request.setAttribute("restockList", restockDAO.selectAllRestocks());
        request.setAttribute("targetRestock", restockDAO.selectRestockByID(restockID));
        
        request.getRequestDispatcher("restock.jsp").forward(request, response);
    }
}