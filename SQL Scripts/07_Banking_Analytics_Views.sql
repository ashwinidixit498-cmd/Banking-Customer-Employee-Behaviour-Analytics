/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 07_Banking_Analytics_Views.sql
Author  : Ashwini Dixit
Database: bank_db

PURPOSE:
This script creates reusable SQL views that combine and transform data from
multiple banking tables into analysis-ready datasets for reporting and
business intelligence.

VIEWS CREATED:
1. vw_customer_behavior
   - Customer demographics
   - Customer segment
   - Product adoption
   - Product value
   - Interaction volume
   - Customer satisfaction
   - Resolution performance

2. vw_employee_performance
   - Employee demographics
   - Department and designation
   - Experience
   - Sales performance
   - Training
   - Attendance
   - Performance rating
   - Customer interactions
   - Customer satisfaction
   - Resolution performance

3. vw_branch_performance
   - Branch information
   - Customer count
   - Product sales
   - Sales value
   - Employee productivity
   - Interaction volume
   - Customer satisfaction
   - Resolution performance

PURPOSE OF USING VIEWS:
- Simplify complex queries for Power BI
- Create reusable analytical datasets
- Reduce repeated SQL logic
- Provide consistent business metrics
- Separate data preparation from visualization
- Create a clean SQL-to-Power BI data pipeline

POWER BI USAGE:
The views created in this script will be imported into Power BI as
analysis-ready datasets for dashboard development.
======================================================================*/


-- ======================================
-- View 1: Customer Behaviour
-- ======================================

CREATE VIEW vw_customer_behavior AS

SELECT
    c.cust_id,
    c.cust_name,
    c.gender,
    c.age,
    c.city,
    c.occupation,
    c.annual_income,
    c.cust_segment,
    c.acc_type,
    c.digital_banking_user,
    c.pref_channel,

    COUNT(co.product_id) AS products_opted,
    SUM(COALESCE(co.amount, 0)) AS total_product_amount,

    COUNT(eci.interaction_id) AS total_interactions,
    AVG(eci.csat) AS avg_csat,
    AVG(eci.resolution_time_hrs) AS avg_resolution_time

FROM customers c

LEFT JOIN customer_opted co
    ON c.cust_id = co.cust_id

LEFT JOIN emp_cust_interaction eci
    ON c.cust_id = eci.cust_id

GROUP BY
    c.cust_id,
    c.cust_name,
    c.gender,
    c.age,
    c.city,
    c.occupation,
    c.annual_income,
    c.cust_segment,
    c.acc_type,
    c.digital_banking_user,
    c.pref_channel;
    
select * from vw_customer_behavior;


-- ======================================
-- View 2: Employee Performance
-- ======================================

CREATE VIEW vw_employee_performance AS

SELECT
    e.emp_id,
    e.emp_name,
    e.gender,
    e.age,
    e.designation,
    e.department,
    e.branch_id,
    e.experience,
    e.salary,

    AVG(ep.sales_target) AS avg_sales_target,
    AVG(ep.training_hrs) AS avg_training_hours,
    AVG(ep.attendence_percentage) AS avg_attendance,

    AVG(
        CASE ep.perf_rating
            WHEN 'Excellent' THEN 5
            WHEN 'Very Good' THEN 4
            WHEN 'Good' THEN 3
            WHEN 'Average' THEN 2
            WHEN 'Poor' THEN 1
        END
    ) AS avg_performance_score,

    COUNT(eci.interaction_id) AS total_interactions,
    AVG(eci.csat) AS avg_csat,
    AVG(eci.resolution_time_hrs) AS avg_resolution_time

FROM employees e

LEFT JOIN emp_performance ep
    ON e.emp_id = ep.emp_id

LEFT JOIN emp_cust_interaction eci
    ON e.emp_id = eci.emp_id

GROUP BY
    e.emp_id,
    e.emp_name,
    e.gender,
    e.age,
    e.designation,
    e.department,
    e.branch_id,
    e.experience,
    e.salary;
    
select * from vw_employee_performance;


-- ======================================
-- View 3: Branch Performance
-- ======================================

CREATE VIEW vw_branch_performance AS
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

select * from vw_branch_performance;