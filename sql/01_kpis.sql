-- =====================================================================
-- FLEET KPI ANALYSIS: 30 trucks, Jan 6 - Jul 5, 2025 (synthetic)
-- On April 7, 2025 the fleet introduced two changes:
--   1. Re-sequenced routes and dispatch schedules (earlier cross-border
--      departures, GTA runs moved out of rush hour)
--   2. A preventive-maintenance (PM) program with tracked service intervals
-- "Before" = Jan 6 - Apr 6 (13 weeks); "After" = Apr 7 - Jul 5 (13 weeks).
-- On-time = delivered no more than 15 minutes after the scheduled time.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1.1  On-time delivery: before vs after
-- ---------------------------------------------------------------------
SELECT CASE WHEN dispatch_date < '2025-04-07' THEN '1 Before' ELSE '2 After' END AS period,
       COUNT(*) AS loads,
       ROUND(100.0 * SUM((julianday(actual_delivery) - julianday(scheduled_delivery)) * 1440 <= 15) / COUNT(*), 1) AS on_time_pct,
       ROUND(AVG(MAX(0, (julianday(actual_delivery) - julianday(scheduled_delivery)) * 1440)), 1) AS avg_minutes_late
FROM loads
GROUP BY period;


-- ---------------------------------------------------------------------
-- 1.2  On-time % by week (trend)
-- ---------------------------------------------------------------------
SELECT CAST((julianday(dispatch_date) - julianday('2025-01-06')) / 7 AS INTEGER) + 1 AS week,
       COUNT(*) AS loads,
       ROUND(100.0 * SUM((julianday(actual_delivery) - julianday(scheduled_delivery)) * 1440 <= 15) / COUNT(*), 1) AS on_time_pct
FROM loads
GROUP BY week
ORDER BY week;


-- ---------------------------------------------------------------------
-- 1.3  On-time % by lane type: before vs after
-- ---------------------------------------------------------------------
SELECT l.lane_type,
       ROUND(100.0 * SUM(CASE WHEN d.dispatch_date < '2025-04-07' AND (julianday(d.actual_delivery) - julianday(d.scheduled_delivery)) * 1440 <= 15 THEN 1 ELSE 0 END)
             / SUM(d.dispatch_date < '2025-04-07'), 1) AS before_pct,
       ROUND(100.0 * SUM(CASE WHEN d.dispatch_date >= '2025-04-07' AND (julianday(d.actual_delivery) - julianday(d.scheduled_delivery)) * 1440 <= 15 THEN 1 ELSE 0 END)
             / SUM(d.dispatch_date >= '2025-04-07'), 1) AS after_pct
FROM loads d
JOIN lanes l ON l.lane_id = d.lane_id
GROUP BY l.lane_type
ORDER BY before_pct;


-- ---------------------------------------------------------------------
-- 1.4  On-time % by lane before the change (which lanes were weakest?)
-- ---------------------------------------------------------------------
SELECT l.destination, l.lane_type,
       COUNT(*) AS loads,
       ROUND(100.0 * SUM((julianday(d.actual_delivery) - julianday(d.scheduled_delivery)) * 1440 <= 15) / COUNT(*), 1) AS on_time_pct
FROM loads d
JOIN lanes l ON l.lane_id = d.lane_id
WHERE d.dispatch_date < '2025-04-07'
GROUP BY l.lane_id
ORDER BY on_time_pct;

-- ---------------------------------------------------------------------
-- 2.1  Unplanned downtime and maintenance cost: before vs after
-- ---------------------------------------------------------------------
SELECT CASE WHEN event_date < '2025-04-07' THEN '1 Before' ELSE '2 After' END AS period,
       SUM(event_type = 'Preventive')                          AS pm_services,
       SUM(event_type = 'Unplanned')                           AS breakdowns,
       ROUND(SUM(CASE WHEN event_type = 'Unplanned' THEN downtime_hours ELSE 0 END)) AS unplanned_downtime_hrs,
       ROUND(SUM(CASE WHEN event_type = 'Preventive' THEN downtime_hours ELSE 0 END)) AS planned_downtime_hrs,
       SUM(CASE WHEN event_type = 'Unplanned' THEN cost_cad ELSE 0 END)  AS unplanned_cost_cad,
       SUM(CASE WHEN event_type = 'Preventive' THEN cost_cad ELSE 0 END) AS pm_cost_cad
FROM maintenance_events
GROUP BY period;


-- ---------------------------------------------------------------------
-- 2.2  Breakdowns by category
-- ---------------------------------------------------------------------
SELECT category,
       COUNT(*) AS breakdowns,
       ROUND(AVG(downtime_hours), 1) AS avg_downtime_hrs,
       SUM(cost_cad) AS total_cost_cad
FROM maintenance_events
WHERE event_type = 'Unplanned'
GROUP BY category
ORDER BY breakdowns DESC;


-- ---------------------------------------------------------------------
-- 2.3  Breakdowns by truck age (model year)
-- ---------------------------------------------------------------------
SELECT CASE WHEN t.model_year <= 2018 THEN '2016-2018'
            WHEN t.model_year <= 2020 THEN '2019-2020'
            ELSE '2021-2023' END AS model_years,
       COUNT(DISTINCT t.truck_id) AS trucks,
       SUM(m.event_type = 'Unplanned') AS breakdowns,
       ROUND(1.0 * SUM(m.event_type = 'Unplanned') / COUNT(DISTINCT t.truck_id), 1) AS breakdowns_per_truck
FROM trucks t
LEFT JOIN maintenance_events m ON m.truck_id = t.truck_id
GROUP BY model_years
ORDER BY model_years;


-- ---------------------------------------------------------------------
-- 3.1  Fleet utilization: loads and km per truck per week, before vs after
-- ---------------------------------------------------------------------
SELECT CASE WHEN dispatch_date < '2025-04-07' THEN '1 Before' ELSE '2 After' END AS period,
       COUNT(*) AS loads,
       SUM(distance_km) AS total_km,
       ROUND(COUNT(*) / 30.0 / 13, 1)          AS loads_per_truck_per_week,
       ROUND(SUM(distance_km) / 30.0 / 13)     AS km_per_truck_per_week
FROM loads
GROUP BY period;


-- ---------------------------------------------------------------------
-- 3.2  Trucks with the most unplanned downtime (review / replace)
-- ---------------------------------------------------------------------
SELECT t.truck_id, t.make_model, t.model_year,
       COUNT(*) AS breakdowns,
       ROUND(SUM(m.downtime_hours)) AS downtime_hrs,
       SUM(m.cost_cad) AS cost_cad
FROM maintenance_events m
JOIN trucks t ON t.truck_id = m.truck_id
WHERE m.event_type = 'Unplanned'
GROUP BY t.truck_id
ORDER BY downtime_hrs DESC
LIMIT 5;
