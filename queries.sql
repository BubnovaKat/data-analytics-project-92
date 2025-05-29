--count dictinct customers from table customers
SELECT COUNT(DISTINCT customer_id) AS customers_count
FROM customers;

--top ten sellers by total income
SELECT
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    COUNT(sales.sales_id) AS operations,
    SUM(sales.quantity * products.price) AS income
FROM sales
LEFT JOIN products ON sales.product_id = products.product_id
LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY employees.first_name, employees.last_name
ORDER BY income DESC LIMIT 10;

--show employees, that selles below total average
SELECT
    seller,
    average_income
FROM (
    SELECT
        seller,
        average_income,
        FLOOR(AVG(average_income) OVER ()) AS total_average
    FROM (
        SELECT
            CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
            FLOOR(AVG(sales.quantity * products.price)) AS average_income
        FROM sales
        LEFT JOIN products ON sales.product_id = products.product_id
        LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
        GROUP BY employees.first_name, employees.last_name
    ) AS employee_sales
) AS with_total
WHERE average_income < total_average
ORDER BY average_income;

-- Show total income for every salesperson by weekday
SELECT
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    TO_CHAR(sales.sale_date, 'FMday') AS day_of_week,
    FLOOR(SUM(sales.quantity * products.price)) AS income
FROM employees
INNER JOIN sales ON employees.employee_id = sales.sales_person_id
INNER JOIN products ON sales.product_id = products.product_id
GROUP BY
    employees.first_name,
    employees.last_name,
    TO_CHAR(sales.sale_date, 'FMday'),
    EXTRACT(ISODOW FROM sales.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM sales.sale_date),
    seller;

--count customers into age categories 
--step 6
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

--counting unique customers by month and total 
--income within that month
--step 6
SELECT
    TO_CHAR(DATE_TRUNC('month', sales.sale_date), 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT customers.customer_id) AS total_customers,
    FLOOR(SUM(sales.quantity * products.price)) AS income
FROM sales
LEFT JOIN customers ON sales.customer_id = customers.customer_id
LEFT JOIN products ON sales.product_id = products.product_id
GROUP BY TO_CHAR(DATE_TRUNC('month', sales.sale_date), 'YYYY-MM')
ORDER BY selling_month;

-- selecting all customers, who has made their first purchase via action
-- step 6
SELECT
    CONCAT(customers.first_name, ' ', customers.last_name) AS customer,
    sales.sale_date::DATE AS sale_date,
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller
FROM (
    SELECT
        sales.*,
        ROW_NUMBER() OVER (PARTITION BY sales.customer_id 
        ORDER BY sales.sale_date) AS rn
    FROM sales
    LEFT JOIN products ON sales.product_id = products.product_id
    WHERE products.price = 0
) AS sales
LEFT JOIN customers ON sales.customer_id = customers.customer_id
LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
WHERE sales.rn = 1
ORDER BY sales.customer_id;
