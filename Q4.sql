/* Question 4: Quarterly Revenue Trends
comparing quarterly revenue between 2023 and 2024
looking at total revenue, average order value and order count
joined orders and order_items for revenue calculation*/

WITH quarterly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) as year,
        EXTRACT(QUARTER FROM o.order_date) as quarter,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(oi.line_total) as total_revenue,
        ROUND(AVG(o.total_amount)::numeric, 2) as avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) IN (2023, 2024)
    GROUP BY year, quarter
)
SELECT *
FROM quarterly_revenue
ORDER BY year, quarter;

-- Identifying the quarter with strongest revenue growth from 2023 to 2024
WITH quarterly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) as year,
        EXTRACT(QUARTER FROM o.order_date) as quarter,
        SUM(oi.line_total) as total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) IN (2023, 2024)
    GROUP BY year, quarter
),
growth AS (
    SELECT 
        a.quarter,
        a.total_revenue as revenue_2023,
        b.total_revenue as revenue_2024,
        ROUND(((b.total_revenue - a.total_revenue) / a.total_revenue * 100)::numeric, 2) as growth_percentage
    FROM quarterly_revenue a
    JOIN quarterly_revenue b ON a.quarter = b.quarter
    WHERE a.year = 2023 AND b.year = 2024
)
SELECT * FROM growth
ORDER BY growth_percentage DESC;-- quarter 1 had the highest growth,every quarter in 2024 massively outperformed 2023