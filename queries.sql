--count dictinct customers from table customers
SELECT 
COUNT(DISTINCT customer_id) as customers_count
FROM customers;

--top ten sellers by total income
SELECT 
CONCAT(employees.first_name, ' ', employees.last_name) as seller,
COUNT(sales.sales_id) as operations,
SUM(sales.quantity * products.price) as income
FROM sales
LEFT JOIN products ON sales.product_id = products.product_id
LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY employees.first_name, employees.last_name
ORDER BY income DESC LIMIT 10;

--show employees, that selles below total average
WITH employee_sales AS (
    SELECT 
        CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
        ROUND(SUM(sales.quantity * products.price) / COUNT(sales.sales_id), 0) AS avg_emp_income
    FROM sales 
    LEFT JOIN products ON sales.product_id = products.product_id
    LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
    GROUP BY e.first_name, e.last_name
),
total_average AS (
    SELECT 
        ROUND(SUM(sales.quantity * products.price) / COUNT(sales.sales_id), 0) AS total_avg
    FROM sales
    LEFT JOIN products ON s.product_id = products.product_id
)

SELECT 
    employee_sales.seller,
    employee_sales.avg_emp_income
FROM employee_sales
CROSS JOIN total_average 
WHERE employee_sales.avg_emp_income < total_average.total_avg
ORDER BY employee_sales.avg_emp_income;

--show average income for evely salesperson for various weekday, sorted by weekday name
WITH sales_by_day AS (
  SELECT 
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    TO_CHAR(sales.sale_date, 'FMDay') AS day_name,
    CASE 
      WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7
      ELSE EXTRACT(DOW FROM s.sale_date)
    END AS day_order,
    ROUND(SUM(sales.quantity * products.price), 0) AS income
  FROM sales
  LEFT JOIN products ON sales.product_id = products.product_id
  LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
  GROUP BY employees.first_name, employees.last_name, TO_CHAR(sales.sale_date, 'FMDay'), day_order
)

SELECT 
  seller,
  day_name,
  income
FROM sales_by_day
ORDER BY day_order, seller;

--count customers into age categories 
--step 6
SELECT 
    age_category,
    COUNT(customer) AS age_count
FROM (
    SELECT customer_id AS customer,
           CASE 
               WHEN age BETWEEN 16 AND 25 THEN '16-25'
               WHEN age BETWEEN 26 AND 40 THEN '26-40'
               ELSE '40+'
           END AS age_category
    FROM customers
) AS age_categories
GROUP BY age_category
ORDER BY age_category;

--counting unique customers by month and total income within that month
--step 6
SELECT 
COUNT(DISTINCT customers.customer_id) as total_customers,
ROUND(SUM(sales.quantity*products.price), 0) as income,
TO_CHAR(DATE_TRUNC('month', sales.sale_date), 'YYYY-MM') AS selling_month
FROM sales
LEFT JOIN customers ON customers.customer_id = sales.customer_id
LEFT JOIN products ON products.product_id = sales.product_id
GROUP BY TO_CHAR(DATE_TRUNC('month', sales.sale_date), 'YYYY-MM')
ORDER BY selling_month;

-- selecting all customers, who has made their first purchase via action
-- step 6
WITH all_first_action_sales AS (
    SELECT DISTINCT ON (customers.customer_id)
        customers.customer_id AS id,
        CONCAT(customers.first_name, ' ', customers.last_name) AS customer,
        sales.sale_date::DATE AS sale_date,
        products.price AS price,
        CONCAT(employees.first_name, ' ', employees.last_name) AS seller
    FROM sales
    LEFT JOIN customers ON sales.customer_id = customers.customer_id
    LEFT JOIN products ON sales.product_id = products.product_id
    LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
    WHERE products.price = 0
    ORDER BY customers.customer_id, sales.sale_date 
)

SELECT 
all_first_action_sales.customer,
all_first_action_sales.sale_date,
all_first_action_sales.seller
FROM all_first_action_sales
ORDER BY all_first_action_sales.id;





