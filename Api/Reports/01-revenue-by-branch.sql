-- Title: Revenue and profit by branch
-- Description: Four-table JOIN with SUM and COUNT DISTINCT, plus a profit margin calculation.
SELECT b.Branch_Name,
       COUNT(DISTINCT s.Sale_ID) AS Sales,
       CAST(SUM(si.Quantity * si.Unit_Price) AS DECIMAL(12,2)) AS Revenue,
       CAST(SUM(si.Quantity * (si.Unit_Price - p.Cost_Price)) AS DECIMAL(12,2)) AS Profit,
       CAST(100.0 * SUM(si.Quantity * (si.Unit_Price - p.Cost_Price))
            / SUM(si.Quantity * si.Unit_Price) AS DECIMAL(5,2)) AS Margin_Pct
FROM Branches b
JOIN Sales s       ON s.Branch_ID  = b.Branch_ID
JOIN Sale_Items si ON si.Sale_ID   = s.Sale_ID
JOIN Products p    ON p.Product_ID = si.Product_ID
GROUP BY b.Branch_Name
ORDER BY Revenue DESC;
