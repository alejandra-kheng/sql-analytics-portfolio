-- ============================================================
-- Query 04: Department Performance Summary
-- Author: Alejandra Kheng
-- Description: Aggregates project metrics by department with
--              CASE WHEN performance tiers, completion health
--              scoring, and at-risk project flagging.
--              Demonstrates advanced aggregation patterns
--              used in executive-level BI reporting.
-- ============================================================

WITH project_scores AS (
    -- Score each project individually first
    SELECT
        p.project_id,
        p.project_name,
        p.department_id,
        p.due_date,
        p.completed_tasks,
        p.total_tasks,
        ROUND(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100, 1
        ) AS completion_pct,

        -- Performance tier per project
        CASE
            WHEN CAST(p.completed_tasks AS NUMERIC)
                / NULLIF(p.total_tasks, 0) >= 0.90 THEN 'High'
            WHEN CAST(p.completed_tasks AS NUMERIC)
                / NULLIF(p.total_tasks, 0) >= 0.60 THEN 'On Track'
            ELSE 'At Risk'
        END AS performance_tier,

        -- Flag overdue projects
        CASE
            WHEN p.due_date < CURRENT_DATE
            AND CAST(p.completed_tasks AS NUMERIC)
                / NULLIF(p.total_tasks, 0) < 1.0
            THEN 1 ELSE 0
        END AS is_overdue

    FROM projects p
),

dept_rollup AS (
    -- Roll up to department level
    SELECT
        ps.department_id,
        COUNT(ps.project_id)                        AS total_projects,
        SUM(ps.completed_tasks)                     AS total_completed_tasks,
        SUM(ps.total_tasks)                         AS total_tasks_overall,
        ROUND(AVG(ps.completion_pct), 1)            AS avg_completion_pct,
        MAX(ps.completion_pct)                      AS highest_project_pct,
        MIN(ps.completion_pct)                      AS lowest_project_pct,

        -- Count projects by tier
        COUNT(CASE WHEN ps.performance_tier = 'High'
              THEN 1 END)                           AS high_performing_count,
        COUNT(CASE WHEN ps.performance_tier = 'On Track'
              THEN 1 END)                           AS on_track_count,
        COUNT(CASE WHEN ps.performance_tier = 'At Risk'
              THEN 1 END)                           AS at_risk_count,

        -- Count overdue
        SUM(ps.is_overdue)                          AS overdue_projects

    FROM project_scores ps
    GROUP BY ps.department_id
)

SELECT
    d.department_name,
    dr.total_projects,
    dr.avg_completion_pct,
    dr.highest_project_pct,
    dr.lowest_project_pct,
    dr.high_performing_count,
    dr.on_track_count,
    dr.at_risk_count,
    dr.overdue_projects,

    -- Overall department health score
    CASE
        WHEN dr.avg_completion_pct >= 90
         AND dr.at_risk_count = 0     THEN 'Excellent'
        WHEN dr.avg_completion_pct >= 75
         AND dr.at_risk_count <= 1    THEN 'Good'
        WHEN dr.avg_completion_pct >= 60 THEN 'Needs Attention'
        ELSE                              'Critical'
    END AS dept_health_status,

    -- At risk percentage
    ROUND(
        CAST(dr.at_risk_count AS NUMERIC)
        / NULLIF(dr.total_projects, 0) * 100, 1
    )  AS pct_projects_at_risk

FROM dept_rollup dr
JOIN departments d
    ON dr.department_id = d.department_id
ORDER BY dr.avg_completion_pct DESC;
