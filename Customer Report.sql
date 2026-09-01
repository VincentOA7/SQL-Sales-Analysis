/* 
==========================================================================================================================
Customer Report
==========================================================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours

Highlight:
	1. Gather essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregate customer-level metris
		- Total orders
		- Total sales
		- Total quantity purchased
		- Total products
		- Lifespan (in months)
	4. Calculate valuable KPIs:
		- Recency (months since last order)
		- Average order value
		_ Average monthly spend
==========================================================================================================================
*/
--------------------------------------------------------------------------------------------------------
--Create View of the report for easy access to get insights from the data 
--and also for data visualization using Tableau or PowerBI

CREATE VIEW gold.report_customers AS
WITH CTE AS (
-- Step 1 - Base Query: Retrieve core columns from table
	SELECT 
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT (c.first_name, ' ', c.last_name) AS Customer_name,
		DATEDIFF (year, c.birthdate, GETDATE()) AS Age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	WHERE f.order_date IS NOT NULL
), 
CTE2 AS (
-- Step 2 - Second Query: Aggregation of measures / Customer aggregation of key metrics
	SELECT 
		customer_key,
		customer_number,
		Customer_name,
		Age,
		MAX (order_date) AS Lastorder,
		COUNT (DISTINCT order_number) AS TotalOrders,
		COUNT (DISTINCT product_key) AS TotalProducts,
		SUM (sales_amount) AS TotalSales,
		SUM (quantity) AS TotalQuantity,
		DATEDIFF (MONTH,MIN (order_date), MAX (order_date)) AS Lifespan
	FROM CTE
	GROUP BY customer_key, customer_number, Customer_name, Age
)
-- Step 3 -	Third Query: Segment customers into categories using the CASE WHEN statement
	SELECT 
		customer_key,
		customer_number,
		Customer_name,
		Age,
		CASE 
			WHEN Age < 20 THEN 'Below 20'
			WHEN Age BETWEEN 20 AND 39 THEN '20 -39'
			WHEN Age BETWEEN 40 AND 59 THEN '40 -59'
			WHEN Age BETWEEN 60 AND 79 THEN '60 -79'
			ELSE '80 and Above'
		END AS Age_seg,
		CASE
			WHEN lifespan >= 12 AND TotalSales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND TotalSales <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS Customer_seg,
		Lastorder,
		DATEDIFF (MONTH, Lastorder, GETDATE()) AS Recency, -- First KPI: Recency (months since last order)
		TotalOrders,
		TotalProducts,
		TotalSales,
		TotalQuantity,
		Lifespan,
--Calculate the average order value. Best to use CASE statement so as to avoid customers who have 0 orders
-- And prevent error in the query. Second KPI
		CASE
			WHEN TotalOrders = 0 THEN 0
			ELSE TotalSales/TotalOrders
		END AS AvgOrderValue,
--Calculate the average monthly spend. Best to use CASE statement so as to avoid customers who have 0 lifespan
-- And prevent error in the query. Third KPI
		CASE
			WHEN Lifespan = 0 THEN TotalSales
			ELSE TotalSales/Lifespan
		END AS AvgMonthlySpend
	FROM CTE2
;


-- To query the View
SELECT *
FROM gold.report_customers
;