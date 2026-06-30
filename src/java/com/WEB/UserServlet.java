package com.WEB;

import com.DAO.UserDAO;
import com.Model.User;
import com.Utility.EmailUtility; 
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(name = "UserServlet", urlPatterns = {
    "/UserServlet", "/list", "/new", "/insert", "/edituser", 
    "/editadmin", "/userupdate", "/adminupdate", "/passwordupdate", "/passwordchange"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UserServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    public void init(){
        userDAO = new UserDAO();
    }
      
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        
        try{
            switch (action){
                case "/new": showNewForm(request,response); break;
                case "/insert": insertUser(request,response); break;  
                case "/edituser": showEditUserForm(request,response); break;
                case "/editadmin": showEditAdminForm(request,response); break;
                case "/userupdate": updateUser(request,response); break;
                case "/adminupdate": updateAdmin(request,response); break;
                case "/passwordupdate": updatePasswordForm(request,response); break;
                case "/passwordchange": changePassword(request,response); break;
                default: listUser(request, response); break;
            }
        }catch (SQLException ex){
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet (request, response);
    }
    
    // --- MAIN METHODS ---

    private void listUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.sendRedirect("index.jsp");
                return;
            }
            List<User> listUser;

            if ("Manager".equals(currentUser.getRole())) {
                listUser = userDAO.selectAllUsersGlobal(); 
            } else {
                String regionToFilter = currentUser.getAssignedRegion();
                listUser = userDAO.selectAllUser(regionToFilter); 
            }
            request.setAttribute("listUser", listUser);
            RequestDispatcher dispatcher = request.getRequestDispatcher("UserList.jsp");
            dispatcher.forward(request,response);
    }
    
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        RequestDispatcher dispatcher = request.getRequestDispatcher("newUser.jsp"); 
        dispatcher.forward(request,response);
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder();
        java.util.Random random = new java.util.Random();
        for (int i = 0; i < 8; i++) { 
            int index = random.nextInt(chars.length());
            sb.append(chars.charAt(index));
        }
        return sb.toString();
    }

    private void insertUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String userName = request.getParameter("username");
        String email = request.getParameter("email");      
        String role = request.getParameter("role");
        
        String assignedRegion = request.getParameter("assignedRegion");
        
        if (assignedRegion == null || assignedRegion.trim().isEmpty()) {
            assignedRegion = "General"; 
        }

        String status = "Active"; 
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String createdAt = sdf.format(new java.util.Date());

        String autoPassword = generateRandomPassword();

        User newUser = new User(null, userName, email, autoPassword, role, assignedRegion, createdAt, status);
        userDAO.insertUser(newUser);
        
        // FIXED: Better Error Handling so you know if the email failed
        try {
            String subject = "ADMS - Account Created";
            String content = "Welcome " + userName + ".\nYour login email is: " + email + "\nYour temporary password is: " + autoPassword;
            EmailUtility.sendEmail(email, subject, content);
            response.sendRedirect("list?msg=UserAdded");
        } catch (Exception e) { 
            System.err.println("Email failed to send. Password is: " + autoPassword);
            e.printStackTrace(); 
            response.sendRedirect("list?msg=UserAddedEmailFailed"); // Tells the UI that the user exists but the email broke!
        }
    }
    
    private void showEditUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        String UserID= request.getParameter("UserID");
        User existingUser = userDAO.selectUser(UserID);
        request.setAttribute("user", existingUser); 
        RequestDispatcher dispatcher = request.getRequestDispatcher("EditUserForm.jsp");
        dispatcher.forward(request,response);
    }
    
    private void showEditAdminForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        String UserID= request.getParameter("UserID"); 
        if (UserID == null) {
            UserID = request.getParameter("id");
        }
        User existingUser = userDAO.selectUser(UserID);
        request.setAttribute("user", existingUser);
        RequestDispatcher dispatcher = request.getRequestDispatcher("EditAdminForm.jsp");
        dispatcher.forward(request,response);
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        
        String UserID = request.getParameter("userId");
        String UserName = request.getParameter("username");
        String Email = request.getParameter("email");
        
        Part filePart = request.getPart("profilePic"); 
        String fileName = "default-avatar.png";
        
        if (filePart != null && filePart.getSize() > 0) {
            String submittedFileName = getFileName(filePart);
            fileName = UserID + "_" + submittedFileName;
            
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            
            filePart.write(uploadPath + File.separator + fileName);
        } else {
            fileName = request.getParameter("existingPic");
        }
        
        User user = new User();
        user.setUserID(UserID);
        user.setUserName(UserName);
        user.setEmail(Email);
        user.setProfilePicture(fileName);
        
        userDAO.userUpdate(user);
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null && currentUser.getUserID().equals(UserID)) {
            currentUser.setUserName(UserName);
            currentUser.setEmail(Email);
            currentUser.setProfilePicture(fileName);
        }

        response.sendRedirect("UserProfile.jsp");
     }
    
    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return "default-avatar.png";
    }
    
    private void updateAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        String UserID= request.getParameter("userId"); 
        String Role= request.getParameter("role");
        String Status= request.getParameter("status");
        
        String AssignedRegion = request.getParameter("assignedRegion");

        if (AssignedRegion == null || AssignedRegion.trim().isEmpty()) {
            AssignedRegion = "General";
        }
        
         User user=new User();
         user.setUserID(UserID);
         user.setRole(Role);
         user.setAssignedRegion(AssignedRegion);
         user.setStatus(Status);
         
         userDAO.adminUpdate(user);
         response.sendRedirect("list?msg=AdminUpdated");
     }
    
    private void updatePasswordForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        String UserID= request.getParameter("UserID"); 
        User existingUser = userDAO.selectUser(UserID);
        RequestDispatcher dispatcher = request.getRequestDispatcher("ChangePasswordForm.jsp");
        dispatcher.forward(request,response);
     }
    
    private void changePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException{
        String UserID= request.getParameter("UserID"); 
        String Password= request.getParameter("Password");
        User user=new User();
        user.setUserID(UserID);
        user.setPassword(Password);
        userDAO.passwordUpdate(user);
        response.sendRedirect("list");
     }
    
    @Override
    public String getServletInfo() {
        return "User Management Controller";
    }
}