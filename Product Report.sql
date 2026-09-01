/* 
==========================================================================================================================
Product Report
==========================================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours

Highlight:
	1. Gather essential fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-performers, Mid-range, or Low-performers.
	3. Aggregate product-level metris
		- Total orders
		- Total sales
		- Total quantity sold
		- Total customers (unique)
		- Lifespan (in months)
		- Average selling price
	4. Calculate valuable KPIs:
		- Recency (months since last order)
		- Average order revenue
		_ Average monthly revenue
==========================================================================================================================
*/
--Create View of the report for easy access to get insights from the database
--and also for data visualization using Tableau or PowerBI

CREATE VIEW gold.report_products AS
WITH CTE AS (
-- Step 1 - Base Query: Retrieve core columns from table
	SELECT 
		p.product_key,
		p.product_number,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost,
		f.order_number,
		f.sales_amount,
		f.quantity,
		f.customer_key,
		f.order_date
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
), 
CTE2 AS (
-- Step 2 - Second Query: Aggregation of measures / Product aggregation of key metrics
	SELECT 
		product_key,
		product_name,
		product_number,
		category,
		subcategory,
		cost,
		COUNT (DISTINCT order_number) AS Totalorders,
		SUM (sales_amount) AS Totalsales,
		SUM (quantity) AS TotalQuantitySold,
		COUNT (DISTINCT customer_key) AS Totalcustomers,
		MAX (order_date) AS Lastsaledate,
		DATEDIFF (MONTH, MIN(order_date), MAX(order_date)) AS Lifespan,
		ROUND (AVG (CAST (sales_amount/NULLIF (quantity, 0) AS DECIMAL (10,2))), 2) AS AvgSellingPrice
	FROM CTE
	GROUP BY product_key, product_number, product_name, category, subcategory, cost
)
-- Step 3 -	Third Query: Segment products by revenue using the CASE WHEN statement
	SELECT 
		product_key,
		product_name,
		product_number,
		category,
		subcategory,
		cost,
		Lastsaledate,
		Totalorders,
		Totalsales, 
		CASE 
			WHEN Totalsales > 100000 THEN 'High-performers'
			WHEN Totalsales >= 50000 THEN 'Mid-range'
			ELSE 'Low-performers'
		END AS ProductSegment,
		TotalQuantitySold,
		Totalcustomers,
		DATEDIFF (MONTH, Lastsaledate, GETDATE()) AS Recency, -- First KPI: Recency (months since last order)
		Lifespan,
--Calculate the average order value. Best to use CASE statement so as to avoid products with 0 orders
-- And prevent error in the query. Second KPI
		CASE 
			WHEN Totalorders = 0 THEN 0
			ELSE Totalsales/Totalorders 
		END AS AvgOrderRev,
--Calculate the average monthly spend. Best to use CASE statement so as to avoid product with 0 lifespan
-- And prevent error in the query. Third KPI
		CASE 
			WHEN Lifespan = 0 THEN Totalsales
			ELSE Totalsales/Lifespan 
		END AS AvgMonthlyRev
		FROM CTE2
;


-- To query the View
SELECT *
FROM gold.report_products
;