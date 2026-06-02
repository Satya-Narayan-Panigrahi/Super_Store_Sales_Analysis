CREATE DATABASE super_store_data;
USE super_store_data;
SELECT * FROM superstore;
-- ============================================================
-- SUPERSTORE SALES DASHBOARD - MySQL Queries
-- Dataset: superstore_dataset2011-2015
-- ============================================================

-- Assumed table name: superstore
-- Assumed column names (matching CSV headers):
--   Category, Profit, Region, Sales, `Order Date`, `Ship Mode`


-- ============================================================
-- HYPOTHESIS 1:
-- Technology products have the highest profit margin
-- compared to other product categories.
-- ============================================================

SELECT
    Category,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Conclusion: Supported — Technology has the highest total profit
--             among all three categories.


-- ============================================================
-- HYPOTHESIS 2:
-- The East region has the highest sales compared to other regions.
-- ============================================================

SELECT
    Region,
    SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Conclusion: NOT supported — the West region has the highest sales,
--             not the East region.


-- ============================================================
-- HYPOTHESIS 3:
-- Sales are higher during certain months of the year.
-- ============================================================

SELECT
    MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))  AS Order_Month,
    SUM(Sales)                                     AS Total_Sales
FROM superstore
GROUP BY Order_Month
ORDER BY Order_Month;

-- Conclusion: Supported — sales peak in November and December,
--             confirming seasonal variation.

-- NOTE: Adjust the STR_TO_DATE format string to match your CSV's
--       actual date format, e.g. '%d/%m/%Y' or '%Y-%m-%d'.


-- ============================================================
-- HYPOTHESIS 4:
-- Orders with same-day shipping have the lowest rate
-- of returned products.
-- (Negative profit is used as a proxy for returned orders.)
-- ============================================================

SELECT
    s.`Ship Mode`,
    COUNT(*)                                              AS Total_Orders,
    SUM(CASE WHEN s.Profit < 0 THEN 1 ELSE 0 END)        AS Returned_Orders,
    ROUND(
        SUM(CASE WHEN s.Profit < 0 THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
    2)                                                    AS Return_Percentage
FROM superstore s
GROUP BY s.`Ship Mode`
ORDER BY Return_Percentage ASC;

-- Conclusion: Supported — Same Day shipping has the lowest
--             return (negative-profit) percentage.


-- ============================================================
-- HYPOTHESIS 5:
-- The company's profit is more on weekdays than on weekends.
-- ============================================================

-- Part A – Profit broken down by individual day of the week
SELECT
    DAYNAME(STR_TO_DATE(`Order Date`, '%m/%d/%Y'))  AS Order_Day,
    SUM(Profit)                                      AS Total_Profit
FROM superstore
GROUP BY Order_Day
ORDER BY FIELD(
    Order_Day,
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
);

-- Part B – Weekday vs Weekend comparison (summary)
SELECT
    CASE
        WHEN DAYOFWEEK(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) IN (1, 7)
             THEN 'Weekend'
        ELSE 'Weekday'
    END                AS Day_Type,
    SUM(Profit)        AS Total_Profit,
    COUNT(*)           AS Total_Orders,
    ROUND(AVG(Profit), 2) AS Avg_Profit_Per_Order
FROM superstore
GROUP BY Day_Type;

-- Conclusion: Supported — total and average profit is higher
--             on weekdays than on weekends.

-- NOTE: DAYOFWEEK() returns 1 = Sunday, 7 = Saturday in MySQL.
--       Adjust the STR_TO_DATE format to match your actual date format.


