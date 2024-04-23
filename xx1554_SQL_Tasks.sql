--List Department details (ID, Name, Location) which does not have any employees 
SELECT
    dept_id,
    dept_name,
    location
FROM
    xx1554_dept d,
    xx1554_emp  e
WHERE
        d.dept_id = e.emp_dept_id (+)
    AND e.emp_id IS NULL;

--List all employees whose salary is greater than average salary of all employees 
SELECT
    emp_name
FROM
    xx1554_emp
WHERE
    emp_salary > (
        SELECT
            AVG(emp_salary)
        FROM
            xx1554_emp
    );

--List all employees who are getting the lowest salary 
SELECT
    emp_name,
    emp_salary
FROM
    xx1554_emp
WHERE
    emp_salary = (
        SELECT
            MIN(emp_salary)
        FROM
            xx1554_emp
    );

SELECT
    emp_name,
    emp_salary
FROM
    xx1554_emp
ORDER BY
    emp_salary
FETCH FIRST 1 ROW ONLY;

--List customer wise sales 
SELECT
    c.name,
    SUM(o.amount) sales
FROM
    xx1554_customers c,
    xx1554_orders    o
WHERE
    c.customer_id = o.order_id
GROUP BY
    c.name
ORDER BY
    SUM(o.amount);

--List Year wise, month wise Sales 
SELECT
    to_char(order_date, 'YYYY') years,
    SUM(amount)                 AS sales
FROM
    xx1554_orders
GROUP BY
    to_char(order_date, 'YYYY')
ORDER BY
    sales;

SELECT
    to_char(order_date, 'MONTH') months,
    SUM(amount)                  AS sales
FROM
    xx1554_orders
GROUP BY
    to_char(order_date, 'MONTH')
ORDER BY
    sales;

--List Year wise, month wise Direct Sales, Online Sales separately 
SELECT
    to_char(order_date, 'YYYY') years,
    SUM(amount)                 AS sales
FROM
    xx1554_orders
WHERE
    order_mode = 'DIRECT'
GROUP BY
    to_char(order_date, 'YYYY');
    
SELECT
    to_char(order_date, 'YYYY') years,
    SUM(amount)                 AS sales
FROM
    xx1554_orders
WHERE
    order_mode = 'ONLINE'
GROUP BY
    to_char(order_date, 'YYYY');

SELECT
    to_char(order_date, 'MONTH') months,
    SUM(amount)                  AS sales
FROM
    xx1554_orders
WHERE
    order_mode = 'DIRECT'
GROUP BY
    to_char(order_date, 'MONTH');
SELECT
    to_char(order_date, 'MONTH') months,
    SUM(amount)                  AS sales
FROM
    xx1554_orders
WHERE
    order_mode = 'ONLINE'
GROUP BY
    to_char(order_date, 'MONTH');

--List customers who are exceeding their credit limits 
SELECT
    c.name,
    ( ot.quantity * ot.unit_price ) expenditure,
    c.credit_limit
FROM
         xx1554_customers c
    JOIN xx1554_orders      o ON c.customer_id = o.customer_id
    JOIN xx1554_order_items ot ON o.order_id = ot.order_id
WHERE
    ( ot.quantity * ot.unit_price ) > c.credit_limit;

--List all employees who were holding more than one Job in various periods in the company 
SELECT
    e.first_name,
    j.company
FROM
    xx1554_employees e,
    xx1554_jobs      j
WHERE
    e.employee_id = j.employee_id
GROUP BY
    e.first_name,
    j.company
HAVING
    COUNT(*) > 1;

--List all employees with their first job 
SELECT
    e.first_name,
    j.company
FROM
    xx1554_employees e,
    xx1554_jobs      j
WHERE
        e.employee_id = j.employee_id
    AND j.experience = 'Fresher';

--How any “orderable” products available  
SELECT
    COUNT(product_id) orderable_products
FROM
    xx1554_products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            xx1554_inventories
    );

--How to find top three highest salary in emp table in oracle? 
SELECT
    e.first_name,
    j.salary
FROM
    xx1554_employees e,
    xx1554_jobs      j
