/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 06B_Employee_Behaviour_Analysis.sql
Author  : Ashwini Dixit
Database: bank_db

PURPOSE:
This script analyzes employee behaviour, productivity, and performance
across different dimensions.

KEY AREAS ANALYZED:
1. Identification of top-performing employees
2. Relationship between training and performance
3. Relationship between attendance and performance
4. Employee interaction workload
5. Employee-level customer satisfaction
6. Employee issue-resolution efficiency

SQL CONCEPTS USED:
- CTEs
- JOINs
- GROUP BY and aggregations
- CASE statements
- Window functions
- Ranking functions
- Calculated metrics

BUSINESS OBJECTIVE:
To evaluate employee productivity and performance, identify high performers,
and identify employees who may require additional training or workload
balancing.
======================================================================*/

USE bank_db;

/* =========================================================================
1. Who are the top-performing employees?

Purpose:
Rank employees based on performance rating, sales target, 
training and attendance.
============================================================================*/

WITH employee_score AS (
    SELECT
        e.emp_id,
        e.emp_name,
        e.designation,
        e.department,
        e.branch_id,
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
        ) AS avg_rating_score
    FROM employees e
    JOIN emp_performance ep
        ON e.emp_id = ep.emp_id
    GROUP BY
        e.emp_id,
        e.emp_name,
        e.designation,
        e.department,
        e.branch_id
),
ranked_employees AS (
    SELECT *,
        RANK() OVER (
            ORDER BY avg_rating_score DESC,
                     avg_sales_target DESC
        ) AS employee_rank
    FROM employee_score
)
SELECT *
FROM ranked_employees
WHERE employee_rank <= 20;


/* =========================================================================
2. Does employee training influence performance rating?

Purpose:
Determine whether employees with more training tend to receive better
performance ratings.
============================================================================*/

WITH training_performance AS (
    SELECT
        CASE
            WHEN ep.training_hrs < 10 THEN 'Low Training'
            WHEN ep.training_hrs BETWEEN 10 AND 20 THEN 'Medium Training'
            ELSE 'High Training'
        END AS training_group,
        AVG(ep.attendence_percentage) AS avg_attendance,
        AVG(ep.sales_target) AS avg_sales_target,
        AVG(
            CASE ep.perf_rating
                WHEN 'Excellent' THEN 5
                WHEN 'Very Good' THEN 4
                WHEN 'Good' THEN 3
                WHEN 'Average' THEN 2
                WHEN 'Poor' THEN 1
            END
        ) AS avg_rating
    FROM emp_performance ep
    GROUP BY
        CASE
            WHEN ep.training_hrs < 10 THEN 'Low Training'
            WHEN ep.training_hrs BETWEEN 10 AND 20 THEN 'Medium Training'
            ELSE 'High Training'
        END
)
SELECT *
FROM training_performance
ORDER BY avg_rating DESC;


/* =========================================================================
3. Does attendance have a relationship with employee performance?

Purpose:
Analyze whether employees with higher attendance demonstrate better 
performance.
============================================================================*/

SELECT
    CASE
        WHEN ep.attendence_percentage < 75 THEN 'Below 75%'
        WHEN ep.attendence_percentage < 90 THEN '75%-90%'
        ELSE '90%+'
    END AS attendance_group,
    COUNT(DISTINCT ep.emp_id) AS employees,
    AVG(ep.sales_target) AS avg_sales_target
FROM emp_performance ep
GROUP BY
    CASE
        WHEN ep.attendence_percentage < 75 THEN 'Below 75%'
        WHEN ep.attendence_percentage < 90 THEN '75%-90%'
        ELSE '90%+'
    END
ORDER BY avg_sales_target DESC;


/* =========================================================================
4. Which employees handle the highest number of customer interactions?

Purpose:
Measure employee workload and identify employees handling a high volume of 
customer service activity.
============================================================================*/

WITH employee_interactions AS (
    SELECT
        emp_id,
        COUNT(interaction_id) AS total_interactions,
        AVG(resolution_time_hrs) AS avg_resolution_time,
        AVG(csat) AS avg_csat
    FROM emp_cust_interaction
    GROUP BY emp_id
),
ranked_employees AS (
    SELECT *,
        RANK() OVER (
            ORDER BY total_interactions DESC
        ) AS workload_rank
    FROM employee_interactions
)
SELECT
    r.*,
    e.emp_name,
    e.designation,
    e.department
FROM ranked_employees r
JOIN employees e
    ON r.emp_id = e.emp_id
ORDER BY workload_rank;


/* =========================================================================
5. Which employees have the best customer satisfaction scores?

Purpose:
Measure employee effectiveness from the customer's perspective.
============================================================================*/

WITH employee_csat AS (
    SELECT
        emp_id,
        COUNT(interaction_id) AS interactions_handled,
        AVG(csat) AS avg_csat
    FROM emp_cust_interaction
    GROUP BY emp_id
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    ec.interactions_handled,
    ROUND(ec.avg_csat, 2) AS avg_csat,
    RANK() OVER (
        ORDER BY ec.avg_csat DESC
    ) AS csat_rank
FROM employee_csat ec
JOIN employees e
    ON ec.emp_id = e.emp_id
WHERE ec.interactions_handled >= 10
ORDER BY csat_rank;


/* =========================================================================
6. Which employees are efficient at resolving customer issues?

Purpose:
Identify employees who achieve good customer satisfaction while maintaining 
low resolution time.
============================================================================*/

WITH employee_service AS (
    SELECT
        emp_id,
        AVG(resolution_time_hrs) AS avg_resolution_time,
        AVG(csat) AS avg_csat,
        COUNT(interaction_id) AS interaction_count
    FROM emp_cust_interaction
    GROUP BY emp_id
),
employee_score AS (
    SELECT *,
        (
            avg_csat * 0.6
            + (1.0 / NULLIF(avg_resolution_time, 0)) * 0.4
        ) AS efficiency_score
    FROM employee_service
)
SELECT
    e.emp_id,
    e.emp_name,
    e.designation,
    es.interaction_count,
    es.avg_resolution_time,
    es.avg_csat,
    RANK() OVER (
        ORDER BY efficiency_score DESC
    ) AS efficiency_rank
FROM employee_score es
JOIN employees e
    ON es.emp_id = e.emp_id
ORDER BY efficiency_rank;