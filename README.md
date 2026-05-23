# SQL Analytics Portfolio

**T-SQL · PostgreSQL · CTEs · Window Functions · Multi-table Analysis**

A collection of analytical SQL queries demonstrating real-world business intelligence patterns
built with PostgreSQL and T-SQL.

## Skills demonstrated
| Concept | Description |
|---------|-------------|
| CTEs | Layered, readable query logic using Common Table Expressions |
| Window functions | RANK, ROW_NUMBER, LAG/LEAD, running totals with PARTITION BY |
| Multi-table analysis | Complex joins with variance analysis across departments |
| Aggregations | CASE WHEN logic, NULLIF safe division, GROUP BY patterns |

## Queries in this repo

### 01 — CTE project completion analysis
Calculates completion rates per project using CTEs for readable, layered logic.
Demonstrates safe division with NULLIF and percentage formatting.

### 02 — Window function department ranking
Uses RANK() OVER PARTITION BY to rank projects within each department.
Includes ROW_NUMBER, DENSE_RANK, and LAG/LEAD for trend comparisons.

### 03 — Two-table variance analysis
Joins a projects table to a departments table to compare each project's
completion rate against its department average. Highlights over and underperformers.

### 04 — Department performance summary
Aggregates project metrics by department with CASE WHEN performance tiers
(High / On Track / At Risk) based on completion thresholds.

## How to run
1. Set up PostgreSQL locally via pgAdmin
2. Create the sample tables using the scripts in `/datasets`
3. Run any `.sql` file in `/queries` against your local database

---
Built by Alejandra Kheng · [LinkedIn](https://linkedin.com/in/alejandra-g-952a58143/)
