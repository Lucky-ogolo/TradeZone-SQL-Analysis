-- Question 5: Customer Spend Segmentation
-- Grouping customers by total spend in 2024
-- High Spenders: 100,000 and above
-- Medium Spenders: 50,000 to 99,999
-- Low Spenders: below 50,000

WITH customer_spend AS (
    SELECT 
        c.customer_id,
        SUM(o.total_amount) as total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY c.customer_id
),
segmented AS (
    SELECT 
        customer_id,
        total_spend,
        CASE 
            WHEN total_spend >= 100000 THEN 'High Spenders'
            WHEN total_spend >= 50000 THEN 'Medium Spenders'
            ELSE 'Low Spenders'
        END as spend_segment
    FROM customer_spend
)
SELECT 
    spend_segment,
    COUNT(customer_id) as customer_count,
    ROUND(AVG(total_spend)::numeric, 2) as avg_spend,
    ROUND(SUM(total_spend)::numeric, 2) as total_revenue
FROM segmented
GROUP BY spend_segment
ORDER BY total_revenue DESC; --high Spenders completely dominate, medium and low spenders have 25 and 49 customers repectively