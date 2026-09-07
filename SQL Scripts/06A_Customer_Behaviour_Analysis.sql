/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 06A_Customer_Behaviour_Analysis.sql
Author  : Ashwini Dixit
Database: bank_db

PURPOSE:
This script analyzes customer behaviour and banking engagement patterns.

KEY AREAS ANALYZED:
1. Customer segment-wise product adoption
2. Top customers based on product adoption and value
3. Customers who have not opted for any banking product
4. Multi-product customer behaviour
5. Effectiveness of product acquisition channels
6. Preferred interaction channels across customer segments
7. Customers generating high volumes of interactions
8. Digital banking adoption and interaction behaviour

SQL CONCEPTS USED:
- CTEs
- Subqueries
- JOINs
- GROUP BY and aggregations
- CASE statements
- Window functions
- Conditional logic

BUSINESS OBJECTIVE:
To understand customer engagement, product adoption, interaction patterns,
and potential cross-selling opportunities.
======================================================================*/

-- =======================================================
--  Understanding Table Schema
-- =======================================================

USE bank_db;

show tables;

/*
1. branches -> (branch_id(pk), branch_name, city, state, branch_type, manager_emp_id(fk_br_emp), opening_date, branch_status)
2. employees -> (emp_id(pk), emp_name, gender, age, designation, department, branch_id(fk_emp_branch), join_date, experience, salary, emp_status)
3. customers -> (cust_id(pk), cust_name, gender, age, city, occupation, annual_income, cust_segment, join_date, acc_type, digital_banking_user, pref_channel, branch_id(fk_cust_branch))
4. customer_opted -> (product_id(pk), cust_id(fk_co_cust), product_name, product_category, opted_date, product_status, aquisitionn_channel, emp_id, amount)
5. emp_cust_interaction -> (interaction_id(pk), cust_id(fk_eci_cust), emp_id(fk_eci_emp), branch_id(fk_eci_branch), interaction_date, interaction_channel, interaction_type, issue_severity, resolution_status, resolution_time_hrs, csat, interaction_duration_min)
6. emp_performance -> (perf_id(pk), emp_id(fk_ep_emp), perf_month_sales_target, taining_hrs, attendence_percentage, perf_rating)
*/


/* =========================================================================
1. Which customer segments generate the highest banking product adoption?

Purpose:
Identify which customer segments are most valuable based on the number 
of products opted for and total amount associated with those products. 
============================================================================*/

WITH customer_product AS (
    SELECT 
        c.cust_segment,
        c.cust_id,
        COUNT(co.product_id) AS products_opted,
        SUM(COALESCE(co.amount, 0)) AS total_product_amount
    FROM customers c
    LEFT JOIN customer_opted co
        ON c.cust_id = co.cust_id
    GROUP BY c.cust_segment, c.cust_id
)
SELECT
    cust_segment,
    COUNT(cust_id) AS total_customers,
    SUM(products_opted) AS total_products_opted,
    ROUND(AVG(products_opted * 1.0), 2) AS avg_products_per_customer,
    SUM(total_product_amount) AS total_amount
FROM customer_product
GROUP BY cust_segment
ORDER BY total_amount DESC;


/* =========================================================================
2. Who are the top customers based on product adoption?

Purpose:
Find high-value/multi-product customers who can be targeted for 
cross-selling and relationship management. 
============================================================================*/

WITH customer_summary AS (
    SELECT
        c.cust_id,
        c.cust_name,
        c.cust_segment,
        c.annual_income,
        COUNT(co.product_id) AS total_products,
        SUM(COALESCE(co.amount, 0)) AS total_amount
    FROM customers c
    LEFT JOIN customer_opted co
        ON c.cust_id = co.cust_id
    GROUP BY
        c.cust_id,
        c.cust_name,
        c.cust_segment,
        c.annual_income
),
ranked_customers AS (
    SELECT *,
        DENSE_RANK() OVER (
            ORDER BY total_products DESC, total_amount DESC
        ) AS customer_rank
    FROM customer_summary
)
SELECT *
FROM ranked_customers
WHERE customer_rank <= 20;


