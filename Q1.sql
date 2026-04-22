-- Q1:
/* Customer Acquisition & 30-Day Conversion,identifying new customers who signed up in 2024
 and which ones made a purchase within 30 days grouping  by state and pick the top 5 */

WITH new_customers_2024 AS (
    SELECT 
        customer_id,
        state,
        signup_date
    FROM customers
    WHERE EXTRACT(YEAR FROM signup_date) = 2024
),
early_buyers AS (
    SELECT DISTINCT 
        c.customer_id
    FROM new_customers_2024 c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_date <= c.signup_date + INTERVAL '30 days'
)
SELECT 
    c.state,
    COUNT(DISTINCT c.customer_id) as new_customers,
    COUNT(DISTINCT e.customer_id) as converted_customers,
    ROUND(COUNT(DISTINCT e.customer_id) * 100.0 / 
    COUNT(DISTINCT c.customer_id), 2) as conversion_percentage
FROM new_customers_2024 c
LEFT JOIN early_buyers e ON c.customer_id = e.customer_id
GROUP BY c.state
ORDER BY new_customers DESC
LIMIT 5;   
/*Lagos is both the biggest market and the best at converting new customers quickly.
Kano signs up customers but struggles to get them to buy.*/