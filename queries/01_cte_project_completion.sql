-- ============================================================
-- Query 01: Project Completion Rate Analysis
-- Author: Alejandra Kheng
-- Description: Calculates project completion rates per department
--              using CTEs for readable, layered logic.
--              Demonstrates safe division, percentage formatting,
--              and performance tier classification.
-- ============================================================

-- Step 1: Create sample tables (run once to set up)
CREATE TABLE IF NOT EXISTS departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS projects (
    project_id       INT PRIMARY KEY,
    project_name     VARCHAR(100),
    department_id    INT REFERENCES departments(department_id),
    completed_tasks  INT,
    total_tasks      INT,
    due_date         DATE
);

-- Step 2: Insert sample data
INSERT INTO departments VALUES
    (1, 'Clinical Operations'),
    (2, 'Health Informatics'),
    (3, 'Quality Assurance'),
    (4, 'Data & Analytics');

INSERT INTO projects VALUES
    (101, 'EHR Migration',          1, 45, 50,  '2024-03-01'),
    (102, 'Patient Intake Redesign',1, 20, 50,  '2024-04-15'),
    (103, 'BI Dashboard Rollout',   2, 48, 50,  '2024-02-28'),
    (104, 'Claims Data Cleanup',    2, 30, 50,  '2024-05-01'),
    (105, 'Audit Prep Q1',          3, 50, 50,  '2024-01-31'),
    (106, 'Compliance Review',      3, 35, 50,  '2024-03-15'),
    (107, 'Data Quality Framework', 4, 42, 50,  '2024-04-01'),
    (108, 'Report Automation',      4, 15, 50,  '2024-06-01');

-- ============================================================
-- MAIN QUERY
-- ============================================================

WITH project_rates AS (
    -- Calculate completion rate per project
    SELECT
        p.project_id,
        p.project_name,
        p.department_id,
        p.completed_tasks,
        p.total_tasks,
        ROUND(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100, 1
        ) AS completion_pct
    FROM projects p
),

dept_averages AS (
    -- Calculate average completion rate per department
    SELECT
        d.department_id,
        d.department_name,
        ROUND(AVG(
            CAST(pr.completed_tasks AS NUMERIC)
            / NULLIF(pr.total_tasks, 0) * 100
        ), 1) AS dept_avg_pct,
        COUNT(pr.project_id) AS total_projects
    FROM departments d
    LEFT JOIN project_rates pr
        ON d.department_id = pr.department_id
    GROUP BY d.department_id, d.department_name
)

SELECT
    pr.project_id,
    pr.project_name,
    da.department_name,
    pr.completion_pct                              AS project_pct,
    da.dept_avg_pct                                AS dept_avg_pct,
    ROUND(pr.completion_pct - da.dept_avg_pct, 1) AS variance_vs_avg,
    da.total_projects,
    CASE
        WHEN pr.completion_pct >= 90 THEN 'High'
        WHEN pr.completion_pct >= 60 THEN 'On Track'
        ELSE                              'At Risk'
    END AS performance_tier
FROM project_rates pr
JOIN dept_averages da
    ON pr.department_id = da.department_id
ORDER BY da.department_name, pr.completion_pct DESC;