/* =========================================================================
3. Which customers have not opted for any banking product?

Purpose:
Identify untapped customers and potential cross-selling opportunities.
============================================================================*/

SELECT
    c.cust_id,
    c.cust_name,
    c.cust_segment,
    c.annual_income,
    c.city,
    c.acc_type,
    c.digital_banking_user
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM customer_opted co
    WHERE co.cust_id = c.cust_id
)
ORDER BY c.annual_income DESC;


/* =========================================================================
4. Which customers have opted for multiple products?

Purpose:
Identify highly engaged customers and understand multi-product 
adoption behaviour.
============================================================================*/

WITH product_count AS (
    SELECT
        cust_id,
        COUNT(DISTINCT product_id) AS product_count
    FROM customer_opted
    GROUP BY cust_id
)
SELECT
    c.cust_id,
    c.cust_name,
    c.cust_segment,
    pc.product_count
FROM product_count pc
JOIN customers c
    ON c.cust_id = pc.cust_id
WHERE pc.product_count > 1
ORDER BY pc.product_count DESC;


/* =========================================================================
5. Which acquisition channels are most effective?

Purpose:
Compare acquisition channels based on customers acquired, products sold, 
and total amount.
============================================================================*/

WITH channel_analysis AS (
    SELECT
        co.aquisition_channel,
        COUNT(DISTINCT co.cust_id) AS customers_acquired,
        COUNT(co.product_id) AS products_sold,
        SUM(COALESCE(co.amount, 0)) AS total_amount
    FROM customer_opted co
    GROUP BY co.aquisition_channel
)
SELECT *
FROM channel_analysis
ORDER BY total_amount DESC;


/* =========================================================================
6. What is the preferred interaction channel for different customer segments?

Purpose:
Understand how different customer groups prefer to interact with the bank.
============================================================================*/

WITH channel_usage AS (
    SELECT
        c.cust_segment,
        eci.interaction_channel,
        COUNT(*) AS interaction_count
    FROM customers c
    JOIN emp_cust_interaction eci
        ON c.cust_id = eci.cust_id
    GROUP BY
        c.cust_segment,
        eci.interaction_channel
),
ranked_channels AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY cust_segment
            ORDER BY interaction_count DESC
        ) AS channel_rank
    FROM channel_usage
)
SELECT *
FROM ranked_channels
WHERE channel_rank = 1;


/* =========================================================================
7. Which customers generate the most support interactions?

Purpose:
Identify customers requiring high service attention and investigate possible 
dissatisfaction or service complexity.
============================================================================*/

WITH interaction_summary AS (
    SELECT
        cust_id,
        COUNT(interaction_id) AS total_interactions,
        AVG(csat) AS avg_csat,
        AVG(resolution_time_hrs) AS avg_resolution_time
    FROM emp_cust_interaction
    GROUP BY cust_id
),
ranked_customers AS (
    SELECT *,
        RANK() OVER (
            ORDER BY total_interactions DESC
        ) AS interaction_rank
    FROM interaction_summary
)
SELECT
    r.*,
    c.cust_name,
    c.cust_segment
FROM ranked_customers r
JOIN customers c
    ON r.cust_id = c.cust_id
WHERE interaction_rank <= 20;


/* =========================================================================
8. Does digital banking adoption influence customer interaction behaviour?

Purpose:
Compare interaction volume and channels between digital and 
non-digital customers.
============================================================================*/

WITH customer_interactions AS (
    SELECT
        c.digital_banking_user,
        COUNT(eci.interaction_id) AS total_interactions,
        COUNT(DISTINCT c.cust_id) AS customers
    FROM customers c
    LEFT JOIN emp_cust_interaction eci
        ON c.cust_id = eci.cust_id
    GROUP BY c.digital_banking_user
)
SELECT
    digital_banking_user,
    customers,
    total_interactions,
    ROUND(
        total_interactions * 1.0 / NULLIF(customers, 0), 2
    ) AS interactions_per_customer
FROM customer_interactions;