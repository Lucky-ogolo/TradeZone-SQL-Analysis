/*Q7: Review Ratings and Sales Performance
-- Grouping products by average rating into High, Mid and Low categories
-- Joined products, reviews and order_items for revenue calculation*/

WITH product_ratings AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.unit_price,
        AVG(r.rating) as avg_rating,
        SUM(oi.line_total) as total_revenue
    FROM products p
    JOIN reviews r ON p.product_id = r.product_id
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.unit_price
),
rated AS (
    SELECT *,
        CASE 
            WHEN avg_rating >= 4.0 THEN 'High Rated'
            WHEN avg_rating >= 3.0 THEN 'Mid Rated'
            ELSE 'Low Rated'
        END as rating_category
    FROM product_ratings
)
SELECT 
    rating_category,
    COUNT(product_id) as product_count,
    ROUND(SUM(total_revenue)::numeric, 2) as total_revenue,
    ROUND(AVG(unit_price)::numeric, 2) as avg_unit_price
FROM rated
GROUP BY rating_category
ORDER BY total_revenue DESC; /*mid Rated products actually generate the most revenue,
high rated came 2nd and i suspect it might be due to low vale,ow Rated products still generate ₦322 million*/