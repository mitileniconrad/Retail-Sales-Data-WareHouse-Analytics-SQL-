SELECT TOP 50 c.Customer_ID, c.First_Name, c.Last_Name, c.City, c.Joined_Date
FROM Customer c
LEFT JOIN Sales s ON s.Customer_ID = c.Customer_ID
WHERE s.Sale_ID IS NULL
ORDER BY c.Joined_Date;
