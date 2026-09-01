/* QUESTION: Segment products into cost ranges and 
			count how many products fall into each segment */

WITH CTE AS (
	SELECT 
		product_key,
		product_name,
		cost,
		CASE
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
			ELSE 'Above 1000'
		END AS CostRange
	FROM gold.dim_products
)
	SELECT
		CostRange,
		COUNT (product_key) AS TotalProducts
	FROM CTE
	GROUP BY CostRange
	ORDER BY COUNT (product_key) DESC
;




/* QUESTION: Group customers into three segments based on their spending behaviour;
				-VIP: Customers with at least 12 months of history and spending more than #5,000.
				- Regular: Customers with at least 12 months of history but spending #5,000 or less.
				- New: Customers with a lifespan of less than 12 months.
				- And find the total number of customers in each group. */

WITH CTE AS (
	SELECT 
	c.customer_key,
	SUM (sales_amount) AS TotalSpending,
	MIN (order_date) AS FirstOrderDate,
	MAX (order_date) AS LastOrderDate,
--Lifespan is calculated by finding the difference of the first orderdate and last orderdate 
-- of each customer to know their month of history.
	DATEDIFF (MONTH,MIN (order_date), MAX (order_date)) AS Lifespan
	FROM gold.dim_customers c
	LEFT JOIN gold.fact_sales f
	ON c.customer_key = f.customer_key
	GROUP BY c.customer_key
)
	SELECT 
	Customer_seg,
	COUNT (customer_key) as TotalCustomers
	FROM(
	-- Customer segment using the CASE WHEN statement
		SELECT
			customer_key,
		CASE
			WHEN lifespan >= 12 AND TotalSpending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND TotalSpending <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS Customer_seg
		FROM CTE
	) AS alias
	GROUP BY Customer_seg
	ORDER BY TotalCustomers DESC