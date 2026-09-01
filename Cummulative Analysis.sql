/* QUESTION: Calculate the total sales and average sales per month
			and the running total and moving average of sales over time*/

SELECT
	Order_date,
	Total_sales,
	SUM (Total_sales) OVER (PARTITION BY YEAR (Order_date) ORDER BY Order_date) as RunningTotal_sales,
	Avg_sales,
	AVG (Avg_sales) OVER (PARTITION BY YEAR (Order_date) ORDER BY Order_date) as MovingAverage_sales
FROM (
	SELECT 
		DATETRUNC (MONTH,order_date) AS Order_date,
		SUM (sales_amount) AS Total_sales,
		AVG (sales_amount) AS Avg_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC (MONTH,order_date)
) AS ALIAS
;