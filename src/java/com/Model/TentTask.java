/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Model;
import java.util.*;


/**
 *
 * @author User
 */
public class TentTask {

    private String tentID;
    private int population;
    private List<Map<String, Object>> dailyItems = new ArrayList<>();
    private List<Map<String, Object>> entryItems = new ArrayList<>();

    public TentTask(String tentID, int population) {
        this.tentID = tentID;
        this.population = population;
    }

    public TentTask() {
    }

    public String getTentID() {
        return tentID;
    }

    public void setTentID(String tentID) {
        this.tentID = tentID;
    }

    public int getPopulation() {
        return population;
    }

    public void setPopulation(int population) {
        this.population = population;
    }

    public List<Map<String, Object>> getDailyItems() {
        return dailyItems;
    }

    public void setDailyItems(List<Map<String, Object>> dailyItems) {
        this.dailyItems = dailyItems;
    }

    public List<Map<String, Object>> getEntryItems() {
        return entryItems;
    }

    public void setEntryItems(List<Map<String, Object>> entryItems) {
        this.entryItems = entryItems;
    }

    public void addDailyItem(String name, int qty) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("totalQty", qty);
        dailyItems.add(item);
    }
}

