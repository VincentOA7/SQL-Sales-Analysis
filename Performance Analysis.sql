/* QUESTION: Analyze the yearly performance of products by comparing 
			each product's sales to both its average sales performance and the previous year's sales*/

WITH CTE AS (
	SELECT
	YEAR (f.order_date) as Order_year,
	p.product_name,
	SUM (f.sales_amount) as CurrentSales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL 
	GROUP BY YEAR (f.order_date), p.product_name
)
SELECT
	Order_year,
	product_name,
	CurrentSales,
	AVG (CurrentSales) OVER (PARTITION BY product_name) AS AVG_sales,
--Comparison of current sales to average sales by products
	CurrentSales - AVG (CurrentSales) OVER (PARTITION BY product_name) AS AvgDiff,
-- Using case statement to create a flag for the difference of current sales and average sales
	CASE
		WHEN CurrentSales - AVG (CurrentSales) OVER (PARTITION BY product_name) > 0 
		THEN 'Above Average'
		WHEN CurrentSales - AVG (CurrentSales) OVER (PARTITION BY product_name) < 0 
		THEN 'Below Average'
		ELSE 'Avg'
	END AS Avg_Change,
-- using LAG to access the prvious year of each product. It must use order by (Year-over-Year Ananlysis)
	LAG (CurrentSales) OVER (PARTITION BY product_name ORDER BY Order_year) AS PrevYear_sales,
-- Comparison of current sales to previous year sales by products
	CurrentSales - LAG (CurrentSales) OVER (PARTITION BY product_name ORDER BY Order_year) AS PrevYearDiff,
-- Using case statement to create a flag for the difference of current sales and previous year sales
	CASE
		WHEN CurrentSales - LAG (CurrentSales) OVER (PARTITION BY product_name ORDER BY Order_year)  > 0 
		THEN 'Increase'
		WHEN CurrentSales - LAG (CurrentSales) OVER (PARTITION BY product_name ORDER BY Order_year) < 0 
		THEN 'Decrease'
		ELSE 'No Change'
	END AS PrevYear_change
FROM CTE
;