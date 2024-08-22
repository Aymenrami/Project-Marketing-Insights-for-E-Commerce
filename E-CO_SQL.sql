create database ecommerce_db
use ecommerce_db

-- Procedure for creating the CustomersInfo table
DELIMITER //
CREATE PROCEDURE Create_CustomersInfo_Table()
BEGIN
    CREATE TABLE IF NOT EXISTS CustomersInfo (
        CustomerID int primary key,
        Gender varchar(2),
        Location varchar(50),
        Tenure_Months int
    );
END //
DELIMITER ;

-- Procedure for creating the Discount_Coupon table
DELIMITER //
CREATE PROCEDURE Create_Discount_Coupon_Table()
BEGIN
    CREATE TABLE IF NOT EXISTS Discount_Coupon (
        Month varchar(3),
        Product_Category varchar(50),
        Coupon_Code varchar(10),
        Discount_pct int
    );
END //
DELIMITER ;

-- Procedure for creating the Marketing_Spend table
DELIMITER //
CREATE PROCEDURE Create_Marketing_Spend_Table()
BEGIN
    CREATE TABLE IF NOT EXISTS Marketing_Spend (
        Date date,
        Offline_Spend decimal(10,2),
        Online_Spend decimal(10,2)
    );
END //
DELIMITER ;

-- Procedure for creating the TAX_Amount table
DELIMITER //
CREATE PROCEDURE Create_TAX_Amount_Table()
BEGIN
    CREATE TABLE IF NOT EXISTS TAX_Amount (
        Product_Category varchar(50),
        GST varchar(10)
    );
END //
DELIMITER ;

-- Procedure for creating the Online_Sales table
DELIMITER //
CREATE PROCEDURE Create_Online_Sales_Table()
BEGIN
    CREATE TABLE IF NOT EXISTS Online_Sales (
        CustomerID int,
        Transaction_ID int,
        Transaction_Date date,
        Product_SKU varchar(20),
        Product_Description varchar(255),
        Product_Category varchar(50),
        Quantity int,
        Avg_Price decimal(10,2),
        Delivery_Charges decimal(10,2),
        Coupon_Status varchar(10),
		FOREIGN KEY (CustomerID) REFERENCES CustomersInfo(CustomerID)
    );
end //


DELIMITER //
create procedure Create_Online_Sales_Table_Archives()
begin
	CREATE TABLE Online_Sales_History (
		HistoryID int AUTO_INCREMENT PRIMARY KEY,
		CustomerID int,
		Transaction_ID int,
		Transaction_Date date,
		Product_SKU varchar(20),
		Product_Description varchar(255),
		Product_Category varchar(50),
		Quantity int,
		Avg_Price decimal(10,2),
		Delivery_Charges decimal(10,2),
		Coupon_Status varchar(10),
		Action_Type varchar(10),  -- 'UPDATE' ou 'DELETE'
		Modified_Date datetime -- Date de modification
);
end //

-- Procedure for counting the number of customers
DELIMITER //
CREATE PROCEDURE Get_Number_Of_Customers()
BEGIN
    SELECT COUNT(DISTINCT CustomerID) AS Number_Of_Customers FROM Online_Sales;
END //
DELIMITER ;

-- Procedure for calculating total sales for each customer
DELIMITER //
CREATE PROCEDURE Get_Total_Sales_Per_Customer()
BEGIN
    SELECT 
        CustomerID, 
        COUNT(CustomerID) AS Number_Of_Transactions
    FROM 
        Online_Sales
    GROUP BY 
        CustomerID
    ORDER BY 
        Number_Of_Transactions DESC;
END //
DELIMITER ;

-- Procedure for fetching all transactions where the customer used the coupon
DELIMITER //
CREATE PROCEDURE Get_Transactions_With_Used_Coupons()
BEGIN
    SELECT * FROM Online_Sales WHERE Coupon_Status = 'Used';
END //
DELIMITER ;

-- Procedure for finding customers who used coupons and the number of times they used them
DELIMITER //
CREATE PROCEDURE Get_Customers_Using_Coupons()
BEGIN
    SELECT 
        CustomerID,
        COUNT(CustomerID) AS How_Many_Coupons,  
        Coupon_Status
    FROM 
        Online_Sales 
    WHERE 
        Coupon_Status = 'Used'
    GROUP BY 
        CustomerID
    ORDER BY 
        How_Many_Coupons DESC;
END //
DELIMITER ;

