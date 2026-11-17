SET NOCOUNT ON;

-- ==========================================  

-- 1. CLEANUP (Ordered by Foreign Key Hierarchy)
-- ==========================================
DELETE FROM Sale_Items;
DELETE FROM Sales;
DELETE FROM Products    WHERE Product_ID > 10;
DELETE FROM Customer    WHERE Customer_ID > 8;
DELETE FROM Employees   WHERE Employee_ID > 6;
DELETE FROM Branches    WHERE Branch_ID > 3;

-- ==========================================
-- 2. BRANCHES (Expanded & Idempotent)
-- ==========================================
IF NOT EXISTS (SELECT 1 FROM Branches WHERE Branch_ID = 4)
    INSERT INTO Branches (Branch_ID, Branch_Name, Location) VALUES (4, 'Pretoria East', 'Pretoria');

IF NOT EXISTS (SELECT 1 FROM Branches WHERE Branch_ID = 5)
    INSERT INTO Branches (Branch_ID, Branch_Name, Location) VALUES (5, 'Gqeberha Mall', 'Gqeberha');

IF NOT EXISTS (SELECT 1 FROM Branches WHERE Branch_ID = 6)
    INSERT INTO Branches (Branch_ID, Branch_Name, Location) VALUES (6, 'J CBD Mall', 'Johannesburg');

-- ==========================================
-- 3. EMPLOYEES (Manager + Staff for Branches 1 to 6)
-- ==========================================
INSERT INTO Employees (Employee_ID, Branch_ID, Full_Name, Job_Title, Hire_Date) VALUES
(7,  1, 'Sizwe Mahlangu',    'Sales Associate', '2021-02-15'),
(8,  1, 'Hannah Pretorius', 'Cashier',         '2023-05-08'),
(9,  2, 'Aisha Jacobs',      'Sales Associate', '2022-03-14'),
(10, 2, 'Luyanda Mthembu',   'Cashier',         '2024-02-19'),
(11, 3, 'Kevin Govender',    'Sales Associate', '2022-09-05'),
(12, 3, 'Zodwa Mkhize',      'Cashier',         '2024-06-03'),
(13, 4, 'Annelie Venter',    'Branch Manager',  '2020-08-17'),
(14, 4, 'Tumelo Molefe',     'Sales Associate', '2022-01-24'),
(15, 4, 'Jaco Kruger',       'Sales Associate', '2023-03-13'),
(16, 4, 'Nandi Radebe',      'Cashier',         '2024-07-22'),
(17, 5, 'Wayne Jacobs',      'Branch Manager',  '2021-10-04'),
(18, 5, 'Lindiwe Baloyi',    'Sales Associate', '2022-11-14'),
(19, 5, 'Chris Fourie',      'Sales Associate', '2023-09-18'),
(20, 5, 'Asanda Ngcobo',     'Cashier',         '2024-04-29'),
(21, 6, 'Pieter van Wyk',    'Branch Manager',  '2020-05-11'),
(22, 6, 'Nomvula Dlamini',   'Sales Associate', '2022-08-20'),
(23, 6, 'Sipho Khumalo',     'Cashier',         '2023-11-15');

