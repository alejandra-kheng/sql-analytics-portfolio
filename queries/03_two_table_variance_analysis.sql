-- ============================================================
-- Query 03: Two-Table Variance Analysis
-- Author: Alejandra Kheng
-- Description: Joins projects to departments to compare each
--              project's completion rate against its department
--              average. Identifies over and underperformers
--              using variance analysis and percentile ranking.
-- ============================================================

WITH dept_summary AS (
    -- Department-level aggregations
    SELECT
        d.department_id,
        d.department_name,
        COUNT(p.project_id)                                    AS total_projects,
        ROUND(AVG(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100
        ), 1)                                                  AS dept_avg_pct,
        ROUND(MIN(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100
        ), 1)                                                  AS dept_min_pct,
        ROUND(MAX(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100
        ), 1)                                                  AS dept_max_pct
    FROM departments d
    LEFT JOIN projects p
        ON d.department_id = p.department_id
    GROUP BY d.department_id, d.department_name
),

project_detail AS (
    -- Project-level metrics with window functions
    SELECT
        p.project_id,
        p.project_name,
        p.department_id,
        p.completed_tasks,
        p.total_tasks,
        ROUND(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100, 1
        )                                                      AS project_pct,

        -- Percentile rank within department
        ROUND(
            PERCENT_RANK() OVER (
                PARTITION BY p.department_id
                ORDER BY
                    CAST(p.completed_tasks AS NUMERIC)
                    / NULLIF(p.total_tasks, 0)
            ) * 100, 1
        )                                                      AS percentile_in_dept

    FROM projects p
)

SELECT
    pd.project_id,
    pd.project_name,
    ds.department_name,
    pd.project_pct,
    ds.dept_avg_pct,
    ds.dept_min_pct,
    ds.dept_max_pct,

    -- Variance vs department average
    ROUND(pd.project_pct - ds.dept_avg_pct, 1)                AS variance_vs_avg,

    -- Percentile position within department
    pd.percentile_in_dept,

    -- Performance classification
    CASE
        WHEN pd.project_pct >= ds.dept_avg_pct + 10 THEN 'Outperforming'
        WHEN pd.project_pct <= ds.dept_avg_pct - 10 THEN 'Underperforming'
        ELSE                                              'Within range'
    END                                                        AS performance_vs_dept,

    -- Total projects in department for context
    ds.total_projects                                          AS dept_total_projects

FROM project_detail pd
JOIN dept_summary ds
    ON pd.department_id = ds.department_id
ORDER BY ds.department_name, pd.project_pct DESC;
