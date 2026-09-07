/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 06C_Customer_Employee_Relationship_Analysis.sql
Author  : Ashwini Dixit
Database: bank_db

PURPOSE:
This script analyzes the relationship between employee activities and
customer outcomes.

KEY AREAS ANALYZED:
1. Employee contribution to product acquisition
2. Employees generating the highest sales
3. Employees achieving both high sales and high customer satisfaction
4. Employees handling high customer interaction workloads
5. Identification of employees with high workload and low CSAT
6. Identification of employees with high sales but low CSAT

SQL CONCEPTS USED:
- CTEs
- Subqueries
- Multiple JOINs
- Aggregations
- Window functions
- Ranking
- Conditional filtering

BUSINESS OBJECTIVE:
To understand how employee behaviour and performance influence customer
acquisition, sales, service quality, and customer satisfaction.
======================================================================*/

USE bank_db;

/* =========================================================================
1. Which employees generate the highest product adoption?

Purpose:
Measure employee contribution to product acquisition and identify strong sales 
performers.
============================================================================*/

WITH employee_sales AS (
    SELECT
        co.emp_id,
        COUNT(co.product_id) AS products_sold,
        COUNT(DISTINCT co.cust_id) AS customers_acquired,
        SUM(COALESCE(co.amount, 0)) AS total_sales
    FROM customer_opted co
    WHERE co.emp_id IS NOT NULL
    GROUP BY co.emp_id
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    es.products_sold,
    es.customers_acquired,
    es.total_sales,
    RANK() OVER (
        ORDER BY es.total_sales DESC
    ) AS sales_rank
FROM employee_sales es
JOIN employees e
    ON es.emp_id = e.emp_id
ORDER BY sales_rank;


/* =========================================================================
2.Which employees are responsible for both high sales and high customer 
satisfaction?

Purpose:
Find employees who are strong in both acquisition and customer service, 
rather than optimizing only one metric.
============================================================================*/

WITH sales AS (
    SELECT
        emp_id,
        SUM(COALESCE(amount, 0)) AS total_sales
    FROM customer_opted
    GROUP BY emp_id
),
service AS (
    SELECT
        emp_id,
        AVG(csat) AS avg_csat
    FROM emp_cust_interaction
    GROUP BY emp_id
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    s.total_sales,
    sv.avg_csat
FROM employees e
JOIN sales s
    ON e.emp_id = s.emp_id
JOIN service sv
    ON e.emp_id = sv.emp_id
WHERE s.total_sales >= (
        SELECT AVG(total_sales)
        FROM sales
    )
AND sv.avg_csat >= (
        SELECT AVG(avg_csat)
        FROM service
    )
ORDER BY s.total_sales DESC, sv.avg_csat DESC;


/* =========================================================================
3. Which employees have high workloads but below-average customer 
satisfaction?

Purpose:
Identify employees who may be overloaded and require workload balancing or 
additional training.
============================================================================*/

WITH employee_metrics AS (
    SELECT
        emp_id,
        COUNT(interaction_id) AS interaction_count,
        AVG(csat) AS avg_csat
    FROM emp_cust_interaction
    GROUP BY emp_id
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    em.interaction_count,
    ROUND(em.avg_csat, 2) AS avg_csat
FROM employee_metrics em
JOIN employees e
    ON em.emp_id = e.emp_id
WHERE em.interaction_count > (
        SELECT AVG(interaction_count)
        FROM employee_metrics
    )
AND em.avg_csat < (
        SELECT AVG(avg_csat)
        FROM employee_metrics
    )
ORDER BY em.interaction_count DESC;


/* =========================================================================
4. Which employees have high sales but low customer satisfaction?

Purpose:
Identify potential cases where aggressive sales performance may be accompanied 
by poor customer experience.
============================================================================*/

WITH employee_sales AS (
    SELECT
        emp_id,
        SUM(COALESCE(amount, 0)) AS total_sales
    FROM customer_opted
    GROUP BY emp_id
),
employee_service AS (
    SELECT
        emp_id,
        AVG(csat) AS avg_csat
    FROM emp_cust_interaction
    GROUP BY emp_id
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    s.total_sales,
    sv.avg_csat
FROM employees e
JOIN employee_sales s
    ON e.emp_id = s.emp_id
JOIN employee_service sv
    ON e.emp_id = sv.emp_id
WHERE s.total_sales > (
        SELECT AVG(total_sales)
        FROM employee_sales
    )
AND sv.avg_csat < (
        SELECT AVG(avg_csat)
        FROM employee_service
    )
ORDER BY s.total_sales DESC;

