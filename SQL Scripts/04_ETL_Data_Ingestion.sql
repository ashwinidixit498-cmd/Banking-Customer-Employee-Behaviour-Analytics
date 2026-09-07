/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 04_ETL_Data_Ingestion.sql
Author  : Ashwini Dixit
Database: bank_db

Purpose:
Transfering data from raw staging tables to operational tables.
======================================================================*/

USE bank_db;

START TRANSACTION;

-- ============================================================================
-- ETL : Branches
-- ============================================================================
TRUNCATE TABLE branches;

INSERT INTO branches
(branch_id, branch_name, city, state,
branch_type, manager_emp_id, opening_date, 
branch_status)
select trim(branch_id),
trim(lower(branch_name)),
trim(lower(city)),
trim(lower(state)),
trim(lower(branch_type)),
trim(Manager_employee_id),
str_to_date(opening_date, '%d-%m-%Y'),
trim(lower(branch_status))
from raw_branches;

select count(*) from branches;

select * from branches;

-- ============================================================================
-- ETL : Employees
-- ============================================================================
TRUNCATE TABLE employees;

INSERT INTO employees
(emp_id, emp_name, gender, age, designation,
department, branch_id, join_date, experience,
salary, emp_status)
select 
trim(employee_id),
trim(lower(employee_name)),
trim(lower(gender)),
cast(trim(age) as signed),
trim(lower(designation)),
trim(lower(department)),
trim(branch_id),
str_to_date(joining_date, '%d-%m-%Y'),
cast(trim(Experience_Years) as decimal(10,2)),
cast(trim(salary) as signed),
trim(lower(employee_status))
from raw_employees;

select count(*) from employees;

select * from employees;


-- ============================================================================
-- ETL : Customers
-- ============================================================================
TRUNCATE TABLE customers;

INSERT INTO customers
(cust_id, cust_name, gender, age, 
city, occupation, annual_income, cust_segment,
join_date, acc_type, digital_banking_user, 
pref_channel, branch_id)
select 
trim(Customer_ID),
trim(lower(Customer_Name)),
trim(lower(gender)),
cast(trim(age) as signed),
trim(lower(city)),
trim(lower(occupation)),
cast(trim(annual_income) as signed),
trim(lower(Customer_Segment)),
str_to_date(join_date, '%d-%m-%Y'),
trim(lower(account_type)),
trim(lower(digital_banking_user)),
trim(lower(preferred_channel)),
trim(branch_id)
from raw_customers;

select count(*) from customers;

select * from customers;


-- ============================================================================
-- ETL : Customer Opted
-- ============================================================================
TRUNCATE TABLE customer_opted;

INSERT INTO customer_opted
(product_id, cust_id, product_name,
product_category, opted_date, product_status,
aquisition_channel, emp_id, amount)
select
trim(Customer_Product_ID),
trim(customer_id),
trim(lower(product_name)),
trim(lower(product_category)),
str_to_date(opted_date, '%d-%m-%Y'),
trim(lower(product_status)),
trim(lower(acquisition_channel)),
trim(employee_id),
cast(trim(amount) as signed)
from raw_customer_opted_products;

select count(*) from customer_opted;

select * from customer_opted;


-- ============================================================================
-- ETL : Employee Performance
-- ============================================================================
TRUNCATE TABLE emp_performance;

INSERT INTO emp_performance(
perf_id, emp_id, perf_month,sales_target, 
training_hrs, attendence_percentage, perf_rating)
select trim(performance_id),
trim(employee_id),
str_to_date(Performance_month, '%Y-%m-%d'),
cast(trim(sales_target) as signed),
cast(trim(training_hours) as decimal(10,2)),
cast(trim(Attendance_Percent) as decimal(10,2)),
trim(lower(performance_rating))
from raw_employee_performance;

select count(*) from emp_performance;

select * from emp_performance;


-- ============================================================================
-- ETL : Employee Customer Interaction
-- ============================================================================
TRUNCATE TABLE emp_cust_interaction;

INSERT INTO emp_cust_interaction
(interaction_id, cust_id, emp_id, branch_id,
interaction_date, interaction_channel, interaction_type,
issue_severity, resolution_status, resolution_time_hrs,
csat, interaction_duration_min)
select 
trim(interaction_id), 
trim(Customer_ID),
trim(Employee_ID),
trim(Branch_ID),
str_to_date(Interaction_date, '%d-%m-%Y'),
trim(lower(interaction_channel)),
trim(lower(interaction_type)),
trim(lower(issue_severity)),
trim(lower(resolution_status)),
cast(trim(resolution_time_hours) as decimal(10,2)),
cast(trim(customer_satisfaction_score) as decimal(10,2)),
cast(trim(interaction_duration_minutes) as signed)
from raw_employee_customer_interaction;

select count(*) from emp_cust_interaction;

select * from emp_cust_interaction;