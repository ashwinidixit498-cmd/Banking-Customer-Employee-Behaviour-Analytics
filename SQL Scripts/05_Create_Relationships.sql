/*======================================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 05_Create_Relationships.sql
Author  : Ashwini Dixit
Database: bank_db

Purpose:
Creating relationships withing tables by defining foreign keys.
======================================================================*/

ALTER TABLE branches
ADD CONSTRAINT fk_employee_branch
FOREIGN KEY (manager_emp_id) REFERENCES employees(emp_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE employees
ADD CONSTRAINT fk_emp_branch
FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE customers
ADD CONSTRAINT fk_cust_branch
FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE customer_opted
ADD CONSTRAINT fk_co_cust
FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
ON DELETE SET NULL
ON UPDATE CASCADE,
ADD CONSTRAINT fk_co_emp
FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE emp_performance
ADD CONSTRAINT fk_perf_emp
FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE emp_cust_interaction
ADD CONSTRAINT fk_eci_cust
FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
ON DELETE SET NULL
ON UPDATE CASCADE,
ADD CONSTRAINT fk_eci_emp
FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
ON DELETE SET NULL
ON UPDATE CASCADE,
ADD CONSTRAINT fk_eci_branch
FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
ON DELETE SET NULL
ON UPDATE CASCADE;