
SELECT
    sale_year,
    sale_month,
    monthly_sales,
    -- Running total for the year (cumulative)
    SUM(monthly_sales) OVER (
        PARTITION BY sale_year
        ORDER BY sale_month
        ROWS UNBOUNDED PRECEDING
    ) as running_total_ytd,
    -- 3-month moving average using ROWS frame
    AVG(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as moving_avg_3month_rows,
    -- Maximum sales in 3-month window
    MAX(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as max_3month_window,
    -- Minimum sales in 3-month window
    MIN(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as min_3month_window
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) as sale_year,
        EXTRACT(MONTH FROM sale_date) as sale_month,
        SUM(amount) as monthly_sales
    FROM transactions
    WHERE sale_date >= DATE '2025-01-15'  -- Use historical date for actual data
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
) monthly_summary
ORDER BY sale_year, sale_month;
INTERPRETATION:
This query shows monthly sales trends using various window functions that provide 
multiple perspectives on sales performance over time.
