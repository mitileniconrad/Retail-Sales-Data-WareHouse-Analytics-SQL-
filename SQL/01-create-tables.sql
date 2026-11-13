-- Creates the Data_Warehouse database and its 8 tables.

CREATE DATABASE Data_Warehouse;

USE Data_Warehouse;

CREATE TABLE Branches (
    Branch_ID    INT PRIMARY KEY,
    Branch_Name  VARCHAR(100) NOT NULL,
    Location     VARCHAR(150) NOT NULL
);

CREATE TABLE Customer (
    Customer_ID  INT PRIMARY KEY,
    First_Name   VARCHAR(50)  NOT NULL,
    Last_Name    VARCHAR(50)  NOT NULL,
    Email        VARCHAR(100),
    City         VARCHAR(100),
    Joined_Date  DATE
);

CREATE TABLE Suppliers (
    Supplier_ID     INT PRIMARY KEY,
    Supplier_name   VARCHAR(100) NOT NULL,
    Supplier_Email  VARCHAR(100)
);

CREATE TABLE Categories (
    Category_ID    INT PRIMARY KEY,
    Category_name  VARCHAR(100) NOT NULL
);

CREATE TABLE Employees (
    Employee_ID  INT PRIMARY KEY,
    Branch_ID    INT NOT NULL,
    Full_Name    VARCHAR(100) NOT NULL,
    Job_Title    VARCHAR(100),
    Hire_Date    DATE,
    FOREIGN KEY (Branch_ID) REFERENCES Branches(Branch_ID)
);

CREATE TABLE Products (
    Product_ID    INT PRIMARY KEY,
    Supplier_ID   INT NOT NULL,
    Category_ID   INT NOT NULL,
    Product_Name  VARCHAR(150) NOT NULL,
    Cost_Price    DECIMAL(10,2),
    List_Price    DECIMAL(10,2),
    FOREIGN KEY (Supplier_ID) REFERENCES Suppliers(Supplier_ID),
    FOREIGN KEY (Category_ID) REFERENCES Categories(Category_ID)
);

CREATE TABLE Sales (
    Sale_ID       INT PRIMARY KEY,
    Customer_ID   INT NOT NULL,
    Branch_ID     INT NOT NULL,
    Employee_ID   INT NOT NULL,
    Sale_Date     DATE NOT NULL,
    Total_Amount  DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Branch_ID)   REFERENCES Branches(Branch_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Sale_Items (
    Sale_Item_ID  INT PRIMARY KEY,
    Sale_ID       INT NOT NULL,
    Product_ID    INT NOT NULL,
    Quantity      INT NOT NULL,
    Unit_Price    DECIMAL(10,2),
    FOREIGN KEY (Sale_ID)    REFERENCES Sales(Sale_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);