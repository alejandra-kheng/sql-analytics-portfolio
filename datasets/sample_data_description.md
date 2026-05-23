# Sample Dataset Description

This repository uses a simulated healthcare project tracking dataset
modeled after real-world operational data in behavioral health environments.

## Tables

### departments
Represents organizational units within a healthcare system.

| Column | Type | Description |
|--------|------|-------------|
| department_id | INT | Primary key |
| department_name | VARCHAR | Name of the department |

**Sample departments:**
- Clinical Operations
- Health Informatics
- Quality Assurance
- Data & Analytics

---

### projects
Represents projects tracked within each department.

| Column | Type | Description |
|--------|------|-------------|
| project_id | INT | Primary key |
| project_name | VARCHAR | Name of the project |
| department_id | INT | Foreign key to departments |
| completed_tasks | INT | Number of tasks completed |
| total_tasks | INT | Total tasks in the project |
| due_date | DATE | Project due date |

---

## How to set up locally

1. Open pgAdmin and connect to your local PostgreSQL instance
2. Open Query Tool
3. Run the `CREATE TABLE` and `INSERT` scripts found in
   `queries/01_cte_project_completion.sql`
4. Once tables are created, all 4 queries in the `queries/` folder
   will run successfully against the same dataset

---

## Data note
All data is synthetic and created for portfolio demonstration purposes.
Domain is inspired by healthcare project management and clinical operations
reporting — reflecting real analytical patterns used in behavioral health
and enterprise IT environments.