-- Procedure for finding the most sold products in each category
DELIMITER //
CREATE PROCEDURE Get_Most_Sold_Products_Per_Category()
BEGIN
    SELECT 
        Product_Category, 
        Product_Description,
        SUM(Quantity) AS Total_Quantity_Sold
    FROM 
        Online_Sales
    GROUP BY 
        Product_Category, 
        Product_Description
    ORDER BY 
        Product_Category, 
        Total_Quantity_Sold DESC;
END //
DELIMITER ;

-- Procedure for calculating the average amount customers spend on each purchase
DELIMITER //
CREATE PROCEDURE Get_Average_Spend_Per_Transaction()
BEGIN
    SELECT
        AVG(Quantity * Avg_Price + Delivery_Charges) AS Average_Spend_Per_Transaction
    FROM 
        Online_Sales;
END //
DELIMITER ;

-- Procedure for calculating the average amount spent per customer
DELIMITER //
CREATE PROCEDURE Get_Average_Spend_Per_Customer()
BEGIN
    SELECT 
        CustomerID, 
        AVG(Quantity * Avg_Price + Delivery_Charges) AS Average_Spend_Per_Transaction,
        COUNT(*) AS Transaction_Count
    FROM 
        Online_Sales
    GROUP BY 
        CustomerID
    ORDER BY 
        Average_Spend_Per_Transaction DESC;
END //
DELIMITER ;

-- Procedure for counting customers with a subscription period of more than 12 months
DELIMITER //
CREATE PROCEDURE Get_Customers_With_Long_Tenure()
BEGIN
    SELECT COUNT(*) AS Customers_With_More_Than_12_Months
    FROM 
        CustomersInfo  
    WHERE 
        Tenure_Months > 12;
END //
DELIMITER ;

-- Procedure for fetching customers with a subscription period of more than 12 months
DELIMITER //
CREATE PROCEDURE Get_Customers_With_Tenure_Above_12_Months()
BEGIN
    SELECT * 
    FROM 
        CustomersInfo  
    WHERE 
        Tenure_Months > 12;
END //
DELIMITER ;

-- Procedure for finding the city that generates the highest revenues
DELIMITER //
CREATE PROCEDURE Get_City_With_Highest_Revenue()
BEGIN
    SELECT 
        Location, 
        SUM(Quantity * Avg_Price + Delivery_Charges) AS Total_Revenue
    FROM 
        Online_Sales O
    INNER JOIN 
        CustomersInfo C 
    ON 
        O.CustomerID = C.CustomerID
    GROUP BY 
        Location
    ORDER BY 
        Total_Revenue DESC;
END //
DELIMITER ;

-- Procedure for determining the day with the highest number of transactions
DELIMITER //
CREATE PROCEDURE Get_Day_With_Highest_Transactions()
BEGIN
    SELECT 
        Transaction_Date, 
        COUNT(Transaction_Date) AS Number_Of_Transactions
    FROM 
        Online_Sales
    GROUP BY 
        Transaction_Date 
    ORDER BY 
        Number_Of_Transactions DESC
    LIMIT 1;
END //
DELIMITER ;

-- Procedure for fetching details of transactions above a certain value
DELIMITER //
CREATE PROCEDURE Get_Transactions_Above_Value(IN transaction_value DECIMAL(10,2))
BEGIN
    SELECT * 
    FROM 
        Online_Sales
    WHERE 
        (Quantity * Avg_Price + Delivery_Charges) > transaction_value;
END //
DELIMITER ;

-- Procedure for calculating the percentage of marketing expenses to monthly revenue
DELIMITER //
CREATE PROCEDURE Get_Marketing_Expense_Percentage()
BEGIN
    SELECT 
        M.Date, 
        (M.Offline_Spend + M.Online_Spend) / SUM(O.Quantity * O.Avg_Price + O.Delivery_Charges) * 100 AS Marketing_Expense_Percentage
    FROM 
        Marketing_Spend M
    INNER JOIN 
        Online_Sales O
    ON 
        MONTH(M.Date) = MONTH(O.Transaction_Date)
    GROUP BY 
        M.Date;
END //
DELIMITER ;

-- Procedure for finding the category with the highest tax rate and its sales volume
DELIMITER //
CREATE PROCEDURE Get_Category_With_Highest_Tax_Rate()
BEGIN
    SELECT 
        T.Product_Category,
        SUM(O.Quantity) AS SumQuantity,
        CAST(REPLACE(T.GST, '%', '') AS FLOAT) AS GST_Percentage
    FROM 
        TAX_Amount T
    INNER JOIN 
        Online_Sales O
    ON 
        T.Product_Category = O.Product_Category
    GROUP BY 
        T.Product_Category, T.GST
    ORDER BY 
        GST_Percentage desc ;
