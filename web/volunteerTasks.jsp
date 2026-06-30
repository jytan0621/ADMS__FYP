<%-- Document: volunteerTasks.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Model.User" %>
<%@ page import="com.Model.TentTask" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect("index.jsp"); return; }
    
    // Retrieve ALL lists from the Servlet
    Map<String, TentTask> taskMap = (Map<String, TentTask>) request.getAttribute("dailyTasks");
    Map<String, TentTask> completedMap = (Map<String, TentTask>) request.getAttribute("completedTasks");
    Set<String> completedDailySet = (Set<String>) request.getAttribute("completedDaily");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ADMS - Distribution Tasks</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CORE STYLES */
        body { 
            margin: 0; 
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif; 
            background-color: #f8fafc; 
            color: #1e293b;
            min-height: 100vh;
        }
        .fixed-header { 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            height: 60px; 
            z-index: 50; 
            background-color: #0b5ea8; 
            color: white; 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            padding: 0 24px; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
        }
        .main-content-scrollable { 
            padding: 90px 24px 60px 24px; 
            min-height: 100vh; 
            box-sizing: border-box; 
            background-color: #f8fafc; 
        }
        .form-card { 
            background: white; 
            width: 100%; 
            max-width: 1024px; 
            margin: 0 auto; 
            padding: 30px; 
            border-radius: 8px; 
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); 
            border: 1px solid #e2e8f0; 
            box-sizing: border-box;
        }
        .page-title { 
            font-size: 28px; 
            font-weight: 600; 
            color: #0f172a; 
            margin: 0 0 20px 0;
        }
        
        /* TABS STYLING */
        .tabs { 
            display: flex; 
            gap: 10px; 
            margin-bottom: 25px; 
            border-bottom: 2px solid #e2e8f0; 
        }
        .tab-btn { 
            padding: 12px 20px; 
            border: none; 
            background: none; 
            font-size: 15px; 
            font-weight: 600; 
            color: #64748b; 
            cursor: pointer; 
            border-bottom: 3px solid transparent; 
            margin-bottom: -2px; 
            transition: all 0.2s ease; 
        }
        .tab-btn:hover { color: #0b5ea8; }
        .tab-btn.active { color: #0b5ea8; border-bottom-color: #0b5ea8; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* TENT TASK STYLES */
        .tent-box { 
            border: 1px solid #cbd5e1; 
            border-radius: 8px; 
            margin-bottom: 24px; 
            background: white; 
            overflow: hidden; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.05); 
        }
        .tent-box-header { 
            background-color: #f8fafc; 
            border-bottom: 1px solid #cbd5e1; 
            padding: 14px 20px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }
        .tent-title { font-size: 18px; font-weight: 700; color: #0f172a; margin: 0; }
        .tent-pop { 
            background: #e0f2fe; 
            color: #0284c7; 
            padding: 4px 12px; 
            border-radius: 20px; 
            font-size: 13px; 
            font-weight: 600; 
            border: 1px solid #bae6fd; 
        }
        .tent-body { 
            padding: 20px; 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 24px; 
        }
        @media (max-width: 768px) { 
            .tent-body { grid-template-columns: 1fr; gap: 20px; } 
        }
        
        .section-title { 
            color: #475569; 
            font-size: 13px; 
            font-weight: 700; 
            text-transform: uppercase; 
            margin-bottom: 12px; 
            letter-spacing: 0.5px; 
            border-bottom: 1px solid #e2e8f0; 
            padding-bottom: 6px; 
        }
        .aid-list { list-style: none; padding: 0; margin: 0; }
        .aid-list li { 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            padding: 8px 0; 
            border-bottom: 1px dashed #e2e8f0; 
            color: #334155; 
            font-size: 15px; 
        }
        .aid-list li:last-child { border-bottom: none; }
        
        /* THE BADGES (Color Specific) */
        .qty-badge-daily { font-weight: 700; color: #0ea5e9; font-size: 16px; }
        .qty-badge-kit { font-weight: 700; color: #f59e0b; font-size: 16px; }
        
        /* COMPLETED VIEW ENCLOSED BOXES */
        .entry-kit-box { 
            background-color: #fff7ed; 
            padding: 16px; 
            border-radius: 6px; 
            border: 1px solid #ffedd5; 
            height: 100%; 
            box-sizing: border-box; 
        }
        .entry-kit-box .section-title { color: #c2410c; border-bottom-color: #fed7aa; }
        
        /* ACTIONS */
        .btn-save { 
            color: white; 
            width: 100%; 
            padding: 12px; 
            border: none; 
            border-radius: 6px;
            font-size: 15px; 
            cursor: pointer; 
            font-weight: 600; 
            transition: opacity 0.2s ease; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            gap: 8px; 
            box-sizing: border-box;
        }
        .btn-save:hover { opacity: 0.9; }
        
        .empty-state { text-align: center; padding: 40px 20px; color: #64748b; }
        .empty-state i { font-size: 40px; color: #cbd5e1; margin-bottom: 12px; }
        .exit-btn { 
            background: #ef4444; 
            color: white; 
            text-decoration: none; 
            padding: 6px 12px; 
            border-radius: 4px; 
            font-weight: 600; 
            font-size: 14px;
            margin-left: 12px; 
            transition: background-color 0.2s ease; 
        }
        .exit-btn:hover { background: #dc2626; }
    </style>
    
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById(tabId).classList.add('active');
            event.currentTarget.classList.add('active');
        }
    </script>
</head>
<body>

    <header class="fixed-header">
        <div style="display: flex; align-items: center; gap: 12px;">
            <img src="Image/Logo_ADMS.png" alt="Logo" style="height:24px;">
            <span style="font-size: 20px; font-weight: bold; letter-spacing: 0.5px;">ADMS</span>
        </div>
        <div style="display: flex; align-items: center;">
            <div style="font-weight: 500; font-size: 14px; background: rgba(255,255,255,0.1); padding: 4px 12px; border-radius: 4px;">
                <%= currentUser.getUserName() %> | <%= session.getAttribute("myShelterID") %>
            </div>
            <a href="LogoutServlet" class="exit-btn"><i class="fas fa-sign-out-alt"></i> Exit</a>
        </div>
    </header>

    <div class="main-content-scrollable">
        <div class="form-card">
            
            <% 
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("true".equals(success)) { 
            %>
                <div style="background-color: #dcfce7; color: #166534; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #bbf7d0; text-align: center;">
                    <i class="fas fa-check-circle"></i> Tent delivery confirmed successfully!
                </div>
            <%  } else if ("true".equals(error) || "missingData".equals(error)) { %>
                <div style="background-color: #fee2e2; color: #991b1b; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #fecaca; text-align: center;">
                    <i class="fas fa-exclamation-circle"></i> Failed to confirm delivery. Database error.
                </div>
            <%  } %>

            <h1 class="page-title"><i class="fas fa-clipboard-list" style="color: #0b5ea8; margin-right: 10px;"></i> Distribution Checklist</h1>

            <div class="tabs">
                <button class="tab-btn active" onclick="switchTab('pending')">
                    <i class="fas fa-tasks"></i> Pending Tasks
                </button>
                <button class="tab-btn" onclick="switchTab('completed')">
                    <i class="fas fa-check-double"></i> Completed Today
                </button>
            </div>

            <div id="pending" class="tab-content active">
                <% if (taskMap != null && !taskMap.isEmpty()) { 
                    for (TentTask task : taskMap.values()) { 
                        boolean isDailyDone = completedDailySet != null && completedDailySet.contains(task.getTentID());
                %>
                    <div class="tent-box">
                        <div class="tent-box-header">
                            <h2 class="tent-title">Tent <%= task.getTentID() %></h2>
                            <span class="tent-pop"><i class="fas fa-users"></i> <%= task.getPopulation() %> Residents</span>
                        </div>
                        
                        <div class="tent-body">
                            <div style="display: flex; flex-direction: column; justify-content: space-between;">
                                <div>
                                    <div class="section-title"><i class="fas fa-box-open"></i> Daily Rations</div>
                                    
                                    <% if (isDailyDone) { %>
                                        <p style="color: #10b981; font-weight: bold; margin-bottom: 20px; padding: 8px 0;"><i class="fas fa-check-circle"></i> Daily Delivered Today</p>
                                    <% } else if (!task.getDailyItems().isEmpty()) { %>
                                        <ul class="aid-list mb-3">
                                            <% for (Map<String, Object> item : task.getDailyItems()) { %>
                                                <li><span><%= item.get("name") %></span><span class="qty-badge-daily">x<%= item.get("totalQty") %></span></li>
                                            <% } %>
                                        </ul>
                                        <form action="confirmTentDelivery" method="POST" style="margin: 0; margin-top: 15px;">
                                            <input type="hidden" name="tentID" value="<%= task.getTentID() %>">
                                            <button type="submit" class="btn-save" style="background-color: #0ea5e9;">
                                                <i class="fas fa-check"></i> Deliver Daily Rations
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <p style="color: #94a3b8; font-style: italic; margin-bottom: 20px; padding: 8px 0;">No daily rules configured.</p>
                                    <% } %>
                                </div>
                            </div>

                            <div style="display: flex; flex-direction: column; justify-content: space-between;">
                                <div>
                                    <div class="section-title" style="color: #c2410c; border-bottom-color: #fed7aa;"><i class="fas fa-gift"></i> New Arrival Kits</div>
                                    
                                    <% if (!task.getEntryItems().isEmpty()) { %>
                                        <ul class="aid-list mb-3">
                                            <% for (Map<String, Object> kit : task.getEntryItems()) { %>
                                                <li><span><%= kit.get("name") %></span><span class="qty-badge-kit">x<%= kit.get("totalQty") %></span></li>
                                            <% } %>
                                        </ul>
                                        <form action="confirmOneOffDelivery" method="POST" style="margin: 0; margin-top: 15px;">
                                            <input type="hidden" name="tentID" value="<%= task.getTentID() %>">
                                            <button type="submit" class="btn-save" style="background-color: #f59e0b;" onclick="return confirm('Confirm WELCOME KIT delivery to Tent <%= task.getTentID() %>?');">
                                                <i class="fas fa-box"></i> Deliver Welcome Kit
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <p style="color: #10b981; font-weight: bold; margin-bottom: 20px; padding: 8px 0;"><i class="fas fa-check-circle"></i> Kit Already Received</p>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } } else { %>
                    <div class="empty-state">
                        <i class="fas fa-check-double"></i>
                        <h3 style="color: #334155; margin-bottom: 8px;">All Caught Up!</h3>
                        <p>There are no pending deliveries for this shelter at the moment.</p>
                    </div>
                <% } %>
            </div>

            <div id="completed" class="tab-content">
                
                <div style="margin-bottom: 40px;">
                    <h3 style="color: #475569; font-size: 16px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 15px; border-bottom: 2px solid #cbd5e1; padding-bottom: 5px;">
                        <i class="fas fa-utensils" style="color: #0ea5e9;"></i> Daily Rations Delivered Today
                    </h3>
                    
                    <% 
                        boolean hasDailyCompleted = false;
                        if (completedMap != null && !completedMap.isEmpty()) { 
                            for (TentTask task : completedMap.values()) { 
                                boolean isTaskDailyDone = completedDailySet != null && completedDailySet.contains(task.getTentID());
                                if (isTaskDailyDone) {
                                    hasDailyCompleted = true;
                    %>
                                    <div class="tent-box" style="border-left: 4px solid #0ea5e9; margin-bottom: 15px;">
                                        <div class="tent-box-header" style="background-color: #f8fafc;">
                                            <h2 class="tent-title" style="color: #475569;">Tent <%= task.getTentID() %></h2>
                                            <span class="tent-pop" style="background: #e2e8f0; color: #475569; border-color: #cbd5e1;"><i class="fas fa-users"></i> <%= task.getPopulation() %> Residents</span>
                                        </div>
                                        <div class="tent-body" style="padding: 15px 20px; display: flex; justify-content: space-between; align-items: center;">
                                            <div style="flex-grow: 1;">
                                                <ul class="aid-list">
                                                    <% if (!task.getDailyItems().isEmpty()) { 
                                                            for (Map<String, Object> item : task.getDailyItems()) { %>
                                                                <li><span><%= item.get("name") %></span><span class="qty-badge" style="color: #64748b;">x<%= item.get("totalQty") %></span></li>
                                                    <%      } 
                                                       } else { %>
                                                            <li><span style="color:#64748b;">Daily Rations Logged</span><span class="qty-badge" style="color: #10b981;"><i class="fas fa-check"></i></span></li>
                                                    <% } %>
                                                </ul>
                                            </div>
                                            <div style="text-align: right; margin-left: 30px; min-width: 220px;">
                                                <span style="color: #166534; background-color: #dcfce7; padding: 6px 12px; border-radius: 4px; font-weight: bold; font-size: 13px; display: inline-block; border: 1px solid #bbf7d0;">
                                                    <i class="fas fa-server"></i> Verified in Outgoing Log
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                    <% 
                                }
                            }
                        } 
                        if (!hasDailyCompleted) { 
                    %>
                        <div style="background: #f1f5f9; text-align: center; padding: 20px; border-radius: 6px; color: #64748b; border: 1px dashed #cbd5e1;">
                            No daily rations have been logged as delivered yet today.
                        </div>
                    <% } %>
                </div>

                <div>
                    <h3 style="color: #475569; font-size: 16px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 15px; border-bottom: 2px solid #cbd5e1; padding-bottom: 5px;">
                        <i class="fas fa-gift" style="color: #f59e0b;"></i> Welcome Kits Distributed
                    </h3>
                    
                    <% 
                        boolean hasKitsCompleted = false;
                        if (completedMap != null && !completedMap.isEmpty()) { 
                            for (TentTask task : completedMap.values()) { 
                                if (!task.getEntryItems().isEmpty()) {
                                    hasKitsCompleted = true;
                    %>
                                    <div class="tent-box" style="border-left: 4px solid #f59e0b; margin-bottom: 15px;">
                                        <div class="tent-box-header" style="background-color: #f8fafc;">
                                            <h2 class="tent-title" style="color: #475569;">Tent <%= task.getTentID() %></h2>
                                            <span class="tent-pop" style="background: #e2e8f0; color: #475569; border-color: #cbd5e1;"><i class="fas fa-users"></i> <%= task.getPopulation() %> Residents</span>
                                        </div>
                                        <div class="tent-body" style="padding: 15px 20px; display: flex; justify-content: space-between; align-items: center;">
                                            <div style="flex-grow: 1;">
                                                <div class="entry-kit-box" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 10px 15px; border-radius: 6px;">
                                                    <ul class="aid-list" style="margin: 0; padding: 0;">
                                                        <% for (Map<String, Object> kit : task.getEntryItems()) { %>
                                                            <li style="display: flex; align-items: center; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #cbd5e1;">
                                                                <div style="display: flex; align-items: center; gap: 12px;">
                                                                    <i class="fas fa-check-square" style="color: #10b981; font-size: 20px;"></i>
                                                                    <span style="text-decoration: line-through; color: #64748b; font-weight: 500;"><%= kit.get("name") %></span>
                                                                </div>
                                                                <span class="qty-badge" style="color: #94a3b8; text-decoration: line-through;">x<%= kit.get("totalQty") %></span>
                                                            </li>
                                                        <% } %>
                                                    </ul>
                                                </div>
                                            </div>
                                            <div style="text-align: right; margin-left: 30px; min-width: 220px;">
                                                <span style="color: #b45309; background-color: #fef3c7; padding: 6px 12px; border-radius: 4px; font-weight: bold; font-size: 13px; display: inline-block; border: 1px solid #fde68a;">
                                                    <i class="fas fa-id-card"></i> Logged in Beneficiary Profile
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                    <% 
                                }
                            }
                        } 
                        if (!hasKitsCompleted) { 
                    %>
                        <div style="background: #f1f5f9; text-align: center; padding: 20px; border-radius: 6px; color: #64748b; border: 1px dashed #cbd5e1;">
                            No new arrival welcome kits have been distributed yet.
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
    </div>

</body>
</html>