-- ==========================================
-- 4. PRODUCTS (Expanded Catalog)
-- ==========================================
INSERT INTO Products (Product_ID, Supplier_ID, Category_ID, Product_Name, Cost_Price, List_Price) VALUES
(11, 1, 1, 'Wireless Keyboard',            220.00, 399.99),
(12, 1, 1, 'Phone Charger 20W',              85.00, 169.99),
(13, 1, 1, 'Bluetooth Earbuds',            190.00, 349.99),
(14, 1, 1, 'Power Bank 10000mAh',          160.00, 289.99),
(15, 1, 1, 'HDMI Cable 2m',                   45.00,  99.99),
(16, 1, 1, 'Webcam 1080p',                  280.00, 499.99),
(17, 1, 1, 'USB Flash Drive 64GB',          55.00, 109.99),
(18, 1, 1, 'Laptop Stand',                 150.00, 279.99),
(19, 1, 1, 'Bluetooth Speaker',            250.00, 459.99),
(20, 1, 1, 'Smart Watch Basic',            450.00, 799.99),
(21, 2, 2, 'Cutlery Set 24pc',             160.00, 299.99),
(22, 2, 2, 'Glass Storage Containers 5pc',  95.00, 179.99),
(23, 2, 2, 'Bath Towel Set',               140.00, 259.99),
(24, 2, 2, 'Chef Knife 8in',               110.00, 199.99),
(25, 2, 2, 'Toaster 2-Slice',              210.00, 389.99),
(26, 2, 2, 'Cotton Bed Sheet Set',         230.00, 449.99),
(27, 2, 2, 'Laundry Basket',                  45.00,  89.99),
(28, 2, 2, 'Non-Stick Frying Pan 28cm',    130.00, 239.99),
(29, 3, 3, 'Basmati Rice 2kg',               38.00,  69.99),
(30, 3, 3, 'Sunflower Oil 750ml',            28.00,  49.99),
(31, 3, 3, 'Maize Meal 5kg',                 42.00,  74.99),
(32, 3, 3, 'Buttermilk Rusks 500g',          32.00,  58.99),
(33, 3, 3, 'Original Biltong 200g',          60.00, 109.99),
(34, 3, 3, 'Peanut Butter 400g',             24.00,  44.99),
(35, 3, 3, 'Strawberry Jam 450g',            20.00,  36.99),
(36, 3, 3, 'Ceylon Tea 100ags',              35.00,  64.99),
(37, 4, 4, 'Highlighters 6-Pack',            18.00,  34.99),
(38, 4, 4, 'Stapler',                        30.00,  59.99),
(39, 4, 4, 'A4 Copy Paper 500 Sheets',       55.00,  99.99),
(40, 4, 4, 'Ring Binder A4',                 14.00,  27.99),
(41, 4, 4, 'Sticky Notes 12-Pack',           20.00,  39.99),
(42, 4, 4, 'Scientific Calculator',          90.00, 169.99),
(43, 4, 4, 'Pencil Case',                    20.00,  39.99),
(44, 4, 4, 'Whiteboard Markers 4-Pack',      22.00,  44.99);

-- ==========================================
-- 5. CUSTOMERS (1,200 South African Customers)
-- ==========================================
CREATE TABLE #First (n INT IDENTITY(1,1), v VARCHAR(50));
INSERT INTO #First (v) VALUES
('Thabo'),('Lerato'),('Sipho'),('Ayesha'),('Johan'),('Naledi'),('Pieter'),('Zanele'),('Themba'),('Nomvula'),
('Bongani'),('Palesa'),('Annelie'),('Sarel'),('Fatima'),('Yusuf'),('Riaan'),('Megan'),('Craig'),('Kagiso'),
('Refilwe'),('Siyabonga'),('Thandi'),('Mpho'),('Lindiwe'),('Tshepo'),('Karabo'),('Jaco'),('Chantal'),('Nandi'),
('Sibusiso'),('Priya'),('Ravi'),('Kabelo'),('Lwazi'),('Anele'),('Busisiwe'),('Michael'),('Sarah'),('David'),
('Emma'),('Daniel'),('Ntombi'),('Hendrik'),('Zodwa'),('Kevin'),('Aisha'),('Luyanda'),('Amahle'),('Tumelo');

CREATE TABLE #Last (n INT IDENTITY(1,1), v VARCHAR(50));
INSERT INTO #Last (v) VALUES
('Mokoena'),('Dlamini'),('Nkosi'),('Patel'),('van der Merwe'),('Khumalo'),('Botha'),('Ndlovu'),('Zulu'),('Sithole'),
('Naidoo'),('Cele'),('Adams'),('Coetzee'),('Smith'),('Pretorius'),('du Plessis'),('Mahlangu'),('Mthembu'),('Molefe'),
('Maseko'),('Shabalala'),('Govender'),('Pillay'),('Moodley'),('Jacobs'),('Williams'),('Fourie'),('Venter'),('Kruger'),
('Joubert'),('Nel'),('Swanepoel'),('Ngcobo'),('Radebe'),('Tshabalala'),('Baloyi'),('Mabaso'),('Sibiya'),('van Wyk');

-- Updated City distribution including Johannesburg CBD mapping to Branch 6

CREATE TABLE #City (City VARCHAR(100), Lo INT, Hi INT, Branch_ID INT);
INSERT INTO #City (City, Lo, Hi, Branch_ID) VALUES
('Johannesburg', 0, 20, 1), ('Johannesburg CBD', 20, 35, 6), ('Cape Town', 35, 52, 2), 
('Durban', 52, 65, 3),      ('Pretoria', 65, 75, 4),        ('Centurion', 75, 80, 4), 
('Gqeberha', 80, 88, 5),    ('Pietermaritzburg', 88, 93, 3),('Bloemfontein', 93, 97, 1), ('East London', 97, 100, 5);

