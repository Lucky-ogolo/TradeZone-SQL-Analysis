/*tradezone data cleaning for hng internship stage 2 by ohiole */

--EXPLORATORY ANALYSIS 

select count(*) from customers; 
SELECT COUNT(*) FROM orders; 
SELECT COUNT(*) FROM products; --
SELECT * FROM customers LIMIT 70;
SELECT * FROM sellers LIMIT 25;
SELECT * FROM orders LIMIT 30;
SELECT * FROM products LIMIT 30;
SELECT * FROM reviews LIMIT 35;
SELECT * FROM payments LIMIT 30;
/*865 customer records, 3015 orders,280 product.i could spot columns had nulls and some has inconsistencies */

--CHECKING FOR DUPLICATE EMAILS 
SELECT email, COUNT(*) 
FROM customers 
GROUP BY email 
HAVING COUNT(*) > 1; --there are about 16 duplicates

--CHECK FOR NEGATIVE PRICE
SELECT * FROM products 
WHERE unit_price < 0; --there are negative ratings and it seems there are invalid ratings

--CHECKING FOR NULLS 
SELECT COUNT(*) FROM customers 
WHERE customer_id IS NULL;
SELECT COUNT(*) FROM customers 
WHERE first_name IS NULL OR last_name IS NULL;

SELECT COUNT(*) FROM sellers
WHERE seller_name IS NULL 
OR onboarding_date IS NULL
OR city IS NULL
OR state IS NULL
OR account_status IS NULL;

SELECT COUNT(*) FROM products
WHERE product_name IS NULL
OR category IS NULL
OR unit_price IS NULL
OR seller_id IS NULL;

SELECT COUNT(*) FROM customers 
WHERE email IS NULL;
SELECT * FROM products
WHERE product_name IS NULL
OR category IS NULL
OR unit_price IS NULL
OR seller_id IS NULL;
SELECT COUNT(*) FROM orders
WHERE order_date IS NULL
OR order_status IS NULL
OR total_amount IS NULL;
SELECT COUNT(*) FROM order_items
WHERE quantity IS NULL
OR unit_price IS NULL
OR line_total IS NULL;

SELECT COUNT(*) FROM payments
WHERE payment_method IS NULL
OR amount IS NULL
OR payment_date IS NULL
OR order_id IS NULL;
SELECT COUNT(*) FROM reviews
WHERE rating IS NULL
OR review_date IS NULL
OR product_id IS NULL
OR customer_id IS NULL;

-- CHECKING FOR INCONSISTENCIES
SELECT DISTINCT state FROM customers ORDER BY state;
SELECT DISTINCT city FROM sellers ORDER BY city;
SELECT DISTINCT city FROM customers ORDER BY city;
SELECT rating FROM reviews WHERE rating < 1 OR rating > 5;
SELECT COUNT(*) FROM customers 
WHERE signup_date IS NULL;
SELECT DISTINCT account_status FROM customers;
SELECT DISTINCT state FROM sellers ORDER BY state;
SELECT DISTINCT city FROM sellers ORDER BY city;
SELECT DISTINCT product_category FROM sellers ORDER BY product_category;
SELECT DISTINCT account_status FROM sellers;
SELECT DISTINCT category FROM products ORDER BY category;
SELECT DISTINCT payment_method FROM payments;
SELECT DISTINCT rating FROM reviews ORDER BY rating;


SELECT COUNT(*) FROM payments
WHERE amount <= 0;


-- FURTHER INVESTIGATING THE TABLES TO CHECK FOR THE NULLS
SELECT 

    COUNT(*) FILTER (WHERE order_date IS NULL) as null_order_date,
    COUNT(*) FILTER (WHERE delivery_date IS NULL) as null_delivery,
    COUNT(*) FILTER (WHERE order_status IS NULL) as null_status,
    COUNT(*) FILTER (WHERE total_amount IS NULL) as null_amount

FROM orders;

