SELECT *
FROM (
    SELECT 
        region,
        name AS product_name,
        total_sales,
        total_quantity,

        -- gives unique numbers which are sequential for each region
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS row_number_rank,

        -- show ranking with gaps for ties
        RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS sales_rank,

        -- show ranking without gaps for ties
        DENSE_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS dense_sales_rank,

        -- shows relative rank as percentage within each region
        PERCENT_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS percent_rank

    FROM (
        SELECT 
            c.region,
            p.name,
            SUM(t.amount) AS total_sales,
            SUM(t.quantity) AS total_quantity
        FROM transactions t
        JOIN products p ON t.product_id = p.product_id
        JOIN customers c ON t.customer_id = c.customer_id
        WHERE t.sale_date >= DATE '2025-01-20'
        GROUP BY c.region, p.name
    ) product_region_sales
) ranked_sales
WHERE sales_rank <= 5
ORDER BY region, sales_rank;

-- INTERPRETATION
-- This query shows the performance of sales for different regions 
-- to help the department identify products that perform highly.

