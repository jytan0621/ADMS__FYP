/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.WEB;

import com.DAO.BeneficiaryAnalysisDAO;
import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/BeneficiaryAnalysis")
public class BeneficiaryAnalysisServlet extends HttpServlet {

    private BeneficiaryAnalysisDAO dao;

    public void init() {
        dao = new BeneficiaryAnalysisDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Map<String, String>> allPeople = dao.getAllIndividuals();

        // 1. Initialize Detailed Counters
        int babyM = 0, babyF = 0;
        int childM = 0, childF = 0;
        int adultM = 0, adultF = 0;
        int seniorM = 0, seniorF = 0;

        int totalMale = 0, totalFemale = 0;
        int okuCount = 0, activeCount = 0, dischargedCount = 0;
        
        Map<String, Integer> admissionTrend = new TreeMap<String, Integer>();
        int currentYear = 2026; 

        for (Map<String, String> p : allPeople) {
            String ic = p.get("IC");
            String oku = p.get("OKU");
            String status = p.get("Status");
            String rawDate = p.get("Date");

            // --- Status & OKU ---
            if (status != null && status.toUpperCase().contains("DISCHARGED")) dischargedCount++; else activeCount++;
            if ("Yes".equalsIgnoreCase(oku)) okuCount++;

            // --- Trend Logic ---
            if (rawDate != null && rawDate.length() >= 10) {
                String cleanDate = rawDate.substring(0, 10);
                if (admissionTrend.containsKey(cleanDate)) {
                    admissionTrend.put(cleanDate, admissionTrend.get(cleanDate) + 1);
                } else {
                    admissionTrend.put(cleanDate, 1);
                }
            }

            // --- Detailed Age & Gender Logic ---
            if (ic != null) {
                String cleanIC = ic.replace("-", "").trim();
                if (cleanIC.length() >= 12) {
                    try {
                        // 1. Determine Gender
                        boolean isMale = false;
                        char lastChar = cleanIC.charAt(cleanIC.length() - 1);
                        if (Character.isDigit(lastChar)) {
                            if (Character.getNumericValue(lastChar) % 2 != 0) {
                                isMale = true;
                                totalMale++;
                            } else {
                                totalFemale++;
                            }
                        }

                        // 2. Determine Age
                        int yy = Integer.parseInt(cleanIC.substring(0, 2));
                        int birthYear = (yy > (currentYear % 100)) ? (1900 + yy) : (2000 + yy);
                        int age = currentYear - birthYear;

                        // 3. Increment Specific Counter
                        if (age >= 0 && age <= 2) {
                            if (isMale) babyM++; else babyF++;
                        } else if (age >= 3 && age <= 12) {
                            if (isMale) childM++; else childF++;
                        } else if (age >= 60) {
                            if (isMale) seniorM++; else seniorF++;
                        } else {
                            // Default to Adult (13-59)
                            if (isMale) adultM++; else adultF++;
                        }

                    } catch (Exception e) {}
                }
            }
        }

        // --- Prepare JSON Data Strings ---
        
        // 1. Demographics Data (Male Array vs Female Array)
        // Order: [Baby, Child, Adult, Senior]
        String maleAgeData = "[" + babyM + "," + childM + "," + adultM + "," + seniorM + "]";
        String femaleAgeData = "[" + babyF + "," + childF + "," + adultF + "," + seniorF + "]";
        String genderTotalData = "[" + totalMale + "," + totalFemale + "]";

        // 2. Trend Data (Manual JSON Builder)
        StringBuilder datesBuilder = new StringBuilder("[");
        StringBuilder valuesBuilder = new StringBuilder("[");
        int count = 0;
        for (Map.Entry<String, Integer> entry : admissionTrend.entrySet()) {
            datesBuilder.append("\"").append(entry.getKey()).append("\"");
            valuesBuilder.append(entry.getValue());
            if (count < admissionTrend.size() - 1) { datesBuilder.append(","); valuesBuilder.append(","); }
            count++;
        }
        datesBuilder.append("]");
        valuesBuilder.append("]");

        // --- Send to JSP ---
        request.setAttribute("maleAgeData", maleAgeData);
        request.setAttribute("femaleAgeData", femaleAgeData);
        request.setAttribute("genderTotalData", genderTotalData);
        
        request.setAttribute("datesLabels", datesBuilder.toString());
        request.setAttribute("admissionValues", valuesBuilder.toString());
        
        // KPI Cards
        request.setAttribute("cActive", activeCount);
        request.setAttribute("cDischarged", dischargedCount);
        request.setAttribute("cOKU", okuCount);
        request.setAttribute("cSenior", (seniorM + seniorF));

        request.getRequestDispatcher("BeneficiaryAnalysis.jsp").forward(request, response);
    }
}