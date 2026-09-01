/* QUESTION: Which category contributes the most to the overall sales */

WITH CTE AS (
	SELECT 
		p.category,
		SUM (f.sales_amount) AS Totalsales
		FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.category
)
	SELECT
		category,
		Totalsales,
		SUM (Totalsales) OVER () as Overallsales,
		CONCAT (ROUND (CAST ((Totalsales) AS DECIMAL (10,2))/SUM (Totalsales) OVER () * 100.0, 2), '%') AS OverallsalesPct
	FROM CTE
	ORDER BY Totalsales DESC
	;