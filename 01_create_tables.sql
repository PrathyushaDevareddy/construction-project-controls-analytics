CREATE TABLE projects (
    project_id VARCHAR(20) PRIMARY KEY,
    project_name VARCHAR(100),
    location VARCHAR(50),
    project_type VARCHAR(50),
    status VARCHAR(30),
    start_date DATE,
    planned_finish_date DATE,
    baseline_budget DECIMAL(14, 2)
);

CREATE TABLE schedule_tasks (
    task_id VARCHAR(30) PRIMARY KEY,
    project_id VARCHAR(20),
    task_name VARCHAR(100),
    discipline VARCHAR(50),
    planned_start DATE,
    planned_finish DATE,
    actual_finish DATE,
    percent_complete DECIMAL(6, 2),
    task_status VARCHAR(30),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE cost_actuals (
    project_id VARCHAR(20),
    task_id VARCHAR(30),
    cost_category VARCHAR(50),
    planned_cost DECIMAL(14, 2),
    actual_cost DECIMAL(14, 2),
    cost_variance DECIMAL(14, 2),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (task_id) REFERENCES schedule_tasks(task_id)
);

CREATE TABLE resource_hours (
    project_id VARCHAR(20),
    task_id VARCHAR(30),
    discipline VARCHAR(50),
    planned_hours INT,
    actual_hours INT,
    hour_variance INT,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (task_id) REFERENCES schedule_tasks(task_id)
);

CREATE TABLE procurement_log (
    po_id VARCHAR(30) PRIMARY KEY,
    project_id VARCHAR(20),
    task_id VARCHAR(30),
    vendor VARCHAR(100),
    discipline VARCHAR(50),
    po_value DECIMAL(14, 2),
    committed_cost DECIMAL(14, 2),
    need_by_date DATE,
    expected_delivery_date DATE,
    delivery_status VARCHAR(30),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (task_id) REFERENCES schedule_tasks(task_id)
);
