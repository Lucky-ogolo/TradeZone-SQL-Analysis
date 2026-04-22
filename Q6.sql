-- Q6: 
/*Payment Method Preferences by State.
analysing which payment methods are most popular in each state 
by joining payments,orders and customers to get state information*/

WITH payment_by_state AS (
    SELECT 
        c.state,
        p.payment_method,
        COUNT(p.payment_id) as transaction_count,
        ROUND(SUM(p.amount)::numeric, 2) as total_amount
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.state, p.payment_method
),
most_popular AS (
    SELECT DISTINCT ON (state)
        state,
        payment_method as most_popular_method,
        transaction_count
    FROM payment_by_state
    ORDER BY state, transaction_count DESC
)
SELECT 
    pb.state,
    pb.payment_method,
    pb.transaction_count,
    pb.total_amount,
    mp.most_popular_method
FROM payment_by_state pb
JOIN most_popular mp ON pb.state = mp.state
ORDER BY pb.state, pb.transaction_count DESC; --card is most popular in Lagos, FCT and Rivers
--cash on Delivery dominates in Kano and Oyo