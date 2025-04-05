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
WITH averaged AS (
SELECT 
CONCAT(employees.first_name, ' ', employees.last_name) as seller,
ROUND(SUM(sales.quantity * products.price)/COUNT(sales.sales_id), 0) as avg_emp_income,
ROUND(
    SUM(SUM(sales.quantity * products.price)) OVER () / SUM(COUNT(sales.sales_id)) OVER (), 
    0
  ) AS total_avg
FROM sales
LEFT JOIN products ON sales.product_id = products.product_id
LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
GROUP BY employees.first_name, employees.last_name
ORDER BY avg_emp_income desc)

SELECT 
seller,
avg_emp_income
FROM averaged 
WHERE avg_emp_income < total_avg
order by avg_emp_income;

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