package com.DAO;

import com.Model.Beneficiary;
import com.Model.Household;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BeneficiaryDAO {
    /*String jdbcURL = "jdbc:mysql://localhost:3306/adms";
    String jdbcUserName = "root";
    String jdbcPassword = "admin";
    */
    
    String jdbcURL = "jdbc:mysql://localhost:3306/s71172_adms";
    String jdbcUserName = "s71172";
    String jdbcPassword = "RynnTan0621@";
    
    // ================= SQL QUERIES FOR BENEFICIARY =================
    private static final String INSERT_BENEFICIARY_SQL = "INSERT INTO beneficiary" +
            " (B_Name, B_ICNumber, B_Race, B_Religion, B_Nationality, B_ContactNumber, HouseholdSize, Street, Postcode, B_OKUStatus, B_DietPreference, B_HealthHistory, B_Allergic, B_Status, RegisteredBy, DateRegistered, ShelterID, TentID) VALUES " +
            " (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE_BENEFICIARY_SQL = "UPDATE beneficiary SET B_Name=?, B_ICNumber=?, B_Race=?, B_Religion=?, " +
            "B_Nationality=?, B_ContactNumber=?, HouseholdSize=?, Street=?, Postcode=?, " +
            "B_OKUStatus=?, B_DietPreference=?, B_HealthHistory=?, B_Allergic=?, " +
            "B_Status=?, ShelterID=?, TentID=? WHERE BeneficiaryID=?";

    private static final String SELECT_BENEFICIARY_BY_IC = "SELECT * FROM beneficiary WHERE B_ICNumber = ?";
    private static final String SELECT_BENEFICIARY_BY_ID = "SELECT * FROM beneficiary WHERE BeneficiaryID = ?";
    private static final String SELECT_ALL_BENEFICIARIES = "SELECT * FROM beneficiary ORDER BY BeneficiaryID DESC";
    
    // FIXED: Filter out previous year's beneficiaries by comparing Registration Date with Shelter Activation Date
    private static final String SELECT_BENEFICIARIES_BY_STATUS = 
            "SELECT b.* FROM beneficiary b LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
            "WHERE b.B_Status = ? AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) ORDER BY b.BeneficiaryID DESC";
    
    private static final String DELETE_BENEFICIARY_SQL = "DELETE FROM beneficiary WHERE BeneficiaryID = ?";
    private static final String UPDATE_BENEFICIARY_STATUS_SQL = "UPDATE beneficiary SET B_status = ? WHERE BeneficiaryID = ?";
    private static final String DISCHARGE_HOUSEHOLD_SQL = "UPDATE household SET H_status = 'DISCHARGED' WHERE BeneficiaryID = ? AND H_status = 'ADMITTED'";

    // ================= SQL QUERIES FOR HOUSEHOLD =================
    private static final String INSERT_HOUSEHOLD_SQL = "INSERT INTO household" +
            " (BeneficiaryID, H_Name, H_ICNumber, H_Nationality, Relationship, H_OKUStatus, H_HealthHistory, H_Allergic, H_DietPreferences, H_status, TentID) VALUES " +
            " (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE_HOUSEHOLD_SQL = "UPDATE household SET H_Name=?, H_ICNumber=?, H_Nationality=?, Relationship=?, " +
            "H_OKUStatus=?, H_HealthHistory=?, H_Allergic=?, H_DietPreferences=?, " +
            "H_status=?, TentID=? WHERE HouseholdID=?";

    private static final String DELETE_HOUSEHOLD_SQL = "DELETE FROM household WHERE HouseholdID = ?";
    private static final String SELECT_HOUSEHOLD_BY_BEN_ID = "SELECT * FROM household WHERE BeneficiaryID = ?";
    private static final String SELECT_HOUSEHOLD_BY_ID = "SELECT * FROM household WHERE HouseholdID = ?";
    
    // ================= SQL QUERIES FOR TENTS =================
    private static final String SELECT_AVAILABLE_TENTS = "SELECT TentID FROM tents WHERE ShelterID = ? AND Status = 'Available' ORDER BY TentNumber ASC LIMIT ?";
    private static final String UPDATE_TENT_INC = "UPDATE tents SET current_occupancy = current_occupancy + 1, Status = IF(current_occupancy + 1 >= capacity, 'Occupied', 'Available') WHERE TentID = ?";
    private static final String UPDATE_TENT_DEC = "UPDATE tents SET current_occupancy = GREATEST(0, current_occupancy - 1), Status = 'Available' WHERE TentID = ?";

    public BeneficiaryDAO(){}
    
    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUserName, jdbcPassword);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Database connection failed");
        }
    }

    // ================= SHELTER LOOKUP USING INNER JOIN =================

    public String getShelterIDByStaffRegion(String regionString) {
        if (regionString == null || regionString.trim().isEmpty()) return null;

        String state = "";
        String city = "";

        // Check if the format is "City, State" (e.g., "Kuala Nerus, Terengganu")
        if (regionString.contains(",")) {
            String[] parts = regionString.split(",");
            city = parts[0].trim();
            state = parts[1].trim();
        } 
        // Fallback for old format "State-City"
        else if (regionString.contains("-")) {
            String[] parts = regionString.split("-");
            state = parts[0].trim();
            city = parts[1].trim();
        } 
        else {
            return null; // Invalid format
        }

        String sql = "SELECT s.ShelterID FROM shelter s " +
                     "JOIN address a ON s.Postcode = a.Postcode " +
                     "WHERE a.State LIKE ? AND a.City LIKE ?";
                     
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + state + "%");
            ps.setString(2, "%" + city + "%");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("ShelterID");
        } catch (SQLException e) { printSQLException(e); }
        
        return null;
    }

    public String getShelterIDByPostcode(int postcode) {
        String sql = "SELECT ShelterID FROM shelter WHERE Postcode = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postcode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("ShelterID");
        } catch (SQLException e) { printSQLException(e); }
        return null;
    }

    // ================= TENT OPERATIONS =================

    public List<String> getAvailableTents(String shelterID, int neededCount) throws SQLException {
        List<String> tentIDs = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(SELECT_AVAILABLE_TENTS)) {
            ps.setString(1, shelterID);
            ps.setInt(2, neededCount);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) { tentIDs.add(rs.getString("TentID")); }
        }
        return tentIDs;
    }

    /**
     * NEW METHOD: Assigns a single beneficiary to a tent based on gender (IC Last Digit).
     * Odd IC = Male (1) | Even IC = Female (0).
     * It ensures the tent does NOT contain families or singles of the opposite gender.
     */
    public String getAvailableTentForSingle(String shelterID, String icNumber) throws SQLException {
        if (icNumber == null || icNumber.isEmpty()) return null;

        // Clean IC by removing hyphens and spaces
        String cleanIC = icNumber.replace("-", "").trim();
        if (cleanIC.isEmpty()) return null;

        // Get the last character. If somehow it's not a digit, default to 0 (Even) to prevent crashes
        char lastChar = cleanIC.charAt(cleanIC.length() - 1);
        int lastDigit = Character.isDigit(lastChar) ? Character.getNumericValue(lastChar) : 0;
        
        // Calculate gender modulo: 1 for Male (Odd), 0 for Female (Even)
        int genderMod = lastDigit % 2; 

        // SQL Explanation:
        // 1. Get an available tent in this shelter.
        // 2. Ensure NO families (HouseholdSize > 1) are in this tent.
        // 3. Ensure NO singles of the OPPOSITE gender are in this tent.
        // 4. Fill partially occupied tents first before opening a completely empty one.
        String sql = "SELECT t.TentID FROM tents t " +
                     "WHERE t.ShelterID = ? AND t.Status = 'Available' " +
                     "AND NOT EXISTS ( " +
                     "    SELECT 1 FROM beneficiary b " +
                     "    WHERE b.TentID = t.TentID AND b.HouseholdSize > 1 AND b.B_Status = 'Active' " +
                     ") " +
                     "AND NOT EXISTS ( " +
                     "    SELECT 1 FROM beneficiary b " +
                     "    WHERE b.TentID = t.TentID AND b.HouseholdSize = 1 AND b.B_Status = 'Active' " +
                     "    AND MOD(CAST(RIGHT(REPLACE(b.B_ICNumber, '-', ''), 1) AS UNSIGNED), 2) != ? " +
                     ") " +
                     "ORDER BY t.current_occupancy DESC, t.TentNumber ASC LIMIT 1";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shelterID);
            ps.setInt(2, genderMod);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("TentID");
            }
        }
        return null; // Return null if no suitable tent is found (shelter full)
    }

    public void incrementTentOccupancy(String tentID) throws SQLException {
        if (tentID == null || tentID.isEmpty()) return;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(UPDATE_TENT_INC)) {
            ps.setString(1, tentID);
            ps.executeUpdate();
        }
    }

    public void decrementTentOccupancy(String tentID) throws SQLException {
        if (tentID == null || tentID.isEmpty()) return;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(UPDATE_TENT_DEC)) {
            ps.setString(1, tentID);
            ps.executeUpdate();
        }
    }

    // ================= SYNCHRONIZED CHECKOUT =================

    public boolean checkoutFamily(String beneficiaryID) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            Beneficiary b = selectBeneficiaryByID(beneficiaryID);
            List<Household> members = selectHouseholdByBeneficiaryID(beneficiaryID);

            if (b != null && b.getTentID() != null) decrementTentOccupancy(b.getTentID());
            for (Household m : members) {
                if (m.getTentID() != null) decrementTentOccupancy(m.getTentID());
            }

            String sqlB = "UPDATE beneficiary SET B_status = 'Inactive', TentID = NULL WHERE BeneficiaryID = ?";
            String sqlH = "UPDATE household SET H_status = 'DISCHARGED', TentID = NULL WHERE BeneficiaryID = ?";
            
            try (PreparedStatement psB = conn.prepareStatement(sqlB);
                 PreparedStatement psH = conn.prepareStatement(sqlH)) {
                psB.setString(1, beneficiaryID);
                psB.executeUpdate();
                psH.setString(1, beneficiaryID);
                psH.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    // ================= NOTIFICATION HELPER =================

    private void checkShelterCapacityWarning(String shelterID) {
        if (shelterID == null || shelterID.isEmpty()) return;
        
        try (Connection conn = getConnection()) {
            int capacity = 0;
            try(PreparedStatement ps = conn.prepareStatement("SELECT Capacity FROM shelter WHERE ShelterID = ?")) {
                ps.setString(1, shelterID);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) capacity = rs.getInt("Capacity");
            }
            
            if (capacity > 0) {
                int currentPop = 0;
                String popSql = "SELECT " +
                    "(SELECT COUNT(*) FROM beneficiary b WHERE b.ShelterID = ? AND b.B_Status = 'Active') + " +
                    "(SELECT COUNT(*) FROM household h JOIN beneficiary b2 ON h.BeneficiaryID = b2.BeneficiaryID WHERE b2.ShelterID = ? AND h.H_status IN ('ADMITTED', 'PENDING')) AS total";
                try(PreparedStatement ps2 = conn.prepareStatement(popSql)) {
                    ps2.setString(1, shelterID);
                    ps2.setString(2, shelterID);
                    ResultSet rs2 = ps2.executeQuery();
                    if(rs2.next()) currentPop = rs2.getInt("total");
                }
                
                double fillPercentage = (double) currentPop / capacity;
                if (fillPercentage >= 0.95) {
                    NotificationDAO notifDAO = new NotificationDAO();
                    String msg = "Capacity Warning: Shelter " + shelterID + " is at " + (int)(fillPercentage * 100) + "% capacity. Prepare secondary shelter.";
                    notifDAO.sendToRole("Manager", msg);
                    notifDAO.sendToRole("Admin", msg);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ================= BENEFICIARY OPERATIONS =================

    public void insertBeneficiary(Beneficiary b) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(INSERT_BENEFICIARY_SQL)) {
            
            preparedStatement.setString(1, b.getB_Name());
            preparedStatement.setString(2, b.getB_ICNumber());
            preparedStatement.setString(3, b.getB_Race());
            preparedStatement.setString(4, b.getB_Religion());
            preparedStatement.setString(5, b.getB_Nationality());
            preparedStatement.setString(6, b.getB_ContactNumber());
            preparedStatement.setInt(7, b.getHouseholdSize());
            preparedStatement.setString(8, b.getStreet());
            preparedStatement.setInt(9, b.getPostcode());
            preparedStatement.setString(10, b.getB_OKUStatus());
            preparedStatement.setString(11, b.getB_DietPreference());
            preparedStatement.setString(12, b.getB_HealthHistory());
            preparedStatement.setString(13, b.getB_Allergic());
            preparedStatement.setString(14, b.getB_Status());
            preparedStatement.setString(15, b.getRegisteredBy());
            
            if (b.getDateRegistered() != null && !b.getDateRegistered().isEmpty()) {
                preparedStatement.setDate(16, java.sql.Date.valueOf(b.getDateRegistered()));
            } else {
                preparedStatement.setDate(16, new java.sql.Date(System.currentTimeMillis()));
            }

            preparedStatement.setString(17, b.getShelterID());
            preparedStatement.setString(18, b.getTentID());

            preparedStatement.executeUpdate();
            
            // --- NOTIFICATION TRIGGER: Capacity Warning ---
            checkShelterCapacityWarning(b.getShelterID());
        }
    }

    public boolean updateBeneficiary(Beneficiary b) throws SQLException {
        boolean rowUpdated;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_BENEFICIARY_SQL)) {
            
            preparedStatement.setString(1, b.getB_Name());
            preparedStatement.setString(2, b.getB_ICNumber());
            preparedStatement.setString(3, b.getB_Race());
            preparedStatement.setString(4, b.getB_Religion());
            preparedStatement.setString(5, b.getB_Nationality());
            preparedStatement.setString(6, b.getB_ContactNumber());
            preparedStatement.setInt(7, b.getHouseholdSize());
            preparedStatement.setString(8, b.getStreet());
            preparedStatement.setInt(9, b.getPostcode());
            preparedStatement.setString(10, b.getB_OKUStatus());
            preparedStatement.setString(11, b.getB_DietPreference());
            preparedStatement.setString(12, b.getB_HealthHistory());
            preparedStatement.setString(13, b.getB_Allergic());
            preparedStatement.setString(14, b.getB_Status());
            
            preparedStatement.setString(15, b.getShelterID());
            preparedStatement.setString(16, b.getTentID());
            preparedStatement.setString(17, b.getBeneficiaryID());

            rowUpdated = preparedStatement.executeUpdate() > 0;
        }
        return rowUpdated;
    }

    public boolean deleteBeneficiary(String id) {
        Connection conn = null;
        PreparedStatement psHousehold = null;
        PreparedStatement psBeneficiary = null;

        checkoutFamily(id);

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String sqlHousehold = "DELETE FROM household WHERE BeneficiaryID = ?";
            psHousehold = conn.prepareStatement(sqlHousehold);
            psHousehold.setString(1, id);
            psHousehold.executeUpdate();

            String sqlBeneficiary = "DELETE FROM beneficiary WHERE BeneficiaryID = ?";
            psBeneficiary = conn.prepareStatement(sqlBeneficiary);
            psBeneficiary.setString(1, id);
            int rowsAffected = psBeneficiary.executeUpdate();

            conn.commit();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            try { if (psHousehold != null) psHousehold.close(); } catch (Exception e) {}
            try { if (psBeneficiary != null) psBeneficiary.close(); } catch (Exception e) {}
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception e) {}
        }
    }

    public boolean updateBeneficiaryStatus(String id, String bStatusInput) {
        boolean success = false;
        Connection conn = null;
        PreparedStatement ps1 = null;

        if ("Inactive".equalsIgnoreCase(bStatusInput)) {
            return checkoutFamily(id);
        }

        try {
            conn = getConnection();
            ps1 = conn.prepareStatement(UPDATE_BENEFICIARY_STATUS_SQL);
            ps1.setString(1, bStatusInput); 
            ps1.setString(2, id.trim());
            
            int rows = ps1.executeUpdate();
            if (rows > 0) success = true;

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (ps1 != null) ps1.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        
        return success;
    }

    public Beneficiary searchByIC(String searchIC) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();

            String sqlBene = "SELECT * FROM beneficiary WHERE REPLACE(B_ICNumber, '-', '') = ?";
            ps = conn.prepareStatement(sqlBene);
            ps.setString(1, searchIC);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToBeneficiary(rs);
            }
            
            rs.close();
            ps.close();

            String sqlHouse = "SELECT * FROM household WHERE REPLACE(H_ICNumber, '-', '') = ?";
            ps = conn.prepareStatement(sqlHouse);
            ps.setString(1, searchIC);
            rs = ps.executeQuery();

            if (rs.next()) {
                String childName = rs.getString("H_Name");
                String childIC = rs.getString("H_ICNumber");
                String relationship = rs.getString("Relationship");
                String parentID = rs.getString("BeneficiaryID");

                Beneficiary parentObj = selectBeneficiaryByID(parentID);

                if (parentObj != null) {
                    parentObj.setB_Name(childName + " (" + relationship + ")");
                    parentObj.setB_ICNumber(childIC);
                    return parentObj;
                }
            }

        } catch (SQLException e) {
            printSQLException(e);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        return null;
    }
    
    public List<Beneficiary> selectBeneficiariesByStatus(String status) {
        List<Beneficiary> beneficiaries = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BENEFICIARIES_BY_STATUS)) {
            
            preparedStatement.setString(1, status);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                beneficiaries.add(mapResultSetToBeneficiary(rs));
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return beneficiaries;
    }
    
    public Beneficiary selectBeneficiaryByIC(String icNumber) {
        Beneficiary b = null;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BENEFICIARY_BY_IC)) {
            
            preparedStatement.setString(1, icNumber);
            ResultSet rs = preparedStatement.executeQuery();

            if (rs.next()) {
                b = mapResultSetToBeneficiary(rs);
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return b;
    }

    public Beneficiary selectBeneficiaryByID(String id) {
        Beneficiary b = null;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BENEFICIARY_BY_ID)) {
            
            preparedStatement.setString(1, id);
            ResultSet rs = preparedStatement.executeQuery();

            if (rs.next()) {
                b = mapResultSetToBeneficiary(rs);
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return b;
    }

    public List<Beneficiary> selectAllBeneficiaries() {
        List<Beneficiary> beneficiaries = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_BENEFICIARIES)) {
            
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                beneficiaries.add(mapResultSetToBeneficiary(rs));
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return beneficiaries;
    }

    private Beneficiary mapResultSetToBeneficiary(ResultSet rs) throws SQLException {
        Beneficiary b = new Beneficiary();
        b.setBeneficiaryID(rs.getString("BeneficiaryID"));
        b.setB_Name(rs.getString("B_Name"));
        b.setB_ICNumber(rs.getString("B_ICNumber"));
        b.setB_Race(rs.getString("B_Race"));
        b.setB_Religion(rs.getString("B_Religion"));
        b.setB_Nationality(rs.getString("B_Nationality"));
        b.setB_ContactNumber(rs.getString("B_ContactNumber"));
        b.setHouseholdSize(rs.getInt("HouseholdSize"));
        b.setStreet(rs.getString("Street"));
        b.setPostcode(rs.getInt("Postcode"));
        b.setB_OKUStatus(rs.getString("B_OKUStatus"));
        b.setB_DietPreference(rs.getString("B_DietPreference"));
        b.setB_HealthHistory(rs.getString("B_HealthHistory"));
        b.setB_Allergic(rs.getString("B_Allergic"));
        b.setB_Status(rs.getString("B_Status"));
        b.setRegisteredBy(rs.getString("RegisteredBy"));
        b.setDateRegistered(rs.getString("DateRegistered"));
        b.setShelterID(rs.getString("ShelterID"));
        b.setTentID(rs.getString("TentID"));
        
        return b;
    }

    // ================= HOUSEHOLD OPERATIONS =================

    public void insertHouseholdMember(Household h) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(INSERT_HOUSEHOLD_SQL)) {
            
            ps.setString(1, h.getBeneficiaryID());
            ps.setString(2, h.getH_Name());
            ps.setString(3, h.getH_IC());
            ps.setString(4, h.getH_Nationality());
            ps.setString(5, h.getH_Relationship());
            ps.setString(6, h.getH_OKUStatus());
            ps.setString(7, h.getH_HealthHistory());
            ps.setString(8, h.getH_Allergic());
            ps.setString(9, h.getH_DietPreference());
            ps.setString(10, h.getH_Status());
            ps.setString(11, h.getTentID());

            ps.executeUpdate();
            
            // --- NOTIFICATION TRIGGER: Capacity Warning ---
            String shelterID = null;
            try(PreparedStatement psS = connection.prepareStatement("SELECT ShelterID FROM beneficiary WHERE BeneficiaryID = ?")) {
                psS.setString(1, h.getBeneficiaryID());
                ResultSet rsS = psS.executeQuery();
                if(rsS.next()) shelterID = rsS.getString(1);
            }
            if(shelterID != null) checkShelterCapacityWarning(shelterID);
            
        } catch (SQLException e) {
            printSQLException(e);
        }
    }

    public boolean updateHouseholdMember(Household h) throws SQLException {
        boolean rowUpdated;
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(UPDATE_HOUSEHOLD_SQL)) {
            
            ps.setString(1, h.getH_Name());
            ps.setString(2, h.getH_IC());
            ps.setString(3, h.getH_Nationality());
            ps.setString(4, h.getH_Relationship());
            ps.setString(5, h.getH_OKUStatus());
            ps.setString(6, h.getH_HealthHistory());
            ps.setString(7, h.getH_Allergic());
            ps.setString(8, h.getH_DietPreference());
            ps.setString(9, h.getH_Status());
            ps.setString(10, h.getTentID());
            ps.setString(11, h.getHouseholdID()); 

            rowUpdated = ps.executeUpdate() > 0;
        }
        return rowUpdated;
    }

    public boolean deleteHouseholdMember(String householdID) throws SQLException {
        Household h = selectHouseholdByID(householdID);
        if (h != null) decrementTentOccupancy(h.getTentID());
        
        boolean rowDeleted;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(DELETE_HOUSEHOLD_SQL)) {
            
            preparedStatement.setString(1, householdID);
            rowDeleted = preparedStatement.executeUpdate() > 0;
        }
        return rowDeleted;
    }

    public List<Household> selectHouseholdByBeneficiaryID(String beneficiaryID) {
        List<Household> households = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_HOUSEHOLD_BY_BEN_ID)) {
            
            preparedStatement.setString(1, beneficiaryID);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                households.add(mapResultSetToHousehold(rs));
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return households;
    }

    public Household selectHouseholdByID(String householdID) {
        Household h = null;
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_HOUSEHOLD_BY_ID)) {
            
            preparedStatement.setString(1, householdID);
            ResultSet rs = preparedStatement.executeQuery();

            if (rs.next()) {
                h = mapResultSetToHousehold(rs);
            }
        } catch (SQLException e) {
            printSQLException(e);
        }
        return h;
    }
    
    private Household mapResultSetToHousehold(ResultSet rs) throws SQLException {
        Household h = new Household();
        h.setHouseholdID(rs.getString("HouseholdID"));
        h.setBeneficiaryID(rs.getString("BeneficiaryID"));
        h.setH_Name(rs.getString("H_Name"));
        h.setH_IC(rs.getString("H_ICNumber"));
        h.setH_Nationality(rs.getString("H_Nationality"));
        h.setH_Relationship(rs.getString("Relationship"));
        h.setH_OKUStatus(rs.getString("H_OKUStatus"));
        h.setH_HealthHistory(rs.getString("H_HealthHistory"));
        h.setH_Allergic(rs.getString("H_Allergic"));
        h.setH_DietPreference(rs.getString("H_DietPreferences"));
        h.setH_Status(rs.getString("H_status"));
        h.setTentID(rs.getString("TentID"));
        return h;
    }

    public String[] getCityStateByPostcode(String postcode) {
        String[] result = new String[2];
        String query = "SELECT City, State FROM address WHERE Postcode = ?";

        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, postcode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result[0] = rs.getString("City");
                    result[1] = rs.getString("State");
                    return result;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public boolean isICAlreadyActive(String icNumber) {
        String cleanIC = icNumber.replace("-", "").trim();

        String sqlBene = "SELECT 1 FROM beneficiary WHERE REPLACE(B_ICNumber, '-', '') = ? " +
                         "AND B_status IN ('Active', 'Pending')";

        String sqlHouse = "SELECT 1 FROM household WHERE REPLACE(H_ICNumber, '-', '') = ? " +
                          "AND H_status IN ('ADMITTED', 'PENDING', 'EXTERNAL_SHELTER')";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlBene)) {
                ps.setString(1, cleanIC);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return true; 
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlHouse)) {
                ps.setString(1, cleanIC);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // FIXED: Fetch only active beneficiaries FOR THE CURRENT DISASTER
    public List<Beneficiary> selectActiveBeneficiaries() {
        List<Beneficiary> beneficiaries = new ArrayList<>();
        
        // JOIN shelter table to ensure DateRegistered is ON or AFTER the Shelter ActivationDate
        String sql = "SELECT b.* FROM beneficiary b " +
                     "LEFT JOIN shelter s ON b.ShelterID = s.ShelterID " +
                     "WHERE b.B_status = 'Active' AND (s.ActivationDate IS NULL OR DATE(b.DateRegistered) >= DATE(s.ActivationDate)) " +
                     "ORDER BY b.BeneficiaryID DESC";
        
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                beneficiaries.add(mapResultSetToBeneficiary(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return beneficiaries;
    }
    
    private void printSQLException(SQLException ex) {
        for (Throwable e : ex) {
            if (e instanceof SQLException) {
                e.printStackTrace(System.err);
                System.err.println("SQLState: " + ((SQLException) e).getSQLState());
                System.err.println("ErrorCode: " + ((SQLException) e).getErrorCode());
                System.err.println("Message: " + ((SQLException) e).getMessage());
                Throwable t = ex.getCause();
                while (t != null) {
                    System.out.println("Cause: " + t);
                    t = t.getCause();
                }
            }
        }
    }
}