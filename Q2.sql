/* Q2: Product Performance
top 10 products by total revenue in 2024*/

WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.line_total) as total_revenue,
        COUNT(DISTINCT o.order_id) as total_orders
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT *
FROM product_revenue
ORDER BY total_revenue DESC
LIMIT 10; -- all 10 products are electronics 