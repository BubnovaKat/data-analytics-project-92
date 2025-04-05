--count dictinct customers from table customers
SELECT 
COUNT(DISTINCT customer_id) as customers_count
FROM customers;