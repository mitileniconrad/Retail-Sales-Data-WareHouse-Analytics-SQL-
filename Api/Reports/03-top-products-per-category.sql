WITH Product_Profit AS (
    SELECT c.Category_name, 
    p.Product_Name,
           SUM(si.Quantity) AS Units_Sold, 
           SUM(si.Quantity *  (si.Unit_Price - p.Cost_Price)) AS Profit
    FROM Sale_Items si
    JOIN Products p   ON p.Product_ID   = si.Product_ID
    JOIN Categories c ON c.Category_ID =  p.Category_ID
    GROUP BY c.Category_name, p.Product_Name
),

Ranked AS (

    SELECT *, RANK() OVER (PARTITION BY Category_name ORDER BY Profit DESC) AS Rank_In_Category
    FROM Product_Profit

)
SELECT Category_name, Rank_In_Category, Product_Name, Units_Sold,

       CAST(Profit AS DECIMAL(12,2)) AS Profit

FROM Ranked
WHERE Rank_In_Category <= 3

ORDER BY Category_name, Rank_In_Category;
