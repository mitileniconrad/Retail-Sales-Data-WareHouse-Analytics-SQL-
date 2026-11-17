Use Data_Warehouse

DELETE FROM Sale_Items WHERE Sale_ID > 10;
DELETE FROM Sales      WHERE Sale_ID > 10;
DELETE FROM Products   WHERE Product_ID > 10;
DELETE FROM Customer   WHERE Customer_ID > 8;
DELETE FROM Employees  WHERE Employee_ID > 6;
DELETE FROM Branches   WHERE Branch_ID > 3;

-- Check: expect Branches 3, Employees 6, Products 10, Customers 8, Sales 10, Sale_Items 19
SELECT (SELECT COUNT(*) FROM Branches)   AS Branches,
       (SELECT COUNT(*) FROM Employees)  AS Employees,
       (SELECT COUNT(*) FROM Products)   AS Products,
       (SELECT COUNT(*) FROM Customer)   AS Customers,
       (SELECT COUNT(*) FROM Sales)      AS Sales,
       (SELECT COUNT(*) FROM Sale_Items) AS Sale_Items;
