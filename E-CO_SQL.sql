create database ECommerce_DB;
USE ECommerce_DB ;

create table CustomersInfo (
CustomerID int primary key,
Gender varchar(2),
Location varchar(50),
Tenure_Months int
) ;

CREATE TABLE Discount_Coupon (
    Month varchar(3),
    Product_Category varchar(50),
    Coupon_Code varchar(10),
    Discount_pct int
);

CREATE TABLE Marketing_Spend (
    Date date,
    Offline_Spend decimal(10,2),
    Online_Spend decimal(10,2)
);

CREATE TABLE TAX_Amount (
    Product_Category varchar(50),
    GST varchar(10)
);


CREATE TABLE Online_Sales (
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

-- le nombre des client
select count(distinct CustomerID) as Number_Of_Custumers from online_sales  ;

-- Calculate total sales for each customer.
SELECT 
CustomerID , 
count(CustomerID) as Number_Of_Transaction
from 
online_sales
group by
customerID
order by Number_Of_Transaction desc ;

-- Fetch all transactions in which the customer used the coupon.
select * from online_sales where Coupon_Status = 'Used';


-- Customers who used coupon 
select CustomerID ,
count(CustomerID) as How_Many_Coupon ,  Coupon_Status
from online_sales 
where Coupon_Status = 'Used'
group by CustomerID
order by How_Many_Coupon desc;

-- Find the most sold products in each category.
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

-- Calculating the average amount that customers spend on each purchase.
select
	avg(Quantity*Avg_Price + Delivery_Charges) as Average_Spend_Per_Transaction
from online_sales;

-- The average amount charged per person
SELECT CustomerID, 
       AVG(Quantity * Avg_Price + Delivery_Charges) AS Average_Spend_Per_Transaction,
       COUNT(*) AS Transaction_Count
FROM online_sales
GROUP BY CustomerID
order by Average_Spend_Per_Transaction desc ;

-- Calculating the number of customers who have a subscription period of more than 12 months
select COUNT(*) as Customers_With_More_Than_12_Months
	from customersinfo  
    where Tenure_Months > 12 ;
-- customers who have a subscription period of more than 12 months
select * 
	from customersinfo  
    where Tenure_Months > 12 ; 

-- Find the city that generates the highest revenues 
select location ,sum(Quantity*Avg_Price +Delivery_Charges) as Total_Revenue
from online_sales O
inner join customersinfo C 
on O.CustomerID = C.CustomerID
group by Location
order by Total_Revenue desc;

-- Determine the day with the highest number of transactions.
select Transaction_Date , count(Transaction_Date) as Number_Of_Transactions
from online_sales
group by Transaction_Date 
order by Number_Of_Transactions desc
limit 1;

-- Fetch details of transactions above a certain value.
SELECT * 
FROM Online_Sales
WHERE (Quantity * Avg_Price + Delivery_Charges) > 3000;

-- Calculate the percentage of marketing expenses to monthly revenue.
-- Find the category with the highest tax rate and its sales volume.











