/*Question 3: Seller delivery efficiency.
Calculating average delivery time in hours per seller for delivered orders and sellers with at least 20 orders*/

WITH seller_fulfilment AS (
    SELECT 
        o.seller_id,
        s.seller_name,
        COUNT(o.order_id) as total_completed_orders,
        AVG(EXTRACT(EPOCH FROM (o.delivery_date::timestamp - o.order_date::timestamp)) / 3600) as avg_hours
    FROM orders o
    JOIN sellers s ON o.seller_id = s.seller_id
    WHERE o.order_status = 'Delivered'
    AND o.delivery_date IS NOT NULL
    GROUP BY o.seller_id, s.seller_name
    HAVING COUNT(o.order_id) >= 20
),
seller_ratings AS (
    SELECT 
        p.seller_id,
        ROUND(AVG(r.rating), 2) as avg_rating
    FROM reviews r
    JOIN products p ON r.product_id = p.product_id
    GROUP BY p.seller_id
)
SELECT 
    f.seller_name,
    f.total_completed_orders,
    ROUND(f.avg_hours::numeric, 2) as avg_fulfilment_hours,
    sr.avg_rating
FROM seller_fulfilment f
LEFT JOIN seller_ratings sr ON f.seller_id = sr.seller_id
ORDER BY avg_fulfilment_hours ASC
LIMIT 20;
--RunFast NG is the fastest seller,QuickTech NG is the slowest,some sellers that are fast have low rating