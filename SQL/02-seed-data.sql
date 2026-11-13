-- Starter rows for every table (10 sales, 20 sale items).

USE Data_Warehouse;

INSERT INTO Branches (Branch_ID, Branch_Name, Location) VALUES
(1, 'Johannesburg Central', 'Johannesburg'),
(2, 'Cape Town Waterfront', 'Cape Town'),
(3, 'Durban North', 'Durban');

INSERT INTO Customer (Customer_ID, First_Name, Last_Name, Email, City, Joined_Date) VALUES

(1, 'Thabo', 'Mokoena', 'thabo.mokoena@email.com', 'Johannesburg', '2024-01-15'),
(2, 'Lerato', 'Dlamini', 'lerato.dlamini@email.com', 'Pretoria', '2024-02-03'),
(3, 'Sipho', 'Nkosi', 'sipho.nkosi@email.com', 'Durban', '2024-03-12'),
(4, 'Ayesha', 'Patel', 'ayesha.patel@email.com', 'Cape Town', '2024-04-20'),
(5, 'Johan', 'van der Merwe', 'johan.vdm@email.com', 'Cape Town', '2024-05-08'),
(6, 'Naledi', 'Khumalo', 'naledi.khumalo@email.com', 'Johannesburg', '2024-06-17'),
(7, 'Pieter', 'Botha', 'pieter.botha@email.com', 'Durban', '2024-07-25'),
(8, 'Zanele', 'Ndlovu', 'zanele.ndlovu@email.com', 'Pretoria', '2024-08-30');

INSERT INTO Suppliers (Supplier_ID, Supplier_name, Supplier_Email) VALUES

(1, 'TechSource Distributors', 'sales@techsource.co.za'),
(2, 'HomeGoods Wholesale', 'orders@homegoods.co.za'),
(3, 'FreshFields Foods', 'supply@freshfields.co.za'),
(4, 'OfficePro Supplies', 'info@officepro.co.za');

INSERT INTO Categories (Category_ID, Category_name) VALUES

(1, 'Electronics'),
(2, 'Home & Kitchen'),
(3, 'Groceries'),
(4, 'Stationery');

INSERT INTO Employees (Employee_ID, Branch_ID, Full_Name, Job_Title, Hire_Date) VALUES

(1, 1, 'Nomsa Zulu', 'Branch Manager', '2020-03-01'),
(2, 1, 'Kabelo Sithole', 'Sales Associate', '2022-06-15'),
(3, 2, 'Megan Adams', 'Branch Manager', '2019-09-10'),
(4, 2, 'Riaan Coetzee', 'Sales Associate', '2023-01-20'),
(5, 3, 'Priya Naidoo', 'Branch Manager', '2021-04-05'),
(6, 3, 'Mandla Cele', 'Sales Associate', '2023-08-12');

INSERT INTO Products (Product_ID, Supplier_ID, Category_ID, Product_Name, Cost_Price, List_Price) VALUES
(1, 1, 1, 'Wireless Mouse', 150.00, 249.99),
(2, 1, 1, 'USB-C Cable', 40.00, 79.99),
(3, 1, 1, 'Bluetooth Speaker', 400.00, 699.99),
(4, 2, 2, 'Non-Stick Frying Pan', 120.00, 219.99),
(5, 2, 2, 'Electric Kettle', 180.00, 329.99),
(6, 3, 3, 'Rooibos Tea 60 Bags', 25.00, 44.99),
(7, 3, 3, 'Ground Coffee 250g', 55.00, 89.99),
(8, 4, 4, 'A4 Notebook', 15.00, 29.99),
(9, 4, 4, 'Ballpoint Pens 10-Pack', 12.00, 24.99),
(10, 4, 4, 'Desk Organiser', 70.00, 129.99);

INSERT INTO Sales (Sale_ID, Customer_ID, Branch_ID, Employee_ID, Sale_Date, Total_Amount) VALUES
(1, 1, 1, 2, '2025-01-10', 409.97),
(2, 2, 1, 2, '2025-01-22', 699.99),
(3, 3, 3, 6, '2025-02-05', 309.97),
(4, 4, 2, 4, '2025-02-14', 419.98),
(5, 5, 2, 4, '2025-03-03', 329.92),
(6, 6, 1, 2, '2025-03-18', 679.96),
(7, 7, 3, 6, '2025-04-02', 779.98),
(8, 8, 1, 1, '2025-04-19', 549.98),
(9, 1, 1, 2, '2025-05-07', 224.96),
(10, 4, 2, 3, '2025-05-21', 379.94);

INSERT INTO Sale_Items (Sale_Item_ID, Sale_ID, Product_ID, Quantity, Unit_Price) VALUES
(1, 1, 1, 1, 249.99),
(2, 1, 2, 2, 79.99),
(3, 2, 3, 1, 699.99),
(4, 3, 4, 1, 219.99),
(5, 3, 6, 2, 44.99),
(6, 4, 5, 1, 329.99),
(7, 4, 7, 1, 89.99),
(8, 5, 8, 5, 29.99),
(9, 5, 9, 2, 24.99),
(10, 5, 10, 1, 129.99),
(11, 6, 1, 2, 249.99),
(12, 6, 7, 2, 89.99),
(13, 7, 3, 1, 699.99),
(14, 7, 2, 1, 79.99),
(15, 8, 5, 1, 329.99),
(16, 8, 4, 1, 219.99),
(17, 9, 6, 3, 44.99),
(18, 9, 7, 1, 89.99),
(19, 10, 10, 2, 129.99),
(20, 10, 8, 4, 29.99);