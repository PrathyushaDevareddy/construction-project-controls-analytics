-- 1. Project cost status summary
SELECT
    p.project_id,
    p.project_name,
    p.baseline_budget,
    SUM(c.planned_cost) AS planned_cost,
    SUM(c.actual_cost) AS actual_cost,
    SUM(c.planned_cost) - SUM(c.actual_cost) AS cost_variance
FROM projects p
JOIN cost_actuals c
    ON p.project_id = c.project_id
GROUP BY
    p.project_id,
    p.project_name,
    p.baseline_budget
ORDER BY cost_variance ASC;

-- 2. Schedule risk by project
SELECT
    p.project_id,
    p.project_name,
    COUNT(*) AS total_tasks,
    SUM(CASE WHEN s.task_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_tasks,
    AVG(s.percent_complete) AS avg_percent_complete
FROM projects p
JOIN schedule_tasks s
    ON p.project_id = s.project_id
GROUP BY
    p.project_id,
    p.project_name
ORDER BY delayed_tasks DESC;

-- 3. Resource hour variance by discipline
SELECT
    discipline,
    SUM(planned_hours) AS planned_hours,
    SUM(actual_hours) AS actual_hours,
    SUM(actual_hours) - SUM(planned_hours) AS hour_variance
FROM resource_hours
GROUP BY discipline
ORDER BY hour_variance DESC;

-- 4. Procurement late-risk report
SELECT
    p.project_name,
    pr.po_id,
    pr.vendor,
    pr.discipline,
    pr.need_by_date,
    pr.expected_delivery_date,
    pr.delivery_status,
    pr.committed_cost
FROM procurement_log pr
JOIN projects p
    ON pr.project_id = p.project_id
WHERE pr.delivery_status = 'Late Risk'
ORDER BY pr.expected_delivery_date;

-- 5. Integrated project risk indicator
SELECT
    p.project_id,
    p.project_name,
    SUM(c.actual_cost) AS actual_cost,
    SUM(c.planned_cost) AS planned_cost,
    SUM(CASE WHEN s.task_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_tasks,
    SUM(CASE WHEN pr.delivery_status = 'Late Risk' THEN 1 ELSE 0 END) AS late_pos,
    CASE
        WHEN SUM(c.actual_cost) > SUM(c.planned_cost) THEN 'Cost Risk'
        WHEN SUM(CASE WHEN s.task_status = 'Delayed' THEN 1 ELSE 0 END) >= 4 THEN 'Schedule Risk'
        WHEN SUM(CASE WHEN pr.delivery_status = 'Late Risk' THEN 1 ELSE 0 END) >= 3 THEN 'Procurement Risk'
        ELSE 'On Track'
    END AS project_risk_status
FROM projects p
LEFT JOIN cost_actuals c
    ON p.project_id = c.project_id
LEFT JOIN schedule_tasks s
    ON c.task_id = s.task_id
LEFT JOIN procurement_log pr
    ON s.task_id = pr.task_id
GROUP BY
    p.project_id,
    p.project_name
ORDER BY project_risk_status;

-- 6. View for Power BI or Excel reporting
CREATE VIEW vw_project_status_summary AS
SELECT
    p.project_id,
    p.project_name,
    p.location,
    p.project_type,
    p.status,
    p.baseline_budget,
    SUM(c.planned_cost) AS planned_cost,
    SUM(c.actual_cost) AS actual_cost,
    SUM(c.planned_cost) - SUM(c.actual_cost) AS cost_variance,
    AVG(s.percent_complete) AS avg_percent_complete,
    SUM(CASE WHEN s.task_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_tasks
FROM projects p
JOIN cost_actuals c
    ON p.project_id = c.project_id
JOIN schedule_tasks s
    ON c.task_id = s.task_id
GROUP BY
    p.project_id,
    p.project_name,
    p.location,
    p.project_type,
    p.status,
    p.baseline_budget;
