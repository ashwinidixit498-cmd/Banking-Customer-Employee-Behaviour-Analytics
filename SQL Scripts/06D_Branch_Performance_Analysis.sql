/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 06D_Branch_Performance_Analysis.sql
Author  : Ashwini Dixit
Database: bank_db

PURPOSE:
This script evaluates branch-level performance by combining customer,
employee, sales, and customer-service metrics.

KEY AREAS ANALYZED:
1. Branch-wise customer distribution
2. Branch-wise product sales and value
3. Branch-wise customer interactions
4. Branch-wise customer satisfaction
5. Branch-wise issue resolution performance
6. Employee productivity by branch
7. Branch-level performance comparison and ranking

SQL CONCEPTS USED:
- CTEs
- JOINs
- LEFT JOINs
- Aggregations
- Calculated metrics
- Window functions
- Ranking

BUSINESS OBJECTIVE:
To identify high-performing and underperforming branches and understand
how customer behaviour, employee productivity, sales, and service quality
vary across branches.
======================================================================*/

USE bank_db;

/* =========================================================================
1. Which branches perform best in terms of customers, products, sales and 
service?
============================================================================*/

WITH customer_metrics AS (
    SELECT
        branch_id,
        COUNT(*) AS total_customers,
        AVG(annual_income) AS avg_customer_income
    FROM customers
    GROUP BY branch_id
),
sales_metrics AS (
    SELECT
        e.branch_id,
        COUNT(co.product_id) AS products_sold,
        SUM(COALESCE(co.amount, 0)) AS total_sales
    FROM customer_opted co
    JOIN employees e
        ON co.emp_id = e.emp_id
    GROUP BY e.branch_id
),
service_metrics AS (
    SELECT
        branch_id,
        COUNT(interaction_id) AS total_interactions,
        AVG(csat) AS avg_csat,
        AVG(resolution_time_hrs) AS avg_resolution_time
    FROM emp_cust_interaction
    GROUP BY branch_id
)
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    b.state,
    b.branch_type,
    COALESCE(cm.total_customers, 0) AS total_customers,
    COALESCE(sm.products_sold, 0) AS products_sold,
    COALESCE(sm.total_sales, 0) AS total_sales,
    COALESCE(sv.total_interactions, 0) AS total_interactions,
    ROUND(COALESCE(sv.avg_csat, 0), 2) AS avg_csat,
    ROUND(COALESCE(sv.avg_resolution_time, 0), 2) AS avg_resolution_time
FROM branches b
LEFT JOIN customer_metrics cm
    ON b.branch_id = cm.branch_id
LEFT JOIN sales_metrics sm
    ON b.branch_id = sm.branch_id
LEFT JOIN service_metrics sv
    ON b.branch_id = sv.branch_id
ORDER BY total_sales DESC;


/* =========================================================================
2. Which branches have the highest employee productivity?

Purpose:
Compare branches based on employee count, sales, interactions and employee 
productivity.
============================================================================*/

WITH employee_metrics AS (
    SELECT
        e.branch_id,
        COUNT(DISTINCT e.emp_id) AS employee_count,
        COUNT(DISTINCT CASE 
            WHEN e.emp_status = 'Active' THEN e.emp_id 
        END) AS active_employees
    FROM employees e
    GROUP BY e.branch_id
),
sales_metrics AS (
    SELECT
        e.branch_id,
        SUM(COALESCE(co.amount, 0)) AS total_sales
    FROM customer_opted co
    JOIN employees e
        ON co.emp_id = e.emp_id
    GROUP BY e.branch_id
)
SELECT
    b.branch_id,
    b.branch_name,
    em.employee_count,
    em.active_employees,
    COALESCE(sm.total_sales, 0) AS total_sales,
    ROUND(
        COALESCE(sm.total_sales, 0) /
        NULLIF(em.active_employees, 0), 2
    ) AS sales_per_employee,
    RANK() OVER (
        ORDER BY
        COALESCE(sm.total_sales, 0) /
        NULLIF(em.active_employees, 0) DESC
    ) AS productivity_rank
FROM branches b
JOIN employee_metrics em
    ON b.branch_id = em.branch_id
LEFT JOIN sales_metrics sm
    ON b.branch_id = sm.branch_id
ORDER BY productivity_rank;