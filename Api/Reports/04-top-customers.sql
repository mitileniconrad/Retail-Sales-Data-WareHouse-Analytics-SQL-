WITH Spend AS (
    SELECT c.Customer_ID,
           c.First_Name + ' ' + c.Last_Name AS Customer,
           c.City,
           COUNT(*) AS Orders,
           SUM(s.Total_Amount) AS Total_Spent,
           MAX(s.Sale_Date) AS Last_Purchase
    FROM Customer c
    JOIN Sales s ON s.Customer_ID = c.Customer_ID
    GROUP BY c.Customer_ID, c.First_Name, c.Last_Name, c.City
)
SELECT TOP 20 Customer, City, Orders,
       CAST(Total_Spent AS DECIMAL(12,2)) AS Total_Spent,
       CAST(Total_Spent / Orders AS DECIMAL(10,2)) AS Avg_Order,
       Last_Purchase,
       NTILE(4) OVER (ORDER BY Total_Spent DESC) AS Spend_Quartile
FROM Spend
ORDER BY Total_Spent DESC;
