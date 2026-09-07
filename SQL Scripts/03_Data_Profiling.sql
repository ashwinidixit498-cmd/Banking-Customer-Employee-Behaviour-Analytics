/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 03_Data_Profiling.sql
Author  : Ashwini Dixit
Database: bank_db

Purpose:
Profiles all raw datasets before ETL. This script performs database
overview, row counts, sample inspection, duplicate checks, NULL analysis,
domain validation, numeric summaries, date validation and relationship
validation.
======================================================================*/

USE bank_db;

-- ==========================================================
-- 1. DATABASE OVERVIEW
-- ==========================================================

SHOW TABLES;

-- ==========================================================
-- 2. ROW COUNTS
-- ==========================================================

SELECT 'raw_branches' AS Table_Name, COUNT(*) AS Total_Records FROM raw_branches
UNION ALL
SELECT 'raw_customers', COUNT(*) FROM raw_customers
UNION ALL
SELECT 'raw_customer_opted_products', COUNT(*) FROM raw_customer_opted_products
UNION ALL
SELECT 'raw_employees', COUNT(*) FROM raw_employees
UNION ALL
SELECT 'raw_employee_customer_interaction', COUNT(*) FROM raw_employee_customer_interaction
UNION ALL
SELECT 'raw_employee_performance', COUNT(*) FROM raw_employee_performance;

-- ==========================================================
-- 3. SAMPLE DATA
-- ==========================================================

SELECT * FROM raw_branches LIMIT 5;
SELECT * FROM raw_customers LIMIT 5;
SELECT * FROM raw_employees LIMIT 5;
SELECT * FROM raw_employee_customer_interaction LIMIT 5;
SELECT * FROM raw_customer_opted_products LIMIT 5;
SELECT * FROM raw_employee_performance LIMIT 5;

-- ==========================================================
-- 4. DUPLICATE CHECKS
-- ==========================================================

SELECT branch_id,COUNT(*) Duplicate_Count
FROM raw_branches
GROUP BY branch_id
HAVING COUNT(*)>1;

SELECT customer_id,COUNT(*) Duplicate_Count
FROM raw_customers
GROUP BY customer_id
HAVING COUNT(*)>1;

SELECT employee_id,COUNT(*) Duplicate_Count
FROM raw_employees
GROUP BY employee_id
HAVING COUNT(*)>1;

SELECT Customer_Product_ID,COUNT(*)Duplicate_Count
FROM raw_customer_opted_products
GROUP BY customer_Product_id
HAVING COUNT(*)>1;

SELECT interaction_id,COUNT(*)Duplicate_Count
FROM raw_employee_customer_interaction
GROUP BY interaction_id
HAVING COUNT(*)>1;

SELECT Performance_id,COUNT(*)Duplicate_Count
FROM raw_employee_performance
GROUP BY Performance_ID
HAVING COUNT(*)>1;

-- ==========================================================
-- 5. NULL ANALYSIS (examples)
-- ==========================================================

SELECT
SUM(branch_id IS NULL),
SUM(branch_name IS NULL),
SUM(city IS NULL),
SUM(state IS NULL),
SUM(branch_type IS NULL),
SUM(manager_employee_id IS NULL),
SUM(opening_date IS NULL),
SUM(branch_status IS NULL)
FROM raw_branches;


SELECT
 SUM(customer_product_id is null),
 SUM(customer_id is null),
 SUM(product_name is null),
 SUM(product_category is null),
 SUM(opted_date is null),
 SUM(product_status is null),
 SUM(acquisition_channel is null),
 SUM(employee_id is null),
 sum(amount is null)
 FROM raw_Customer_opted_products;
 
 SELECT 
 SUM(Customer_ID is null),
 SUM(Customer_Name is null),
 SUM(Gender is null),
 SUM(Age is null),
 SUM(City is null),
 SUM(Occupation is null),
 SUM(Annual_Income is null),
 SUM(Customer_Segment is null),
 SUM(Join_Date is null),
 SUM(Account_Type is null),
 SUM(Digital_Banking_User is null),
 SUM(Preferred_Channel is null),
 SUM(Branch_id is null)
 FROM raw_customers;


SELECT
SUM(Interaction_ID is null),
SUM(Customer_ID is null),
SUM(Employee_ID is null),
SUM(Branch_ID is null),
SUM(Interaction_date is null),
SUM(interaction_channel is null),
SUM(Interaction_type is null),
SUM(Issue_Severity is null),
SUM(Resolution_Status is null),
SUM(Resolution_Time_Hours is null),
SUM(Customer_Satisfaction_Score is null),
SUM(Interaction_duration_minutes is null)
From raw_employee_customer_interaction;

SELECT
SUM(Performance_ID is null),
SUM(Employee_ID is null),
SUM(Performance_Month is null),
SUM(Sales_Target is null),
SUM(Training_Hours is null),
SUM(attendance_percent is null),
SUM(performance_rating is null)
From raw_employee_performance;

SELECT
SUM(Employee_ID is null),
SUM(employee_name is null),
SUM(gender is null),
SUM(age is null),
SUM(designation is null),
SUM(department is null),
SUM(branch_id is null),
SUM(joining_date is null),
SUM(experience_years is null),
SUM(salary is null),
SUM(employee_status is null)
From raw_employees;

select * from raw_branches;