End //
delimiter ;
-- Create a trigger to store the old data after an update occurs on Online_Sales
DELIMITER //
drop trigger if exists Update_Online_Sales_Archive;
CREATE TRIGGER Update_Online_Sales_Archive
BEFORE UPDATE ON Online_Sales
FOR EACH ROW
BEGIN
    -- Insert the old data into the Online_Sales_History table, marking it as an update
    INSERT INTO Online_Sales_History (
        CustomerID,
        Transaction_ID,
        Transaction_Date,
        Product_SKU,
        Product_Description,
        Product_Category,
        Quantity,
        Avg_Price,
        Delivery_Charges,
        Coupon_Status,
        Action_Type,
        Modified_Date
    )
    VALUES (
        OLD.CustomerID,
        OLD.Transaction_ID,
        OLD.Transaction_Date,
        OLD.Product_SKU,
        OLD.Product_Description,
        OLD.Product_Category,
        OLD.Quantity,
        OLD.Avg_Price,
        OLD.Delivery_Charges,
        OLD.Coupon_Status,
        'UPDATE',  -- Mark this action as an update
        current_date()  -- Record the current date and time of the update
    );
END //
DELIMITER ;

-- Create a trigger to store the old data after a delete occurs on Online_Sales
DROP TRIGGER Delete_Online_Sales_Archive
DELIMITER //
CREATE TRIGGER Delete_Online_Sales_Archive
BEFORE DELETE ON Online_Sales
FOR EACH ROW
BEGIN
    -- Insert the old data into the Online_Sales_History table, marking it as a delete
    INSERT INTO Online_Sales_History (
        CustomerID,
        Transaction_ID,
        Transaction_Date,
        Product_SKU,
        Product_Description,
        Product_Category,
        Quantity,
        Avg_Price,
        Delivery_Charges,
        Coupon_Status,
        Action_Type,
        Modified_Date
    )
    VALUES (
        OLD.CustomerID,
        OLD.Transaction_ID,
        OLD.Transaction_Date,
        OLD.Product_SKU,
        OLD.Product_Description,
        OLD.Product_Category,
        OLD.Quantity,
        OLD.Avg_Price,
        OLD.Delivery_Charges,
        OLD.Coupon_Status,
        'DELETE',  -- Mark this action as a delete
        current_date()  -- Record the current date and time of the deletion
    );
END //
DELIMITER ;

-- create procedure of join customersinfo_online_sales
delimiter //
create procedure customersinfo_Salse()
begin
	select O.CustomerID  , O.Product_Description , O.Quantity , O.Avg_Price , O.Delivery_Charges , O.Coupon_Status , C.Gender , C.Location  , C.Tenure_Months
	from online_sales O
	inner join customersinfo C
	on O.CustomerID = C.CustomerID ;
end //

-- relation betwen Long_Tenure and Salses

drop procedure if exists Long_Tenure;
delimiter //
create  procedure Long_Tenure()
begin
	select O.CustomerID ,
    count(O.CustomerID) as Totales_Salses,
	C.Tenure_Months
	from online_sales O
	inner join customersinfo C
	on O.CustomerID = C.CustomerID 
    group by O.CustomerID
    order by C.Tenure_Months desc;
end //

drop procedure AddSeasonColumn
DELIMITER //
-- procedure to add a season Column 
CREATE PROCEDURE AddSeasonColumn()
BEGIN
    SELECT *,
        CASE
            WHEN month IN ('Dec','Jan','Feb') THEN 'Winter'
            WHEN month IN ('Mar','Apr', 'May') THEN 'Spring'
            WHEN month IN ('Jul','Jun','Aug') THEN 'Summer'
            WHEN month IN ('Sep','Oct', 'Nov') THEN 'Fall'
            ELSE 'Invalid Month'
        END AS season
    FROM discount_coupon;
END //

DELIMITER ;

-- Procedure for How meny Transaction by days
drop procedure if exists GetMarketingSpendSummary
delimiter //
create procedure GetMarketingSpendSummary()
begin
	select 
		M.Date , 
        M.Offline_Spend , 
        M.Online_Spend ,
        sum(O.Quantity) as  Quantity ,
        sum(O.Avg_Price) as Avg_Price ,
        sum(O.Delivery_Charges) as Delivery_Charges  ,
        count(O.Transaction_Date) as Transaction_Count
	from marketing_spend M 
	inner join online_sales O 
	on M.Date  = O.Transaction_Date 
	group by M.Date, M.Offline_Spend, M.Online_Spend;
end //

