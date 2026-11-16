SELECT b.Branch_Name, e.Full_Name, e.Job_Title,
       COUNT(s.Sale_ID) AS Sales,
       CAST(ISNULL(SUM(s.Total_Amount), 0) AS DECIMAL(12,2)) AS Revenue,
       RANK() OVER (PARTITION BY b.Branch_Name ORDER BY ISNULL(SUM(s.Total_Amount), 0) DESC) AS Rank_In_Branch
FROM Employees e
JOIN Branches b ON b.Branch_ID = e.Branch_ID
LEFT JOIN Sales s ON s.Employee_ID = e.Employee_ID
GROUP BY b.Branch_Name, e.Full_Name, e.Job_Title
ORDER BY b.Branch_Name, Rank_In_Branch;
