-- ============================================================
-- Query 02: Window Function Department Ranking
-- Author: Alejandra Kheng
-- Description: Ranks projects within each department using
--              window functions. Demonstrates RANK, ROW_NUMBER,
--              DENSE_RANK, LAG for trend comparison, and
--              running totals with SUM OVER PARTITION BY.
-- ============================================================

WITH project_metrics AS (
    -- Base calculation: completion rate per project
    SELECT
        p.project_id,
        p.project_name,
        d.department_name,
        p.completed_tasks,
        p.total_tasks,
        p.due_date,
        ROUND(
            CAST(p.completed_tasks AS NUMERIC)
            / NULLIF(p.total_tasks, 0) * 100, 1
        ) AS completion_pct
    FROM projects p
    JOIN departments d
        ON p.department_id = d.department_id
),

ranked_projects AS (
    SELECT
        project_id,
        project_name,
        department_name,
        completion_pct,
        due_date,
        completed_tasks,
        total_tasks,

        -- Rank within department (gaps on ties)
        RANK() OVER (
            PARTITION BY department_name
            ORDER BY completion_pct DESC
        ) AS rank_in_dept,

        -- Row number within department (no gaps, strict order)
        ROW_NUMBER() OVER (
            PARTITION BY department_name
            ORDER BY completion_pct DESC
        ) AS row_num_in_dept,

        -- Dense rank (no gaps on ties)
        DENSE_RANK() OVER (
            PARTITION BY department_name
            ORDER BY completion_pct DESC
        ) AS dense_rank_in_dept,

        -- Running total of completed tasks within department
        SUM(completed_tasks) OVER (
            PARTITION BY department_name
            ORDER BY completion_pct DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_completed,

        -- Previous project completion rate in same department
        LAG(completion_pct, 1) OVER (
            PARTITION BY department_name
            ORDER BY due_date
        ) AS prev_project_pct,

        -- Next project completion rate in same department
        LEAD(completion_pct, 1) OVER (
            PARTITION BY department_name
            ORDER BY due_date
        ) AS next_project_pct

    FROM project_metrics
)

SELECT
    project_id,
    project_name,
    department_name,
    completion_pct,
    rank_in_dept,
    dense_rank_in_dept,
    running_completed,
    prev_project_pct,
    next_project_pct,

    -- Trend vs previous project in same department
    CASE
        WHEN prev_project_pct IS NULL        THEN 'First project'
        WHEN completion_pct > prev_project_pct THEN 'Improving'
        WHEN completion_pct < prev_project_pct THEN 'Declining'
        ELSE                                      'No change'
    END AS trend_vs_previous,

    -- Top performer flag
    CASE
        WHEN rank_in_dept = 1 THEN 'Top performer'
        ELSE NULL
    END AS top_performer_flag

FROM ranked_projects
ORDER BY department_name, rank_in_dept;