DECLARE @fc INT = (SELECT COUNT(*) FROM #First);
DECLARE @sc INT = (SELECT COUNT(*) FROM #Last);

SELECT TOP (1200)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 8 AS id,
       ABS(CHECKSUM(NEWID())) % @fc + 1 AS f,
       ABS(CHECKSUM(NEWID())) % @sc + 1 AS s,
       ABS(CHECKSUM(NEWID())) % 100 + 1 AS c,
       ABS(CHECKSUM(NEWID())) % 4       AS dom,
       ABS(CHECKSUM(NEWID())) % 820     AS d
INTO #CustRand
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

INSERT INTO Customer (Customer_ID, First_Name, Last_Name, Email, City, Joined_Date)
SELECT r.id, f.v, l.v,
       LOWER(REPLACE(f.v + '.' + l.v, ' ', '')) + CAST(r.id AS VARCHAR(10)) + '@' +
         CASE r.dom WHEN 0 THEN 'gmail.com' WHEN 1 THEN 'outlook.com'
                    WHEN 2 THEN 'yahoo.com' ELSE 'webmail.co.za' END,
       ct.City,
       DATEADD(DAY, r.d, '2023-01-01')
FROM #CustRand r
JOIN #First f ON f.n = r.f
JOIN #Last  l ON l.n = r.s
JOIN #City ct ON r.c > ct.Lo AND r.c <= ct.Hi;

-- ==========================================
-- 6. CALENDAR & WEIGHTED SALES GENERATION
-- ==========================================
CREATE TABLE #Days (Day_Date DATE, W FLOAT, Prev FLOAT, Cum FLOAT);

;WITH t AS (
    SELECT TOP (668) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
), d AS (
    SELECT DATEADD(DAY, i, '2025-01-01') AS dt FROM t
), w AS (
    SELECT dt,
           CAST(CASE DATEDIFF(DAY, '2024-12-30', dt) % 7 WHEN 4 THEN 1.4 WHEN 5 THEN 1.8 WHEN 6 THEN 1.2 ELSE 1.0 END
              * CASE WHEN DAY(dt) >= 25 THEN 1.4 ELSE 1.0 END
              * CASE WHEN MONTH(dt) = 12 THEN 1.5
                     WHEN MONTH(dt) = 11 AND DAY(dt) >= 24 THEN 1.8
                     WHEN MONTH(dt) = 1 THEN 0.85 ELSE 1.0 END AS FLOAT) AS w
    FROM d
), c AS (
    SELECT dt, w, SUM(w) OVER (ORDER BY dt ROWS UNBOUNDED PRECEDING) AS cum FROM w
)
INSERT INTO #Days (Day_Date, W, Prev, Cum)
SELECT dt, w, cum - w, cum FROM c;

DECLARE @TotalW FLOAT = (SELECT MAX(Cum) FROM #Days);
DECLARE @cc INT = (SELECT MAX(Customer_ID) FROM Customer);

SELECT TOP (12000)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 10 AS Sale_ID,
       1 + CAST(@cc * POWER(CAST(ABS(CHECKSUM(NEWID())) % 10000 AS FLOAT) / 10000, 1.3) AS INT) AS Customer_ID,
       ABS(CHECKSUM(NEWID())) % 100 AS away,
       ABS(CHECKSUM(NEWID())) % 6 + 1 AS other_branch,
       (ABS(CHECKSUM(NEWID())) % 1000000 + 1) / 1000000.0 AS u_day,
       ABS(CHECKSUM(NEWID())) % 60  AS shift,
       ABS(CHECKSUM(NEWID())) % 100 AS n_roll
INTO #SaleRand
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

INSERT INTO Sales (Sale_ID, Customer_ID, Branch_ID, Employee_ID, Sale_Date, Total_Amount)
SELECT sr.Sale_ID, sr.Customer_ID, b.Branch_ID, e.Employee_ID,
       CASE WHEN d.Day_Date < c.Joined_Date 
            THEN DATEADD(DAY, sr.shift, c.Joined_Date)
            ELSE d.Day_Date END,
       0
FROM #SaleRand sr
JOIN Customer c  ON c.Customer_ID = sr.Customer_ID
JOIN #City hc    ON hc.City = c.City
JOIN #Days d     ON sr.u_day * @TotalW > d.Prev AND sr.u_day * @TotalW <= d.Cum
CROSS APPLY (SELECT CASE WHEN sr.away < 90 THEN hc.Branch_ID ELSE sr.other_branch END AS Branch_ID) b
CROSS APPLY (SELECT TOP 1 Employee_ID
             FROM Employees
             WHERE Branch_ID = b.Branch_ID AND Job_Title <> 'Branch Manager'
             ORDER BY NEWID()) e;

-- ==========================================
-- 7. SALE ITEMS & TOTALS
-- ==========================================
SELECT p.Product_ID,
       (CASE p.Category_ID WHEN 3 THEN 3.0 WHEN 4 THEN 1.5 WHEN 2 THEN 1.0 ELSE 0.7 END)
         / SQRT(p.List_Price) AS W
INTO #PW
FROM Products p;

SELECT s.Sale_ID, p.Product_ID,
       -LOG((ABS(CHECKSUM(NEWID())) % 999999 + 1) / 1000000.0) / p.W AS k,
       CAST(ABS(CHECKSUM(NEWID())) % 1000 AS FLOAT) / 1000            AS uq,
       ABS(CHECKSUM(NEWID())) % 100                                   AS ud
INTO #Keys
FROM Sales s CROSS JOIN #PW p
WHERE s.Sale_ID > 10;

SELECT Sale_ID, Product_ID, uq, ud,
       ROW_NUMBER() OVER (PARTITION BY Sale_ID ORDER BY k) AS rk
INTO #Pick
FROM #Keys;

DECLARE @maxItem INT = ISNULL((SELECT MAX(Sale_Item_ID) FROM Sale_Items), 0);

INSERT INTO Sale_Items (Sale_Item_ID, Sale_ID, Product_ID, Quantity, Unit_Price)
SELECT @maxItem + ROW_NUMBER() OVER (ORDER BY pk.Sale_ID, pk.rk),
       pk.Sale_ID,
       pk.Product_ID,
       1 + CAST(POWER(pk.uq, 3) * CASE p.Category_ID WHEN 3 THEN 4 WHEN 4 THEN 5 ELSE 2 END AS INT),
       CAST(p.List_Price * CASE WHEN pk.ud < 10 THEN 0.90 ELSE 1.00 END AS DECIMAL(10,2))
FROM #Pick pk
JOIN #SaleRand sr ON sr.Sale_ID = pk.Sale_ID
JOIN Products p   ON p.Product_ID = pk.Product_ID
WHERE pk.rk <= CASE WHEN sr.n_roll < 35 THEN 1 WHEN sr.n_roll < 65 THEN 2
                    WHEN sr.n_roll < 85 THEN 3 WHEN sr.n_roll < 95 THEN 4 ELSE 5 END;

-- Update Totals
UPDATE s
SET Total_Amount = t.total
FROM Sales s
JOIN (SELECT Sale_ID, SUM(Quantity * Unit_Price) AS total
      FROM Sale_Items GROUP BY Sale_ID) t ON t.Sale_ID = s.Sale_ID
WHERE s.Sale_ID > 10;

-- ==========================================
-- 8. VERIFICATION QUERIES
-- ==========================================
SELECT (SELECT COUNT(*) FROM Branches)    AS Branches,
       (SELECT COUNT(*) FROM Employees)   AS Employees,
       (SELECT COUNT(*) FROM Products)    AS Products,
       (SELECT COUNT(*) FROM Customer)    AS Customers,
       (SELECT COUNT(*) FROM Sales)       AS Sales,
       (SELECT COUNT(*) FROM Sale_Items) AS Sale_Items;

SELECT b.Branch_Name, COUNT(*) AS Sales, CAST(SUM(s.Total_Amount) AS DECIMAL(12,2)) AS Revenue
FROM Sales s JOIN Branches b ON b.Branch_ID = s.Branch_ID
GROUP BY b.Branch_Name ORDER BY Revenue DESC;

SELECT TOP 10 p.Product_Name, SUM(si.Quantity) AS Units_Sold
FROM Sale_Items si JOIN Products p ON p.Product_ID = si.Product_ID
GROUP BY p.Product_Name ORDER BY Units_Sold DESC;

DROP TABLE #First, #Last, #City, #CustRand, #Days, #SaleRand, #PW, #Keys, #Pick;