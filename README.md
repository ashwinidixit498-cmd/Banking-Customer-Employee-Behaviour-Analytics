# 🏦 Digital Banking Analytics | SQL + Power BI

## 📌 Project Overview

**Digital Banking Analytics** is an end-to-end data analytics project built using **SQL and Power BI** to analyze customer behavior, banking product adoption, employee performance, customer interactions, and branch performance.

The project uses a **synthetically generated banking dataset** containing 6 interconnected tables. SQL was used for database creation, data profiling, cleaning, ETL, relationship creation, business analysis, and development of analytical SQL views. The resulting views were then connected to Power BI to create interactive dashboards for business reporting and decision-making.

The complete workflow follows:

> **Raw CSV Data → SQL Database → Data Profiling → Data Cleaning → ETL → Relationships → SQL Analysis → SQL Views → Power BI Dashboard**

---

## 🎯 Business Objectives

The project aims to answer key banking business questions:

- How are customers distributed across different segments?
- Which banking products and categories have the highest adoption?
- What is the relationship between digital banking usage and product adoption?
- Which acquisition channels generate the highest product value?
- Which branches have the highest customer interactions and product value?
- How do employee training, attendance, and performance relate?
- How do customer satisfaction and resolution time vary?
- Which customer segments contribute the most business value?

---

## 🗂️ Dataset

The synthetic dataset contains **6 relational tables**:

| Table | Records | Purpose |
|---|---:|---|
| `branches` | 50 | Branch master data |
| `customers` | 10,000 | Customer demographics and banking details |
| `customer_opted` | 18,450 | Customer product adoption |
| `employees` | 500 | Employee master data |
| `emp_cust_interaction` | 65,000 | Customer-employee interactions |
| `emp_performance` | 6,000 | Monthly employee performance |

The dataset was generated using **Gemini** for portfolio and educational purposes.

---

## 🛠️ SQL Workflow

The SQL implementation is divided into structured stages:

1. **Database Creation**
2. **Clean Table Creation**
3. **Data Profiling**
4. **ETL / Data Ingestion**
5. **Relationship Creation**
6. **Customer Behaviour Analysis**
7. **Employee Behaviour Analysis**
8. **Customer-Employee Relationship Analysis**
9. **Branch Performance Analysis**
10. **Banking Analytics Views**

The project uses primary keys and foreign keys to establish relationships between customers, employees, branches, products, interactions, and performance data.

---

## 📊 SQL Analytical Views

Three business-ready SQL views were created for Power BI:

### `vw_customer_behavior`

Provides customer-level metrics including:

- Products opted
- Total product amount
- Total interactions
- Average CSAT
- Average resolution time
- Customer segment
- Digital banking usage

### `vw_employee_performance`

Combines employee information with:

- Average sales target
- Training hours
- Attendance
- Performance score
- Customer interactions
- CSAT
- Resolution time

### `vw_branch_performance`

Provides branch-level KPIs including:

- Total customers
- Products sold
- Total sales
- Customer interactions
- Average CSAT
- Average resolution time

---

## 📈 Power BI Dashboards

The Power BI report contains **3 interactive dashboard pages**.

### 1. 🏦 Banking Executive Overview

Provides a high-level view of:

- Total Customers
- Total Employees
- Total Branches
- Products Opted
- Customer Interactions
- Average CSAT
- Average Resolution Time
- Product Adoption Trend
- Customer Segment Distribution
- Digital Banking Usage
- Product Adoption by Category

### 2. 👥 Customer Behaviour & Product Analytics

Focuses on:

- Customer product value
- Product adoption
- Product categories
- Acquisition channels
- Customer segments
- Digital banking usage
- Multi-product customers
- Product adoption rate

### 3. 👨‍💼 Employee & Branch Performance

Analyzes:

- Employee performance
- Training hours
- Attendance
- Performance ratings
- Customer interactions
- Branch product value
- Branch performance

---

## 🔧 Tools & Technologies

- **SQL** – Database design, cleaning, ETL, analysis and views
- **Power BI** – Data visualization and interactive dashboards
- **CSV** – Raw data source
- **Gemini** – Synthetic dataset generation
- **GitHub** – Project documentation and version control

---

## 📁 Project Structure

```text
Digital-Banking-Analytics/
│
├── Data/
├── SQL/
│   ├── 01_Database_Creation.sql
│   ├── 02_Create_Clean_Tables.sql
│   ├── 03_Data_Profiling.sql
│   ├── 04_ETL_Data_Ingestion.sql
│   ├── 05_Create_Relationships.sql
│   ├── 06A_Customer_Behaviour_Analysis.sql
│   ├── 06B_Employee_Behaviour_Analysis.sql
│   ├── 06C_Customer_Employee_Relationship_Analysis.sql
│   ├── 06D_Branch_Performance_Analysis.sql
│   └── 07_Banking_Analytics_Views.sql
│
├── PowerBI/
│   └── Digital_Banking_Analytics.pbix
│
└── README.md
---
## 👩‍💻 Author

### **Ashwini Dixit**
**Aspiring Data Analyst**