WHERE
    e.employee_id = j.employee_id
ORDER BY
    j.salary DESC
FETCH FIRST 3 ROWS ONLY;

--SQL Query to find fifth highest salary with empno 
SELECT
    first_name,
    salary
FROM
    (
        SELECT
            e.first_name,
            j.salary,
            DENSE_RANK()
            OVER(
                ORDER BY
                    j.salary DESC
            ) "RANK"
        FROM
            xx1554_employees e,
            xx1554_jobs      j
        WHERE
            e.employee_id = j.employee_id
    )
WHERE
    "RANK" = 5;

--What is the total on-hand quantity of all products 
SELECT
    SUM(quantity)
FROM
    xx1554_inventories;

--List the products does not have stock 
SELECT
    product_name
FROM
    xx1554_products
WHERE
    product_id NOT IN (
        SELECT
            product_id
        FROM
            xx1554_inventories
    );

--List the items which can be ordered 
SELECT
    product_name
FROM
    xx1554_products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            xx1554_inventories
    );

--Get the order details for one order 
SELECT
    *
FROM
    xx1554_orders
WHERE
    order_id = :order_id;

--Verify whether the order_total is calculated correctly or not 
SELECT
    order_id,
    product_id,
    unit_price,
    quantity,
    ( quantity * unit_price ) AS order_total
FROM
    xx1554_order_items
WHERE
    order_id = :order_id;

--List the items which are ordered 
SELECT
    product_name
FROM
    xx1554_products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            xx1554_order_items
    );

--List of items which are not yet ordered 
SELECT
    product_name
FROM
    xx1554_products
WHERE
    product_id NOT IN (
        SELECT
            product_id
        FROM
            xx1554_order_items
    );

--List the Order details where items are ordered less than the list price 
SELECT
    *
FROM
         xx1554_orders o
    JOIN xx1554_order_items ot ON o.order_id = ot.order_id
    JOIN xx1554_products    p ON ot.product_id = p.product_id
WHERE
    ot.unit_price < p.list_price;

--List the Order details where items are ordered less than the minimum price 
SELECT
    *
FROM
         xx1554_orders o
    JOIN xx1554_order_items ot ON o.order_id = ot.order_id
    JOIN xx1554_products    p ON ot.product_id = p.product_id
WHERE
    ot.unit_price < p.standard_cost;

--Find the profit of each order line (compare minimum price with order) 
SELECT
    ot.order_id,
    ot.product_id,
    p.standard_cost,
    ot.unit_price,
    ( ot.unit_price - p.standard_cost ) profit
FROM
         xx1554_order_items ot
    JOIN xx1554_products p ON ot.product_id = p.product_id;

--Find the profit of each order and its %
SELECT
    ot.order_id,
    SUM(ot.unit_price - p.standard_cost)                                     profit,
    round(SUM(ot.unit_price - p.standard_cost) / SUM(p.standard_cost) * 100) "PROFIT_%"
FROM
         xx1556_order_items ot
    JOIN xx1556_products p ON ot.product_id = p.product_id
GROUP BY
    ot.order_id;

--Create table xx100_product by copying only orderable items from product master 
CREATE TABLE xx1554_product
    AS
        SELECT
            *
        FROM
            xx1554_inventories
        WHERE
            quantity > 0;

SELECT
    *
FROM
    xx1554_product;

--Take backup of employee master 
CREATE VIEW xx1554_employees_master AS
    SELECT
        *
    FROM
        xx1554_employees;

SELECT
    *
FROM
    xx1554_employees_master;

--Create table xx100_employee with (id, full_name, salary) and copy data from employee master 
CREATE TABLE xx1554_employee
    AS
        (
            SELECT
                emp_id     AS id,
                emp_name   AS full_name,
                emp_salary AS salary
            FROM
                xx1554_emp
        );

SELECT
    *
FROM
    xx1554_employee;

--In new table xx100_employee increment salary by 10% 
SELECT
    id,
    salary,
    ( salary * ( 10 / 100 ) )              AS hike,
    ( salary + ( salary * ( 10 / 100 ) ) ) AS new_salary
FROM
    xx1554_employee;