--=========QUESTION: Analyze sales performance over time ========

-- Year
SELECT 
	YEAR (order_date) AS Order_year,
	SUM (sales_amount) AS Total_sales,
	COUNT (DISTINCT customer_key) AS Total_customers,
	SUM (quantity) AS Total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR (order_date)
ORDER BY Order_year ASC
;


-- Month
SELECT 
	MONTH (order_date) AS Order_month,
	SUM (sales_amount) AS Total_sales,
	COUNT (DISTINCT customer_key) AS Total_customers,
	SUM (quantity) AS Total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH (order_date)
ORDER BY Order_month ASC
;

-- Year and Month (DATETRUNC or FORMAT can be used)
SELECT 
	FORMAT (order_date, 'yyyy-MM') AS Order_date,
	SUM (sales_amount) AS Total_sales,
	COUNT (DISTINCT customer_key) AS Total_customers,
	SUM (quantity) AS Total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT (order_date, 'yyyy-MM')
ORDER BY Order_date ASC