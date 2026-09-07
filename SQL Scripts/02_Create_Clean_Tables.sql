/*=============================================================
Project : Banking Customer & Employee Behaviour Analysis
File : 02_Create_Clean_Tables.sql
Author  : Ashwini Dixit
Database: bank_db

Purpose:
Creates the cleaned operational tables that are needed for 
Analysing Banks customer and Employees behaviour. 
==============================================================*/

use bank_db;

-- ============================================================
-- Branches
-- ============================================================

DROP TABLE IF EXISTS Branches;

CREATE TABLE Branches(
branch_id varchar(10) primary key,
branch_name varchar(30) not null,
city varchar(20),
state varchar(20),
branch_type varchar(20),
manager_emp_id varchar(20),
opening_date date,
branch_status varchar(10));

-- ============================================================
-- Customers
-- ============================================================

DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers(
cust_id varchar(20) primary key,
cust_name varchar(30) not null,
gender varchar(20),
age int,
city varchar(20),
occupation varchar(20),
annual_income int,
cust_segment varchar(20),
join_date date,
acc_type varchar(20),
digital_banking_user varchar(10),
pref_channel varchar(20),
branch_id varchar(10));

-- ============================================================
-- Employees
-- ============================================================

DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees(
emp_id varchar(20) primary key,
emp_name varchar(20),
gender varchar(20),
age int,
designation varchar(30),
department varchar(20),
branch_id varchar(10),
join_date date,
experience float,
salary int,
emp_status varchar(20)
);

-- ============================================================
-- customer Opted
-- ============================================================

DROP TABLE IF EXISTS Customer_Opted;

CREATE TABLE Customer_Opted(
product_id varchar(20) primary key,
cust_id varchar(20),
product_name varchar(20),
product_category varchar(20),
opted_date date,
product_status varchar(20),
aquisition_channel varchar(20),
emp_id varchar(10),
amount int);


-- ============================================================
-- Employee Customer Interaction
-- ============================================================

DROP TABLE IF EXISTS emp_cust_interaction;

CREATE TABLE emp_cust_interaction(
interaction_id varchar(20) primary key,
cust_id varchar(20),
emp_id varchar(20),
branch_id varchar(20),
interaction_date date,
interaction_channel varchar(20),
interaction_type varchar(20),
issue_severity varchar(20),
resolution_status varchar(20),
resolution_time_hrs float,
csat float,
interaction_duration_min int);


-- ============================================================
-- Employee Performance
-- ============================================================

DROP TABLE IF EXISTS emp_performance;

CREATE TABLE emp_performance(
perf_id varchar(20) primary key,
emp_id varchar(20),
perf_month date,
sales_target int,
training_hrs float,
attendence_percentage float,
perf_rating varchar(20));