-- Question 8: Top Seller Bonus Qualification
-- Finding top 10 sellers in 2024 by revenue
-- Only sellers with at least 10 orders and average rating of 4.0 or above
-- Joined sellers, orders, products and reviews

WITH seller_revenue AS (
    SELECT 
        o.seller_id,
        s.seller_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(oi.line_total) as total_revenue
    FROM orders o
    JOIN sellers s ON o.seller_id = s.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY o.seller_id, s.seller_name
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
seller_ratings AS (
    SELECT 
        p.seller_id,
        ROUND(AVG(r.rating)::numeric, 2) as avg_rating
    FROM reviews r
    JOIN products p ON r.product_id = p.product_id
    GROUP BY p.seller_id
)
SELECT 
    sr.seller_name,
    sv.total_orders,
    sl.avg_rating,
    ROUND(sv.total_revenue::numeric, 2) as total_revenue
FROM seller_revenue sv
JOIN sellers sr ON sv.seller_id = sr.seller_id
JOIN seller_ratings sl ON sv.seller_id = sl.seller_id
WHERE sl.avg_rating >= 4.0
ORDER BY total_revenue DESC
LIMIT 10; /*GreenHome Stores leads in revenue at ₦15.9 million
QuickTech NG has the most orders (42) and highest rating (4.17) among the top 10
All 10 sellers maintain a solid 4.0+ */