SELECT 
    COUNT(*) FILTER (WHERE quantity IS NULL) as null_qty,
    COUNT(*) FILTER (WHERE unit_price IS NULL) as null_price,
    COUNT(*) FILTER (WHERE line_total IS NULL) as null_line_total
FROM order_items;

SELECT 
    COUNT(*) FILTER (WHERE payment_method IS NULL) as null_method,
    COUNT(*) FILTER (WHERE amount IS NULL) as null_amount,
    COUNT(*) FILTER (WHERE payment_date IS NULL) as null_date
FROM payments;
-- ============================================================
/* DUPLICATE CUSTOMERS
 16 duplicate email addresses found in customers table.
duplicates cannot be deleted as affected customer records are referenced in the orders table.
Deleting them would orphan existing order records. Duplicates are flagged here for awareness but retained to preserve data integrity.*/
-- ============================================================

-- Identify duplicate emails for documentation purposes
SELECT email, COUNT(*) as duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- city and state names had spacing and casing issues
-- Used trim and init to fix this across customers table
UPDATE customers
SET city = INITCAP(TRIM(city)),
    state = INITCAP(TRIM(state)); --updated 865 records

-- Fixed casing and spacing issues in sellers city and product category
UPDATE sellers
SET city = INITCAP(TRIM(city)),
    product_category = INITCAP(TRIM(product_category)); -- updated 90 rows

-- Fixed casing and spacing issues in products category
UPDATE products
SET category = INITCAP(TRIM(category)); --updated 280 records

-- Check which products have NULL unit prices
SELECT * FROM products
WHERE unit_price IS NULL;

/*NULL unit prices found in 4 products Cannot delete as products are referenced in order_items.
Updating unit_price from order_items where available*/
UPDATE products p
SET unit_price = (
    SELECT AVG(oi.unit_price)
    FROM order_items oi
    WHERE oi.product_id = p.product_id
    AND oi.unit_price IS NOT NULL
)
WHERE p.unit_price IS NULL; --4 products updated

--97 rows in order_items had NULL unit_price and line_total,these records cannot be used for revenue analysis.
--deleting them as no price information can be recovered
DELETE FROM order_items
WHERE unit_price IS NULL
OR line_total IS NULL;

-- 150 orders found with NULL total_amount
-- Updating total_amount by calculating sum from order_items
UPDATE orders o
SET total_amount = (
    SELECT SUM(line_total)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
)
WHERE o.total_amount IS NULL;

-- Check if NULL payment amounts can be recovered from orders
SELECT p.payment_id, o.total_amount
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.amount IS NULL
LIMIT 10;

-- Updating NULL payment amounts from orders total_amount
-- where order total is available
UPDATE payments p
SET amount = (
    SELECT o.total_amount
    FROM orders o
    WHERE o.order_id = p.order_id
    AND o.total_amount IS NOT NULL
)
WHERE p.amount IS NULL; --155 updated

SELECT COUNT(*) FROM payments
WHERE amount IS NULL;

/*12 payment records remain with NULL amounts after recovery attempt,corresponding orders also have no total_amount available.
deleting these records as they cannot be used for payment analysis*/
DELETE FROM payments
WHERE amount IS NULL;

-- 8 invalid ratings found in reviews table
/*Ratings must be between 1 and 5, values outside this range
are impossible and unusable for analysis, deleting them*/
DELETE FROM reviews
WHERE rating < 1 OR rating > 5; --5 deleted

--running checks 
SELECT DISTINCT rating FROM reviews ORDER BY rating;
SELECT COUNT(*) FROM customers; --865
SELECT COUNT(*) FROM orders;--3015
SELECT COUNT(*) FROM products;--280
SELECT COUNT(*) FROM order_items;--6329
SELECT COUNT(*) FROM payments;--2250
SELECT COUNT(*) FROM reviews;--812

SELECT DISTINCT city FROM customers ORDER BY city;
SELECT DISTINCT city FROM sellers ORDER BY city;
SELECT DISTINCT category FROM products ORDER BY category;
SELECT DISTINCT product_category FROM sellers ORDER BY product_category;
SELECT DISTINCT order_status FROM orders ORDER BY order_status;
SELECT DISTINCT account_status FROM customers ORDER BY account_status;
SELECT DISTINCT account_status FROM sellers ORDER BY account_status;
SELECT DISTINCT payment_method FROM payments ORDER BY payment_method;

-- Fixing inconsistent city names in customers table
UPDATE customers
SET city = CASE
    WHEN city = 'Lago S' THEN 'Lagos'
    WHEN city = 'Port-Harcourt' THEN 'Port Harcourt'
    WHEN city = 'Portharcourt' THEN 'Port Harcourt'
    ELSE city
END
WHERE city IN ('Lago S', 'Port-Harcourt', 'Portharcourt'); --105 updated

-- Fixing inconsistent city names in sellers table
UPDATE sellers
SET city = CASE
    WHEN city = 'Lago S' THEN 'Lagos'
    WHEN city = 'Port-Harcourt' THEN 'Port Harcourt'
    WHEN city = 'Portharcourt' THEN 'Port Harcourt'
    ELSE city
END
WHERE city IN ('Lago S', 'Port-Harcourt', 'Portharcourt');--17 updated

SELECT DISTINCT city FROM customers ORDER BY city;
SELECT DISTINCT city FROM sellers ORDER BY city;

-- Fixing inconsistent category names in products table
UPDATE products
SET category = CASE
    WHEN category IN ('Beauty', 'Beauty And Personal Care') THEN 'Beauty & Personal Care'
    WHEN category IN ('Books', 'Books And Stationery') THEN 'Books & Stationery'
    WHEN category = 'Electronis' THEN 'Electronics'
    WHEN category = 'Fashon' THEN 'Fashion'
    WHEN category IN ('Food', 'Food And Beverages') THEN 'Food & Beverages'
    WHEN category = 'Home And Garden' THEN 'Home & Garden'
    WHEN category IN ('Sports', 'Sports And Fitness') THEN 'Sports & Fitness'
    ELSE category
END;--280 fixed

-- Fixing inconsistent product_category names in sellers table
UPDATE sellers
SET product_category = CASE
    WHEN product_category IN ('Beauty', 'Beauty And Personal Care') THEN 'Beauty & Personal Care'
    WHEN product_category IN ('Books', 'Books And Stationery') THEN 'Books & Stationery'
    WHEN product_category = 'Electronis' THEN 'Electronics'
    WHEN product_category = 'Fashon' THEN 'Fashion'
    WHEN product_category IN ('Food', 'Food And Beverages') THEN 'Food & Beverages'
    WHEN product_category = 'Home And Garden' THEN 'Home & Garden'
    WHEN product_category IN ('Sports', 'Sports And Fitness') THEN 'Sports & Fitness'
    ELSE product_category
END;--90 updated
SELECT DISTINCT category FROM products ORDER BY category;
SELECT DISTINCT product_category FROM sellers ORDER BY product_category;

-- Checking if order total_amount matches sum of order_items line totals
-- Flagging orders where difference is greater than 10
SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.line_total) as items_total,
    ABS(o.total_amount - SUM(oi.line_total)) as difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY difference DESC;

-- Checking the scale of differences between order totals and item sums
SELECT 
    MIN(difference) as min_difference,
    MAX(difference) as max_difference,
    AVG(difference) as avg_difference
FROM (
    SELECT 
        ABS(o.total_amount - SUM(oi.line_total)) as difference
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.total_amount
    HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
) as flagged_orders;

/*124 orders found where total_amount differs from sum of order_items
by more than 10 Naira. Differences range from 99.63 to 326,748.16
These could be due to discounts, delivery fees or data entry errors
Flagging these orders for awareness but retaining them*/
SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.line_total) as items_total,
    ABS(o.total_amount - SUM(oi.line_total)) as difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY difference DESC;